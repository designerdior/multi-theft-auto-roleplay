local db = exports.sas_mysql:getConnection()

local tuningData = { }

local loadedVehicle = {}

armoredCars = { [427]=true, [528]=true, [432]=true, [601]=true, [428]=true, [597]=true } -- Enforcer, FBI Truck, Rhino, SWAT Tank, Securicar, SFPD Car
totalTempVehicles = 0
respawnTimer = nil

local vehMarkersOnSide = {}

local names = {}

handlingTable =
{
	["vehicle.tuning.engine"] =
	{
		[0] = {["tuningData"] = {{"engineAcceleration"}, {"maxVelocity"}}},
		[1] = {["tuningData"] = {{"engineAcceleration", 0}, {"maxVelocity", 0}}},
		[2] = {["tuningData"] = {{"engineAcceleration", 5}, {"maxVelocity", 15}}},
		[3] = {["tuningData"] = {{"engineAcceleration", 10}, {"maxVelocity", 30}}},
		[4] = {["tuningData"] = {{"engineAcceleration", 20}, {"maxVelocity", 40}}},
		[5] = {["tuningData"] = {{"engineAcceleration", 30}, {"maxVelocity", 50}}}
	},
	["vehicle.tuning.turbo"] =
	{
		[0] = {["tuningData"] = {{"engineInertia"}}},
		[1] = {["tuningData"] = {{"engineInertia", 0}}},
		[2] = {["tuningData"] = {{"engineAcceleration", 5}}},
		[3] = {["tuningData"] = {{"engineAcceleration", 10}}},
		[4] = {["tuningData"] = {{"engineAcceleration", 15}}},
		[5] = {["tuningData"] = {{"engineAcceleration", 20}}}
	},
	["vehicle.tuning.ecu"] =
	{
		[0] = {["tuningData"] = {{"engineInertia"}}},
		[1] = {["tuningData"] = {{"engineInertia"}}},
		[2] = {["tuningData"] = {{"engineInertia", -10}}},
		[3] = {["tuningData"] = {{"engineInertia", -20}}},
		[4] = {["tuningData"] = {{"engineInertia", -30}}},
		[5] = {["tuningData"] = {{"engineInertia", -40}}}
	},
	["vehicle.tuning.valto"] =
	{
		[0] = {["tuningData"] = {{"engineInertia"}}},
		[1] = {["tuningData"] = {{"engineInertia"}}},
		[2] = {["tuningData"] = {{"engineInertia", -10}}},
		[3] = {["tuningData"] = {{"engineInertia", -20}}},
		[4] = {["tuningData"] = {{"engineInertia", -30}}},
		[5] = {["tuningData"] = {{"engineInertia", -40}}}
	},
	["vehicle.tuning.felfugg"] =
	{
		[0] = {["tuningData"] = {{"engineInertia"}}},
		[1] = {["tuningData"] = {{"engineInertia"}}},
		[2] = {["tuningData"] = {{"engineInertia", -10}}},
		[3] = {["tuningData"] = {{"engineInertia", -20}}},
		[4] = {["tuningData"] = {{"engineInertia", -30}}},
		[5] = {["tuningData"] = {{"engineInertia", -40}}}
	},
	["vehicle.tuning.nitro"] =
	{
		[0] = {["tuningData"] = 0},
		[1] = {["tuningData"] = 0},
		[2] = {["tuningData"] = 25},
		[3] = {["tuningData"] = 50},
		[4] = {["tuningData"] = 75},
		[5] = {["tuningData"] = 100}
	},
	["vehicle.tuning.tires"] =
	{
		[0] = {["tuningData"] = {{"tractionMultiplier"}, {"tractionLoss"}}},
		[1] = {["tuningData"] = {{"tractionMultiplier", 0}, {"tractionLoss", 0}}},
		[2] = {["tuningData"] = {{"tractionMultiplier", 0.10}, {"tractionLoss", 0.04}}},
		[3] = {["tuningData"] = {{"tractionMultiplier", 0.13}, {"tractionLoss", 0.07}}},
		[4] = {["tuningData"] = {{"tractionMultiplier", 0.18}, {"tractionLoss", 0.09}}},
		[5] = {["tuningData"] = {{"tractionMultiplier", 0.23}, {"tractionLoss", 0.11}}}
	},
	["vehicle.tuning.brakes"] =
	{
		[0] = {["tuningData"] = {{"brakeDeceleration"}, {"brakeBias"}}},
		[1] = {["tuningData"] = {{"brakeDeceleration", 0}, {"brakeBias", 0}}},
		[2] = {["tuningData"] = {{"brakeDeceleration", 0.10}, {"brakeBias", 0.5}}},
		[3] = {["tuningData"] = {{"brakeDeceleration", 0.15}, {"brakeBias", 0.18}}},
		[4] = {["tuningData"] = {{"brakeDeceleration", 0.24}, {"brakeBias", 0.28}}},
		[5] = {["tuningData"] = {{"brakeDeceleration", 0.34}, {"brakeBias", 0.38}}}
	},
	["vehicle.tuning.weightreduction"] =
	{
		[0] = {["tuningData"] = {{"mass"}}},
		[1] = {["tuningData"] = {{"mass", 0}}},
		[2] = {["tuningData"] = {{"mass", -20}}},
		[3] = {["tuningData"] = {{"mass", -50}}},
		[4] = {["tuningData"] = {{"mass", -100}}},
		[5] = {["tuningData"] = {{"mass", -150}}}
	}
}

