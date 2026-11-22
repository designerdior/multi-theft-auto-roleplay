local markElement = createMarker(1561.3310546875, -2315.384765625, 12.548420906067,"cylinder",2,124, 197, 118,220)
setElementData(markElement,"isRentMark",true)

addEvent("createRentVeh",true)
addEventHandler("createRentVeh",getRootElement(),function(x, y, z,vehicleModel,price)
	local money = getElementData(client, "money")

	if getElementData(client, "money") >= price then
		local veh = createVehicle(vehicleModel, x, y, z, 0,0,90)
		local dbid = getElementData(client,"dbid")

		setElementHealth(veh, 1000)
		setElementData(veh, "rentVeh",true)
		setElementData(veh, "dbid",dbid)
		setElementData(veh, "job", -1)
		setElementData(veh, "owner", -1)
		setElementData(veh, "faction", -1)
		setElementData(veh, "fuel", 100)

		setVehiclePlateText(veh, "RENT-"..dbid)
		setVehicleRespawnPosition(veh, x,y,z,0,0,90)
		warpPedIntoVehicle(client, veh)

		setTimer(function()
			setVehicleEngineState(veh, false)
		end,100,1)

		setElementData(client, "rentCar", veh)
		setElementData(client,"onRentCar",true)
		setElementData(client, "money", money-price)
	else
		exports.sas_hud:addNotification(client, "Nincs elég pénzed. ("..price.." $.)","error")
	end
end)

addEvent("destroyRentVeh",true)
addEventHandler("destroyRentVeh",getRootElement(),function(veh)
	if getElementData(client,"onRentCar") then
		if getElementData(veh,"rentVeh") then
			destroyElement(veh)
			removeElementData(client, "rentCar")
			removeElementData(client,"onRentCar")
			removeElementData(client,"seatbelt")
		end
	end
end)

addEventHandler("onPlayerQuit", getRootElement(), function()
	local veh = getElementData(source, "rentCar")
	if isElement(veh) then
		destroyElement(veh)
	end
end)