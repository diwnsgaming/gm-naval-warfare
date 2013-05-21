AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetOverlayText("Disconnected")
	self.Oil = 0
	self.MaxOil = 30
	self.ConnectDistance = 10
	self.DisconnectDistance = 10
	self:Think()
	self.ISTANK = true
end
function ENT:Think()
	self.connectionpoint = (self:GetUp()*14)-(self:GetRight()*3)-(self:GetForward()*3.5)
	self:SetOverlayText("Oil: "..math.Round(self.Oil))
end