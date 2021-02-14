include("autorun/sh_dynamicnames.lua")


resource.AddFile("sound/dynamicnames/tadah_pingpingping.mp3")

util.AddNetworkString( "dynNms_plyInit" )

--[[net.Receive( "dynNms_plyInit", function( len, ply )
	sql.Query("CREATE TABLE IF NOT EXISTS dynNms_player_data( steamid TEXT, firstName TEXT, lastName TEXT, idNum TEXT, rank TEXT )")
    sql.Query("IF NOT EXISTS (SELECT steamid FROM dynNms_player_data WHERE steamid ="..ply:SteamID()..") BEGIN INSERT INTO dynNms_player_data( steamid ) VALUES("..ply:SteamID()..") END")
    print(sql.QueryRow)
    if sql.Query("SELECT steamid FROM dynNms_player_data WHERE EXISTS (SELECT steamid FROM dynNms_player_data WHERE dynNms_player_data.steamid = "..ply:SteamID()..")") then
        ply:ChatPrint("Your steamid was found!")
        return
    else
        ply:ChatPrint("Your steamid was not found, we're adding it to the database!")
        --sql.Query("INSERT INTO dynNms_player_data( steamid ) VALUES("..ply:SteamID()..")")
    end
end )]]