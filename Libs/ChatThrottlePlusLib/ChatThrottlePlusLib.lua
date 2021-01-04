--
-- ChatThrottlePlusLib by Strucker
-- Expansion of ChatThrottleLib by Mikk
--
-- Manages AddOn chat output to keep player from getting kicked off.
--
-- ChatThrottlePlusLib:SendChatMessage 
-- (priority, prefix, text, chattype, language, destination, queueName, callbackFn, callbackArg)
-- ChatThrottlePlusLib:SendAddonMessage 
-- (priority, prefix, text, chattype, target, queueName, callbackFn, callbackArg)
-- ChatThrottlePlusLib:SendAddonMessageLogged
-- (priority, prefix, text, chattype, target, queueName, callbackFn, callbackArg)
-- ChatThrottlePlusLib:BNSendGameData 
-- (priority, prefix, text, bnetIDAccount, queueName, callbackFn, callbackArg)
--
-- Possible Priorities ("BULK", "NORMAL", "ALERT").
--
-- Priorities get an equal share of available bandwidth when fully loaded.
-- Communication channels are separated on extension+chattype+destination and
-- get round-robinned. (Destination only matters for whispers and channels,
-- obviously)
--
-- Installs hooks for to measure bandwidth bypassing the library and use less bandwidth itself.
--
-- Fully embeddable library. Just copy this file into your addon directory,
-- add it to the .toc, and it's done.
--
-- Can run as a standalone addon also, but, really, just embed it! :-)
--

local CTL_VERSION = 112

local _G = _G

if _G.ChatThrottlePlusLib and _G.ChatThrottlePlusLib.version >= CTL_VERSION then
	-- There's already a newer (or same) version loaded. Buh-bye.
	return
end

if not _G.ChatThrottlePlusLib then
	_G.ChatThrottlePlusLib = {}
end

ChatThrottlePlusLib = _G.ChatThrottlePlusLib  -- in case some addon does "local ChatThrottlePlusLib" above us and we're copypasted (AceComm-2, sigh)
local ChatThrottlePlusLib = _G.ChatThrottlePlusLib

ChatThrottlePlusLib.version = CTL_VERSION

