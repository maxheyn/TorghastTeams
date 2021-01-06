TorghastTeams = LibStub("AceAddon-3.0"):NewAddon("TorghastTeams", "AceConsole-3.0", "AceEvent-3.0")
local TGT_GUI, TGT_Chat;
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")
local TorghastTeamsLDB = LibStub:GetLibrary("LibDataBroker-1.1", true)

local minimapBtn = TorghastTeamsLDB:NewDataObject("TorghastTeams", {
	type = "data source",
	text = "TorghastTeams",
	icon = "Interface\\ICONS\\INV_Torghast",
    OnClick = function(self, btn)
        if (btn == "LeftButton") then
			if (IsControlKeyDown()) then
				TGT_GUI:ToggleSimpleState(GetNumGroupMembers())
			else
				if (IsInJailersTower()) then
					if (TGT_GUI:IsAltFrameVisible() and TorghastTeams.db.profile.simple == true) then
						TGT_GUI:HideSimpleState(GetNumGroupMembers())
						TorghastTeams:HideInterface()
					elseif (not TGT_GUI:IsAltFrameVisible() and TorghastTeams.db.profile.simple == true) then
						TGT_GUI:ShowSimpleState(GetNumGroupMembers())
						TorghastTeams:HideInterface()
					elseif(TGT_GUI.TGT_Container:IsVisible() and TorghastTeams.db.profile.simple == false) then
						TGT_GUI:HideSimpleState(GetNumGroupMembers())
						TorghastTeams:HideInterface()
					elseif(not TGT_GUI.TGT_Container:IsVisible() and TorghastTeams.db.profile.simple == false) then
						TGT_GUI:HideSimpleState(GetNumGroupMembers())
						TorghastTeams:ShowInterface()
					end
				else
					if (TGT_GUI.TGT_Container:IsVisible()) then
						TorghastTeams:HideInterface()
					else
						TorghastTeams:ShowInterface()
					end
				end
            end
		elseif (btn == "RightButton") then
			-- Nothing yet but here incase we decide to implement it
        end
    end,
    OnTooltipShow = function(self)
        if not self or not self.AddLine then
            return
        end
        self:AddLine(L["ADDON_NAME_COLORED"])
        self:AddLine(L["MINIMAP_LEFTCLICK"], 1, 1, 1)
		self:AddLine(L["MINIMAP_CTRLLEFTCLICK"], 1, 1, 1)
    end
})

-- Commands that users can type for interaction
local options = {
    name = L["ADDON_NAME"],
    handler = TorghastTeams,
    type = "group",
    args = {
        minimap = {
            type = "execute",
            name = L["COMMAND_MINIMAP_NAME"],
            desc = L["COMMAND_MINIMAP_DESC"],
            func = "MinimapButtonToggle",
		}, show = {
			type = "execute",
			name = L["COMMAND_SHOW_NAME"],
			desc = L["COMMAND_SHOW_DESC"],
			func = "ShowInterface"
		}, hide = {
			type = "execute",
			name = L["COMMAND_HIDE_NAME"],
			desc = L["COMMAND_HIDE_DESC"],
			func = "HideInterface"
		}
	}
}

-- Minimap Icon Constructor
local icon = LibStub("LibDBIcon-1.0")
local FRAMES_HAVE_NOT_BEEN_CREATED = true

-- Ace3 Intialization
function TorghastTeams:OnInitialize()
    -- Initial Variables
    local COMMAND_PREFIX_COMPLETE = "torghastteams"
    local COMMAND_PREFIX_SHORT = "tgt"

    -- Registering Commands with prefixes
    LibStub("AceConfig-3.0"):RegisterOptionsTable("TorghastTeams", options, {COMMAND_PREFIX_COMPLETE, COMMAND_PREFIX_SHORT})

    -- Databroker things, still trying to really figure this out
    self.db = LibStub("AceDB-3.0"):New("TorghastTeamsDB", {
        profile = {
            minimap = {
                hide = false,
			},
			simple = false,
			framePos = {
				["*"] = {
					anchor = "TOPLEFT",
					x = 0,
					y = 0,
				},
			},
        }
    })
	icon:Register("TorghastTeamsIcon", minimapBtn, self.db.profile.minimap)
