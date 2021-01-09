local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_Options = TorghastTeams:NewModule("TGT_Options", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")
local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0");


local options = {
    type = "group",
    args = {
        minimap = {
            name = "Show Minimap Button",
            desc = "Enables / disables the minimap button",
            type = "toggle",
            get = function(info) return not TorghastTeams.db.profile.minimap.hide end,
            set = function(info, val) 
                TorghastTeams.db.profile.minimap.hide = not val
                if val then 
                    TorghastTeams.icon:Show("TorghastTeamsIcon") 
                else 
                    TorghastTeams.icon:Hide("TorghastTeamsIcon") 
                end
            end,
        },
        ui={
            name = "User Interface",
            type = "group",
            order = 1,
            args={
                simplemode = {
                    name = "Test Option",
                    desc = "Enables / disables the minimap button",
                    type = "toggle",
                    get = function(info) return not TorghastTeams.db.profile.simple end,
                    set = function(info, val) 
                        TorghastTeams.db.profile.simple = not val
                        if val then 
                            TorghastTeams.icon:Show("TorghastTeamsIcon") 
                        else 
                            TorghastTeams.icon:Hide("TorghastTeamsIcon") 
                        end
                    end,
                },
            }
        },
        animapowers={
            name = "Anima Powers",
            type = "group",
            order = 2,
            args={
            -- more options go here
            }
        }
    }
}


function TGT_Options:OnInitialize()
    config:RegisterOptionsTable("TorghastTeams", options, {"torghastteams","tgt"});
	dialog:AddToBlizOptions("TorghastTeams");
end


function TGT_Options:OnEnable()

end

