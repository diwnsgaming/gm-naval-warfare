local walkSpeed = 200
local runSpeed = 500
local checkPlyStamina = 0
local function isSafe(ply) 
	local filter = {ply}
	if ply:InVehicle() then
		filter[2] = ply:GetVehicle()
	end
	local pos = ply:GetShootPos()
	local traceData = {{},{},{},{},{}}
	local traceDirs =  {
		Vector(0,0,50000),Vector(50000,0,0),Vector(-50000,0,0),
		Vector(0,50000,0),Vector(0,-50000,0)
	}
	for i = 1, 5 do
		traceData[i].start = pos
		traceData[i].endpos = pos+traceDirs[i]
		traceData[i].filter = filter
		local trace = util.TraceLine(traceData[i])
		if not trace.HitNonWorld then
			ply:SetNWBool("issafe", true)
			return false
		end
	end		
	ply:SetNWBool("issafe", false)
	return true
end

local function setStamina(ply,n)
	ply.stamina = n	
	if ply.stamina != ply.oldstamina then
		if ply.stamina <= 0 then 
			ply.stamina = 0 
			ply:SetRunSpeed(walkSpeed)
		elseif ply.stamina > 100 then 
			ply.stamina = 100
		elseif ply.stamina != 0 then 
			ply:SetRunSpeed(runSpeed)
		end
		ply.oldstamina = ply.stamina
		ply:SetNWInt("stamina",ply.stamina)
	end
end

local function isSprinting(ply)
	if ply:KeyDown( IN_SPEED ) and (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) then
		return true
	end
	return false
end

local function Think()
	if checkPlyStamina >= 30 then
		local plys = player.GetAll()
		for k,ply in pairs(plys) do
			if not ply.adminMode and not ply.isAtHome and (ply:GetMoveType() != MOVETYPE_NOCLIP or ply:InVehicle()) then
				if ply:GetPos().z <= -40 and not isSafe(ply) then
					if ply.stamina > 0 then
						if(ply:InVehicle()) then
							local chair = ply:GetVehicle()
							if chair:WaterLevel() >= 3 then
								setStamina(ply,ply.stamina - 5)
							elseif chair:WaterLevel() == 2 then
								setStamina(ply,ply.stamina - 2)
							end
						else
							if ply:WaterLevel() >= 3 then
								setStamina(ply,ply.stamina - 5)
							else
								setStamina(ply,ply.stamina - 2)
							end
						end
						--if ply:InVehicle() then
						--	setStamina(ply,ply.stamina - 5)
						--end
					elseif ply:Alive() then
						ply:SetHealth( ply:Health() - 3 )
						ply:ViewPunch( Angle( -10, 0, 0 ) )
						if ply:Health() <= 0 then
							ply:Kill()
						end
					end	
				end
				if isSprinting(ply) and not ply:InVehicle() then
					if ply.stamina > 0 then
						setStamina(ply,ply.stamina-5)
					end
				end
			end
			if (ply.isAtHome or ply:GetPos().z >= -30 or isSafe(ply)) and not isSprinting(ply) then
				if ply.stamina != nil and ply.stamina < 100 then
					setStamina(ply,ply.stamina + 10)
				end
			end
		end
		checkPlyStamina = 0
	else
		checkPlyStamina = checkPlyStamina + 1
	end

end
hook.Add("Think", "navalwarfare_stamina_stuff", Think)
function playerDeath(victim, weapon, killer)
	setStamina(victim,100)
end

hook.Add( "PlayerDeath", "navalwarfare_reset_stamina", playerDeath)
local function OnPlayerAuth( ply, steamID, UID)
	checkZoneCounter[UID] = 0
	ply.isAtHome = false
	ply.stamina = 100
	ply.oldstamina = ply.stamina
	ply:SetNWInt("stamina", ply.stamina)
	ply.justJoined = true
	ply.adminMode = false
	ply.barrelCount = 0

