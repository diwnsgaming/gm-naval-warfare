
function SpawnEntity(class, model, pos, angle)
	local ent = ents.Create(class) -- This creates our zombie entity
	ent:SetPos(pos) -- This positions the zombie at the place our trace hit.
	ent:SetAngles(angle)
	ent:SetModel(model)
	ent:Spawn()
	ent:GetPhysicsObject():EnableMotion(false)
	ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	if(IsValid(ent)) then
		print(ent)
	end
	return ent
end
function Init_SpawnEntities()
	
	--SpawnRoom entities
	local ussr = SpawnEntity("harbor_ussrspawn", "models/hunter/blocks/cube2x3x025.mdl", Vector(4200, -4200, 5950), Angle(0,45,90)):SetMaterial("Models/effects/vol_light001")
	local usa = SpawnEntity("harbor_usaspawn", "models/hunter/blocks/cube2x3x025.mdl", Vector(4500, -4500, 5950), Angle(0,45,90)):SetMaterial("Models/effects/vol_light001")
	--NADMOD.SetOwnerWorld(ussr)
	--NADMOD.SetOwnerWorld(usa)
	--other
	SpawnEntity("harbor_main", "models/props_pipes/pipe03_connector01.mdl", Vector(9216.722656, 9215.520508, 2064.031250), Angle(0,0,0)):SetMaterial("Models/effects/vol_light001") -- Oil Rig Plugs and Main
	SpawnEntity("harbor_oiltransfer", "models/props_lab/tpplugholder_single.mdl", Vector(0,0,0), Angle(0,0,0))
	
	--npcs
		--USSR
		SpawnEntity("harbor_npc_oilBroker", "", Vector(-15753, 14581,3), Angle(0,0,0))
		NPC_UPGRADES = SpawnEntity("harbor_npc_upgrades", "", Vector(-15612, 15142,3), Angle(0,-90,0))
		SpawnEntity("harbor_npc_gunshop", "", Vector(-15706, 15101,3), Angle(0,-90,0))
		SpawnEntity("harbor_npc_ammoshop", "", Vector(-15797, 15099,3), Angle(0,-90,0))

		--USA
		SpawnEntity("harbor_npc_oilBroker", "", Vector(15753, -14581,3), Angle(0,180,0))
		NPC_UPGRADES = SpawnEntity("harbor_npc_upgrades", "", Vector(15612, -15142,3), Angle(0,90,0))
		SpawnEntity("harbor_npc_gunshop", "", Vector(15706, -15101,3), Angle(0,90,0))
		SpawnEntity("harbor_npc_ammoshop", "", Vector(15797, -15099,3), Angle(0,90,0))
		
end
local function Init_Delay() --fucking weird shit to make gravity hull designator not crash the server
	timer.Simple(1, function() Init_SpawnEntities() end)
end
hook.Add( "InitPostEntity", "navalwarfare_MapStart_SpawnEntities", Init_Delay)
