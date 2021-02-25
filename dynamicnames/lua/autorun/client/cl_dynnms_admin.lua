include("autorun/sh_dynamicnames.lua")




function DynamicNames.OpenAdminMenu()
    if IsValid(DynamicNames.AdminMenu) then
        DynamicNames.AdminMenu:Remove()
    elseif (IsValid(DynamicNames.PlayerMenu)) then
        DynamicNames.PlayerMenu:Remove()
    end
    
    local scrw, scrh = ScrW(), ScrH()
    local frameW, frameH, animTime, animDelay, animEase = scrw * .5, scrh * .6, 1.8, 0, .1
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
    adminNavbar.Bar.Paint = function(self,w,h)
        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["Navbar Background"])
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["Header/Navbar Divider Line"])
        surface.DrawRect(0,0,w, h * .05)
    end
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
        btn:SizeToContentsX(ScrW() * .128)
        btn:SetTextColor(DynamicNames.Themes.AdminMenu["Navbar Buttons Color"])
        btn.DoClick = function(pnl)
            SetActive(pnl.id)
        end

        adminNavbar.Tabs[i] = DynamicNames.AdminMenu:Add(panel or "DPanel")
        panel = adminNavbar.Tabs[i]
        panel:Dock(FILL)
        panel:SetVisible(false)
    end

    -- Add navigation tabs --
    addNavTab("Players", "DPanel")
    addNavTab("Settings", "DPanel")
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

