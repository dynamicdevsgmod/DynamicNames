include("shared.lua")

-- Draw some 3D text
local function Draw3DText( pos, ang, scale, text, flipView )
	if ( flipView ) then
		-- Flip the angle 180 degrees around the UP axis
		ang:RotateAroundAxis( Vector( 0, 0, 1 ), 180 )
	end

    local angle = EyeAngles()
    angle = Angle( 0, angle.y, 0 )
    angle:RotateAroundAxis( angle:Up(), -90 )
	angle:RotateAroundAxis( angle:Forward(), 90 )

	cam.Start3D2D( pos, angle, scale )
		-- draw.DrawText( text, "DynamicNames.3D2D", 0, 0, color_white, TEXT_ALIGN_CENTER )
		draw.SimpleTextOutlined(text, "DynamicNames.3D2D", 0,0, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0))
	cam.End3D2D()
end

function ENT:Draw()
	self:DrawModel()

	local text = "Change Your Name"

	local mins, maxs = self:GetModelBounds()
	local pos = self:GetPos() + Vector( 0, 0, maxs.z + 6 )

    local plyPos = LocalPlayer():GetPos()
    local entPos = self:GetPos()
    local dist = plyPos:DistToSqr(entPos)

    if dist <= 250000 then
        Draw3DText( pos, nil, 0.1, text, false )
    end
end