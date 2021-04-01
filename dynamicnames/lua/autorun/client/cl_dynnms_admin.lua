include("autorun/sh_dynamicnames.lua")


local btnClick = "dynamicnames/button_click.mp3"
local click_off = "dynamicnames/click_off.mp3"
local click_on = "dynamicnames/click_on.mp3"
local dcolTri = Material("dynamicnames/dcolcat-triangle.png")

local function draw_Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 )
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local function DynamicNames_OpenAdminMenu()
    if !DynamicNames.AdminGroups[LocalPlayer():GetUserGroup()] then return end

    if IsValid(adminFrame) then return end
    local scrw, scrh = ScrW(), ScrH()
    local adminFrame = vgui.Create("EditablePanel")
    adminFrame:SetSize(scrw * .45, scrh * .5)
    adminFrame:Center()
    adminFrame:MakePopup()
    adminFrame.Paint = function(self,w,h)
        if DynamicNames.Preferences["EnableMenuBlur"] then
            Derma_DrawBackgroundBlur(self) 
        end
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

                    if DynamicNames.Preferences["EnableIDNumber"] then
                        draw.SimpleText(tDynNms.idNum, "DynamicNames.DataLabels", w * .84 , h*.5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end

                    draw.SimpleText(tDynNms.steamid, "DynamicNames.DataLabels", w * .06, h*.5, Color(255,255,255), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                    draw.SimpleText(tDynNms.firstName, "DynamicNames.DataLabels",w * .43, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    draw.SimpleText(tDynNms.lastName, "DynamicNames.DataLabels", w * .65, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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
    local settingsMenu = adminNavbar.Tabs[2]
    local settingsScroll = settingsMenu:Add("DScrollPanel")
    settingsScroll:Dock(FILL)
    local settingsScrollVbar = settingsScroll:GetVBar()
    settingsScrollVbar:SetHideButtons(true)
    settingsScrollVbar:SetWide(7)
    function settingsScrollVbar:Paint(w,h) end
    function settingsScrollVbar.btnGrip:Paint(w,h)
        draw.RoundedBox(16,0,0,w,h,color_white)
    end

    local function addTickSetting(name, defaultVal, helpText)
        local thisSetting = {}
        thisSetting.switch = {}

        thisSetting.Frame = settingsScroll:Add("DPanel")
        thisSetting.Frame:Dock(TOP)
        thisSetting.Frame:DockMargin(10,10,10,0)
        thisSetting.Frame:SetSize(0, ScrH() * .05)
        thisSetting.Frame.Paint = function(self,w,h)
            draw.RoundedBox(8,0,0,w,h,Color(161,161,161))
            draw.SimpleText(name, "DynamicNames.Title", self:GetWide() * .01, ScrH() * .01,Color(0,0,0), TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT)
        end

        local bColor
        thisSetting.switch.frame = thisSetting.Frame:Add("DPanel")
        thisSetting.switch.frame:SetPos(ScrW() * .2, ScrH() * .013)
        thisSetting.switch.frame:SetMouseInputEnabled(true)
        thisSetting.switch.frame:SetCursor("hand")
        thisSetting.switch.frame.Paint = function(self,w,h)
            if !DynamicNames.Preferences[defaultVal] then
                bColor = Color(231, 76, 60)
            else
                bColor = Color(39, 174, 96)
            end
            draw.RoundedBox(12,0,0,w,h, bColor)
        end

        local defaultPos
        if DynamicNames.Preferences[defaultVal] then
            defaultPos = thisSetting.switch.frame:GetWide() * .6
        else
            defaultPos = 0
        end

        thisSetting.switch.circle = thisSetting.switch.frame:Add("DPanel")
        thisSetting.switch.circle:SetPos(defaultPos,0)
        thisSetting.switch.circle:SetSize(thisSetting.switch.frame:GetWide() * .4, thisSetting.switch.frame:GetTall())
        thisSetting.switch.circle:SetMouseInputEnabled( false )
        thisSetting.switch.circle.Paint = function(self,w,h)
            surface.SetDrawColor( 0, 0, 0)
            draw.NoTexture()
            draw_Circle( w * .5, h * .5, 10, 30 )
        end

        thisSetting.switch.frame.OnMousePressed = function()

            DynamicNames.Preferences[defaultVal] = !DynamicNames.Preferences[defaultVal]
            if DynamicNames.Preferences[defaultVal] then
                surface.PlaySound(click_on)
                thisSetting.switch.circle:MoveTo(thisSetting.switch.frame:GetWide() * .6, 0, .2, 0, -1)
            else
                surface.PlaySound(click_off)
                thisSetting.switch.circle:MoveTo(0, 0, .2, 0, -1)
            end

            net.Start("DynamicNames_ToggleConfig")
                net.WriteString(defaultVal)
                net.WriteBool(DynamicNames.Preferences[defaultVal])
            net.SendToServer()

        end

        if helpText then
            thisSetting.helpText = thisSetting.Frame:Add("DImage")
            thisSetting.helpText:SetImage("icon16/information.png")
            thisSetting.helpText:SizeToContents()
            thisSetting.helpText:SetPos(ScrW() * .4, ScrH() * .015)
            thisSetting.helpText:SetMouseInputEnabled(true)
            thisSetting.helpText:SetCursor("hand")
            thisSetting.helpText:SetTooltip(helpText)
        end
    end
    local function addListSetting(name, litable, helpText)
        local thisSetting = {}
        thisSetting.listItems = litable

        thisSetting.colCat = settingsScroll:Add("DCollapsibleCategory")
        thisSetting.colCat:Dock(TOP)
        thisSetting.colCat:DockMargin(10,10,10,0)
        thisSetting.colCat:SetHeaderHeight(ScrH() * .05)
        thisSetting.colCat:SetLabel("")
        thisSetting.colCat:SetExpanded(false)
        local rot
        thisSetting.colCat.Paint = function(self,w,h)
            draw.RoundedBox(8,0,0,w,h,Color(161,161,161))
            draw.SimpleText(name, "DynamicNames.Title", self:GetWide() * .5, self:GetHeaderHeight() * .5,Color(0,0,0), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

            if self:GetExpanded() then
                rot = -90
            else
                rot = 0
            end
            surface.SetDrawColor(color_white)
            surface.SetMaterial(dcolTri)
            surface.DrawTexturedRectRotated(ScrW() * .407,self:GetHeaderHeight() * .5,self:GetWide() * 0.0336700336700337,self:GetHeaderHeight() * 0.5263157894736842,rot)
        end

        local listView = vgui.Create("DListView")
        listView:Dock(TOP)
        thisSetting.colCat:SetContents(listView)
        listView:SetMultiSelect(false)
        listView:SetDataHeight(25)
        listView:SetHeaderHeight(0)
        listView:AddColumn("Banned Name")
        listView:DisableScrollbar(true)
        for value,bool in pairs(DynamicNames.Preferences[litable]) do
            listView:AddLine(value)
        end

        for lineID, line in ipairs(listView:GetLines()) do
            line.Paint = function(self,w,h)
                if self:IsLineSelected() then
                    surface.SetDrawColor(Color(69,147,211))
                elseif self:IsHovered() then
                    surface.SetDrawColor(Color(202,202,202))
                end
                surface.DrawRect(0,0,w,h)
            end
            for i, label in ipairs(line.Columns) do
              label:SetFont("DynamicNames.DataLabels")
            end
        end

        function listView:OnRowRightClick(lineID, line)
            local contMenu = DermaMenu(false)
    
            local edit = contMenu:AddOption("Edit", function()
                Derma_StringRequest("Edit", self.Columns[1].Header:GetText(), line.Columns[1]:GetText(), function(msg)
                    surface.PlaySound(btnClick)
                    local curLine = line.Columns[1]:GetText()
                    net.Start("DynamicNames_TableConfig")
                        net.WriteString(litable)
                        net.WriteString(curLine)
                        net.WriteBool(false)
                        net.WriteBool(false)
                        net.WriteString(msg)
                    net.SendToServer()
                    line.Columns[1]:SetText(msg)
                end, function()
                    surface.PlaySound(btnClick)
                end, "Edit", "Cancel")
            end )
            edit:SetIcon("icon16/pencil.png")

            local delete = contMenu:AddOption("Delete", function()
                Derma_Query("Are you sure you want to delete this banned name?", "Confirm Deletion", "Confirm", function()
                    surface.PlaySound(btnClick)
                    local curLine = line.Columns[1]:GetText()
                    net.Start("DynamicNames_TableConfig")
                        net.WriteString(litable)
                        net.WriteString(curLine)
                        net.WriteBool(true)
                        net.WriteBool(false)
                    net.SendToServer()
                    listView:RemoveLine(lineID)
                end, "Cancel", function()
                    surface.PlaySound(btnClick)
                end)
            end )
            delete:SetIcon("icon16/cross.png")

            contMenu:Open()
        end

        local addBNBtn = thisSetting.colCat.Header:Add("DImageButton")
        addBNBtn:SetImage("icon16/add.png")
        addBNBtn:SetKeepAspect(true)
        addBNBtn:SizeToContents()
        addBNBtn:SetPos(thisSetting.colCat.Header:GetWide() * .5, 0)
        addBNBtn:CenterVertical()
        addBNBtn:SetTooltip("Add a new banned name")
        addBNBtn.DoClick = function(self)
            local newBN = vgui.Create("EditablePanel")
            newBN:SetSize(ScrW() * .3, ScrH() * .35)
            newBN:Center()
            newBN:MakePopup()
            newBN:MoveToFront()
            newBN:DoModal(true)
            newBN.Paint = function(self,w,h)
                Derma_DrawBackgroundBlur(self)
                surface.SetDrawColor(DynamicNames.Themes.Default["Frame"])
                surface.DrawRect(0,0,w,h)
            end

            local bannedNameEntry = newBN:Add("DTextEntry")
            bannedNameEntry:SetSize(newBN:GetWide() * .5, newBN:GetTall() * .1)
            bannedNameEntry:SetPos(newBN:GetWide() * .25, newBN:GetTall() * .38)
            bannedNameEntry:SetPlaceholderText("Banned Name (Case Insensitive)")
            bannedNameEntry:SetFont("DynamicNames.Entries")

            local confirmBtn = newBN:Add("DButton")
            confirmBtn:SetWide(newBN:GetWide() * .2)
            confirmBtn:SetPos(newBN:GetWide() * .27, newBN:GetTall() * .7)
            confirmBtn:SetText("")
            local speed1  = 15
            local percentage1 = 0
            confirmBtn.Paint = function(self,w,h)
                if self:IsHovered() then
                    percentage1 = math.Clamp(percentage1 + speed1 * FrameTime(), 0, 1)
                else
                    percentage1 = math.Clamp(percentage1 - speed1 * FrameTime(), 0, 1)
                end
                surface.SetDrawColor(DynamicNames.Themes.Default["SubmitButton"])
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(DynamicNames.Themes.Default["SubmitHighlight"])
                surface.DrawRect(0,0,w, h * percentage1)
                draw.SimpleText("Confirm", "DynamicNames.DataLabels", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            confirmBtn.DoClick = function(self)
                surface.PlaySound(btnClick)
                local bannedName = bannedNameEntry:GetValue()
                if (bannedName == "" or bannedName == nil) then return end
                newBN:Remove()

                listView:AddLine(bannedName)
                for i, line in ipairs(listView:GetLines()) do
                    line.Paint = function(self,w,h)
                        if self:IsLineSelected() then
                            surface.SetDrawColor(Color(69,147,211))
                        elseif self:IsHovered() then
                            surface.SetDrawColor(Color(202,202,202))
                        end
                        surface.DrawRect(0,0,w,h)
                    end
                    for i, label in ipairs(line.Columns) do
                    label:SetFont("DynamicNames.DataLabels")
                    end
                end
                net.Start("DynamicNames_TableConfig")
                    net.WriteString(litable)
                    net.WriteString(bannedName)
                    net.WriteBool(false)
                    net.WriteBool(true)
                net.SendToServer()
            end

            local cancelBtn = newBN:Add("DButton")
            cancelBtn:SetWide(newBN:GetWide() * .2)
            cancelBtn:SetPos(newBN:GetWide() * .53, newBN:GetTall() * .7)
            cancelBtn:SetText("")
            local speed2 = 15
            local percentage2 = 0
            cancelBtn.Paint = function(self,w,h)
                if self:IsHovered() then
                    percentage2 = math.Clamp(percentage2 + speed2 * FrameTime(), 0, 1)
                else
                    percentage2 = math.Clamp(percentage2 - speed2 * FrameTime(), 0, 1)
                end
                surface.SetDrawColor(DynamicNames.Themes.Default["SubmitButton"])
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(DynamicNames.Themes.Default["SubmitHighlight"])
                surface.DrawRect(0,0,w, h * percentage2)
                draw.SimpleText("Cancel", "DynamicNames.DataLabels", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            cancelBtn.DoClick = function(self)
                surface.PlaySound(btnClick)
                newBN:Remove()
            end
        end


    end
    addTickSetting("Enable ID Number", "EnableIDNumber", "Enable the ID number primarily found in SCP-RP servers (e.g. D-0000).")
    addTickSetting("Enable Menu Blur", "EnableMenuBlur", "Enable or disable the blur around the menus.")
    addListSetting("Banned Names", "BannedNames")

    -- PREFIX TAB --

    addNavTab("Prefixes")

    local prefixMenu = adminNavbar.Tabs[3]
    local prefixList = prefixMenu:Add("DListView")
    prefixList:Dock(FILL)
    prefixList:AddColumn("Job")
    prefixList:AddColumn("Prefix")
    prefixList:SetMultiSelect(false)
    prefixList:SetDataHeight(40)
    prefixList:SetHeaderHeight(30)

    prefixList.Columns[1].Header.Paint = function(self,w,h)
        local drawCol
        if self:IsHovered() then
            drawCol = Color(199, 196, 196) 
        else
            drawCol = Color(141, 138, 138)
        end
        draw.RoundedBox(6,0,0,w,h,drawCol)
    end
    prefixList.Columns[1].Header:SetFont("DynamicNames.DataLabels")
    prefixList.Columns[1].Header:SetTextColor(Color(0,0,0))

    prefixList.Columns[2].Header.Paint = function(self,w,h)
        local drawCol
        if self:IsHovered() then
            drawCol = Color(199, 196, 196) 
        else
            drawCol = Color(141, 138, 138)
        end
        draw.RoundedBox(4,0,0,w,h,drawCol)
    end
    prefixList.Columns[2].Header:SetFont("DynamicNames.DataLabels")
    prefixList.Columns[2].Header:SetTextColor(Color(0,0,0))

    for job,prfx in pairs(DynamicNames.ClientPrefixes) do
        prefixList:AddLine(job,prfx)
    end
    
    prefixList.Paint = function(self,w,h)
        surface.DrawRect(0,0,w,h)
    end

    prefixList.VBar:SetHideButtons(true)
    prefixList.VBar:SetWide(2)
    prefixList.VBar.Paint = nil
    prefixList.VBar.btnGrip.Paint = function(self,w,h)
        draw.RoundedBox(16,0,0,w,h,color_white)
    end

    for i, line in ipairs(prefixList:GetLines()) do
        line.Paint = function(self,w,h)
            if self:IsLineSelected() then
                surface.SetDrawColor(Color(69,147,211))
            elseif self:IsHovered() then
                surface.SetDrawColor(Color(255,255,255))
            end
            surface.DrawRect(0,0,w,h)
        end
        for i, label in ipairs(line.Columns) do
          label:SetFont("DynamicNames.DataLabels")
        end
    end

    function prefixList:OnRowRightClick(lineID, line)
        local contMenu = DermaMenu(false)
        local subMenu, contMenuOption = contMenu:AddSubMenu("Edit")
        contMenuOption:SetIcon("icon16/pencil.png")
        

        local eJobName = subMenu:AddOption("Job Name", function()
            Derma_StringRequest("Edit", self.Columns[1].Header:GetText(), line.Columns[1]:GetText(), function(msg)
                surface.PlaySound(btnClick)
                net.Start("DynamicNames_prfxEditJobName")
                    net.WriteString(line.Columns[1]:GetText())
                    net.WriteString(msg)
                net.SendToServer()
                line.Columns[1]:SetText(msg)
            end, function()
                surface.PlaySound(btnClick)
            end, "Edit", "Cancel")
        end )
        eJobName:SetIcon("icon16/application_form.png")

        local eJobPrefix = subMenu:AddOption("Job Prefix", function()
            Derma_StringRequest("Edit", self.Columns[2].Header:GetText(), line.Columns[2]:GetText(),  function(msg)
                surface.PlaySound(btnClick)
                net.Start("DynamicNames_EditPrefix")
                    net.WriteString(line.Columns[1]:GetText())
                    net.WriteString(msg)
                net.SendToServer()
                line.Columns[2]:SetText(msg)
            end, function()
                surface.PlaySound(btnClick) 
            end, "Edit", "Cancel")
        end )
        eJobPrefix:SetIcon("icon16/application_form.png")

        local delEntry = contMenu:AddOption("Delete", function()
            Derma_Query("Are you sure you want to delete the prefix for "..line.Columns[1]:GetText().."?", "Confirm Deletion", "Confirm", function()
                surface.PlaySound(btnClick)
               net.Start("DynamicNames_DelPrefix")
                    net.WriteString(line.Columns[1]:GetText())
               net.SendToServer() 
               prefixList:RemoveLine(lineID)
            end, "Cancel", function()
                surface.PlaySound(btnClick)
            end)
        end )
        delEntry:SetIcon("icon16/cross.png")

        contMenu:Open()
    end


    local addPrefixBtn = prefixMenu:Add("DImageButton")
    addPrefixBtn:SetImage("icon16/add.png")
    addPrefixBtn:SetPos( prefixMenu:GetWide() * .1, prefixMenu:GetTall() * .25 )
    addPrefixBtn:SetKeepAspect(true)
    addPrefixBtn:SizeToContents()
    addPrefixBtn:SetTooltip("Add a new prefix")
    addPrefixBtn.DoClick = function(self)
        local newPrefix = vgui.Create("EditablePanel")
        newPrefix:SetSize(ScrW() * .3, ScrH() * .35)
        newPrefix:Center()
        newPrefix:MakePopup()
        newPrefix:MoveToFront()
        newPrefix:DoModal(true)
        newPrefix.Paint = function(self,w,h)
            Derma_DrawBackgroundBlur(self)
            surface.SetDrawColor(DynamicNames.Themes.Default["Frame"])
            surface.DrawRect(0,0,w,h)
        end

        local jobNameEntry = newPrefix:Add("DTextEntry")
        jobNameEntry:SetSize(newPrefix:GetWide() * .5, newPrefix:GetTall() * .07)
        jobNameEntry:SetPos(newPrefix:GetWide() * .25, newPrefix:GetTall() * .38)
        jobNameEntry:SetPlaceholderText("Job Name (Case Sensitive)")
        jobNameEntry:SetFont("DynamicNames.Entries")

        local prefixEntry = newPrefix:Add("DTextEntry")
        prefixEntry:SetSize(newPrefix:GetWide() * .5, newPrefix:GetTall() * .07)
        prefixEntry:SetPos(newPrefix:GetWide() * .25, newPrefix:GetTall() * .48)
        prefixEntry:SetPlaceholderText("Job Prefix")
        prefixEntry:SetFont("DynamicNames.Entries")

        local prefixInfo = newPrefix:Add("DImage")
        prefixInfo:SetImage("icon16/information.png")
        prefixInfo:SizeToContents()
        prefixInfo:SetPos(newPrefix:GetWide() * .2, newPrefix:GetTall() * .49)
        prefixInfo:SetMouseInputEnabled(true)
        prefixInfo:SetTooltip("You can use #firstName, #lastName, and #idNum (if enabled). See the readme for more information.")
        prefixInfo:SetCursor("hand")

        local confirmBtn = newPrefix:Add("DButton")
        confirmBtn:SetWide(newPrefix:GetWide() * .2)
        confirmBtn:SetPos(newPrefix:GetWide() * .27, newPrefix:GetTall() * .7)
        confirmBtn:SetText("")
        local speed1  = 15
        local percentage1 = 0
        confirmBtn.Paint = function(self,w,h)
            if self:IsHovered() then
                percentage1 = math.Clamp(percentage1 + speed1 * FrameTime(), 0, 1)
            else
                percentage1 = math.Clamp(percentage1 - speed1 * FrameTime(), 0, 1)
            end
            surface.SetDrawColor(DynamicNames.Themes.Default["SubmitButton"])
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(DynamicNames.Themes.Default["SubmitHighlight"])
            surface.DrawRect(0,0,w, h * percentage1)
            draw.SimpleText("Confirm", "DynamicNames.DataLabels", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        confirmBtn.DoClick = function(self)
            surface.PlaySound(btnClick)
            local jobName = jobNameEntry:GetValue()
            local prefixName = prefixEntry:GetValue()
            if (jobName == "" or jobName == nil) and (prefixName == "" or prefixName == nil) then return end
            newPrefix:Remove()

            prefixList:AddLine(jobName, prefixName)
            for i, line in ipairs(prefixList:GetLines()) do
                line.Paint = function(self,w,h)
                    if self:IsLineSelected() then
                        surface.SetDrawColor(Color(69,147,211))
                    elseif self:IsHovered() then
                        surface.SetDrawColor(Color(255,255,255))
                    end
                    surface.DrawRect(0,0,w,h)
                end
                for i, label in ipairs(line.Columns) do
                  label:SetFont("DynamicNames.DataLabels")
                end
            end
            net.Start("DynamicNames_EditPrefix")
                net.WriteString(jobName)
                net.WriteString(prefixName)
            net.SendToServer()
        end

        local cancelBtn = newPrefix:Add("DButton")
        cancelBtn:SetWide(newPrefix:GetWide() * .2)
        cancelBtn:SetPos(newPrefix:GetWide() * .53, newPrefix:GetTall() * .7)
        cancelBtn:SetText("")
        local speed2 = 15
        local percentage2 = 0
        cancelBtn.Paint = function(self,w,h)
            if self:IsHovered() then
                percentage2 = math.Clamp(percentage2 + speed2 * FrameTime(), 0, 1)
            else
                percentage2 = math.Clamp(percentage2 - speed2 * FrameTime(), 0, 1)
            end
            surface.SetDrawColor(DynamicNames.Themes.Default["SubmitButton"])
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(DynamicNames.Themes.Default["SubmitHighlight"])
            surface.DrawRect(0,0,w, h * percentage2)
            draw.SimpleText("Cancel", "DynamicNames.DataLabels", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        cancelBtn.DoClick = function(self)
            surface.PlaySound(btnClick)
            newPrefix:Remove()
        end
    end
    --------------------------

end

concommand.Add( "dynamicnames_admin", function()
    net.Start("DynamicNames_RetrievePrefixes+Prefs")
    net.SendToServer()
end )

net.Receive("DynamicNames_SendPrefixes+Prefs", function()
    DynamicNames.ClientPrefixes = net.ReadTable()
    DynamicNames.Preferences = net.ReadTable()
    DynamicNames_OpenAdminMenu()
end )