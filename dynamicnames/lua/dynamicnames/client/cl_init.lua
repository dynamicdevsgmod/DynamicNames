if !DynamicNames then
    MsgC(Color(255,255,255),"[", Color(0,217,255), "Dynamic Names", Color(255,255,255),"] ", Color(255,0,0), "Some files didn't load properly, Dynamic Names will not work! Try restarting your server. \n")
    return
end

local titleSize = ScreenScale(12)
local closeSize = ScreenScale(16)
local entrySize = ScreenScale(5.75)
local dlblSize = ScreenScale(9.142)
local npcSize = ScreenScale(8)

local blueCol = Color(69,147,211)

local function DynamicNames_SetFonts()
    surface.CreateFont( "DynamicNames.Title", {
        font = "Roboto",
        size = titleSize,
        -- 30
        weight = 500,
        antialias = true,
    })

    surface.CreateFont( "DynamicNames.CloseButton", {
        font = "Tahoma",
        size = closeSize,
        -- 45
        weight = 500,
        antialias = true,
    })

    surface.CreateFont( "DynamicNames.Entries", {
        font = "Roboto",
        size = entrySize,
        -- 14
        weight = 500,
        antialias = true,
    })

    surface.CreateFont( "DynamicNames.DataLabels", {
        font = "Roboto",
        size = dlblSize,
        weight = 500,
        antialias = true,
    })

    surface.CreateFont( "DynamicNames.NPCText", {
        font = "Roboto",
        size = npcSize,
        weight = 500,
        antialias = true,
    })

    surface.CreateFont("DynamicNames.3D2D", {
        font = "Verdana",
        size = 40,
    })
end

hook.Add("InitPostEntity", "DynamicNames_plyInit", function()
    net.Start("dynNms_plyInit")
    net.SendToServer()
    DynamicNames_SetFonts()
end )

hook.Add("OnScreenSizeChanged", "DynamicNames_ScaleFonts", function(oldW,oldH)
    titleSize = ScreenScale(12)
    closeSize = ScreenScale(16)
    entrySize = ScreenScale(5.75)
    dlblSize = ScreenScale(9.142)
    npcSize = ScreenScale(8)
    DynamicNames_SetFonts() 
end )

local submitNoise = "dynamicnames/tadah_pingpingping.mp3"
local errorNoise = "dynamicnames/error_bump.mp3"