end
hook.Add("PlayerAuthed", "NavalWarfare_PlayerAuthed", OnPlayerAuth)

function PositionalToolCheck(ply, trace, toolmode)
	if trace.HitPos then
		local plyPos = trace.HitPos
		local isInHome = false
		if plyPos:Distance(USAPos) < HarborRadius or 
			   isInBox(plyPos,USASquare[1],USASquare[2]) then 
			if ply.Zone == ZONE_USA then
				if ply:Team() == TEAM_USA then
					isInHome = true
				else
					isInHome = false
				end
			end
		elseif plyPos:Distance(USSRPos) < HarborRadius or
			   isInBox(plyPos,USSRSquare[1],USSRSquare[2]) then
			if ply.Zone == ZONE_USSR then
				if ply:Team() == TEAM_USSR then
					isInHome = true
				else
					isInHome = false
				end
			end
		elseif isInBox(plyPos,OilRigSquare[1],OilRigSquare[2]) then
			if ply.Zone == ZONE_OILRIG then
				isInHome = true
			end
		elseif plyPos:Distance(islandPos) < 4500 then
			if ply.Zone == ZONE_ISLAND then
				isInHome = true
			end
		end
		if !isInHome and !ply.adminMode then
			ply:PrintMessage( HUD_PRINTTALK, "You may not tool there")
			return false
		end
	end
end
hook.Add("CanTool", "harbor_usetoolposcheck", PositionalToolCheck)

function HEntityTakeDamage( ent, dmginfo)
	local damageamount = dmginfo:GetDamage()
	if string.find(ent:GetClass(),"harbor_") then
		dmginfo:SetDamage(0)
	end
	--ACF_Check(ent)
	if ent:Health() <= damageamount then 
		ent.wasDestroyed = true 
	end
	
end
hook.Add("EntityTakeDamage", "NavalWarfare_takedamage", HEntityTakeDamage)

local function noclipCheck( ply )
	return (ply.adminMode or ply.isAtHome) 
end
hook.Add("PlayerNoClip", "navalwarfare_noclip_check", noclipCheck)

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnObject( ply )
   Desc: Called to ask whether player is allowed to spawn any objects
-----------------------------------------------------------]]

function GM:PlayerSpawnObject( ply )
	if not ply.isAtHome and ply.Zone != ZONE_ISLAND and not ply.adminMode then
		SendHint(ply,"You are not allowed to spawn entities here!",NOTIFY_ERROR,5)
		return false
	end
	
	if ply:GetCount("prop") >= ply.attr["prop_limmit"] then
		SendHint(ply, "You've hit your prop limit!",NOTIFY_ERROR,5 )
		return false
	end
	return true
end

function GM:EntityRemoved( ent )
    local ply = ent.FPPOwner
	if ply != nil  and not ent:IsWeapon() then
		if ent.couldSpawn and not ent.wasDestroyed then
			
			--print("test")
			if ent:GetPhysicsObject():IsValid() then
				local cost = ent.cost
				if cost == nil then
					local phys = ent:GetPhysicsObject( )
					if phys:IsValid() then
						ent.cost = phys:GetVolume()/3000
					else
						cost = 100
					end
				else
					changeMoney(ply,cost,false)
				end
			end
		end
		if ent.ISTANK != nil and ent.ISTANK then
			--print(ply.barrelCount)
			ply.barrelCount = ply.barrelCount - ent.barrelCost
			ent.ISTANK = false
		end
		if ent.ISTANK == nil then
			ent.ISTANK = false
		end
	end
	self.BaseClass:EntityRemoved( ent );
	
end

--[[---------------------------------------------------------
   Name: LimitReachedProcess
   
-----------------------------------------------------------]]
local function LimitReachedProcess( ply, str )

	-- Always allow in single player
	if ( game.SinglePlayer() ) then return true end
	if ( !IsValid( ply ) ) then return true end

	local c = cvars.Number( "sbox_max"..str, 0 )
	
	if ( ply:GetCount( str ) < c || c < 0 ) then return true end 
	
	ply:LimitHit( str ) 
	return false

