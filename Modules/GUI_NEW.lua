local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_GUI_NEW = TorghastTeams:NewModule("TGT_GUI_NEW", "AceConsole-3.0", "AceEvent-3.0")
local TGT_MawBuffs
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
        value="tabChangelog",
        text="Changelog",
    },
    {
        value="tabSettings",
        text="Settings",
    },
}

local playerTabInfo = {
    {   
        value="p1",
        text="Player 1",
    },
    {
        value="p2",
        text="Player 2",
    },
    {
        value="p3",
        text="Player 3",
    },
    {
        value="p4",
        text="Player 4",
    },
    {
        value="p5",
        text="Player 5",
    },

}

-- Called when this module is enabled
-- Usually on load unless manually disabled elsewhere
function TGT_GUI_NEW:OnEnable()
    TGT_MawBuffs = TorghastTeams:GetModule("TGT_MawBuffs")

    self:SetupFrames()
end

-- Creates our main frame with tabs and everything
function TGT_GUI_NEW:SetupFrames()
    self.frame = AceGUI:Create("Frame")
    self.frame:SetTitle(L["ADDON_NAME_COLORED"] .. " v" .. GetAddOnMetadata("TorghastTeams", "VERSION"))
    self.frame:EnableResize(true)
    self.frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    self.frame:SetLayout("Fill")
    self:CreateTabs()
end

local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if (group == "tabWelcome") then
        TGT_GUI_NEW:TabWelcome(container)
    elseif (group == "tabAnimaPowers") then
        TGT_GUI_NEW:TabAnimaPowers(container)
    elseif (group == "tabStatistics") then
        TGT_GUI_NEW:TabStatistics(container)
    elseif (group == "tabHelp") then
        TGT_GUI_NEW:TabHelp(container)
    elseif (group == "tabChangelog") then
        TGT_GUI_NEW:TabChangelog(container)
    elseif (group == "tabSettings") then
        TGT_GUI_NEW:TabSettings(container)
    end
end



-- The Welcome Tab
-- Displays basic information about the addon
function TGT_GUI_NEW:TabWelcome(container)
    --self.playerFrame:Hide()

    local desc = AceGUI:Create("Label")
    desc:SetText("This is Tab 1")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    local button = AceGUI:Create("Button")
    button:SetText("Tab 1 Button")
    button:SetWidth(200)
    container:AddChild(button)
end

do
    local widgetType = "AnimaPowersFrame"
    local version = 1

    local function OnAcquire(self)
        self.frame:SetAllPoints()
		self.frame:Show()
    end
    
	local function OnRelease(self)
		self.frame:ClearAllPoints()
		self.frame:Hide()
	end

    local function constructor()
        local frame = CreateFrame("Button", nil, "TGTMawBuffsContainer")
        local self = {}
        self.type = widgetType
        self.OnRelease = OnRelease
        self.OnAcquire = OnAcquire
        -- self.SetText = SetText
        -- self.SetWidth = SetWidth
        self.frame = frame
        frame.obj = self
        frame:SetSize(220, 50)
        AceGUI:RegisterAsWidget(self)
        return self
    end
    AceGUI:RegisterWidgetType(widgetType, constructor, version)
    -- self.playerFrame = CreateFrame("Frame",  "tgt_apframe", content, "TGTMawBuffsList")
    -- self.playerFrame:SetSize(220, 50)
    
end

-- The Anima Powers Tab
-- Displays information relating your party member's Anima Powers
function TGT_GUI_NEW:TabAnimaPowers(container)
    local apf = AceGUI:Create("AnimaPowersFrame")
    -- local tabs = AceGUI:Create("TabGroup")
    -- tabs:SetTitle("Select a party member.")
    -- tabs:SetLayout("List")
    -- tabs:SetTabs(playerTabInfo)
    -- tabs:SetCallback("OnGroupSelected", SelectGroup)
    -- tabs:SelectTab("tabWelcome")
    -- container.frame:AddChild(tabs)
    
    -----------------------------------

    -- local mawBuffs, uniqueBuffCount = TGT_MawBuffs:GetPlayerAnimaPowers()
    -- local buff1 = AceGUI:Create("Icon")
    -- local buff2 = AceGUI:Create("Icon")
    -- local buff3 = AceGUI:Create("Icon")
    -- buff1:SetImage(mawBuffs[1].icon)
    -- buff2:SetImage(mawBuffs[1].icon)
    -- buff3:SetImage(mawBuffs[1].icon)
    -- buff1:SetImageSize(45, 45)
    -- buff2:SetImageSize(45, 45)
    -- buff3:SetImageSize(45, 45)
    -- container:AddChild(buff1)
    -- container:AddChild(buff2)
    -- container:AddChild(buff3)

    ---------------------------------

    -- local smallTabs = 0
    -- self.playerFrame:Show()
    -- if (container.frame.height == 56) then smallTabs = 36 else smallTabs = 56 end

    -- self.playerFrame:SetSize((container.frame:GetParent().width - 2), (container.frame:GetParent().height - smallTabs))
    -- --playerFrame:SetPoint("CENTER") --, container, "CENTER", 0, 75)
    -- self.playerFrame:SetParent(container.frame)
    -- self.playerFrame:SetPoint("TOPLEFT", container.frame, 0, -smallTabs)

    -- self.playerFrame:Update(TGT_MawBuffs:GetPlayerAnimaPowers())
end



function TGT_GUI_NEW:TabStatistics(container)
    --self.playerFrame:Hide()
    
end

function TGT_GUI_NEW:TabHelp(container)
    --self.playerFrame:Hide()
end

function TGT_GUI_NEW:TabSettings(container)
    --self.playerFrame:Hide()
end

function TGT_GUI_NEW:TabChangelog(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    scrollFrame:SetLayout("Flow")
    container:AddChild(scrollFrame)

    local changelog = AceGUI:Create("Label")
    changelog:SetText("Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?\n\nAt vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    changelog:SetRelativeWidth(1)
    scrollFrame:AddChild(changelog)
end

function TGT_GUI_NEW:CreateTabs()
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs(tabInfo)
    tabs:SetCallback("OnGroupSelected", SelectGroup)
    tabs:SelectTab("tabWelcome")
    self.frame:AddChild(tabs)
end