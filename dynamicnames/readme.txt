Hey, we're super glad you decided to purchase Dynamic Names! There's a few things you should know before you get started, though.

Please read this in full.

-- MAIN USAGE --
This addon is very easy to use so long as your brain cells aren't fried from smoking methamphetamines. Most important config options can be found in-game, however there are
some that you may want to make note of in the file "sh_dynamicnames.lua" found in the "lua/autorun" directory. I would recommend tweaking the length limits to meet your needs,
however you should be reading the comments left throughout the file so you understand what to do and what not to do to give your players the best possible experience with this
addon.

-- USING IDs --
If you, for whatever reason, suddenly decide to start using the ID number system when you have not been using it before, there may be some issues you'll have to take into account.
If it was disabled beforehand, all players will have an id of "NULL" (which I assume you don't want). So, to fix this you will have to delete all player data from the addon. I
understand that it's annoying to have everyone set their names again, however this is necessary if you want to start using IDs. To do this, simply changed the "drop player data"
option to true, and SET IT TO FALSE ONCE YOUR SERVER IS UP IF YOU DO NOT WANT ALL DATA TO BE WIPED EVERY TIME THE ADDON GETS LOADED.

-- NPC Models --
The NPC gun allows you to set a model for the name change NPC. You have to be careful though, because you can NOT use a playermodel. If the model path has /player/ in it, the NPC
will t-pose. Other models will work.