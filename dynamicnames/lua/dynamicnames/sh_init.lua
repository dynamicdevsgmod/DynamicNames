-- Hey, we're super glad you decided to download Dynamic Names! There's a few things you should know before you get started, though.

-- Please read this in full.

-- -- MAIN USAGE --
-- This addon is very easy to use so long as your brain cells aren't fried from smoking methamphetamines. Most important config options can be found in-game, however there are
-- some that you may want to make note of in this. I would recommend tweaking the length limits to meet your needs,
-- however you should be reading the comments left throughout the file so you understand what to do and what not to do to give your players the best possible experience with this
-- addon.

-- -- USING IDs --
-- If you, for whatever reason, suddenly decide to start using the ID number system when you have not been using it before, there may be some issues you'll have to take into account.
-- If it was disabled beforehand, all players will have an id of "NULL" (which I assume you don't want). So, to fix this you will have to delete all player data from the addon. I
-- understand that it's annoying to have everyone set their names again, however this is necessary if you want to start using IDs. To do this, simply changed the "drop player data"
-- option to true, and SET IT TO FALSE ONCE YOUR SERVER IS UP IF YOU DO NOT WANT ALL DATA TO BE WIPED EVERY TIME THE ADDON GETS LOADED.

-- -- NPC Models --
-- The NPC gun allows you to set a model for the name change NPC. You have to be careful though, because you can NOT use a playermodel. If the model path has /player/ in it, the NPC
-- will t-pose. Other models will work.


DynamicNames = {}
--[[----------------------------------------------------------------------------------------------------------------
--  _____                              _        _   _                              _____             __ _         --
-- |  __ \                            (_)      | \ | |                            / ____|           / _(_)        --
-- | |  | |_   _ _ __   __ _ _ __ ___  _  ___  |  \| | __ _ _ __ ___   ___  ___  | |     ___  _ __ | |_ _  __ _   --
-- | |  | | | | | '_ \ / _` | '_ ` _ \| |/ __| | . ` |/ _` | '_ ` _ \ / _ \/ __| | |    / _ \| '_ \|  _| |/ _` |  --
-- | |__| | |_| | | | | (_| | | | | | | | (__  | |\  | (_| | | | | | |  __/\__ \ | |___| (_) | | | | | | | (_| |  --
-- |_____/ \__, |_| |_|\__,_|_| |_| |_|_|\___| |_| \_|\__,_|_| |_| |_|\___||___/  \_____\___/|_| |_|_| |_|\__, |  --
--          __/ |                                                                                          __/ |  --
--         |___/                                                                                          |___/   --
]]------------------------------------------------------------------------------------------------------------------

-- The following three settings must add up to 30 collectively as that is the rpname length limit. 
--If you aren't using the ID number then only the name lengths have to add up to 30.
DynamicNames.firstNameLength = 13
DynamicNames.lastNameLength = 13
DynamicNames.IDNumberLength = 4 -- If ID Numbers are enabled this will then set the max length of the ID number. 

DynamicNames.AdminGroups = { -- List of all ranks that have access to the Admin Menu. These are case sensitive.
	["superadmin"] = true, -- Don't forget to put commas after each entry.
}



-- USE CAUTION WHEN EDITING -- 

DynamicNames.Red = Color(231, 76, 60)
DynamicNames.Green = Color(39, 174, 96)

DynamicNames.Themes = { -- Cosmetic customization options
	Default = { -- Used in the main menu for the addon
		["Header"] = Color(82,82,82),
		["Frame"] = Color(47,54,64),
		["SubmitButton"] = Color(68,68,68),
		["SubmitHighlight"] = Color(69,147,211),
	},
	AdminMenu = { -- Used in the admin panel (Some themes are shared between default and this.)
		["Navbar Background"] = Color(207,207,207),
		["Navbar Buttons Color"] = Color(44, 62, 80),
		["Navbar Tabs Accent"] = Color(225, 112, 85),
	},

}

DynamicNames.AllowClose = true -- You probably want to keep this false if you don't want players skipping the name prompt. It's meant for development.

DynamicNames.AllowNameChange = false --[[ This is pretty pointless to have enabled, however you may want it. Basically it allows people to change their names to whatever they want using /name. 
When they switch jobs it will be changed back to their set name or the job prefix.]]

-- DANGER, BE VERY CAREFUL WHEN EDITING --
-- SERIOUSLY, READ THE README BEFORE YOU MESS WITH THIS --
DynamicNames.DropPlayerData = false -- If true, it will drop all name data from the addon every time the addon loads. This should only ever be true once, do not forget about it and leave it on.