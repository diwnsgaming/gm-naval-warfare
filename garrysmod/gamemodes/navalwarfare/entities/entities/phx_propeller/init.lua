
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.WireDebugName = "PHX Propeller"

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:DrawShadow( false )
	self:SetToggle( false )
	self.ToggleState = false
	self.Direction = 0
	self.Breaking = 0
	self.SpinVel = 0
	self.AngVel = Angle(0,0,0)
	self.Vel = Angle(0,0,0)
	self.Accelerating = false
	self.AccTo = 0
	self.OrigForce = 0
	self.KeyBinds = {}
	self.StartVel = 0

	self.Snd = CreateSound(self, Sound("vehicles/Airboat/fan_blade_fullthrottle_loop1.wav"))

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	local max = self.Entity:OBBMaxs()
	local min = self.Entity:OBBMins()
	
	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	self:SetForce( 0 )
	
	self:SetOffset( self.ThrustOffset )
	self:StartMotionController()
	self.Entity:StartMotionController()
	
	if (Wire_CreateInputs) then
		self.Inputs = Wire_CreateInputs(self.Entity, { "Go" })
	end

	if (Wire_CreateOutputs) then
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Speed", "Thrust" })
	end
end

function ENT:SetAxis( vec )

	self.Axis = self:GetPos() + vec * 512
	self.Axis = self:NearestPoint( self.Axis )
	self.Axis = self:WorldToLocal( self.Axis )

end

function ENT:SetPlayer( pl )
	self.Ply = pl
end

function ENT:SetForce( force, mul )
	if (force) then
		self.Force = force
		self:NetSetForce( force )
	end
	mul = mul or 1
	
	local phys = self.Entity:GetPhysicsObject()
	if (!phys:IsValid()) then
		return
	end

	// Get the data in worldspace
	local ThrusterWorldPos = phys:LocalToWorld( self.ThrustOffset )
	local ThrusterWorldForce = phys:LocalToWorldVector( self.ThrustOffset * -1 )

	// Calculate the velocity
	ThrusterWorldForce = ThrusterWorldForce * self.Force  * 50
	self.ForceLinear, self.ForceAngle = phys:CalculateVelocityOffset( ThrusterWorldForce, ThrusterWorldPos );
	self.ForceLinear = phys:WorldToLocalVector( self.ForceLinear )
	
	if ( mul > 0 ) then
		self:SetOffset( self.ThrustOffset )
	else
		self:SetOffset( self.ThrustOffsetR )
	end

	if (math.abs(self.SpinVel) < 10) then
		self.Snd:Stop()
	elseif (self.Snd) then
		self.Snd:Play()
	end		
	if (self.Snd:IsPlaying()) then
		self.Snd:ChangePitch(self.MinPitch + math.abs(self.SpinVel/self.Speed*(self.MaxPitch - self.MinPitch)), 5)
	end
end

function ENT:Setup(force, speed, acceleration, decceleration, owater, uwater, bidir, sound, minpitch, maxpitch, soundname)
	self:SetForce(0)
	self.OrigForce = force
	self.Speed = speed
	self.Acceleration = acceleration
	self.Decceleration = decceleration
	self.BiDir = bidir
	self.EnableSound = sound
	self.OWater = owater
	self.UWater = uwater
	self.MinPitch = math.Clamp(minpitch,0,255)
	self.MaxPitch = math.Clamp(maxpitch,0,255)
	self.SoundName = soundname
	self.Snd = CreateSound(self, soundname)
end

function ENT:SetToggle( bool )
	self.Toggle = bool
end

function ENT:GetToggle()
	return self.Toggle
end

function ENT:SetFwd( fwd )
	self.Fwd = fwd
	if (self.KeyBinds[1]) then
		numpad.Remove(self.KeyBinds[1])
		numpad.Remove(self.KeyBinds[2])
	end
	self.KeyBinds[1] = numpad.OnDown(self.Ply, fwd, "PropellerForward", self, true )
	self.KeyBinds[2] = numpad.OnUp( self.Ply, fwd, "PropellerForward", self, false )
end

function ENT:SetBck( bck )
	self.Bck = bck
	if (self.KeyBinds[3]) then
		numpad.Remove(self.KeyBinds[3])
		numpad.Remove(self.KeyBinds[4])
	end
	self.KeyBinds[3] = numpad.OnDown( self.Ply, bck, "PropellerReverse", self, true )
	self.KeyBinds[4] = numpad.OnUp( self.Ply, bck, "PropellerReverse", self, false )
end

