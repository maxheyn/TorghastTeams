local TorghastTeams = LibStub("AceAddon-3.0"):GetAddon("TorghastTeams")
local TGT_Chat = TorghastTeams:NewModule("TGT_Chat", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TorghastTeams")

function TGT_Chat:BroadcastPhantasma(msg, sender, channel, target)
    -- Extract the command from the string
    local commandString = { strsplit(" ", string.lower(msg)) }
    local cmd = commandString[1]
    local broadcast
    local name, _ = UnitName("player")

    if (cmd == "!p" or cmd == "!phantasma") then
        broadcast = "<" .. L["ADDON_NAME"] .. "> ".. name .. " " .. L["PHANTASMA_BROADCAST_HAS"] .. " " .. C_CurrencyInfo.GetCurrencyInfo(1728)["quantity"] .. " " .. C_CurrencyInfo.GetCurrencyLink(1728, 0)
        ChatThrottleLib:SendChatMessage("NORMAL", L["ADDON_NAME"], broadcast, channel, nil, target)
    end
end