end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnRagdoll( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnRagdoll( ply, model )

	return LimitReachedProcess( ply, "ragdolls" )
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnProp( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnProp( ply, model )

	return LimitReachedProcess( ply, "props" )

end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnEffect( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnEffect( ply, model )

	return LimitReachedProcess( ply, "effects" )

end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnVehicle( ply, model, vname, vtable )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnVehicle( ply, model, vname, vtable )

	return LimitReachedProcess( ply, "vehicles" )
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnSWEP( ply, wname, wtable )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnSWEP( ply, wname, wtable )

	return LimitReachedProcess( ply, "sents" )	
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerGiveSWEP( ply, wname, wtable )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerGiveSWEP( ply, wname, wtable )

	return true
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnSENT( ply, name )
   Desc: Return true if player is allowed to spawn the SENT
-----------------------------------------------------------]]
function GM:PlayerSpawnSENT( ply, name )
		
	return LimitReachedProcess( ply, "sents" )	
	
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnNPC( ply, npc_type )
   Desc: Return true if player is allowed to spawn the NPC
-----------------------------------------------------------]]
function GM:PlayerSpawnNPC( ply, npc_type, equipment )

	return LimitReachedProcess( ply, "npcs" )	
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnedRagdoll( ply, model, ent )
   Desc: Called after the player spawned a ragdoll
-----------------------------------------------------------]]
function GM:PlayerSpawnedRagdoll( ply, model, ent )
if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	local cost = 0
	if not ply.adminMode then
		cost = ent:GetPhysicsObject():GetVolume()/3000
		ent.cost = cost
		if ply.Zone == ZONE_ISLAND then
			cost = cost*4
		end
	end
	if not changeMoney(ply,-cost,false) then
		ent:Remove()
		SendHint(ply,"You don't have enough credits to spawn that!", NOTIFY_ERROR, 5)
	else
		ent.couldSpawn = true
		ply:AddCount( "ragdolls", ent )
	end
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnedProp( ply, model, ent )
   Desc: Called after the player spawned a prop
-----------------------------------------------------------]]
function GM:PlayerSpawnedProp( ply, model, ent )
if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	local cost = 0
	if not ply.adminMode then
		cost = ent:GetPhysicsObject():GetVolume()/3000
		ent.cost = cost
		if ply.Zone == ZONE_ISLAND then
			cost = cost*4
		end
	end
	if model == "models/props_c17/oildrum001_explosive.mdl" or not changeMoney(ply,-cost,false) then
		ent:Remove()
		SendHint(ply,"You don't have enough credits to spawn that!", NOTIFY_ERROR, 5)

	else
		ent.couldSpawn = true
		ply:AddCount( "props", ent )
	end	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnedEffect( ply, model, ent )
   Desc: Called after the player spawned an effect
-----------------------------------------------------------]]
function GM:PlayerSpawnedEffect( ply, model, ent )
if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	local cost = 0
	if not ply.adminMode then
		cost = ent:GetPhysicsObject():GetVolume()/3000
		ent.cost = cost
		if ply.Zone == ZONE_ISLAND then
			cost = cost*4
		end
	end
	if not changeMoney(ply,-cost,false) then
		ent:Remove()
		SendHint(ply,"You don't have enough credits to spawn that!", NOTIFY_ERROR, 5)

	else
		ent.couldSpawn = true
		ply:AddCount( "effects", ent )
	end
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnedVehicle( ply, ent )
   Desc: Called after the player spawned a vehicle
