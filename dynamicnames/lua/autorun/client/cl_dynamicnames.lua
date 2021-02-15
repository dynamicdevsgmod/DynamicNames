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

surface.CreateFont( "DynamicNames.Entries", {
    font = "Roboto",
    size = 14,
    weight = 500,
    antialias = true,
})

hook.Add( "InitPostEntity", "playerHasSpawned", function()
	net.Start( "dynNms_plyInit" )
	net.SendToServer()
end )

local submitNoise = "dynamicnames/tadah_pingpingping.mp3"
local errorNoise = "dynamicnames/error_bump.mp3"

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
    DynamicNames.PlayerMenu:ShowCloseButton( false )
    DynamicNames.PlayerMenu:DockPadding(0,0,0,0)
    local isAnimating = true
    DynamicNames.PlayerMenu:SizeTo( frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false
    end )
    DynamicNames.PlayerMenu.Paint = function(self,w,h)
        if DynamicNames.EnableBlur then
            Derma_DrawBackgroundBlur(self, self.startTime)
        end
        surface.SetDrawColor(DynamicNames.Themes.Default["Frame"])
        surface.DrawRect(0,0,w,h)
    end

    local firstNameField = DynamicNames.PlayerMenu:Add("DTextEntry")
    firstNameField:SetPlaceholderText("First Name")
    firstNameField:SetFont("DynamicNames.Entries")
    function firstNameField:OnLoseFocus()
        local firstName = firstNameField:GetValue()
    end
    function firstNameField:AllowInput( self, stringValue )
        return string.len(firstNameField:GetValue()) >= DynamicNames.firstNameLength
    end

    local lastNameField = DynamicNames.PlayerMenu:Add("DTextEntry")
    lastNameField:SetPlaceholderText("Last Name")
    lastNameField:SetFont("DynamicNames.Entries")
    lastNameField:SetEnterAllowed( false )
    function lastNameField:OnLoseFocus()
        local lastName = lastNameField:GetValue()
    --[[        if DynamicNames.BannedNames[ string.lower( lastNameField:GetValue() ) ] then
            print("Banned name Detected")
        end]]
    end
    function lastNameField:AllowInput( self, stringValue )
        return string.len(lastNameField:GetValue()) >= DynamicNames.lastNameLength
    end


    local idNumField = DynamicNames.PlayerMenu:Add("DTextEntry")
    idNumField:SetVisible(false)
    idNumField:SetFont("DynamicNames.Entries")
    function idNumField:OnLoseFocus()
        local idNumber = idNumField:GetValue()
    end
    function idNumField:AllowInput( self, stringValue )
        return string.len(idNumField:GetValue()) >= DynamicNames.IDNumberLength
    end


    local submitButton = DynamicNames.PlayerMenu:Add("DButton")
    submitButton:Dock(BOTTOM)
    submitButton:DockMargin( frameW * .25, 0, frameW * .25, frameH * .05)
    submitButton:SetFont("DynamicNames.Title")
    submitButton:SetText("")
    local speed  = 5
    local percentage = 0
    local submitText = "Submit"
    submitButton.Paint = function(self,w,h)
        if self:IsHovered() then
            percentage = math.Clamp(percentage + speed * FrameTime(), 0, 1)
        else
            percentage = math.Clamp(percentage - speed * FrameTime(), 0, 1)
        end
        surface.SetDrawColor(DynamicNames.Themes.Default["SubmitButton"])
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(DynamicNames.Themes.Default["SubmitHighlight"])
        surface.DrawRect(0,0,w * percentage, h)
        draw.SimpleText(submitText, "DynamicNames.Title", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function submitButton:DoClick()
        if DynamicNames.BannedNames[ string.lower( firstNameField:GetValue() ) ] then
            surface.PlaySound(errorNoise)
            submitText = "Banned name!"
            firstNameField:SetTextColor(Color(255,0,0))
            timer.Simple(2.5, function()
            submitText = "Submit"
            firstNameField:SetTextColor(Color(0,0,0))
            end )

            return
        elseif DynamicNames.BannedNames[ string.lower( lastNameField:GetValue() ) ] then
            surface.PlaySound(errorNoise)
            submitText = "Banned name!"
            lastNameField:SetTextColor(Color(255,0,0))
            timer.Simple(2.5, function()
                submitText = "Submit"
                lastNameField:SetTextColor(Color(0,0,0))
            end )
        else

            if string.len(lastNameField:GetValue()) > 0 and string.len(firstNameField:GetValue()) > 0 then
                if DynamicNames.EnableIDNumber and string.len(idNumField:GetValue()) > 0 then
                    surface.PlaySound(submitNoise)
                    DynamicNames.PlayerMenu:Remove()
                    net.Start("dynNms_nameToSet")
                        net.WriteString(firstNameField:GetValue())
                        net.WriteString(lastNameField:GetValue())
                        net.WriteString(idNumField:GetValue())
                    net.SendToServer()
                elseif !DynamicNames.EnableIDNumber then
                    surface.PlaySound(submitNoise)
                    DynamicNames.PlayerMenu:Remove()
                    net.Start("dynNms_nameToSet")
                        net.WriteString(firstNameField:GetValue())
                        net.WriteString(lastNameField:GetValue())

                    net.SendToServer()
                else
                    surface.PlaySound(errorNoise)
                end
            else
                surface.PlaySound(errorNoise)
            end
        end
    end

    local playerHeader = DynamicNames.PlayerMenu:Add("DPanel")
    playerHeader:SetBackgroundColor(DynamicNames.Themes.Default["Header"])
    playerHeader:Dock(TOP)

    local playerTitle = playerHeader:Add("DLabel")
    playerTitle:SetFont("DynamicNames.Title")
    playerTitle:SetText("Please Fill Out the Following Fields")
    playerTitle:SizeToContents()
    playerTitle:SetPos( playerHeader:GetWide() * 3.15, playerHeader:GetTall() * .5 )

    if DynamicNames.AllowClose then
        local playerExit = playerHeader:Add("DButton")
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
    end

    DynamicNames.PlayerMenu.OnSizeChanged = function(self,w,h)
        if isAnimating then
            self:Center()
        end
        playerHeader:SetTall( frameH * .1)

        firstNameField:SetSize( submitButton:GetWide() , 30 )
        lastNameField:SetSize( submitButton:GetWide() , 30 )
        if DynamicNames.EnableIDNumber then
            firstNameField:SetPos(DynamicNames.PlayerMenu:GetWide() * .25, DynamicNames.PlayerMenu:GetTall() * .3)
            lastNameField:SetPos( DynamicNames.PlayerMenu:GetWide() * .25, DynamicNames.PlayerMenu:GetTall() * .4)

            idNumField:SetNumeric(true)
            idNumField:SetSize( submitButton:GetWide() , 30)
            idNumField:SetPos(DynamicNames.PlayerMenu:GetWide() * .25, DynamicNames.PlayerMenu:GetTall() * .5)
            idNumField:SetPlaceholderText("Numeric Serial Number")
            idNumField:SetVisible(true)

        else
            firstNameField:SetPos( DynamicNames.PlayerMenu:GetWide() * .25, DynamicNames.PlayerMenu:GetTall() * .4)
            lastNameField:SetPos( DynamicNames.PlayerMenu:GetWide() * .25, DynamicNames.PlayerMenu:GetTall() * .5)
        end
        
        submitButton:SetTall( frameH * .1 )

    end

end

net.Receive("dynNms_sendDataToClient", function()
    local dynNms_toOpenMenu = net.ReadBool()
    if dynNms_toOpenMenu then
        DynamicNames.OpenMenu()
    end
end )

concommand.Add( "dynamicnames", DynamicNames.OpenMenu)
