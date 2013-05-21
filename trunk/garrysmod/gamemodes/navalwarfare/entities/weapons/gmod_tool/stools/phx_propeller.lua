TOOL.Category   = "Construction"
TOOL.Name       = "Propeller"
TOOL.Command    = nil
TOOL.ConfigName = ""

if ( CLIENT ) then
	language.Add( "Tool_phx_propeller_name", "Propeller Tool" )
	language.Add( "Tool_phx_propeller_desc", "Spawns a Propeller" )
	language.Add( "Tool_phx_propeller_0", "Primary: Create Propeller   Secondary: Update Propeller" )
	language.Add( "undone_phx_propeller", "Undone Propeller" )
	language.Add( "SBoxLimit_phx_propellers", "Max Propellers Reached" )
end

TOOL.ClientConVar[ "force" ] = "1500"
TOOL.ClientConVar[ "speed" ] = "200"
TOOL.ClientConVar[ "acceleration" ] = "0"
TOOL.ClientConVar[ "decceleration" ] = "0"
TOOL.ClientConVar[ "model" ] = "models/props_phx/misc/propeller2x_small.mdl"
TOOL.ClientConVar[ "bidir" ] = "1"
TOOL.ClientConVar[ "nocollide" ] = "0"
TOOL.ClientConVar[ "sound" ] = "1"
TOOL.ClientConVar[ "owater" ] = "1"
TOOL.ClientConVar[ "uwater" ] = "1"
TOOL.ClientConVar[ "fwd" ] = "8"
TOOL.ClientConVar[ "bck" ] = "5"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "minpitch" ] = "100"
TOOL.ClientConVar[ "maxpitch" ] = "100"
TOOL.ClientConVar[ "soundname" ] = "vehicles/Airboat/fan_blade_fullthrottle_loop1.wav"



if (SERVER) then
	CreateConVar("sbox_maxphx_propellers", 100)
end


local degrees = 0

function TOOL:LeftClick( trace )
	
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if (CLIENT) then return true end
	
	local ply = self:GetOwner()

	if ( !self:GetSWEP():CheckLimit( "phx_propellers" ) ) then return false end

	local targetPhys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	
	local force       	= self:GetClientNumber( "force" )
	local speed   		= self:GetClientNumber( "speed" )
	local acceleration   	= self:GetClientNumber( "acceleration" )
	local decceleration   	= self:GetClientNumber( "decceleration" )
	local model       	= self:GetClientInfo( "model" )
	local bidir       	= self:GetClientNumber( "bidir" ) ~= 0
	local nocollide   	= self:GetClientNumber( "nocollide" ) != 0
	local sound       	= self:GetClientNumber( "sound" ) ~= 0
	local owater      	= self:GetClientNumber( "owater" ) ~= 0
	local uwater      	= self:GetClientNumber( "uwater" ) ~= 0
	local toggle		= self:GetClientNumber( "toggle" ) != 0
	local fwd		= self:GetClientNumber( "fwd" )
	local bck		= self:GetClientNumber( "bck" )
	local minpitch		= self:GetClientNumber( "minpitch" )
	local maxpitch		= self:GetClientNumber( "maxpitch" )
	local soundname		= self:GetClientInfo( "soundname" )
	local TargetAngle = trace.HitNormal:Angle()
	local pos = trace.HitPos
	
	if model == "models/props_phx/misc/propeller2x_small.mdl" or model == "models/props_phx/misc/propeller3x_small.mdl" then
		TargetAngle = TargetAngle + Angle(90, 0, 0)
	else
		local propeller = MakePHXPropeller( ply, pos, Angle(0,0,0), model, force, speed, acceleration, decceleration, owater, uwater, bidir, sound, nocollide, fwd, bck, toggle, minpitch, maxpitch, soundname)
		pos = pos + trace.HitNormal*((propeller:OBBMaxs().z-propeller:OBBMins().z))*0.25
		propeller:Remove()
	end

	if ( !util.IsValidModel( model ) ) then return false end
	if ( !util.IsValidProp( model ) ) then return false end
	
	local propeller = MakePHXPropeller( ply, pos, Angle(0,0,0), model, force, speed, acceleration, decceleration, owater, uwater, bidir, sound, nocollide, fwd, bck, toggle, minpitch, maxpitch, soundname)
	propeller:Setup(force, speed, acceleration, decceleration, owater, uwater, bidir, sound, minpitch, maxpitch, soundname)
	

	propeller:SetAngles( TargetAngle )	

	propeller:GetPhysicsObject():Wake()
	
	local TargetPos = propeller:GetPos()
	local LPos1 = propeller:GetPhysicsObject():WorldToLocal( TargetPos + trace.HitNormal )
	local LPos2 = targetPhys:WorldToLocal( trace.HitPos )
	
	local constraint, axis = constraint.Motor( propeller, trace.Entity, 0, trace.PhysicsBone, LPos1, LPos2, 0, 10, 0, 1, ply, 0)

	undo.Create("Propeller")
	undo.AddEntity( constraint )
	undo.AddEntity( axis )
	undo.AddEntity( propeller )
	undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "propellers", axis )
	ply:AddCleanup( "propellers", constraint )
	ply:AddCleanup( "propellers", propeller )
	
	propeller:SetAxis( trace.HitNormal )
	propeller:SetToggle( toggle )
	propeller:SetFwd( fwd )
	propeller:SetBck( bck )

	return true
