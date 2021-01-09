local L = LibStub("AceLocale-3.0"):NewLocale("TorghastTeams", "enUS", true)
if not L then return end

--------------------------------------------------------------------------------------------------------------------------------------------
L["CHANGELOG"] = "View the full Changelog on GitHub or CurseForge."

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
L["DEFAULT_BODY_TAGLINE"] = { 
    "Your favorite tool for playing Torghast with friends!",
    "Your favorite tool for playing Torghast with randoms!",
    "Your favorite tool for playing Torghast with annoying guildies!",
    "Party Anima Powers Display",
    "Created by Zerukai and Accuracy114!",
    "Also check out my Minecraft Datapacks!", -- Developer also made some Minecraft Datapacks on their GitHub
    "Will never offer to sell you carries for gold.",
    "[WTS] Torghast Layer 1 carry 750k gold!",
    "Remember to thank your local Addon developer.",
    "Oooh, big scary tower. I'm not afraid of you.",
    "A banshee and her boyfriend walk into a bar...",
    "Always fresh, never Frost Nova'ed",
    "https://github.com/maxheyn/TorghastTeams", -- Source repository
    "We do not condone Maw Rat abuse.",
    "Flame your friends for picking F-tier powers.",
    "All bugs should be ignored for the sake of the developer's mental state.",
    "Does this place have air conditioning?",
    "Use the Ravenous Anima Cell on the Broker before your teammates can buy.",
    "Because you're too weak to solo Layer 8 alone.",
    "togasteems",
    "Okay, but what is Sylvanas actually up to?",
    "A <Quake Star> product.", -- Developer's guild
    "They won't be laughing when the Torghast Raid comes out.",
    "Thanks for the suggestions and feedback, raptormama!", -- First external contributor / issues raised on GitHub
    "THAT'S A 50 DKP MINUS!",
    "Now with stupid, silly, alternating taglines.",
    "Esports Ready",
    "Barrens Chat v2.0",
    "You only lost because you got unlucky.",
    "If you like it, tell your friends/guild about it!",
    "Phantastic AddOn",
    "Always pick the shiny purple powers.",
    "Alliance > Horde",
    "Horde > Alliance",
    "Hacking into the Torghast defense grid mainframe.",
    "Faker, what was that!?",
    "Hi, Blizzard. Please hire me. I can do cool stuff.",
    "He died to the axe trap. Twice.",
    "The smokey phylacteries have powers inside!",
    "Imagine picking defensive powers, nerd.",
    "Fleeting Frenzy Potions are pretty good!",
    "Thanks for all the downloads everyone! Means a lot to us!",
    "Ad free, AND gluten free!",
    "We want more Anima powers!!!",
    "Please give us some cosmetic rewards for this, Blizz.",
    "Speedrun Any% Glitchless Co-op Tarragrue Kill (Layer 8, Soulforges).",
    "Bring those Weapon Oils, they're super cheap!",
    "Wait for Bloodlust for every pack to make sure you don't die.",
    "print(\"TorghastTeams_FunnyTagline\")",
    "Because you're 10 Soul Ash off of your next legendary...",
    "Is it too easy, too hard? You people can't decide.",
    "Finish a layer with 1000 Phantasma for an achievement!",
    "Count from 0 to 15 in binary to solve the lever chests!",
    "No Maw Rats Allowed!",
    "Invite some lower item level players along, share the love!",
    "!ereht olleh ,siht daer nac uoy fI", -- "If you can read this, hello there!" but backwards
    "Jailer-O's, part of a balanced breakfast.",
    "Maw Rat tested, Ve'nari approved!",
    "What's the DEAL with those Maw Rats?",
    "You can jump onto the pedestal in the middle of the Torghast lobby.",
    "insert funny tagline text here",
    "Not safe for human consumption.",
    "No tagline this time, sorry. Try again later.",
    "Who are you people!?",
    "These taglines are getting pretty annoying.",
    "Come on man, don't you have any better taglines than this?",
    "LFM Twisting Corridors Layer 8 Raid",
    "World First Tarragrue Kill",
    "togas, tower of dang",
    "Who is George Lucas?",
    "Anima Power is stored in the cells.",
    "There are a total of 144 floors in all Twisting Corridors.",
    "Sylvanas, you're acting like a total buzzkill right about now.",
    "Death Knights have some of the coolest Anima Powers.",
    "",
}

L["DEFAULT_BODY_INFORMATION"] = "TorghastTeams lets you see all of the Anima Powers that you and your party pick up, so you don't have to memorize their builds from the chat window.\n\nYou can see every party member's build at the same time, letting you play around their Anima Powers and just see what kind of cool and fun powers they've chosen."
L["DEFAULT_BODY_PROMPT"] = "Get started by queuing up for Torghast by yourself or with a party, then click the minimap button or type '/tgt show' to bring up the Anima Powers screen!"
L["DEFAULT_BODY_COMMANDS"] = "Type /tgt or /torghastteams to see all available commands."

L["COMMAND_MINIMAP_EXAMPLE"] = "/tgt minimap"
L["COMMAND_MINIMAP_NAME"] = "Minimap Button Toggle"
L["COMMAND_MINIMAP_DESC"] = "Toggles the display of the minimap button."
L["COMMAND_SHOW_EXAMPLE"] = "/tgt show"
L["COMMAND_SHOW_NAME"] = "Show Interface"
L["COMMAND_SHOW_DESC"] = "Shows the TorghastTeams Interface."
L["COMMAND_HIDE_EXAMPLE"] = "/tgt hide"
L["COMMAND_HIDE_NAME"] = "Hide Interface"
L["COMMAND_HIDE_DESC"] = "Hides the TorghastTeams Interface."

L["TOGGLE_MODE_WARNING"] = "You must be in Torghast to cycle between display modes mode."
L["MOVE_FRAME_WARNING"] = "You can't move this container right now. Switch to Simple Mode (Ctrl+Left click minimap button) to move it."

L["PHANTASMA_BROADCAST_HAS"] = "has"
