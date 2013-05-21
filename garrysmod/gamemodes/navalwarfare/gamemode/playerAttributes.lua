--I DID THIS FOR YOU
function InitAllAttributes()
	for k,v in pairs(player.GetAll()) do InitNilAttributes(v) end
end
function InitNilAttributes(ply)
--print(ply)
	if ply.attr == nil then
		ply.attr = {}
	end
	if ply.attr["prop_limmit"] == nil then
		ply.attr["prop_limmit"] = 200
	end
	if ply.attr["gun_limmit"] == nil then
		ply.attr["gun_limmit"] = 2
	end
	if ply.attr["monney"] == nil then
		ply.attr["monney"] = 5000
	end
	if ply.attr["armor_resistance"] == nil then
		ply.attr["armor_resistance"] = 1 --player takes 100% damage
	end
	if ply.attr["barter"] == nil then
		ply.attr["barter"] = 1 --player recieves full price 
	end
	if ply.attr["speed_limmit"] == nil then
		ply.attr["speed_limmit"] = 100 -- wtf speedlimit how the fuck
	end
	if ply.attr["has_liscense"] == nil then
		ply.attr["has_liscense"] = false --no piolots liscense
	end
	if ply.attr["rof"] == nil then
		ply.attr["rof"] = 1 --100% rate of fire
	end
	if ply.attr["score"] == nil then
		ply.attr["score"] = 0
	end
	if ply.attr["copper"] == nil then
		ply.attr["copper"] = 1000
	end
	if ply.attr["barrel_limmit"] == nil then
		ply.attr["barrel_limmit"] = 1
	end
	if ply.attr["merch_level"] == nil then
		ply.attr["merch_level"] = 1
	end
	if ply.attr["inAlpha"] == nil then
		ply.attr["inAlpha"] = true
	end
	if ply.attr["oil_speed"] == nil then
		ply.attr["oil_speed"] = 1
	end



end

local function OnPlayerAuth( ply, steamID, UID)	
	local fileName = "navalwarfare/playerData/"..string.gsub(steamID,":","")..".txt"
	fileName = string.gsub(fileName,"_","")
	if not file.Exists(fileName,"DATA") then
		ply.attr = {}
		ply.attr["prop_limmit"] = 200
		ply.attr["gun_limmit"] = 2
		ply.attr["monney"] = 5000
		ply.attr["armor_resistance"] = 1 --player takes 100% damage
		ply.attr["barter"] = 1 --player recieves full price 
		ply.attr["speed_limmit"] = 100 -- wtf speedlimit how the fuck
		ply.attr["has_liscense"] = false --no piolots liscense
		ply.attr["rof"] = 1 --100% rate of fire
		ply.attr["score"] = 0
		ply.attr["copper"] = 1000
		ply.attr["barrel_limmit"] = 1
		ply.attr["merch_level"] = 1
		ply.attr["inAlpha"] = true
		ply.attr["oil_speed"] = 1
		ply.firstJoin = true
		savePlayerData(ply)
		--newPlayer(ply)
		print("Created new player file at "..fileName.." for "..ply:Nick())
	else 
		local plyData = file.Read(fileName,"DATA")
		print("Loaded player data for "..ply:Nick())
		ply.attr = von.deserialize(plyData)	
		ply.firstJoin = false
	end
	InitNilAttributes(ply)
	setMoney(ply,ply.attr["monney"])
	ply:SetNWInt("credits",ply.attr["monney"])
	ply:SetNWInt("score", ply.attr["score"])
	ply:SetNWInt("merch_level", ply.attr["merch_level"])
	ply:SetNWInt("barrel_limmit", ply.attr["barrel_limmit"])
	
end
hook.Add("PlayerAuthed", "NavalWarfare_PlayerAuthed_LoadAttributes", OnPlayerAuth)
--local function newPlayer(ply) end

function addScore(ply,val)
	ply.attr["score"] = val + ply.attr["score"]
	ply:SetNWInt("score",ply.attr["score"])
end
function changeMoney(ply,val,isScorable)
	val = math.Round(val)
	if ply.attr==nil then return false end
	if ply.attr["monney"] + val >= 0 then 
		if val > 0  and  isScorable then
			addScore(ply,val)
		end
		setMoney(ply,ply.attr["monney"] + val)
		--print(val)
		return true 
	end
	return false
end
function setMoney(ply,val)
	if ply.attr==nil then return false end
	if val != ply.attr["monney"] then
		ply.attr["monney"] = val
		--print(val)
		ply:SetNWInt("credits",val)
	end
end

function saveAllPlayerData()

	local players = player.GetAll()
	if #players > 0 then
		for k,v in pairs(players) do
			savePlayerData(v)
		end
		print("Saved all player data")
	end
	timer.Create( "saveAllPlayerData", 60, 1, saveAllPlayerData)
end
hook.Add( "InitPostEntity", "navalwarfare_start_save_timer", saveAllPlayerData)
function savePlayerData( ply )
	local fileName = "navalwarfare/playerData/"..string.gsub(ply:SteamID(),":","")..".txt"
	fileName = string.gsub(fileName,"_","")
	file.Write(fileName,von.serialize(ply.attr))
end
hook.Add( "PlayerDisconnected", "navalwarfare_saveDCData", savePlayerData )


function resetAllPlayersMoney()
	for k,v in pairs(player.GetAll()) do
		setMoney(v,5000)
	end
end