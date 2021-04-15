if !DynamicNames then return end

if !file.Exists( "dynamic_names/data/config.txt", "DATA") then
    local defaultPrefs = util.TableToJSON({
        ["EnableIDNumber"] = true,
        ["EnableMenuBlur"] = true,
        ["BannedNames"] = {
            ["hitler"] = true,
            ["stalin"] = true
        },
        ["BypassName"] = {
            ["Citizen"] = true,
        }
    })

    file.Write("dynamic_names/data/config.txt", defaultPrefs)
end

util.AddNetworkString("dynNms_RetrievePrefs")
util.AddNetworkString("dynNms_SendPrefs")
util.AddNetworkString("dynNms_ToggleConfig")
util.AddNetworkString("dynNms_TableConfig")

net.Receive("dynNms_RetrievePrefs", function(len,ply)
    if timer.Exists("dynNms_netCD2") then return end
    timer.Create("dynNms_netCD2", 0.5, 1, function()
        timer.Remove("dynNms_netCD2")
    end )

    local PrefsJSON = file.Read("dynamic_names/data/config.txt", "DATA")
    local ServerPrefs = util.JSONToTable(PrefsJSON)

    net.Start("dynNms_SendPrefs")
        net.WriteTable(ServerPrefs)
    net.Send(ply)
end )

net.Receive("dynNms_ToggleConfig", function(len,ply)
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

net.Receive("dynNms_TableConfig", function(len,ply)
    if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
        MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to edit config options. \n")
        return
    end

    local JSONPrefs = file.Read("dynamic_names/data/config.txt", "DATA")
    local prefs = util.JSONToTable(JSONPrefs)

    local key = net.ReadString()
    local key2 = net.ReadString()
    local isDeleting = net.ReadBool()
    local isAdding = net.ReadBool()

    prefs[key][key2] = nil
    if !isDeleting then
        local newVal = net.ReadString()
        if !isAdding then
            prefs[key][newVal] = true
        else
            prefs[key][string.lower(key2)] = true
        end
    end

    JSONPrefs = util.TableToJSON(prefs)
    file.Write("dynamic_names/data/config.txt", JSONPrefs)
end )