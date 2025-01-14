include("shared.lua")
surface.CreateFont("MARKMENUFONT", {
  font = "Roboto",
  size = 30,
  weight = 650,
  shadow = true,
  antialias = false,
})

function ENT:Draw()
  self:DrawModel()
  local Pos = self:GetPos() - Vector(-8, 0, 0)
  local Ang = Angle(0, 0, 0)
  surface.SetFont("MARKMENUFONT")
  Ang:RotateAroundAxis(Ang:Forward(), 90)
  local TextAng = Ang
  TextAng:RotateAroundAxis(TextAng:Right(), -90)
  cam.Start3D2D(Pos + Ang:Right() * -17, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
  local colortable = self:Getrpcolor()
  local newcolor = colortable:ToColor()
  draw.WordBox(.9, -50, 0, self:GetRPText(), "MARKMENUFONT", ColorAlpha(color_black, 155), newcolor)
  cam.End3D2D()
end

local function markermenu(data)
  local markerent = net.ReadEntity()
  markercreationui = vgui.Create("DFrame")
  markercreationui:SetSize(550, 350)
  markercreationui:SetPos(ScrW() / 2 - 350, ScrH() / 2 - 200)
  markercreationui:MakePopup()
  markercreationui:SetTitle("Marker Creation Menu")
  markercreationui:SetBackgroundBlur("true")
  local Mixer = vgui.Create("DColorMixer", markercreationui)
  Mixer:SetSize(200, 200)
  Mixer:SetPos(160, 100)
  Mixer:SetPalette(true)
  Mixer:SetAlphaBar(false)
  Mixer:SetWangs(true)
  Mixer:SetLabel("Choose Marker Color")
  Mixer:SetColor(color_white)
  Mixer.ValueChanged = function()
    mixercolor = Mixer:GetColor()
    net.Start("markercolor")
    net.WriteEntity(markerent)
    net.WriteColor(mixercolor)
    net.SendToServer()
  end

  local TextLimit = 60
  local TextEntryPH = vgui.Create("DTextEntry", markercreationui)
  TextEntryPH:SetPos(65, 50)
  TextEntryPH:SetSize(400, 26)
  TextEntryPH:SetPlaceholderText("Fill Text Here and Text Color Below")
  TextEntryPH.OnEnter = function(self)
    net.Start("markartextchange")
    net.WriteEntity(markerent)
    net.WriteString(string.sub(self:GetValue(), 1, TextLimit))
    net.SendToServer()
  end

  local DermaButton = vgui.Create("DButton", markercreationui)
  DermaButton:SetText("Delete Marker")
  DermaButton:SetPos(150, 318)
  DermaButton:SetSize(250, 30)
  DermaButton.DoClick = function()
    net.Start("deletemarker")
    net.WriteEntity(markerent)
    net.SendToServer()
    markercreationui:Close()
  end
end

net.Receive("markarmenu", markermenu)
