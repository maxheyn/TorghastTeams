local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")

local MAW_BUFF_MAX_DISPLAY = 48;
local classIcons = {}
classIcons = {
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
TGTMawBuffsContainerMixin = {};

function TGTMawBuffsContainerMixin:OnLoad()
	self:Show()
	self.List:Show()
	self:Enable()
	self:RegisterForDrag("LeftButton")
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function TGTMawBuffsContainerMixin:OnEvent(event, ...)
	-- All of our events are handled in TorghastTeams.lua
end

function TGTMawBuffsContainerMixin:Update()
	--print(TorghastTeams.db.profile.frames.framePlayer.x)
	local mawBuffs = {};
	local uniqueMawBuffs = 0;
	local totalCount = 0;
	for i=1, MAW_BUFF_MAX_DISPLAY do
		local _, icon, count, _, _, _, _, _, _, spellID = UnitAura("player", i, "MAW");
		if icon then
			if count == 0 then
				count = 1;
			end

			totalCount = totalCount + count;
			table.insert(mawBuffs, {icon = icon, count = count, slot = i, spellID = spellID});

			if (count >= 1) then
				uniqueMawBuffs = uniqueMawBuffs + 1;
			end
		end
	end
	
	local name, _ = UnitName("player")
	local guid = UnitGUID("player")

	local _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
	self:SetText("|T" .. classIcons[englishClass] .. ":0|t " .. name .. " (" .. totalCount .. ")")

	self.List:Update(mawBuffs, uniqueMawBuffs);

	self.buffCount = #mawBuffs;
	self:UpdateHelptip();
end

-- Just like TGTMawBuffsContainerMixin:Update(), but it specifically changes the UnitAura
-- to a party member rather than the player. Not sure if we needed a whole new function
-- but it was easier than trying to figure out some other loopholes around the issue
-- of working with 'self.whatever'.
function TGTMawBuffsContainerMixin:UpdatePartyMember(partyMember)
	local mawBuffs = {};
	local totalCount = 0;
	local uniqueMawBuffs = 0;
	for i=1, MAW_BUFF_MAX_DISPLAY do

		local _, icon, count, _, _, _, _, _, _, spellID = UnitAura("party" .. partyMember, i, "MAW");
		if icon then
			if count == 0 then
				count = 1;
			end
			
			totalCount = totalCount + count;
			table.insert(mawBuffs, {icon = icon, count = count, slot = i, spellID = spellID});

			if (count >= 1) then
				uniqueMawBuffs = uniqueMawBuffs + 1;
			end
		end
	end

	local name, realm = UnitName("party" .. partyMember)
	local guid = UnitGUID("party" .. partyMember)

	local _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
	if (realm == "") then
		self:SetText("|T" .. classIcons[englishClass] .. ":0|t " .. name .. " (" .. totalCount .. ")")
	else
		self:SetText("|T" .. classIcons[englishClass] .. ":0|t " .. name .. "-" .. realm .. " (" .. totalCount .. ")")
	end

	self.List:Update(mawBuffs, uniqueMawBuffs);

	self.buffCount = #mawBuffs;
	self:UpdateHelptip();
end


function TGTMawBuffsContainerMixin:UpdateHelptip()
	if(self.buffCount > 0 and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_9_0_JAILERS_TOWER_BUFFS)) then
		local selectLocationHelpTipInfo = {
			text = JAILERS_TOWER_BUFFS_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_9_0_JAILERS_TOWER_BUFFS,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			autoEdgeFlipping = true,
			useParentStrata = true,
		};
		HelpTip:Show(self, selectLocationHelpTipInfo)
	else
		HelpTip:Hide(self, JAILERS_TOWER_BUFFS_TUTORIAL);
	end
end

function TGTMawBuffsContainerMixin:UpdateListState(shouldShow)
	self:SetEnabled(not shouldShow); 
	self.List:SetShown(shouldShow and self.buffCount > 0);
end

