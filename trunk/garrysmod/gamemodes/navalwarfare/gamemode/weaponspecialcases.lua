local function SpawnedProp(ply, model, ent)
	ent.NWHealth = ent:GetPhysicsObject():GetVolume()/150
end 
hook.Add("PlayerSpawnedProp", "playerSpawnedProp", SpawnedProp)

local function TakeDamage( ent, dmginfo )
	if !ent:GetPhysicsObject() or dmginfo:GetDamageType()==DMG_CRUSH then
		return false
	end
	if ent.NWArmor == nil then ent.NWArmor = 1 end
	if ent.NWHealth == nil then ent.NWHealth = ent:GetPhysicsObject():GetVolume()/100 end
	if ent.MNWHealth == nil then 
		ent:SetNWInt("NWMHealth", ent:GetPhysicsObject():GetVolume()/100 )
		ent.MNWHealth = ent:GetPhysicsObject():GetVolume()/100
	end
	local effectdata = EffectData()
	effectdata:SetStart(dmginfo:GetDamagePosition())
	effectdata:SetOrigin(dmginfo:GetDamagePosition())
	effectdata:SetScale(5)
	effectdata:SetEntity(ent)
	util.Effect("entity_remove", effectdata)
	
	if ent.FPPOwner!=nil and ent.FPPOwner:GetClass()=="player" then
		local amount = dmginfo:GetDamage()
		local victim = ent.FPPOwner
		local attacker = dmginfo:GetInflictor()
		if attacker:IsPlayer() or attacker:GetClass("harbor_projectile") then
			if attacker:IsPlayer() and victim:IsPlayer() and attacker:Team()==victim:Team() then return end
			ent.NWHealth = ent.NWHealth - amount * ent.NWArmor
			if ent.NWHealth < 0 then
				local vPoint = ent:GetPos()
				local effectdata = EffectData()
				effectdata:SetStart( vPoint )
				effectdata:SetOrigin( vPoint )
				effectdata:SetScale( 1 )
				util.Effect( "HelicopterMegaBomb", effectdata )	
				ent:Remove()
			end
		end
	end
	ent:SetNWInt("NWHealth", ent.NWHealth)
end
hook.Add("EntityTakeDamage", "navalwarfaredamage", TakeDamage)