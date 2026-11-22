local connection = exports.sas_mysql:getConnection()

local lastUsed = {}

function saveVehicle(source)
	local dbid = tonumber(getElementData(source, "dbid")) or -1
	
	if isElement(source) and getElementType(source) == "vehicle" and dbid >= 0 then
		local owner = getElementData(source, "owner")
		if (owner~=-1) then
			local fuel = getElementData(source, "fuel")
			local engine = getElementData(source, "engine")
			local locked = isVehicleLocked(source) and 1 or 0		
			local lights = getVehicleOverrideLights(source)
			local sirens = getVehicleSirensOn(source) and 1 or 0
			local Impounded = getElementData(source, "Impounded") or 0
			local handbrake = getElementData(source, "handbrake") or 0
			local health = getElementHealth(source)
			local dimension = getElementDimension(source)
			local interior = getElementInterior(source)

			local wheel1, wheel2, wheel3, wheel4 = getVehicleWheelStates(source)
			local wheelState = toJSON( { wheel1, wheel2, wheel3, wheel4 } )
			
			local panel0 = getVehiclePanelState(source, 0)
			local panel1 = getVehiclePanelState(source, 1)
			local panel2 = getVehiclePanelState(source, 2)
			local panel3 = getVehiclePanelState(source, 3)
			local panel4 = getVehiclePanelState(source, 4)
			local panel5 = getVehiclePanelState(source, 5)
			local panel6 = getVehiclePanelState(source, 6)
			local panelState = toJSON( { panel0, panel1, panel2, panel3, panel4, panel5, panel6 } )
				
			local door0 = getVehicleDoorState(source, 0)
			local door1 = getVehicleDoorState(source, 1)
			local door2 = getVehicleDoorState(source, 2)
			local door3 = getVehicleDoorState(source, 3)
			local door4 = getVehicleDoorState(source, 4)
			local door5 = getVehicleDoorState(source, 5)
			local doorState = toJSON( { door0, door1, door2, door3, door4, door5 } )

			dbExec(connection, "UPDATE vehicles SET panelStates=?, wheelStates=?, doorStates=?, fuel=?, engine=?, locked=?, lights=?, hp=?, sirens=?, Impounded=?, handbrake=? WHERE id=?", panelState, wheelState, doorState, fuel, engine, locked, lights, health, sirens, Impounded, handbrake, dbid)
		end
	end
end

function savePlayer(source)
	if not getElementData(source, "loggedin") then return end
	local x, y, z = getElementPosition(source)
	local _, _, rotation = getElementPosition(source)
	dbExec(connection, "UPDATE characters SET charname=?, health=?, armor=?, hunger=?, thirst=?, money=?, bankmoney=?, pp=?, skin=?, x=?, y=?, z=?, rotation=?, interior=?, dimension=?, description=?, walkstyle=?, fightstyle=?, maxvehicles=?, job=?, bone=?, blueprints=?, timeinserver=? WHERE id=?", getElementData(source, "charname"), getElementHealth(source), getPedArmor(source), getElementData(source, "hunger"), getElementData(source, "thirst"), getElementData(source, "money"), getElementData(source, "bankmoney"), getElementData(source, "pp"), getElementModel(source), x, y, z, rotation, getElementInterior(source), getElementDimension(source), getElementData(source, "description"), getPedWalkingStyle(source), getPedFightingStyle(source), getElementData(source, "maxvehicles"), getElementData(source, "job"), toJSON(getElementData(source, "bone")), toJSON(getElementData(source, "blueprints")), getElementData(source, "timeinserver"), getElementData(source, "dbid"))
end
addEventHandler("onPlayerQuit", getRootElement(), function()
	savePlayer(source)
end)

function saveAllPlayer()
	for k, v in ipairs(getElementsByType("player")) do
		savePlayer(v)
	end
end
addEventHandler("onResourceStop", resourceRoot, saveAllPlayer)

addEventHandler("onVehicleEnter", getRootElement(), function()
	if not lastUsed[source] then
		lastUsed[source] = true
	end
end)

function saveAllVehicle()
	local cache = lastUsed
	lastUsed = {}
	for veh in pairs(cache) do
		saveVehicle(veh)
	end
end
setTimer(saveAllVehicle, 3600000, 0)

addCommandHandler("saveveh", function()
	print("[SAVE] Összes jármű mentése folyamatban!")
	saveAllVehicle()
end)

addCommandHandler("saveplr", function()
	print("[SAVE] Összes játékos mentése folyamatban!")
	saveAllPlayer()
end)

addCommandHandler("saveall", function()
	print("[SAVE] Összes játékos & jármű mentése folyamatban!")
	saveAllPlayer()
	saveAllVehicle()
end)