addCommandHandler("makeveh", function(thePlayer, commandName, model, owner)
	if getElementData(thePlayer, "adminlevel") > 6 then
		if not tonumber(model) or not owner then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [id/NÉV] [Tulaj]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer = exports.sas_global:findPlayerByPartialNick(thePlayer, owner)

			if targetPlayer then
				local x, y, z = getElementPosition(targetPlayer)

				-- plate
				local letter1 = string.char(math.random(65,90))
				local letter2 = string.char(math.random(65,90))
				local str = "abcdefghijklmnopqrstuvwxyz"
				local plate = ""

				for index = 1, 3 do
					plate = plate .. string.char(str:byte(math.random(1, #str)))
				end

				plate = string.upper(plate)
				plate = plate .. "-"

				for index = 1, 3 do
					plate = plate .. math.random(1, 9)
				end
				-- plate

				dbExec(db, "INSERT INTO vehicles SET model=?, x=?, y=?, z=?, owner=?, plate=?, currx=?, curry=?, currz=?", tonumber(model), x, y, z, getElementData(targetPlayer, "dbid"), plate, x, y, z)

				dbQuery(function(qh, targetPlayer)
					local result, rows = dbPoll(qh, 0)
					if rows > 0 then
						local veh = loadOneVehicle(result[1])
						table.insert(getElementData(targetPlayer, "vehicles"), result[1].id)
						triggerEvent("giveItem", targetPlayer, targetPlayer, 1, result[1].id, 1, 0)
						outputChatBox("#7cc576[SeeMTA]: #FFFFFF".. getVehicleName(veh) .. " #FFFFFFlespawnolva ezzel az ID-vel: #32b3ef" .. result[1].id .. "#FFFFFF.", thePlayer, 255, 194, 14, true)
					end
				end, {targetPlayer}, db, "SELECT * FROM vehicles WHERE id=LAST_INSERT_ID()")
			end
		end
	end
end)

function makeShopVehicle(player, model, r, g, b)
	local carshopPos = {
		{2161.287109375, -1144.021484375, 24.812623977661},
		{2160.951171875, -1148.234375, 24.383399963379},
		{2160.576171875, -1153.291015625, 23.869070053101},
		{2160.765625, -1158.158203125, 23.838272094727},
		{2161.046875, -1163.3486328125, 23.81609916687},
		{2160.775390625, -1168.322265625, 23.819984436035},
		{2160.2392578125, -1173.3779296875, 23.819984436035},
		{2161.4794921875, -1177.802734375, 23.816761016846},
	}

	local rand = math.random(1, #carshopPos)
	local x, y, z = unpack(carshopPos[rand])
	
	-- plate
	local letter1 = string.char(math.random(65,90))
	local letter2 = string.char(math.random(65,90))
	local str = "abcdefghijklmnopqrstuvwxyz"
	local plate = ""

	for index = 1, 3 do
		plate = plate .. string.char(str:byte(math.random(1, #str)))
	end

	local plate = string.upper(plate)
	local plate = plate .. "-"

	for index = 1, 3 do
		plate = plate .. math.random(1, 9)
	end
	-- plate

	dbExec(db, "INSERT INTO vehicles SET model=?, x=?, y=?, z=?, owner=?, plate=?, currx=?, curry=?, currz=?, r=?, g=?, b=?", model, x, y, z, getElementData(player, "dbid"), plate, x, y, z, r, g, b)

	dbQuery(function(qh, player)
		local result, rows = dbPoll(qh, 0)
		if rows > 0 then
			table.insert(getElementData(player, "vehicles"), result[1].id)
			triggerEvent("giveItem", player, player, 1, result[1].id, 1, 0)
			local veh = loadOneVehicle(result[1])
			setTimer(warpPedIntoVehicle, 1000, 1, player, veh)
		end
	end, {player}, db, "SELECT * FROM vehicles WHERE id=LAST_INSERT_ID()")
end

function loadOneVehicle(row)
	if loadedVehicle[row.id] then return end
	loadedVehicle[row.id] = createVehicle(row.model, row.currx, row.curry, row.currz, 0, 0, row.currrot, row.plate)

	local veh = loadedVehicle[row.id]

	setElementData(veh, "dbid", row.id)

	setVehicleColor(veh, row.r, row.g, row.b)

	setVehiclePaintjob(veh, row.paintjob)

	setVehicleDamageProof(veh, false)

	local upgrades = fromJSON(row["upgrades"])
	for slot, upgrade in ipairs(upgrades) do
		if upgrade and tonumber(upgrade) > 0 then
			addVehicleUpgrade(veh, upgrade)
		end
	end

	local panelStates = fromJSON(row["panelStates"])
	for panel, state in ipairs(panelStates) do
		setVehiclePanelState(veh, panel-1 , tonumber(state) or 0)
	end

	local wheelStates = fromJSON(row["wheelStates"])
	setVehicleWheelStates(veh, tonumber(wheelStates[1]) , tonumber(wheelStates[2]) , tonumber( wheelStates[3]) , tonumber(wheelStates[4]) )

	setVehicleLocked(veh, row.locked == 1)
	setElementData(veh, "locked", row.locked == 1)

	setVehicleSirensOn(veh, row.sirens == 0)

	if row.job > 0 then
		toggleVehicleRespawn(veh, true)
		setVehicleRespawnDelay(veh, 60000)
		setVehicleIdleRespawnDelay(veh, 180000)
		setElementData(veh, "job", row.job)
	else
		setElementData(veh, "job", 0)
	end

	setVehicleDamageProof(veh, false)
	setVehicleRespawnPosition(veh, row.x, row.y, row.z, 0, 0, row.rot)
	setElementData(veh, "respawnposition", {row.x, row.y, row.z, 0, 0, row.rot})

	setElementData(veh, "kilometerek", row.kilometerek)
	setElementData(veh, "olajszint", row.olajszint)
	-- setElementData(veh, "kilometerek", row.kilometerek)
	setElementData(veh, "fuel", row.fuel)
	setElementData(veh, "oldx", 0)
	setElementData(veh, "oldy", 0)
	setElementData(veh, "oldz", row.currrot)
	setElementData(veh, "faction", tonumber(row.faction))
	setElementData(veh, "owner", tonumber(row.owner))
	setElementData(veh, "handbrake", 0)
	setElementData(veh, "kezifek", false)
	setElementData(veh, "vehicle:windowstat", 0, true)

	setElementData(veh, "Impounded", tonumber(row.Impounded))
	setVehicleDamageProof(veh, false)

	setElementData(veh, "tuningadatok", {})


	setElementDimension(veh, row.currdimension)
	setElementInterior(veh, row.currinterior)

	setElementData(veh, "dimension", row.dimension)
	setElementData(veh, "interior", row.interior)

	setVehicleOverrideLights(veh, row.lights == 0 and 1 or row.lights )

	setElementHealth(veh, row.hp)
	setVehicleDamageProof(veh, false)
	setVehicleEngineState(veh, false)
	setElementData(veh, "engine", false)
	setElementData(veh, "enginebroke", false)

	setVehicleFuelTankExplodable(veh, false)

	if row.handbrake > 0 then
		setElementFrozen(veh, true)
	end

	-- refill
	local data = sideMarkers[row.model]
	if data then
		local x, y, z = getElementPosition(veh)
		vehMarkersOnSide[row.id] = createMarker(x, y, z, "cylinder", 0.6, 0, 0, 0, 0)
		attachElements(vehMarkersOnSide[row.id], veh, data[1], data[2], data[3])
		setElementData(veh, "Veh->fuelPos", vehMarkersOnSide[row.id])
		setElementData(vehMarkersOnSide[row.id], "Fuel->tankMarker", veh)
	end

	-- Load tunings
	local r = tostring(row["r"])
	local g = tostring(row["g"])
	local b = tostring(row["b"])
	local r1 = tostring(row["r1"])
	local g1 = tostring(row["g1"])
	local b1 = tostring(row["b1"])
	setVehicleColor(veh, r, g, b, r1, g1, b1)
	local model = getElementModel(veh)
	exports.sas_paintjob:addVehiclePaintJob(veh, model, row.sticker)
	setElementData(veh, "PaintJob", row.sticker)
	local jsonWheelStates = fromJSON(tostring(row["wheelStates"]))
	local jsonUpgrades = fromJSON(tostring(row["opticalTunings"]))
	local jsonPerformance = fromJSON(tostring(row["performanceTuning"]))
	local headlight = fromJSON(tostring(row["headlight"]))
	local var = tonumber(row["var"])
	setVehicleVariant(veh, var, var)
	setElementData(veh, "Variant", var)

	for index, value in ipairs(jsonUpgrades) do
		if value and value > 0 then
			setElementData(veh, "vehicle.tuning." .. index, value)
			addVehicleUpgrade(veh, value)
		end
	end
	local LSDDoor = tostring(row["LSDDoor"])
	if LSDDoor == "true" then
		LSDDoor = true
	end
	if LSDDoor == "false" then
		LSDDoor = false
	end
	setElementData(veh, "tuning.lsdDoor", LSDDoor)

	local trafiRadar = tostring(row["trafiRadar"])
	if trafiRadar == "true" then
		trafiRadar = true
	end
	if trafiRadar == "false" then
		trafiRadar = false
	end
	setElementData(veh, "vehicle.tuning.trafiRadar", trafiRadar)

	local seeGO = tostring(row["seeGO"])
	if seeGO == "false" then
		seeGO = false
	end
	if seeGO == "1" then
		seeGO = 1
	end
	if seeGO == "2" then
		seeGO = 2
	end
	setElementData(veh, "vehicle.tuning.seeGO", seeGO)

	local airRide = tostring(row["airRide"])
	if airRide == "true" then
		airRide = true
	end
	if airRide == "false" then
		airRide = false
	end
	setElementData(veh, "tuning.airRide", airRide)
	local wheelFront = tonumber(row["wheelFront"])
	local wheelRear = tonumber(row["wheelRear"])
	local offroadAbility = tonumber(row["offroadAbility"])
	local driveType = tostring(row["driveType"])
	exports["sas_tuning"]:setVehicleHandlingFlags(veh, 3, wheelFront)
	exports["sas_tuning"]:setVehicleHandlingFlags(veh, 4, wheelRear)
	exports["sas_tuning"]:setVehicleHandlingFlags(veh, 6, offroadAbility)
	setVehicleHandling(veh, "driveType", driveType, false)
	local neonTuning = tostring(row["neonTuning"])
	--if not neonTuning == "false" or not neonTuning == false then
		setElementData(veh, "vehicle.tuning.neon", neonTuning)
		--setElementData(veh, "vehicle.neon.active")
	--end
	setVehicleHeadLightColor(veh, headlight[1], headlight[2], headlight[3])
	setVehicleWheelStates(veh, jsonWheelStates[1], jsonWheelStates[2], jsonWheelStates[3], jsonWheelStates[4])
	if jsonPerformance[1] then
		setElementData(veh, "vehicle.tuning.engine", jsonPerformance[1])
		--outputChatBox("felszerelve vehiclesys")
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.engine"][jsonPerformance[1]]["tuningData"])
		--outputChatBox("felszerelve vehiclesys")
	end
	if jsonPerformance[2] then
		setElementData(veh, "vehicle.tuning.turbo", jsonPerformance[2])
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.turbo"][jsonPerformance[2]]["tuningData"])
		--outputChatBox("felszerelve turbo")
	end
	if jsonPerformance[3] then
		setElementData(veh, "vehicle.tuning.ecu", jsonPerformance[3])
		--outputChatBox("felszerelve vehiclesys")
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.ecu"][jsonPerformance[3]]["tuningData"])
	end
	if jsonPerformance[4] then
		setElementData(veh, "vehicle.tuning.valto", jsonPerformance[4])
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.valto"][jsonPerformance[4]]["tuningData"])
	end
	if jsonPerformance[5] then
		setElementData(veh, "vehicle.tuning.felfugg", jsonPerformance[5])
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.felfugg"][jsonPerformance[5]]["tuningData"])
	end
	if jsonPerformance[6] then
		setElementData(veh, "vehicle.tuning.brakes", jsonPerformance[6])
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.brakes"][jsonPerformance[6]]["tuningData"])
	end
	if jsonPerformance[7] then
		setElementData(veh, "vehicle.tuning.tires", jsonPerformance[7])
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.tires"][jsonPerformance[7]]["tuningData"])
	end
	if jsonPerformance[8] then
		setElementData(veh, "vehicle.tuning.nitro", jsonPerformance[8])
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.nitro"][jsonPerformance[8]]["tuningData"])
	end
	if jsonPerformance[9] then
		setElementData(veh, "vehicle.tuning.weightreduction", jsonPerformance[9])
		exports["sas_tuning"]:performanceUpgrade(veh, handlingTable["vehicle.tuning.weightreduction"][jsonPerformance[9]]["tuningData"])
	end
	return veh
end

addEventHandler("onElementDataChange", getRootElement(), function(theKey, oldValue, newValue)
	if getElementType(source) == "player" and theKey == "loggedin" and newValue then
		dbQuery(function(qh, source)
			local result, rows = dbPoll(qh, 0)
			if rows > 0 then
				local vehicleCache = {}
				for _, data in ipairs(result) do
					local veh = loadOneVehicle(data)
					table.insert(vehicleCache, data.id)
				end
				setElementData(source, "vehicles", vehicleCache)
			end
		end, {source}, db, "SELECT * FROM vehicles WHERE owner=?", getElementData(source, "dbid"))
	end
end)

addEventHandler("onPlayerQuit", getRootElement(), function()
	local vehicleCache = getElementData(source, "vehicles") or {}
	for _, id in ipairs(vehicleCache) do
		if isElement(loadedVehicle[id]) then destroyElement(loadedVehicle[id]) end
		loadedVehicle[id] = nil
	end
end)

function vehicleExploded()
	local job = getElementData(source, "job")

	if not job or job<=0 then
		setTimer(respawnVehicle, 60000, 1, source)
	end
end
addEventHandler("onVehicleExplode", getRootElement(), vehicleExploded)

function vehicleRespawn(exploded)
	local id = getElementData(source, "dbid")
	local faction = getElementData(source, "faction")
	local job = getElementData(source, "job")
	local owner = getElementData(source, "owner")
	local windowstat = getElementData(source, "vehicle:windowstat")

	if (job>0) then
		toggleVehicleRespawn(source, true)
		setVehicleRespawnDelay(source, 60000)
		setVehicleIdleRespawnDelay(source, 180000)
		setElementFrozen(source, true)
		setElementData(source, "handbrake", 1)
	end

	-- Set the vehicle armored if it is armored
	local vehid = getElementModel(source)
	if (armoredCars[tonumber(vehid)]) then
		setVehicleDamageProof(source, true)
	else
		setVehicleDamageProof(source, false)
	end

	setVehicleFuelTankExplodable(source, false)
	setVehicleEngineState(source, false)
	setVehicleLandingGearDown(source, true)

	setElementData(source, "enginebroke", false)

	setElementData(source, "dbid", id)
	setElementData(source, "fuel", 100)
	setElementData(source, "engine", false)
	setElementData(source, "vehicle:windowstat", windowstat)

	local x, y, z = getElementPosition(source)
	setElementData(source, "oldx", x)
	setElementData(source, "oldy", y)
	setElementData(source, "oldz", z)

	setElementData(source, "faction", faction)
	setElementData(source, "owner", owner)

	setVehicleOverrideLights(source, 1)
	setElementFrozen(source, false)

	-- Set the sirens off
	setVehicleSirensOn(source, false)

	setVehicleLightState(source, 0, 0)
	setVehicleLightState(source, 1, 0)

	local dimension = getElementDimension(source)
	local interior = getElementInterior(source)

	setElementDimension(source, dimension)
	setElementInterior(source, interior)

	-- unlock civ vehicles
	if owner == -2 then
		setVehicleLocked(source, false)
		setElementData(source, "locked", false)
		setElementFrozen(source, true)
		setElementData(source, "handbrake", 1)
	end
end
addEventHandler("onVehicleRespawn", getRootElement(), vehicleRespawn)

function setEngineStatusOnEnter(thePlayer, seat)
	if seat == 0 then
		local engine = getElementData(source, "engine")
		local model = getElementModel(source)
		if not (enginelessVehicle[model]) then
			if not engine then
				toggleControl(thePlayer, 'brake_reverse', false)
				setVehicleEngineState(source, false)
			else
				toggleControl(thePlayer, 'brake_reverse', true)
				setVehicleEngineState(source, true)
			end
		else
			toggleControl(thePlayer, 'brake_reverse', true)

			setVehicleEngineState(source, true)
			setElementData(source, "engine", true)
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), setEngineStatusOnEnter)

function vehicleExit(thePlayer, seat)
	if (isElement(thePlayer)) then
		toggleControl(thePlayer, 'brake_reverse', true)
		-- For oldcar
		local vehid = getElementData(source, "dbid")
		setElementData(thePlayer, "lastvehid", vehid)
	end
end
addEventHandler("onVehicleExit", getRootElement(), vehicleExit)

function destroyTyre(veh)
	local tyre1, tyre2, tyre3, tyre4 = getVehicleWheelStates(veh)

	if (tyre1==1) then
		tyre1 = 2
	end

	if (tyre2==1) then
		tyre2 = 2
	end

	if (tyre3==1) then
		tyre3 = 2
	end

	if (tyre4==1) then
		tyre4 = 2
	end

	if (tyre1==2 and tyre2==2 and tyre3==2 and tyre4==2) then
		tyre3 = 0
	end

	setElementData(veh, "tyretimer", 0)
	setVehicleWheelStates(veh, tyre1, tyre2, tyre3, tyre4)
end

function damageTyres()
	local tyre1, tyre2, tyre3, tyre4 = getVehicleWheelStates(source)
	local tyreTimer = getElementData(source, "tyretimer")

	if (tyretimer~=1) then
		if (tyre1==1) or (tyre2==1) or (tyre3==1) or (tyre4==1) then
			setElementData(source, "tyretimer", 1)
			local randTime = math.random(5, 15)
			randTime = randTime * 1000
			setTimer(destroyTyre, randTime, 1, source)
		end
	end
end
addEventHandler("onVehicleDamage", getRootElement(), damageTyres)

addEvent("setVehicleLocked", true)
addEventHandler("setVehicleLocked", getRootElement(), function(state)
	setVehicleLocked(source, state)
end)

addEvent("setVehicleEngineState", true)
addEventHandler("setVehicleEngineState", getRootElement(), function(state)
	setVehicleEngineState(source, state)
end)

-- bike lock fix
function checkBikeLock(thePlayer)
	if (isVehicleLocked(source)) and (getVehicleType(source)=="Bike" or getVehicleType(source)=="Boat" or getVehicleType(source)=="BMX" or getVehicleType(source)=="Quad" or getElementModel(source)==568 or getElementModel(source)==571 or getElementModel(source)==572 or getElementModel(source)==424) then
		if not getElementData(thePlayer, "interiormarker") then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFA jármű bevan zárva.", thePlayer, 255, 194, 15, true)
		end
		cancelEvent()
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), checkBikeLock)

function setRealInVehicle(thePlayer)
	if getElementType(thePlayer) ~= "player" then return end
	if isVehicleLocked(source) then
		setElementData(thePlayer, "realinvehicle", 0)
	else
		setElementData(thePlayer, "realinvehicle", 1)

		local owner = getElementData(source, "owner")
		local faction = getElementData(source, "faction")
		local carName = getVehicleName(source)
		local id = getElementData(source, "dbid")

		outputChatBox("#dc143c[SeeMTA]:#FFFFFF A rádió bekapcsolásához használd az #32b3ef[R] #FFFFFFgombot!", thePlayer, 255, 255, 255, true)
		--local theVehicle = getPedOccupiedVehicle ( playerSource )
		if not getVehicleEngineState ( source ) then
			outputChatBox("#dc143c[SeeMTA]:#98ba65 A jármű elindításához fordítsd el a gyújtáskapcsolót és indítsd a motort!", thePlayer, 255, 255, 255, true)
			outputChatBox("#dc143c[SeeMTA]:#98ba65 (( Tartsd lenyomva a #FFFFFF'J' #98ba65betűt, mellé pedig szintén tartsd lenyomva a #FFFFFF'Space' #98ba65-t, amíg a motor be nem indul. )) ", thePlayer, 255, 255, 255, true)
		end
		if (owner < 0) and (faction == -1) then
			if getElementData(thePlayer, "adminduty") then
				outputChatBox("#7cc576[SeeMTA - Admin]:#FFFFFF Civil jármű #32b3ef(" .. carName .. ") ( "..id.." )", thePlayer, 255, 195, 14, true)
			end
		elseif (faction==-1) and (owner>0) then
			local ownerName = getCharacterName(owner)

			if ownerName then
				if getElementData(thePlayer, "adminduty") then
					outputChatBox("#7cc576[SeeMTA - Admin]:#FFFFFF A jármű tulaja: #32b3ef" .. ownerName .. " #FFFFFF(( ID: "..id.." ))", thePlayer, 255, 195, 14, true)
				end
				if (getElementData(source, "Impounded") > 0) then
					local output = getRealTime().yearday-getElementData(source, "Impounded")
					outputChatBox("(( Ez a " .. carName .. ", le van foglalva " .. output .. (output == 1 and " Napra." or " Napra.") .. " ))", thePlayer, 255, 195, 14)
				end
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), setRealInVehicle)

function vipvehicle(thePlayer)
	if not isVehicleLocked(source) then
		local owner = getElementData(source, "owner")
		if (owner == 5844) and ( exports.sas_global:isPlayerBronzeDonator(thePlayer) or exports.sas_global:isPlayerAdmin(thePlayer) )  then
		elseif (owner == 5844) then
			outputChatBox("Ez a kocsi VIP tagoknak van fenntartva.",thePlayer,22,222,222)
			cancelEvent()
			return
		end
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), vipvehicle)
function setRealNotInVehicle(thePlayer)
	local locked = isVehicleLocked(source)

	if not (locked) then
		if (thePlayer) then
			setElementData(thePlayer, "realinvehicle", 0)
		end
	end
