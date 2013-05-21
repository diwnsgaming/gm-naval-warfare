AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_oilcheat" )
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
	self:SetOverlayText("herp")
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Linked = false
	self.Oil = 100000
	self:CreatePlug()
	self:Think()
end
function ENT:OnRemove( )
	self.plug:Remove()
end
function ENT:CreatePlug()
	self.plug = ents.Create("harbor_oilpump")
	self.plug:SetPos(self:GetPos()+self:GetForward()*10)
	self.plug:Spawn()
	self.plug:Activate()
	self.plug:SetConnector(self)
	self.plug.smoothyaw = 0
	self.plug.smoothpitch = 0
end
function ENT:Think()
	local Offset = (self:GetForward()*6)+(self:GetUp()*10)-(self:GetRight()*13)
	self.Offset = Offset
	local Distance = self.plug:GetPos():Distance(self:GetPos()+Offset)
	if(Distance<15&&!self.plug:IsPlayerHolding()) then
		if(self.Linked == false) then
			self.plug:SetPos(self:GetPos()+Offset)
			self.plug:SetAngles(Angle(self:GetAngles().pitch,self:GetAngles().yaw,-self:GetAngles().roll))
			self.plug:GetPhysicsObject():EnableMotion(false)
			local weld = constraint.Weld( self, self.plug, 0, 0, 0, true )
			if (weld and weld:IsValid()) then
				self.plug:DeleteOnRemove( weld )
				self:DeleteOnRemove( weld )
				self.Weld = weld
			end
			self.plug:GetPhysicsObject():EnableMotion(true)
			self.Linked = true
			self.plug.IsHeld = true
		end
	elseif(Distance<35&&self.Linked==false) then
		self.plug:GetPhysicsObject():SetVelocity(((self:GetPos()+Offset)-self.plug:GetPos())*5)
	else
		if(self.Linked == true) then
			self.Linked = false
			self.plug.IsHeld = false
			self.Weld:Remove()
			self.plug:GetPhysicsObject():EnableMotion(true)
		else
			if(self.plug:SendOil(4)) then
				self.Oil = self.Oil - 4
			end
		end
	end
	self:SetOverlayText(self.Oil)
	self:NextThink( CurTime() + 0.1 )
	return true
end