local function DynamicNames_OpenClMenu()
    if IsValid(DynamicNames.PlayerMenu) then
        DynamicNames.PlayerMenu:Remove()
    end
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH, animTime, animDelay, animEase = scrw * .4, scrh * .5,.6, 0, .5
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
        if DynamicNames.CPreferences["EnableMenuBlur"] then
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
    end
    function lastNameField:AllowInput( self, stringValue )
        return string.len(lastNameField:GetValue()) >= DynamicNames.lastNameLength
    end


    local idNumField = DynamicNames.PlayerMenu:Add("DTextEntry")
    local strAllowedNumericCharacters = "1234567890.-" -- I had to make my own "SetNumeric" because I could not get the default one to function alongside the length check.
    idNumField:SetVisible(false)
    idNumField:SetFont("DynamicNames.Entries")
    idNumField:SetUpdateOnType(true)
    function idNumField:OnLoseFocus()
        local idNumber = idNumField:GetValue()
    end
    function idNumField:AllowInput(val)
        if ( !string.find( strAllowedNumericCharacters, val, 1, true ) ) or string.len(self:GetValue()) >= DynamicNames.IDNumberLength then
            return true
        end
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
        net.Start("dynNms_whenTableToClient")
        net.SendToServer()
    end
    net.Receive("dynNms_tableToClient", function()
        local dynNms_data = net.ReadTable()
        local firstNameInput = firstNameField:GetValue()
        local lastNameInput = lastNameField:GetValue()
        local idNumInput = idNumField:GetValue()

        if DynamicNames.CPreferences["BannedNames"][ string.lower( firstNameInput ) ] then
            surface.PlaySound(errorNoise)
            submitText = "Banned name!"
            firstNameField:SetTextColor(Color(255,0,0))
            timer.Create("isFNameBanned", 2.5, 0, function()
            submitText = "Submit"
            firstNameField:SetTextColor(Color(0,0,0))
            end )
            return
        elseif DynamicNames.CPreferences["BannedNames"][ string.lower( lastNameInput ) ] then
            surface.PlaySound(errorNoise)
            submitText = "Banned name!"
            lastNameField:SetTextColor(Color(255,0,0))
            timer.Create("isLNameBanned", 2.5, 0, function()
                submitText = "Submit"
                lastNameField:SetTextColor(Color(0,0,0))
            end )
            return
            
        else
            for _, tDynNms in ipairs(dynNms_data) do
                if firstNameInput == tDynNms.firstName and lastNameInput == tDynNms.lastName then
                    surface.PlaySound(errorNoise)
                    submitText = "Name taken!"
                    firstNameField:SetTextColor(Color(255,0,0))
                    lastNameField:SetTextColor(Color(255,0,0))
                    timer.Create("isNameTaken", 2.5, 0, function()
                        submitText = "Submit"
                        firstNameField:SetTextColor(Color(0,0,0))
                        lastNameField:SetTextColor(Color(0,0,0))
                    end )
                    return
                elseif DynamicNames.CPreferences["EnableIDNumber"] and idNumInput == tDynNms.idNum then
                    surface.PlaySound(errorNoise)
                    submitText = "ID taken!"
                    idNumField:SetTextColor(Color(255,0,0))
                    timer.Create("isIDTaken", 2.5, 0, function()
                        submitText = "Submit"
                        idNumField:SetTextColor(Color(0,0,0))
                    end )
                    return
                end
            end

            if string.len(lastNameField:GetValue()) > 0 and string.len(firstNameField:GetValue()) > 0 then
                if DynamicNames.CPreferences["EnableIDNumber"] and string.len(idNumField:GetValue()) > 0 then
                    surface.PlaySound(submitNoise)
                    DynamicNames.PlayerMenu:Remove()
                    net.Start("dynNms_nameToSet")
                        net.WriteString(firstNameField:GetValue())
                        net.WriteString(lastNameField:GetValue())
                        net.WriteString(idNumField:GetValue())
                    net.SendToServer()
                    if timer.Exists("isFNameBanned") then
                        timer.Stop("isFNameBanned")
                    end
                    if timer.Exists("isLNameBanned") then
                        timer.Stop("isLNameBanned")
                    end
                    if timer.Exists("isNameTaken") then
                        timer.Stop("isNameTaken")
                    end
                    if timer.Exists("isIDTaken") then
                        timer.Stop("isIDTaken")
                    end
                elseif !DynamicNames.CPreferences["EnableIDNumber"] then
                    surface.PlaySound(submitNoise)
                    DynamicNames.PlayerMenu:Remove()
                    net.Start("dynNms_nameToSet")
                        net.WriteString(firstNameField:GetValue())
                        net.WriteString(lastNameField:GetValue())
                    net.SendToServer()
                    if timer.Exists("isFNameBanned") then
                        timer.Stop("isFNameBanned")
                    end
                    if timer.Exists("isLNameBanned") then
                        timer.Stop("isLNameBanned")
                    end
                    if timer.Exists("isNameTaken") then
                        timer.Stop("isNameTaken")
                    end
                else
                    surface.PlaySound(errorNoise)
                end
            else
                surface.PlaySound(errorNoise)
            end
        end
    end )

    local playerHeader = DynamicNames.PlayerMenu:Add("DPanel")
    playerHeader:Dock(TOP)
    playerHeader.Paint = function(self,w,h)
        surface.SetDrawColor(DynamicNames.Themes.Default["Header"])
        surface.DrawRect(0,0,w,h)
    end

    local playerTitle = playerHeader:Add("DLabel")
    playerTitle:SetFont("DynamicNames.Title")
    playerTitle:SetText("Please Fill Out the Following Fields")
    playerTitle:SizeToContents()

    if DynamicNames.AllowClose then
        local playerExit = playerHeader:Add("DButton")
        playerExit:SetText("")
        playerExit:Dock(RIGHT)
        local closeColor = color_white
        playerExit.Paint = function(self,w,h)
            if self:IsHovered() then
                closeColor = DynamicNames.Red
            else
                closeColor = color_white
            end
            draw.SimpleText("X", "DynamicNames.CloseButton", w * .5, h * .5, closeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function playerExit:DoClick()
            DynamicNames.PlayerMenu:Remove()
            if timer.Exists("isFNameBanned") then
                timer.Stop("isFNameBanned")
            end
            if timer.Exists("isLNameBanned") then
                timer.Stop("isLNameBanned")
            end
            if timer.Exists("isNameTaken") then
                timer.Stop("isNameTaken")
            end
            if timer.Exists("isIDTaken") then
                timer.Stop("isIDTaken")
            end
        end
    end

    DynamicNames.PlayerMenu.OnSizeChanged = function(self,w,h)
        if isAnimating then
            self:Center()
        end
        playerHeader:SetTall( frameH * .1)
        playerTitle:Center()

        firstNameField:SetSize( submitButton:GetWide() , 30 )
        lastNameField:SetSize( submitButton:GetWide() , 30 )
        if DynamicNames.CPreferences["EnableIDNumber"] then
            firstNameField:SetPos(DynamicNames.PlayerMenu:GetWide() * .25, DynamicNames.PlayerMenu:GetTall() * .3)
            lastNameField:SetPos( DynamicNames.PlayerMenu:GetWide() * .25, DynamicNames.PlayerMenu:GetTall() * .4)

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

net.Receive("dynNms_sendDataToClient",  function()
    net.Start("dynNms_RetrievePrefs")
    net.SendToServer()
end )

net.Receive("dynNms_NPCMenuPrompt", function() 
    local p = net.ReadFloat()
    local qry = vgui.Create("EditablePanel")
    qry:SetSize(ScrW() * .25,ScrH() * .15)
    qry:Center()
    qry:MakePopup()
    qry.Paint = function(self,w,h)
        Derma_DrawBackgroundBlur(self)
        draw.RoundedBox(6,0,0,w,h,DynamicNames.Themes.Default["Frame"])
    end
    qry.lbl = qry:Add("DLabel")
    qry.lbl:SetText("You must pay "..DarkRP.formatMoney(p).." to change your name")
    qry.lbl:SetFont("DynamicNames.NPCText")
    qry.lbl:SizeToContents()
    qry.lbl:SetPos(qry:GetWide() * .1, qry:GetTall() * .1)
    qry.lbl:CenterHorizontal()

    local speed = .05
    qry.acpt = qry:Add("DButton")
    qry.acpt:SetText("Accept")
    qry.acpt:SetSize(qry:GetWide() * .3, qry:GetTall() * .2)
    qry.acpt:SetPos(qry:GetWide() * .17, qry:GetTall() * .6)
    qry.acpt:SetFont("DynamicNames.Entries")
    local prg1 = 0
    qry.acpt.Paint = function(self,w,h)
        if self:IsHovered() then
            prg1 = Lerp(speed, prg1, w * 1.1)
            self:SetTextColor(color_white)
        else
            prg1 = Lerp(speed, prg1,0)
            self:SetTextColor(color_black)
        end
        surface.SetDrawColor(color_white)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(Color(87,172,252))
        surface.DrawRect(0,0,prg1,h )
    end
    function qry.acpt:DoClick(self)
        net.Start("dynNms_StartMenu")
        net.SendToServer()
        qry:Remove()
    end

    qry.cncl = qry:Add("DButton")
    qry.cncl:SetText("Cancel")
    qry.cncl:SetSize(qry:GetWide() * .3, qry:GetTall() * .2)
    qry.cncl:SetPos(qry:GetWide() * .53, qry:GetTall() * .6)
    qry.cncl:SetFont("DynamicNames.Entries")
    local prg2 = 0
    qry.cncl.Paint = function(self,w,h)
        if self:IsHovered() then
            prg2 = Lerp(speed, prg2, w * 1.1)
            self:SetTextColor(color_white)
        else
            prg2 = Lerp(speed, prg2,0)
            self:SetTextColor(color_black)
        end
        surface.SetDrawColor(color_white)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(blueCol)
        surface.DrawRect(0,0,prg2,h )
    end
    function qry.cncl:DoClick(self)
        qry:Remove()
    end
end )

net.Receive("dynNms_NPCCantAfford", function()
    surface.PlaySound(errorNoise)
    notification.AddLegacy("You can't afford this name change!", 1, 3)
end )

net.Receive("dynNms_menuPrompted", function() 
    net.Start("dynNms_RetrievePrefs")
    net.SendToServer()
end )

net.Receive("dynNms_SendPrefs", function()
    DynamicNames.CPreferences = net.ReadTable()
    DynamicNames_OpenClMenu()
end )