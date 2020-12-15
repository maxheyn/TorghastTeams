local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("BAG_UPDATE")

EventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "BAG_UPDATE") then
		print("Working")
	end
end)