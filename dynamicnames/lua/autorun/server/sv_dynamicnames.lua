include("autorun/sh_dynamicnames.lua")

if !sql.TableExists( "dynNms_player_data" ) then
    sql.Query("CREATE TABLE dynNms_player_data( steamid64 VARCHAR(255), steamid VARCHAR(255), firstName VARCHAR(255), lastName VARCHAR(255), idNum VARCHAR(255) )")
end -- Initially wrote with just the steamid, but ran into problems with the avatar in the admin menu because it needed the ID64.
if !file.Exists( "dynamic_names", "DATA" ) then
    file.CreateDir("dynamic_names")
end
if !file.Exists("dynamic_names/data", "DATA") then
    file.CreateDir("dynamic_names/data")
end

-- Content
resource.AddFile("sound/dynamicnames/tadah_pingpingping.mp3")
resource.AddFile("sound/dynamicnames/error_bump.mp3")
resource.AddFile("sound/dynamicnames/button_click.mp3")
--

-- Networking
util.AddNetworkString("dynNms_whenTableToClient")
util.AddNetworkString("dynNms_tableToClient")


util.AddNetworkString( "dynNms_plyInit" )
util.AddNetworkString("dynNms_sendDataToClient")
util.AddNetworkString("dynNms_nameToSet")

util.AddNetworkString("MenuPrompt_Request")
util.AddNetworkString("MenuPrompt_Prompted")
--

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
            net.WriteTable(sql.Query("SELECT steamid64, steamid, firstName, lastName, idNum FROM dynNms_player_data")) -- Apparently we shouldn't use this, if I have the time I'll figure out how to alternatively format this.
        net.Send(ply)
end )


net.Receive( "dynNms_nameToSet", function( len, ply )
    local stringPly = tostring(ply)

    if timer.Exists(stringPly) then MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they should be changing their name right now. \n") return end
    timer.Create(stringPly, 0, 0, function() end)

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

net.Receive("MenuPrompt_Request", function(len, ply)  -- When an admin presses the button on the far right of the player panel (in the admin menu)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to prompt the player menu. \n")
        return
    end

    local plyToSend = net.ReadEntity()
    local stringPly = tostring(plyToSend)

    net.Start("MenuPrompt_Prompted")
        if timer.Exists(stringPly) then
            timer.Remove(stringPly)
            print("Timer destroyed.")
        end
    net.Send(plyToSend)
end )