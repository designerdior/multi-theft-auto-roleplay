local connection = exports.sas_mysql:getConnection()


addEventHandler("onResourceStart", resourceRoot,function()
	dbQuery(function(qh)
		local res, rows, err = dbPoll(qh, 0)
		if rows > 0 then
			for k, row in pairs(res) do
				loadOnePet(row["id"])
			end
		end
	end,connection,"SELECT * FROM pets")
end)

function spawnPet(id, player)
	--outputChatBox("pet")
	dbExec(connection,"UPDATE pets SET spawned=? WHERE id=?",1,id)

	dbQuery(function(qh)
		local res, rows, err = dbPoll(qh, 0)
		if rows > 0 then
			local x,y,z = getElementPosition(player)
			--outputChatBox("pet")
			for k, row in pairs(res) do
			 	if row["type"] == 1 then
					ped = createPed(9,x+0.6, y, z)
				elseif row["type"] == 2 then
					ped = createPed(296,x+0.6, y, z)
				elseif row["type"] == 3 then
					ped = createPed(297,x+0.6, y, z)
				elseif row["type"] == 4 then
					ped = createPed(298,x+0.6, y, z)
				elseif row["type"] == 5 then
					ped = createPed(257,x+0.6, y, z)
				elseif row["type"] == 6 then
					ped = createPed(256,x+0.6, y, z)
				end
				if isElement(ped) then
					setPedRotation(ped, row["rotation"])
					setElementInterior(ped, row["interior"])
					setElementDimension(ped, row["dimension"])
					setElementHealth(ped, row["health"])
					setElementData(ped,"pet:type", row["type"])
					setElementData(ped,"pet:owner", row["owner"])
					setElementData(ped,"pet:food", row["food"])
					setElementData(ped,"pet:thirsty", row["thirsty"])
					setElementData(ped,"pet:love", row["love"])
					setElementData(ped,"pet:follow", false)
					setElementData(ped,"nameEnabled",true)
					setElementData(ped,"name", row["name"])
					setElementData(ped,"visiblePedName", row["name"])
					setElementData(ped,"tagName", "PET")
					setElementData(ped,"petTag", getPetType(getElementData(ped,"pet:type")))
					setElementData(ped,"id", id)
					setElementData(ped,"isPet", true)
					setElementData(ped,"pet:spawned", 1)
				end
			end
		end
	end,connection,"SELECT * FROM pets WHERE id = ?",id)
end

setTimer(function()
	if isElement(ped) then
		triggerClientEvent ( root, "syncMoving", ped )
	end
end, 200, 0)

setTimer(function()
	if isElement(ped) then
		triggerClientEvent ( root, "syncAttack", ped )
	end
end, 200, 0)

function loadOnePet(id)
	--outputChatBox("pet")
--	dbExec(connection,"UPDATE pets SET spawned=? WHERE id=?",1,id)

	dbQuery(function(qh)
		local res, rows, err = dbPoll(qh, 0)
		if rows > 0 then

			--outputChatBox("pet")
			for k, row in pairs(res) do
				if row["spawned"] == 1 then
					if row["type"] == 1 then
						ped = createPed(9,row["x"], row["y"], row["z"])
					elseif row["type"] == 2 then
						ped = createPed(296,row["x"], row["y"], row["z"])
					elseif row["type"] == 3 then
						ped = createPed(297,row["x"], row["y"], row["z"])
					elseif row["type"] == 4 then
						ped = createPed(298,row["x"], row["y"], row["z"])
					elseif row["type"] == 5 then
						ped = createPed(257,row["x"], row["y"], row["z"])
					elseif row["type"] == 6 then
						ped = createPed(256,row["x"], row["y"], row["z"])
					end
				end
				if row["spawned"] == 1 then
					if isElement(ped) then
						setPedRotation(ped, row["rotation"])
						setElementInterior(ped, row["interior"])
						setElementDimension(ped, row["dimension"])
						setElementHealth(ped, row["health"])
						setElementData(ped,"pet:type", row["type"])
						setElementData(ped,"pet:owner", row["owner"])
						setElementData(ped,"pet:food", row["food"])
						setElementData(ped,"pet:thirsty", row["thirsty"])
						setElementData(ped,"pet:love", row["love"])
						setElementData(ped,"pet:follow", false)
						setElementData(ped,"nameEnabled",true)
						setElementData(ped,"name", row["name"])
						setElementData(ped,"visiblePedName", row["name"])
						setElementData(ped,"tagName", "PET")
						setElementData(ped,"petTag", getPetType(getElementData(ped,"pet:type")))
						setElementData(ped,"id", id)
						setElementData(ped,"isPet", true)
						setElementData(ped,"pet:spawned", 1)
					end
				end
			end
		end
	end,connection,"SELECT * FROM pets WHERE id = ?",id)
end

