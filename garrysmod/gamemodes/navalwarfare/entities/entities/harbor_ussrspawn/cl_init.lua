include('shared.lua')
surface.CreateFont("US_Default_Font", { font = "ChatFont",	size = 300, weight = 100, underline = true})
local Pos, Ang = nil

local function WorldToScreen(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end
function ENT:Initialize()
    --self:SetModel("models/dav0r/buttons/button.mdl")
end
function ENT:Draw()
	self:DrawModel()
	
	if(Pos == nil) or (Ang == nil) then
		Ang = self:GetAngles()
		Pos = self:GetPos() - Ang:Forward()*28 - Ang:Right()*5 - Ang:Up()*10		
	end
	
	surface.SetFont("US_Default_Font")
	local ussr_x, ussr_y = surface.GetTextSize(language.GetPhrase("REBEL"))
	local full_x, full_y = surface.GetTextSize(language.GetPhrase("FULL"))
	
	cam.Start3D2D(Pos, Ang, 0.1)
	
		surface.SetDrawColor(140,0,0,100)
		surface.DrawRect(40,0,480,ussr_y+5)
		
		surface.SetTextColor(190,190,190,100)
		surface.SetTextPos(285-ussr_x/2,0)
		surface.DrawText(language.GetPhrase("REBEL"))
		
		if(self:GetNWBool("isfull")) then
			surface.SetTextPos(285-full_x/2,-150)
			surface.DrawText(language.GetPhrase("FULL"))
			surface.DrawRect(40,-150,480,full_y+5)
		end
		
	cam.End3D2D()	
end