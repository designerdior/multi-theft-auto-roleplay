local createdBusses = 0
local mesh = {}
local tolo = {}
function createJobVehicle(thePlayer, type, vehR, vehG, vehB)
	local r = getPedRotation(thePlayer)
	local x, y, z = getElementPosition(thePlayer)
	local veh = createVehicle(type, x, y, z, 0, 0, r, plate)
	if (veh) then
		createdBusses = createdBusses + 1
		setVehiclePlateText(veh, "MUNKA-"..createdBusses)
		setVehicleDamageProof(veh, false)

		totalTempVehicles = (getElementData(getRootElement(), "totalTempVehicles") or 0) + 1
		local dbid = (-totalTempVehicles)
		local username = getPlayerName(thePlayer)
		setVehicleColor(veh, vehR, vehG, vehB, vehR, vehG, vehB)

		setElementInterior(veh, getElementInterior(thePlayer))
		setElementDimension(veh, getElementDimension(thePlayer))

		setVehicleOverrideLights(veh, 1)
		setVehicleEngineState(veh, false)
		setVehicleFuelTankExplodable(veh, false)

		setElementData(veh, "dbid", dbid)
		setElementData(veh, "fuel", 100)
		setElementData(veh, "Impounded", 0)
		setElementData(veh, "engine", 1)
		setElementData(veh, "oldx", x)
		setElementData(veh, "oldy", y)
		setElementData(veh, "oldz", z)
		setElementData(veh, "faction", -1)
		setElementData(veh, "owner", -1)
		setElementData(veh, "job", 3)
		setElementData(veh, "handbrake", 0)
		if getElementModel(veh) == 456 then
			setElementData(veh, "truck_state", false)
			setElementData(veh, "truck_state_down", false)
			mesh[veh] = createObject(16183,0,0,0,0,0,0)
			tolo[veh] = createObject(16149,0,0,0,0,0,0)
			setElementData(veh, "mesh", mesh[veh])
			setElementData(veh, "tolo", tolo[veh])

			local calc1 = createObject(1598, 0, 0, 0)
			local calc2 = createObject(1598, 0, 0, 0)
			local calc3 = createObject(1598, 0, 0, 0)
			local calc4 = createObject(1598, 0, 0, 0)
			setObjectScale(calc1, 0.1)
			setObjectScale(calc2, 0.1)
			setObjectScale(calc3, 0.1)
			setObjectScale(calc4, 0.1)
			attachElements(calc1, veh, 1,0.4, 0.1)
			attachElements(calc2, veh, -1,0.4,0.1)
			attachElements(calc3, veh, 1,-5,0.1)
			attachElements(calc4, veh, -1,-5,0.1)
			setElementAlpha(calc1, 0)
			setElementAlpha(calc2, 0)
			setElementAlpha(calc3, 0)
			setElementAlpha(calc4, 0)

			setElementData(veh, "calc1", calc1)
			setElementData(veh, "calc2", calc2)
			setElementData(veh, "calc3", calc3)
			setElementData(veh, "calc4", calc4)
		end
		setElementData(veh, "vehicle.tuning.seeGO", 1)
		if type == 431 then
			setTimer(function()
				warpPedIntoVehicle(thePlayer, veh)
			end, 2000, 1)
		else
			warpPedIntoVehicle(thePlayer, veh)
			attachElements(tolo[veh], veh, 0,-1)
		end
	end
end
addEvent("createJobVehicle", true)
addEventHandler("createJobVehicle", getRootElement(), createJobVehicle)

function deleteJobVehicle(player)
	local veh = getPedOccupiedVehicle(player)
	if veh then
		destroyElement(veh)
	end
end
addEvent("deleteJobVehicle", true)
addEventHandler("deleteJobVehicle", getRootElement(), deleteJobVehicle)
