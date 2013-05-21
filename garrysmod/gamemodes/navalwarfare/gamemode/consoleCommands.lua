
function consoleSetOil( ply, com, args)
	if ply.adminMode then
		setMoney(args[1],val)
	end
end
concommand.Add("navalwarfare_setmoney",sellOil)

function updateHealth( ply, com, args)
	ent = Entity(tonumber(args[1]))
	if ent.NWHealth == nil or ent.NWHealth == 0 then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	ent:SetNWInt("NWHealth", ent.NWHealth)
end
concommand.Add("nw_uph",updateHealth)

function joinPirateTeam(ply, com, args)
	if args[1] == ply.validation then
		ply:SetTeam(TEAM_PIRATE)
		ply:SetPos(Vector(-5910,-8800, 1))
		ply:SetEyeAngles((Angle(0,90,0)))
		ColorizePlayer(ply, _, _)
		ply:Give( "gmod_tool" )
		ply:Give( "weapon_crowbar" )
		ply:SetModel("models/player/police.mdl")
	else
		print(args[1])
	end
end
concommand.Add("navalwarfare_beapirate", joinPirateTeam)

function sellOil( ply, com, args)
	if ply.validation==args[3] then
		price = tonumber(args[1])
		changeMoney(ply, price, true)
		print(ply:Nick().." sold his oil for "..price.." credits!")
		--for k,v in pairs(ply.inRangeBarrels) do
			Entity(tonumber(args[2])).Oil = Entity(tonumber(args[2])).Oil-tonumber(args[1])
		--end
	else
		print(ply:Nick().." attempted to sell oil with an incorrect validation key.  Is he trying to cheat?")
	end
end
concommand.Add("navalwarfare_sellOil",sellOil)

local usaguns = { 
	["weapon_357"]			= 250,
	["weapon_ar2"] 			= 200,
	["weapon_frag"]			= 50,
	["weapon_pistol"]		= 100,
	["weapon_smg1"]			= 150,
	["weapon_shotgun"]		= 150
}
local ussrguns = { 
	["weapon_357"]			= 250,
	["weapon_ar2"] 			= 200,
	["weapon_frag"]			= 50,
	["weapon_pistol"]		= 100,
	["weapon_smg1"]			= 150,
	["weapon_shotgun"]		= 150
}
local usagunsammo = { 
	["AR2"]			= 2,
	["Pistol"] 		= 0.5,
	["SMG1"] 		= 2,
	["357"]			= 5,
	["Buckshot"]	= 5,
	["Grenade"]		= 50
}
local ussrgunsammo = { 
	["AR2"]			= 2,
	["Pistol"] 		= 0.5,
	["SMG1"] 		= 2,
	["357"]			= 5,
	["Buckshot"]	= 5,
	["Grenade"]		= 50
}
function buyGun( ply, com, args)
	if ply.validation==args[2] then
		local team = ply:Team()
		if team==1 then
			local price = ussrguns[args[1]]
			if changeMoney(ply, -price, false) then
				print(ply:Nick().." bought a gun for "..price.." credits!")
				local gun = ply:Give( args[1] )
				ply:GiveAmmo(ussrgunsammo[args[1]], gun:GetPrimaryAmmoType())
			else
				ply:SendHint("You don't have enough money for that!",5)
			end
		elseif team==2 then
			local price = usaguns[args[1]]
			print(usaguns[args[1]])
			if changeMoney(ply, -price, false) then
				print(ply:Nick().." bought a gun for "..price.." credits!")
				local gun = ply:Give( args[1] )
				if gun:IsValid() then
					ply:GiveAmmo(usagunsammo[args[1]], gun:GetPrimaryAmmoType())
				end
			else
				ply:SendHint("You don't have enough money for that!",5)
			end
		end
	else
		print(ply:Nick().." attempted to buy guns with an incorrect validation key.  Is he trying to cheat?")
	end
end
concommand.Add("navalwarfare_buygun",buyGun)

