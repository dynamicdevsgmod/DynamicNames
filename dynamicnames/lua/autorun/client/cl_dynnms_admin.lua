include("autorun/sh_dynamicnames.lua")




function DynamicNames.OpenAdminMenu()
    if !DynamicNames.AdminGroups[LocalPlayer():GetUserGroup()] then return end
    if IsValid(adminFrame) then return end
    local scrw, scrh = ScrW(), ScrH()
    local adminFrame = vgui.Create("EditablePanel")
    adminFrame:SetSize(scrw * .45, scrh * .5)
    adminFrame:Center()
    adminFrame:MakePopup()
    adminFrame.Paint = function(self,w,h)
        Derma_DrawBackgroundBlur(self)
        surface.SetDrawColor(DynamicNames.Themes.Default["Frame"])
        surface.DrawRect(0,0,w,h)
    end

    local adminHeader = adminFrame:Add("DPanel")
    adminHeader:Dock(TOP)
    adminHeader:SetTall(adminFrame:GetTall() * .12)
    adminHeader.Paint = function(self,w,h)
        surface.SetDrawColor(DynamicNames.Themes.Default["Header"])
        surface.DrawRect(0,0,w,h)

        draw.SimpleText("Administration Panel", "DynamicNames.Title", self:GetWide() *.5, self:GetTall() * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local adminExit = adminHeader:Add("DButton")
    adminExit:SetText("")
    adminExit:Dock(RIGHT)
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
        adminFrame:Remove()
    end

    local adminNavbar = {}
    adminNavbar.Bar = adminFrame:Add("DPanel")
    adminNavbar.Bar:Dock(TOP)
    adminNavbar.Bar:SetTall(adminFrame:GetTall() * .1)
    adminNavbar.Bar.Paint = function(self,w,h)
        surface.SetDrawColor(DynamicNames.Themes.AdminMenu["Navbar Background"])
        surface.DrawRect(0,0,w,h)
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
        SetActive(1)

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
        btn:SetWide((scrw * .46) / 3)
        btn:SetTextColor(DynamicNames.Themes.AdminMenu["Navbar Buttons Color"])
        btn.DoClick = function(pnl)
            SetActive(pnl.id)
        end

        adminNavbar.Tabs[i] = adminFrame:Add(panel or "DPanel")
        panel = adminNavbar.Tabs[i]
        panel:Dock(FILL)
        panel:SetBackgroundColor(DynamicNames.Themes.Default["Frame"])
        panel:SetVisible(false)
    end

    -- PLAYER TAB --
    addNavTab("Players")
    local playerMenu = adminNavbar.Tabs[1]
    local plySearchBar = playerMenu:Add("DTextEntry")
    plySearchBar:Dock(TOP)
    plySearchBar:DockMargin(0,scrw * .02, 0,0)
    plySearchBar:SetTall(playerMenu:GetTall() * 2)
    plySearchBar:SetPlaceholderText("Search by last name")
    plySearchBar:SetFont("DynamicNames.Title")
    plySearchBar:SetUpdateOnType(true)

    local playerDataList = playerMenu:Add("DScrollPanel")
    playerDataList:Dock(FILL)
    playerDataList:DockMargin(0,scrw * .02, 0,0)
    playerDataList:SetTall(scrw * .1)
    local playerDataList_sbar = playerDataList:GetVBar()
    playerDataList_sbar:SetHideButtons(true)
    playerDataList_sbar:SetWide(7)
    function playerDataList_sbar:Paint(w,h) end
    function playerDataList_sbar.btnGrip:Paint(w,h)
        draw.RoundedBox(16,0,0,w,h,color_white)
    end

    net.Start("dynNms_whentableToClient")
    net.SendToServer()
    net.Receive("dynNms_tableToClient", function()
        local dynNms_data = net.ReadTable()

        local firstNameXPos
        local lastNameXPos

        local skipLblPnl = 1
        function tDynNms_GeneratePlyPanel(searchedFor)
            for _, tDynNms in ipairs(dynNms_data) do

                if searchedFor then
                    if !string.StartWith(string.lower(tDynNms.lastName), string.lower(plySearchBar:GetValue())) then
                        continue
                    end
                end
                
                if skipLblPnl == 1 or dontSkip then
                    local playerLblPnl = playerDataList:Add("DPanel")
                    playerLblPnl:Dock(TOP)
                    playerLblPnl:DockMargin(0, 0, 0, 20)
                    playerLblPnl:SetTall( 50 )
                    playerLblPnl.Paint = function(self,w,h)
                        draw.RoundedBox(8,0,0,w,h,Color(149, 165, 166))

                        draw.SimpleText("STEAMID", "DynamicNames.DataLabels", w * .08, h * .5, Color(255,255,255), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                        draw.SimpleText("FIRST NAME", "DynamicNames.DataLabels",w * .43, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                        draw.SimpleText("LAST NAME", "DynamicNames.DataLabels", w * .65, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText("EXTRAS", "DynamicNames.DataLabels", w * .9, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
                skipLblPnl = 2

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
                playerData_Avatar:SetSteamID(tDynNms.steamid64, 32)


                local playerData_PromptMenu = playerDataPanel:Add("DImageButton")
                playerData_PromptMenu:SetPos( scrw * .41, playerDataPanel:GetTall() * .3)
                playerData_PromptMenu:SetImage("icon16/application_form.png")
                playerData_PromptMenu:SizeToContents()
                playerData_PromptMenu.DoClick = function()
                    net.Start("MenuPrompt_Request")
                        net.WriteEntity(player.GetBySteamID(tDynNms.steamid))
                    net.SendToServer()
                end
                local dynNms_isPlyOnline = false
                if IsValid(player.GetBySteamID64(tDynNms.steamid64)) then
                    dynNms_isPlyOnline = true
                else
                    dynNms_isPlyOnline = false
                end
                if !dynNms_isPlyOnline then
                    playerData_PromptMenu:SetEnabled(false)
                    playerData_PromptMenu:SetTooltip("This player is offline")
                else
                    playerData_PromptMenu:SetTooltip("Bring up the name menu for this player")
                end
            end
        end
        tDynNms_GeneratePlyPanel()
    end )

    function plySearchBar:OnValueChange(searchedFor)
        if searchedFor == "" then
            playerDataList:Clear()
            skipLblPnl = 1
            tDynNms_GeneratePlyPanel()
            return
        else
            playerDataList:Clear()
            tDynNms_GeneratePlyPanel(searchedFor)
        end
    end
    ----------------------
    addNavTab("Settings")

    -- PREFIX TAB --

    addNavTab("Prefixes")

    local prefixMenu = adminNavbar.Tabs[3]
    local prefixList = prefixMenu:Add("DListView")
    prefixList:Dock(FILL)
    prefixList:AddColumn("Job")
    prefixList:AddColumn("Prefix")
    for k,prfx in pairs(DynamicNames.Prefixes) do
        prfx = prfx
        prefixList:AddLine(k,v)
    end
    --------------------------

end


concommand.Add( "dynamicnames_admin", DynamicNames.OpenAdminMenu)
