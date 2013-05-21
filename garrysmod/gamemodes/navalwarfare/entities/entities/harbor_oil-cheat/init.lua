AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--DEFINE_BASECLASS( "harbor_oiltankbase" )
include( "shared.lua" )
--[[local function entityRemoved(ent)
   	local ply = ent.Owner
	if ent:GetClass() == "harbor_oil-cheat" then
		local index = -1
		for k,v in pairs(ply.oilBarrels) do
			if v == ent then index = k end 
		end
		if index != -1 then
			table.remove( ply.oilBarrels, index)
		end
	end
end
hook.Add("EntityRemoved", "navalwarfare_removeBarrell-cheat", entityRemoved)]]--
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_oil-cheat" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	--if ply.oilBarrels == nil then
	--	ply.oilBarrels = {}
	--end
	--table.insert(ply.oilBarrels,ent)
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
	if phys:IsValid() then
		phys:Wake()
		phys:SetMaterial("wood")
	end
	self:SetOverlayText("Empty Oil Tank")
	self.Oil = 1000
	self.MaxOil = 1000
	self.ConnectDistance = 20
	self.DisconnectDistance = 25
	self.GetAttachmentAngle = function(self) 
		return self:GetUp():Angle()
	end
	self:Think()
	self.ISTANK = true
	self.cost = 0
end
function ENT:Think()
	local weight = 0.20*self.Oil+50
	self.connectionpoint = (self:GetUp()*45)+(self:GetForward()*10)
	self:SetOverlayText("Oil: "..math.Round(self.Oil).."\n".."Weight: "..weight)
	self:GetPhysicsObject():SetMass(weight)
end