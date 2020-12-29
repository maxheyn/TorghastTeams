
local TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_ID = 90;
local TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_OFFSET = -220; 

local gossipButtonTextureKitRegions = {
	["Background"] = "jailerstower-wayfinder-tierbackground-%s",
}

local TORGHAST_LEVEL_PICKER_EVENTS = {
	"PARTY_LEADER_CHANGED",
	"GOSSIP_OPTIONS_REFRESHED",
	"GROUP_ROSTER_UPDATE",
	"UNIT_AREA_CHANGED",
	"UNIT_PHASE", 
	"GROUP_FORMED",
};

TGTInterfaceMixin = {};

function TGTInterfaceMixin:OnLoad()
	CustomGossipFrameBaseMixin.OnLoad(self);
	self.gossipOptionsPool = CreateFramePool("CHECKBUTTON", self.GridLayoutContainer, "TorghastLevelPickerOptionButtonTemplate");
	self.TGTBodyTextContainer:Show()
end

function TGTInterfaceMixin:OnEvent(event, ...)
	if (event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" or event == "GROUP_FORMED") then 
		C_GossipInfo.RefreshOptions(); 
		local inParty = UnitInParty("player"); 
		self.isPartyLeader = not inParty or UnitIsGroupLeader("player");
	elseif(event == "UNIT_AREA_CHANGED" or event == "UNIT_PHASE") then 
		C_GossipInfo.RefreshOptions(); 
	elseif (event == "GOSSIP_OPTIONS_REFRESHED") then 
		self:SetupOptions();
		self:UpdatePortalButtonState();
	end 
end 

function TGTInterfaceMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, TORGHAST_LEVEL_PICKER_EVENTS);
	PlaySound(SOUNDKIT.UI_TORGHAST_WAYFINDER_OPEN_UI, nil, SOUNDKIT_ALLOW_DUPLICATES); 
end 

function TGTInterfaceMixin:CancelEffects()
	if(self.backgroundEffectController) then 
		self.backgroundEffectController:CancelEffect(); 
		self.backgroundEffectController = nil; 
	end 
end 

function TGTInterfaceMixin:UpdatePortalButtonState(startingIndex)
	local enabled = true; 
	local isPartyInTorghast = C_PartyInfo.IsPartyInJailersTower(); 
	if	(startingIndex and self.currentSelectedButtonIndex) then 
		local maxIndexPerPage = (self.maxOptionsPerPage + startingIndex) - 1; 
		enabled = self.currentSelectedButtonIndex >= startingIndex and self.currentSelectedButtonIndex <= maxIndexPerPage;
	end 

end

function TGTInterfaceMixin:SetupOptions()
	self:BuildOptionList();
	self:SetupGrid();
	self:SetupLevelButtons(); 
end 

function TGTInterfaceMixin:TryShow(textureKit) 
	self.textureKit = textureKit; 
	self.Title:SetText(C_GossipInfo.GetText());

	local inParty = UnitInParty("player"); 
	self.isPartyLeader = not inParty or UnitIsGroupLeader("player");

	self:CancelEffects(); 

	local smokeEffectDescription = { effectID = TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_ID, offsetY = TORGHAST_LEVEL_PICKER_SMOKE_EFFECT_OFFSET, };
	self.backgroundEffectController = GlobalFXBackgroundModelScene:AddDynamicEffect(smokeEffectDescription, self);

	self:SetupOptions();
	self:ScrollAndSelectHighestAvailableLayer();
	ShowUIPanel(self); 
end 

function TGTInterfaceMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, TORGHAST_LEVEL_PICKER_EVENTS);
	self:ClearLevelSelection(); 

	self.textureKit = nil; 
	EmbeddedItemTooltip:Hide(); 
	self:CancelEffects(); 
	C_GossipInfo.CloseGossip(); 
end		

function TGTInterfaceMixin:SetupGrid()
	self.GridLayoutContainer:SetSize(420, 260); 
	self.GridLayoutContainer:ClearAllPoints();
	-- self.GridLayoutContainer:SetPoint("TOP", self.SubTitle, "BOTTOM", 20, -40)
end 

function TGTInterfaceMixin:SetupLevelButtons()
	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.GridLayoutContainer, "TOPLEFT");
	local overridePaddingX = 45; 
	local overridePaddingY = 45; 
	self:LayoutGridInit(anchor, overridePaddingX, overridePaddingY, GridLayoutMixin.Direction.TopLeftToBottomRight); 
	self:UpdatePortalButtonState(); 
end 

function TGTInterfaceMixin:SetStartingPage(page)
	self.Pager:Init(page); 
end 

function TGTInterfaceMixin:GetCurrentPage()
	return self.Pager.currentPage; 
end

function TGTInterfaceMixin:ClearLevelSelection() 
	if (self.currentSelectedButton) then 
		self.currentSelectedButton:ClearSelection(); 
		self.currentSelectedButton = nil;
		self.currentSelectedButtonIndex = nil;
	end 
	self:UpdatePortalButtonState(); 
end 

function TGTInterfaceMixin:SelectLevel(selectedLevelButton)
	if(self.currentSelectedButton == selectedLevelButton and self.currentSelectedButtonIndex == selectedLevelButton.index) then 
		self.currentSelectedButton:ClearSelection(); 
		self.currentSelectedButton = nil;
		self.currentSelectedButtonIndex = nil;
	else 
		if (self.currentSelectedButton) then 
			self.currentSelectedButton:ClearSelection(); 
		end 
		self.currentSelectedButton = selectedLevelButton; 
		self.currentSelectedButtonIndex = self.currentSelectedButton.index; 
	end
	self:UpdatePortalButtonState(); 
end		

function TGTInterfaceMixin:SetupBackground()
	SetupTextureKitOnRegions(self.textureKit, self, gossipBackgroundTextureKitRegion, true, TextureKitConstants.UseAtlasSize);
end

function TGTInterfaceMixin:ScrollAndSelectHighestAvailableLayer()
	local highestAvailableLayerIndex = nil

	--First get the highest unlocked layer. 
	for i = 1, #self.gossipOptions do 
		local optionInfo = self.gossipOptions[i];
		local optionCanBeSelected = optionInfo.status == Enum.GossipOptionStatus.Available or optionInfo.status == Enum.GossipOptionStatus.AlreadyComplete; 
		if (optionCanBeSelected and (not highestAvailableLayerIndex or (highestAvailableLayerIndex < i))) then 
			highestAvailableLayerIndex = i;
		end 
	end 

	-- If there is none which there shouldn't be.. return
	if(not highestAvailableLayerIndex) then 
		return;
	end 

	-- Go to the page that has this layer
	local page = math.ceil(highestAvailableLayerIndex / self.maxOptionsPerPage);  
	self:SetStartingPage(page); 

	local startingIndex = ((page - 1) * self.maxOptionsPerPage) + 1;
	self:SetupOptionsByStartingIndex(startingIndex);

	-- Select the option that is the highest available layer. 
	for layer in self.gossipOptionsPool:EnumerateActive() do 
		if (layer.index == highestAvailableLayerIndex) then 
			self:SelectLevel(layer);
			layer:SetState(self.gossipOptions[highestAvailableLayerIndex].status)
			return; 
		end 
	end 
end 