-----------------------------------------------------------]]
function GM:PlayerSpawnedVehicle( ply, ent )
if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	local cost = 0
	if not ply.adminMode then
		cost = ent:GetPhysicsObject():GetVolume()/3000
		
		if ply.Zone == ZONE_ISLAND then
			cost = cost*4
		end
	end
	ent.cost = cost
	if ent:GetModel() == "models/airboat.mdl" or not changeMoney(ply,-cost,false) then
		ent:Remove()
		SendHint(ply,"You don't have enough credits to spawn that!", NOTIFY_ERROR, 5)

	else
		ent.couldSpawn = true
		ply:AddCount( "vehicles", ent )
	end
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnedNPC( ply, ent )
   Desc: Called after the player spawned an NPC
-----------------------------------------------------------]]
function GM:PlayerSpawnedNPC( ply, ent )
if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	local cost = 0
	if not ply.adminMode then
		cost = ent:GetPhysicsObject():GetVolume()/3000
		ent.cost = cost
		if ply.Zone == ZONE_ISLAND then
			cost = cost*4
		end
	end
	ent.cost = cost
	if not changeMoney(ply,-cost,false) then
		ent:Remove()
		SendHint(ply,"You don't have enough credits to spawn that!", NOTIFY_ERROR, 5)
	else
		ent.couldSpawn = true
		ply:AddCount( "npcs", ent )
	end
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnedSENT( ply, ent )
   Desc: Called after the player has spawned a SENT
-----------------------------------------------------------]]

local SENTWHITELIST = { --can contain partials
	"harbor",
	"wire",
	"balloon"
}

function GM:PlayerSpawnedSENT( ply, ent )
if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	local isWhitelist = ply.adminMode
	local class = ent:GetClass()
	if not isWhitelist then
		for k,v in pairs(SENTWHITELIST) do
			if string.find(class,v) then 
				isWhitelist = true
				break
			end
		end
		if not isWhitelist then
			ent:Remove()
			SendHint(ply,"You can't spawn that entity!",NOTIFY_ERROR,5)--?
			return false
		end
	end
	local cost = 0
	if not ply.adminMode then
		if ent.cost == nil then
			cost = ent:GetPhysicsObject():GetVolume()/3000
			ent.cost = cost
		else
			cost = ent.cost
		end
		if ply.Zone == ZONE_ISLAND then
			cost = cost*4
		end
	end
	local canSpawn = true
	ent.cost = cost
	if ent.ISTANK then
		if ent.merch != nil and ply.attr["merch_level"] >= ent.merch then
			local barrels = ents.FindByClass("harbor_oil-*")
			local count = 0
			for k,v in pairs(barrels) do
				if v.Owner == ply then
					--print("barrel")
					count = count + 1
				end
			end
			if count > ply.attr["barrel_limmit"] then
				canSpawn = false
				SendHint(ply,"You have reached your barrel limit!",NOTIFY_ERROR,5)--?
			end
		elseif ent.merch != nil then
			SendHint(ply,"Sorry, this entity requires Merchant Level "..ent.merch.."!",NOTIFY_ERROR,5)
			canSpawn = false
		end
	end
	if not canSpawn then
		ent:Remove()
	elseif not changeMoney(ply,-cost,false) then
		ent:Remove()
		SendHint(ply,"You don't have enough credits to spawn that!", NOTIFY_ERROR, 5)
	else
		ent.couldSpawn = true
		ply:AddCount( "sents", ent )
	end
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnedWeapon( ply, ent )
   Desc: Called after the player has spawned a Weapon
-----------------------------------------------------------]]
function GM:PlayerSpawnedSWEP( ply, ent )
if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	if not ply.adminMode then
		ent:Remove()
		SendHint(ply,"You're not allowed to spawn SWEPS", NOTIFY_ERROR, 5)
	else
		ply:AddCount( "sents", ent )
	end
end

--[[---------------------------------------------------------
   Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
-----------------------------------------------------------]]
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	-- More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( 3 )
	 
	 end
	 
	-- Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_RIGHTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.5 )
	 
	 end

end


