include('shared.lua')
local Laser = Material("cable/redlaser")
function ENT:Draw()
	self:DrawModel()
	if self:GetNWBool("fire") then
		local pos = self:GetPos()
		local ang = self:GetAngles()
		
		local tracedata = {}
		tracedata.start = pos + self:GetUp()*300
		tracedata.endpos = pos + (self:GetUp()*5000)
		tracedata.filter = self
		
		local trace = util.TraceLine(tracedata)
		render.SetBlend(0.5)
		if trace.Hit then
			local StartPos = self:GetPos()
			local EndPos   = trace.HitPos
			render.SetMaterial(Laser)
			render.DrawBeam(StartPos, EndPos, 200, 1, 1, Color(255,255,255,255))
		else
			local StartPos = self:GetPos()
			local EndPos   = pos + (self:GetUp()*5000)
			render.SetMaterial(Laser)
			render.DrawBeam(StartPos, EndPos, 200, 1, 1, Color(255,255,255,255))
		end
		effects.halo.Add({trace.Entity}, Color(255,0, 0), 4, 4, 2, true, true)
	end
end