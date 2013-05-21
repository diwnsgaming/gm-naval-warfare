AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = Vector(9678,9666,1074)	
	local ent = ents.Create( "harbor_oiltransfer" )
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
	self:SetOverlayText("Oil Relay")
	self:SetPos(Vector(9677,9666,1074))
	self:SetAngles(Angle(0,-90,0))
	self.Linked = false
	self.Oil = 0
	self.Linked = false
	self.OldLinked = false
	self.MaxOil = 16
	self.ISTANK = true
	self.ConnectDistance = 20
	self.DisconnectDistance = 25
	self.GetAttachmentAngle = function(self) 
		return Angle(self:GetAngles().pitch,self:GetAngles().yaw,-self:GetAngles().roll)
	end
	self.connectionpoint = (self:GetForward()*6)+(self:GetUp()*10)-(self:GetRight()*13)
	self.connectionangle = self:GetForward():Angle()
	self:CreateOutPort()
	self.plug = self:CreatePlug(self.plugPort)
	self.plugPort:Spawn()
	--local constraint, rope = constraint.Elastic( self.plug, self.plugPort, 0, 0, self.plug:GetForward()*-11, 
		--Vector(00,0,20), 200, 200, "cable/cable2", 3, true)
	local constraint, rope = constraint.Rope( self.plug, self.plugPort, 0, 0, self.plug:GetForward()*-11, 
			Vector(00,0,20), 200, 200, 0, 3, "cable/cable2", false)
end
function ENT:OnRemove()
	self.plug:Remove()
	self.plugPort:Remove()
end
function ENT:CreateOutPort()
	self.plugPort = ents.Create("harbor_plugPort")
	self.plugPort:SetPos(Vector(9825,9610,49.5))
	self.plugPort:SetAngles(Angle(0,-78,0))
end
function ENT:CreatePlug(ent)
	local plug = ents.Create("harbor_oilpump")
	plug:SetPos(self.plugPort:GetPos()+self.plugPort:GetForward()*5)
	plug:SetAngles(Angle(0,-90,0))
	plug:Spawn()
	plug:Activate()
	local phys = plug:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	plug.smoothyaw = 0
	plug.smoothpitch = 0
	ent.plug = plug	
	return plug
end
function ENT:Think()
	self.connectionangle = self:GetForward():Angle()
	self:SetNWVector("connectionpoint", self.connectionpoint)
	self:SetNWVector("connectionangle", self.connectionangle)
	if self.plug.Tank != nil then
		local remainingStorage = self.plug.Tank.MaxOil - self.plug.Tank.Oil
		if remainingStorage < self.Oil then
			self.plug:SendOil(remainingStorage)
			self.Oil = self.Oil - remainingStorage
		elseif remainingStorage >= self.Oil then
			self.plug:SendOil(self.Oil)
			self.Oil = 0
		end
	end
	if self.Linked!=self.OldLinked then
		self.OldLinked = self.Linked
		if self.Linked then
			self:SetNWBool("isconnected", true)
			self.plugPort:SetNWBool("isconnected", true)
		else
			self:SetNWBool("isconnected", false)
			self.plugPort:SetNWBool("isconnected", false)
		end
	end
end