--[[---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

-----------------------------------------------------------]]
-- These files get sent to the client




AddCSLuaFile( "cl_hints.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_notice.lua" )
AddCSLuaFile( "cl_search_models.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "cl_worldtips.lua" )
AddCSLuaFile( "cl_npcmenu.lua" )
AddCSLuaFile( "hudelements/cl_init.lua")
AddCSLuaFile( "persistence.lua" )
AddCSLuaFile( "player_extension.lua" )
AddCSLuaFile( "save_load.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "gui/IconEditor.lua" )

AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_captureisland.lua" )
AddCSLuaFile( "cl_capturerig.lua" )

include( 'hudelements/init.lua' )
include( 'consoleCommands.lua' )
include( 'download.lua' )
include( 'shared.lua' )
include( 'commands.lua' )
include( 'player.lua' )
include( 'spawnmenu/init.lua' )
include( 'spawnworld.lua' )
include( 'captureisland.lua' )
include( 'capturerig.lua' )
include( 'zones.lua' )
include( 'playerAttributes.lua' )
include( 'weaponspecialcases.lua' )

DEFINE_BASECLASS( "gamemode_base" )

function ColorizePlayer( ply, com, args)
	local PlayerTeam = ply:Team()
	local tc = team.GetColor(PlayerTeam)
	if ply.adminMode then tc = Color(0,255,0,255) end -- this can be removed, admins have thier own team now.
	local Colory = Vector(tc.r,tc.g,tc.b)
	Colory:Normalize()
	ply:SetPlayerColor(Colory)
end
--concommand.Add("updatecolor",ColorizePlayer)
--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( pl )
	player_manager.SetPlayerClass( pl, "player_sandbox" )
	BaseClass.PlayerSpawn( self, pl )
	if(pl:Team() == TEAM_USA) then
		pl:SetPos(USA_SPAWNPOS)
		pl:Give( "gmod_tool" )
		pl:Give("weapon_stunstick")
	elseif(pl:Team() == TEAM_USSR) then
		pl:SetPos(USSR_SPAWNPOS)
		pl:Give( "gmod_tool" )
		pl:Give("weapon_crowbar")
	elseif(pl:Team() == TEAM_PIRATE) then
		pl:SetPos(PIRATE_SPAWNPOS)
		pl:Give( "gmod_tool" )
		pl:Give("weapon_crowbar")
		pl:Give("weapon_shotgun")
		pl:GiveAmmo(1000, "Buckshot", true)
	end
	pl.HoldTeam = pl:Team()
	ColorizePlayer(pl, _, _)
end

function GM:PlayerSetModel( ply )
	if(ply:Team() == TEAM_USSR) then
		local Randomness = math.random(1, 9)
		ply:SetModel("models/player/group03/male_0"..tostring(Randomness)..".mdl")
	elseif(ply:Team() == TEAM_USA) then
		local Randomness = math.random(1, 4)
		if Randomness == 1 then ply:SetModel("models/player/police.mdl") end
		if Randomness == 2 then ply:SetModel("models/player/combine_soldier_prisonguard.mdl") end
		if Randomness == 3 then ply:SetModel("models/player/combine_super_soldier.mdl") end
		if Randomness == 4 then ply:SetModel("models/player/combine_soldier.mdl") end
	end
end

function PlayerTeamChange( ply, oldteam, newteam )
	ColorizePlayer(ply, _, _)
end
hook.Add("OnPlayerChangedTeam", "navalwarfare_changeteam", PlayerTeamChange)

function ShouldCollider(entity1, entity2)
	if entity1:GetClass() == "harbor_projectile" or entity2:GetClass() == "harbor_projectile" then
		return true
	end
end
hook.Add("ShouldCollide", "HAR", ShouldCollider)

--[[---------------------------------------------------------
   Name: gamemode:OnPhysgunFreeze( weapon, phys, ent, player )
   Desc: The physgun wants to freeze a prop
-----------------------------------------------------------]]
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	
	-- Don't freeze persistent props (should already be froze)
	if ( ent:GetPersistent() ) then return false end

	BaseClass.OnPhysgunFreeze( self, weapon, phys, ent, ply )

	ply:SendHint( "PhysgunUnfreeze", 0.3 )
	ply:SuppressHint( "PhysgunFreeze" )
	
end


--[[---------------------------------------------------------
   Name: gamemode:OnPhysgunReload( weapon, player )
   Desc: The physgun wants to unfreeze
-----------------------------------------------------------]]
function GM:OnPhysgunReload( weapon, ply )

	local num = ply:PhysgunUnfreeze()
	
	if ( num > 0 ) then
		ply:SendLua( "GAMEMODE:UnfrozeObjects("..num..")" )
	end

	ply:SuppressHint( "PhysgunReload" )

end


--[[---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
   Note: This is a shared function - the client will think they can 
	 damage the players even though they can't. This just means the 
	 prediction will show blood.
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, attacker )
	
	-- Global godmode, players can't be damaged in any way
	if ( cvars.Bool( "sbox_godmode", false ) ) then return false end
	
	-- No player vs player damage
	if (attacker:IsPlayer() and attacker:Team()==ply:Team() ) then
		return false
	end
	-- Default, let the player be hurt
	return true

end


--[[---------------------------------------------------------
   Show the search when f1 is pressed
-----------------------------------------------------------]]
function GM:ShowHelp( ply )

	ply:SendLua( "hook.Run( 'StartSearch' )" );
	
end


--[[---------------------------------------------------------
   Called once on the player's first spawn
-----------------------------------------------------------]]
function GM:PlayerInitialSpawn( ply )

	BaseClass.PlayerInitialSpawn( self, ply )
	ply:SetTeam(TEAM_SPAWN)
	print("Added "..ply:Name().." to team spawn room")
end


--[[---------------------------------------------------------
   Desc: A ragdoll of an entity has been created
-----------------------------------------------------------]]
function GM:CreateEntityRagdoll( entity, ragdoll )

	-- Replace the entity with the ragdoll in cleanups etc
	undo.ReplaceEntity( entity, ragdoll )
	cleanup.ReplaceEntity( entity, ragdoll )
	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerUnfrozeObject( )
-----------------------------------------------------------]]
function GM:PlayerUnfrozeObject( ply, entity, physobject )

	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
		effectdata:SetEntity( entity )
	util.Effect( "phys_unfreeze", effectdata, true, true )	
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerFrozeObject( )
-----------------------------------------------------------]]
function GM:PlayerFrozeObject( ply, entity, physobject )

	if ( DisablePropCreateEffect ) then return end
	
	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
		effectdata:SetEntity( entity )
	util.Effect( "phys_freeze", effectdata, true, true )	
	
