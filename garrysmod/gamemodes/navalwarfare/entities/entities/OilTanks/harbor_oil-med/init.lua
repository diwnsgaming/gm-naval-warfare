AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
trip = false
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_oil-med" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel( "models/props_badlands/barrel02.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetOverlayText("herp")
	self.Oil = 0
	self.MaxOil = 1500
	self.ConnectDistance = 30
	self.DisconnectDistance = 40
	self:Think()
	self.ISTANK = true
end
function ENT:Think()
	self.connectionpoint = (self:GetUp()*80)+(self:GetForward()*20)
	self:SetOverlayText("Oil: "..math.Round(self.Oil))
end