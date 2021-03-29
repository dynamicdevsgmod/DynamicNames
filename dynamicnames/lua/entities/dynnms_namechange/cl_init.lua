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
		-- Actually draw the text. Customize this to your liking.
		draw.DrawText( text, "DynamicNames.CloseButton", 0, 0, color_white, TEXT_ALIGN_CENTER )
	cam.End3D2D()
end

function ENT:Draw()
	-- Draw the model
	self:DrawModel()

	local text = "Change Your Name"

	local mins, maxs = self:GetModelBounds()
	local pos = self:GetPos() + Vector( 0, 0, maxs.z + 10 )

    local plyPos = LocalPlayer():GetPos()
    local entPos = self:GetPos()
    local dist = plyPos:DistToSqr(entPos)
    -- print(dist)

    if dist <= 250000 then
        Draw3DText( pos, nil, 0.2, text, false ) 
    end
end