function TGTMawBuffsContainerMixin:OnClick()
	self.List:SetShown(not self.List:IsShown());
	HelpTip:Acknowledge(self, JAILERS_TOWER_BUFFS_TUTORIAL);
	PlaySound(SOUNDKIT.UI_MAW_BUFFS_ANIMA_POWERS_BUTTON, nil, SOUNDKIT_ALLOW_DUPLICATES);
end

function TGTMawBuffsContainerMixin:MoveMawBuffsContainer()
	if (self.isMovable == "false") then print (L["ADDON_CHAT_PREFIX"] .. L["MOVE_FRAME_WARNING"])
	else self:StartMoving() end
end

function TGTMawBuffsContainerMixin:StopMovingMawBuffsContainer()
	self:StopMovingOrSizing()
end

function TGTMawBuffsContainerMixin:HighlightBuffAndShow(spellID, maxStacks)
	self.List:HighlightBuffAndShow(spellID, maxStacks)
end

function TGTMawBuffsContainerMixin:HideBuffHighlight(spellID)
	self.List:HideBuffHighlight(spellID)
end

TGTMawBuffsListMixin = {};

local BUFF_HEIGHT = 45;
local BUFF_LIST_MIN_HEIGHT = 159;
local BUFF_LIST_PADDING_HEIGHT = 36;
local BUFF_LIST_NUM_COLUMNS = 4;
local BUFF_LIST_PADDING_WIDTH = 11;
local BUFF_LIST_VERTICAL_SPACING = 0;
local BUFF_LIST_TOP_ANCHOR = -12;

-- Our breakpoints for resizing
local SIZE_BREAKPOINT_1 = 12
local SIZE_BREAKPOINT_2 = 15
local SIZE_BREAKPOINT_3 = 20
local SIZE_BREAKPOINT_4 = 30
local SIZE_BREAKPOINT_5 = 36
local SIZE_BREAKPOINT_6 = 42
local SIZE_BREAKPOINT_7 = 48

function TGTMawBuffsListMixin:OnLoad()
	self.container = self:GetParent();
	self:SetFrameLevel(self.container:GetFrameLevel() + 1);
	self.buffPool = CreateFramePool("BUTTON", self, "TGTMawBuffTemplate");
end

function TGTMawBuffsListMixin:OnShow()
	-- Nothing here yet.
end

function TGTMawBuffsListMixin:OnHide()
	-- Nothing here yet.
end

function TGTMawBuffsListMixin:HighlightBuffAndShow(spellID, maxStackCount)
	if(not spellID or not maxStackCount or not self.buffPool) then
		return;
	end
	for mawBuff in self.buffPool:EnumerateActive() do
		if(mawBuff.spellID == spellID and mawBuff.count < maxStackCount) then
			if( not self:IsShown()) then
				self:Show();
			end
			mawBuff.HighlightBorder:Show();
			return;
		end
	end
end

function TGTMawBuffsListMixin:HideBuffHighlight(spellID)
	if(not spellID or not self.buffPool) then
		return;
	end

	for mawBuff in self.buffPool:EnumerateActive() do
		if(mawBuff.spellID == spellID) then
			mawBuff.HighlightBorder:Hide();
		end
	end
end

function TGTMawBuffsListMixin:Update(mawBuffs, uniqueBuffCount)
	self.buffPool:ReleaseAll();

	local lastRowFirstFrame;
	local lastBuffFrame;
	local buffsTotalHeight = 0;
	for index, buffInfo in ipairs(mawBuffs) do
		local buffFrame = self.buffPool:Acquire();
		buffFrame:ResizeMawBuffs(uniqueBuffCount)
		local column = mod(index, BUFF_LIST_NUM_COLUMNS);
		if column == 1 then
			if lastRowFirstFrame then
				buffFrame:SetPoint("TOPLEFT", lastRowFirstFrame, "BOTTOMLEFT", 0, BUFF_LIST_VERTICAL_SPACING);
				buffsTotalHeight = buffsTotalHeight + BUFF_HEIGHT + 3;
			else
				buffFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 12, BUFF_LIST_TOP_ANCHOR);
				buffsTotalHeight = BUFF_HEIGHT;
			end
			lastRowFirstFrame = buffFrame;
		else
			buffFrame:SetPoint("TOPLEFT", lastBuffFrame, "TOPRIGHT", BUFF_LIST_PADDING_WIDTH, 0);
		end

		lastBuffFrame = buffFrame;
		buffFrame:SetBuffInfo(mawBuffs[index]);
	end

	local totalListHeight = math.max(buffsTotalHeight + BUFF_LIST_PADDING_HEIGHT, BUFF_LIST_MIN_HEIGHT);
