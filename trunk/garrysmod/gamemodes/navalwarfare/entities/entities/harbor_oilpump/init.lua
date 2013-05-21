AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "harbor_oilpump" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end
function ENT:Initialize()
	self:SetModel("models/props_lab/tpplug.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(50)
	end
	self:SetOverlayText("herp")
	self.Oil = 1
	self.Tank = nil
	self.Linked = false
	self.IsHeld = false
	self.IsPlug = true
	self.MaxTransferPerTick = 4
	self.TransferedThisTick = 0
end
function ENT:CheckLinked()
	if self.Tank != nil and self.Tank:IsValid() and self.Linked and self.Tank.MaxOil>self.Tank.Oil then
		return 1
	end
	return 0
end
function ENT:SendOil(resource)
	if self.Linked then
		if self.Tank != nil and self.Tank:IsValid() and self.Tank.Oil < self.Tank.MaxOil then
			--print(self.Tank.Owner)
			local mul = 1
			if self.Tank.Owner.attr != nil then
				local add = (self.Tank.Owner.attr["oil_speed"] - 1)*0.05	
				mul = 1 + add
				--print("test")
			end
			self.Tank.Oil = self.Tank.Oil + resource * mul
			
			return true
		else
			return false
		end
	end
	return false
end
function ENT:Think()
	if self.IsPlug == nil then self.IsPlug = true end
	if not self.IsHeld then
		if self.Tank==nil or not self.Tank:IsValid() then
			local nearestEnt = nil
			local olddistance = 200
			for _, ent in pairs( ents.FindInSphere( self:GetPos(), 500 ) ) do
				if(ent.ISTANK==true) then
					local distance = (self:GetPos():Distance(ent:GetPos()+ent.connectionpoint))
					if( distance < olddistance && distance < 1000 ) then
						olddistance = distance
						nearestEnt = ent
					end
				end
			end
			self.Tank = nearestEnt
		else
			local Distance = self:GetPos():Distance(self.Tank:GetPos()+self.Tank.connectionpoint)
			if Distance>self.Tank.DisconnectDistance then
				self.Tank = nil
			elseif !self:IsPlayerHolding()&&Distance<self.Tank.ConnectDistance&&self.Tank:IsValid() then
				if self.Linked == false and self.Tank.Linked == false or self.Linked == false and self.Tank.Linked == nil then
					--print(!IsValid(self.Tank.FPPOwner))
					if self.Tank.FPPOwner == nil or !IsValid(self.Tank.FPPOwner) or self.Tank.FPPOwner:IsPlayer() and self.Tank.FPPOwner:Team() == RigCapturedBy then
						self:SetPos(self.Tank:GetPos()+self.Tank.connectionpoint)
						self:SetAngles(self.Tank.GetAttachmentAngle(self.Tank))
						self:GetPhysicsObject():EnableMotion(false)
						local weld = constraint.Weld( self, self.Tank, 0, 0, 0, true )
						self.Tank.Linked = true
						if weld and weld:IsValid() then
							self.Tank:DeleteOnRemove( weld )
							self:DeleteOnRemove( weld )
							self.Weld = weld
							self.shouldunweld = true
						end
						self:GetPhysicsObject():EnableMotion(true)
						self.Linked = true
						self.Tank.Linked = true
					end
				end
				self:SetOverlayText("Connected")
			else
				if self.Linked == true then
					self.Linked = false
					self.Tank.Linked = false
					self.Tank = nil
					if self.Weld != nil then
						print("REMOVING WELD; ERRORS DIRECTLY BELOW DO NOT MATTER!")
						self.Weld:Remove()
					end
					self:GetPhysicsObject():EnableMotion(true)
				end
				self:SetOverlayText("Disconnected")
			end
		end
	else
		self:SetOverlayText("Holstered")
	end
	self:NextThink( CurTime() + 0.1)
	return true
end
local function EntityTakeDamage(ent, inflictor, attacker, amount, dmginfo)
	if(dmginfo!=nil) then
		local ouch = dmginfo:GetInflictor():GetClass()
		if(ouch=="harbor_oilpump") then
			dmginfo:ScaleDamage(0)
		else
			print(ouch)
		end
	end
end
hook.Add("EntityTakeDamage", "navalwarfare_PlugAntidammage", EntityTakeDamage, ent, inflictor, attacker, amount, dmginfo)