function savePet(pet)
	local x,y,z = getElementPosition(pet)
	local rot = getPedRotation(pet)
	local interior = getElementInterior(pet)
	local dimension = getElementDimension(pet)
	local health = getElementHealth(pet)
	local food = getElementData(pet,"pet:food")
	local thirsty = getElementData(pet,"pet:thirsty")
	local love = getElementData(pet,"pet:love")
	local name = getElementData(pet,"name")
	local owner = getElementData(pet,"pet:owner")
	--local spawned = getElementData(pet,"pet:spawned")
	dbExec(connection,"UPDATE pets SET x=?, y=?, z=?, rotation=?, interior=?, dimension=?, health=?, food=?, thirsty=?, love=?, name=?, owner=? WHERE id=?",tonumber(x),tonumber(y),tonumber(z),rot,interior,dimension,health,food,thirsty,love,name,owner,getElementData(pet, "id"))
end

addEventHandler("onResourceStop",resourceRoot,function()
	for k,v in ipairs(getElementsByType("ped")) do
		if getElementData(v,"isPet") then
			savePet(v)
		end
	end
end)

addEvent("playPetSound", true)
addEventHandler("playPetSound", root, function(p, soundfile)
	triggerClientEvent(root, "playPetSound", root, p, soundfile)
end)

addEvent("warpPetIntoVehicle", true)
addEventHandler("warpPetIntoVehicle", root, function(pet, veh)
	warpPedIntoVehicle(pet, veh)
end)


addEvent("removePetFromVehicle", true)
addEventHandler("removePetFromVehicle", root, function(pet, veh)
	removePedFromVehicle(pet)
end)

addEvent("setSimiAnim",true)
addEventHandler("setSimiAnim",getRootElement(),function(playerSource)
	setPedAnimation (playerSource, "bomber", "bom_plant", -1, true, false, false, false)
end)

addEvent("removeSimiAnim",true)
addEventHandler("removeSimiAnim",getRootElement(),function(playerSource)
	setPedAnimation(playerSource,nil,nil)
end)

setTimer(function()
	for k,v in ipairs(getElementsByType("ped")) do
		if getElementData(v,"isPet") then
			if getElementData(v,"pet:food") >= 1 then
				setElementData(v,"pet:food",getElementData(v,"pet:food")-math.random(1,3))
			end
			if getElementData(v,"pet:food") <= 10 then
				setElementHealth(v,getElementHealth(v)-math.random(3,5))
			end
		end
	end
end,60000*8,0)


setTimer(function()
	for k,v in ipairs(getElementsByType("ped")) do
		if getElementData(v,"isPet") then
			if getElementData(v,"pet:love") >= 1 then
				setElementData(v,"pet:love",getElementData(v,"pet:love")-math.random(1,3))
			end
		end
	end
end,60000*12,0)

function getPetType(typ)
	if typ == 1 then
		return "Huski"
	elseif typ == 2 then
		return "Doberman"
	elseif typ == 3 then
		return "Doberman"
	elseif typ == 4 then
		return "Pitbull"
	elseif typ == 5 then
		return "type5"
	elseif typ == 6 then
		return "type6"
	elseif typ == 7 then
		return "Bull terrier"
	elseif typ == 8 then
		return "Doberman"
	elseif typ == 9 then
		return "Német vizsla"
	end
end

function createPetServer(player, name, petType)
	if player then
		if (tostring(type(tonumber(petType))) == "number") then
			local x, y, z = getElementPosition(player)
			local interior = getElementInterior(player)
			local dimension = getElementDimension(player)
			local rot = getPedRotation(player)
			local owner = getElementData(player,"dbid")
			dbQuery(function(qh)
				local query, query_lines,id = dbPoll(qh, 0)
				local id = tonumber(id)
				if id > 0 then
					--loadOnePet(id)
				end
			end,connection,"INSERT INTO pets SET x = ? , y = ? , z = ? , interior = ? , dimension = ? , rotation = ? , type = ?, name = ?, owner = ?",x, y, z,interior,dimension,rot,petType,name,owner)
		end
	end
end

