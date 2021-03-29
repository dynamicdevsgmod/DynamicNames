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
		print("You used me!") -- Replace with menu net msg.
	end
end