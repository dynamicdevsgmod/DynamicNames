AddCSLuaFile("entities/dynnms_namechange/shared.lua")
AddCSLuaFile("entities/dynnms_namechange/cl_init.lua")

include("entities/dynnms_namechange/shared.lua")

util.AddNetworkString("NPC_MenuPrompt")
util.AddNetworkString("NPC_StartMenu")
util.AddNetworkString("NPC_CantAfford")

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
			net.Start("MenuPrompt_Prompted")
				if plys[plyToSend:SteamID()] then
					plys[plyToSend:SteamID()] = nil
				end
			net.Send(plyToSend)
			JSONPlys = util.TableToJSON(plys)
			file.Write("dynamic_names/data/changedname.txt", JSONPlys)
			return
		end

		net.Start("NPC_MenuPrompt")
			net.WriteFloat(self:GetNWFloat("Price", 0))
		net.Send(plyToSend)
		JSONPlys = util.TableToJSON(plys)
		file.Write("dynamic_names/data/changedname.txt", JSONPlys)
	end
	net.Receive("NPC_StartMenu", function(len,ply)
		local JSONPlys = file.Read("dynamic_names/data/changedname.txt", "DATA")
		local plys = util.JSONToTable(JSONPlys)
		local p = self:GetNWFloat("Price", 0)
	
		if !ply:canAfford(p) then
			net.Start("NPC_CantAfford")
			net.Send(ply)
			return
		end
		ply:addMoney(-p)
	
		net.Start("MenuPrompt_Prompted")
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