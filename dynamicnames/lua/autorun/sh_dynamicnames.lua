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

DynamicNames.AllowClose = true -- You probably want to keep this false if you don't want players skipping the name prompt. It's meant for development.

DynamicNames.EnableBlur = true -- Enable background blur around the menus.

DynamicNames.EnableIDNumber = true -- An ID number is primarily found on SWRP and SCPRP, For example the name for a Clone Trooper may be `CT PVT #### John` where the `#` is the ID number would be.


-- The following three settings must add up to 30 collectively as that is the rpname length limit. 
--If you aren't using the ID number then only the name lengths have to add up to 30.
DynamicNames.IDNumberLength = 4 -- If ID Numbers are enabled this will then set the length of the ID number. 
DynamicNames.firstNameLength = 13
DynamicNames.lastNameLength = 13

DynamicNames.AdminGroups = { -- List of all ranks that have access to the Admin Menu. Use the same format that the other tables do.
	["superadmin"] = true,
}

DynamicNames.BannedNames = {  -- List of all BANNED names for both first and last names. When adding BANNED names keep them all lowercase!
    ["hitler"] = true,
    ["stalin"] = true,
    ["garry"] = false, -- you DO NOT need to add names here as false. This is here for example purposes only
}

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




