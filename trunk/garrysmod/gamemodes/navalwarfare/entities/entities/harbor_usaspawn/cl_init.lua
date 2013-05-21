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
	Pos = nil
	Ang = nil
end
function ENT:Draw()
	self:DrawModel()
	
	if(Pos == nil) or (Ang == nil) then
		Ang = self:GetAngles()
		Ang.y = Ang.y +180
		Pos = self:GetPos() + self:GetForward()*28 - self:GetRight()*5 + self:GetUp()*15
	end
	
	surface.SetFont("US_Default_Font")
	local usa_x, usa_y = surface.GetTextSize("COMBINE")
	local full_x, full_y = surface.GetTextSize("FULL")
	
	cam.Start3D2D(Pos, Ang, 0.1)
	
		surface.SetDrawColor(0,0,140,100)
		surface.DrawRect(40,0,480,usa_y+5)
		
		surface.SetTextColor(190,190,190,100)
		surface.SetTextPos(285-usa_x/2,0)
		surface.DrawText("COMBINE")
		
		if(self:GetNWBool("isfull")) then
			surface.SetTextPos(285-full_x/2,-150)
			surface.DrawText(language.GetPhrase("FULL"))
			surface.DrawRect(40,-150,480,full_y+5)
		end
		
	cam.End3D2D()	
end