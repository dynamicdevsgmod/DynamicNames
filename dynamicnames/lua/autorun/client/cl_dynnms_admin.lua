include("autorun/sh_dynamicnames.lua")




function DynamicNames.OpenAdminMenu()
    if IsValid(DynamicNames.AdminMenu) then
        DynamicNames.AdminMenu:Remove()
    end
    
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH, animTime, animDelay, animEase = scrw * .4, scrh * .5, 1.8, 0, .1
    DynamicNames.AdminMenu = vgui.Create("DFrame")
    DynamicNames.AdminMenu:SetSize(0, 0)
    DynamicNames.AdminMenu:Center()
    DynamicNames.AdminMenu:MakePopup()
    DynamicNames.AdminMenu:SetTitle("")
    DynamicNames.AdminMenu:ShowCloseButton( true )
    DynamicNames.AdminMenu:DockPadding(0,0,0,0)
    local isAnimating = true
    DynamicNames.AdminMenu:SizeTo( frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false
    end )
    DynamicNames.AdminMenu.Paint = function(self,w,h)
        if DynamicNames.EnableBlur then
            Derma_DrawBackgroundBlur(self, self.startTime)
        end
        surface.SetDrawColor(DynamicNames.Themes.Default["Frame"])
        surface.DrawRect(0,0,w,h)
    end

    local adminHeader = DynamicNames.AdminMenu:Add("DPanel")
    adminHeader:SetBackgroundColor(DynamicNames.Themes.Default["Header"])
    adminHeader:Dock(TOP)

    local adminTitle = adminHeader:Add("DLabel")
    adminTitle:SetFont("DynamicNames.Title")
    adminTitle:SetText("Administration Panel")
    adminTitle:SizeToContents()
    adminTitle:SetPos( adminHeader:GetWide() * 4, adminHeader:GetTall() * .5 )

    local adminExit = adminHeader:Add("DButton")
    adminExit:SetText("")
    local closeColor = color_white
    adminExit.Paint = function(self,w,h)
        if self:IsHovered() then
            closeColor = Color(189,61,61)
        else
            closeColor = color_white
        end
        draw.SimpleText("X", "DynamicNames.CloseButton", w * .5, h * .5, closeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function adminExit:DoClick()
        DynamicNames.AdminMenu:Remove()
    end

    local playerPanel = DynamicNames.AdminMenu:Add("DScrollPanel")
    local playerPanelSbar = playerPanel:GetVBar()
    playerPanelSbar:SetHideButtons(true)

    local playerSearchBar = DynamicNames.AdminMenu:Add("DTextEntry")
    playerSearchBar:SetPlaceholderText("Search by last name (Non functioning/NEEDS OPTIMIZATION)")
    playerSearchBar:SetFont("DynamicNames.Title")
    playerSearchBar:SetUpdateOnType( true )
            --[[local playerSearch = tab1:Add("DTextEntry")
        playerSearch:Dock(TOP)
        tab1AllPlayers:Clear()
        for _,ply in ipairs(player.GetAll()) do
            local playerPanel = tab1AllPlayers:Add("DPanel")
            playerPanel:Dock(TOP)
            playerPanel:SetTall(20)
            playerPanel:DockMargin(0,10,0,0)
            playerPanel.Paint = function(self,w,h)
                draw.RoundedBox(6,0,0,w,h,Color(0,0,0))
                draw.SimpleText(ply:Name(), "Default", playerPanel:GetWide() * .5, playerPanel:GetTall() * .5, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

        end
        for k, v in ipairs(player.GetAll())
        if (!string.find(search_string, v:Name()) then return end

        do shit()
        end


        function playerSearch:OnChange()
            if playerSearch:GetValue() == "" then
                tab1AllPlayers:Clear()
                for _,ply in ipairs(player.GetAll()) do
                    local playerPanel = tab1AllPlayers:Add("DPanel")
                    playerPanel:Dock(TOP)
                    playerPanel:SetTall(20)
                    playerPanel:DockMargin(0,10,0,0)
                    playerPanel.Paint = function(self,w,h)
                        draw.RoundedBox(6,0,0,w,h,Color(0,0,0))
                        draw.SimpleText(ply:Name(), "Default", playerPanel:GetWide() * .5, playerPanel:GetTall() * .5, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    end
    
                end
            else
                tab1AllPlayers:Clear()
                for _,ply in ipairs(player.GetAll()) do

                    local playerPanel = tab1AllPlayers:Add("DPanel")
                    playerPanel:Dock(TOP)
                    playerPanel:SetTall(20)
                    playerPanel:DockMargin(0,10,0,0)
                    playerPanel.Paint = function(self,w,h)
                        draw.RoundedBox(6,0,0,w,h,Color(0,0,0))
                        draw.SimpleText(ply:Name(), "Default", playerPanel:GetWide() * .5, playerPanel:GetTall() * .5, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    end

                    if (!string.find(playerSearch:GetValue(), ply:Name())) then playerPanel:Remove() end
                end
            end
        end]]
    net.Start("dynNms_whenTableToClient")
        net.WriteBool( true )
    net.SendToServer()
    net.Receive("dynNms_tableToClient", function()

        DynNmsStoredData = net.ReadTable()
        -- The following may be a little too performance heavy...
        playerPanel:Clear()
        for _,tDynNms in ipairs(DynNmsStoredData) do
            -- tDynNms.steamid, tDynNms.firstName, tDynNms.lastName, tDynNms.idNum

            --if (!string.find(tDynNms.lastName, playerSearchValue)) then return end

            local DPanel = playerPanel:Add("DPanel")
            DPanel:Dock(TOP)
            DPanel:DockMargin( 0, 0, 0, 5 )
            DPanel:SetText("Button on Scroll Panel")
            DPanel:SetTall( 50 )
            function DPanel.Paint(self,w,h)
                draw.RoundedBox(6,0,0,w,h,Color(255,255,255))
            end

            local steamIDLabel = DPanel:Add("DLabel")
            steamIDLabel:Dock(LEFT)
            steamIDLabel:SetTextColor(Color(0,0,0))
            steamIDLabel:SetFont("DynamicNames.Entries")
            steamIDLabel:SetText( tDynNms.steamid )
            steamIDLabel:SizeToContents()
            steamIDLabel:DockMargin( DPanel:GetWide() * .1,0,0,0)

            local lastNameLabel = DPanel:Add("DLabel")
            lastNameLabel:Dock(LEFT)
            lastNameLabel:SetTextColor(Color(0,0,0))
            lastNameLabel:SetFont("DynamicNames.Entries")
            lastNameLabel:SetText( tDynNms.lastName.."," )
            lastNameLabel:SizeToContents()
            lastNameLabel:DockMargin( DPanel:GetWide() * 1.5,0,0,0)

            local firstNameLabel = DPanel:Add("DLabel")
            firstNameLabel:Dock(LEFT)
            firstNameLabel:SetTextColor(Color(0,0,0))
            firstNameLabel:SetFont("DynamicNames.Entries")
            firstNameLabel:SetText( tDynNms.firstName )
            firstNameLabel:SizeToContents()
            firstNameLabel:DockMargin( DPanel:GetWide() * .1,0,0,0)

            if DynamicNames.EnableIDNumber then
                local idNumLabel = DPanel:Add("DLabel")
                idNumLabel:SetPos( DPanel:GetWide() * 7.2, DPanel:GetTall() * .36)
                idNumLabel:SetTextColor(Color(0,0,0))
                idNumLabel:SetFont("DynamicNames.Entries")
                idNumLabel:SetText( tDynNms.idNum )
                idNumLabel:SizeToContents()
                idNumLabel:DockMargin( DPanel:GetWide() * .5,0,0,0)
            end
            
        end

        function playerSearchBar:OnChange()
            playerPanel:Clear()
            for _, tDynNyms in ipairs(DynNmsStoredData) do
                if playerSearchBar:GetValue() == "" then
                    local DPanel = playerPanel:Add("DPanel")
                    DPanel:Dock(TOP)
                    DPanel:DockMargin( 0, 0, 0, 5 )
                    DPanel:SetText("Button on Scroll Panel")
                    DPanel:SetTall( 50 )
                    function DPanel.Paint(self,w,h)
                        draw.RoundedBox(6,0,0,w,h,Color(255,255,255))
                    end
        
                    local steamIDLabel = DPanel:Add("DLabel")
                    steamIDLabel:Dock(LEFT)
                    steamIDLabel:SetTextColor(Color(0,0,0))
                    steamIDLabel:SetFont("DynamicNames.Entries")
                    steamIDLabel:SetText( tDynNms.steamid )
                    steamIDLabel:SizeToContents()
                    steamIDLabel:DockMargin( DPanel:GetWide() * .1,0,0,0)
        
                    local lastNameLabel = DPanel:Add("DLabel")
                    lastNameLabel:Dock(LEFT)
                    lastNameLabel:SetTextColor(Color(0,0,0))
                    lastNameLabel:SetFont("DynamicNames.Entries")
                    lastNameLabel:SetText( tDynNms.lastName.."," )
                    lastNameLabel:SizeToContents()
                    lastNameLabel:DockMargin( DPanel:GetWide() * 1.5,0,0,0)
        
                    local firstNameLabel = DPanel:Add("DLabel")
                    firstNameLabel:Dock(LEFT)
                    firstNameLabel:SetTextColor(Color(0,0,0))
                    firstNameLabel:SetFont("DynamicNames.Entries")
                    firstNameLabel:SetText( tDynNms.firstName )
                    firstNameLabel:SizeToContents()
                    firstNameLabel:DockMargin( DPanel:GetWide() * .1,0,0,0)
        
                    if DynamicNames.EnableIDNumber then
                        local idNumLabel = DPanel:Add("DLabel")
                        idNumLabel:SetPos( DPanel:GetWide() * 7.2, DPanel:GetTall() * .36)
                        idNumLabel:SetTextColor(Color(0,0,0))
                        idNumLabel:SetFont("DynamicNames.Entries")
                        idNumLabel:SetText( tDynNms.idNum )
                        idNumLabel:SizeToContents()
                        idNumLabel:DockMargin( DPanel:GetWide() * .5,0,0,0)
                    end
                else
                    local DPanel = playerPanel:Add("DPanel")
                    DPanel:Dock(TOP)
                    DPanel:DockMargin( 0, 0, 0, 5 )
                    DPanel:SetText("Button on Scroll Panel")
                    DPanel:SetTall( 50 )
                    function DPanel.Paint(self,w,h)
                        draw.RoundedBox(6,0,0,w,h,Color(255,255,255))
                    end
        
                    local steamIDLabel = DPanel:Add("DLabel")
                    steamIDLabel:Dock(LEFT)
                    steamIDLabel:SetTextColor(Color(0,0,0))
                    steamIDLabel:SetFont("DynamicNames.Entries")
                    steamIDLabel:SetText( tDynNms.steamid )
                    steamIDLabel:SizeToContents()
                    steamIDLabel:DockMargin( DPanel:GetWide() * .1,0,0,0)
        
                    local lastNameLabel = DPanel:Add("DLabel")
                    lastNameLabel:Dock(LEFT)
                    lastNameLabel:SetTextColor(Color(0,0,0))
                    lastNameLabel:SetFont("DynamicNames.Entries")
                    lastNameLabel:SetText( tDynNms.lastName.."," )
                    lastNameLabel:SizeToContents()
                    lastNameLabel:DockMargin( DPanel:GetWide() * 1.5,0,0,0)
        
                    local firstNameLabel = DPanel:Add("DLabel")
                    firstNameLabel:Dock(LEFT)
                    firstNameLabel:SetTextColor(Color(0,0,0))
                    firstNameLabel:SetFont("DynamicNames.Entries")
                    firstNameLabel:SetText( tDynNms.firstName )
                    firstNameLabel:SizeToContents()
                    firstNameLabel:DockMargin( DPanel:GetWide() * .1,0,0,0)
        
                    if DynamicNames.EnableIDNumber then
                        local idNumLabel = DPanel:Add("DLabel")
                        idNumLabel:SetPos( DPanel:GetWide() * 7.2, DPanel:GetTall() * .36)
                        idNumLabel:SetTextColor(Color(0,0,0))
                        idNumLabel:SetFont("DynamicNames.Entries")
                        idNumLabel:SetText( tDynNms.idNum )
                        idNumLabel:SizeToContents()
                        idNumLabel:DockMargin( DPanel:GetWide() * .5,0,0,0)
                    end
                    if (!string.find(playerSearchBar:GetValue(), tDynNyms.lastName)) then playerPanel:Remove() end
                end
            end
        
        end





    end )
    
    

    local playerPanelButton = DynamicNames.AdminMenu:Add("DButton")
    playerPanelButton:SetFont("DynamicNames.CloseButton")
    playerPanelButton:SetText("")
    local speed  = 5
    local percentage = 0
    playerPanelButton.Paint = function(self,w,h)
        if self:IsHovered() then
            percentage = math.Clamp(percentage + speed * FrameTime(), 0, 1)
        else
            percentage = math.Clamp(percentage - speed * FrameTime(), 0, 1)
        end
        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["SettingsButton"])
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["SettingsButtonHighlight"])
        surface.DrawRect(0,h * .9,w * percentage, h * .1)
        draw.SimpleText("PLAYERS", "DynamicNames.Title", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local settingsPanelButton = DynamicNames.AdminMenu:Add("DButton")
    settingsPanelButton:SetFont("DynamicNames.CloseButton")
    settingsPanelButton:SetText("")
    local speed  = 5
    local percentage = 0
    settingsPanelButton.Paint = function(self,w,h)
        if self:IsHovered() then
            percentage = math.Clamp(percentage + speed * FrameTime(), 0, 1)
        else
            percentage = math.Clamp(percentage - speed * FrameTime(), 0, 1)
        end
        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["SettingsButton"])
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["SettingsButtonHighlight"])
        surface.DrawRect(0,h * .9,w * percentage, h * .1)
        draw.SimpleText("SETTINGS", "DynamicNames.Title", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end



    local steamIDFieldLabel = DynamicNames.AdminMenu:Add("DLabel")
    steamIDFieldLabel:SetFont("DynamicNames.CloseButton")
    steamIDFieldLabel:SetText("")
    steamIDFieldLabel:SetTextColor(Color(255,255,255))
    steamIDFieldLabel.Paint = function(self,w,h)
        surface.SetDrawColor(Color(151,154,155))
        surface.DrawRect(0,0,w,h)
        draw.SimpleText("SteamID", "DynamicNames.CloseButton", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local nameFieldLabel = DynamicNames.AdminMenu:Add("DLabel")
    nameFieldLabel:SetFont("DynamicNames.CloseButton")
    nameFieldLabel:SetText("")
    nameFieldLabel:SetTextColor(Color(255,255,255))
    nameFieldLabel.Paint = function(self,w,h)
        surface.SetDrawColor(Color(151,154,155))
        surface.DrawRect(0,0,w,h)
        draw.SimpleText("Name", "DynamicNames.CloseButton", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local idFieldLabel = DynamicNames.AdminMenu:Add("DLabel")
    idFieldLabel:SetFont("DynamicNames.CloseButton")
    idFieldLabel:SetText("")
    idFieldLabel:SetTextColor(Color(255,255,255))
    idFieldLabel.Paint = function(self,w,h)
        surface.SetDrawColor(Color(151,154,155))
        surface.DrawRect(0,0,w,h)
        draw.SimpleText("ID", "DynamicNames.CloseButton", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local functionsLabel = DynamicNames.AdminMenu:Add("DLabel")
    functionsLabel:SetFont("DynamicNames.CloseButton")
    functionsLabel:SetText("")
    functionsLabel:SetTextColor(Color(255,255,255))
    functionsLabel.Paint = function(self,w,h)
        surface.SetDrawColor(Color(151,154,155))
        surface.DrawRect(0,0,w,h)
        draw.SimpleText("Functions", "DynamicNames.CloseButton", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    DynamicNames.AdminMenu.OnSizeChanged = function(self,w,h)
        if isAnimating then
            self:Center()
        end
        adminHeader:SetTall( frameH * .1)
        adminExit:Dock(RIGHT)

        playerPanelButton:SetSize( adminHeader:GetWide() * .48, adminHeader:GetTall() )
        playerPanelButton:SetPos( adminHeader:GetWide() * .01, adminHeader:GetTall() )

        settingsPanelButton:SetSize( adminHeader:GetWide() * .49, adminHeader:GetTall() )
        settingsPanelButton:SetPos( adminHeader:GetWide() * .50, adminHeader:GetTall() )

        playerPanel:Dock(FILL)
        playerPanel:DockMargin( DynamicNames.AdminMenu:GetWide() * .005 ,adminHeader:GetTall() * 3,DynamicNames.AdminMenu:GetWide() * .005,0)

        playerSearchBar:SetPos(0, adminHeader:GetTall() * 2.43)
        playerSearchBar:SetSize( adminHeader:GetWide(), adminHeader:GetTall() * .8)

        steamIDFieldLabel:SetSize( playerPanel:GetWide() * .25, 40)
        steamIDFieldLabel:SetPos( 0, adminHeader:GetTall() * 3.26 )

        nameFieldLabel:SetSize( playerPanel:GetWide() * .25, 40)
        nameFieldLabel:SetPos( adminHeader:GetWide() * .25, adminHeader:GetTall() * 3.26 )

        idFieldLabel:SetSize( playerPanel:GetWide() * .25, 40)
        idFieldLabel:SetPos( adminHeader:GetWide() * .5, adminHeader:GetTall() * 3.26 )

        functionsLabel:SetSize( playerPanel:GetWide() * .25, 40)
        functionsLabel:SetPos( adminHeader:GetWide() * .75, adminHeader:GetTall() * 3.26 )
    end

end

concommand.Add( "dynamicnames_admin", DynamicNames.OpenAdminMenu)

