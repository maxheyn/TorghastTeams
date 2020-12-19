-- Initial Variables
local TGT_Container = CreateFrame("Frame", "TGT_Container", UIParent, "TGTTorghastLevelPickerFrame")
TGT_Container:SetSize(807, 569)
TGT_Container:SetPoint("CENTER", UIParent, "CENTER")

local AnimaPowersList = {}
local AnimaPowersListPartyMember1 = "PM1"
local AnimaPowersListPartyMember2 = "PM2"
local AnimaPowersListPartyMember3 = "PM3"
local AnimaPowersListPartyMember4 = "PM4"
local AnimaPowersListPartyMember5 = "PM5"

-----------------------------------------------------------------------------
-- Slash Command
SLASH_TORGHASTTEAMS1 = "/tgt"
SLASH_TORGHASTTEAMS2 = "/torghastteams"
SlashCmdList["TORGHASTTEAMS"] = function(msg)
	if (msg == "show") then
		TGT_Container:Show()
	elseif (msg == "hide") then
		TGT_Container:Hide()
	else -- TODO: fix me
		if (TGT_Container.isVisible()) then -- isVisible seems to be the problem
			print("It's visible right now dude")
			TGT_Container:Hide()
		elseif (not TGT_Container.isVisible()) then
			TGT_Container:Show()
			print("It's totally not visible right now dude")
		end
	end
end

local function CreateAnimaPowerFrames(partyMemberCount)
	partyMemberCount = 1 --for debugging
	for count = 1, partyMemberCount + 1, 1 do
		-- AnimaPowersList["PM" .. count] = CreateFrame("Button", "TGT_AnimaPowersPartyMember" .. count, TGT_Container, "TGTMawBuffTemplate")
		AnimaPowersList["PMC" .. count] = CreateFrame("Button", "TGT_AnimaPowersContainerPMC" .. count, TGT_Container, "TGTMawBuffsContainer")
		AnimaPowersList["PMA" .. count] = CreateFrame("Button", "TGT_AnimaPowersPMA" .. count, AnimaPowersList["PMC" .. count], "TGTMawBuffsList")
	end

	-- This is probably a stupid way to do it but it's the easiest way to do it
	if (partyMemberCount == 1) then
		-- Looks like:
		-- [ 1 ]
		AnimaPowersList["PMA1"]:SetPoint("CENTER", TGT_Container, "CENTER")
		AnimaPowersList["PMC1"]:Update()
	elseif (partyMemberCount == 2) then
		-- Looks like:
		-- [ 1 2 ]
		AnimaPowersList["PMA1"]:SetPoint("CENTER", TGT_Container, "CENTER", -160, 0)
		AnimaPowersList["PMA2"]:SetPoint("CENTER", TGT_Container, "CENTER", 160, 0)
	elseif (partyMemberCount == 3) then
		-- Looks like:
		-- [ 1 2 ]
		-- [  3  ]
		AnimaPowersList["PMA1"]:SetPoint("CENTER", TGT_Container, "CENTER", -130, 95)
		AnimaPowersList["PMA2"]:SetPoint("CENTER", TGT_Container, "CENTER", 0, -95)
		AnimaPowersList["PMA3"]:SetPoint("CENTER", TGT_Container, "CENTER", 130, 95)
	elseif (partyMemberCount == 4) then
		-- Looks like:
		-- [ 1 2 ]
		-- [ 3 4 ]
		AnimaPowersList["PMA1"]:SetPoint("CENTER", TGT_Container, "CENTER", -130, 95)
		AnimaPowersList["PMA2"]:SetPoint("CENTER", TGT_Container, "CENTER", 130, -95)
		AnimaPowersList["PMA3"]:SetPoint("CENTER", TGT_Container, "CENTER", -130, -95)
		AnimaPowersList["PMA4"]:SetPoint("CENTER", TGT_Container, "CENTER", 130, 95)
	elseif (partyMemberCount == 5) then
		-- Looks like:
		-- [1 2 3]
		-- [ 4 5 ]
		AnimaPowersList["PMA1"]:SetPoint("CENTER", TGT_Container, "CENTER", -230, 95)
		AnimaPowersList["PMA2"]:SetPoint("CENTER", TGT_Container, "CENTER", 0, 95)
		AnimaPowersList["PMA3"]:SetPoint("CENTER", TGT_Container, "CENTER", 230, 95)
		AnimaPowersList["PMA4"]:SetPoint("CENTER", TGT_Container, "CENTER", -115, -95)
		AnimaPowersList["PMA5"]:SetPoint("CENTER", TGT_Container, "CENTER", 115, -95)
	end
end

-----------------------------------------------------------------------------
-- Event Listener Frame and Script
local EventFrame = CreateFrame("Frame", "EventFrame")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("BAG_UPDATE")

EventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		if (IsInJailersTower()) then
			print("Welcome to Torghast Teams! Type /tgt show to see the UI.")
			local partyMembers = GetNumGroupMembers()
			CreateAnimaPowerFrames(partyMembers)
		end
	end
	if(event == "GROUP_ROSTER_UPDATE") then
		local partyMembers = GetNumGroupMembers()
	end
	if(event == "BAG_UPDATE") then
		print("chat msg loot")
		if (IsInJailersTower()) then
			AnimaPowersList["PMC1"]:Update()
		end
	end
end)