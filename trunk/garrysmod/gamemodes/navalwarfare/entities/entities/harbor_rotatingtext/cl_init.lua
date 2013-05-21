include('shared.lua')
surface.CreateFont( "Myfont",
{
	font    = "DefaultBold", -- Not file name, font name
	--size    = fontSize,
	size = 25,
	weight  = 400,
	antialias = true,
	shadow = true
})
function ENT:Draw()
	--self:DrawModel()
	local pos = self:GetPos()
	local rot = CurTime()*50
	cam.Start3D2D( pos, Angle(0,rot,90), 0.25)
		draw.DrawText( self:GetNWString("text1"), "Myfont",0,0,Color(255,255,255,255), TEXT_ALIGN_CENTER)
	cam.End3D2D()
	cam.Start3D2D( pos, Angle(0,rot+180,90), 0.25)
		draw.DrawText( self:GetNWString("text2"), "Myfont",0,0,Color(255,255,255,255), TEXT_ALIGN_CENTER)
	cam.End3D2D()
end