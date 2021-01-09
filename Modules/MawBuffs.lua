local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_MawBuffs = TorghastTeams:NewModule("TGT_MawBuffs", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")

local MAW_BUFF_MAX_DISPLAY = 48;

function TGT_MawBuffs:GetPlayerAnimaPowers()
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

	return mawBuffs, uniqueMawBuffs;
	
	-- local name, _ = UnitName("player")
	-- local guid = UnitGUID("player")

	-- local _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
	-- self:SetText("|T" .. classIcons[englishClass] .. ":0|t " .. name .. " (" .. totalCount .. ")")

	-- self.List:Update(mawBuffs, uniqueMawBuffs);

	-- self.buffCount = #mawBuffs;
	-- self:UpdateHelptip();
end