end

if (SERVER) then
	
	function MakePHXPropeller( pl, Pos, Ang, model, force, speed, acceleration, decceleration, owater, uwater, bidir, sound, nocollide, fwd, bck, toggle, minpitch, maxpitch, soundname)
		if ( !pl:CheckLimit( "phx_propellers" ) ) then return false end
		
		local propeller = ents.Create( "phx_propeller" )

		if (!propeller:IsValid()) then return false end
		propeller:Setup(force, speed, acceleration, decceleration, owater, uwater, bidir, sound, minpitch, maxpitch, soundname)
		propeller:SetModel( model )
		
		propeller:SetAngles( Ang )
		propeller:SetPos( Pos )
		propeller:Spawn()
		
		propeller:SetToggle(toggle)
		propeller:SetPlayer( pl )
		
		if ( nocollide == true ) then propeller:GetPhysicsObject():EnableCollisions( false ) end

		propeller:SetFwd(fwd)
		propeller:SetBck(bck)
		
		pl:AddCount( "propellers", propeller )
		
		return propeller
	end
	duplicator.RegisterEntityClass("phx_propeller", MakePHXPropeller, "Pos", "Ang", "Model", "Force", "Speed", "Acceleration", "Decceleration", "OWater", "UWater", "BiDir", "Sound", "NoCollide","Fwd","Bck","Toggle", "MinPitch", "MaxPitch", "SoundName")
	
end

function TOOL:RightClick(trace)

	local force       	= self:GetClientNumber( "force" )
	local speed   		= self:GetClientNumber( "speed" )
	local acceleration   	= self:GetClientNumber( "acceleration" )
	local decceleration	= self:GetClientNumber( "decceleration" )
	local model       	= self:GetClientInfo( "model" )
	local bidir       	= self:GetClientNumber( "bidir" ) ~= 0
	local nocollide   	= self:GetClientNumber( "nocollide" ) != 0
	local sound       	= self:GetClientNumber( "sound" ) ~= 0
	local owater      	= self:GetClientNumber( "owater" ) ~= 0
	local uwater      	= self:GetClientNumber( "uwater" ) ~= 0
	local toggle		= self:GetClientNumber( "toggle" ) != 0
	local fwd		= self:GetClientNumber( "fwd" )
	local bck		= self:GetClientNumber( "bck" )
	local minpitch		= self:GetClientNumber( "minpitch" )
	local maxpitch		= self:GetClientNumber( "maxpitch" )
	local soundname		= self:GetClientInfo( "soundname" )

	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return true end

	local ply = self:GetOwner()

	if (trace.Entity:IsValid() && trace.Entity:GetClass() == "phx_propeller") then
		local propeller = trace.Entity
		propeller:SetModel( model )
		propeller:Setup(force, speed, acceleration, decceleration, owater, uwater, bidir, sound, minpitch, maxpitch, soundname)

		propeller:SetBck(bck)
		propeller:SetToggle(toggle)
		
		if ( nocollide == true ) then propeller:GetPhysicsObject():EnableCollisions( false ) end

		return true
	end
end

function TOOL:UpdateGhostPHXPropeller( ent, player )
	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= util.GetPlayerTrace( player, player:GetAimVector() )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	if (trace.Entity && trace.Entity:GetClass() == "phx_propeller" || trace.Entity:IsPlayer()) then
		ent:SetNoDraw( true )
		return
	end
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local min = ent:OBBMins()
	 ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )
	
	ent:SetNoDraw( false )
end


