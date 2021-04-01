if !DarkRP then
	if SERVER then return end
    MsgC( MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), "[FATAL ERROR] ", color_white, "DarkRP functions are not available. Please ensure that your gamemode has a DarkRP base before using this addon. \n"))
    return
end

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
	["superadmin"] = true,
}



-- USE CAUTION WHEN EDITING -- 

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

DynamicNames.AllowClose = false -- You probably want to keep this false if you don't want players skipping the name prompt. It's meant for development.

DynamicNames.AllowNameChange = false --[[ This is pretty pointless to have enabled, however you may want it. Basically it allows people to change their names to whatever they want using /name. 
When they switch jobs it will be changed back to their set name or the job prefix.]]

-- DANGER, BE VERY CAREFUL WHEN EDITING --
-- SERIOUSLY, READ THE README BEFORE YOU MESS WITH THIS --
DynamicNames.DropPlayerData = false -- If true, it will drop all name data from the addon every time the addon loads. This should only ever be true once, do not forget about it and leave it on.