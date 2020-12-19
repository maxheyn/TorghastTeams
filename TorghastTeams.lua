
local function createAnimaPowerFrames(partyMemberCount)
	local TGT_MawBuffsContainer = CreateFrame("Frame", "TGT_ContainerFrame", UIParent, "TGTTorghastLevelPickerFrame")
	TGT_MawBuffsContainer:SetSize(807, 569)
	TGT_MawBuffsContainer:SetPoint("CENTER", UIParent, "CENTER")
	
	for count = 0, partyMemberCount, 1 do
		local AnimaPowersList = CreateFrame("Frame", "TorghastTeams_AnimaPowerGroupmate" .. count, TGT_MawBuffsContainer, "TGTMawBuffsList")
		AnimaPowersList:SetSize(268, 159)
		AnimaPowersList:SetPoint("LEFT", TGT_MawBuffsContainer, "LEFT")
	end
	
	SLASH_TORGHASTTEAMS1 = "/tgt"
	
	SlashCmdList["TORGHASTTEAMS"] = function(msg)
		if (msg == nil) then
			-- toggle implement here pls
		elseif (msg == "show") then
			TGT_MawBuffsContainer:Show()
		elseif (msg == "hide") then
			TGT_MawBuffsContainer:Hide()
		end
	end
end

-----------------------------------------------------------------------------
-- Event Listener Frame
local EventFrame = CreateFrame("Frame", "EventFrame")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

EventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "GROUP_ROSTER_UPDATE") then
		local members = GetNumGroupMembers();
		print("GROUP MEMBERS: " .. members)
		createAnimaPowerFrames(members)
	end
end)