function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()
	local angvel = physobj:GetAngleVelocity()
	local spin = true

	if (math.abs(angvel.z) < 10) then
		self:SetForce(0, 1)
	else
		self:SetForce(angvel.z * (self.OrigForce / self.Speed) * -1, 1)
	end
	
	self.AngVel = angvel
	self.Vel = vel
	
	if (self.Entity:WaterLevel() > 0) then
		if (not self.UWater) then
			spin = false
		end
		
	else
		if (not self.OWater) then
			spin = false
		end
	end

	if (self.SpinVel != 0) then
		if (spin) then
			physobj:AddAngleVelocity( -1 * physobj:GetAngleVelocity() + Vector(0,0,self.SpinVel))
		end
	end

	if (Wire_TriggerOutput) then
		Wire_TriggerOutput(self.Entity, "Speed", self.SpinVel)
		Wire_TriggerOutput(self.Entity, "Thrust", math.Round(angvel.z * (self.OrigForce / self.Speed)))
	end

	physobj:SetVelocity(vel)
end

function ENT:TriggerInput(iname, value)
	if (iname == "Go") then
		if (self.toggle) then
			if (value > 0) then
				self:Forward(true)
			end
		else 
			if ( value == 0 ) then
				self:Stop()
			else
				self:Forward(true)
			end
		end
	end
end

function ENT:PhysicsSimulate( phys, deltatime )
	
	if (self.Accelerating) then
		if (self.AccTo > self.StartVel) then
			self.SpinVel = self.SpinVel + (deltatime * self.Acceleration)
			if (self.SpinVel > self.AccTo) then
				self.SpinVel = self.AccTo
				self.AccInc = 0
				self.Accelerating = false
				if self.SpinVel < 10 then
					self:Stop()
				end
			end
		else
			self.SpinVel = self.SpinVel - (deltatime * self.Decceleration)
			if (self.SpinVel < self.AccTo) then
				self.SpinVel = self.AccTo
				self.AccInc = 0
				self.Accelerating = false
				if self.SpinVel < 10 then
					self:Stop()
				end
			end
		end
	end	

	local ForceAngle, ForceLinear = self.ForceAngle, self.ForceLinear
	
	return ForceAngle, ForceLinear, SIM_LOCAL_ACCELERATION
end

function ENT:OnRemove()
	if (self.Snd) then
		self.Snd:Stop()
	end
	numpad.Remove(self.KeyBinds[1])
	numpad.Remove(self.KeyBinds[2])
	numpad.Remove(self.KeyBinds[3])
	numpad.Remove(self.KeyBinds[4])
	self.BaseClass.OnRemove(self)
end


function ENT:BuildDupeInfo()
	local info = WireLib.BuildDupeInfo(self.Entity) or {}
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )	
end

function ENT:OnRestore()
    Wire_Restored(self.Entity)
end

function ENT:PreEntityCopy()
	local DupeInfo = self:BuildDupeInfo()
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end

function ENT:Accelerate(to)
	self.StartVel = self.SpinVel
	self.AccTo = to
	self.SpinVel = self.AngVel.z
	self.Accelerating = true
end

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

function ENT:Reverse(down)
	if (self.Toggle) then
		if (down == true) then
			if (self.Direction == -1) then
				if (self.Acceleration != 0) then
					self:Accelerate(0)
				else
					self.Stop()
				end
			else
				if (self.Acceleration != 0) then
					self:Accelerate(self.Speed * -1)
				else
					self.SpinVel = self.Speed * -1
				end
				self.Direction = -1
			end
		end
	else 
		if (down == true) then
			if (self.Acceleration != 0) then
				self:Accelerate(self.Speed * -1)
			else
				self.SpinVel = self.Speed * -1
			end
			self.Direction = -1
		else
			if (self.Acceleration != 0) then
				self:Accelerate(0)
			else
				self.Stop()
			end
		end
	end
end

function ENT:Forward(down)
	if (self.Toggle) then
		if (down == true) then
			if (self.Direction == 1) then
				if (self.Acceleration != 0) then
					self:Accelerate(0)
				else
					self.Stop()
				end
			else
				if (self.Acceleration != 0) then
					self:Accelerate(self.Speed)
				else
					self.SpinVel = self.Speed
				end
				self.Direction = 1
			end
		end
	else 
		if (down == true) then
			if (self.Acceleration != 0) then
				self:Accelerate(self.Speed)
			else
				self.SpinVel = self.Speed
			end
			self.Direction = 1
		else
			if (self.Acceleration != 0) then
				self:Accelerate(0)
			else
				self:Stop()
			end
		end
	end
end

function ENT:Stop()
	self.Direction = 0
	self.SpinVel = 0
	self.Accelerating = false
end

function propeller_ForwardKey(pl, prop, down)
	prop:Forward(down)
end

numpad.Register("PropellerForward", propeller_ForwardKey)

function propeller_BackKey(pl, prop, down)
	if (prop.BiDir) then
		prop:Reverse(down)
	end
end

numpad.Register("PropellerReverse", propeller_BackKey)