------------------ TWEAKABLES -----------------
ChatThrottlePlusLib.MAX_CPS = 800			  -- 2000 seems to be safe if NOTHING ELSE is happening. let's call it 800.
ChatThrottlePlusLib.MSG_OVERHEAD = 40		-- Guesstimate overhead for sending a message; source+dest+chattype+protocolstuff
ChatThrottlePlusLib.BURST = 4000				-- WoW's server buffer seems to be about 32KB. 8KB should be safe, but seen disconnects on _some_ servers. Using 4KB now.
ChatThrottlePlusLib.MIN_FPS = 20				-- Reduce output CPS to half (and don't burst) if FPS drops below this value

local setmetatable = setmetatable
local table_remove = table.remove
local tostring = tostring
local GetTime = GetTime
local math_min = math.min
local math_max = math.max
local next = next
local strlen = string.len
local GetFrameRate = GetFrameRate

-----------------------------------------------------------------------
-- Double-linked ring implementation

local Ring = {}
local RingMeta = { __index = Ring }

function Ring:New()
	local ret = {}
	setmetatable(ret, RingMeta)
	return ret
end

function Ring:Add(obj)	-- Append at the "far end" of the ring (aka just before the current position)
	if self.pos then
		obj.prev = self.pos.prev
		obj.prev.next = obj
		obj.next = self.pos
		obj.next.prev = obj
	else
		obj.next = obj
		obj.prev = obj
		self.pos = obj
	end
end

function Ring:Remove(obj)
	obj.next.prev = obj.prev
	obj.prev.next = obj.next
	if self.pos == obj then
		self.pos = obj.next
		if self.pos == obj then
			self.pos = nil
		end
	end
end

-----------------------------------------------------------------------
-- Recycling bin for pipes 
-- A pipe is a plain integer-indexed queue, which also happens to be a ring member

ChatThrottlePlusLib.PipeBin = nil -- pre-v19, drastically different
local PipeBin = setmetatable({}, {__mode="k"})

local function DelPipe(pipe)
	for i = #pipe, 1, -1 do
		pipe[i] = nil
	end
	pipe.prev = nil
	pipe.next = nil

	PipeBin[pipe] = true
end

local function NewPipe()
	local pipe = next(PipeBin)
	if pipe then
		PipeBin[pipe] = nil
		return pipe
	end
	return {}
end

-----------------------------------------------------------------------
-- Recycling bin for messages

ChatThrottlePlusLib.MsgBin = nil -- pre-v19, drastically different
local MsgBin = setmetatable({}, {__mode="k"})

local function DelMsg(msg)
	msg[1] = nil
	-- there's more parameters, but they're very repetetive so the string pool doesn't suffer really, and it's faster to just not delete them.
	MsgBin[msg] = true
end

local function NewMsg()
	local msg = next(MsgBin)
	if msg then
		MsgBin[msg] = nil
		return msg
	end
	return {}
end


-----------------------------------------------------------------------
-- ChatThrottlePlusLib:Init
-- Initialize queues, set up frame for OnUpdate, etc

function ChatThrottlePlusLib:Init()	

	-- Set up queues
	if not self.Prio then
		self.Prio = {}
		self.Prio["ALERT"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
		self.Prio["NORMAL"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
		self.Prio["BULK"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
	end

	-- v4: total send counters per priority
	for _, Prio in pairs(self.Prio) do
		Prio.nTotalSent = Prio.nTotalSent or 0
	end

	if not self.avail then
		self.avail = 0 -- v5
	end
	if not self.nTotalSent then
		self.nTotalSent = 0 -- v5
	end


	-- Set up a frame to get OnUpdate events
	if not self.Frame then
		self.Frame = CreateFrame("Frame")
		self.Frame:Hide()
	end
	self.Frame:SetScript("OnUpdate", self.OnUpdate)
	self.Frame:SetScript("OnEvent", self.OnEvent)	-- v11: Monitor P_E_W so we can throttle hard for a few seconds
	self.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.OnUpdateDelay = 0
	self.LastAvailUpdate = GetTime()
	self.HardThrottlingBeginTime = GetTime()	-- v11: Throttle hard for a few seconds after startup

	-- Hook SendChatMessage and SendAddonMessage so we can measure unpiped traffic and avoid overloads (v7)
	if not self.securelyHooked then
		self.securelyHooked = true
		--SendChatMessage
		hooksecurefunc("SendChatMessage", function(...)
			return ChatThrottlePlusLib.Hook_SendChatMessage(...)
		end)
		--SendAddonMessage
		hooksecurefunc(C_ChatInfo,"SendAddonMessage", function(...)
			return ChatThrottlePlusLib.Hook_SendAddonMessage(...)
		end)
		--SendAddonMessageLogged
		hooksecurefunc(C_ChatInfo,"SendAddonMessageLogged", function(...)
			return ChatThrottlePlusLib.Hook_SendAddonMessageLogged(...)
		end)
		--BNSendGameData
		hooksecurefunc("BNSendGameData", function(...)
			return ChatThrottlePlusLib.Hook_BNSendGameData(...)
		end)
	end
	self.nBypass = 0
end


-----------------------------------------------------------------------
-- ChatThrottlePlusLib.Hook_SendChatMessage / .Hook_SendAddonMessage

local bMyTraffic = false

function ChatThrottlePlusLib.Hook_SendChatMessage(text, chattype, language, destination, ...)
	if bMyTraffic then
		return
	end
	local self = ChatThrottlePlusLib
	local size = strlen(tostring(text or "")) + strlen(tostring(destination or "")) + self.MSG_OVERHEAD
	self.avail = self.avail - size
	self.nBypass = self.nBypass + size	-- just a statistic
end
function ChatThrottlePlusLib.Hook_SendAddonMessage(prefix, text, chattype, destination, ...)
	if bMyTraffic then
		return
	end
	local self = ChatThrottlePlusLib
	local size = tostring(text or ""):len() + tostring(prefix or ""):len();
	size = size + tostring(destination or ""):len() + self.MSG_OVERHEAD
	self.avail = self.avail - size
	self.nBypass = self.nBypass + size	-- just a statistic
end
function ChatThrottlePlusLib.Hook_SendAddonMessageLogged(prefix, text, chattype, destination, ...)
	if bMyTraffic then
		return
	end
	local self = ChatThrottlePlusLib
	local size = tostring(text or ""):len() + tostring(prefix or ""):len();
	size = size + tostring(destination or ""):len() + self.MSG_OVERHEAD
	self.avail = self.avail - size
	self.nBypass = self.nBypass + size	-- just a statistic
end
function ChatThrottlePlusLib.Hook_BNSendGameData(presenceID, prefix, text)
	if bMyTraffic then
		return
	end
	local self = ChatThrottlePlusLib
	local size = tostring(text or ""):len() + tostring(prefix or ""):len();
	size = size + tostring(presenceID or ""):len() + self.MSG_OVERHEAD
	self.avail = self.avail - size
	self.nBypass = self.nBypass + size	-- just a statistic
end



-----------------------------------------------------------------------
-- ChatThrottlePlusLib:UpdateAvail
-- Update self.avail with how much bandwidth is currently available

function ChatThrottlePlusLib:UpdateAvail()
	local now = GetTime()
	local MAX_CPS = self.MAX_CPS;
	local newavail = MAX_CPS * (now - self.LastAvailUpdate)
	local avail = self.avail

	if now - self.HardThrottlingBeginTime < 5 then
		-- First 5 seconds after startup/zoning: VERY hard clamping to avoid irritating the server rate limiter, it seems very cranky then
		avail = math_min(avail + (newavail*0.1), MAX_CPS*0.5)
		self.bChoking = true
	elseif GetFramerate() < self.MIN_FPS then		-- GetFrameRate call takes ~0.002 secs
		avail = math_min(MAX_CPS, avail + newavail*0.5)
		self.bChoking = true		-- just a statistic
	else
		avail = math_min(self.BURST, avail + newavail)
		self.bChoking = false
	end

	avail = math_max(avail, 0-(MAX_CPS*2))	-- Can go negative when someone is eating bandwidth past the lib. but we refuse to stay silent for more than 2 seconds; if they can do it, we can.

	self.avail = avail
	self.LastAvailUpdate = now

	return avail
end


-----------------------------------------------------------------------
-- Despooling logic

function ChatThrottlePlusLib:Despool(Prio)
	local ring = Prio.Ring
	while ring.pos and Prio.avail > ring.pos[1].nSize do
		local msg = table_remove(Prio.Ring.pos, 1)
		if not Prio.Ring.pos[1] then
			local pipe = Prio.Ring.pos
			Prio.Ring:Remove(pipe)
			Prio.ByName[pipe.name] = nil
			DelPipe(pipe)
		else
			Prio.Ring.pos = Prio.Ring.pos.next
		end
		Prio.avail = Prio.avail - msg.nSize
		bMyTraffic = true
		msg.f(unpack(msg, 1, msg.n))
		bMyTraffic = false
		Prio.nTotalSent = Prio.nTotalSent + msg.nSize
		DelMsg(msg)
		if msg.callbackFn then
			msg.callbackFn (msg.callbackArg)
		end
	end
end


function ChatThrottlePlusLib.OnEvent(this,event)
	-- v11: We know that the rate limiter is touchy after login. Assume that it's touchy after zoning, too.
	local self = ChatThrottlePlusLib
	if event == "PLAYER_ENTERING_WORLD" then
		self.HardThrottlingBeginTime = GetTime()	-- Throttle hard for a few seconds after zoning
		self.avail = 0
	end
end


function ChatThrottlePlusLib.OnUpdate(this,delay)
	local self = ChatThrottlePlusLib

	self.OnUpdateDelay = self.OnUpdateDelay + delay
	if self.OnUpdateDelay < 0.08 then
		return
	end
	self.OnUpdateDelay = 0

	self:UpdateAvail()

	if self.avail < 0  then
		return -- argh. some bastard is spewing stuff past the lib. just bail early to save cpu.
	end

	-- See how many of our priorities have queued messages (we only have 3, don't worry about the loop)
	local n = 0
	for prioname,Prio in pairs(self.Prio) do
		if Prio.Ring.pos or Prio.avail < 0 then 
			n = n + 1 
		end
	end

	-- Anything queued still?
	if n<1 then
		-- Nope. Move spillover bandwidth to global availability gauge and clear self.bQueueing
		for prioname, Prio in pairs(self.Prio) do
			self.avail = self.avail + Prio.avail
			Prio.avail = 0
		end
		self.bQueueing = false
		self.Frame:Hide()
		return
	end

	-- There's stuff queued. Hand out available bandwidth to priorities as needed and despool their queues
	local avail = self.avail/n
	self.avail = 0

	for prioname, Prio in pairs(self.Prio) do
		if Prio.Ring.pos or Prio.avail < 0 then
			Prio.avail = Prio.avail + avail
			if Prio.Ring.pos and Prio.avail > Prio.Ring.pos[1].nSize then
				self:Despool(Prio)
				-- Note: We might not get here if the user-supplied callback function errors out! Take care!
			end
		end
	end

end

-----------------------------------------------------------------------
-- Spooling logic

function ChatThrottlePlusLib:Enqueue(prioname, pipename, msg)
	local Prio = self.Prio[prioname]
	local pipe = Prio.ByName[pipename]
	if not pipe then
		self.Frame:Show()
		pipe = NewPipe()
		pipe.name = pipename
		Prio.ByName[pipename] = pipe
		Prio.Ring:Add(pipe)
	end

	pipe[#pipe + 1] = msg

	self.bQueueing = true
end

function ChatThrottlePlusLib:SendChatMessage(prio, prefix, text, chattype, language, destination, queueName, callbackFn, callbackArg)
	if not self or not prio or not prefix or not text or not self.Prio[prio] then
		error('Usage: ChatThrottlePlusLib:SendChatMessage("{BULK||NORMAL||ALERT}", "prefix", "text"[, "chattype"[, "language"[, "destination"]]]', 2)
	end
	if callbackFn and type(callbackFn)~="function" then
		error('ChatThrottlePlusLib:ChatMessage(): callbackFn: expected function, got '..type(callbackFn), 2)
	end

	local nSize = text:len()

	if nSize>255 then
		error("ChatThrottlePlusLib:SendChatMessage(): message length cannot exceed 255 bytes", 2)
	end

	nSize = nSize + self.MSG_OVERHEAD

	-- Check if there's room in the global available bandwidth gauge to send directly
	if not self.bQueueing and nSize < self:UpdateAvail() then
		self.avail = self.avail - nSize
		bMyTraffic = true
		_G.SendChatMessage(text, chattype, language, destination)
		bMyTraffic = false
		self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
		if callbackFn then
			callbackFn (callbackArg)
		end
		return
	end

	-- Message needs to be queued
	local msg = NewMsg()
	msg.f = _G.SendChatMessage
	msg[1] = text
	msg[2] = chattype or "SAY"
	msg[3] = language
	msg[4] = destination
	msg.n = 4
	msg.nSize = nSize
	msg.callbackFn = callbackFn
	msg.callbackArg = callbackArg

	self:Enqueue(prio, queueName or (prefix..(chattype or "SAY")..(destination or "")), msg)
end

function ChatThrottlePlusLib:SendAddonMessage(prio, prefix, text, chattype, target, queueName, callbackFn, callbackArg)
	if not self or not prio or not prefix or not text or not chattype or not self.Prio[prio] then
		error('Usage: ChatThrottlePlusLib:SendAddonMessage("{BULK||NORMAL||ALERT}", "prefix", "text", "chattype"[, "target"])', 2)
	end
	if callbackFn and type(callbackFn)~="function" then
		error('ChatThrottlePlusLib:SendAddonMessage(): callbackFn: expected function, got '..type(callbackFn), 2)
	end

	local nSize = text:len();

	if C_ChatInfo or RegisterAddonMessagePrefix then
		if nSize>255 then
			error("ChatThrottlePlusLib:SendAddonMessage(): message length cannot exceed 255 bytes", 2)
		end
	else
		nSize = nSize + prefix:len() + 1
		if nSize>255 then
			error("ChatThrottlePlusLib:SendAddonMessage(): prefix + message length cannot exceed 254 bytes", 2)
		end
	end

	nSize = nSize + self.MSG_OVERHEAD;

	-- Check if there's room in the global available bandwidth gauge to send directly
	if not self.bQueueing and nSize < self:UpdateAvail() then
		self.avail = self.avail - nSize
		bMyTraffic = true
		C_ChatInfo.SendAddonMessage(prefix, text, chattype, target)
		bMyTraffic = false
		self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
		if callbackFn then
			callbackFn (callbackArg)
		end
		return
	end

	-- Message needs to be queued
	local msg = NewMsg()
	msg.f = C_ChatInfo.SendAddonMessage
	msg[1] = prefix
	msg[2] = text
	msg[3] = chattype
	msg[4] = target
	msg.n = (target~=nil) and 4 or 3;
	msg.nSize = nSize
	msg.callbackFn = callbackFn
	msg.callbackArg = callbackArg

	self:Enqueue(prio, queueName or (prefix..chattype..(target or "")), msg)
end

function ChatThrottlePlusLib:SendAddonMessageLogged(prio, prefix, text, chattype, target, queueName, callbackFn, callbackArg)
	if not self or not prio or not prefix or not text or not chattype or not self.Prio[prio] then
		error('Usage: ChatThrottlePlusLib:SendAddonMessageLogged("{BULK||NORMAL||ALERT}", "prefix", "text", "chattype"[, "target"])', 2)
	end
	if callbackFn and type(callbackFn)~="function" then
		error('ChatThrottlePlusLib:SendAddonMessageLogged(): callbackFn: expected function, got '..type(callbackFn), 2)
	end

	local nSize = text:len();

	if C_ChatInfo or RegisterAddonMessagePrefix then
		if nSize>255 then
			error("ChatThrottlePlusLib:SendAddonMessageLogged(): message length cannot exceed 255 bytes", 2)
		end
	else
		nSize = nSize + prefix:len() + 1
		if nSize>255 then
			error("ChatThrottlePlusLib:SendAddonMessageLogged(): prefix + message length cannot exceed 254 bytes", 2)
		end
	end

	nSize = nSize + self.MSG_OVERHEAD;

	-- Check if there's room in the global available bandwidth gauge to send directly
	if not self.bQueueing and nSize < self:UpdateAvail() then
		self.avail = self.avail - nSize
		bMyTraffic = true
		C_ChatInfo.SendAddonMessageLogged(prefix, text, chattype, target)
		bMyTraffic = false
		self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
		if callbackFn then
			callbackFn (callbackArg)
		end
		return
	end

	-- Message needs to be queued
	local msg = NewMsg()
	msg.f = C_ChatInfo.SendAddonMessageLogged
	msg[1] = prefix
	msg[2] = text
	msg[3] = chattype
	msg[4] = target
	msg.n = (target~=nil) and 4 or 3;
	msg.nSize = nSize
	msg.callbackFn = callbackFn
	msg.callbackArg = callbackArg

	self:Enqueue(prio, queueName or (prefix..chattype..(target or "")), msg)
end

function ChatThrottlePlusLib:BNSendGameData(prio, prefix, text, bnetIDAccount, queueName, callbackFn, callbackArg)
	if not self or not prio or not prefix or not text or not self.Prio[prio] then
		error('Usage: ChatThrottlePlusLib:SendAddonMessage("{BULK||NORMAL||ALERT}", "prefix", "text", "bnetIDAccount"')
	end
	if callbackFn and type(callbackFn)~="function" then
		error('ChatThrottlePlusLib:SendAddonMessage(): callbackFn: expected function, got '..type(callbackFn), 2)
	end

	local nSize = text:len() + prefix:len() + 1;
	if nSize>255 then
		error("ChatThrottlePlusLib:BNSendGameData(): prefix + message length cannot exceed 254 bytes", 2)
	end

	nSize = nSize + self.MSG_OVERHEAD;

	-- Check if there's room in the global available bandwidth gauge to send directly
	if not self.bQueueing and nSize < self:UpdateAvail() then
		self.avail = self.avail - nSize
		bMyTraffic = true
		_G.BNSendGameData(bnetIDAccount, prefix, text)
		bMyTraffic = false
		self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
		if callbackFn then
			callbackFn (callbackArg)
		end
		return
	end

	-- Message needs to be queued
	local msg = NewMsg()
	msg.f = _G.BNSendGameData
	msg[1] = bnetIDAccount
	msg[2] = prefix
	msg[3] = text
	msg.n = 3;
	msg.nSize = nSize
	msg.callbackFn = callbackFn
	msg.callbackArg = callbackArg

	self:Enqueue(prio, queueName or (prefix.."BNET"..(target or "")), msg)
end

ChatThrottlePlusLib:Init()