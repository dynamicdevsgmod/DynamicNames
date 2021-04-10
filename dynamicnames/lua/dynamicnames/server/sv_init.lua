if !DynamicNames then
    MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), "Some files didn't load properly, Dynamic Names will not work! Try restarting your server. \n")
    return
end

if !sql.TableExists( "dynNms_player_data" ) then -- Initially wrote with just the steamid, but ran into problems with the avatar in the admin menu because it needed the ID64.
    sql.Query("CREATE TABLE dynNms_player_data( steamid64 VARCHAR(255), steamid VARCHAR(255), firstName VARCHAR(255), lastName VARCHAR(255), idNum VARCHAR(255) )")
elseif sql.TableExists( "dynNms_player_data" ) and DynamicNames.DropPlayerData then
    sql.Query("DROP TABLE dynNms_player_data")
    sql.Query("CREATE TABLE dynNms_player_data( steamid64 VARCHAR(255), steamid VARCHAR(255), firstName VARCHAR(255), lastName VARCHAR(255), idNum VARCHAR(255) )")
    file.Delete("dynamic_names/data/changedname.txt")
end
if !file.Exists( "dynamic_names", "DATA" ) then
    file.CreateDir("dynamic_names/data")
end
if !file.Exists("dynamic_names/data/changedname.txt", "DATA") then
    file.Write("dynamic_names/data/changedname.txt", util.TableToJSON({["fakePly"] = true}))
end
-- Content
resource.AddFile("sound/dynamicnames/tadah_pingpingping.mp3")
resource.AddFile("sound/dynamicnames/error_bump.mp3")
resource.AddFile("sound/dynamicnames/button_click.mp3")
resource.AddFile("sound/dynamicnames/click_on.mp3")
resource.AddFile("sound/dynamicnames/click_off.mp3")
resource.AddFile("materials/dynamicnames/dcolcat-triangle.png")
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
        net.Send( ply )
    end
end ) 

net.Receive("dynNms_whenTableToClient", function(len, ply)
        net.Start("dynNms_tableToClient")
            net.WriteTable(sql.Query("SELECT steamid64, steamid, firstName, lastName, idNum FROM dynNms_player_data"))
        net.Send(ply)
end )


net.Receive( "dynNms_nameToSet", function( len, ply )
    local stringPly = tostring(ply)
    local pteam = team.GetName(ply:Team())
    
    local JSONPlys = file.Read("dynamic_names/data/changedname.txt", "DATA")
    local plys = util.JSONToTable(JSONPlys)
    local JSONPrefs = file.Read("dynamic_names/data/config.txt", "DATA")
    local prefs = util.JSONToTable(JSONPrefs)
    local PrefixJSON = file.Read("dynamic_names/data/prefixes.txt", "DATA")
    local ServerPrefixes = util.JSONToTable(PrefixJSON)

    if plys[ply:SteamID()] then MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they should be changing their name right now. \n") return end
    plys[ply:SteamID()] = true

    local firstName = net.ReadString()
    local lastName = net.ReadString()
    if prefs["EnableIDNumber"] then
        local idNumber = net.ReadString()
        sql.Query(("UPDATE dynNms_player_data SET `firstName`=%s, `lastName`=%s, `idNum`=%s WHERE `steamid`=%s"):format(sql.SQLStr(firstName), sql.SQLStr(lastName), sql.SQLStr(idNumber), sql.SQLStr(ply:SteamID())))
    else
        sql.Query(("UPDATE dynNms_player_data SET `firstName`=%s, `lastName`=%s WHERE `steamid`=%s"):format(sql.SQLStr(firstName), sql.SQLStr(lastName), sql.SQLStr(ply:SteamID())))
    end

    if ServerPrefixes[pteam] then          
        local setprfxName = string.Replace(ServerPrefixes[pteam], "#firstName", firstName)
        setprfxName = string.Replace(setprfxName, "#lastName", lastName)

        if prefs["EnableIDNumber"] then
            local idn = sql.Query("SELECT idNum FROM dynNms_player_data WHERE steamid = '"..ply:SteamID().."'")
            setprfxName = string.Replace(setprfxName, "#idNum", idn[1].idNum)
        end
        ply:setRPName( setprfxName, false )
    else
        ply:setRPName( firstName.." "..lastName, false )
    end

    JSONPlys = util.TableToJSON(plys)
    file.Write("dynamic_names/data/changedname.txt", JSONPlys)    
end )

hook.Add("CanChangeRPName", "DynNms_DisableNameChange", function( ply, name )
    local JSONPrefs = file.Read("dynamic_names/data/config.txt", "DATA")
    local prefs = util.JSONToTable(JSONPrefs)

    local t = ply:Team()
    local tn = team.GetName(t)
    local tnl = string.lower(tn)

    if !DynamicNames.AllowNameChange and (!prefs["BypassName"][tnl] and !prefs["BypassName"][tn]) then
        return false, "Disabled by Dynamic Names."
    else
        return true
    end
end )

net.Receive("MenuPrompt_Request", function(len, ply)  -- When an admin presses the button on the far right of the player panel (in the admin menu)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to prompt the player menu. \n")
        return
    end
    local JSONPlys = file.Read("dynamic_names/data/changedname.txt", "DATA")
    local plys = util.JSONToTable(JSONPlys)

    local plyToSend = net.ReadEntity()
    local stringPly = tostring(plyToSend)

    net.Start("MenuPrompt_Prompted")
        if plys[plyToSend:SteamID()] then
            plys[plyToSend:SteamID()] = nil
        end
    net.Send(plyToSend)
    JSONPlys = util.TableToJSON(plys)
    file.Write("dynamic_names/data/changedname.txt", JSONPlys)
end )

