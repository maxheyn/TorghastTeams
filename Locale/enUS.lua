local L = LibStub("AceLocale-3.0"):NewLocale("TorghastTeams", "enUS", true)
if not L then return end

--------------------------------------------------------------------------------------------------------------------------------------------
L["CHANGELOG"] = "Changelog:\n- Added changelog (this!) on welcome screen.\n- Added dynamic resizing of anima powers in Torghast.\n- Added low-profile mode when ctrl-left clicking minimap icon. (Added last patch but included here for convenience.)"

L["ADDON_NAME"] = "TorghastTeams"
L["ADDON_NAME_COLORED"] = "|cffd67666T|cffd98071o|cffe2998cr|cffecb6abg|cfff3cec6h|cfff0e5e1a|cffe7e7e6s|cffdfecf6t|r|cffd1f2feT|cffbbebfee|cffa1e1ffa|cff67c3f3m|cff78cffcs|r"

L["DEFAULT_BODY_TAGLINE"] = "Party Anima Powers Display"
L["DEFAULT_BODY_WELCOME"] = "Welcome to TorghastTeams!"
L["DEFAULT_BODY_INFORMATION"] = "This AddOn lets you see all of the Anima Powers that you and your party pick up, so you don't have to memorize their builds from the chat window.\n\nYou can see every party member's build at the same time, letting you play around their Anima Powers and just see what kind of cool and fun powers they've chosen."
L["DEFAULT_BODY_PROMPT"] = "Get started by queuing up for Torghast by yourself or with a party, then click the minimap button or type '/tgt show' to bring up the Anima Powers screen!"
L["DEFAULT_BODY_COMMANDS"] = "See our list of commands below!\nAlternatively, type /tgt or /torghastteams to see all available commands."

L["COMMAND_MINIMAP_EXAMPLE"] = "/tgt minimap"
L["COMMAND_MINIMAP_NAME"] = "Minimap Button Toggle"
L["COMMAND_MINIMAP_DESC"] = "Toggles the display of the minimap button."
L["COMMAND_SHOW_EXAMPLE"] = "/tgt show"
L["COMMAND_SHOW_NAME"] = "Show Interface"
L["COMMAND_SHOW_DESC"] = "Shows the TorghastTeams Frame."
L["COMMAND_HIDE_EXAMPLE"] = "/tgt hide"
L["COMMAND_HIDE_NAME"] = "Hide Interface"
L["COMMAND_HIDE_DESC"] = "Hides the TorghastTeams Frame."