function TOOL:Think()
	
	if (self:NumObjects() > 0) then
		if ( SERVER ) then
			local Phys2 = self:GetPhys(2)
			local Norm2 = self:GetNormal(2)
			local cmd = self:GetOwner():GetCurrentCommand()
			degrees = degrees + cmd:GetMouseX() * 0.05
			local ra = degrees
			if (self:GetOwner():KeyDown(IN_SPEED)) then ra = math.Round(ra/45)*45 end
			local Ang = Norm2:Angle()
			Ang.pitch = Ang.pitch + 90
			Ang:RotateAroundAxis(Norm2, ra)
			Phys2:SetAngle( Ang )
			Phys2:Wake()
		end
	else
		local model = self:GetModel()

		if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != model ) then
			self:MakeGhostEntity( Model(model), Vector(0,0,0), Angle(0,0,0) )
		end

		self:UpdateGhostPHXPropeller( self.GhostEntity, self:GetOwner() )
	end
	
end

function TOOL:GetModel()
	local model = "models/propeller/propeller2x_small.mdl"
	local modelcheck = self:GetClientInfo( "model" )

	if (util.IsValidModel(modelcheck) and util.IsValidProp(modelcheck)) then
		model = modelcheck
	end
	
	return model
end

if (CLIENT) then
	function TOOL:FreezeMovement()
		return self:GetStage() == 1
	end
end

function TOOL:Holster()
	self:ClearObjects()
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_phx_propeller_name", Description = "#Tool_phx_propeller_desc" })
	
	panel:AddControl("ComboBox", {
		Label = "#Presets",
		MenuButton = "1",
		Folder = "propeller",
		
		Options = {
			Default = {
				phx_propeller_model = "models/props_phx/misc/propeller2x_small.mdl",
				phx_propeller_force = "1500",
				phx_propeller_speed = "200",
				phx_propeller_acceleration = "0",
				phx_propeller_decceleration = "0", 
				phx_propeller_bidir = "1",
				phx_propeller_sound = "0",
				phx_propeller_owater = "1",
				phx_propeller_uwater = "1",
				
			}
		},

		CVars = {
			[0] = "phx_propeller_model",
			[1] = "phx_propeller_force",
			[2] = "phx_propeller_speed",
			[3] = "phx_propeller_acceleration",
			[4] = "phx_propeller_decceleration",
			[5] = "phx_propeller_bidir",
			[6] = "phx_propeller_sound",
			[7] = "phx_propeller_owater",
			[8] = "phx_propeller_uwater",
		}
	})
	
	-- panel:AddControl( "PropSelect", {
		-- Label = "Model",
		-- ConVar = "phx_propeller_model",
		-- Category = "Propellers",
		-- Modelsw = list.Get("PHXPROPMODELS")
		-- })
		
	panel:AddControl( "PropSelect", { Label = "Model",
									 ConVar = "phx_propeller_model",
									 Category = "Propellers",
									 Height = 6,
									 Models = list.Get( "PropellerModels" ) } )
	
	panel:AddControl("Slider", {
		Label = "Propeller Force",
		Type = "Float",
		Min = "1",
		Max = "10000",
		Command = "phx_propeller_force"
	})
	
	panel:AddControl("Slider", {
		Label = "Speed",
		Type = "Float",
		Min = "0",
		Max = "2000",
		Command = "phx_propeller_speed"
	})
	
	panel:AddControl("Slider", {
		Label = "Acceleration",
		Type = "Float",
		Min = "0",
		Max = "100",
		Command = "phx_propeller_acceleration"
	})

	panel:AddControl("Slider", {
		Label = "Decceleration",
		Type = "Float",
		Min = "0",
		Max = "100",
		Command = "phx_propeller_decceleration"
	})

	panel:AddControl("Slider", {
		Label = "Sound Min Pitch",
		Type = "Float",
		Min = "0",
		Max = "255",
		Command = "phx_propeller_minpitch"
	})

	panel:AddControl("Slider", {
		Label = "Sound Max Pitch",
		Type = "Float",
		Min = "0",
		Max = "255",
		Command = "phx_propeller_maxpitch"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Bi-directional",
		Command = "phx_propeller_bidir"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Not Solid",
		Command = "phx_propeller_nocollide"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Sound",
		Command = "phx_propeller_sound"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Works out of water",
		Command = "phx_propeller_owater"
	})
	
	panel:AddControl("CheckBox", {
		Label = "Works Underwater",
		Command = "phx_propeller_uwater"
	})
	panel:AddControl( "CheckBox", {
		Label = "Toggle",
		Command = "phx_propeller_toggle" 
	})
end

list.Set( "PropellerModels", "models/props_phx/misc/propeller2x_small.mdl", {} )
list.Set( "PropellerModels", "models/props_phx/misc/propeller3x_small.mdl", {} )
list.Set( "PropellerModels", "models/XQM/propeller1medium.mdl", {} )
list.Set( "PropellerModels", "models/XQM/propeller1big.mdl", {} )
list.Set( "PropellerModels", "models/XQM/propeller1large.mdl", {} )
