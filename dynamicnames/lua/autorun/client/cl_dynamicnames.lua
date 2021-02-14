include("autorun/sh_dynamicnames.lua")


surface.CreateFont( "DynamicNames.Title", {
    font = "Roboto",
    size = 30,
    weight = 500,
    antialias = true,
})

surface.CreateFont( "DynamicNames.CloseButton", {
    font = "Tahoma",
    size = 45,
    weight = 500,
    antialias = true,
})

--[[hook.Add( "InitPostEntity", "playerHasSpawned", function()
	net.Start( "dynNms_plyInit" )
	net.SendToServer()
end )]]

local frameColor = Color(47,54,64)
local submitNoise = "dynamicnames/tadah_pingpingping.mp3"

function DynamicNames.OpenMenu() -- Could use some optimization / localization tbh
    if IsValid(DynamicNames.PlayerMenu) then
        DynamicNames.PlayerMenu:Remove()
    end
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH, animTime, animDelay, animEase = scrw * .4, scrh * .5, 1.8, 0, .1
    DynamicNames.PlayerMenu = vgui.Create("DFrame")
    DynamicNames.PlayerMenu:SetSize(0, 0)
    DynamicNames.PlayerMenu:Center()
    DynamicNames.PlayerMenu:MakePopup()
    DynamicNames.PlayerMenu:SetTitle("")
    DynamicNames.PlayerMenu:ShowCloseButton( true )
    DynamicNames.PlayerMenu:DockPadding(0,0,0,0)
    local isAnimating = true
    DynamicNames.PlayerMenu:SizeTo( frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false
    end )
    DynamicNames.PlayerMenu.Paint = function(self,w,h)
        surface.SetDrawColor(frameColor)
        surface.DrawRect(0,0,w,h)
    end

    local submitButton = DynamicNames.PlayerMenu:Add("DButton")
    submitButton:Dock(BOTTOM)
    submitButton:DockMargin( frameW * .25, 0, frameW * .25, frameH * .05)
    submitButton:SetFont("DynamicNames.Title")
    submitButton:SetText("")
    local speed  = 5
    local percentage = 0
    submitButton.Paint = function(self,w,h)
        if self:IsHovered() then
            percentage = math.Clamp(percentage + speed * FrameTime(), 0, 1)
        else
            percentage = math.Clamp(percentage - speed * FrameTime(), 0, 1)
        end
        surface.SetDrawColor(Color(68,68,68))
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(Color(69,147,211))
        surface.DrawRect(0,0,w * percentage, h)
        draw.SimpleText("Submit", "DynamicNames.Title", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function submitButton:DoClick()
        surface.PlaySound(submitNoise)
        isAnimating = true
        DynamicNames.PlayerMenu:Remove()
    end
    
    playerHeader = DynamicNames.PlayerMenu:Add("DPanel")
    playerHeader:SetBackgroundColor(Color(82,82,82))
    playerHeader:Dock(TOP)

    playerTitle = playerHeader:Add("DLabel")
    playerTitle:SetFont("DynamicNames.Title")
    playerTitle:SetText("Please Fill Out the Following Fields")
    playerTitle:SizeToContents()
    playerTitle:SetPos( playerHeader:GetWide() * 3.15, playerHeader:GetTall() * .5 )

    playerExit = playerHeader:Add("DButton")
    playerExit:SetText("")
    playerExit:Dock(RIGHT)
    local closeColor = color_white
    playerExit.Paint = function(self,w,h)
        if self:IsHovered() then
            closeColor = Color(189,61,61)
        else
            closeColor = color_white
        end
        draw.SimpleText("X", "DynamicNames.CloseButton", w * .5, h * .5, closeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function playerExit:DoClick()
        DynamicNames.PlayerMenu:Remove()
    end

    DynamicNames.PlayerMenu.OnSizeChanged = function(self,w,h)
        if isAnimating then
            self:Center()
        end
        playerHeader:SetTall( frameH * .1)
        submitButton:SetTall( frameH * .1 )

    end


end

concommand.Add( "dynamicnames", DynamicNames.OpenMenu)






--[[function openDerma()
    
    local scrw,scrh = ScrW(), ScrH()
    local boxw,boxh = ScrW() * .33 , ScrH() * .33
    
        local Frame = vgui.Create( "DFrame" )
        Frame:SetTitle( "Test panel" )
        Frame:SetSize( boxw ,boxh )
        Frame:Center()			
        Frame:SetDraggable(false)
        Frame:SetDraggable(false)
        Frame:ShowCloseButton( DynamicNames.AllowClose )
        Frame:MakePopup()
        Frame.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
        end
            
    
    
        local lnameEntry = vgui.Create( "DTextEntry", Frame ) -- create the form as a child of frame
            lnameEntry:SetPos( boxw / 2.38, boxh / 2 )
            lnameEntry:SetSize( 135, 25 )
    
        local fnameEntry = vgui.Create( "DTextEntry", Frame ) -- create the form as a child of frame
            fnameEntry:SetPos( boxw / 2.38, boxh / 2.80 )
            fnameEntry:SetSize( 135, 25 )
    
    
    
        local Button = vgui.Create("DButton", Frame)
            Button:SetText( "SUBMIT" )
            Button:SetTextColor( Color(255,255,255) )
            Button:SetPos( boxw / 2.38 , boxh / 1.25)
            Button:SetSize( 100, 30 )
            Button.Paint = function( self, w, h )
                draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 180, 0, 250 ) ) -- Draw a blue button
            end
            Button.DoClick = function()
                Frame:Close()
                chat.AddText( "Your name is now " .. fnameEntry:GetValue() .. " " .. lnameEntry:GetValue() .. ".") 
    
            end
    
    
    
    
    
    end
concommand.Add("openDerma", openDerma)]]