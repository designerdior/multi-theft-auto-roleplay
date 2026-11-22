function openDoor(door)
	local vehicle = getPedOccupiedVehicle(source)
	setVehicleDoorOpenRatio(vehicle, door, 1 - getVehicleDoorOpenRatio ( vehicle, door ), 800)
end
addEvent("moveThisShit", true)
addEventHandler("moveThisShit", getRootElement(), openDoor)