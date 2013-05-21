function payDay(isCaptured)
	if not isCaptured then
		for k,v in pairs(player.GetAll()) do
			local pay = 10
			changeMoney(v,pay,false)
			v:PrintMessage( HUD_PRINTTALK, "You have recieved "..pay.." credits for your service!")	
		end
	else
		for k,v in pairs(player.GetAll()) do
			if v:Team() == CapturedBy then
				pay = (#player.GetAll()-1)*50
				changeMoney(v,pay,false)
				v:PrintMessage( HUD_PRINTTALK, "You have recieved "..pay.." credits for holding the island!")	
			else
				v:PrintMessage( HUD_PRINTTALK, "Warning! The other team recieved "..pay.." credits each for having captured the island.")
			end
		end
	end
end

function Init_Vars()
	USA_SPAWNPOS = Vector(15777, -15725, 1)
	USSR_SPAWNPOS = Vector(-15779, 15719, 1)
	PIRATE_SPAWNPOS = Vector(-5910,-8800, 1)
	
	if(not file.IsDir("navalwarfare","DATA")) then
		file.CreateDir("navalwarfare","DATA")
	end
	if(not file.IsDir("navalwarfare/playerData","DATA")) then
		file.CreateDir("navalwarfare/playerData","DATA")
	end
	
	USSRSquare = {Vector(-13310,13819,-200),Vector(-10285,16000,980)}
	USASquare = {Vector(10285,-16000,980),Vector(13310,-13819,-200)}

	USSRPos = Vector(-16000,16000,0)
	USAPos = Vector(16000,-16000,0)

	HarborRadius = 4600

	OilRigSquare = {Vector(7700,7800,-1500),Vector(10500,10800,2000)}

	islandPos = Vector(-7295.541504, -8403.884766, 520.271362)

	ZONE_NEUTRAL = 0
	ZONE_USA = 1
	ZONE_USSR = 2
	ZONE_OILRIG = 3
	ZONE_ISLAND = 4
	checkZoneCounter = {}

	timer.Create("navalplay_payday",600,0,function() payDay(false) end)
	
	if not file.Exists("navalwarfare/suggestions.txt", "DATA") then
		file.Write("navalwarfare/suggestions.txt", "")
	end
	Suggestions = von.deserialize(file.Read("navalwarfare/suggestions.txt", "DATA"))
end
hook.Add( "Initialize", "navalwarfare_zonesinit", Init_Vars );


local checkZones = 0
local function PlayerMove()
	local players = player.GetAll()
	if checkZones > 100 then
		for k,ply in pairs(players) do
			
			local plyPos = ply:GetPos()
			if plyPos:Distance(USAPos) < HarborRadius or 
			   isInBox(plyPos,USASquare[1],USASquare[2]) then 
			   if ply.Zone != ZONE_USA then
					ply.Zone = ZONE_USA
					if ply:Team() == TEAM_USA then
						ply:PrintMessage( HUD_PRINTTALK, "Welcome to the USA harbor!")	
						ply.isAtHome = true
						if not ply:HasWeapon( "weapon_physgun" ) then
							ply:Give( "weapon_physgun" )
						end
					else
						ply:PrintMessage( HUD_PRINTTALK, "Warning! You are entering the USA harbor!")	
						ply.isAtHome = false	
					end
				end
			elseif plyPos:Distance(USSRPos) < HarborRadius or
			   isInBox(plyPos,USSRSquare[1],USSRSquare[2]) then
				if ply.Zone != ZONE_USSR then
					ply.Zone = ZONE_USSR
					if ply:Team() == TEAM_USSR then
						ply:PrintMessage( HUD_PRINTTALK, "Welcome to the USSR harbor!")	
						ply.isAtHome = true	
						if not ply:HasWeapon( "weapon_physgun" ) then
							ply:Give( "weapon_physgun" )
						end
					else
						ply:PrintMessage( HUD_PRINTTALK, "Warning! You are entering the USSR harbor!")	
						ply.isAtHome = false	
					end
				end
			elseif isInBox(plyPos,OilRigSquare[1],OilRigSquare[2]) then
				if ply.Zone != ZONE_OILRIG then
					ply:PrintMessage( HUD_PRINTTALK, "Arriving at the Oil Rig.")	
					ply.Zone = ZONE_OILRIG
					ply.isAtHome = false
					
				end
			elseif (plyPos - islandPos):LengthSqr() < 25000000 then --4500 for capture point useage
				if ply.Zone != ZONE_ISLAND then
					ply:PrintMessage( HUD_PRINTTALK, "Arriving at Copperhead Island.")				
					ply.Zone = ZONE_ISLAND
					if ply:Team() == TEAM_PIRATE then
						ply.isAtHome = true
					else
						ply.isAtHome = false
					end
					if not ply:HasWeapon( "weapon_physgun" ) then
						ply:Give( "weapon_physgun" )
					end
				end
			else
				if ply.Zone == ZONE_USA then
					ply:PrintMessage( HUD_PRINTTALK, "Now leaving the USA harbor.")	
					ply.isAtHome = false
					
				elseif ply.Zone == ZONE_USSR then
					ply:PrintMessage( HUD_PRINTTALK, "Now leaving the USSR harbor.")	
					ply.isAtHome = false
					
				elseif ply.Zone == ZONE_OILRIG then
					ply:PrintMessage( HUD_PRINTTALK, "Now leaving the Oil Rig.")
					ply.isAtHome = false
					
				elseif ply.Zone == ZONE_ISLAND then
					ply:PrintMessage( HUD_PRINTTALK, "Now leaving Copperhead Island.")
					ply.isAtHome = false
					
				end
				if ply:GetMoveType() == MOVETYPE_NOCLIP and not ply.adminMode and !ply.IsAtHome then
					ply:SetMoveType( MOVETYPE_WALK )
				end
				ply.Zone = ZONE_NEUTRAL
			end
			if ply.lastZone==nil or ply.Zone != ply.lastZone then 
				ply:SetNWBool("ishome", ply.isAtHome)
				ply:SetNWInt("zone", ply.Zone)
				if not ply.isAtHome and ply.Zone != ZONE_ISLAND and not ply.adminMode then
					ply:StripWeapon( "weapon_physgun" )
				end
				ply.lastZone = ply.Zone
			end
			ply.previousPos = plyPos

		end
		checkZones = 0
	end
	for k,ply in pairs(players) do 
		if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_FLY then
			--I looked at old methods, and they used MOVETYPE_FLY, but garry changed it
			--MOVETYPE_FLY is just retarded now.
			local pos = ply:GetShootPos()
			if ply.previousPos == nil then ply.previousPos = pos end
			local tracedata = {}
			tracedata.start = pos
			tracedata.endpos = ply:GetVelocity()/20+ pos --make the divisor bigger to check a shorter distance
			local filter = player.GetAll()
			tracedata.filter = filter
			local trace = util.TraceLine(tracedata)
			if trace.HitWorld then
				timer.Simple(0,function()
					if(ply.previousPos != nil) then
						ply:SetPos(ply.previousPos) --previous pos is set every zone check (100 movements)
					end
				end)
			end
		end
	end
	checkZones = checkZones + 1
end
hook.Add("Think", "NavalWarfare_movement", PlayerMove)

function isInBox(self,boxMin, boxMax)
	if self.x >= boxMin.x and 
	   self.y >= boxMin.y and
	   self.x <= boxMax.x and
	   self.y <= boxMax.y then	   
		return true
	end
	return false
end
