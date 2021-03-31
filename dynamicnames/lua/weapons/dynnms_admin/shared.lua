AddCSLuaFile()

SWEP.Author			= "Dynamic Devs"
SWEP.Instructions	= "Left click to spawn the name change NPC. Left click again on the NPC to configure it. Right click on that NPC to remove it."

SWEP.Spawnable			= true
SWEP.AdminOnly			= true
SWEP.UseHands			= true
SWEP.Category 			= "Dynamic Names"
SWEP.DrawCrosshair      = true

SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_Pistol.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.PrintName			= "Name Change NPC Tool"
SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
    return true
end

function SWEP:DrawHUD()
end

if CLIENT then
    local btnClick = "dynamicnames/button_click.mp3"
    function SWEP:PrimaryAttack()
        if( !IsFirstTimePredicted() ) then return end
        local _et = self.Owner:GetEyeTrace()
        local _ent = _et.Entity
        local _entc = _ent:GetClass()

        if (_et.HitPos:Distance(self.Owner:GetPos()) < 800) and (_entc != "dynnms_namechange") then
            Derma_StringRequest("Edit", "Set Model", "models/gman_high.mdl", function(msg)
                surface.PlaySound(btnClick)
                local ent_mdl = msg

                net.Start("DynamicNames_SetModel")
                    net.WriteString(msg)
                net.SendToServer()
            end, nil )
        elseif (_et.HitPos:Distance(self.Owner:GetPos()) < 800) and (_entc == "dynnms_namechange") then
            local p = _ent:GetNWFloat("Price", 0)
            local r = Derma_StringRequest("Edit", "Set Name Change Price", p, function(msg)
                surface.PlaySound(btnClick)
                p = tonumber(msg)
                net.Start("DynamicNames_SetPrice")
                    if p then
                        net.WriteFloat(p)
                        net.WriteString(msg)
                    end
                net.SendToServer()
            end )
        end
    end
end

if SERVER then
    util.AddNetworkString("DynamicNames_SetModel")
    util.AddNetworkString("DynamicNames_SetPrice")
    function SWEP:PrimaryAttack()
        if( !IsFirstTimePredicted() ) then return end
        local _et = self.Owner:GetEyeTrace()
        local _ent = _et.Entity
        local _entc = _ent:GetClass()

        if (_et.HitPos:Distance(self.Owner:GetPos()) < 800) and (_entc != "dynnms_namechange") then
            net.Receive("DynamicNames_SetModel", function(len,ply)
                if !DynamicNames.AdminGroups[ply:GetUserGroup()] then
                    MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), ply:Name().." may be abusing a net message. Please ensure that they have the proper permissions to use the admin tool. \n")
                    return
                end
                local ent_mdl = net.ReadString()
                   
                local entity = ents.Create( "dynnms_namechange" )
                if ( !IsValid( entity ) ) then return end 
                entity:SetPos( _et.HitPos )
                local entang = self.Owner:GetAngles()
                entity:SetAngles(Angle(0, entang.y, 0) +Angle(0, 180, 0))
                entity:SetModel(ent_mdl)
                entity:Spawn()
                entity:DropToFloor()
            end )
        end
        net.Receive("DynamicNames_SetPrice", function(len,ply)
            local p = net.ReadFloat()
            _ent:SetNWFloat("Price", p)
        end )
    end

    function SWEP:SecondaryAttack()
        if( !IsFirstTimePredicted() ) then return end
        if !DynamicNames.AdminGroups[self.Owner:GetUserGroup()] then
            MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), self.Owner:Name().." may be abusing a net message. Please ensure that they have the proper permissions to use the admin tool. \n")
            return
        end

        local _et = self.Owner:GetEyeTrace()
        local _ent = _et.Entity:GetClass()

        if _et.HitPos:Distance(self.Owner:GetPos()) < 800 then
            if _ent == "dynnms_namechange" then
                _et.Entity:Remove()
            end
        end
    end
end
hook.Add("canDropWeapon", "preventWeaponDrop", function(ply, weapon)
    if weapon:GetPrintName() == "Name Change NPC Tool" then
        return false
    end
end )