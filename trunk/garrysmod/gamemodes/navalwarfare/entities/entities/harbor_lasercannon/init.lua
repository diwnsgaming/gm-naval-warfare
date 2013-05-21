AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
--models/props_trainstation/trainstation_post001.mdl
--models/props_combine/breenlight.mdl
local BEAM = nil
local SOUND = nil
local CHARGELOOP = Sound("weapons/gauss/chargeloop.wav")

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1 + Vector( 0, 0, 20)
	local ent = ents.Create( "harbor_lasercannon" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1000)
	end
	
	SOUND = CreateSound(self, CHARGELOOP)
	
	self.Energy = 1000
	self.MaxEnergy = 1000
	self.Capacitor = 0
	self.MaxCapacitor = 100
	
	self.IsFireing = false
	self.FirstFire = false
	self.IsCharging = false
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" } )
	self.Outputs = WireLib.CreateSpecialOutputs( self.Entity, { "Ready", "Capacitor", "Energy" }, { "NORMAL" , "NORMAL" , "NORMAL" } )
	Wire_TriggerOutput(self.Entity, "Entity", self.Entity)
	self.WireDebugName = "Heavy Cannon"
	
	self.cost = 1500
end

local function FireRound(self)
	SOUND:Stop()
	
	if !self.FirstFire then
		self.FirstFire = true
		self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
	else
		self:EmitSound("weapons/gauss/fire1.wav")
	end
	self:SetNWBool("fire", true)
	self:GetPhysicsObject():AddVelocity(-self:GetUp()*100)
	self.IsFireing = true
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos + (self:GetUp()*800)
	tracedata.filter = self
	
	local trace = util.TraceLine(tracedata)
	if trace.Hit then
		trace.Entity:TakeDamage( 200, trace.Entity.FPPOwner, self )
		local mult = (800-(trace.HitPos:Distance(self:GetPos())))*75
		print(mult)
		trace.Entity:GetPhysicsObject( ):ApplyForceOffset(self:GetUp()*mult, trace.HitPos)
	end
	if self.Capacitor < 0 then
		self.Capacitor = 0
		self:SetOverlayText("Laser Cannon \n ReloadSpeed: 25 \n Damage: 1000".."\n Capacitor: "..self.Capacitor.."\n ENERGY: "..self.Energy)
	end
end

function ENT:TriggerInput( iname , value )
	if value > 0 then
		self.IsCharging = true
		SOUND:Play()
	end
end

function ENT:Use( activator, caller )
	self.IsCharging = true
	SOUND:Play()
end

function ENT:Think()
	if SOUND == nil then SOUND = CreateSound(self, CHARGELOOP) end
	if SOUND == nil then return false end
	self:SetOverlayText("Laser Cannon \n ReloadSpeed: 25 \n Damage: 1000".."\n Capacitor: "..self.Capacitor.."\n ENERGY: "..self.Energy)
	if self.Energy <= 0 and self.Capacitor < 1 then
		self:SetOverlayText("Laser Cannon \n NO ENERGY REMAINING \n RETURN TO HARBOR TO RE-ENERGIZE")
	elseif self.IsCharging and self.Energy > 0 then
		if self.Capacitor < self.MaxCapacitor then
			self.Capacitor = self.Capacitor + 5
			self.Energy = self.Energy -5
			self.FirstFire = false
			self:SetOverlayText("Laser Cannon \n ReloadSpeed: 25 \n Damage: 1000".."\n Capacitor: "..self.Capacitor.."\n ENERGY: "..self.Energy)
		else
			self.IsCharging = false
			FireRound(self)
			if self.Capacitor < 0 then
				self.Capacitor = 0
			end
		end
	elseif self.Capacitor > 0 and self.Energy == 0 then
		self.IsCharging = false
		FireRound(self)
	end
	if self.IsFireing then
		if self.Capacitor > 1 then
			FireRound(self)
			self.Capacitor = self.Capacitor - 10
			self:SetOverlayText("Laser Cannon \n ReloadSpeed: 25 \n Damage: 1000".."\n Capacitor: "..self.Capacitor.."\n ENERGY: "..self.Energy)
		else
			self.IsFireing = false
			self:SetNWBool("fire", false)
		end
	end
	local plyPos = self:GetPos()
	if plyPos:Distance(USAPos) < HarborRadius or 
	   isInBox(plyPos,USASquare[1],USASquare[2]) then 
		if self.FPPOwner:IsValid() and self.FPPOwner:Team() == TEAM_USA then
			if self.Energy < self.MaxEnergy then
				self.Energy = self.Energy + 1
				self:SetOverlayText("Laser Cannon \n ReloadSpeed: 25 \n Damage: 1000".."\n Capacitor: "..self.Capacitor.."\n RECHARGING("..self.Energy..")")
			end
		end
	elseif plyPos:Distance(USSRPos) < HarborRadius or
	   isInBox(plyPos,USSRSquare[1],USSRSquare[2]) then
		if self.FPPOwner:IsValid() and self.FPPOwner:Team() == TEAM_USSR then
			if self.Energy < self.MaxEnergy then
				self.Energy = self.Energy + 1
				self:SetOverlayText("Laser Cannon \n ReloadSpeed: 25 \n Damage: 1000".."\n Capacitor: "..self.Capacitor.."\n RECHARGING("..self.Energy..")")
			end
		end
	end
	WireLib.TriggerOutput(self, "Capacitor", self.Capacitor)
	WireLib.TriggerOutput(self, "Energy", self.Energy)
	WireLib.TriggerOutput(self, "Ready", 1)
	self:GetPhysicsObject():SetMass(1000)
	self:NextThink( CurTime() + 0.1)
	return true
end