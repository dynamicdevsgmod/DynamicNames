include("autorun/sh_dynamicnames.lua")

if !sql.TableExists( "dynNms_player_data" ) then
    sql.Query("CREATE TABLE dynNms_player_data( steamid VARCHAR(255), firstName VARCHAR(255), lastName VARCHAR(255), idNum VARCHAR(255) )")
end

resource.AddFile("sound/dynamicnames/tadah_pingpingping.mp3")
resource.AddFile("sound/dynamicnames/error_bump.mp3")


-- Personally, I think the net code can be cleaned up, but I really don't have the time to look at it all. Maybe I will if we need to go back to the drawing board.
util.AddNetworkString("dynNms_whenTableToClient")
util.AddNetworkString("dynNms_tableToClient")
util.AddNetworkString( "dynNms_plyInit" )
util.AddNetworkString("dynNms_sendDataToClient")
util.AddNetworkString("dynNms_nameToSet")

net.Receive( "dynNms_plyInit", function( len, ply )
    if sql.Query("SELECT steamid FROM dynNms_player_data WHERE steamid = '"..ply:SteamID().."'") then
        return
    else
        sql.Query("INSERT INTO dynNms_player_data ('steamid')VALUES ('"..ply:SteamID().."')")
        net.Start("dynNms_sendDataToClient")
            net.WriteBool(true)
        net.Send( ply )
    end
end ) 

net.Receive("dynNms_whenTableToClient", function(len, ply)
    if net.ReadBool() then
        net.Start("dynNms_tableToClient")
            net.WriteTable(sql.Query("SELECT steamid, firstName, lastName, idNum FROM dynNms_player_data"))
        net.Broadcast()
    end
end )


net.Receive( "dynNms_nameToSet", function( len, ply )
    local firstName = net.ReadString()
    local lastName = net.ReadString()

    if DynamicNames.EnableIDNumber then
        local idNumber = net.ReadString()
        ply:setRPName(firstName.." "..lastName.." "..idNumber)
        sql.Query("UPDATE dynNms_player_data SET firstName = '"..firstName.."', lastName = '"..lastName.."', idNum = '"..idNumber.."' WHERE steamid = '"..ply:SteamID().."'")
    else
        ply:setRPName(firstName.." "..lastName)
        sql.Query("UPDATE dynNms_player_data SET firstName = '"..firstName.."', lastName = '"..lastName.."' WHERE steamid = '"..ply:SteamID().."'")
    end

end )

hook.Add("CanChangeRPName", "DynNms_DisableNameChange", function( ply, name ) 
    return false, "Disabled by Dynamic Names."
end )
