local TEAM2 = Color(255, 255, 255, 150)
local SinAng2 = 0
local tex2 = surface.GetTextureID("navalwarfare/capture_ring2")
function DrawBox()
	if(SinAng2!=nil) then
		if(SinAng2>360) then
			SinAng2=0
		else
			SinAng2 = SinAng2 + 0.01
		end
	else
		SinAng2 = 0
	end
	local Ang2 = Angle(90,0,0)
	local Vec2 = Vector(9252, 9211, 2132)
	local Verc2 = (Vec2 + Ang2:Up()):ToScreen()
	local Rad2 = 850 + math.sin(SinAng2)*75
	cam.Start3D2D( Vec2, Angle(0, 0, 0), 10)
		draw.TexturedQuad
		{
			texture = tex2,
			color = TEAM2,
			x = -Rad2/2,
			y = -Rad2/2,
			w = Rad2,
			h = Rad2
		}
    cam.End3D2D()
end
hook.Add("PostDrawOpaqueRenderables", "DrawBox", DrawBox);
hook.Remove("PostDrawOpaqueRenderables", "DrawBox")

local function RecvMyUmsg( data )
	local term2 = data:ReadShort()
	TEAM2 = team.GetColor(term2)
end
usermessage.Hook( "sendteamrig", RecvMyUmsg );