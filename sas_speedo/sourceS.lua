function vehicleStartExit(thePlayer, seat, jacked)
	if getElementData(thePlayer, "seatbelt") then
		exports.sas_hud:addNotification(thePlayer, "Előbb kösd ki az öved. (F5)", "error")
		cancelEvent()
	elseif isVehicleLocked(source) then
		exports.sas_hud:addNotification(thePlayer, "A jármű be van zárva, ezért nem szállhatsz ki.", "error")
		cancelEvent()
	end
end
addEventHandler("onVehicleStartExit",getRootElement(),vehicleStartExit)

function sendMeMessageOn()
	exports.sas_chat:sendLocalMeAction(source, "becsatolja a biztonsági övet.")
end
addEvent("sendMeMessageOn", true)
addEventHandler("sendMeMessageOn", getRootElement(), sendMeMessageOn)

function sendMeMessageOff()
	exports.sas_chat:sendLocalMeAction(source, "kicsatolja a biztonsági övet.")
end
addEvent("sendMeMessageOff", true)
addEventHandler("sendMeMessageOff", getRootElement(), sendMeMessageOff)
