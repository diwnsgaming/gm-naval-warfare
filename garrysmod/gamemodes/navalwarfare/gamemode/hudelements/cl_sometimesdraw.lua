function DrawPlayerNames()
	for _, pl in ipairs( player.GetAll() ) do
		if ( pl!=LocalPlayer() and pl:Health() > 0 and pl:Team() == LocalPlayer():Team() or pl!=LocalPlayer() and adminMode) then
			local td = {}
			td.start = LocalPlayer():GetShootPos()
			td.endpos = pl:GetShootPos()
			local trace = util.TraceLine( td )

			if ( !trace.HitWorld ) then
				surface.SetFont( "DermaDefaultBold" )
				local w = surface.GetTextSize( pl:Nick() ) + 32
				local h = 24

				local pos = pl:GetShootPos()
				local bone = pl:LookupBone( "ValveBiped.Bip01_Head1" )
				if ( bone ) then
					pos = pl:GetBonePosition( bone )
				end

				local drawPos = pl:GetShootPos():ToScreen()
				local distance = LocalPlayer():GetShootPos():Distance( pos )
				drawPos.x = drawPos.x - w / 2
				drawPos.y = drawPos.y - h - 25

				local alpha = 255
				if ( distance > 512 ) then
					alpha = 255 - math.Clamp( ( distance - 512 ) / ( 2048 - 512 ) * 255, 0, 255 )
				end

				surface.SetDrawColor( 62, 62, 62, alpha )
				surface.DrawRect( drawPos.x, drawPos.y, w, h )
				if adminMode then
					surface.DrawRect( drawPos.x, drawPos.y-25, w-50, h )
				end
				surface.SetDrawColor( 129, 129, 129, alpha )
				surface.DrawOutlinedRect( drawPos.x, drawPos.y, w, h )
				if adminMode then
					surface.DrawOutlinedRect( drawPos.x, drawPos.y-25, w-50, h )
				end
				surface.SetMaterial( Material("materials/null") )

				surface.SetDrawColor( 255, 255, 255, math.Clamp( alpha * 2, 0, 255 ) )

				local col = team.GetColor( pl:Team() )
				col.a = math.Clamp( alpha * 2, 0, 255 )
				draw.DrawText( pl:Nick(), "DermaDefaultBold", drawPos.x+15, drawPos.y + 5, col, 0 )
			end
		end
	end
end
local transA = 0
function DrawAmmoCounter(clip, total)
	if transOn then
		if transitionAmmo >= 0.5 then
			local mul = 1/0.5*(transitionAmmo-0.5)
			mainHudElements["innerCircle"] = getArc(40,scrHeight-40,90,32,math.pi*0.96*mul,math.pi*1.495)
			mainHudElements["outerCircle"] = getArc(40,scrHeight-40,100,32,math.pi*0.9,math.pi*1.46455)
		elseif transitionAmmo <= 0.5 then 
			local mul = 1/0.5*(transitionAmmo)
			mainHudElements["outerCircle"] = getArc(40,scrHeight-40,100,32,math.pi*0.9*mul,math.pi*1.46455)
		end
		transA = 0
	end
	surface.SetTexture(0)
	surface.SetDrawColor(teamCol2)
	surface.DrawPoly(mainHudElements["outerCircle"])
	surface.SetDrawColor(teamCol)
	surface.DrawPoly(mainHudElements["innerCircle"])
	
	surface.SetDrawColor(Color(100,100,100,255))
	if !transOn then
		local radius = 80
		local add = -math.pi*1.6
		local asdasd = 10
		local col2 = Color(teamCol2.r,teamCol2.g,teamCol2.b,teamCol2.a*transA/4)
		for i = 1, clip do
			local ang = ( 130 / asdasd * i ) + math.floor( (i-1) / asdasd ) * 230 + 150
			local x = math.sin(math.rad(-ang)) * radius + 40
			local y = math.cos(math.rad(-ang)) * radius + scrHeight - 40
			surface.SetDrawColor(Color(188,155,64,255*transA))
			surface.DrawTexturedRectRotated(x,y,radius/6,3,-ang)
			surface.SetDrawColor(Color(188,155,64,100))
			surface.DrawTexturedRectRotated(x-1,y-1,radius/6+2,5,-ang)
			if( i % asdasd == 0 ) then 
				radius  = radius - 6
			end
		end
		surface.SetFont( "HudText" )
		surface.SetTextColor(255, 255, 255, 255*transA)
		surface.SetTextPos( clip1HudElements["TextX"], clip1HudElements["TextY"] )
		surface.SetDrawColor(col2)
		surface.DrawPoly(clip1HudElements["TextCircle"])
		surface.DrawText( clip )
		surface.SetFont( "HudText-small" )
		surface.SetTextPos( clip1HudElements["TextX"]+27, clip1HudElements["TextY"]+9 )
		surface.DrawText( total )
		if transA < 1 then
			transA = transA + 0.005
		end
		
	end
	
	--surface.SetTextColor(255, 255, 255, 150)
	--surface.SetFont( "HudText" )
	--surface.SetTextPos( clip1HudElements["TextX"], clip1HudElements["TextY"] )
	
	--draw.RoundedBox( 6, clip1HudElements["X"], clip1HudElements["Y"], clip1HudElements["BoxWidth"], clip1HudElements["BoxHeight"], Color( 0, 0, 0, 150 ) )
