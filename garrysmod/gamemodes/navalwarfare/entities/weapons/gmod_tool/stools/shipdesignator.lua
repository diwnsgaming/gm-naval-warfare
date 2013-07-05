
TOOL.Category		= "Harbor"
TOOL.Name			= "Ship Designator"


cleanup.Register( "nocollide" )

function TOOL:LeftClick( trace )

	if ( !IsValid( trace.Entity ) ) then return end
	if ( trace.Entity:IsPlayer() ) then return end
	
	-- If there's no physics object then we can't constraint it!
	--if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	if(CLIENT) then
		return false
	end
	
	if(trace.Entity:IsValid()) then
		local mass = 0

		for _, ent in pairs( constraint.GetAllConstrainedEntities( trace.Entity ) ) do
			local const = ent:GetPhysicsObject()
			if(const!=nil)then
				mass = mass + const:GetVolume()
			end
		end
		
		local classification = nil
		if(mass<10000000) then
			classification = "Speed Boat"
		elseif(mass<30000000)then
			classification = "Boat"
		elseif(mass>30000000)then
			classification = "Tanker or Warship"
		end
		print(mass)
		local ply = self:GetOwner()
		ply:PrintMessage( HUD_PRINTTALK,"-----------------------------------------------------")
		ply:PrintMessage( HUD_PRINTTALK,"WARNING: This tool is a rough estimate only. If you disagree with the clasification please ask for an admin.")
		ply:PrintMessage( HUD_PRINTTALK,"CLASSIFICATION: " .. classification)
		ply:PrintMessage( HUD_PRINTTALK,"Please put the corresponding color onto a flag, keeping the main body of your ship your team color.")
		ply:PrintMessage( HUD_PRINTTALK,"Submarines, planes, and blimps cannot be decided by this tool. Make something that looks the part then ask an admin.")
		ply:PrintMessage( HUD_PRINTTALK,"ColorTable: ")
		ply:PrintMessage( HUD_PRINTTALK,"SpeedBoat = Green")
		ply:PrintMessage( HUD_PRINTTALK,"Boat = Turqiouse")
		ply:PrintMessage( HUD_PRINTTALK,"Tanker = Yellow")
		ply:PrintMessage( HUD_PRINTTALK,"Warship = Black")
		ply:PrintMessage( HUD_PRINTTALK,"-----------------------------------------------------")
	end
		
	return true
	
end

