local Origen = Vector(9252, 9211, 768)
local NextFindTime = 0
local Term = 0
local OldTerm = 0
local caps = 0
local pathticker = 0
local dealtwith = false
RigCapturedBy = TEAM_NEUTRAL
currentNPCS = {}
local function UpdateCaps(plys)
	for k,v in pairs(plys) do
		umsg.Start("sendrigcaps")
			umsg.Short(caps)
		umsg.End()
	end

end
local function printCapture()
	for k,v in pairs(player.GetAll()) do
		if RigCapturedBy == TEAM_USA then
			v:PrintMessage( HUD_PRINTTALK, "The USA has captured the oil rig!")
		elseif RigCapturedBy == TEAM_USSR then 
			v:PrintMessage( HUD_PRINTTALK, "The USSR has captured the oil rig!")
		else
			v:PrintMessage( HUD_PRINTTALK, "The rig has been contested!")
		end
	end
end
local function SendUsrMessage(herp)
	umsg.Start( "sendteamrig" )
		umsg.Short( herp )
	umsg.End()
	RigCapturedBy = herp
	printCapture()
end

local function dealWithResets()
	local harbor_ents = ents.FindInSphere(Origen,1280)
	local harbor_npcs = {}
	for k,v in pairs ( harbor_ents ) do
		if v:GetClass() == "npc_combine_S" or v:GetClass() == "npc_citizen" then
			v:Remove()
			v:Remove()
		end
	end
end
hook.Add( "PostGamemodeLoaded", "navalwarfare_dealWithResets", dealWithResets )

local function spawnNPCs(model, vec)
	local npc = ents.Create(model)
	npc:SetPos(vec)
		npc:SetKeyValue( "additionalequipment", "weapon_smg1" )
	npc:Spawn()
	npc:CapabilitiesAdd(CAP_MOVE_GROUND)
	npc:CapabilitiesAdd(CAP_ANIMATEDFACE)
	npc:CapabilitiesAdd(CAP_TURN_HEAD)
	npc:CapabilitiesAdd(CAP_USE_SHOT_REGULATOR)
	npc:CapabilitiesAdd(CAP_AIM_GUN)
	npc:CapabilitiesAdd(CAP_USE_WEAPONS)
	npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
	
	npc:SetNPCState(NPC_STATE_COMBAT)
	npc:SetSchedule(SCHED_RANGE_ATTACK1)
	
	for k,v in pairs ( player.GetAll() ) do
		if v:Team() == RigCapturedBy then
			npc:AddEntityRelationship(v, D_LI, 99)
		else
			npc:AddEntityRelationship(v, D_HT, 99)
		end
	end
	npc:FearSound()
	return npc
end

local function conspawnNPCs(player2, command, arguments)
	local model = arguments[1]
	local vec = player2:GetShootPos() + Vector(0,0,300)
	spawnNPCs(model, vec)
end
concommand.Add("harbor_spawnnpc", conspawnNPCs)

local function makeNPCs(derp)
	local count = 0
	if table.Count(currentNPCS) == 0 and dealtwith == false then
		dealtwith = true
		dealWithResets()
		--print("OMGRAWR")
	end
	for k,v in pairs ( currentNPCS ) do
		if v:IsValid() then
			count = count + 1
		end
	end
	if derp == TEAM_USA then
		for i=0, 10-count do
			for j=0, 50 do
				local X = math.random(8311, 10180)
				local Y = math.random(8245, 10153)
				local Z = 1500
				local pos = Vector(X,Y,Z)
				local tracedata = {}
				tracedata.start = pos
				tracedata.endpos = pos + Vector(0,0,500)
				tracedata.filter = self

				local trace = util.TraceLine(tracedata)
				if !trace.Hit then
					currentNPCS[i] = spawnNPCs("npc_combine_S",Vector(X,Y,Z))
					break
				end
			end
		end
	elseif derp == TEAM_USSR then
		for i=1, 10-count do
			for j=0, 50 do
				local X = math.random(8311, 10180)
				local Y = math.random(8245, 10153)
				local Z = 1500
				local pos = Vector(X,Y,Z)
				local tracedata = {}
				tracedata.start = pos
				tracedata.endpos = pos + Vector(0,0,500)
				tracedata.filter = self

				local trace = util.TraceLine(tracedata)
				if !trace.Hit then
					currentNPCS[i] = spawnNPCs("npc_citizen",Vector(X,Y,Z))
					break
				end
			end
		end
	elseif derp == 7 then
		for k,v in pairs ( currentNPCS ) do
			if v:IsValid() then
				v:Remove()
			end
		end
	end
end

local function fuckwithpaths()
	if pathticker > 100 then
		pathticker = 0
		for k,v in pairs ( currentNPCS ) do
			if v:IsValid() then
				local X = math.random(8311, 10180)
				local Y = math.random(8245, 10153)
				local Z = 1024
				local pos = Vector(X,Y,Z)
				v:SetLastPosition( pos )
				v:SetSchedule( SCHED_FORCED_GO_RUN )
				--print(v)
			end
		end
	else
		pathticker = pathticker + 1
	end
end
hook.Add("Think", "harbor_pathfuck", fuckwithpaths)

function DetectPlayers()
	
    if (CurTime() >= NextFindTime) then
		local allplayers = player.GetAll()
		local usaPlys = 0
		local ussrPlys = 0
		local sends = {}
		for k,v in pairs ( allplayers ) do
			if(v.Zone == ZONE_OILRIG) then
				if(v:Team() == TEAM_USA) then
					usaPlys = usaPlys + 1
				elseif(v:Team() == TEAM_USSR) then
					ussrPlys = ussrPlys + 1
				end
				sends[#sends + 1] = v
			end
		end
		caps = caps + usaPlys*5 - ussrPlys*5
		if usaPlys==0 and ussrPlys==0 then
			if caps > 0 then
				caps = caps - 10
			elseif caps < 0 then
				caps = caps + 10
			end
		end
		if usaPlys != ussrPlys or usaPlys+ussrPlys == 0  then
			UpdateCaps(sends)
		end
		if caps > 100 then
			caps = 100
		elseif caps < -100 then
			caps = -100
		end
		if caps >= 90 and RigCapturedBy != TEAM_USA then
			SendUsrMessage(TEAM_USA)
			makeNPCs(TEAM_USA)
		elseif caps <= -90 and RigCapturedBy != TEAM_USSR then
			SendUsrMessage(TEAM_USSR)
			makeNPCs(TEAM_USSR)
		elseif RigCapturedBy != TEAM_NEUTRAL and math.abs(caps) < 90 then
			SendUsrMessage(TEAM_NEUTRAL)
			makeNPCs(TEAM_NEUTRAL)
		elseif caps == 0 then
			makeNPCs(7)
		end
        NextFindTime = CurTime() + 1
    end
end
hook.Add("Think", "navalwarfare_DetectPlayers_capturePoint", DetectPlayers)