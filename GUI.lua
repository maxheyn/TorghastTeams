local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_GUI = TorghastTeams:NewModule("TGT_GUI", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")

local AnimaPowersList = {}
local SIMPLE_STATE = true
local TEST = "tdsf"
local TGT_Container = CreateFrame("Frame", "TGT_Container", UIParent, "TGTInterface")
TGT_Container:SetPoint("CENTER", UIParent, "CENTER")

-----------------------------------------------------------------------------
-- UI Manipulation Functions

-- Shows the UI with /tgt show
function TGT_GUI:ShowInterface(info)
	TGT_Container:Show()
end

-- Hides the UI with /tgt hide
function TGT_GUI:HideInterface(info)
	TGT_Container:Hide()
end

-- Toggles between the UI, not a command, used for minimap button
function TGT_GUI:ToggleInterface()
	if (TGT_Container:IsVisible()) then
		TGT_Container:Hide()
	elseif (not TGT_Container:IsVisible()) then
		TGT_Container:Show()
	end
end

-- Sets UI to "default", i.e. what you see when you're NOT in Torghast
function TGT_GUI:SetInterfaceToDefaultState()
	TGT_Container.Title:SetPoint("TOP", TGT_Container, "TOP", 170, -70)
	TGT_Container.Title:SetText(L["ADDON_NAME_COLORED"] .. " " .. GetAddOnMetadata("TorghastTeams", "VERSION"))
	TGT_Container.Tagline:SetText(L["DEFAULT_BODY_TAGLINE"])
	TGT_Container.BodyContainer.Welcome:SetText(L["CHANGELOG"] .. "\n\n" .. L["DEFAULT_BODY_WELCOME"])
	TGT_Container.BodyContainer.Information:SetText(L["DEFAULT_BODY_INFORMATION"])
	TGT_Container.BodyContainer.Commands:SetText(L["DEFAULT_BODY_COMMANDS"] .. "\n\n- " .. L["COMMAND_MINIMAP_EXAMPLE"] .. "\n\n- " .. L["COMMAND_SHOW_EXAMPLE"] .. "\n\n- " .. L["COMMAND_HIDE_EXAMPLE"])
	TGT_Container.BodyContainer:Show()

	-- Hide all anima power frames
	AnimaPowersList["DEF0"]:Hide()
	AnimaPowersList["DEF1"]:Hide()
	AnimaPowersList["DEF2"]:Hide()
	AnimaPowersList["DEF3"]:Hide()
	AnimaPowersList["DEF4"]:Hide()
	AnimaPowersList["ALT0"]:Hide()
	AnimaPowersList["ALT1"]:Hide()
	AnimaPowersList["ALT2"]:Hide()
	AnimaPowersList["ALT3"]:Hide()
	AnimaPowersList["ALT4"]:Hide()
end

-- Sets UI to "playing", i.e. what you see when you're in Torghast
function TGT_GUI:SetInterfaceToPlayingState()
	TGT_Container.Title:SetPoint("TOP", TGT_Container, "TOP", 0, -70)
	TGT_Container.Title:SetText(L["ADDON_NAME_COLORED"] .. " " .. GetAddOnMetadata("TorghastTeams", "VERSION"))
	TGT_Container.Tagline:SetPoint("TOP", TGT_Container.Title, "BOTTOM", 0, -6)
	TGT_Container.BodyContainer:Hide()

	AnimaPowersList["ALT0"]:Hide()
	AnimaPowersList["ALT1"]:Hide()
	AnimaPowersList["ALT2"]:Hide()
	AnimaPowersList["ALT3"]:Hide()
	AnimaPowersList["ALT4"]:Hide()
end

function TGT_GUI:ToggleSimpleState(partyMemberCount)
	if (IsInJailersTower()) then 
		if (not SIMPLE_STATE) then
			TGT_Container:Show()
			for partyMemberIndex = 0, partyMemberCount - 1, 1 do
				AnimaPowersList["ALT" .. partyMemberIndex]:SetMovable(true)
				AnimaPowersList["ALT" .. partyMemberIndex].isMovable = "true"
				AnimaPowersList["ALT" .. partyMemberIndex]:EnableMouse(true)
				AnimaPowersList["ALT" .. partyMemberIndex]:Hide()
				SIMPLE_STATE = true
			end
		else
			TGT_Container:Hide()
			for partyMemberIndex = 0, partyMemberCount - 1, 1 do
				AnimaPowersList["ALT" .. partyMemberIndex]:SetMovable(true)
				AnimaPowersList["ALT" .. partyMemberIndex].isMovable = "true"
				AnimaPowersList["ALT" .. partyMemberIndex]:EnableMouse(true)
				AnimaPowersList["ALT" .. partyMemberIndex]:Show()
				SIMPLE_STATE = false
			end
		end
	else
		print(L["ADDON_CHAT_PREFIX"] .. L["TOGGLE_MODE_WARNING"])
	end
end

function TGT_GUI:IsAltFrameVisible()
	for partyMemberIndex = 0, 4, 1 do
		if AnimaPowersList["ALT" .. partyMemberIndex]:IsVisible() then return true end
	end 
end

-----------------------------------------------------------------------------
-- Main Addon Functions

-- Creates the frames inside our main TGT_Container holder and
-- sets their positions based on number of party members in the group.
-- args:
-- frameType: string should be either "DEF" or "ALT"
function TGT_GUI:CreateAnimaPowerFrames(frameType)
	if (not (frameType == "DEF" or frameType == "ALT")) then print("CreateAnimaPowerFrames: Invalid frame type, must be 'DEF' or 'ALT'") return end

	for partyMemberIndex = 0, 4, 1 do
		if (frameType == "DEF") then 
			AnimaPowersList[frameType .. partyMemberIndex] = CreateFrame("Button", "TGT_" .. frameType .. partyMemberIndex, TGT_Container, "TGTMawBuffsContainer")
		elseif (frameType == "ALT") then
			AnimaPowersList[frameType .. partyMemberIndex] = CreateFrame("Button", "TGT_" .. frameType .. partyMemberIndex, UIParent, "TGTMawBuffsContainer")
		end
		AnimaPowersList[frameType .. partyMemberIndex]:SetSize(220, 50)

		-- This is probably really stupid but it's used to differentiate between containers later
		-- in the TCG_MawBuffs.lua file in the MaxBuffMixin:RefreshTooltip() function
		-- It was 'necessary' because otherwise the tooltips would overlap because there was no
		-- other easy way to differentiate between frames
		local magicNumber = 5554654
		AnimaPowersList[frameType .. partyMemberIndex]:SetID(magicNumber + partyMemberIndex)
		AnimaPowersList[frameType .. partyMemberIndex]:Update()
	end
	FRAMES_HAVE_NOT_BEEN_CREATED = false
end

-- Make sure that our Anima Power displays are up to date, going through
-- all available party members' powers.
-- args:
-- frameType: string should be either "DEF" or "ALT"
-- partyMemberCount: the size of the player's party
function TGT_GUI:UpdateAnimaPowers(frameType, partyMemberCount)
	if (not (frameType == "DEF" or frameType == "ALT")) then print("UpdateAnimaPowers: Invalid frame type, must be 'DEF' or 'ALT'") return end
	if (next(AnimaPowersList) ~= nil) then
		for partyMemberIndex = 0, partyMemberCount - 1, 1 do
			if partyMemberIndex == 0 then
				AnimaPowersList[frameType .. partyMemberIndex]:Update(partyMemberIndex)
			else
				AnimaPowersList[frameType .. partyMemberIndex]:UpdatePartyMember(partyMemberIndex)
			end
		end
	end
end

-- Manually setting the layouts of the containers, depending on party size.
function TGT_GUI:PositionFramesByPartySize(frameType, partyMemberCount)
	if (not (frameType == "DEF" or frameType == "ALT")) then print("PositionFramesByPartySize: Invalid frame type, must be 'DEF' or 'ALT'") return end

	for partyMemberIndex = 0, 4 , 1 do
		AnimaPowersList[frameType .. partyMemberIndex]:ClearAllPoints()
	end
	
	if (partyMemberCount == 0) then
		for partyMemberIndex = 0, 4 , 1 do
			AnimaPowersList[frameType .. partyMemberIndex]:Hide()
		end 
	elseif (partyMemberCount == 1) then
		-- Looks like:
		-- [ 1 ]
		AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", 0, 75)
		AnimaPowersList[frameType .. "0"]:Show()

		AnimaPowersList[frameType .. "1"]:Hide()
		AnimaPowersList[frameType .. "2"]:Hide()
		AnimaPowersList[frameType .. "3"]:Hide()
		AnimaPowersList[frameType .. "4"]:Hide()
	elseif (partyMemberCount == 2) then
		-- Looks like:
		-- [ 1 2 ]
		AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -160, 75)
		AnimaPowersList[frameType .. "0"]:Show()
		AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 160, 75)
		AnimaPowersList[frameType .. "1"]:Show()

		AnimaPowersList[frameType .. "2"]:Hide()
		AnimaPowersList[frameType .. "3"]:Hide()
		AnimaPowersList[frameType .. "4"]:Hide()
	elseif (partyMemberCount == 3) then
		-- Looks like:
		-- [ 1 2 ]
		-- [  3  ]
		AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -240, 75)
		AnimaPowersList[frameType .. "0"]:Show()
		AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 0, 75)
		AnimaPowersList[frameType .. "1"]:Show()
		AnimaPowersList[frameType .. "2"]:SetPoint("CENTER", AnimaPowersList[frameType .. "2"]:GetParent(), "CENTER", 240, 75)
		AnimaPowersList[frameType .. "2"]:Show()

		AnimaPowersList[frameType .. "3"]:Hide()
		AnimaPowersList[frameType .. "4"]:Hide()
	elseif (partyMemberCount == 4) then
		-- Looks like:
		-- [ 1 2 ]
		-- [ 3 4 ]
		AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -160, 165)
		AnimaPowersList[frameType .. "0"]:Show()
		AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 160, -65)
		AnimaPowersList[frameType .. "1"]:Show()
		AnimaPowersList[frameType .. "2"]:SetPoint("CENTER", AnimaPowersList[frameType .. "2"]:GetParent(), "CENTER", -160, -65)
		AnimaPowersList[frameType .. "2"]:Show()
		AnimaPowersList[frameType .. "3"]:SetPoint("CENTER", AnimaPowersList[frameType .. "3"]:GetParent(), "CENTER", 160, 165)
		AnimaPowersList[frameType .. "3"]:Show()

		AnimaPowersList[frameType .. "PMC4"]:Hide()
	elseif (partyMemberCount == 5) then
		-- Looks like:
		-- [1 2 3]
		-- [ 4 5 ]
		AnimaPowersList[frameType .. "0"]:SetPoint("CENTER", AnimaPowersList[frameType .. "0"]:GetParent(), "CENTER", -230, 165)
		AnimaPowersList[frameType .. "0"]:Show()
		AnimaPowersList[frameType .. "1"]:SetPoint("CENTER", AnimaPowersList[frameType .. "1"]:GetParent(), "CENTER", 0, 165)
		AnimaPowersList[frameType .. "1"]:Show()
		AnimaPowersList[frameType .. "2"]:SetPoint("CENTER", AnimaPowersList[frameType .. "2"]:GetParent(), "CENTER", 230, 165)
		AnimaPowersList[frameType .. "2"]:Show()
		AnimaPowersList[frameType .. "3"]:SetPoint("CENTER", AnimaPowersList[frameType .. "3"]:GetParent(), "CENTER", -115, -65)
		AnimaPowersList[frameType .. "3"]:Show()
		AnimaPowersList[frameType .. "4"]:SetPoint("CENTER", AnimaPowersList[frameType .. "4"]:GetParent(), "CENTER", 115, -65)
		AnimaPowersList[frameType .. "4"]:Show()
	end
end