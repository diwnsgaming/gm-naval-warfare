AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--DEFINE_BASECLASS( "harbor_oiltankbase" )
include( "shared.lua" )
local barrelCost = 2
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "harbor_oil-large" )
	ent.FPPOwner = ply
	ent:SetPos( SpawnPos )
	ent.ISTANK = true
	ent:Spawn()
	ent:Activate()
	return ent
end
function ENT:Initialize()
	self:SetModel( "models/props_wasteland/horizontalcoolingtank04.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local physbone = self:TranslateBoneToPhysBone(1)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMaterial("wood")
		phys:SetMass(50)
	end
	--addBarrels(self.Owner,2)
	--self:SetOverlayText("Empty Oil Tank")
	self.Oil = 0
	self.lastOil = -1
	self.MaxOil = 6000
	self.barrelCost = barrelCost
	local ply = self.FPPOwner
	if ((ply.barrelCount + barrelCost) > ply.attr["barrel_limmit"]) then 
		SendHint(ply,"You've hit your oil barrel limit!", NOTIFY_ERROR, 5)
		self:Remove()
		return nil
	end
	ply.barrelCount = ply.barrelCount + barrelCost
	
	self.ConnectDistance = 20
	self.DisconnectDistance = 25
	self.GetAttachmentAngle = function(self) 
		return self:GetForward():Angle()
	end
	self:Think()
	self.ISTANK = true
	self.merch = 3
	self.cost = 600
	self.Linked = false 
end
function ENT:Think()
	self.Oil = math.Round(self.Oil)
	local weight = 0.20*self.Oil+300
	self.connectionpoint = (self:GetUp()*5)+(self:GetForward()*155)
	self:SetNWVector("connectionpoint", self.connectionpoint)
	self.connectionangle = self:GetForward():Angle()
	self:SetNWVector("connectionangle", self.connectionangle)
	--self:SetOverlayText("Oil: "..math.Round(self.Oil).."\n".."Weight: "..weight)
	local phys = self:GetPhysicsObject()
	phys:SetMass(weight)
	if self.lastOil != self.Oil then
		self:SetNWInt("oil",self.Oil)
		self:SetNWInt("mass",math.ceil(phys:GetMass()))
		self.lastOil = self.Oil
	end
end