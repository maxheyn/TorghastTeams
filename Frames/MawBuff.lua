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
    frame.obj:Fire("OnEnter")
    GameTooltip:SetOwner(frame, "ANCHOR_LEFT");
    GameTooltip:SetUnitAura("player", frame.slot, "MAW");
    GameTooltip:Show()
    frame.highlightBorder:Show()
end

local function Control_OnLeave(frame)
    frame.obj:Fire("OnLeave")
    GameTooltip_Hide()
    frame.highlightBorder:Hide()
end

local function Button_OnClick(frame, button)
    frame.obj:Fire("OnClick", button)
    if (IsModifiedClick("CHATLINK")) then
		ChatEdit_InsertLink(GetMawPowerLinkBySpellID(frame.spellID));
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

	-- ["OnRelease"] = nil,

	-- ["SetLabel"] = function(self, text)
	-- 	if text and text ~= "" then
	-- 		self.label:Show()
	-- 		self.label:SetText(text)
	-- 		self:SetHeight(self.image:GetHeight() + 25)
	-- 	else
	-- 		self.label:Hide()
	-- 		self:SetHeight(self.image:GetHeight() + 10)
	-- 	end
    -- end,
    ["SetBuffInfo"] = function(self, buffInfo)
        self.icon:SetTexture(buffInfo.icon)
        self.slot = buffInfo.slot
        self.count = buffInfo.count
        self.spellID = buffInfo.spellID

        local rarityAtlas = C_Spell.GetMawPowerBorderAtlasBySpellID(self.spellID);
        local showCount = buffInfo.count > 1;
    
        if (showCount) then
            self.Count:SetText(buffInfo.count);
        end 
    
        if(rarityAtlas) then
            self.highlightBorder:SetAtlas(rarityAtlas, false);
        end 
    
        self.Count:SetShown(showCount);
        self.CountRing:SetShown(showCount);
    
        if GameTooltip:GetOwner() == self then
            self:OnEnter();
        end
    
        self:Show();
    end,

	-- ["SetImage"] = function(self, buffIcon, ...)
	-- 	local image = self.icon
	-- 	image:SetTexture(buffIcon)
		
	-- 	if image:GetTexture() then
	-- 		local n = select("#", ...)
	-- 		if n == 4 or n == 8 then
	-- 			image:SetTexCoord(...)
	-- 		else
	-- 			image:SetTexCoord(0, 1, 0, 1)
	-- 		end
	-- 	end
	-- end,

	-- ["SetImageSize"] = function(self, width, height)
	-- 	self.icon:SetWidth(width)
	-- 	self.icon:SetHeight(height)
	-- 	--self.frame:SetWidth(width + 30)
	-- 	-- if self.label:IsShown() then
	-- 	-- 	self:SetHeight(height + 25)
	-- 	-- else
	-- 	-- 	self:SetHeight(height + 10)
	-- 	-- end
	-- end,

	-- ["SetDisabled"] = function(self, disabled)
	-- 	self.disabled = disabled
	-- 	if disabled then
	-- 		self.frame:Disable()
	-- 		-- self.label:SetTextColor(0.5, 0.5, 0.5)
	-- 		self.icon:SetVertexColor(0.5, 0.5, 0.5, 0.5)
	-- 	else
	-- 		self.frame:Enable()
	-- 		-- self.label:SetTextColor(1, 1, 1)
	-- 		self.icon:SetVertexColor(1, 1, 1, 1)
	-- 	end
	-- end
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

	-- local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	-- label:SetPoint("BOTTOMLEFT")
	-- label:SetPoint("BOTTOMRIGHT")
	-- label:SetJustifyH("CENTER")
	-- label:SetJustifyV("TOP")
	-- label:SetHeight(18)

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetWidth(35)
	icon:SetHeight(35)
    icon:SetPoint("CENTER", 0, 0)
    
    local mask = frame:CreateMaskTexture(nil, "ARTWORK", "Interface\\CharacterFrame\\TempPortraitAlphaMask")
    mask:SetWidth(32)
    mask:SetHeight(32)
    mask:SetPoint("CENTER", 0, 0)

    local border = frame:CreateTexture(nil, "ARTWORK", 2)
    border:SetWidth(40)
    border:SetHeight(40)
    border:SetPoint("CENTER", 0, 0)
    
	local highlightBorder = frame:CreateTexture(nil, "ARTWORK", 2)
    highlightBorder:SetWidth(36)
    highlightBorder:SetHeight(36)
    highlightBorder:SetPoint("CENTER", 0, 0)

    local countRing = frame:CreateTexture(nil, "OVERLAY")
    countRing:SetAtlas("jailerstower-animapowerlist-rank", true)
    countRing:SetAlpha(0.5)
    countRing:SetPoint("CENTER", 0, 0)

    local count = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
    count:SetPoint("BOTTOM",countRing, 0, 0)


	local widget = {
		frame = frame,
        icon = icon,
        mask = mask,
        border = border,
        highlightBorder = highlightBorder,
        countRing = countRing,
        count = count,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
