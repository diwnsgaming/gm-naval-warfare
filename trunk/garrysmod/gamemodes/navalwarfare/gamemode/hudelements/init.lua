AddCSLuaFile( "cl_alwaysdraw.lua" )
AddCSLuaFile( "cl_animated.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_motd.lua" )
AddCSLuaFile( "cl_sometimesdraw.lua" )
AddCSLuaFile( "cl_3d.lua" )

local function navalwarfareGravPickup( ply, ent )
	if ent.IsPlug != nil and ent.IsPlug then
		umsg.Start( "CreatePlugs", ply )
		umsg.End()
	end
	return canTouch
end
hook.Add("GravGunOnPickedUp", "navalwarfare_plugdraw", navalwarfareGravPickup)
function gravDrop(ply,ent)
	if ent.IsPlug != nil and ent.IsPlug then
		umsg.Start( "DestroyPlugs", ply );
		umsg.End();
	end
end
hook.Add( "GravGunOnDropped", "navalwarfare_plugundraw", gravDrop)

