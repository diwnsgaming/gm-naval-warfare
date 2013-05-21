AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_plugPort" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel( "models/props_lab/tpplugholder_single.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	self.Linked = false
	self.GetAttachmentAngle = function(self) 
		return Angle(self:GetAngles().pitch,self:GetAngles().yaw,-self:GetAngles().roll)
	end
	self.MaxOil = 0
	self.Oil = 0
	self.ISTANK = true
	self.ConnectDistance = 20
	self.DisconnectDistance = 25
	self.connectionpoint = (self:GetForward()*6)+(self:GetUp()*10)-(self:GetRight()*13)
	self:Think()
end