end
addEventHandler("onVehicleStartExit", getRootElement(), setRealNotInVehicle)

function removeFromFactionVehicle(thePlayer)
	local faction = getElementData(thePlayer, "faction")
	local vfaction = tonumber(getElementData(source, "faction"))

	if (vfaction~=-1) then

		local seat = getPedOccupiedVehicleSeat(thePlayer)
		local factionName = "this faction"
		for key, value in ipairs(getElementsByType("team")) do
			local id = tonumber(getElementData(value, "id"))
			if (id==vfaction) then
				factionName = getTeamName(value)
				break
			end
		end

		if (faction~=vfaction) and (seat==0) then
			--outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem vagy a tagja a '" .. factionName .. "'-nek/nak.", thePlayer, 255, 194, 14, true)
		end
	end
	local Impounded = getElementData(source,"Impounded")
	if (Impounded and Impounded > 0) then
		setElementData(source, "enginebroke", true)
		setVehicleDamageProof(source, false)
		setVehicleEngineState(source, false)
	end
end
addEventHandler("onVehicleEnter", getRootElement(), removeFromFactionVehicle)

-- engines dont break down
function doBreakdown()
	local health = getElementHealth(source)
	local broke = getElementData(source, "enginebroke")

	if health <= 350 and not broke then
		setElementHealth(source, 250)
		setVehicleDamageProof(source, true)
		setVehicleEngineState(source, false)
		setElementData(source, "enginebroke", true)
		setElementData(source, "engine", false)

		local player = getVehicleOccupant(source)
		if player then
			toggleControl(player, 'brake_reverse', false)
		end
	end