end

TGTMawBuffMixin = {};

function TGTMawBuffMixin:ResizeMawBuffs(uniqueBuffCount)
	if (uniqueBuffCount <= SIZE_BREAKPOINT_1) then
		self:SetSize(45, 45)
		self.Icon:SetSize(35, 35)
		self.CircleMask:SetSize(32, 32)
		self.Border:SetSize(40, 40)
		self.HighlightBorder:SetSize(36, 36)
		self.CountRing:SetPoint("BOTTOMLEFT")
		self.CountRing:SetAlpha(1)
		BUFF_HEIGHT = 45
		BUFF_LIST_NUM_COLUMNS = 4
		BUFF_LIST_PADDING_WIDTH = 3
		BUFF_LIST_PADDING_HEIGHT = 36
		BUFF_LIST_VERTICAL_SPACING = 0
		BUFF_LIST_TOP_ANCHOR = -12
	elseif (uniqueBuffCount > SIZE_BREAKPOINT_1 and uniqueBuffCount <= SIZE_BREAKPOINT_2) then
		self:SetSize(40, 40)
		self.Icon:SetSize(32, 32)
		self.CircleMask:SetSize(25, 25)
		self.Border:SetSize(36, 36)
		self.HighlightBorder:SetSize(32, 32)
		self.CountRing:SetPoint("BOTTOMLEFT")
		self.CountRing:SetAlpha(1)
		BUFF_HEIGHT = 28
		BUFF_LIST_NUM_COLUMNS = 5
		BUFF_LIST_PADDING_WIDTH = -3
		BUFF_LIST_PADDING_HEIGHT = 36
		BUFF_LIST_VERTICAL_SPACING = -3
		BUFF_LIST_TOP_ANCHOR = -18
	elseif (uniqueBuffCount > SIZE_BREAKPOINT_2 and uniqueBuffCount <= SIZE_BREAKPOINT_3) then
		self:SetSize(28, 28)
		self.Icon:SetSize(26, 26)
		self.CircleMask:SetSize(25, 25)
		self.Border:SetSize(32, 32)
		self.HighlightBorder:SetSize(33, 33)
		self.CountRing:SetPoint("CENTER")
		self.CountRing:SetAlpha(0.5)
		BUFF_HEIGHT = 28
		BUFF_LIST_NUM_COLUMNS = 5
		BUFF_LIST_PADDING_WIDTH = 10
		BUFF_LIST_PADDING_HEIGHT = 36
		BUFF_LIST_VERTICAL_SPACING = -3
		BUFF_LIST_TOP_ANCHOR = -18
	elseif (uniqueBuffCount > SIZE_BREAKPOINT_3 and uniqueBuffCount <= SIZE_BREAKPOINT_4) then
		self:SetSize(26, 26)
		self.Icon:SetSize(24, 24)
		self.CircleMask:SetSize(20, 20)
		self.Border:SetSize(26, 26)
		self.HighlightBorder:SetSize(21, 21)
		self.CountRing:SetPoint("CENTER")
		self.CountRing:SetAlpha(0.5)
		BUFF_HEIGHT = 26
		BUFF_LIST_NUM_COLUMNS = 6
		BUFF_LIST_PADDING_WIDTH = 6
		BUFF_LIST_PADDING_HEIGHT = 36
		BUFF_LIST_VERTICAL_SPACING = 0
		BUFF_LIST_TOP_ANCHOR = -14
	elseif (uniqueBuffCount > SIZE_BREAKPOINT_4 and uniqueBuffCount <= SIZE_BREAKPOINT_5) then
		self:SetSize(26, 26)
		self.Icon:SetSize(24, 24)
		self.CircleMask:SetSize(18, 18)
		self.Border:SetSize(24, 24)
		self.HighlightBorder:SetSize(21, 21)
		self.CountRing:SetPoint("CENTER")
		self.CountRing:SetAlpha(0.5)
		BUFF_HEIGHT = 26
		BUFF_LIST_NUM_COLUMNS = 6
		BUFF_LIST_PADDING_WIDTH = 6
		BUFF_LIST_PADDING_HEIGHT = 36
		BUFF_LIST_VERTICAL_SPACING = 5
		BUFF_LIST_TOP_ANCHOR = -14
	elseif (uniqueBuffCount > SIZE_BREAKPOINT_5 and uniqueBuffCount <= SIZE_BREAKPOINT_6) then
		self:SetSize(26, 26)
		self.Icon:SetSize(24, 24)
		self.CircleMask:SetSize(18, 18)
		self.Border:SetSize(24, 24)
		self.HighlightBorder:SetSize(21, 21)
		self.CountRing:SetPoint("CENTER")
		self.CountRing:SetAlpha(0.5)
		BUFF_HEIGHT = 26
		BUFF_LIST_NUM_COLUMNS = 7
		BUFF_LIST_PADDING_WIDTH = 1
		BUFF_LIST_PADDING_HEIGHT = 36
		BUFF_LIST_VERTICAL_SPACING = 5
		BUFF_LIST_TOP_ANCHOR = -14
	elseif (uniqueBuffCount > SIZE_BREAKPOINT_6 and uniqueBuffCount <= SIZE_BREAKPOINT_7) then
		self:SetSize(26, 26)
		self.Icon:SetSize(24, 24)
		self.CircleMask:SetSize(18, 18)
		self.Border:SetSize(24, 24)
		self.HighlightBorder:SetSize(21, 21)
		self.CountRing:SetPoint("CENTER")
		self.CountRing:SetAlpha(0.5)
		BUFF_HEIGHT = 26
		BUFF_LIST_NUM_COLUMNS = 8
		BUFF_LIST_PADDING_WIDTH = -3
		BUFF_LIST_PADDING_HEIGHT = 36
		BUFF_LIST_VERTICAL_SPACING = 5
		BUFF_LIST_TOP_ANCHOR = -14
	end
