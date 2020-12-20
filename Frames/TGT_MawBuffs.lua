local MAW_BUFF_MAX_DISPLAY = 44;

MawBuffsContainerMixin = {};

function MawBuffsContainerMixin:OnLoad()
	local partySize = GetNumGroupMembers()
	-- self:Update()
	-- if partySize > 1 then
	-- 	for currentMember = 1, partySize - 1, 1 do
	-- 		self:UpdatePartyMember(currentMember);
	-- 	end
	-- end
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterUnitEvent("UNIT_AURA", "party1");
	self:RegisterUnitEvent("UNIT_AURA", "party2");
	self:RegisterUnitEvent("UNIT_AURA", "party3");
	self:RegisterUnitEvent("UNIT_AURA", "party4");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	print('MawBuffsContainerMixin:OnLoad() ' .. tostring(self))
end

function MawBuffsContainerMixin:OnEvent(event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		if (!IsInJailersTower()) then
			print("outside");
			self.Update();
		end
	end
	-- local partySize = GetNumGroupMembers()
	-- local unit = ...;
	-- if event == "UNIT_AURA" then
	-- 	self:Update()
	-- 	if partySize > 1 then
	-- 		for currentMember = 1, partySize - 1, 1 do
	-- 			self:UpdatePartyMember(currentMember);
	-- 		end
	-- 	end
		
	-- elseif event == "GLOBAL_MOUSE_DOWN" then
	-- 	if self.List:IsShown() then
	-- 		if (self:IsMouseOver() or self.List:IsMouseOver() or (PlayerChoiceFrame and PlayerChoiceFrame:IsShown()))  then 
	-- 			return; 
	-- 		end 

	-- 		self:UpdateListState(false);
	-- 	end
	
end

function MawBuffsContainerMixin:Update() --add params for targets so we can select party in unitaura
	--print("updating container")
	-- makes a mawbuffs container and a loop, gets the unitauras from the player only if they are MAW buffs (anima powers)
	local mawBuffs = {};
	local totalCount = 0;
	for i=1, MAW_BUFF_MAX_DISPLAY do
		-- gets the displayicon, number of stacks of that anima power, and the spellID using UnitAura()
		-- i is the buff in the list
		local _, icon, count, _, _, _, _, _, _, spellID = UnitAura("player", i, "MAW"); --this is the key to getting it to work
		if icon then
			if count == 0 then
				count = 1;
			end
			totalCount = totalCount + count;
			-- put that into the mawbuffs table with all of the info + number of stacks as count
			table.insert(mawBuffs, {icon = icon, count = count, slot = i, spellID = spellID});
		end
	end

	-- idk what this does
	self:SetText(JAILERS_TOWER_BUFFS_BUTTON_TEXT:format(totalCount));

	-- this is probably MawBuffsListMixin:Update()
	self.List:Update(mawBuffs); 
	
	if(IsInJailersTower()) then
		self:Show();
	else
		self:Hide();
	end

	-- buffcount = length of mawbuffs
	self.buffCount = #mawBuffs;
	if self.buffCount == 0 then
		print('hiding no buffs')
		self.List:Hide();
		self:Disable();
	else
		self:Enable();
	end
	self:UpdateHelptip();
end

function MawBuffsContainerMixin:UpdatePartyMember(partyMember) --add params for targets so we can select party in unitaura
	--print("updating container")
	-- makes a mawbuffs container and a loop, gets the unitauras from the player only if they are MAW buffs (anima powers)
	local mawBuffs = {};
	local totalCount = 0;
	for i=1, MAW_BUFF_MAX_DISPLAY do
		-- gets the displayicon, number of stacks of that anima power, and the spellID using UnitAura()
		-- i is the buff in the list
		local _, icon, count, _, _, _, _, _, _, spellID = UnitAura("party" .. partyMember, i, "MAW"); --this is the key to getting it to work
		if icon then
			if count == 0 then
				count = 1;
			end
			totalCount = totalCount + count;
			-- put that into the mawbuffs table with all of the info + number of stacks as count
			table.insert(mawBuffs, {icon = icon, count = count, slot = i, spellID = spellID});
		end
	end

	-- idk what this does
	self:SetText(JAILERS_TOWER_BUFFS_BUTTON_TEXT:format(totalCount));

	-- this is probably MawBuffsListMixin:Update()
	self.List:Update(mawBuffs, partyMember); 
	
	if(IsInJailersTower()) then
		self:Show();
	else
		self:Hide();
	end

	-- buffcount = length of mawbuffs
	self.buffCount = #mawBuffs;
	if self.buffCount == 0 then
 		self.List:Show();
		self:Disable();
	else
		self:Enable();
	end
	self:UpdateHelptip();
end


-- i dont think i care about this function
function MawBuffsContainerMixin:UpdateHelptip()
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

function MawBuffsContainerMixin:UpdateListState(shouldShow) 
	self:SetEnabled(not shouldShow); 
	self.List:SetShown(shouldShow and self.buffCount > 0); 
end 

function MawBuffsContainerMixin:OnClick()
	self.List:SetShown(not self.List:IsShown());
	HelpTip:Acknowledge(self, JAILERS_TOWER_BUFFS_TUTORIAL);
	PlaySound(SOUNDKIT.UI_MAW_BUFFS_ANIMA_POWERS_BUTTON, nil, SOUNDKIT_ALLOW_DUPLICATES);
end

function MawBuffsContainerMixin:HighlightBuffAndShow(spellID, maxStacks)
	self.List:HighlightBuffAndShow(spellID, maxStacks)
end 

function MawBuffsContainerMixin:HideBuffHighlight(spellID)
	self.List:HideBuffHighlight(spellID)
end 

MawBuffsListMixin = {};

local BUFF_HEIGHT = 45;
local BUFF_LIST_MIN_HEIGHT = 159;
local BUFF_LIST_PADDING_HEIGHT = 36;
local BUFF_LIST_NUM_COLUMNS = 4;

function MawBuffsListMixin:OnLoad()
	self.container = self:GetParent();
	self:SetFrameLevel(self.container:GetFrameLevel() + 1);
	self.buffPool = CreateFramePool("BUTTON", self, "TGTMawBuffTemplate");
end

-- anima powers button
function MawBuffsListMixin:OnShow()
	-- self.button:SetPushedAtlas("jailerstower-animapowerbutton-pressed");
	-- self.button:SetHighlightAtlas("jailerstower-animapowerbutton-pressed-highlight");
	-- self.button:SetWidth(268);
	-- self.button:SetButtonState("NORMAL");
	-- self.button:SetPushedTextOffset(8.75, -1);
	-- self.button:SetButtonState("PUSHED", true);
	print("shown")
end

-- anima powers button
function MawBuffsListMixin:OnHide()
	-- self.button:SetPushedAtlas("jailerstower-animapowerbutton-normalpressed");
	-- self.button:SetHighlightAtlas("jailerstower-animapowerbutton-highlight");
	-- self.button:SetWidth(253);
	-- self.button:SetButtonState("NORMAL", false);
	-- self.button:SetPushedTextOffset(1.25, -1);
	print('hidden')
end

function MawBuffsListMixin:HighlightBuffAndShow(spellID, maxStackCount)
	print("howdy")
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

function MawBuffsListMixin:HideBuffHighlight(spellID)
	if(not spellID or not self.buffPool) then 
		return;
	end 

	for mawBuff in self.buffPool:EnumerateActive() do
		if(mawBuff.spellID == spellID) then 
			mawBuff.HighlightBorder:Hide(); 
		end 
	end
end

function MawBuffsListMixin:Update(mawBuffs) --TODO: find out what is in mawBuffs 
	-- table.insert(mawBuffs, {icon = icon, count = count, slot = i, spellID = spellID});
	-- print('MawBuffsListMixin:Update(mawBuffs) | ' .. tostring(self:GetParent()))
	--debug print
	for index, data in ipairs(mawBuffs) do
		-- print(index)
	
		for key, value in pairs(data) do
			-- print('\t', key, value)
		end
	end
	--end debug print
	self.buffPool:ReleaseAll();

	local lastRowFirstFrame;
	local lastBuffFrame;
	local buffsTotalHeight = 0;
	for index, buffInfo in ipairs(mawBuffs) do
		local buffFrame = self.buffPool:Acquire();

		local column = mod(index, BUFF_LIST_NUM_COLUMNS);
		if column == 1 then
			if lastRowFirstFrame then
				buffFrame:SetPoint("TOPLEFT", lastRowFirstFrame, "BOTTOMLEFT", 0, -3);
				buffsTotalHeight = buffsTotalHeight + BUFF_HEIGHT + 3;
			else
				buffFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 12, -18);
				buffsTotalHeight = BUFF_HEIGHT;
			end
			lastRowFirstFrame = buffFrame;
		else
			buffFrame:SetPoint("TOPLEFT", lastBuffFrame, "TOPRIGHT", 3, 0);
		end

		lastBuffFrame = buffFrame;
		buffFrame:SetBuffInfo(mawBuffs[index]);
	end

	local totalListHeight = math.max(buffsTotalHeight + BUFF_LIST_PADDING_HEIGHT, BUFF_LIST_MIN_HEIGHT);
	self:SetHeight(totalListHeight);
end

MawBuffMixin = {};

function MawBuffMixin:SetBuffInfo(buffInfo)
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
		self.Border:SetAtlas(rarityAtlas, TextureKitConstants.UseAtlasSize);
	end 

	self.Count:SetShown(showCount);
	self.CountRing:SetShown(showCount);

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end

	self:Show();
end

function MawBuffMixin:OnEnter()
	self:RefreshTooltip(); 
end

function MawBuffMixin:RefreshTooltip()
	local containerID = self:GetParent():GetParent():GetID() --jesus christ
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if containerID == 5554654 then
		GameTooltip:SetUnitAura("player", self.slot, "MAW");
	else
		GameTooltip:SetUnitAura("party" .. math.fmod(containerID, 5554654), self.slot, "MAW");	
	end
	GameTooltip:Show();
	self.HighlightBorder:Show(); 
end

function MawBuffMixin:OnClick()
	if (IsModifiedClick("CHATLINK")) then
		ChatEdit_InsertLink(GetMawPowerLinkBySpellID(self.spellID));
		return;
	end
end

function MawBuffMixin:OnLeave()
	GameTooltip_Hide(); 
	self.HighlightBorder:Hide(); 
end