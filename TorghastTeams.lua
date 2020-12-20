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
		if (TGT_Container:IsVisible()) then -- isVisible seems to be the problem
			print("It's visible right now dude")
			TGT_Container:Hide()
		elseif (not TGT_Container:IsVisible()) then
			TGT_Container:Show()
			print("It's totally not visible right now dude")
		end
	end
end

local function CreateAnimaPowerFrames(partyMemberCount)
	--local partyMemberCount = 5 --for debugging

	for count = 0, partyMemberCount - 1, 1 do
		print('creating frame')
		AnimaPowersList["PMC" .. count] = CreateFrame("Button", "TGT_AnimaPowersContainerPM" .. count, TGT_Container, "TGTMawBuffsContainer")
		print('capf: ' .. tostring(AnimaPowersList['PMC' .. count]))
		AnimaPowersList["PMC" .. count]:SetSize(50, 50)
		AnimaPowersList["PMC" .. count]:SetID(5554654 + count)
		AnimaPowersList["PMC" .. count]:Update()

		--AnimaPowersList["PML" .. count] = CreateFrame("Frame", "TGT_AnimaPowersListPM" .. count, AnimaPowersList["PMC" .. count], "TGTMawBuffsList")
		--AnimaPowersList["PMB" .. count] = CreateFrame("Button", "TGT_AnimaPowersBuffPM" .. count, AnimaPowersList["PML" .. count], "TGTMawBuffTemplate")
	end
	
	-- This is probably a stupid way to do it but it's the easiest way to do it
	if (partyMemberCount == 1) then
		-- Looks like:
		-- [ 1 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER")
		print('hey ' .. tostring(AnimaPowersList["PML1"]))
	elseif (partyMemberCount == 2) then
		-- Looks like:
		-- [ 1 2 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -160, 0)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 160, 0)
	elseif (partyMemberCount == 3) then
		-- Looks like:
		-- [ 1 2 ]
		-- [  3  ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -130, 95)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 0, -95)
		AnimaPowersList["PMC2"]:SetPoint("CENTER", TGT_Container, "CENTER", 130, 95)
	elseif (partyMemberCount == 4) then
		-- Looks like:
		-- [ 1 2 ]
		-- [ 3 4 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -130, 95)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 130, -95)
		AnimaPowersList["PMC2"]:SetPoint("CENTER", TGT_Container, "CENTER", -130, -95)
		AnimaPowersList["PMC3"]:SetPoint("CENTER", TGT_Container, "CENTER", 130, 95)
	elseif (partyMemberCount == 5) then
		-- Looks like:
		-- [1 2 3]
		-- [ 4 5 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -230, 95)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 0, 95)
		AnimaPowersList["PMC2"]:SetPoint("CENTER", TGT_Container, "CENTER", 230, 95)
		AnimaPowersList["PMC3"]:SetPoint("CENTER", TGT_Container, "CENTER", -115, -95)
		AnimaPowersList["PMC4"]:SetPoint("CENTER", TGT_Container, "CENTER", 115, -95)
	end
end

local function UpdateAnimaPowers(partyMemberCount)
	--local partyMemberCount = 1 --for debugging
	for currentMember = 0, partyMemberCount - 1, 1 do
		print('in update: ' .. currentMember)
		if currentMember == 0 then
			AnimaPowersList["PMC" .. currentMember]:Update(currentMember)
		else
			AnimaPowersList["PMC" .. currentMember]:UpdatePartyMember(currentMember)
		end
	end
end

-----------------------------------------------------------------------------
-- Event Listener Frame and Script
local EventFrame = CreateFrame("Frame", "EventFrame")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterUnitEvent("UNIT_AURA", "player")

EventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		if (IsInJailersTower()) then
			print("Welcome to Torghast Teams! Type '/tgt show' to see the UI.")
			local partyMembers = GetNumGroupMembers()
			CreateAnimaPowerFrames(partyMembers)
		end
	end
	if(event == "GROUP_ROSTER_UPDATE") then
		local partyMembers = GetNumGroupMembers()
	end
	if(event == "UNIT_AURA") then
		if (IsInJailersTower()) then
			local partyMembers = GetNumGroupMembers()
			UpdateAnimaPowers(partyMembers)
		end
	end
end)