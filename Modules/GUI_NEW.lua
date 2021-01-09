local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_GUI_NEW = TorghastTeams:NewModule("TGT_GUI_NEW", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")
local AceGUI = LibStub("AceGUI-3.0")
local lwin = LibStub("LibWindow-1.1")

-- Called when this module is enabled
-- Usually on load unless manually disabled elsewhere
function TGT_GUI_NEW:OnEnable()
    self:SetupFrame()
end

-- Creates our main frame with tabs and everything
function TGT_GUI_NEW:SetupFrame()
    self.frame = AceGUI:Create("Frame")
    self.frame:SetTitle(L["ADDON_NAME_COLORED"] .. " v" .. GetAddOnMetadata("TorghastTeams", "VERSION"))
    self.frame:EnableResize(true)
    self.frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    self.frame:SetLayout("Fill")
    self:CreateTabs()
end


local function TabWelcome(container)
    local desc = AceGUI:Create("Label")
    desc:SetText("This is Tab 1")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    local button = AceGUI:Create("Button")
    button:SetText("Tab 1 Button")
    button:SetWidth(200)
    container:AddChild(button)
end

local function TabAnimaPowers(container)
    local desc = AceGUI:Create("Label")
    desc:SetText("This is Tab 2")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    local button = AceGUI:Create("Button")
    button:SetText("Tab 2 Button")
    button:SetWidth(200)
    container:AddChild(button)
end

local function TabStatistics()
    
end

local function TabHelp()
    
end

local function TabChangelog()
    
end

local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if (group == "tabWelcome") then
        TabWelcome(container)
    elseif (group == "tabAnimaPowers") then
        TabAnimaPowers(container)
    elseif (group == "tabStatistics") then
        TabStatistics(container)
    elseif (group == "tabHelp") then
        TabHelp(container)
    elseif (group == "tabChangelog") then
        TabChangelog(container)
    end
end

function TGT_GUI_NEW:CreateTabs()
    local tabs = AceGUI:Create("TabGroup")
    local tabInfo = {
        {   
            value="tabWelcome",
            text="Welcome",
        },
        {
            value="tabAnimaPowers",
            text="Anima Powers",
        },
        {
            value="tabStatistics",
            text="Statistics",
        },
        {
            value="tabHelp",
            text="Tips/Help",
        },
        {
            value="tabChangelog",
            text="Changelog",
        },
    }
    tabs:SetLayout("Flow")
    tabs:SetTabs(tabInfo)
    tabs:SetCallback("OnGroupSelected", SelectGroup)
    tabs:SelectTab("tabWelcome")
    self.frame:AddChild(tabs)
end

