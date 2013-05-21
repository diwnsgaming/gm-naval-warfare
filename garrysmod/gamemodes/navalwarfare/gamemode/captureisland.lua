local Origen = Vector(-7295.541504, -8403.884766, 520.271362)
local NextFindTime = 0
local Term = 0
local OldTerm = 0
local CapturedBy = -1
local caps = 0

--This code is being kept in solitary because it attacked one of the inmates.

--reload
-- local function SendUsrmessage(herp)
	-- umsg.Start( "sendteam" )
		-- umsg.Short( herp )
	-- umsg.End()
	-- CapturedBy = herp
-- end

-- local function UpdateCaps(plys)
	-- for k,v in pairs(plys) do
		-- umsg.Start("sendislandcaps")
			-- umsg.Short(caps)
		-- umsg.End()
	-- end
	
-- end
-- local function printCapture()
	-- for k,v in pairs(player.GetAll()) do
		-- if CapturedBy == TEAM_USA then
			-- v:PrintMessage( HUD_PRINTTALK, "The USA has captured the island!")
		-- elseif CapturedBy == TEAM_USSR then 
			-- v:PrintMessage( HUD_PRINTTALK, "The USSR has captured the island!")
		-- else
			-- v:PrintMessage( HUD_PRINTTALK, "The capture point has been contested!")
		-- end
	-- end
-- end
-- function DetectPlayers()
        -- if (CurTime() >= NextFindTime) then
		-- local allplayers = player.GetAll()
		-- local usaPlys = 0
		-- local ussrPlys = 0
		-- local sends = {}
		-- for k,v in pairs ( allplayers ) do
			-- if(v.Zone == ZONE_ISLAND) then
				-- if(v:Team() == TEAM_USA) then
					-- usaPlys = usaPlys + 1
				-- elseif(v:Team() == TEAM_USSR) then
					-- ussrPlys = ussrPlys + 1
				-- end
				-- sends[#sends + 1] = v
			-- end
		-- end
		-- caps = caps + usaPlys - ussrPlys
		-- if usaPlys != ussrPlys then
			-- UpdateCaps(sends)
		-- end
		-- if caps > 100 then
			-- caps = 100
		-- elseif caps < -100 then
			-- caps = -100
		-- end
		-- if caps >= 90 and CapturedBy != TEAM_USA then
			-- SendUsrMessage(TEAM_USA)
			-- timer.Create("navalplay_payday-captured",300,0,function() payDay(true) end)
		-- elseif caps <= -90 and CapturedBy != TEAM_USSR then
			-- SendUsrMessage(TEAM_USSR)
			-- timer.Create("navalplay_payday-captured",300,0,function() payDay(true) end)
		-- elseif CapturedBy != TEAM_NEUTRAL and math.abs(caps) < 90 then
			-- SendUsrMessage(TEAM_NEUTRAL)	
		-- end
		
        -- NextFindTime = CurTime() + 1
    -- end
-- end
-- hook.Add("Think", "navalwarfare_DetectPlayers_capturePoint", DetectPlayers)

--But seriously if you uncomment the above it will turn the island into a capture zone that rewards people with money.