AddCSLuaFile("entities/dynnms_namechange/shared.lua")
AddCSLuaFile("entities/dynnms_namechange/cl_init.lua")

include("entities/dynnms_namechange/shared.lua")
function ENT:Initialize()
 
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE || CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
 
	self:SetMaxYawSpeed( 90 )
 
end

function ENT:AcceptInput( input, cause, player, data )	
	if input == "Use" and player:IsPlayer() then
		local JSONPlys = file.Read("dynamic_names/data/changedname.txt", "DATA")
		local plys = util.JSONToTable(JSONPlys)

		local plyToSend = player
		local stringPly = tostring(plyToSend)

		net.Start("MenuPrompt_Prompted")
			if plys[plyToSend:SteamID()] then
				plys[plyToSend:SteamID()] = nil
			end
		net.Send(plyToSend)
		JSONPlys = util.TableToJSON(plys)
		file.Write("dynamic_names/data/changedname.txt", JSONPlys)
	end
end