end


function TGTMawBuffMixin:SetBuffInfo(buffInfo)
	self.Icon:SetTexture(buffInfo.icon);
	self.slot = buffInfo.slot;
	self.count = buffInfo.count;
	self.spellID = buffInfo.spellID;

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

	self:Show();
end

function TGTMawBuffMixin:OnEnter()
	self:RefreshTooltip();
end

function TGTMawBuffMixin:RefreshTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");

	-- A Buff is a child of the BuffList which is a child of the BuffListContainer
	-- Therefore we need to get the parent's parent, and then their ID so that we can
	-- compare it and make sure we are correctly getting either the player or party member.
	local containerID = self:GetParent():GetParent():GetID()

	-- See: TorghastTeams:CreateAnimaPowerFrames()
	-- for explanation of the number.
	local magicNumber = 5554654
	if containerID == magicNumber then
		GameTooltip:SetUnitAura("player", self.slot, "MAW");
	else
		GameTooltip:SetUnitAura("party" .. math.fmod(containerID, magicNumber), self.slot, "MAW");
	end
	GameTooltip:Show();
	self.HighlightBorder:Show();
end

function TGTMawBuffMixin:OnClick()
	if (IsModifiedClick("CHATLINK")) then
		ChatEdit_InsertLink(GetMawPowerLinkBySpellID(self.spellID));
		return;
	end
end

function TGTMawBuffMixin:OnLeave()
	GameTooltip_Hide();
	self.HighlightBorder:Hide();
end