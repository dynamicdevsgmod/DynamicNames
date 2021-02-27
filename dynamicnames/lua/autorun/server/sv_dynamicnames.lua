include("autorun/sh_dynamicnames.lua")

--[[ An example of safe to use SQL
sql.Query(("INSERT INTO sql_safetyTesting_table(col1 , col2)VALUES (%s, %s) "):format(sql.SQLStr("Aghh"), sql.SQLStr("SQL is cool")))]]

if !sql.TableExists( "dynNms_player_data" ) then
    sql.Query("CREATE TABLE dynNms_player_data( steamid64 VARCHAR(255), steamid VARCHAR(255), firstName VARCHAR(255), lastName VARCHAR(255), idNum VARCHAR(255) )")
end

--sql.Query("DROP TABLE dynNms_player_data")

resource.AddFile("sound/dynamicnames/tadah_pingpingping.mp3")
resource.AddFile("sound/dynamicnames/error_bump.mp3")

util.AddNetworkString("dynNms_whenTableToClient")
util.AddNetworkString("dynNms_tableToClient")


util.AddNetworkString( "dynNms_plyInit" )
util.AddNetworkString("dynNms_sendDataToClient")
util.AddNetworkString("dynNms_nameToSet")

util.AddNetworkString("MenuPrompt_Request")
util.AddNetworkString("MenuPrompt_Prompted")

net.Receive( "dynNms_plyInit", function( len, ply )
    if sql.Query("SELECT steamid FROM dynNms_player_data WHERE steamid = '"..ply:SteamID().."'") then
        return
    else
        sql.Query("INSERT INTO dynNms_player_data (steamid64, steamid)VALUES ('"..ply:SteamID64().."','"..ply:SteamID().."')")
        net.Start("dynNms_sendDataToClient")
            net.WriteBool(true)
        net.Send( ply )
    end
end ) 

net.Receive("dynNms_whenTableToClient", function(len, ply)
        net.Start("dynNms_tableToClient")
            net.WriteTable(sql.Query("SELECT steamid64, steamid, firstName, lastName, idNum FROM dynNms_player_data"))
        net.Send(ply)
end )


net.Receive( "dynNms_nameToSet", function( len, ply )
    local firstName = net.ReadString()
    local lastName = net.ReadString()

    if DynamicNames.EnableIDNumber then
        local idNumber = net.ReadString()
        ply:setRPName(firstName.." "..lastName.." "..idNumber)
        sql.Query(("UPDATE dynNms_player_data SET `firstName`=%s, `lastName`=%s, `idNum`=%s WHERE `steamid`=%s"):format(sql.SQLStr(firstName), sql.SQLStr(lastName), sql.SQLStr(idNumber), sql.SQLStr(ply:SteamID())))
    else
        ply:setRPName(firstName.." "..lastName)
        sql.Query(("UPDATE dynNms_player_data SET `firstName`=%s, `lastName`=%s WHERE `steamid`=%s"):format(sql.SQLStr(firstName), sql.SQLStr(lastName), sql.SQLStr(ply:SteamID())))
    end

    
end )

hook.Add("CanChangeRPName", "DynNms_DisableNameChange", function( ply, name ) 
    return false, "Disabled by Dynamic Names."
end )

net.Receive("MenuPrompt_Request", function() 
    net.Start("MenuPrompt_Prompted")
    net.Send(net.ReadEntity())
end )
