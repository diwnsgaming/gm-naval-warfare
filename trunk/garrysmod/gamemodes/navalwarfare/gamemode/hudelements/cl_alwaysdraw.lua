function DrawHarborBits()
	pos = Vector(-14484, 14355, 0)
	--render.DrawBox(pos, Angle(0,0,0), pos+Vector(10,10,10), pos-Vector(10,10,10), Color(255,255,255,255))
end

function DrawMainHud()

	surface.SetTexture(0)
	-- surface.SetFont( "HudText" )
	-- surface.SetTextColor( 255, 255, 255, 150)
	-- surface.SetTextPos( mainHudElements["HTextX"], mainHudElements["HTextY"])
	-- surface.DrawText( "Health: "..hitPoints) // Health
	
	-- surface.SetTextColor( 255, 255, 255, 150)
	-- surface.SetTextPos( mainHudElements["ATextX"], mainHudElements["ATextY"] )
	-- surface.DrawText( "Armor: "..armor) //Armor

	-- draw.RoundedBox( 6, mainHudElements["X"], mainHudElements["Y"], mainHudElements["BoxWidth"], mainHudElements["BoxHeight"], Color( 0, 0, 0, 150 ) )

	local trans = mainHudElements["xMod"]*transitionAmmo
	local leftX = 10 + trans
	local len = (260)
	
	mainHudElements["innerSquare"][2]["x"] = 277+trans
	mainHudElements["innerSquare"][3]["x"] = 317+trans
	mainHudElements["outerSquare"][2]["x"] = 287+trans
	mainHudElements["outerSquare"][3]["x"] = 327+trans
	
	mainHudElements["healthOutline"][1]["x"] = leftX-5
	mainHudElements["healthOutline"][4]["x"] = leftX-5
	mainHudElements["healthOutline"][2]["x"] = 275+trans
	mainHudElements["healthOutline"][3]["x"] = 300+trans
	
	mainHudElements["healthBar"][1]["x"] = leftX
	mainHudElements["healthBar"][4]["x"] = leftX
	mainHudElements["healthBar"][2]["x"] = len/100*hitPoints+leftX
	mainHudElements["healthBar"][3]["x"] = len/100*hitPoints+18+leftX
	
	
	surface.SetDrawColor(teamCol2)	
	surface.DrawPoly(mainHudElements["outerSquare"])	
			
	surface.SetDrawColor(teamCol)
	surface.DrawPoly(mainHudElements["innerSquare"])

	--print(hitPoints)
	
	surface.SetDrawColor(Color(100,100,100,255))
	surface.DrawPoly(mainHudElements["healthOutline"])
	surface.SetDrawColor(Color(255,255,255,200))
	surface.DrawPoly(mainHudElements["healthBar"])
	surface.SetFont( "HudText-noshad" )
	surface.SetTextPos(mainHudPosition["X"] + leftX + 105 , scrHeight - 37)
	surface.SetTextColor( 0, 0, 0, 255)
	surface.DrawText( hitPoints ) //Armor
end
local dispCredit = 0
local credWid = 100
function DrawCreditCounter()
	if dispCredit != credits then
		local diff = credits - dispCredit
		dispCredit = dispCredit + math.ceil(diff/13)
	end
	local str = "Credits: " .. dispCredit
	surface.SetFont( "HudText" )
	local width, hight = surface.GetTextSize(str)
	if credWid != width then
		local diff = width - credWid + 25									
		credWid = credWid + math.ceil(diff/13)
	end
	creditHudElements["outerSquare"][2]["x"] = credWid + 15
	creditHudElements["outerSquare"][3]["x"] = credWid + 45
	creditHudElements["innerSquare"][2]["x"] = credWid
	creditHudElements["innerSquare"][3]["x"] = credWid + 25
	surface.SetDrawColor(teamCol2)
	surface.DrawPoly(creditHudElements["outerSquare"])
	surface.SetDrawColor(teamCol)
	surface.DrawPoly(creditHudElements["innerSquare"])
	
	surface.SetTextPos(creditHudElements["TextX"], creditHudElements["TextY"] )
	surface.SetTextColor( 255, 255, 255, 255)
	surface.DrawText( str ) //Armor
end

function DrawTextLocation()
	if LocalPlayer():Team()!=1 and LocalPlayer():Team()!=2 or LocalPlayer():Team()!=3 or LocalPlayer():Team()!=6 then return end
	local str = zoneTable[zone]
	local width = zoneWidths[zone]
	local TColor = Color( 0, 0, 0, 150 )
	local caps = nil
	if zone == 3 then
		caps = rigCaps

	elseif zone == 4 then
		caps = landCaps
	end
	local boxPos = MIDX-(width+45)/2
	draw.RoundedBox( 6, boxPos, TextLocationHudElements["Y"], width+45, TextLocationHudElements["BoxHeight"], TColor)
	
	if caps != nil and zone != 4 then
		local USAWidth = (width+35)/200*caps
		local USSRWidth = (width+35)/200*(200-caps)
		local captureHeight = TextLocationHudElements["Y"]+5
		local color = team.GetColor(TEAM_USA)
		color.a = 100
		
		draw.RoundedBoxEx( 6, boxPos+5 + USSRWidth, captureHeight, USAWidth, 40, color, false, true, false, true )

		color = team.GetColor(TEAM_USSR)
		color.a = 100
		draw.RoundedBoxEx( 6, boxPos+5, captureHeight, USSRWidth, 40, color, true, false, true, false)
	end
	draw.DrawText(str,"HudText",MIDX,TextLocationHudElements["TextY"],Color(255,255,255,255),TEXT_ALIGN_CENTER)
end

landCaps = 100
rigCaps = 100
usermessage.Hook("sendrigcaps", function(um)
	rigCaps = um:ReadShort()+100
end)

usermessage.Hook("sendislandcaps", function(um)
	rigCaps = um:ReadShort()+100
end)
