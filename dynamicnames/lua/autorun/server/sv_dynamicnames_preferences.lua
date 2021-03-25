include("autorun/sh_dynamicnames.lua")

if !file.Exists( "dynamic_names/data/config.txt", "DATA") then
    local defaultPrefs = util.TableToJSON({
        ["EnableIDNumber"] = true,
    })

    file.Write("dynamic_names/data/config.txt", defaultPrefs)
end

util.AddNetworkString("DynamicNames_RetrievePrefs")
util.AddNetworkString("DynamicNames_SendPrefs")
util.AddNetworkString("DynamicNames_ToggleConfig")

net.Receive("DynamicNames_RetrievePrefs", function(len,ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        return
    end

    local PrefsJSON = file.Read("dynamic_names/data/config.txt", "DATA")
    local ServerPrefs = util.JSONToTable(PrefsJSON)

    net.Start("DynamicNames_SendPrefs")
        net.WriteTable(ServerPrefs)
    net.Send(ply)
end )

net.Receive("DynamicNames_ToggleConfig", function(len,ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to edit config options. \n")
        return
    end

    local JSONPrefs = file.Read("dynamic_names/data/config.txt", "DATA")
    local prefs = util.JSONToTable(JSONPrefs)

    local key = net.ReadString()
    local newVal = net.ReadBool()

    prefs[key] = newVal

    JSONPrefs = util.TableToJSON(prefs)
    file.Write("dynamic_names/data/config.txt", JSONPrefs)

end )