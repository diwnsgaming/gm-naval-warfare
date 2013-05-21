include('shared.lua')
function DrawHalo()
	local drawTable = {}
	drawTable[0] = self
	--halo.Add(drawTable, Color(255,255,255,255), 5, 5, 2)
end

hook.Add("PreDrawHalos", "AddHalos", DrawHalo)