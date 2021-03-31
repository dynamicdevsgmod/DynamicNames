ENT.Base                        = "base_ai"
ENT.Type                        = "ai"
ENT.PrintName                   = "Name Change NPC"
ENT.Author						= "Dynamic Devs"
ENT.Category                    = "Dynamic Names"

ENT.AutomaticFrameAdvance       = true
ENT.Spawnable                   = false

function ENT:SetAutomaticFrameAdvance( usingAnim )
	self.AutomaticFrameAdvance = usingAnim
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Price")
	if SERVER then
		self:SetPrice(3)
	end
end