end
addEventHandler("onVehicleDamage", getRootElement(), doBreakdown)

------------------------------------------------
-- SELLS A VEHICLE bugosgeci
------------------------------------------------
function sellVehicle(thePlayer, commandName, targetPlayerName)
	if isPedInVehicle(thePlayer) then
		if not targetPlayerName then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/" .. commandName .. " [név / id]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayerName)
			if targetPlayer and getElementData(targetPlayer, "dbid") then
				local px, py, pz = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)
				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) < 20 then
					local theVehicle = getPedOccupiedVehicle(thePlayer)
					if theVehicle then
						local vehicleID = getElementData(theVehicle, "dbid")
						if getElementData(theVehicle, "owner") == getElementData(thePlayer, "dbid") or exports.sas_global:isSuperAdmin(thePlayer) then
							if getElementData(targetPlayer, "dbid") ~= getElementData(theVehicle, "owner") then
								if exports.sas_global:hasSpaceForItem(targetPlayer, 3) then
									if exports.sas_global:canPlayerBuyVehicle(targetPlayer) then
										--if query then
											setElementData(theVehicle, "owner", getElementData(targetPlayer, "dbid"))

											exports.sas_items:giveItem(targetPlayer, 1, vehicleID, 1, 0)

											--exports.logs:logMessage("[SELL] car #" .. vehicleID .. " was sold from " .. getPlayerName(thePlayer):gsub("_", " ") .. " to " .. targetPlayerName, 9)

											outputChatBox("#7cc576[SeeMTA]: #FFFFFFSikeresen eladtad a " .. getVehicleName(theVehicle) .. "#e7d9b0-t neki" .. targetPlayerName .. "#e7d9b0.", thePlayer, 0, 255, 0, true)
											outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " eladtad a " .. getVehicleName(theVehicle) .. "-t.", targetPlayer, 0, 255, 0)
										--else
											--outputChatBox("Error 09001 - Jelentsd a fórumon.", thePlayer, 255, 0, 0)
										--end
									else
										outputChatBox(targetPlayerName .. " -nek/nak túl sok járműve van", thePlayer, 255, 0, 0)
										outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " Megpróbálod eladni az autót, de már túl sok van neki. ", targetPlayer, 255, 0, 0)
									end
								else
									outputChatBox(targetPlayerName .. " nincs elég hely a kulcsoknak", thePlayer, 255, 0, 0)
									outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " megpróbálod eladni a járműved, de nincs helye a kulcsoknak.", targetPlayer, 255, 0, 0)
								end
							else
								outputChatBox("#d9534f[SeeMTA]: #FFFFFFMagadnak nem bírod eladni a kocsid.", thePlayer, 255, 0, 0, true)
							end
						else
							outputChatBox("#d9534f[SeeMTA]: #FFFFFFEz a jármű nem a tiéd.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFA járműben kell lenned.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFTúl messze vagy tőle  " .. targetPlayerName .. ".", thePlayer, 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("sell", sellVehicle)

function fillFuelTank(veh, fuel)
	local currFuel = getElementData(veh, "fuel")
	local engine = getElementData(veh, "engine")
	if (math.ceil(currFuel)==100) then
		outputChatBox("A kocsi már tele van.", source)
	elseif (fuel==0) then
		outputChatBox("#d9534f[SeeMTA]: #FFFFFFA kocsiba nincs üzemanyag.", source, 255, 0, 0, true)
	elseif (engine==1) then
		outputChatBox("#d9534f[SeeMTA]: #FFFFFFÜzemanyag nélkül nem tudod elindítani a motort.", source, 255, 0, 0, true)
	else
		local fuelAdded = fuel

		if (fuelAdded+currFuel>100) then
			fuelAdded = 100 - currFuel
		end

		outputChatBox("Hozzá adtál " .. math.ceil(fuelAdded) .. " liter benzint.", source, 0, 255, 0 )

		local gender = getElementData(source, "gender")
		local genderm = "his"
		if (gender == 1) then
			genderm = "her"
		end
		exports.sas_chat:sendLocalMeAction(source, "Feltöltted a járművet.")

		setElementData(veh, "fuel", currFuel+fuelAdded)
	end
end
addEvent("fillFuelTankVehicle", true)
addEventHandler("fillFuelTankVehicle", getRootElement(), fillFuelTank)

function quitPlayer ( quitReason )
	if (quitReason == "Timed out") then
		if (isPedInVehicle(source)) then
			local vehicleSeat = getPedOccupiedVehicleSeat(source)
			if (vehicleSeat == 0) then
				local theVehicle = getPedOccupiedVehicle(source)
				local dbid = tonumber(getElementData(theVehicle, "dbid"))
				if (exports.sas_items:hasKey(source, 1, dbid)) then
					if not isVehicleLocked(theVehicle) then
						local passenger1 = getVehicleOccupant( theVehicle , 1 )
						local passenger2 = getVehicleOccupant( theVehicle , 2 )
						local passenger3 = getVehicleOccupant( theVehicle , 3 )
						if (passenger1 == false) then
							if (passenger2 == false) then
								if (passenger3 == false) then
									lockUnlockOutside(theVehicle)
									local engine = getElementData(theVehicle, "engine")
									if engine then
										setVehicleEngineState(theVehicle, false)
										setElementData(theVehicle, "engine", false)
									end
									setElementData(theVehicle, "handbrake", 1)
									setElementData(theVehicle, "kezifek", false)
									setElementFrozen(theVehicle, true)
								end
							end
						end
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerQuit",getRootElement(), quitPlayer)

-- /unflip
function unflipCar(thePlayer, commandName, targetPlayer)
	if (exports.sas_global:isPlayerAdmin(thePlayer) or getTeamName(getPlayerTeam(thePlayer)) == "Szerelo") then
		if not targetPlayer then
			if not (isPedInVehicle(thePlayer)) then
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFNem vagy jármûben.", thePlayer, 255, 0, 0, true)
			else
				local veh = getPedOccupiedVehicle(thePlayer)
				local rx, ry, rz = getVehicleRotation(veh)
				setVehicleRotation(veh, 0, ry, rz)
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFA jármûved nincs felfordulva!", thePlayer, 0, 255, 0, true)
			end
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				else
					local pveh = getPedOccupiedVehicle(targetPlayer)
					if pveh then
						local rx, ry, rz = getVehicleRotation(pveh)
						setVehicleRotation(pveh, 0, ry, rz)
						if getElementData(thePlayer, "hiddenadmin") == 1 then
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFA jármûved helyreállította egy Rejtett Admin.", targetPlayer, 0, 255, 0, true)
						else
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFA jármûved helyreállította " .. getPlayerName(thePlayer):gsub("_", " ") .. ".", targetPlayer, 0, 255, 0, true)
						end
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFHelyreállítottad " .. targetPlayerName:gsub("_"," ") .. " jármûvét.", thePlayer, 0, 255, 0, true)
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFF".. (targetPlayerName:gsub("_"," ")) .. " #FFFFFFnincs jármûben.", thePlayer, 255, 0, 0, true)
					end
				end
			end
		end
	end
end
addCommandHandler("unflip", unflipCar, false, false)

-- /veh
local leadplus = { [425] = true, [520] = true, [447] = true, [432] = true, [444] = true, [556] = true, [557] = true, [441] = true, [464] = true, [501] = true, [465] = true, [564] = true, [476] = true }
function createTempVehicle(thePlayer, commandName, modelID)
	if (exports.sas_global:isPlayerLeadAdmin(thePlayer)) then
		if not modelID then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF /" .. commandName .. " [ID/NÉV]", thePlayer, 255, 194, 14, true)
		else
			local vehicleID = tonumber(modelID)

			local r = getPedRotation(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			x = x + ( ( math.cos ( math.rad ( r ) ) ) * 5 )
			y = y + ( ( math.sin ( math.rad ( r ) ) ) * 5 )

			local str = "abcdefghijklmnopqrstuvwxyz"
			local plate = ""
			for index = 1, 3 do
				plate = plate .. string.char(str:byte(math.random(1, #str)))
			end
			plate = string.upper(plate)
			plate = plate .. "-"
			for index = 1, 3 do
				plate = plate .. math.random(1, 9)
			end

			if vehicleID then
				if leadplus[ vehicleID ] and not exports.sas_global:isPlayerLeadAdmin(thePlayer) then
					outputChatBox( "#7cc576[SeeMTA]: #FFFFFFNincs hozzáférés.", thePlayer, 255, 0, 0, true)
					return
				end

				local veh = createVehicle(vehicleID, x, y, z, 0, 0, r, plate)

				if not (veh) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFHelytelen jármû ID.", thePlayer, 255, 0, 0, true)
				else
					if (armoredCars[vehicleID]) then
						setVehicleDamageProof(veh, true)
					end

					totalTempVehicles = totalTempVehicles + 1
					local dbid = (-totalTempVehicles)

					setElementInterior(veh, getElementInterior(thePlayer))
					setElementDimension(veh, getElementDimension(thePlayer))

					setVehicleOverrideLights(veh, 1)
					setVehicleEngineState(veh, false)
					setVehicleFuelTankExplodable(veh, false)

					setElementData(veh, "dbid", dbid)
					setElementData(veh, "fuel", 100)
					setElementData(veh, "Impounded", 0)
					setElementData(veh, "engine", false)
					setElementData(veh, "oldx", x)
					setElementData(veh, "oldy", y)
					setElementData(veh, "oldz", z)
					setElementData(veh, "faction", -1)
					setElementData(veh, "owner", -1)
					setElementData(veh, "job", 0)
					setElementData(veh, "handbrake", 0)
					outputChatBox("#7cc576[SeeMTA]: #FFFFFF".. (getVehicleName(veh)) .. " #FFFFFFlespawnolva, ezzel az ID-vel: " .. dbid .. ".", thePlayer, 255, 194, 14, true)

				end
			else
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFHelytelen jármû ID.", thePlayer, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("veh", createTempVehicle, false, false)

-- /oldcar
function getOldCarID(thePlayer, commandName)
	local oldvehid = getElementData(thePlayer, "lastvehid")

	if not (oldvehid) then
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFMég nem száltál be jármûbe a csatlakozásod óta.", thePlayer, 255, 0, 0)
	else
		outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFFRégi jármû ID: #32b3ef" .. tostring(oldvehid) .. "#FFFFFF.", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("oldcar", getOldCarID, false, false)

-- /thiscar
function getCarID(thePlayer, commandName)
	local veh = getPedOccupiedVehicle(thePlayer)

	if (veh) then
		local dbid = getElementData(veh, "dbid")
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFJármû ID: #32b3ef" .. dbid, thePlayer, 255, 194, 14, true)
	else
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFNem vagy kocsidban.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("thiscar", getCarID, false, false)

-- /gotocar
function gotoCar(thePlayer, commandName, id)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (id) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF/" .. commandName .. " #FFFFFF[id]", thePlayer, 255, 194, 14, true)
		else
			local theVehicle = loadedVehicle[tonumber(id)]
			if theVehicle then
				local rx, ry, rz = getVehicleRotation(theVehicle)
				local x, y, z = getElementPosition(theVehicle)
				x = x + ( ( math.cos ( math.rad ( rz ) ) ) * 5 )
				y = y + ( ( math.sin ( math.rad ( rz ) ) ) * 5 )

				setElementPosition(thePlayer, x, y, z)
				setPedRotation(thePlayer, rz)
				setElementInterior(thePlayer, getElementInterior(theVehicle))
				setElementDimension(thePlayer, getElementDimension(theVehicle))

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFTeleportálva lettél a jármûhöz.", thePlayer, 255, 194, 14, true)
			else
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFÉrvénytelen jármû ID.", thePlayer, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("gotocar", gotoCar, false, false)

-- /getcar
function getCar(thePlayer, commandName, id)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (id) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF /" .. commandName .. " [id]", thePlayer, 255, 194, 14, true)
		else
			local theVehicle = loadedVehicle[tonumber(id)]
			if theVehicle then
				local r = getPedRotation(thePlayer)
				local x, y, z = getElementPosition(thePlayer)
				x = x + ( ( math.cos ( math.rad ( r ) ) ) * 5 )
				y = y + ( ( math.sin ( math.rad ( r ) ) ) * 5 )

				if	(getElementHealth(theVehicle)==0) then
					spawnVehicle(theVehicle, x, y, z, 0, 0, r)
				else
					setElementPosition(theVehicle, x, y, z)
					setVehicleRotation(theVehicle, 0, 0, r)
				end

				setElementInterior(theVehicle, getElementInterior(thePlayer))
				setElementDimension(theVehicle, getElementDimension(thePlayer))

				outputChatBox("#7cc576[SeeMTA]: #FFFFFFJármû teleportálva lettél a pozíciódra.", thePlayer, 255, 194, 14, true)
			else
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFÉrvénytelen jármû ID.", thePlayer, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("getcar", getCar, false, false)

function getNearbyVehicles(thePlayer, commandName)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		outputChatBox("#7cc576[SeeMTA]: #FFFFFFKözelben lévõ jármûvek:", thePlayer, 255, 126, 0, true)
		local count = 0

		for index, nearbyVehicle in ipairs( exports.sas_global:getNearbyElements(thePlayer, "vehicle") ) do
			local thisvehid = getElementData(nearbyVehicle, "dbid")
			local vehicleID = getElementModel(nearbyVehicle)
			local vehicleName = getVehicleNameFromModel(vehicleID)
			local owner = getElementData(nearbyVehicle, "owner")
			local faction = getElementData(nearbyVehicle, "faction")
			count = count + 1

			local ownerName = ""

			if (faction>0) then
				ownerName = "Frakció jármű"
			elseif (owner==-1) then
				ownerName = "Admin"
			elseif (owner>0) then
				ownerName = getCharacterName(owner)
			else
				ownerName = "Civilian"
			end

			if (thisvehid) then
				outputChatBox("" .. vehicleName .. " (" .. vehicleID ..") ID: " .. thisvehid .. ". Tulaj: " .. ownerName, thePlayer, 255, 255, 255, true)
			elseif not (thisvehid) then
				outputChatBox("" ..  "*IDEIGLENES* " .. vehicleName .. " (" .. vehicleID ..") ID: " .. thisvehid .. ". Tulaj: " .. ownerName, thePlayer, 255, 255, 255, true)
			end
		end

		if (count==0) then
			outputChatBox("#d9534fSemmi.", thePlayer, 255, 126, 0, true)
		end
	end
end
addCommandHandler("nearbyvehicles", getNearbyVehicles, false, false)

function respawnCmdVehicle(thePlayer, commandName, id)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (id) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF /respawnveh [id]", thePlayer, 255, 194, 14, true)
		else
			local theVehicle = loadedVehicle[tonumber(id)]
			if theVehicle then
				if isElementAttached(theVehicle) then
					detachElements(theVehicle)
				end
				setElementData(theVehicle, 'i:left')
				setElementData(theVehicle, 'i:right')
				local dbid = getElementData(theVehicle,"dbid")
				if (dbid<0) then -- TEMP vehicle
					fixVehicle(theVehicle) -- Can't really respawn this, so just repair it
					if armoredCars[ getElementModel( theVehicle ) ] then
						setVehicleDamageProof(theVehicle, true)
					else
						setVehicleDamageProof(theVehicle, false)
					end
					setVehicleWheelStates(theVehicle, 0, 0, 0, 0)
					setElementData(theVehicle, "enginebroke", false)
				else
					respawnVehicle(theVehicle)
					if getElementData(theVehicle, "owner") == -2 and getElementData(theVehicle,"Impounded") == 0  then
						setVehicleLocked(theVehicle, false)
						setElementData(theVehicle, "locked", false)
					end
				end
				outputChatBox("Jármû respawnolva.", thePlayer, 255, 194, 14)
			else
				outputChatBox("Érvénytelen jármû ID.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("respawnveh", respawnCmdVehicle, false, false)

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function respawnAllVehicles(thePlayer, commandName, timeToRespawn)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if commandName then
			if isTimer(respawnTimer) then
				outputChatBox("Jármû respawn folyamatban, /respawnstop a leállításához.", thePlayer, 255, 0, 0)
			else
				timeToRespawn = tonumber(timeToRespawn) or 30
				timeToRespawn = timeToRespawn < 10 and 10 or timeToRespawn
				for k, arrayPlayer in ipairs(exports.sas_global:getAdmins()) do
					local logged = getElementData(arrayPlayer, "loggedin")
					if (logged) then
						if exports.sas_global:isPlayerLeadAdmin(arrayPlayer) then
							outputChatBox( "LeadAdmWarn: " .. getPlayerName(thePlayer):gsub("_", " ") .. " respawnolta az összes jármûvet.", arrayPlayer, 255, 194, 14)
						end
					end
				end

				outputChatBox("*** Az összes jármû "..timeToRespawn.." másodpercen belül respawnolódik! ***", getRootElement(), 255, 194, 14)
				outputChatBox("/respawnstop a leállításhoz!", thePlayer)
				respawnTimer = setTimer(respawnAllVehicles, timeToRespawn*1000, 1, thePlayer)
			end
			return
		end
		local tick = getTickCount()
		local vehicles = getElementsByType("vehicle")
		local counter = 0
		local tempcounter = 0
		local tempoccupied = 0
		local occupiedcounter = 0
		local unlockedcivs = 0
		local notmoved = 0

		local dimensions = { }
		for k, p in ipairs(getElementsByType("player")) do
			dimensions[ getElementDimension( p ) ] = true
		end

		for k, theVehicle in ipairs(vehicles) do
			if isElement( theVehicle ) then
				local dbid = getElementData(theVehicle, "dbid")
				if not (dbid) or (dbid<0) then -- TEMP vehicle
					local driver = getVehicleOccupant(theVehicle)
					local pass1 = getVehicleOccupant(theVehicle, 1)
					local pass2 = getVehicleOccupant(theVehicle, 2)
					local pass3 = getVehicleOccupant(theVehicle, 3)

					if (dbid and dimensions[dbid + 20000]) or (pass1) or (pass2) or (pass3) or (driver) or (getVehicleTowingVehicle(theVehicle)) or #getAttachedElements(theVehicle) > 0 then
						tempoccupied = tempoccupied + 1
					else
						destroyElement(theVehicle)
						tempcounter = tempcounter + 1
					end
				else
					local driver = getVehicleOccupant(theVehicle)
					local pass1 = getVehicleOccupant(theVehicle, 1)
					local pass2 = getVehicleOccupant(theVehicle, 2)
					local pass3 = getVehicleOccupant(theVehicle, 3)

					if (dimensions[dbid + 20000]) or (pass1) or (pass2) or (pass3) or (driver) or (getVehicleTowingVehicle(theVehicle)) or #getAttachedElements(theVehicle) > 0 then
						occupiedcounter = occupiedcounter + 1
					else
						if isVehicleBlown(theVehicle) or isElementInWater(theVehicle) then
							fixVehicle(theVehicle)
							if armoredCars[ getElementModel( theVehicle ) ] then
								setVehicleDamageProof(theVehicle, true)
							else
								setVehicleDamageProof(theVehicle, false)
							end
							for i = 0, 5 do
								setVehicleDoorState(theVehicle, i, 4) -- all kind of stuff missing
							end
							setElementHealth(theVehicle, 300) -- lowest possible health
						end

						setElementData(theVehicle, 'i:left')
						setElementData(theVehicle, 'i:right')
						if getElementData(theVehicle, "owner") == -2 and getElementData(theVehicle,"Impounded") == 0 then
							if isElementAttached(theVehicle) then
								detachElements(theVehicle)
							end
							respawnVehicle(theVehicle)
							setVehicleLocked(theVehicle, false)
							setElementData(theVehicle, "locked", false)
							unlockedcivs = unlockedcivs + 1
						else
							local checkx, checky, checkz = getElementPosition( theVehicle )
							local x, y, z, rx, ry, rz = unpack(getElementData(theVehicle, "respawnposition"))

							if (round(checkx, 6) == x) and (round(checky, 6) == y) then
								notmoved = notmoved + 1
							else
								if isElementAttached(theVehicle) then
									detachElements(theVehicle)
								end
								setElementPosition(theVehicle, x, y, z)
								setVehicleRotation(theVehicle, rx, ry, rz)
								setElementInterior(theVehicle, getElementData(theVehicle, "interior"))
								setElementDimension(theVehicle, getElementData(theVehicle, "dimension"))
								counter = counter + 1
							end
						end

						-- fix faction vehicles
						if getElementData(theVehicle, "faction") ~= -1 then
							fixVehicle(theVehicle)
							if (getElementData(theVehicle, "Impounded") == 0) then
								setElementData(theVehicle, "enginebroke", false)
								if armoredCars[ getElementModel( theVehicle ) ] then
									setVehicleDamageProof(theVehicle, true)
								else
									setVehicleDamageProof(theVehicle, false)
								end
							end
						end
					end
				end
			end
		end
		local timeTaken = (getTickCount() - tick)/1000
		createDebugNotification(root, "Az összes Jármű respawnolva",1)
		outputChatBox("Respawnolva " .. counter .. "/" .. counter + notmoved .. " jármû. (" .. occupiedcounter .. " foglalt) .", thePlayer)
		outputChatBox("Törölve " .. tempcounter .. " ideiglenes jármû. (" .. tempoccupied .. " foglalt).", thePlayer)
		outputChatBox("Kinyitva és respawnolva " .. unlockedcivs .. " civil jármû.", thePlayer)
		outputChatBox("Az egész folyamat " .. timeTaken .." másodpercet vett igénybe.", thePlayer)
	end
end
--addCommandHandler("respawnall", respawnAllVehicles, false, false)

function respawnVehiclesStop(thePlayer, commandName)
	if exports.sas_global:isPlayerAdmin(thePlayer) and isTimer(respawnTimer) then
		killTimer(respawnTimer)
		respawnTimer = nil
		if commandName then
			local name = getPlayerName(thePlayer):gsub("_", " ")
			if getElementData(thePlayer, "hiddenadmin") == 1 then
				name = "Rejtett Admin"
			end
			outputChatBox( "*** " .. name .. " megállította a jármû respawnot ***", getRootElement(), 255, 194, 14)
		end
	end
end
addCommandHandler("respawnstop", respawnVehiclesStop, false, false)

function respawnAllCivVehicles(thePlayer, commandName)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		local vehicles = getElementsByType("vehicle")
		local counter = 0

		for k, theVehicle in ipairs(vehicles) do
			local dbid = getElementData(theVehicle, "dbid")
			if dbid and dbid > 0 then
				local driver = getVehicleOccupant(theVehicle)
				local pass1 = getVehicleOccupant(theVehicle, 1)
				local pass2 = getVehicleOccupant(theVehicle, 2)
				local pass3 = getVehicleOccupant(theVehicle, 3)

				if not pass1 and not pass2 and not pass3 and not driver and not getVehicleTowingVehicle(theVehicle) and #getAttachedElements(theVehicle) == 0 then
					-- civ vehicles
					if getElementData(theVehicle, "owner") == -2 then
						if isElementAttached(theVehicle) then
							detachElements(theVehicle)
						end
						setElementData(theVehicle, 'i:left')
						setElementData(theVehicle, 'i:right')
						respawnVehicle(theVehicle)
						setVehicleLocked(theVehicle, false)
						setElementData(theVehicle, "locked", false)
						counter = counter + 1
					end
				end
			end
		end
		outputChatBox("Respawnolva " .. counter .. " civil jármû.", thePlayer)
	end
end
addCommandHandler("respawnciv", respawnAllCivVehicles, false, false)

function resetUpgrades(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerSuperAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF /" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				if not (isPedInVehicle(targetPlayer)) then
					outputChatBox("Ez a játékos nincs jármûben.", thePlayer, 255, 0, 0)
				else
					local theVehicle = getPedOccupiedVehicle(targetPlayer)
					for key, value in ipairs(getVehicleUpgrades(theVehicle)) do
						removeVehicleUpgrade(theVehicle, value)
					end
					setVehiclePaintjob(theVehicle, 3)
					outputChatBox("Eltüntette az összes kiegészítõt " .. targetPlayerName .. " jármûvérõl.", thePlayer, 255, 255, 255)
					exports['sas_saveveh']:saveVehicleMods(theVehicle)
				end
			end
		end
	end
end
addCommandHandler("resetupgrades", resetUpgrades, false, false)

function findVehID(thePlayer, commandName, ...)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF/" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local vehicleName = table.concat({...}, " ")
			local carID = getVehicleModelFromName(vehicleName)

			if (carID) then
				local fullName = getVehicleNameFromModel(carID)
				outputChatBox(fullName .. ": ID " .. carID .. ".", thePlayer)
			else
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFNem találom a jármûvet.", thePlayer, 255, 0 , 0, true)
			end
		end
	end
end
addCommandHandler("findvehid", findVehID, false, false)

-----------------------------[FIX VEH]---------------------------------
function fixPlayerVehicle(thePlayer, commandName, target)
	local x, y, z = getElementPosition(thePlayer)
	local dutyCucc = tonumber(getElementData(thePlayer, "duty"))
	if exports.sas_global:isPlayerAdmin(thePlayer) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF /" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then
					outputChatBox("A játékos nincs bejelentkezve.", thePlayer, 255, 0, 0)
				else
					local veh = getPedOccupiedVehicle(targetPlayer)
					if (veh) then
						fixVehicle(veh)
						if (getElementData(veh, "Impounded") == 0) then
							setElementData(veh, "enginebroke", false)
							if armoredCars[ getElementModel( veh ) ] then
								setVehicleDamageProof(veh, true)
							else
								setVehicleDamageProof(veh, false)
							end
						end
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFMegszerelted #32b3ef" .. targetPlayerName .. " #FFFFFFjármûvét.", thePlayer, 255, 194, 14, true)
						outputChatBox("#7cc576[SeeMTA]: #32b3ef".. getPlayerName(thePlayer):gsub("_", " ") .. " #FFFFFFmegszerelte a jármûved.", targetPlayer, 255, 194, 14, true)
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFEz a játékos nincs jármûben.", thePlayer, 255, 0, 0, true)
					end
				end
			end
		end
	end
end
addCommandHandler("fixveh", fixPlayerVehicle, false, false)

-----------------------------[BLOW CAR]---------------------------------
function blowPlayerVehicle(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF/" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				else
					local veh = getPedOccupiedVehicle(targetPlayer)
					if (veh) then
						blowVehicle(veh)
						outputChatBox("#FFFFFFFelrobbantottad #32b3ef" .. targetPlayerName .. " #FFFFFFjármûvét.", thePlayer, 255, 0, 0, true)

					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFEz a játékos nincs jármûben.", thePlayer, 255, 0, 0, true)
					end
				end
			end
		end
	end
end
addCommandHandler("blowveh", blowPlayerVehicle, false, false)

-----------------------------[SET CAR HP]---------------------------------
function setCarHP(thePlayer, commandName, target, hp)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (target) or not (hp) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF /" .. commandName .. " [NévRészlet] [Élet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				else
					local veh = getPedOccupiedVehicle(targetPlayer)
					if (veh) then
						local sethp = setElementHealth(veh, tonumber(hp))

						if (sethp) then
							outputChatBox("#FFFFFFBeállítottad #32b3ef" .. targetPlayerName .. " #FFFFFFjármûvének életét erre: #32b3ef" .. hp .. "#FFFFFF.", thePlayer, 255, 0, 0, true)

						else
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFÉrvénytelen élet érték.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFEz a játékos nincs jármûben.", thePlayer, 255, 0, 0, true)
					end
				end
			end
		end
	end
end
--addCommandHandler("setcarhp", setCarHP, false, false)


function fixAllVehicles(thePlayer, commandName)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		for key, value in ipairs(getElementsByType("vehicle")) do
			fixVehicle(value)
			setElementData(value, "enginebroke", false)
			if armoredCars[getElementModel(value)] then
				setVehicleDamageProof(value, true)
			else
				setVehicleDamageProof(value, false)
			end
		end
		outputChatBox("Az összes jármû megszerelve Admin " .. getPlayerName(thePlayer):gsub("_", " ") .. " által.")
	end
end
addCommandHandler("fixvehs", fixAllVehicles)

-----------------------------[FUEL VEH]---------------------------------
function fuelPlayerVehicle(thePlayer, commandName, target)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF /" .. commandName .. " [NévRészlet]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				else
					local veh = getPedOccupiedVehicle(targetPlayer)
					if (veh) then
						setElementData(veh, "fuel", 100, false)
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFFeltankoltad #32b3ef" .. targetPlayerName .. " #FFFFFFjármûvét.", thePlayer,0,0,0,true)
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFA jármûved feltankolva Admin #32b3ef" .. getPlayerName(thePlayer):gsub("_", " ") .. " #FFFFFFáltal.", targetPlayer,0,0,0,true)
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFEz a játékos nincs jármûben.", thePlayer, 255, 0, 0, true)
					end
				end
			end
		end
	end
end
addCommandHandler("fuelveh", fuelPlayerVehicle, false, false)

function fuelAllVehicles(thePlayer, commandName)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		for key, value in ipairs(getElementsByType("vehicle")) do
			setElementData(value, "fuel", 100, false)
		end
		outputChatBox("Az összes jármû feltankolva Admin " .. getPlayerName(thePlayer):gsub("_", " ") .. " által.")
	end
end
--addCommandHandler("fuelvehs", fuelAllVehicles, false, false)

-----------------------------[SET COLOR]---------------------------------
function setPlayerVehicleColor(thePlayer, commandName, target, r, g, b)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (target) or not (r) or not (g) or not (b) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF/" .. commandName .. " [NévRészlet] [r] [g] [b]", thePlayer, 255, 194, 14, true)
		else
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then
					outputChatBox("#7cc576[SeeMTA]: #FFFFFFA játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
				else
					local veh = getPedOccupiedVehicle(targetPlayer)
					if (veh) then
						local color = setVehicleColor(veh, r, g, b, r, g, b)

						if (color) then
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFJármû szinei sikeresen megváltoztatva.", thePlayer, 255, 0, 0, true)
							exports['sas_saveveh']:saveVehicleMods(veh)
						else
							outputChatBox("#7cc576[SeeMTA]: #FFFFFFÉrvénytelen szin ID.", thePlayer, 255, 194, 14, true)
						end
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFEz a játékos nincs jármûben.", thePlayer, 255, 0, 0, true)
					end
				end
			end
		end
	end
end
addCommandHandler("setvehcolor", setPlayerVehicleColor, false, false)
-----------------------------[GET COLOR]---------------------------------
function getAVehicleColor(thePlayer, commandName, carid)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if not (carid) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF/" .. commandName .. " [Jármû ID]", thePlayer, 255, 194, 14, true)
		else
			local acar = nil
			for i,c in ipairs(getElementsByType("vehicle")) do
				if (getElementData(c, "dbid") == tonumber(carid)) then
					acar = c
				end
			end
			if acar then
				local c1, c2 = getVehicleColor(acar)
				outputChatBox("#FFFFFFA jármû színei: ID1: #32b3ef" .. tonumber(c1) .. "#FFFFFF, ID2: #32b3ef" .. tonumber(c2) .. "#FFFFFF.", thePlayer, 255, 194, 14, true)
			else
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFRossz Jármû ID.", thePlayer, 255, 194, 14, true)
			end
		end
	end
end
addCommandHandler("getcolor", getAVehicleColor, false, false)

function deleteVehicle(thePlayer, commandName, id)
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		local dbid = tonumber(id)
		if not (dbid) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF/" .. commandName .. " [id]", thePlayer, 255, 194, 14, true)
		else
			local theVehicle = loadedVehicle[tonumber(id)]
			if theVehicle then
				if (dbid<0) then -- TEMP vehicle
					destroyElement(theVehicle)
				else
					if (exports.sas_global:isPlayerSuperAdmin(thePlayer)) then
						dbPoll ( dbQuery( db, "DELETE FROM vehicles WHERE id='?'",dbid), -1 )
						loadedVehicle[dbid] = nil
						destroyElement(theVehicle)
					else
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFNincs megfelelõ jogosultságod.", thePlayer, 255, 0, 0, true)
						return
					end
				end
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFJármû törölve.", thePlayer, 255, 0, 0, true)
			else
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFNem találtam ilyen ID-vel rendelkezõ jármûvet.", thePlayer, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("delveh", deleteVehicle, false, false)

-- DELTHISVEH

function deleteThisVehicle(thePlayer, commandName)
	local veh = getPedOccupiedVehicle(thePlayer)
	local dbid = getElementData(veh, "dbid")
	if (exports.sas_global:isPlayerAdmin(thePlayer)) then
		if dbid < 0 or exports.sas_global:isPlayerSuperAdmin(thePlayer) then
			if not (isPedInVehicle(thePlayer)) then
				outputChatBox("#7cc576[SeeMTA]: #FFFFFFNem vagy kocsiban!", thePlayer, 255, 0, 0, true)
			else
				if dbid > 0 then
					dbPoll ( dbQuery( db, "DELETE FROM vehicles WHERE id='?'",dbid), -1 )
					-- ide esetleges itemeltávolítás
				end
				destroyElement(veh)
			end
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFNincs megfelelõ jogosultságod.", thePlayer, 255, 0, 0, true)
			return
		end
	end
end
addCommandHandler("delthisveh", deleteThisVehicle, false, false)

function setVehTFFaction(thePlayer, commandName, pid, fid)
	if (exports.sas_global:isPlayerSuperAdmin(thePlayer)) then
		if not (pid) or not (fid) then
			outputChatBox("#7cc576[SeeMTA - Admin]: #FFFFFF/" .. commandName .. " [játékos] [frakcióID vagy -1]", thePlayer, 255, 194, 14, true)
		else
			local username = getPlayerName(thePlayer):gsub("_", " ")
			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, pid)
			if (targetPlayer) then
				local pv = getPedOccupiedVehicle(targetPlayer)
				if (pv) then
					local faction = tonumber(fid)
					local tnplayer = tonumber(getElementData(targetPlayer, "dbid"))
					local ocarid = tonumber(getElementData(pv, "dbid"))
					local oowner = tonumber(getElementData(pv, "owner"))
					local ofaction = tonumber(getElementData(pv, "faction"))
					if (faction == -1) then
						setElementData(pv, "faction", -1, false)
						setElementData(pv, "owner", tnplayer, false)
						exports['sas_saveveh']:saveVehicle(pv)

						outputChatBox("Jármû #" .. ocarid .. " frakciója átálítva: '" .. ofaction .. "', tulaj: '" .. targetPlayerName .. "'.", thePlayer, 255, 255, 255)
						outputChatBox("Admin " .. username .. " beállította a jármû tulaját a frakciódhoz: " .. ofaction .. ".", targetPlayer, 255, 255, 255)
						dbPoll ( dbQuery( db, "UPDATE vehicles SET  owner= '?', faction='?' WHERE id='?'",tnplayer, ofaction, ocarid), -1 )
					elseif false--[[(exports.sas_pool:getElement("team", faction))]] then
						setElementData(pv, "faction", faction, false)
						setElementData(pv, "owner", -1, false)
						exports['sas_saveveh']:saveVehicle(pv)

						outputChatBox("Jármû #" .. ocarid .. " frakciója átálítva: '" .. faction .. "'-ról erre: '" .. ofaction .. "'.", thePlayer, 255, 255, 255)
						outputChatBox("Admin " .. username .. " beállította a jármû tulaját a frakciódhoz: '" .. faction .. "'.", targetPlayer, 255, 255, 255)
						dbPoll ( dbQuery( db, "UPDATE vehicles SET  owner= '?', faction='?' WHERE id='?'",tnplayer, ofaction, ocarid), -1 )
					else
						outputChatBox("Érvénytelen frakció.", thePlayer, 255, 255, 255)
					end
				else
					outputChatBox("A játékos nincs jármûben.", thePlayer, 255, 255, 255)
				end
			end
		end
	end
end
addCommandHandler("setvehfaction", setVehTFFaction)

safeTable = {}
function addSafe( dbid, x, y, z, rz, interior )
	local tempobject = createObject(2332, x, y, z, 0, 0, rz)
	setElementInterior(tempobject, interior)
	setElementDimension(tempobject, dbid + 20000)
	safeTable[dbid] = tempobject
end

function removeSafe( dbid )
	if safeTable[dbid] then
		destroyElement(safeTable[dbid])
		safeTable[dbid] = nil
	end
end

function getSafe( dbid )
	return safeTable[dbid]
end

function getCharacterName(id)
	if not names[id] then
		dbQuery(function(qh)
			local result, rows = dbPoll(qh, 0)
			if rows > 0 then
				names[id] = result[1].charname:gsub("_", " ")
			end
		end, db, "SELECT charname FROM characters WHERE id=?", id)
	end
	return names[id]
end

function changeCharacterName(id, name)
	if not names[id] then return end
	names[id] = name
end