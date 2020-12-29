local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_GUI = TorghastTeams:NewModule("TGT_GUI", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")

function TGT_GUI:OnEnable()
	-- Initialing some important variables
	self.TGT_Container = CreateFrame("Frame", "self.TGT_Container", UIParent, "TGTInterface")
	self.TGT_Container:SetPoint("CENTER", UIParent, "CENTER")
	self.AnimaPowersList = {}
	self.SIMPLE_STATE = false
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
	self.TGT_Container.Tagline:SetText(L["DEFAULT_BODY_TAGLINE"])
	self.TGT_Container.BodyContainer.Welcome:SetText(L["CHANGELOG"] .. "\n\n" .. L["DEFAULT_BODY_WELCOME"])
	self.TGT_Container.BodyContainer.Information:SetText(L["DEFAULT_BODY_INFORMATION"])
	self.TGT_Container.BodyContainer.Commands:SetText(L["DEFAULT_BODY_COMMANDS"] .. "\n\n- " .. L["COMMAND_MINIMAP_EXAMPLE"] .. "\n\n- " .. L["COMMAND_SHOW_EXAMPLE"] .. "\n\n- " .. L["COMMAND_HIDE_EXAMPLE"])
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
		self.SIMPLE_STATE = false
	end
end

-- Hides all simple state frames
function TGT_GUI:HideSimpleState(partyMemberCount)
	if (IsInJailersTower()) then
		for partyMemberIndex = 0, partyMemberCount - 1, 1 do
			self.AnimaPowersList["ALT" .. partyMemberIndex]:Hide()
		end
		self.SIMPLE_STATE = true
	end
end

-- Turns simple state on and off
function TGT_GUI:ToggleSimpleState(partyMemberCount)
	if (IsInJailersTower()) then 
		if (self.SIMPLE_STATE) then
			self.TGT_Container:Hide()
			self:ShowSimpleState(partyMemberCount)
		elseif (not self.SIMPLE_STATE) then
			self.TGT_Container:Show()
			self:HideSimpleState(partyMemberCount)
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
function TGT_GUI:CreateAnimaPowerFrames(frameType)
	if (not (frameType == "DEF" or frameType == "ALT")) then print("CreateAnimaPowerFrames: Invalid frame type, must be 'DEF' or 'ALT'") return end

	for partyMemberIndex = 0, 4, 1 do
		if (frameType == "DEF") then 
			self.AnimaPowersList[frameType .. partyMemberIndex] = CreateFrame("Button", "TGT_" .. frameType .. partyMemberIndex, self.TGT_Container, "TGTMawBuffsContainer")
		elseif (frameType == "ALT") then
			self.AnimaPowersList[frameType .. partyMemberIndex] = CreateFrame("Button", "TGT_" .. frameType .. partyMemberIndex, UIParent, "TGTMawBuffsContainer")
			self.AnimaPowersList[frameType .. partyMemberIndex]:SetMovable(true)
			self.AnimaPowersList[frameType .. partyMemberIndex].isMovable = "true"
			self.AnimaPowersList[frameType .. partyMemberIndex]:EnableMouse(true)
		end
		self.AnimaPowersList[frameType .. partyMemberIndex]:SetSize(220, 50)

		-- This is probably really stupid but it's used to differentiate between containers later
		-- in the TCG_MawBuffs.lua file in the MaxBuffMixin:RefreshTooltip() function
		-- It was 'necessary' because otherwise the tooltips would overlap because there was no
		-- other easy way to differentiate between frames
		local magicNumber = 5554654
		self.AnimaPowersList[frameType .. partyMemberIndex]:SetID(magicNumber + partyMemberIndex)
		self.AnimaPowersList[frameType .. partyMemberIndex]:Update()
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

		self.AnimaPowersList[frameType .. "PMC4"]:Hide()
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