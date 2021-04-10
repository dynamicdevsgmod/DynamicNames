local dir = "dynamicnames"

local cl_files = file.Find(dir.."/client/cl_*.lua", "LUA")
local sv_files = file.Find(dir.."/server/sv_*.lua", "LUA")
local shared = file.Find(dir.."/sh_*.lua", "LUA")

for _,file in ipairs(shared) do
    include(dir.."/"..file)
end

if SERVER then
    for _,file in ipairs(sv_files) do
        include(dir.."/server/"..file)
    end
    for _,file in ipairs(cl_files) do
        AddCSLuaFile(dir.."/client/"..file)
    end
    for _,file in ipairs(shared) do
        AddCSLuaFile(dir.."/"..file)
    end
end

if CLIENT then
    for _,file in ipairs(cl_files) do
        include(dir.."/client/"..file)
    end
    for _,file in ipairs(shared) do
        include(dir.."/"..file)
    end
end