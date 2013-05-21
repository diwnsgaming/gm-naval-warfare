include( 'shared.lua' )
include( 'cl_spawnmenu.lua' )
include( 'cl_notice.lua' )
include( 'cl_hints.lua' )
include( 'cl_worldtips.lua' )
include( 'cl_search_models.lua' )
include( 'gui/IconEditor.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_captureisland.lua' )
include( 'cl_capturerig.lua' )
include( 'hudelements/cl_init.lua' )
include( 'cl_npcmenu.lua' )

DEFINE_BASECLASS( "gamemode_base" )


local physgun_halo = CreateConVar( "physgun_halo", "1", { FCVAR_ARCHIVE }, "Draw the physics gun halo?" )

function GM:Initialize()

	BaseClass.Initialize( self )
	
end

function GM:LimitHit( name )

	self:AddNotify( "#SBoxLimit_"..name, NOTIFY_ERROR, 6 )
	surface.PlaySound( "buttons/button10.wav" )

end

function GM:OnUndo( name, strCustomString )
	if ( !strCustomString ) then
		self:AddNotify( "#Undone_"..name, NOTIFY_UNDO, 2 )
	else	
		self:AddNotify( strCustomString, NOTIFY_UNDO, 2 )
	end
	surface.PlaySound( "buttons/button15.wav" )
end

function GM:OnCleanup( name )
	self:AddNotify( "#Cleaned_"..name, NOTIFY_CLEANUP, 5 )
	surface.PlaySound( "buttons/button15.wav" )
end

function GM:UnfrozeObjects( num )
	self:AddNotify( "Unfroze "..num.." Objects", NOTIFY_GENERIC, 3 )
	surface.PlaySound( "npc/roller/mine/rmine_chirp_answer1.wav" )
end

--[[---------------------------------------------------------
	Draws on top of VGUI..
-----------------------------------------------------------]]
function GM:PostRenderVGUI()
	BaseClass.PostRenderVGUI( self )
end

local PhysgunHalos = {}

--[[---------------------------------------------------------
   Name: gamemode:DrawPhysgunBeam()
   Desc: Return false to override completely
-----------------------------------------------------------]]
function GM:DrawPhysgunBeam( ply, weapon, bOn, target, boneid, pos )
	if ( physgun_halo:GetInt() == 0 ) then return true end
	
	if ( IsValid( target ) ) then
		PhysgunHalos[ ply ] = target
	end
	return true
end

hook.Add( "PreDrawHalos", "AddPhysgunHalos", function()
	if ( !PhysgunHalos || table.Count( PhysgunHalos ) == 0 ) then return end

	for k, v in pairs( PhysgunHalos ) do
		if ( !IsValid( k ) ) then continue end

		local size = math.random( 1, 2 )
		local colr = k:GetWeaponColor() + VectorRand() * 0.3

		effects.halo.Add( PhysgunHalos, Color( colr.x * 255, colr.y * 255, colr.z * 255 ), size, size, 1, true, false )
	end

	PhysgunHalos = {}
end )


--[[---------------------------------------------------------
   Name: gamemode:NetworkEntityCreated()
   Desc: Entity is created over the network
-----------------------------------------------------------]]
function GM:NetworkEntityCreated( ent )
	if ( ent:GetSpawnEffect() && ent:GetCreationTime() > (CurTime() - 1.0) ) then
		local ed = EffectData()
			ed:SetEntity( ent )
		util.Effect( "propspawn", ed, true, true )
	end
end