local ammo = { 
	["AR2"]			= 2,
	["Pistol"] 		= 0.5,
	["SMG1"] 		= 2,
	["357"]			= 5,
	["Buckshot"]	= 5,
	["Grenade"]		= 50
}

function buyammo( ply, com, args)
	if ply.validation==args[3] then
		local price = ammo[args[1]]*tonumber(args[2])
		if changeMoney(ply, -price, false) then
			print(ply:Nick().." bought ammo for "..price.." credits!")
			ply:GiveAmmo( tonumber(args[2]),	args[1], 		true )
		else
			ply:SendHint("You don't have enough money for that!",5)
		end
	else
		print(ply:Nick().." attempted to buy ammo with an incorrect validation key.  Is he trying to cheat?")
	end
end
concommand.Add("navalwarfare_buyammo",buyammo)

function buycurrentammo( ply, com, args)
	if ply.validation==args[2] then
		local wep = ply:GetActiveWeapon()
		local ammotype = wep:GetPrimaryAmmoType()
		local price = ammo[ammotype]*tonumber(args[1])
		if changeMoney(ply, -price, false) then
			print(ply:Nick().." bought ammo for "..price.." credits!")
			ply:GiveAmmo( tonumber(args[1])+1,	ammotype, 		true )
		else
			ply:SendHint("You don't have enough money for that!",5)
		end
	else
		print(ply:Nick().." attempted to buy ammo with an incorrect validation key.  Is he trying to cheat?")
	end
end
--concommand.Add("navalwarfare_buycurrentammo",buycurrentammo)

function buyupgrade( ply, com, args)
	local upNum = tonumber(args[1])
	if ply.validation==args[2] then
		if Upgrades[upNum][5](ply) then
			local price = Upgrades[upNum][4](ply)
			if changeMoney(ply, -price, false) then
				print(ply:Nick().." bought upgrade "..Upgrades[upNum][1].." for "..price.." credits!")
				ply.attr[Upgrades[upNum][3]] = ply.attr[Upgrades[upNum][3]] + 1
				ply:SetNWInt(Upgrades[upNum][3],ply.attr[Upgrades[upNum][3]])
				savePlayerData(ply)
				--SendUpgrades(NPC_UPGRADES,ply)
			else
				ply:SendHint("You don't have enough money for that!",5)
			end
		else
			ply:SendHint("You're already at the max level!",5)
		end	
			
	else
		print(ply:Nick().." attempted to buy upgrades with an incorrect validation key.  Is he trying to cheat?")
	end
end
concommand.Add("navalwarfare_buyupgrade",buyupgrade)


local function getNewKey(ply, com, args)
	ply.validation = GetValidationString()
end
concommand.Add("navalwarfare_generateNewKey",getNewKey)

function sendHint( ply, com, args)
	ply:SendHint(args[1],5)
end
concommand.Add("navalwarfare_sendmeahint",sendHint)

local function drawNewFaggot(ply, com, args)
	if ply:IsAdmin() then
		--print("derp")
		local pl = nil
		for k,v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()),string.lower(args[1])) then
				pl = v
			end		
		end
		if pl != nil then
			--print("making faggot")
			ply:PrintMessage( HUD_PRINTTALK, "You made a faggot!")
			pl:SetNWBool("faggot",true)
			pl:SetNWString("faggotText",args[2])
		end
	end
end
concommand.Add("addFaggot",drawNewFaggot)

local function removeOldFaggot(ply, com, args)
	if ply:IsAdmin() then
		--print("derp")
		local pl = nil
		for k,v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Nick()),string.lower(args[1])) then
				pl = v
			end		
		end
		if pl != nil then
			--print("making faggot")
			ply:PrintMessage( HUD_PRINTTALK, "You removed a faggot!")
			pl:SetNWBool("faggot",false)
			pl:SetNWString("faggotText",args[2])
		end
	end
end
concommand.Add("removeFaggot",removeOldFaggot)
