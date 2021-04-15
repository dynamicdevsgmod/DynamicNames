AddCSLuaFile("entities/dynnms_namechange/shared.lua")
AddCSLuaFile("entities/dynnms_namechange/cl_init.lua")

include("entities/dynnms_namechange/shared.lua")

util.AddNetworkString("dynNms_NPCMenuPrompt")
util.AddNetworkString("dynNms_StartMenu")
util.AddNetworkString("dynNms_NPCCantAfford")

function ENT:Initialize()
 
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE || CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
 
	self:SetMaxYawSpeed( 90 )
	
	self:SetMaxHealth(1)
	self:SetHealth(self:GetMaxHealth())
 
end

function ENT:AcceptInput( input, cause, player, data )	
	if input == "Use" and player:IsPlayer() then
		local p = self:GetNWFloat("Price")

		local JSONPlys = file.Read("dynamic_names/data/changedname.txt", "DATA")
		local plys = util.JSONToTable(JSONPlys)

		local plyToSend = player

		if p <= 0 then 
			net.Start("dynNms_menuPrompted")
				if plys[plyToSend:SteamID()] then
					plys[plyToSend:SteamID()] = nil
				end
			net.Send(plyToSend)
			JSONPlys = util.TableToJSON(plys)
			file.Write("dynamic_names/data/changedname.txt", JSONPlys)
			return
		end

		net.Start("dynNms_NPCMenuPrompt")
			net.WriteFloat(self:GetNWFloat("Price", 0))
		net.Send(plyToSend)
		JSONPlys = util.TableToJSON(plys)
		file.Write("dynamic_names/data/changedname.txt", JSONPlys)
	end
	net.Receive("dynNms_StartMenu", function(len,ply)
		if timer.Exists("dynNms_netCD3") then return end
		timer.Create("dynNms_netCD3", 0.8, 1, function()
			timer.Remove("dynNms_netCD3")
		end )
		local JSONPlys = file.Read("dynamic_names/data/changedname.txt", "DATA")
		local plys = util.JSONToTable(JSONPlys)
		local p = self:GetNWFloat("Price", 0)
	
		if !ply:canAfford(p) then
			net.Start("dynNms_NPCCantAfford")
			net.Send(ply)
			return
		end
		ply:addMoney(-p)
	
		net.Start("dynNms_menuPrompted")
			if plys[ply:SteamID()] then
				plys[ply:SteamID()] = nil
			end
		net.Send(ply)
		JSONPlys = util.TableToJSON(plys)
		file.Write("dynamic_names/data/changedname.txt", JSONPlys)
	end )
end

function ENT:OnTakeDamage(dmginfo)
	dmginfo:SetDamage(0)
end