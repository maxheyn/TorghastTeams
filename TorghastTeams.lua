
-- User Configuration Frame
local UIConfig = CreateFrame("Frame", "TorghastTeams_ConfigFrame", UIParent, "BasicFrameTemplateWithInset")
UIConfig:SetSize(280, 560)
UIConfig:SetPoint("RIGHT", UIParent, "RIGHT")


-----------------------------------------------------------------------------
-- Event Listener Frame
local EventFrame = CreateFrame("Frame", "EventFrame")
EventFrame:RegisterEvent("BAG_UPDATE")

EventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "BAG_UPDATE") then
		print("Working")
	end
end)