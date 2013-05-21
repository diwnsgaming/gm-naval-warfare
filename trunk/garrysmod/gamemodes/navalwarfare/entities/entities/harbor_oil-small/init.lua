AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--DEFINE_BASECLASS( "harbor_oiltankbase" )
include( "shared.lua" )
local barrelCost = 1
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_oil-small" )
	ent.FPPOwner = ply
	ent.ISTANK = true
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end
function ENT:Initialize()
	self:SetModel( "models/props_c17/oildrum001.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local physbone = self:TranslateBoneToPhysBone(1)
	local phys = self:GetPhysicsObject()
	--addBarrels(self.Owner,1)
	if phys:IsValid() then
		phys:Wake()
		phys:SetMaterial("wood")
		phys:SetMass(50)
	end
	--self:SetOverlayText("Empty Oil Tank")
	self.Oil = 0
	self.lastOil = -1
	self.MaxOil = 1000
	self.barrelCost = barrelCost
	if ((self.FPPOwner.barrelCount + barrelCost) > self.FPPOwner.attr["barrel_limmit"]) then 
		SendHint(self.FPPOwner,"You've hit your oil barrel limit!", NOTIFY_ERROR, 5)
		self:Remove()
		return nil
	end
	print("test")
	self.FPPOwner.barrelCount = self.FPPOwner.barrelCount + barrelCost
	
	self.ConnectDistance = 20
	self.DisconnectDistance = 25
	self.GetAttachmentAngle = function(self) 
		return self:GetUp():Angle()
	end
	self:Think()
	self.ISTANK = true
	self.cost = 100
	self.merch = 1
	self:SetNWFloat("mass",phys:GetMass())
	self.connectionpoint = self:GetPos()
	self.oldconnectionpoint = self.connectionpoint
end
function ENT:Think()
	local weight = 0.20*self.Oil+50
	self.connectionpoint = (self:GetUp()*45)+(self:GetForward()*10)
	self:SetNWVector("connectionpoint", self.connectionpoint)
	self.connectionangle = self:GetUp():Angle()
	self:SetNWVector("connectionangle", self.connectionangle)
	phys = self:GetPhysicsObject()
	phys:SetMass(weight)
	if self.lastOil != self.Oil then
		self:SetNWInt("oil",self.Oil)
		self:SetNWInt("mass",math.ceil(phys:GetMass()))
		self.lastOil = self.Oil
	end
	
end