end

function TorghastTeams:OnEnable()
	-- Registering for events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("CHAT_MSG_PARTY")
    self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
    self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
    self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
	
	-- Getting modules from other files
	TGT_GUI = self:GetModule("TGT_GUI")
	TGT_Chat = self:GetModule("TGT_Chat")
end

-- Toggles the minimap button on or off with /tgt minimap
function TorghastTeams:MinimapButtonToggle(info)
	if self.db.profile.minimap.hide then
		print(L["ADDON_CHAT_PREFIX"] .. L["MINIMAP_SHOWN"])
		self.db.profile.minimap.hide = false
		icon:Show("TorghastTeamsIcon")
	else
		print(L["ADDON_CHAT_PREFIX"] .. L["MINIMAP_HIDDEN"])
		self.db.profile.minimap.hide = true
		icon:Hide("TorghastTeamsIcon")
	end
end

-- Shows the UI with /tgt show
function TorghastTeams:ShowInterface(info)
	TGT_GUI.TGT_Container:Show()
end

-- Hides the UI with /tgt hide
function TorghastTeams:HideInterface(info)
	TGT_GUI.TGT_Container:Hide()
end


-----------------------------------------------------------------------------
-- Event Listeners and Scripts

-- Mostly some setup whenever the player enters the world.
-- Creates some frames initially and then does some positioning
-- depending on whether or not the player is in Torghast.
function TorghastTeams:PLAYER_ENTERING_WORLD()
	local partyMembers = GetNumGroupMembers()
	if (FRAMES_HAVE_NOT_BEEN_CREATED) then
		--TGT_GUI:CreateAnimaPowerFrames("DEF")
		TGT_GUI:CreateAnimaPowerFrames("ALT")
		FRAMES_HAVE_NOT_BEEN_CREATED = false
	end
	if (IsInJailersTower()) then
		TGT_GUI:PositionFramesByPartySize("DEF", partyMembers)
		--TGT_GUI:PositionFramesByPartySize("ALT", partyMembers)
		TGT_GUI:SetInterfaceToPlayingState()
		TGT_GUI:UpdateAnimaPowers("DEF", partyMembers)
		TGT_GUI:UpdateAnimaPowers("ALT", partyMembers)
	else
		-- TGT_GUI:UpdateAnimaPowers("DEF", partyMembers)
		-- TGT_GUI:UpdateAnimaPowers("ALT", partyMembers)
		TGT_GUI:SetInterfaceToDefaultState()
	end
end

-- Resize the frames dependin on current group size, incase
-- someone leaves you Torghast run. Sadge :/
function TorghastTeams:GROUP_ROSTER_UPDATE()
	if (IsInJailersTower()) then
		local partyMembers = GetNumGroupMembers()
		TGT_GUI:PositionFramesByPartySize("DEF", partyMembers)
	end
end

-- This is the most important event, it triggers every time a player
-- selects a new anima power.
function TorghastTeams:UNIT_AURA()
	if (IsInJailersTower()) then
		local partyMembers = GetNumGroupMembers()
		TGT_GUI:UpdateAnimaPowers("DEF", partyMembers)
		TGT_GUI:UpdateAnimaPowers("ALT", partyMembers)
	end
end

function TorghastTeams:CHAT_MSG_PARTY(self, msg, sender)
	if (IsInJailersTower()) then
		TGT_Chat:BroadcastPhantasma(msg, sender, "PARTY")
	end
end

function TorghastTeams:CHAT_MSG_PARTY_LEADER(self, msg, sender)
	if (IsInJailersTower()) then
		TGT_Chat:BroadcastPhantasma(msg, sender, "PARTY")
	end
end

function TorghastTeams:CHAT_MSG_INSTANCE_CHAT(self, msg, sender)
	if (IsInJailersTower()) then
		TGT_Chat:BroadcastPhantasma(msg, sender, "INSTANCE_CHAT")
	end
end

function TorghastTeams:CHAT_MSG_INSTANCE_CHAT_LEADER(self, msg, sender)
	if (IsInJailersTower()) then
		TGT_Chat:BroadcastPhantasma(msg, sender, "INSTANCE_CHAT")
	end
end