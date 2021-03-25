-- It's easier to handle these in a separate file.
include("autorun/sh_dynamicnames.lua")


if !file.Exists( "dynamic_names/data/prefixes.txt", "DATA") then
    local defaultPrefix = util.TableToJSON({
        ["Hobo"] = "Poor #firstName",
        ["Mob boss"] = "Boss #lastName"
    })

    file.Write("dynamic_names/data/prefixes.txt", defaultPrefix)
end

util.AddNetworkString("DynamicNames_prfxEditJobName")
util.AddNetworkString("DynamicNames_DelPrefix")
util.AddNetworkString("DynamicNames_EditPrefix")
util.AddNetworkString("DynamicNames_AddPrefix")
util.AddNetworkString("DynamicNames_RetrievePrefixes")
util.AddNetworkString("DynamicNames_SendPrefixes")

net.Receive("DynamicNames_RetrievePrefixes", function(len, ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        return
    end
    local PrefixJSON = file.Read("dynamic_names/data/prefixes.txt", "DATA")
    local ServerPrefixes = util.JSONToTable(PrefixJSON)

    net.Start("DynamicNames_SendPrefixes")
        net.WriteTable(ServerPrefixes)
    net.Send(ply)
end)

net.Receive("DynamicNames_prfxEditJobName", function(len, ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to edit job prefixes. \n")
        return
    end
    
    local oldJobName = net.ReadString()
    local newJobName = net.ReadString()

    local PrefixJSON = file.Read("dynamic_names/data/prefixes.txt", "DATA")
    local ServerPrefixes = util.JSONToTable(PrefixJSON)

    local oldValue = ServerPrefixes[oldJobName]

    ServerPrefixes[oldJobName] = nil
    ServerPrefixes[newJobName] = oldValue

    PrefixJSON = util.TableToJSON(ServerPrefixes)
    file.Write("dynamic_names/data/prefixes.txt", PrefixJSON)

end )

net.Receive("DynamicNames_EditPrefix", function(len, ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to edit job prefixes. \n")
        return
    end
    
    local job = net.ReadString()
    local prefix = net.ReadString()

    local PrefixJSON = file.Read("dynamic_names/data/prefixes.txt", "DATA")
    local ServerPrefixes = util.JSONToTable(PrefixJSON)

    ServerPrefixes[job] = prefix

    PrefixJSON = util.TableToJSON(ServerPrefixes)
    file.Write("dynamic_names/data/prefixes.txt", PrefixJSON)

end )



net.Receive("DynamicNames_DelPrefix", function(len, ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to edit job prefixes. \n")
        return
    end

    local toDelete = net.ReadString()

    local PrefixJSON = file.Read("dynamic_names/data/prefixes.txt", "DATA")
    local ServerPrefixes = util.JSONToTable(PrefixJSON)

    ServerPrefixes[toDelete] = nil

    PrefixJSON = util.TableToJSON(ServerPrefixes)
    file.Write("dynamic_names/data/prefixes.txt", PrefixJSON)
end )

net.Receive("DynamicNames_AddPrefix", function(len, ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to edit job prefixes. \n")
        return
    end

    local job = net.ReadString()
    local prefix = net.ReadString()

    local PrefixJSON = file.Read("dynamic_names/data/prefixes.txt", "DATA")
    local ServerPrefixes = util.JSONToTable(PrefixJSON)

    ServerPrefixes[job] = prefix

    PrefixJSON = util.TableToJSON(ServerPrefixes)
    file.Write("dynamic_names/data/prefixes.txt", PrefixJSON)
end )

hook.Add("PlayerChangedTeam", "SetPrefix", function(ply, oldTeam, newTeam)
    local JSONPrefs = file.Read("dynamic_names/data/config.txt", "DATA")
    local prefs = util.JSONToTable(JSONPrefs)

    local teamName = team.GetName(newTeam)

    local firstname = sql.Query("SELECT firstName FROM dynNms_player_data WHERE steamid = '"..ply:SteamID().."'")            
    local lastname = sql.Query("SELECT lastName FROM dynNms_player_data WHERE steamid = '"..ply:SteamID().."'")

    local fullname = firstname[1].firstName.." "..lastname[1].lastName

    local PrefixJSON = file.Read("dynamic_names/data/prefixes.txt", "DATA")
    local ServerPrefixes = util.JSONToTable(PrefixJSON)

    if ServerPrefixes[teamName] then          
        local setprfxName = string.Replace(ServerPrefixes[teamName], "#firstName", firstname[1].firstName)
        setprfxName = string.Replace(setprfxName, "#lastName", lastname[1].lastName)

        if prefs["EnableIDNumber"] then
            local idn = sql.Query("SELECT idNum FROM dynNms_player_data WHERE steamid = '"..ply:SteamID().."'")
            setprfxName = string.Replace(setprfxName, "#idNum", idn[1].idNum)
        end
        ply:setRPName( setprfxName, false )
    elseif ply:Name() != fullname then

        ply:setRPName( firstname[1].firstName.." "..lastname[1].lastName, false )
        
    end
end )