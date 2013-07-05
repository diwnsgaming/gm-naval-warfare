AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
--
localself = nil

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1 + Vector( 0, 0, 20)
	local ent = ents.Create( "harbor_projectile" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end


local function RemoveSelf()
	local localerself = localself
	if(localerself:IsValid()) then
		localerself:Remove()
	end
end
 

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100)
	end
	self:SetOverlayText("cannonball")
	self.Scale = 2.3
	localself = self
	timer.Simple( 10, RemoveSelf )
end

function ENT:PhysicsCollide( data, physobj )
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart( vPoint )
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( self.Scale*0.05 )
	effectdata:SetMagnitude(self.Scale*0.05)
	util.Effect( "Explosion", effectdata )	
	local damageProps = ents.FindInSphere( self:GetPos(), self.Scale*100 )
	for k,v in pairs(damageProps) do
		if v.NWHealth != nil or v:GetClass() == "player" then
			 v:TakeDamage( self.Scale*100, v.FPPOwner, self )
		end
	end
	self:Remove()
end
function ENT:Touch(hitEnt)
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart( vPoint )
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( self.Scale*0.05 )
	effectdata:SetMagnitude(self.Scale*0.05)
	util.Effect( "Explosion", effectdata )	
	local damageProps = ents.FindInSphere( self:GetPos(), self.Scale*100 )
	for k,v in pairs(damageProps) do
		if v.NWHealth != nil or v:GetClass() == "player" then
			 v:TakeDamage( self.Scale*100, v.FPPOwner, self )
		end
	end
	self:Remove()
end

function ENT:Think()
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = self:GetPos() + self:GetForward()*10
	tracedata.filter = self
	local trace = util.TraceLine(tracedata)
	if trace.HitNonWorld and false then
		local vPoint = self:GetPos()
		local effectdata = EffectData()
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( self.Scale*0.05 )
		effectdata:SetMagnitude(self.Scale*0.05)
		util.Effect( "Explosion", effectdata )	
		local damageProps = ents.FindInSphere( self:GetPos(), self.Scale*100 )
		for k,v in pairs(damageProps) do
			if v.NWHealth != nil or v:GetClass() == "player" then
				 v:TakeDamage( self.Scale*100, v.FPPOwner, self )
			end
		end
		self:Remove()
	end
	self:GetPhysicsObject():SetDamping( 1, 0 )
	self:NextThink( CurTime() + 0.01)
	return true
end