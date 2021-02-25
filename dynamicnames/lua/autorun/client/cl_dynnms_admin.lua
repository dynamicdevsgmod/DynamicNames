include("autorun/sh_dynamicnames.lua")




function DynamicNames.OpenAdminMenu()
    if IsValid(DynamicNames.AdminMenu) then
        DynamicNames.AdminMenu:Remove()
    elseif (IsValid(DynamicNames.PlayerMenu)) then
        DynamicNames.PlayerMenu:Remove()
    end
    
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH, animTime, animDelay, animEase = scrw * .5, scrh * .6, 1.6, 0, .1
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

    local adminNavbar = {}
    adminNavbar.Bar = DynamicNames.AdminMenu:Add("DPanel")
    adminNavbar.Bar:Dock(TOP)

    adminNavbar.Buttons = {}
    adminNavbar.Tabs = {}

    
    local function SetActive(id)
        local btn = adminNavbar.Buttons[id]
        if (!IsValid(btn)) then return end

        local activeBtn = adminNavbar.Buttons[adminNavbar.active]
        if (IsValid(activeBtn)) then
            activeBtn:SetTextColor(DynamicNames.Themes.AdminMenu["Navbar Buttons Color"])
            
            local activePnl = adminNavbar.Tabs[adminNavbar.active]
            if (IsValid(activePnl)) then
                activePnl:SetVisible(false)
            end
        end

        adminNavbar.active = id

        btn:SetTextColor(DynamicNames.Themes.AdminMenu["Navbar Tabs Accent"])
        local panel = adminNavbar.Tabs[id]
        panel:SetVisible(true)
    end

    local function addNavTab(name, panel)
        local i = table.Count(adminNavbar.Buttons) + 1

        adminNavbar.Buttons[i] = adminNavbar.Bar:Add("DButton")
        local btn = adminNavbar.Buttons[i]
        btn:Dock(LEFT)
        btn.id = i
        btn:DockMargin(0, adminNavbar.Bar:GetTall() * .05,0,0)
        btn:SetText(name)
        btn:SetFont("DynamicNames.Title")
        btn.Paint = function(pnl, w, h)
            if (adminNavbar.active == pnl.id) then
                surface.SetDrawColor(DynamicNames.Themes.AdminMenu["Navbar Tabs Accent"])
            else 
                surface.SetDrawColor(Color(0,0,0,0))
            end
            surface.DrawRect(0,h * .96,w,h * .1) 
        end
        --btn:SizeToContentsX( (adminNavbar.Bar:GetWide() * 2.33  ) )
        btn:SetWide((scrw * .51) / 3)
        --print(adminNavbar.Bar:GetWide())
        btn:SetTextColor(DynamicNames.Themes.AdminMenu["Navbar Buttons Color"])
        btn.DoClick = function(pnl)
            SetActive(pnl.id)
        end

        adminNavbar.Tabs[i] = DynamicNames.AdminMenu:Add(panel or "DPanel")
        panel = adminNavbar.Tabs[i]
        panel:Dock(FILL)
        panel:SetBackgroundColor(DynamicNames.Themes.Default["Frame"])
        panel:SetVisible(false)
    end

    -- Add navigation tabs --
    addNavTab("Players", "DPanel")
    local lbpnlDockMargin = adminNavbar.Tabs[1]:GetTall() / 0.25
    local labelPanel = adminNavbar.Tabs[1]:Add("DPanel")
    labelPanel:Dock(TOP)
    labelPanel:SetTall( adminNavbar.Tabs[1]:GetTall() * 2.3 )
    labelPanel:DockMargin(0,lbpnlDockMargin,0,0)
    labelPanel.Paint = function(self,w,h)
        surface.SetDrawColor(color_black)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(Color(255,255,255))
        surface.DrawRect(1,0,w * .3,h)
        draw.SimpleText("STEAMID", "DynamicNames.Title", w * .1, h*.5, Color(54,54,54), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER )

        surface.DrawRect(w * .303, 0, w * .25,h)
        draw.SimpleText("First Name", "DynamicNames.Title", w * .37, h*.5, Color(54,54,54), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER )
        
        surface.DrawRect(w * .554, 0, w * .2,h)
        draw.SimpleText("Last Name", "DynamicNames.Title", w * .59, h*.5, Color(54,54,54), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER )

        surface.DrawRect(w * .755, 0, w * .245,h)
        draw.SimpleText("Extras", "DynamicNames.Title", w * .84, h*.5, Color(54,54,54), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER )
    
    end

    local playerDataList = adminNavbar.Tabs[1]:Add("DScrollPanel")
    playerDataList:Dock(TOP)
    playerDataList:SetTall( ScrH() * .283)

    local playerDataSbar = playerDataList:GetVBar()
    playerDataSbar:SetHideButtons(true)

    playerDataSbar.Paint =  nil
    playerDataSbar:SetWide(7)
    playerDataSbar.btnGrip.Paint = function(self,w,h)
        draw.RoundedBox(12,0,0,w,h, Color(41, 128, 185))
    end

    net.Start("dynNms_whentableToClient")
        net.WriteBool(true)
    net.SendToServer()
    net.Receive("dynNms_tableToClient", function()
        local dynNms_data = net.ReadTable()

        local firstNameXPos
        local lastNameXPos

        for _, tDynNms in ipairs(dynNms_data) do
            local playerDataPanel = playerDataList:Add("DPanel")
            playerDataPanel:Dock(TOP)
            playerDataPanel:DockMargin(0, 10, 0, 0)
            playerDataPanel:SetTall( 32 )
            playerDataPanel.Paint = function(self,w,h)
                draw.RoundedBoxEx(8,0,0,w,h,Color(149, 165, 166), false, true, false, true)

                if DynamicNames.EnableIDNumber then
                    firstNameXPos = w * .43
                    lastNameXPos = w * .65

                    draw.SimpleText(tDynNms.idNum, "DynamicNames.DataLabels", w * .84 , h*.5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                else
                    firstNameXPos = w * .45
                    lastNameXPos = w * .7
                end

                draw.SimpleText(tDynNms.steamid, "DynamicNames.DataLabels", w * .05, h*.5, Color(255,255,255), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                draw.SimpleText(tDynNms.firstName, "DynamicNames.DataLabels",firstNameXPos, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                draw.SimpleText(tDynNms.lastName, "DynamicNames.DataLabels", lastNameXPos, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            local playerData_Avatar = playerDataPanel:Add("AvatarImage")
            playerData_Avatar:SetSize( 32, 32 )
            playerData_Avatar:SetPos( 0, 0 )
            --playerData_Avatar:SetPlayer(player.GetBySteamID(tDynNms.steamid), 32) USE THIS
            playerData_Avatar:SetSteamID("76561198353324150", 32)

            local playerData_PromptMenu = playerDataPanel:Add("DImageButton")
            playerData_PromptMenu:SetPos( ScrW() * .48, playerDataPanel:GetTall() * .3)
            playerData_PromptMenu:SetImage("icon16/application_form.png")
            playerData_PromptMenu:SizeToContents()
            playerData_PromptMenu:SetTooltip("Bring up the name menu for this player")
            playerData_PromptMenu.DoClick = function()
                net.Start("MenuPrompt_Request")
                    net.WriteEntity(player.GetBySteamID(tDynNms.steamid))
                net.SendToServer()
            end
        end
    end )
    

    --
    addNavTab("Settings", "DPanel")

    --
    addNavTab("Credits", "DPanel")
    --


    -- Set default tab --
    for i, btn in ipairs(adminNavbar.Buttons) do
        if (btn:GetText() == "Players") then
            SetActive(btn.id)

            break
        end
    end
    --

    adminNavbar.Bar.Paint = function(self,w,h)
        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["Navbar Background"])
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["Header/Navbar Divider Line"])
        surface.DrawRect(0,0,w, h * .05)
    end

    DynamicNames.AdminMenu.OnSizeChanged = function(self,w,h)
        if isAnimating then
            self:Center()
        end
        adminHeader:SetTall( frameH * .1)
        adminExit:Dock(RIGHT)
        adminTitle:Center()

        adminNavbar.Bar:SetTall(DynamicNames.AdminMenu:GetTall() * .1)
    end

end

concommand.Add( "dynamicnames_admin", DynamicNames.OpenAdminMenu)

