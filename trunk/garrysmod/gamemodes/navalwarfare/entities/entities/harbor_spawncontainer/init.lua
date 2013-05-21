AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
--This creates a shield that rejects things going both ways. Works well, but not what we need right now.
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_spawncontainer" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self.Size = 2000
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInitSphere(self.Size)
	local offset = Vector(self.Size,self.Size,self.Size)
	self:SetCollisionBounds(-1*offset, offset)
	self:DrawShadow(false)
	self:SetTrigger(true)
	self:SetNotSolid(true)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableCollisions(false)
	end
	print(self)
end

local function Permiate(hitEnt)
	local shouldPermiate = true
	if hitEnt.isConfigured then
		local constrainedents = constraint.GetAllConstrainedEntities( hitEnt )
		for k,v in pairs(constrainedents) do
			if v.isConfigured then
			
			end
		end
	end
end

function ENT:StartTouch(hitEnt)
	hitEnt:GetPhysicsObject():SetVelocity(Vector(0,0,0))
end

function ENT:EndTouch(hitEnt)
	hitEnt:GetPhysicsObject():SetVelocity(Vector(0,0,0))
end

function ENT:Think()
end