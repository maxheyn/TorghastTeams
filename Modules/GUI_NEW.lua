local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_GUI_NEW = TorghastTeams:NewModule("TGT_GUI_NEW", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")
local AceGUI = LibStub("AceGUI-3.0")
local lwin = LibStub("LibWindow-1.1")

-- Table containing information for the various tabs
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
        value="tabSettings",
        text="Settings",
    },
    {
        value="tabChangelog",
        text="Changelog",
    },
}

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

local function TabStatistics(container)
    
end

local function TabHelp(container)
    
end

local function TabSettings(container)
    
end

local function TabChangelog(container)
    -- local scrollContainer = AceGUI:Create("SimpleGroup")
    -- scrollContainer:SetFullWidth(true)
    -- scrollContainer:SetFullHeight(true)
    -- scrollContainer:SetLayout("Fill")
    -- container:AddChild(scrollContainer)
    
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    scrollFrame:SetLayout("Flow")
    container:AddChild(scrollFrame)
    -- scrollContainer:AddChild(scrollFrame)

    local changelog = AceGUI:Create("Label")
    changelog:SetText("Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?\n\nAt vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    changelog:SetRelativeWidth(1)
    scrollFrame:AddChild(changelog)
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
    elseif (group == "tabSettings") then
        TabSettings(container)
    elseif (group == "tabChangelog") then
        TabChangelog(container)
    end
end

function TGT_GUI_NEW:CreateTabs()
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs(tabInfo)
    tabs:SetCallback("OnGroupSelected", SelectGroup)
    tabs:SelectTab("tabWelcome")
    self.frame:AddChild(tabs)
end

