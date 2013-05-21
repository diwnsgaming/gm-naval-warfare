--[[
Converts from Draw3D2D screen coordinates to world coordinates.
x and y are the coordinates to transform, in pixels.
vPos is the position you gave Start3D2D. The screen is drawn from this point in the world.
scale is a number you also gave to Start3D2D. The Draw3D2D screen is scaled this much
aRot is the angles you gave Start3D2D. The screen is drawn rotated according to these angles.
]]--
local function ScreenToWorld(x,y,vPos,scale,aRot)
    local vWorldPos=Vector(x*scale,(-y)*scale,0);
    vWorldPos:Rotate(aRot);
    vWorldPos=vWorldPos+vPos;
    return vWorldPos;
end
 
--[[
Converts from world coordinates to Draw3D2D screen coordinates.
vWorldPos is a vector in the world nearby a Draw3D2D screen.
vPos is the position you gave Start3D2D. The screen is drawn from this point in the world.
scale is a number you also gave to Start3D2D.
aRot is the angles you gave Start3D2D. The screen is drawn rotated according to these angles.
]]--
local function WorldToScreen(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

function DoHealthMeter()
	local pos = LocalPlayer():GetShootPos()
	local ang = LocalPlayer():GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ang*180)
	tracedata.filter = LocalPlayer()
	local trace = util.TraceLine(tracedata)
	if trace.HitNonWorld and trace.Entity:GetClass() == "prop_physics" then
		local target = trace.Entity
		local NWHealth = target:GetNWInt("NWHealth")
		draw.DrawText( "HEALTH: "..math.Round(NWHealth), "Myfont",ScrW()/2,ScrH()/2,Color(255,255,255,255), TEXT_ALIGN_CENTER)
		if math.Round(NWHealth) == 0 then
			RunConsoleCommand("nw_uph", trace.Entity:EntIndex())
		end
	end
end

function DrawCompass()
	--Not important
end

function DrawCompass2() --  FUCK THIS COMPASS
	local EAngles = LocalPlayer():GetAimVector():Angle()
	local ang = Angle(EAngles.p+140, EAngles.y, EAngles.r)
	local pos = LocalPlayer():GetShootPos()+EAngles:Forward()*10
	pos = ScreenToWorld(0,0, pos,1,Angle(0,0,0))
	--cam.Start3D2D( pos, ang, 1	)
	--	draw.TexturedQuad
	--	{
	--		texture = surface.GetTextureID "navalwarfare/compass",
	--		color = Color(10, 10, 10, 120),
	--		x = -1,
	---		y = -1,
	--		w = 2,
	--		h = 2
	--	}
	--cam.End3D2D()
end
hook.Add( "PostDrawOpaqueRenderables", "ClusterFuck", DrawCompass2 )