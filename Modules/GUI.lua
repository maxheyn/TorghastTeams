local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_GUI = TorghastTeams:NewModule("TGT_GUI", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")
local lwin = LibStub("LibWindow-1.1")

local names = {
	prefix = "TGT_Frame"
}

function TGT_GUI:OnEnable()
	-- Initialing some important variables
	self.TGT_Container = CreateFrame("Frame", "TGT_Container", UIParent, "TGTInterface")
	self.TGT_Container:SetPoint("CENTER", UIParent, "CENTER")
	self.AnimaPowersList = {}
	self.RandomTagline = math.random(#L["DEFAULT_BODY_TAGLINE"])
end

-----------------------------------------------------------------------------
-- UI Manipulation Functions

-- Toggles between the UI, not a command, used for minimap button
function TGT_GUI:ToggleInterface()
	if (self.TGT_Container:IsVisible()) then
		self.TGT_Container:Hide()
	elseif (not self.TGT_Container:IsVisible()) then
		self.TGT_Container:Show()
	end
end

-- Sets UI to "default", i.e. what you see when you're NOT in Torghast
function TGT_GUI:SetInterfaceToDefaultState()
	self.TGT_Container.Title:SetPoint("TOP", self.TGT_Container, "TOP", 170, -70)
	self.TGT_Container.Title:SetText(L["ADDON_NAME_COLORED"] .. " " .. GetAddOnMetadata("TorghastTeams", "VERSION"))
	self.TGT_Container.Tagline:SetText(L["DEFAULT_BODY_TAGLINE"][self.RandomTagline])
	self.TGT_Container.BodyContainer.Welcome:SetText(L["DEFAULT_BODY_WELCOME"])
	self.TGT_Container.BodyContainer.Prompt:SetText(L["DEFAULT_BODY_PROMPT"])
	self.TGT_Container.BodyContainer.Information:SetText(L["DEFAULT_BODY_INFORMATION"])
	self.TGT_Container.BodyContainer.Commands:SetText(L["DEFAULT_BODY_COMMANDS"])
	self.TGT_Container.BodyContainer.Changelog:SetText(L["CHANGELOG"])
	self.TGT_Container.BodyContainer:Show()

	-- Hide all anima power frames
	for partyMemberIndex = 0, 4, 1 do
		self.AnimaPowersList["DEF" .. partyMemberIndex]:Hide()
		self.AnimaPowersList["ALT" .. partyMemberIndex]:Hide()
	end
end

-- Sets UI to "playing", i.e. what you see when you're in Torghast
function TGT_GUI:SetInterfaceToPlayingState()
	self.TGT_Container.Title:SetPoint("TOP", self.TGT_Container, "TOP", 0, -70)
	self.TGT_Container.Title:SetText(L["ADDON_NAME_COLORED"] .. " " .. GetAddOnMetadata("TorghastTeams", "VERSION"))
	self.TGT_Container.Tagline:SetPoint("TOP", self.TGT_Container.Title, "BOTTOM", 0, -6)
	self.TGT_Container.Tagline:SetText(L["DEFAULT_BODY_TAGLINE"][self.RandomTagline])
	self.TGT_Container.BodyContainer:Hide()

	for partyMemberIndex = 0, 4, 1 do
		self.AnimaPowersList["ALT" .. partyMemberIndex]:Hide()
	end
end

-- Shows all simple state frames
function TGT_GUI:ShowSimpleState(partyMemberCount)
	if (IsInJailersTower()) then
		for partyMemberIndex = 0, partyMemberCount - 1, 1 do
			self.AnimaPowersList["ALT" .. partyMemberIndex]:Show()
		end
		--TorghastTeams.db.profile.simple = true
	end
end

-- Hides all simple state frames
function TGT_GUI:HideSimpleState(partyMemberCount)
	if (IsInJailersTower()) then
		for partyMemberIndex = 0, partyMemberCount - 1, 1 do
			self.AnimaPowersList["ALT" .. partyMemberIndex]:Hide()
		end
		--TorghastTeams.db.profile.simple = false
	end
end

-- Turns simple state on and off
function TGT_GUI:ToggleSimpleState(partyMemberCount)
	if (IsInJailersTower()) then 
		if (TorghastTeams.db.profile.simple == false) then
			self.TGT_Container:Hide()
			self:ShowSimpleState(partyMemberCount)
			TorghastTeams.db.profile.simple = true
			print(L["ADDON_CHAT_PREFIX"] .. L["SWITCH_MODE_DEFAULT"])
		elseif (TorghastTeams.db.profile.simple == true) then
			self.TGT_Container:Show()
			self:HideSimpleState(partyMemberCount)
			TorghastTeams.db.profile.simple = false
			print(L["ADDON_CHAT_PREFIX"] .. L["SWITCH_MODE_SIMPLE"])
			
		end
	else
		print(L["ADDON_CHAT_PREFIX"] .. L["TOGGLE_MODE_WARNING"])
	end
end

function TGT_GUI:IsAltFrameVisible()
	for partyMemberIndex = 0, 4, 1 do
		if self.AnimaPowersList["ALT" .. partyMemberIndex]:IsVisible() then return true end
	end 
end

-----------------------------------------------------------------------------
-- Main Addon Functions

-- Creates the frames inside our main self.TGT_Container holder and
-- sets their positions based on number of party members in the group.
-- args:
-- frameType: string should be either "DEF" or "ALT"
function TGT_GUI:CreateAnimaPowerFrames()
	for partyMemberIndex = 0, 4, 1 do
		self.AnimaPowersList["DEF" .. partyMemberIndex] = CreateFrame("Button", "TGT_DEF" .. partyMemberIndex, self.TGT_Container, "TGTMawBuffsContainer")
		self.AnimaPowersList["ALT" .. partyMemberIndex] = CreateFrame("Button", "TGT_ALT" .. partyMemberIndex, UIParent, "TGTMawBuffsContainer")
		self.AnimaPowersList["DEF" .. partyMemberIndex]:EnableMouse(true)
		self.AnimaPowersList["ALT" .. partyMemberIndex]:EnableMouse(true)
		self.AnimaPowersList["DEF" .. partyMemberIndex]:SetSize(220, 50)
		self.AnimaPowersList["ALT" .. partyMemberIndex]:SetSize(220, 50)

		-- This is probably really stupid but it's used to differentiate between containers later
		-- in the TCG_MawBuffs.lua file in the MaxBuffMixin:RefreshTooltip() function
		-- It was 'necessary' because otherwise the tooltips would overlap because there was no
		-- other easy way to differentiate between frames
		local magicNumber = 5554654
		self.AnimaPowersList["DEF" .. partyMemberIndex]:SetID(magicNumber + partyMemberIndex)
		self.AnimaPowersList["ALT" .. partyMemberIndex]:SetID(magicNumber + partyMemberIndex)
		self.AnimaPowersList["DEF" .. partyMemberIndex]:Update()
		self.AnimaPowersList["ALT" .. partyMemberIndex]:Update()
	end

	-- someone please tell me a better way to do this
	lwin.RegisterConfig(self.AnimaPowersList["ALT0"], TorghastTeams.db.profile.framePos.alt0, names)
	lwin.RegisterConfig(self.AnimaPowersList["ALT1"], TorghastTeams.db.profile.framePos.alt1, names)
	lwin.RegisterConfig(self.AnimaPowersList["ALT2"], TorghastTeams.db.profile.framePos.alt2, names)
	lwin.RegisterConfig(self.AnimaPowersList["ALT3"], TorghastTeams.db.profile.framePos.alt3, names)
	lwin.RegisterConfig(self.AnimaPowersList["ALT4"], TorghastTeams.db.profile.framePos.alt4, names)

	for partyMemberIndex = 0, 4, 1 do
		lwin.RestorePosition(self.AnimaPowersList["ALT" .. partyMemberIndex])
		lwin.MakeDraggable(self.AnimaPowersList["ALT" .. partyMemberIndex])
	end
end

-- Make sure that our Anima Power displays are up to date, going through
-- all available party members' powers.
-- args:
-- frameType: string should be either "DEF" or "ALT"
-- partyMemberCount: the size of the player's party
function TGT_GUI:UpdateAnimaPowers(frameType, partyMemberCount)
	if (not (frameType == "DEF" or frameType == "ALT")) then print("UpdateAnimaPowers: Invalid frame type, must be 'DEF' or 'ALT'") return end
	if (next(self.AnimaPowersList) ~= nil) then
		for partyMemberIndex = 0, partyMemberCount - 1, 1 do
			if partyMemberIndex == 0 then
				self.AnimaPowersList[frameType .. partyMemberIndex]:Update(partyMemberIndex)
			else
				self.AnimaPowersList[frameType .. partyMemberIndex]:UpdatePartyMember(partyMemberIndex)
			end
		end
	end
end

-- Manually setting the layouts of the containers, depending on party size.
function TGT_GUI:PositionFramesByPartySize(frameType, partyMemberCount)
	if (not (frameType == "DEF" or frameType == "ALT")) then print("PositionFramesByPartySize: Invalid frame type, must be 'DEF' or 'ALT'") return end

	for partyMemberIndex = 0, 4 , 1 do
		self.AnimaPowersList[frameType .. partyMemberIndex]:ClearAllPoints()
		--lwin.RestorePosition(self.AnimaPowersList[frameType .. partyMemberIndex])
	end
	
	if (partyMemberCount == 0) then
		for partyMemberIndex = 0, 4 , 1 do
			self.AnimaPowersList[frameType .. partyMemberIndex]:Hide()
		end 
	elseif (partyMemberCount == 1) then
		-- Looks like:
		-- [ 1 ]
		self.AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", 0, 75)
		self.AnimaPowersList[frameType .. "0"]:Show()

		self.AnimaPowersList[frameType .. "1"]:Hide()
		self.AnimaPowersList[frameType .. "2"]:Hide()
		self.AnimaPowersList[frameType .. "3"]:Hide()
		self.AnimaPowersList[frameType .. "4"]:Hide()
	elseif (partyMemberCount == 2) then
		-- Looks like:
		-- [ 1 2 ]
		self.AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -160, 75)
		self.AnimaPowersList[frameType .. "0"]:Show()
		self.AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 160, 75)
		self.AnimaPowersList[frameType .. "1"]:Show()

		self.AnimaPowersList[frameType .. "2"]:Hide()
		self.AnimaPowersList[frameType .. "3"]:Hide()
		self.AnimaPowersList[frameType .. "4"]:Hide()
	elseif (partyMemberCount == 3) then
		-- Looks like:
		-- [ 1 2 ]
		-- [  3  ]
		self.AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -240, 75)
		self.AnimaPowersList[frameType .. "0"]:Show()
		self.AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 0, 75)
		self.AnimaPowersList[frameType .. "1"]:Show()
		self.AnimaPowersList[frameType .. "2"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "2"]:GetParent(), "CENTER", 240, 75)
		self.AnimaPowersList[frameType .. "2"]:Show()

		self.AnimaPowersList[frameType .. "3"]:Hide()
		self.AnimaPowersList[frameType .. "4"]:Hide()
	elseif (partyMemberCount == 4) then
		-- Looks like:
		-- [ 1 2 ]
		-- [ 3 4 ]
		self.AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -160, 165)
		self.AnimaPowersList[frameType .. "0"]:Show()
		self.AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 160, -65)
		self.AnimaPowersList[frameType .. "1"]:Show()
		self.AnimaPowersList[frameType .. "2"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "2"]:GetParent(), "CENTER", -160, -65)
		self.AnimaPowersList[frameType .. "2"]:Show()
		self.AnimaPowersList[frameType .. "3"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "3"]:GetParent(), "CENTER", 160, 165)
		self.AnimaPowersList[frameType .. "3"]:Show()

		self.AnimaPowersList[frameType .. "4"]:Hide()
	elseif (partyMemberCount == 5) then
		-- Looks like:
		-- [1 2 3]
		-- [ 4 5 ]
		self.AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -230, 165)
		self.AnimaPowersList[frameType .. "0"]:Show()
		self.AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 0, 165)
		self.AnimaPowersList[frameType .. "1"]:Show()
		self.AnimaPowersList[frameType .. "2"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "2"]:GetParent(), "CENTER", 230, 165)
		self.AnimaPowersList[frameType .. "2"]:Show()
		self.AnimaPowersList[frameType .. "3"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "3"]:GetParent(), "CENTER", -115, -65)
		self.AnimaPowersList[frameType .. "3"]:Show()
		self.AnimaPowersList[frameType .. "4"]:SetPoint("CENTER", self.AnimaPowersList[frameType .. "4"]:GetParent(), "CENTER", 115, -65)
		self.AnimaPowersList[frameType .. "4"]:Show()
	end
end