addCommandHandler("makepet",function(playerSource,cmd,target,typ,...)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if not (target) or not typ then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/"..cmd.." [ID/Név] [Tipus] [Név]", playerSource,61,122,188,true)
			outputChatBox("Tipus:#ffffff 1(Dalmata), 2(Labrador), 3(Németjuhasz), 4(Rottweiler), 5(Sharpei), 6(Husky), 7(Bull terrier), 8(Doberman), 9(Német vizsla)", playerSource,255,255,255, true)
		else
			if (tostring(type(tonumber(typ))) == "number") then
				local targetPlayer, targetPlayerName = exports['global']:findPlayerByPartialNick(playerSource, target)
				if targetPlayer then
					local name = table.concat({...}, " ")
					local x, y, z = getElementPosition(targetPlayer)
					local interior = getElementInterior(targetPlayer)
					local dimension = getElementDimension(targetPlayer)
					local rot = getPedRotation(targetPlayer)
					local owner = getElementData(targetPlayer,"dbid")
					dbQuery(function(qh)
						local query, query_lines,id = dbPoll(qh, 0)
						local id = tonumber(id)
						if id > 0 then
							outputChatBox("[SeeMTA]:#ffffff Sikeresen leraktál egy pet-et. #3D7ABC("..id..")", playerSource,61,122,188, true)
							loadOnePet(id)
						end
					end,connection,"INSERT INTO pets SET x = ? , y = ? , z = ? , interior = ? , dimension = ? , rotation = ? , type = ?, name = ?, owner = ?",x, y, z,interior,dimension,rot,typ,name,owner)
				end
			else
				outputChatBox("[SeeMTA]:#ffffff Hibás tipus.", playerSource,61,122,188,true)
			end
		end
	end
end)

addCommandHandler("delpet", function(playerSource)
	if getElementData(playerSource, "adminlevel") >= 8 then
		local count = 0
		local x,y,z = getElementPosition(playerSource)
		for k,v in ipairs(getElementsByType("ped")) do
			if getElementData(v,"isPet") then
				local px,py,pz = getElementPosition(v)
				if getDistanceBetweenPoints3D(x,y,z,px,py,pz)<=2 then
					count=count+1
					dbQuery(function(qh, v)
						local res, rows, err = dbPoll(qh, 0)
						if rows > 0 then
							outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen töröltél egy pet-et. #3D7ABC("..tonumber(getElementData(v, "id"))..")", playerSource,61,122,188, true)
							destroyElement(v)
						end
					end, {v}, connection,"DELETE FROM pets WHERE id = ?",tonumber(getElementData(v, "id")))
				end
			end
		end
		if count == 0 then
			outputChatBox("[SeeMTA]:#ffffff Nincs a közeledben pet.", playerSource,61,122,188, true)
		end
	end
end)

addCommandHandler("nearbypets", function(playerSource)
	if getElementData(playerSource, "adminlevel") >= 8 then
		local count = 0
		local x,y,z = getElementPosition(playerSource)
		for k,v in ipairs(getElementsByType("ped")) do
			if getElementData(v,"isPet") then
				local px,py,pz = getElementPosition(v)
				if getDistanceBetweenPoints3D(x,y,z,px,py,pz)<=2 then
					count=count+1
					outputChatBox("#7cc576[SeeMTA - PET]: #FFFFFF "..getElementData(v,"id").." #3D7ABC-#ffffff "..getElementData(v,"name").."",playerSource,61,122,188, true)
				end
			end
		end
		if count == 0 then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFF Nincs a közeledben pet.", playerSource,61,122,188, true)
		end
	end
end)

function respawnPet(id)
	if id then
		if (tostring(type(tonumber(id))) == "number") then
			local count = 0
			for k,v in ipairs(getElementsByType("ped")) do
				if getElementData(v, "isPet") then
					if tonumber(getElementData(v,"id")) == tonumber(id) then
						count = count+1
						respawnToPet(v)
						exports.sas_hud:addNotification("Sikeresen felélesztetted a kutyádat!", "success")
					end
				end
			end
		end
	end
end

function respawnToPet(pet)
	local x,y,z = getElementPosition(pet)
	local rot = getPedRotation(pet)
	local interior = getElementInterior(pet)
	local dimension = getElementDimension(pet)
	local health = 100
	local food = 100
	local thirsty = 100
	local love = 100
	local name = getElementData(pet,"name")
	local owner = getElementData(pet,"pet:owner")
	dbExec(connection,"UPDATE pets SET x=?, y=?, z=?, rotation=?, interior=?, dimension=?, health=?, food=?, thirsty=?, love=?, name=?, owner=? WHERE id=?",x,y,z,rot,interior,dimension,health,food,thirsty,love,name,owner,getElementData(pet, "id"))
	loadOnePet(getElementData(pet,"id"))
	destroyElement(pet)
end

function despawnPet(id)
	if id then
		if (tostring(type(tonumber(id))) == "number") then
			local count = 0
			for k,v in ipairs(getElementsByType("ped")) do
				if getElementData(v, "isPet") then
					if tonumber(getElementData(v,"id")) == tonumber(id) then
						count = count+1
						dbExec(connection,"UPDATE pets SET spawned=? WHERE id=?",0,id)
						savePet(v)
						destroyElement(v)
					end
				end
			end
		end
	end
end

