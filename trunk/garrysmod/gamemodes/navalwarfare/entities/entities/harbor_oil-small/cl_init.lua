include('shared.lua')
function ENT:Draw()
	self:DrawModel()
	local offset = Vector(0,0,60)
	local ang = self:GetAngles()
	offset:Rotate( ang)
	local pos = self:GetPos()+offset
	local rot = CurTime()*50
	ang.p = 0
	ang.r = 0

	cam.Start3D2D( pos, ang+Angle(0,rot,90), 0.25)
		draw.DrawText( math.Round(self:GetNWInt("Oil")).." oil", "Myfont",0,0,Color(255,255,255,255), TEXT_ALIGN_CENTER)
		--print("derp")
	cam.End3D2D()
	cam.Start3D2D( pos,ang+Angle(0,rot+180,90), 0.25)
		draw.DrawText( self:GetNWInt("mass").." kg", "Myfont",0,0,Color(255,255,255,255), TEXT_ALIGN_CENTER)
		--print("derp")
	cam.End3D2D()
end