end

function DrawAmmoCounterAlt(alt)
	surface.SetTextColor( 255, 255, 255, 150)
	surface.SetFont( "HudText" )
	surface.SetTextPos( clip2HudElements["TextX"], clip2HudElements["TextY"] )
	surface.DrawText( "ALT: "..alt) 
	draw.RoundedBox( 6, clip2HudElements["X"], clip2HudElements["Y"], clip2HudElements["BoxWidth"], clip2HudElements["BoxHeight"], Color( 0, 0, 0, 150 ) )
end

function DrawAdminBox()
	draw.RoundedBox( 6, adminHudElements["X"], adminHudElements["Y"], adminHudElements["BoxWidth"], adminHudElements["BoxHeight"], Color( 0, 0, 0, 255 ) )
	surface.SetTextColor( 255, 255, 255, 255)
	surface.SetFont( "HudText" )
	surface.SetTextPos( adminHudElements["TextX"], adminHudElements["TextY"] )
	surface.DrawText( "Admin" )
end
local a = 0
function DrawStaminaBar()
	-- local cornerRadius = 6
	-- local length = (staminaHudElements["BoxHeight"])/100*stamina
	-- if length < 12 then
		-- cornerRadius = math.ceil(length/2)
	-- end
	-- draw.RoundedBox( cornerRadius, staminaHudElements["X"]+5, staminaHudElements["Y"]+5, (length*6)-10, staminaHudElements["BoxHeight"]-10, Color( 0, 127, 255, 200) )
	-- draw.RoundedBox( 6, staminaHudElements["X"], staminaHudElements["Y"], staminaHudElements["BoxWidth"], staminaHudElements["BoxHeight"], Color( 0, 0, 0, 150 ) )
	-- if(ply:GetNWBool("ishome")) then
		-- draw.DrawText("Protected by Harbor", "HudText", staminaHudElements["TextX"]+135, staminaHudElements["TextY"], Color( 150, 150, 150, 255),TEXT_ALIGN_CENTER)
	-- else
		-- draw.DrawText("Stamina", "HudText", staminaHudElements["TextX"]+135, staminaHudElements["TextY"], Color( 150, 150, 150, 255),TEXT_ALIGN_CENTER)
	-- end
	surface.SetTexture(0)
	local trans = mainHudElements["xMod"]*transitionAmmo
	local leftX = trans
	local StamTrans = transitionStamina*40
	if a < 1 and !stransOn then
		a = a + 0.005
	elseif stransOn then a = 0
	end
	staminaHudElements["square"][1]["x"] = mainHudElements["outerSquare"][2]["x"]
	staminaHudElements["square"][3]["x"] = mainHudElements["outerSquare"][3]["x"] + StamTrans
	staminaHudElements["square"][2]["x"] = mainHudElements["outerSquare"][2]["x"] + StamTrans
	staminaHudElements["square"][4]["x"] = mainHudElements["outerSquare"][3]["x"]
	
	staminaHudElements["bar"][1]["x"] = 295 + leftX
	staminaHudElements["bar"][2]["x"] = 325 + leftX
	staminaHudElements["bar"][3]["x"] = 351 + leftX
	staminaHudElements["bar"][4]["x"] = 321 + leftX
	
	staminaHudElements["stam"][1]["x"] = 306 + leftX + 20/100*(100-stamina)
	staminaHudElements["stam"][1]["y"] = scrHeight-40 + 30/100*(100-stamina)
	staminaHudElements["stam"][2]["x"] = 320 + leftX + 20/100*(100-stamina)
	staminaHudElements["stam"][2]["y"] = scrHeight-40 + 30/100*(100-stamina)
	
	staminaHudElements["stam"][3]["x"] = 341 + leftX
	staminaHudElements["stam"][4]["x"] = 326 + leftX
	
	surface.SetDrawColor(teamCol2)
	surface.DrawPoly(staminaHudElements["square"])
	surface.SetDrawColor(Color(100,100,100,a*255))
	surface.DrawPoly(staminaHudElements["bar"])
	surface.SetDrawColor(Color(100,255,100,a*255))
	surface.DrawPoly(staminaHudElements["stam"])
	
end

function navalwarfare_DrawFaggot()
	if(isAFag) then
		for i = 0, 256 do
			draw.DrawText(LocalPlayer():GetNWString("faggotText"), "HudText", math.random(0,surface.ScreenWidth()),math.random(0,surface.ScreenHeight()),Color(math.random(100,255),math.random(100,255),math.random(100,255)))
		end
	end
end