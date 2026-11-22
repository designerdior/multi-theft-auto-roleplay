local connection = exports.sas_mysql:getConnection()

function buyVehicle(modellID, r, g, b, amount, jelenVeh)
	if client then
		if getElementData(client, "money") >= amount then
			if #getElementData(client, "vehicles") < getElementData(client, "maxvehicles") then
				exports.sas_vehicle:makeShopVehicle(client, modellID, r, g, b)

				triggerClientEvent(client, "paymentCompleted", client)

				setElementData(client, "money", getElementData(client, "money") - amount)
			else
				exports.sas_hud:addNotification(client, "Nincs szabad jármű slot-od!", "error")
			end
		else
			exports.sas_hud:addNotification(client, "Nincs elég pénzed!", "error")
		end
	end
end
addEvent("buyVehicle", true)
addEventHandler("buyVehicle", root, buyVehicle)

function buyVehiclePP(modellID, r, g, b, pp, jelenVeh)
	if client then
		if getElementData(client, "pp") >= pp then
			if #getElementData(client, "vehicles") < getElementData(client, "maxvehicles") then
				exports.sas_vehicle:makeShopVehicle(client, modellID, r, g, b)

				triggerClientEvent(client, "paymentCompleted", client)

				setElementData(client, "pp", getElementData(client, "pp") - pp)
			else
				exports.sas_hud:addNotification(client, "Nincs szabad jármű slot-od!", "error")
			end
		else
			exports.sas_hud:addNotification(client, "Nincs elég PP-d!", "error")
		end
	end
end
addEvent("buyVehiclePP", true)
addEventHandler("buyVehiclePP", root, buyVehiclePP)