addCommandHandler("respawnpet",function(playerSource,cmd,id)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if id then
			if (tostring(type(tonumber(id))) == "number") then
				local count = 0
				for k,v in ipairs(getElementsByType("ped")) do
					if getElementData(v, "isPet") then
						if tonumber(getElementData(v,"id")) == tonumber(id) then
							count = count+1
							respawnToPet(v)
							outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen respawn-oltál egy állatot.", playerSource,61,122,188, true)
						end
					end
				end
				if count == 0 then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFF Hibás pet id.", playerSource,61,122,188, true)
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFF Csak számot.", playerSource,61,122,188, true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF /"..cmd.." [petID]", playerSource,61,122,188, true)
		end
	end
end)

addCommandHandler("setpetowner",function(playerSource,cmd,target,id)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if target or id then
			if (tostring(type(tonumber(id))) == "number") then
				local targetPlayer, targetPlayerName = exports['global']:findPlayerByPartialNick(playerSource, target)
				if targetPlayer then
					if getElementData(targetPlayer,"loggedin") == 1 then
						local count = 0
						for k,v in ipairs(getElementsByType("ped")) do
							if getElementData(v, "isPet") then
								if tonumber(getElementData(v,"id")) == tonumber(id) then
									count = count+1
									outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen megváltoztattad az állat tulajdonosát. #3D7ABC("..getElementData(v,"pet:owner").." -> "..tonumber(getElementData(targetPlayer,"dbid"))..")", playerSource,61,122,188, true)
									outputChatBox("#7cc576[SeeMTA]: #FFFFFF Tulajdonodba adott #3D7ABC"..getElementData(playerSource,"anev").."#ffffff egy állatot. #3D7ABC("..tostring(getElementData(v,"name"))..")", targetPlayer,61,122,188, true)
									setElementData(v,"pet:owner",tonumber(getElementData(targetPlayer,"dbid")))
								end
							end
						end
						if count == 0 then
							outputChatBox("#d9534f[SeeMTA]: #FFFFFF Hibás pet id.", playerSource,61,122,188, true)
						end
					else
						outputChatBox("#d9534f[SeeMTA]: #FFFFFF A kiválasztott játékos nincs bejelentkezve.", playerSource,61,122,188, true)
					end
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFF Csak számot.", playerSource,61,122,188, true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF /"..cmd.." [játékosID] [petID]", playerSource,61,122,188, true)
		end
	end
end)

addCommandHandler("setpetname",function(playerSource,cmd,id,...)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if id or (...) then
			if (tostring(type(tonumber(id))) == "number") then
				name = table.concat({...}, " ")
				local count = 0
				for k,v in ipairs(getElementsByType("ped")) do
					if getElementData(v, "isPet") then
						if tonumber(getElementData(v,"id")) == tonumber(id) then
							count = count+1
							outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen megváltoztattad a pet nevét. #3D7ABC("..getElementData(v,"name").." -> "..name..")", playerSource,61,122,188, true)
							setElementData(v,"name",name)
						end
					end
				end
				if count == 0 then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFF Hibás pet id.", playerSource,61,122,188, true)
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFF Csak számot.", playerSource,61,122,188, true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF /"..cmd.." [petID] [Név]", playerSource,61,122,188, true)
		end
	end
end)

addCommandHandler("getpet",function(playerSource,cmd,id)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if id then
			if (tostring(type(tonumber(id))) == "number") then
				local count = 0
				local x,y,z = getElementPosition(playerSource)
				for k,v in ipairs(getElementsByType("ped")) do
					if getElementData(v, "isPet") then
						if tonumber(getElementData(v,"id")) == tonumber(id) then
							count = count+1
							setElementPosition(v,x,y,z)
							outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen magadhoz teleportáltál egy pet-et.", playerSource,61,122,188, true)
						end
					end
				end
				if count == 0 then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFF Hibás pet id.", playerSource,61,122,188, true)
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFF Csak számot.", playerSource,61,122,188, true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF /"..cmd.." [petID]", playerSource,61,122,188, true)
		end
	end
end)

addCommandHandler("gotopet",function(playerSource,cmd,id)
	if getElementData(playerSource, "adminlevel") >= 8 then
		if id then
			if (tostring(type(tonumber(id))) == "number") then
				local count = 0
				for k,v in ipairs(getElementsByType("ped")) do
					if getElementData(v, "isPet") then
						if tonumber(getElementData(v,"id")) == tonumber(id) then
							count = count+1
							local x,y,z = getElementPosition(v)
							setElementPosition(playerSource,x,y,z)
							outputChatBox("#7cc576[SeeMTA]: #FFFFFF Sikeresen oda teleportáltál egy pet-hez.", playerSource,61,122,188, true)
						end
					end
				end
				if count == 0 then
					outputChatBox("#d9534f[SeeMTA]: #FFFFFF Hibás pet id.", playerSource,61,122,188, true)
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFF Csak számot.", playerSource,61,122,188, true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF /"..cmd.." [petID]", playerSource,61,122,188, true)
		end
	end
end)
