local TorghastTeams = LibStub("AceAddon-3.0"):NewAddon("TorghastTeams", "AceConsole-3.0", "AceEvent-3.0")
local TorghastTeamsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("TorghastTeams", {
	type = "String",
	text = "TorghastTeams",
	icon = "Interface\\ICONS\\INV_Torghast",
	OnClick = function()
		if (TGT_Container:IsVisible()) then
			TGT_Container:Hide()
		elseif (not TGT_Container:IsVisible()) then
			TGT_Container:Show()
		end
	end,
})

-- Commands that users can type
local options = {
    name = "TorghastTeams",
    handler = TorghastTeams,
    type = "group",
    args = {
        minimap = {
            type = "execute",
            name = "Minimap Button Toggle",
            desc = "Toggles the display of the minimap button.",
            func  = "ToggleMinimapButtonShown",
		},
    },
}

-- Minimap Icon Constructor
local icon = LibStub("LibDBIcon-1.0")

-- Frame Setup for Anima Powers
local TGT_Container = CreateFrame("Frame", "TGT_Container", UIParent, "TGTTorghastLevelPickerFrame")
TGT_Container:SetSize(807, 569)
TGT_Container:SetPoint("CENTER", UIParent, "CENTER")
local AnimaPowersList = {}

-----------------------------------------------------------------------------
-- Ace3 Intialization
function TorghastTeams:OnInitialize()
	-- Initial Variables

	-- Registering Commands with prefixes
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TorghastTeams", options, {"torghastteams", "tgt"})

	-----------------------------------------------------------------------------
	-- Slash Command
	-- SLASH_TORGHASTTEAMS1 = "/tgt"
	-- SLASH_TORGHASTTEAMS2 = "/torghastteams"
	-- SlashCmdList["TORGHASTTEAMS"] = function(msg)
	-- 	if (msg == "show") then
	-- 		TGT_Container:Show()
	-- 	elseif (msg == "hide") then
	-- 		TGT_Container:Hide()
	-- 	else
	-- 		if (TGT_Container:IsVisible()) then
	-- 			print("It's visible right now dude")
	-- 			TGT_Container:Hide()
	-- 		elseif (not TGT_Container:IsVisible()) then
	-- 			TGT_Container:Show()
	-- 			print("It's totally not visible right now dude")
	-- 		end
	-- 	end
	-- end

	self.db = LibStub("AceDB-3.0"):New("TorghastTeamsDB", {
		profile = {
			minimap = {
				hide = false,
			}
		}
	})
	icon:Register("TorghastTeamsIcon", TorghastTeamsLDB, self.db.profile.minimap)
	self:RegisterChatCommand("bunnies", "ToggleInterface")
end

function TorghastTeams:ToggleMinimapButtonShown(info)
	if self.db.profile.minimap.hide then
		print("TorghastTeams minimap button is now shown.")
		self.db.profile.minimap.hide = false
		icon:Show("TorghastTeamsIcon")
	else
		print("TorghastTeams minimap button is now hidden.")
		self.db.profile.minimap.hide = true
		icon:Hide("TorghastTeamsIcon")
	end
end


function TorghastTeams:CreateAnimaPowerFrames(partyMemberCount)
	for count = 0, partyMemberCount - 1, 1 do
		print('creating frame')
		AnimaPowersList["PMC" .. count] = CreateFrame("Button", "TGT_AnimaPowersContainerPM" .. count, TGT_Container, "TGTMawBuffsContainer")
		print('capf: ' .. tostring(AnimaPowersList['PMC' .. count]))
		AnimaPowersList["PMC" .. count]:SetSize(50, 50)

		-- This is probably really stupid but it's used to differentiate between containers later
		-- in the TCG_MawBuffs.lua file in the MaxBuffMixin:RefreshTooltip() function
		-- It was 'necessary' because otherwise the tooltips would overlap because there was no
		-- other easy way to differentiate between frames
		AnimaPowersList["PMC" .. count]:SetID(5554654 + count)
		AnimaPowersList["PMC" .. count]:Update()
	end
	
	-- Manually setting the layouts of the containers, depending on party size.
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

function TorghastTeams:UpdateAnimaPowers(partyMemberCount)
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
			TorghastTeams:CreateAnimaPowerFrames(partyMembers)
		else
			print("OUTORUOUSUSIDE.")
			local partyMembers = GetNumGroupMembers()
			TorghastTeams:UpdateAnimaPowers(partyMembers)
		end
	end
	if(event == "GROUP_ROSTER_UPDATE") then
		local partyMembers = GetNumGroupMembers()
		--TODO: update the lists if group members change during a torghast run
	end
	if(event == "UNIT_AURA") then
		if (IsInJailersTower()) then
			local partyMembers = GetNumGroupMembers()
			TorghastTeams:UpdateAnimaPowers(partyMembers)
		end
	end
end)