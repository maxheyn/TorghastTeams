local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_GUI_NEW = TorghastTeams:NewModule("TGT_GUI_NEW", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")
local AceGUI = LibStub("AceGUI-3.0")
local lwin = LibStub("LibWindow-1.1")

local classIcons = {
	["DEATHKNIGHT"] =   "Interface\\Icons\\ClassIcon_DeathKnight",
	["DEMONHUNTER"] =   "Interface\\Icons\\ClassIcon_DemonHunter",
	["DRUID"] =         "Interface\\Icons\\ClassIcon_Druid",
	["HUNTER"] =        "Interface\\Icons\\ClassIcon_Hunter",
	["MAGE"] =          "Interface\\Icons\\ClassIcon_Mage",
	["MONK"] =          "Interface\\Icons\\ClassIcon_Monk",
	["PALADIN"] =       "Interface\\Icons\\ClassIcon_Paladin",
	["PRIEST"] =        "Interface\\Icons\\ClassIcon_Priest",
	["ROGUE"] =         "Interface\\Icons\\ClassIcon_Rogue",
	["SHAMAN"] =        "Interface\\Icons\\ClassIcon_Shaman" ,
	["WARLOCK"] =       "Interface\\Icons\\ClassIcon_Warlock",
	["WARRIOR"] =       "Interface\\Icons\\ClassIcon_Warrior",
}

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

local playerTabInfo = {}
local tabsCreated = false

-- Called when this module is enabled
-- Usually on load unless manually disabled elsewhere
function TGT_GUI_NEW:OnEnable()
    self:RegisterEvent("UNIT_AURA")

    self:SetupFrames()
end

-- Creates our main frame with tabs and everything
function TGT_GUI_NEW:SetupFrames()
    self.frame = AceGUI:Create("Window")
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

local function SelectPlayer(container, event, group)
    container:ReleaseChildren()
    if (group == "p0") then
        TGT_GUI_NEW:TabPlayer(container)
    elseif (group == "p1") then
        TGT_GUI_NEW:TabParty1(container)
    elseif (group == "p2") then
        TGT_GUI_NEW:TabParty2(container)
    elseif (group == "p3") then
        TGT_GUI_NEW:TabParty3(container)
    elseif (group == "p4") then
        TGT_GUI_NEW:TabParty4(container)
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

local function GetMawBuffs(target)
    local MAW_BUFF_MAX_DISPLAY = 256
    local mawBuffs = {}

    for i=1, MAW_BUFF_MAX_DISPLAY do
        local _, icon, count, _, _, _, _, _, _, spellID = UnitAura(target, i, "MAW");
        if (icon) then
            if (count == 0) then
                count = 1
            end

            table.insert(mawBuffs, {icon = icon, count = count, slot = i, spellID = spellID})
        end
    end

    return mawBuffs
end

local function GetMawBuffCount(target)
    local mawBuffs = GetMawBuffs(target)
    return #mawBuffs
end

function TGT_GUI_NEW:TabPlayer(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    scrollFrame:SetLayout("Flow")
    container:AddChild(scrollFrame)

    local mawBuffs = GetMawBuffs("player")
    for i=1, #mawBuffs do
        local animaPowerFrame = AceGUI:Create("MawBuff")
        animaPowerFrame:SetBuffInfo(mawBuffs[i])
        scrollFrame:AddChild(animaPowerFrame)
    end
end

-- The Anima Powers Tab
-- Holds the tabs for each Party Member's Anima Powers
function TGT_GUI_NEW:TabAnimaPowers(container)
    container:ReleaseChildren()

    local guid, englishClass, name, realm, text
    for i = 0, GetNumGroupMembers() - 1 do
        if (i == 0) then
            guid = UnitGUID("player")
            _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
            text = "|T" .. classIcons[englishClass] .. ":0|t  " .. name .. " (" .. GetMawBuffCount("player") .. ")"

            table.insert(playerTabInfo, {value = "p" .. i, text = text})
        else
            guid = UnitGUID("party" .. i)
            _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
            if (realm == "") then
                text = "|T" .. classIcons[englishClass] .. ":0|t  " .. name --.. " (" .. totalCount .. ")")
            else
                text = "|T" .. classIcons[englishClass] .. ":0|t  " .. name .. "-" .. realm --.. " (" .. totalCount .. ")")
            end

            table.insert(playerTabInfo, {value = "p" .. i, text = text})
        end
    end

    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs(playerTabInfo)
    tabs:SetCallback("OnGroupSelected", SelectPlayer)
    tabs:SelectTab("p0")

    container:SetLayout("Fill")
    container:AddChild(tabs)
    playerTabInfo = {}
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

function TGT_GUI_NEW:TabParty1(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    scrollFrame:SetLayout("Flow")
    container:AddChild(scrollFrame)

    local mawBuffs = GetMawBuffs("party1")
    for i=1, #mawBuffs do
        local animaPowerFrame = AceGUI:Create("MawBuff")
        animaPowerFrame:SetBuffInfo(mawBuffs[i])
        scrollFrame:AddChild(animaPowerFrame)
    end
end

function TGT_GUI_NEW:TabParty2(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    scrollFrame:SetLayout("Flow")
    container:AddChild(scrollFrame)

    local mawBuffs = GetMawBuffs("party2")
    for i=1, #mawBuffs do
        local animaPowerFrame = AceGUI:Create("MawBuff")
        animaPowerFrame:SetBuffInfo(mawBuffs[i])
        scrollFrame:AddChild(animaPowerFrame)
    end
end

function TGT_GUI_NEW:TabParty3(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    scrollFrame:SetLayout("Flow")
    container:AddChild(scrollFrame)

    local mawBuffs = GetMawBuffs("party3")
    for i=1, #mawBuffs do
        local animaPowerFrame = AceGUI:Create("MawBuff")
        animaPowerFrame:SetBuffInfo(mawBuffs[i])
        scrollFrame:AddChild(animaPowerFrame)
    end
end

function TGT_GUI_NEW:TabParty4(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    scrollFrame:SetLayout("Flow")
    container:AddChild(scrollFrame)

    local mawBuffs = GetMawBuffs("party4")
    for i=1, #mawBuffs do
        local animaPowerFrame = AceGUI:Create("MawBuff")
        animaPowerFrame:SetBuffInfo(mawBuffs[i])
        scrollFrame:AddChild(animaPowerFrame)
    end
end

function TGT_GUI_NEW:CreateTabs()
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetTitle("ASLDKJA")
    tabGroup:SetLayout("Flow")
    tabGroup:SetTabs(tabInfo)
    tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    tabGroup:SelectTab("tabWelcome")
    self.frame:AddChild(tabGroup)

end

function TGT_GUI_NEW:UNIT_AURA()
    print('aaa')
    local guid, englishClass, name, realm, text
    for i = 0, GetNumGroupMembers() - 1 do
        if (i == 0) then
            print('ccc')
            GetMawBuffs("player")
            guid = UnitGUID("player")
            _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
            text = "|T" .. classIcons[englishClass] .. ":0|t  " .. name .. " (" .. GetMawBuffCount("player") .. ")"

            --self.frame.tabs[2].tabs[i].text = text
        else
            GetMawBuffs("party" .. i)
            guid = UnitGUID("party" .. i)
            _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
            if (realm == "") then
                text = "|T" .. classIcons[englishClass] .. ":0|t  " .. name --.. " (" .. totalCount .. ")")
            else
                text = "|T" .. classIcons[englishClass] .. ":0|t  " .. name .. "-" .. realm --.. " (" .. totalCount .. ")")
            end

            --self.frame.tabs[2].tabs[i].text = text
        end
    end
end