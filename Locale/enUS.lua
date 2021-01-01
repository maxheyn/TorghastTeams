local L = LibStub("AceLocale-3.0"):NewLocale("TorghastTeams", "enUS", true)
if not L then return end

--------------------------------------------------------------------------------------------------------------------------------------------
L["CHANGELOG"] = "Changelog:\n- Added class icons to frames.\n- Reworked how minimap button works.\n  - Left click now always toggles between showing and hiding the current selected display mode.\n  - Ctrl+Left click now cycles between display modes (i.e. simple, default) while in Torghast.\n- Simple mode frames now save their location when you move them.\n- Now remebers what mode you were in when you start another Torghast run.\n- Refactored code to be easier to maintain."

L["ADDON_NAME"] = "TorghastTeams"
L["ADDON_NAME_COLORED"] = "|cffd67666T|cffd98071o|cffe2998cr|cffecb6abg|cfff3cec6h|cfff0e5e1a|cffe7e7e6s|cffdfecf6t|r|cffd1f2feT|cffbbebfee|cffa1e1ffa|cff67c3f3m|cff78cffcs|r"
L["ADDON_CHAT_PREFIX"] = "<|cffd67666T|cffd98071o|cffe2998cr|cffecb6abg|cfff3cec6h|cfff0e5e1a|cffe7e7e6s|cffdfecf6t|r|cffd1f2feT|cffbbebfee|cffa1e1ffa|cff67c3f3m|cff78cffcs|r> "

L["MINIMAP_LEFTCLICK"] = "- Left click to toggle the |cffd67666T|cffd98071o|cffe2998cr|cffecb6abg|cfff3cec6h|cfff0e5e1a|cffe7e7e6s|cffdfecf6t|r|cffd1f2feT|cffbbebfee|cffa1e1ffa|cff67c3f3m|cff78cffcs|r display."
L["MINIMAP_CTRLLEFTCLICK"] = "- Ctrl+Left click to cycle between display modes (Only while in Torghast)."
L["MINIMAP_HIDDEN"] = "Minimap button is now hidden."
L["MINIMAP_SHOWN"] = "Minimap button is now shown."

L["SWITCH_MODE_DEFAULT"] = "Display switched to |cff6CDB79Simple Mode|r. Change it back by Ctrl+Left clicking the minimap icon."
L["SWITCH_MODE_SIMPLE"] =  "Display switched to |cff67c3f3Default Mode|r. Change it back by Ctrl+Left clicking the minimap icon."

L["DEFAULT_BODY_WELCOME"] = "Welcome to TorghastTeams!"
L["DEFAULT_BODY_TAGLINE"] = "Your favorite tool for playing Torghast with friends!"
L["DEFAULT_BODY_INFORMATION"] = "This AddOn lets you see all of the Anima Powers that you and your party pick up, so you don't have to memorize their builds from the chat window.\n\nYou can see every party member's build at the same time, letting you play around their Anima Powers and just see what kind of cool and fun powers they've chosen."
L["DEFAULT_BODY_PROMPT"] = "Get started by queuing up for Torghast by yourself or with a party, then click the minimap button or type '/tgt show' to bring up the Anima Powers screen!"
L["DEFAULT_BODY_COMMANDS"] = "Type /tgt or /torghastteams to see all available commands."

L["COMMAND_MINIMAP_EXAMPLE"] = "/tgt minimap"
L["COMMAND_MINIMAP_NAME"] = "Minimap Button Toggle"
L["COMMAND_MINIMAP_DESC"] = "Toggles the display of the minimap button."
L["COMMAND_SHOW_EXAMPLE"] = "/tgt show"
L["COMMAND_SHOW_NAME"] = "Show Interface"
L["COMMAND_SHOW_DESC"] = "Shows the TorghastTeams Frame."
L["COMMAND_HIDE_EXAMPLE"] = "/tgt hide"
L["COMMAND_HIDE_NAME"] = "Hide Interface"
L["COMMAND_HIDE_DESC"] = "Hides the TorghastTeams Frame."

L["TOGGLE_MODE_WARNING"] = "You must be in Torghast to cycle between display modes mode."
L["MOVE_FRAME_WARNING"] = "You can't move this container right now. Switch to Simple Mode (Ctrl+Left click minimap button) to move it."
