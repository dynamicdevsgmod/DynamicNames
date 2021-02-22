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

    DynamicNames.AdminMenu.OnSizeChanged = function(self,w,h)
        if isAnimating then
            self:Center()
        end
        adminHeader:SetTall( frameH * .1)
        adminExit:Dock(RIGHT)
    end

end

concommand.Add( "dynamicnames_admin", DynamicNames.OpenAdminMenu)



--[[ TESTING FOR PREFIX SYSTEM

]]