--[[---------------------------------------------------------
   Name: gamemode:PlayerEnteredVehicle( player, vehicle, role )
   Desc: Player entered the vehicle fine
-----------------------------------------------------------]]
function GM:PlayerEnteredVehicle( player, vehicle, role )

	player:SendHint( "VehicleView", 2 )

end

--[[---------------------------------------------------------
	These are buttons that the client is pressing. They're used
	in Sandbox mode to control things like wheels, thrusters etc.
-----------------------------------------------------------]]
function GM:PlayerButtonDown( ply, btn ) 

	numpad.Activate( ply, btn )

end

--[[---------------------------------------------------------
	These are buttons that the client is pressing. They're used
	in Sandbox mode to control things like wheels, thrusters etc.
-----------------------------------------------------------]]
function GM:PlayerButtonUp( ply, btn ) 

	numpad.Deactivate( ply, btn )

end

function InitialSpawn( ply )
	if ply.justJoined then
		umsg.Start("draw_RULES",ply)
			umsg.Bool(not ply.firstJoin)
		umsg.End()
		umsg.Start("draw_MOTD",ply)
			umsg.Bool(not ply.firstJoin)
		umsg.End()
		ply.justJoined = false
	end
end
hook.Add( "PlayerSpawn", "navalwarfare_FirstSpawn", InitialSpawn)

local function nextPrint(ply,mType,message)
	timer.Simple(0,function() ply:PrintMessage(mType,message) end )


end

local function getTarget(s)
	s = string.lower(s)
	local recip = nil
	local moreThanOne = false
	for k,v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()),s) then
			if recip == nil then
				recip = v
			else
				moreThanOne = true
			end
		end
	end
	if moreThanOne then recip = nil end
	return recip
end

local function investigate(ply, command, arguments)
	if ply.adminMode then
		local allents = ents.GetAll()
		local allplayers = player.GetAll()
		local alldata = {}
		local allc = {}
		local totalprops = 0
		local accountedprops = 0
		for k, v in pairs(allents) do
			if v:GetClass() == "prop_physics" then
				totalprops = totalprops + 1
				if v.FPPOwner != nil and v.FPPOwner:IsValid() then
					local index = v.FPPOwner:Nick()
					if alldata[index] == nil then alldata[index] = 0 end
					alldata[index] = alldata[index] + 1
					if allc[index] == nil then allc[index] = 0 end
					allc[index] = allc[index] + table.Count(constraint.FindConstraints( v, "Weld" ))
					allc[index] = allc[index] + table.Count(constraint.FindConstraints( v, "Rope" ))
					allc[index] = allc[index] + table.Count(constraint.FindConstraints( v, "Elastic" ))
				end
			end
		end
		ply:PrintMessage( HUD_PRINTTALK, "Investigating laggy server!" )
		ply:PrintMessage( HUD_PRINTTALK, "TotalPlayers: "..table.Count(allplayers) )
		ply:PrintMessage( HUD_PRINTTALK, "TotalProps: "..totalprops )
		ply:PrintMessage( HUD_PRINTTALK, "TotalPlayersLogged: "..table.Count(alldata) )
		ply:PrintMessage( HUD_PRINTTALK, "*****************************************")
		for k, v in pairs(alldata) do
			accountedprops = accountedprops + alldata[k]
			ply:PrintMessage( HUD_PRINTTALK, k..":				"..alldata[k]..":"..allc[k])
		end
		ply:PrintMessage( HUD_PRINTTALK, "*****************************************")
		ply:PrintMessage( HUD_PRINTTALK, "TotalPropsAccounted: "..accountedprops )
	end
end
concommand.Add( "in", investigate )
function toggleAdminMode(ply)
	if ply:IsAdmin() then
		local tog = "OFF"
		ply.adminMode = not ply.adminMode
		if ply.adminMode then
			ply.HoldTeam = ply:Team()
			tog = "ON"
			ply:Give( "weapon_physgun" )
			ply:SetTeam(6)
		else
			ply:SetTeam(ply.HoldTeam)
		end
		ColorizePlayer(ply, _, _)

		ply:SetNWBool("adminmode", ply.adminMode)
		ply:SetNWInt("holdteam", ply.HoldTeam)
	end
