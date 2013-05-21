include('shared.lua')
function ENT:Draw()
	self:DrawModel()
	local offset = Vector(160,-15,-5)
	local ang = self:GetAngles()
	offset:Rotate( ang)
	local pos = self:GetPos()+offset
	local rot = CurTime()*50
	ang.p = 0
	ang.r = 0

	cam.Start3D2D( pos, ang+Angle(0,90,90), 0.25)
		draw.DrawText( math.Round(self:GetNWInt("Oil")).." oil", "Myfont",-25,0,Color(255,255,255,255), TEXT_ALIGN_LEFT)
		draw.RoundedBox(0,-25,25,160,20,Color(100,100,100,255))
		draw.RoundedBox(0,-23,27,156/6000*self:GetNWInt("Oil"),16,Color(0,0,0,255))
		draw.DrawText( self:GetNWInt("mass").." kg", "Myfont",136,0,Color(255,255,255,255), TEXT_ALIGN_RIGHT)
	cam.End3D2D()
end