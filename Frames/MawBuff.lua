--[[-----------------------------------------------------------------------------
Icon Widget
-------------------------------------------------------------------------------]]
local Type, Version = "MawBuff", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs, print = select, pairs, print

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
    local self = frame.obj
    self:Fire("OnEnter")
    GameTooltip:SetOwner(frame, "ANCHOR_LEFT");
    GameTooltip:SetUnitAura("player", self.slot, "MAW");
    GameTooltip:Show()
    self.HighlightBorder:Show()
end

local function Control_OnLeave(frame)
    local self = frame.obj
    self:Fire("OnLeave")
    GameTooltip_Hide()
    self.HighlightBorder:Hide()
end

local function Button_OnClick(frame, button)
    local self = frame.obj
    self:Fire("OnClick", button)
    if (IsModifiedClick("CHATLINK")) then
        ChatEdit_InsertLink(GetMawPowerLinkBySpellID(self.spellID));
        return;
    end
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ["OnAcquire"] = function(self)
		self:SetHeight(45)
		self:SetWidth(45)
		self:SetDisabled(false)
    end,

    ["SetBuffInfo"] = function(self, buffInfo)
        self.Icon:SetTexture(buffInfo.icon)
        self.count = buffInfo.count
        self.slot = buffInfo.slot
        self.spellID = buffInfo.spellID

        local rarityAtlas = C_Spell.GetMawPowerBorderAtlasBySpellID(self.spellID);
        local showCount = buffInfo.count > 1;
    
        if (showCount) then
            self.Count:SetText(buffInfo.count);
        end 
    
        if(rarityAtlas) then
            self.Border:SetAtlas(rarityAtlas, false);
        end 
    
        self.Count:SetShown(showCount);
        self.CountRing:SetShown(showCount);
    
        if GameTooltip:GetOwner() == self then
            self:OnEnter();
        end
    
        self.frame:Show();
    end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
			-- self.label:SetTextColor(0.5, 0.5, 0.5)
			self.Icon:SetVertexColor(0.5, 0.5, 0.5, 0.5)
		else
			self.frame:Enable()
			-- self.label:SetTextColor(1, 1, 1)
			self.Icon:SetVertexColor(1, 1, 1, 1)
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()

    local frame = CreateFrame("Button", nil, UIParent)
    frame:SetWidth(45)
	frame:SetHeight(45)
	frame:Hide()
    frame:EnableMouse(true)
    
    frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnClick", Button_OnClick)

	local Icon = frame:CreateTexture(nil, "ARTWORK")
	Icon:SetWidth(35)
	Icon:SetHeight(35)
    Icon:SetPoint("CENTER", 0, 0)
    
    local Mask = frame:CreateMaskTexture()
    Mask:SetWidth(32)
    Mask:SetHeight(32)
    Mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    Mask:SetPoint("CENTER", frame, 0, 0)
    Icon:AddMaskTexture(Mask)

    local Border = frame:CreateTexture(nil, "ARTWORK", 2)
    Border:SetWidth(45)
    Border:SetHeight(45)
    Border:SetPoint("CENTER", frame, 0, 0)
    
    local HighlightBorder = frame:CreateTexture(nil, "ARTWORK", 2)
    HighlightBorder:SetAtlas("jailerstower-animapowerlist-highlight")
    HighlightBorder:SetWidth(41)
    HighlightBorder:SetHeight(41)
    HighlightBorder:SetPoint("CENTER", frame, 0, 0)
    HighlightBorder:Hide()

    local CountRing = frame:CreateTexture(nil, "OVERLAY")
    CountRing:SetAtlas("jailerstower-animapowerlist-rank", true)
    CountRing:SetAlpha(0.9)
    CountRing:SetPoint("BOTTOMLEFT", frame, 0, 0)

    local Count = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
    Count:SetPoint("CENTER", CountRing, 0, 0)

	local widget = {
		frame = frame,
        type  = Type,
        Icon = Icon,
        Mask = Mask,
        Border = Border,
        HighlightBorder = HighlightBorder,
        CountRing = CountRing,
        Count = Count,
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