end

local function consoletoggleadminmode(ply, command, arguments)
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			nextPrint(v, HUD_PRINTTALK, "Admin "..ply:Nick().." has toggled admin mode ")
		end
	end
	toggleAdminMode(ply)
end
concommand.Add( "am", consoletoggleadminmode )

function chatStuff( ply, text,isPublic, livlihood )
	local args = string.Explode(" ",text)
	if string.lower(args[1]) == "!sug" then
		table.remove(args,1)
		--Suggestions = {}
		Suggestions[#Suggestions+1] = {ply:Nick(),table.concat(args," ")}
		file.Write("navalwarfare/suggestions.txt", von.serialize(Suggestions))
		--nextPrint(ply,HUD_PRINTTALK,"Thank you for your suggestion!\n") --Type \"!getsugs\" to view all suggestions")
	elseif string.lower(args[1]) == "!givemoney" then
		
		local money = tonumber(args[3])
		local tar = getTarget(args[2])
		if money!=nil and money > 0 then
			if ply.attr["monney"] >= money or ply.adminMode then 
				if tar != nil then
					if not ply.adminMode then
						changeMoney(ply,-money,false)
					end
					changeMoney(tar,money,false)
					nextPrint(ply, HUD_PRINTTALK, "Gave "..tar:Nick().." "..tostring(money).." credits!")
					nextPrint(tar, HUD_PRINTTALK, ply:Nick().." gave you "..tostring(money).." credits!")
				
				else
					nextPrint(ply, HUD_PRINTTALK, "No suitable player found.  Be more specific, or correct the name")
				end
			else				
				nextPrint(ply, HUD_PRINTTALK, "You don't have enough money to do that!")
			end
		else
			nextPrint(ply, HUD_PRINTTALK, "You must enter a value greater than zero.")
		end
	elseif string.lower(args[1]) == "!setmoney" then
		local tar = getTarget(args[2])
		local money = tonumber(args[3])
		if ply.adminMode then
			changeMoney(tar,money,false)
		end
	elseif string.lower(args[1]) == "!motd" then
		umsg.Start("draw_MOTD",ply)
		umsg.Bool(true)
		umsg.End()
		print("MOTD")
	elseif string.lower(args[1]) == "!rules" then
		umsg.Start("draw_RULES",ply)
		umsg.Bool(true)
		umsg.End()
		print("MOTD")
	end
end
hook.Add( "PlayerSay", "navalplay_chatCommands", chatStuff)

local function playerKill( vic, wep, kil )
	if vic:IsPlayer() and kil:IsPlayer() then 
		if vic:Team() != kil:Team() then 
			changeMoney(kil,100,true)
		end
	end
end
hook.Add( "PlayerDeath", "navalwarfare_playerkill", playerKill )

function SendHint(ply,text,kind, length)
	ply:SendLua("GAMEMODE:AddNotify(\""..text.."\","..tostring(kind)..","..tostring(length)..")")
end


function playershouldtakedamage(victim, attacker)
	print("NWDamage: "..attacker:GetClass().."->"..victim:GetClass())
	if victim.adminMode then
		return false
	elseif attacker:GetClass()=="player" and victim:GetClass()=="player" then
		if attacker:Team()==victim:Team() then
			return false
		end
	elseif attacker:GetClass()=="prop_physics" and victim.isAtHome then
		return false
	elseif attacker:GetClass()=="worldspawn" and victim.isAtHome then
		--print("FA:SE")
		return false
	end
end
 
hook.Add( "PlayerShouldTakeDamage", "playershouldtakedamage", playershouldtakedamage)
 