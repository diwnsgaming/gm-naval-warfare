AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

local MaxOilPerTick = 4

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_main" )
	ent:SetPos( SpawnPos + Vector(0,0,-17))
	ent:SetAngles(Angle(0,0,0))
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel( "models/props_pipes/pipe03_connector01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:SetOverlayText("Oil Well")
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:GetPhysicsObject():EnableMotion(false)
	self.Linked = false
	self.Oil = 100000
	self.plug1 = self:CreatePlug(Vector(130,130,-1016))
	self.plug2 = self:CreatePlug(Vector(-130,130,-1016))
	self.plug3 = self:CreatePlug(Vector(-130,-130,-1016))
	self.plug4 = self:CreatePlug(Vector(130,-130,-1016))
	print(self:GetPos())
	self:Think()
end
function ENT:OnRemove( )
	offsetsIndex = 0
	self.plug1:Remove()
	self.plug2:Remove()
	self.plug3:Remove()
	self.plug4:Remove()
end

local plugRopeAttachPoint = {}
local plugRopeAttachPointIndex = 1

function ENT:CreatePlug(offset)
	local plug = ents.Create("harbor_oilpump")
	local Random = math.random(-180,180)
	plug.OilWell = self
	plug:SetPos(self:GetPos()+offset)
	plug:Spawn()
	plug:Activate()
	plug:GetPhysicsObject():EnableMotion(true)
	plug:SetAngles(Angle(0,180,0))
	--local Bone1, Bone2 = self:GetBone(0),	 plug:GetBone(0)
	local WPos1, WPos2 = self:GetPos(),	 plug:GetPos()
	local constraint, rope = constraint.Rope( self, plug, 0, 0, offset*0.95, plug:GetForward()*-11, 10, 800, 0, 3, "cable/cable2", false )
	
	plugRopeAttachPoint[plugRopeAttachPointIndex] = offset*0.95
	plugRopeAttachPointIndex = plugRopeAttachPointIndex + 1


	plug.smoothyaw = 0
	plug.smoothpitch = 0
	plug.IsHeld = false
	return plug
end

function ENT:SendOilToAll(amount)
	self.plug1:SendOil(amount)
	self.plug2:SendOil(amount)
	self.plug3:SendOil(amount)
	self.plug4:SendOil(amount)
end

local function resetPlug(ent,index)

	if ent:GetPos().z < 740 then
		local newPos = ent:GetPos()
		newPos.z = 1134
		ent:SetPos(newPos)
		ent:GetPhysicsObject():SetVelocity(Vector(0,0,0))
		ent:SetAngles(Angle(0,180,0))

		constraint.RemoveConstraints( ent, "Rope")
		local constraint, rope = constraint.Rope( ent.OilWell, ent, 0, 0, plugRopeAttachPoint[index], ent:GetForward()*-11, 10,800, 0, 3, "cable/cable2", false )
	
	end


end

function ENT:Think()

	local PlugsLinked = 0
	if !self.plug1:IsValid() or !self.plug2:IsValid() or !self.plug3:IsValid() or !self.plug4:IsValid() then
		return false
	end
	PlugsLinked = self.plug1:CheckLinked() + self.plug2:CheckLinked() + self.plug3:CheckLinked() + self.plug4:CheckLinked()

	self:SendOilToAll(math.Round(MaxOilPerTick/PlugsLinked))

	self:NextThink( CurTime() + 0.1 )

	resetPlug(self.plug1,1)
	resetPlug(self.plug2,2)
	resetPlug(self.plug3,3)
	resetPlug(self.plug4,4)
	

	return true
end
