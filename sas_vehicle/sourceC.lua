addEventHandler("onClientKey", getRootElement(), function(key, state)
	if not getElementData(localPlayer, "loggedin") or isChatBoxInputActive() or not state then return end

	if key == "k" then
		if not isPedInVehicle(localPlayer) then
			local px, py, pz = getElementPosition(localPlayer)

			for _, v in ipairs(getElementsByType("vehicle"), getRootElement(), true) do
				if getElementInterior(v) == getElementInterior(localPlayer) and getElementDimension(v) == getElementDimension(localPlayer) then
					local vx, vy, vz = getElementPosition(v)
					if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) < 5 then
						veh = v
						carname = getVehicleNames(getElementModel(v)) or getVehicleName(v)
					end
				end
			end
		end

		if not veh then return end

		if exports.sas_items:hasItem(1, getElementData(veh, "dbid")) or getElementData(veh, "owner") < 0 or getElementData(localPlayer, "adminduty") then
			local locked = getElementData(veh, "locked")
			triggerServerEvent("setVehicleLocked", veh, not locked)
			setElementData(veh, "locked", not locked)

			exports.sas_chat:sendLocalMeAction(localPlayer, (locked and "kinyitotta" or "bezárta").." egy "..carname.." ajtaját.")
		else
			exports.sas_hud:addNotification("Nincs kulcsod ehhez a járműhöz.", "error")
		end
	end

	if not veh or seat ~= 0 then return end

	if key == "j" then
		if getElementData(veh, "engine") then
			triggerServerEvent("setVehicleEngineState", veh, false)
			toggleControl("brake_reverse", false)
			setElementData(veh, "engine", false)

			exports.sas_chat:sendLocalMeAction(localPlayer, "leállította egy "..carname.." motorját.")
		else
			playSound("files/lightswitch.mp3")
		end
	elseif key == "space" then
		if not getKeyState("j") or getElementData(veh, "engine") then return end
		starterSound = playSound("files/starter.mp3")
		if isTimer(engineTimer) then
			killTimer(engineTimer)
			stopSound(starterSound)
		end
		engineTimer = setTimer(function()
			if not getKeyState("space") then return end
			if exports.sas_items:hasItem(1, getElementData(veh, "dbid")) or getElementData(veh, "owner") < 0 or getElementData(localPlayer, "adminduty") then
				if getElementData(veh, "enginebroke") then
					exports.sas_chat:sendLocalMeAction(localPlayer, "megpróbálja elindítani a motort, de nem sikerül neki.")
				elseif getElementData(veh, "fuel") > 0 then
					triggerServerEvent("setVehicleEngineState", veh, true)
					toggleControl("brake_reverse", true)
					setElementData(veh, "engine", true)

					exports.sas_chat:sendLocalMeAction(localPlayer, "beindítja egy "..carname.." motorját.")
				else
					exports.sas_chat:sendLocalMeAction(localPlayer, "megpróbálja elindítani a motort, de nem sikerül neki.")
					exports.sas_hud:addNotification("Kifogyott az üzemanyag!", "error")
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFNincs kulcsod ehhez a járműhöz.", 255, 0, 0, true)
			end
		end, 1000, 1)
	end
end)

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(vehicle, vehseat)
	local model = getElementModel(vehicle)
	if not enginelessVehicle[model] then
		veh = vehicle
		seat = vehseat
		carname = getVehicleNames(model) or getVehicleName(vehicle)
	end
end)

addEventHandler("onClientPlayerVehicleExit", localPlayer, function(vehicle)
	if not enginelessVehicle[getElementModel(vehicle)] then
		veh, seat, carname = nil, nil, nil
	end
end)