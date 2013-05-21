function EnteredVehicle( player, vehicle, role )
	local ce = constraint.GetAllConstrainedEntities( vehicle )
	local totalmass = 0
	local totalvolume = 0
	local totalprops = 0
	local totalpoints = 0
	for k,v in pairs(ce) do
		local po = v:GetPhysicsObject()
		totalmass = totalmass + po:GetMass()
		totalvolume = totalvolume + po:GetVolume()
		totalprops = totalprops + 1
	end
	
end
hook.Add("PlayerEnteredVehicle", "harbor_shipmenu", EnteredVehicle)