end


--
-- Who can edit variables?
-- If you're writing prop protection or something, you'll
-- probably want to hook or override this function.
--
function GM:CanEditVariable( ent, ply, key, val, editor )

	-- Only allow admins to edit admin only variables!
	if ( editor.AdminOnly ) then
		return ply:IsAdmin()
	end

	-- This entity decides who can edit its variables
	if ( isfunction( ent.CanEditVariables ) ) then
		return ent:CanEditVariables( ply )
	end

	-- default in sandbox is.. anyone can edit anything.
	return true

end
isRestarting = false
function serverRestart(delay,lol,lol2)
	if lol2 then isRestarting = true end
	if isRestarting then
		local faggot = "minutes"
		if not lol then
			faggot = "seconds"
		end
		for k,v in pairs(player.GetAll()) do 
			v:PrintMessage(HUD_PRINTCENTER,"Server restart in "..delay.." "..faggot)	
		end
		delay = delay - 1
		if delay == 1 and lol then
			delay = 60
			lol = false
		elseif delay == 1 and not lol then
			game.ConsoleCommand("map habor2ocean_nw1")
		end
		local timeD = 10
		if lol then 
			timeD = 60
		end
		timer.Simple(timeD,function() serverRestart(delay,lol,false) end)
	end
end
local NoDrop = {
	"weapon_physcannon",
	"weapon_crowbar",
	"gmod_tool",
	"gmod_camera",
	"weapon_physgun",
	"weapon_sim_spade",
}	
local function DropWep(ply)
	if(ply:GetActiveWeapon():IsValid()) then
		local shouldDrop = false
		local weapon = ply:GetActiveWeapon():GetClass()
		for k,wep in pairs(NoDrop) do
			if wep == weapon then
				shouldDrop = true
				break
			end
		end
		if !shouldDrop then
			ply:DropWeapon(ply:GetActiveWeapon())
		end
	end
	if ply.adminMode then
		toggleAdminMode(ply)
	end
	ply.lastZone=nil
end
hook.Add("DoPlayerDeath", "NavalWarfare_dropweps", DropWep)
concommand.Add("harbor_dropweapon", DropWep)