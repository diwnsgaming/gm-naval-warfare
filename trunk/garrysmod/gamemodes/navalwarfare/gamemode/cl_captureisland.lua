local TEAM = Color(255, 255, 255, 150)
local SinAng = 0
local tex = surface.GetTextureID("navalwarfare/capture_ring2")

--Uncomment this if you also uncomment the serverside portion.

-- function DrawBox()
	-- if(SinAng!=nil) then
		-- if(SinAng>360) then
			-- SinAng=0
		-- else
			-- SinAng = SinAng + 0.01
		-- end
	-- else
		-- SinAng = 0
	-- end
	-- local Ang = Angle(90,0,0)
	-- local Vec = Vector(-7295.541504, -8403.884766, 520.271362)
	-- local Verc = (Vec + Ang:Up()):ToScreen()
	-- local Rad = 850 + math.sin(SinAng)*75
	-- if(Verc.visible) then
		-- surface.DrawCircle( Verc.x, Verc.y, 50, Color(255,255,255,255) ) 
	-- end
	-- cam.Start3D2D( Vec, Angle(0, 0, 0), 10)
		-- draw.TexturedQuad
		-- {
			-- texture = tex,
			-- color = TEAM,
			-- x = -Rad/2,
			-- y = -Rad/2,
			-- w = Rad,
			-- h = Rad
		-- }
    -- cam.End3D2D()
-- end
-- hook.Add("PostDrawOpaqueRenderables", "DrawBox", DrawBox);

-- local function RecvMyUmsg( data )
	-- local term = data:ReadShort()
	-- TEAM = team.GetColor(term)
-- end
-- usermessage.Hook( "sendteam", RecvMyUmsg )