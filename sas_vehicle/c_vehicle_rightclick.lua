wRightClick = nil
bInventory = nil
bCloseMenu = nil
ax, ay = nil
localPlayer = getLocalPlayer()
vehicle = nil

function requestInventory(button)
	if button=="left" and not getElementData(localPlayer, "exclusiveGUI") then
		if isVehicleLocked(vehicle) and vehicle ~= getPedOccupiedVehicle(localPlayer) then
			triggerServerEvent("onVehicleRemoteAlarm", vehicle)
			outputChatBox("Jármű zárva.", 255, 0, 0)
		elseif type(getElementData(vehicle, "Impounded")) == "number" and getElementData(vehicle, "Impounded") > 0 and not exports.sas_global:hasItem(localPlayer, 38, getElementData(vehicle, "dbid")) then
			outputChatBox("Nincs kulcsod ehhez a jármûhöz.", 255, 0, 0)
		else
			--outputChatBox("Ez a funkció jelenleg nem elérhető...", 255, 0, 0)
			triggerServerEvent( "szerverElementInventoryMegjelenites", localPlayer, getLocalPlayer(), getElementData(vehicle, "dbid"),  getElementData(vehicle, "job"), ax, ay)
			--triggerServerEvent("elementInventoryMegjelenites", localPlayer)
		end
		hideVehicleMenu()
	end
end

--[[function clickVehicle(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if (element) and (getElementType(element)=="vehicle") and (button=="right") and (state=="down") and not (wInventory) then
		local x, y, z = getElementPosition(localPlayer)
		
		if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3) then
			if (wRightClick) then
				hideVehicleMenu()
			end
			showCursor(true)
			ax = absX
			ay = absY
			vehicle = element
			showVehicleMenu()
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickVehicle, true)]]

function isNotAllowedV(theVehicle)
	local vmodel = getElementModel(theVehicle)
	if (getVehicleType(vmodel) == "Plane") then
		return true
	end
	if (getVehicleType(vmodel) == "Helicopter") then
		return true
	end
	if (getVehicleType(vmodel) == "Boat") then
		return true
	end
	if (getVehicleType(vmodel) == "Train") then
		return true
	end
	if (getVehicleType(vmodel) == "Trailer") then
		return true
	end
	return false
end

function showVehicleMenu()
	local y = 0.10
	wRightClick = guiCreateWindow(ax, ay, 150, 200, getVehicleName(vehicle), false)
	
	lPlate = guiCreateLabel(0.05, y, 0.87, 0.1, "Rendszám: " .. getVehiclePlateText(vehicle), true, wRightClick)
	guiSetFont(lPlate, "default-bold-small")
	y = y + 0.1

	if (isVehicleImpounded(vehicle)) then
		lImpounded = guiCreateLabel(0.05, y, 0.87, 0.1, "Lefoglalva: Igen", true, wRightClick)
		guiSetFont(lImpounded, "default-bold-small")
		y = y + 0.1
	end
	
	if (hasVehicleWindows(vehicle)) then
		local windowState = isVehicleWindowUp(vehicle, true) and "Felhúzva" or "Lehúzva"
		lWindows = guiCreateLabel(0.05, y, 0.87, 0.1, "Ablakok: " .. windowState , true, wRightClick)
		guiSetFont(lWindows, "default-bold-small")
		y = y + 0.1
	end
	
	bInventory = guiCreateButton(0.05, y, 0.87, 0.1, "Csomagtartó", true, wRightClick)
	addEventHandler("onClientGUIClick", bInventory, requestInventory, false)
	y = y + 0.14
	
	if ( getPedSimplestTask(localPlayer) == "TASK_SIMPLE_CAR_DRIVE" and getPedOccupiedVehicle(localPlayer) == vehicle ) or exports.sas_global:hasItem(localPlayer, 38, getElementData(vehicle, "dbid")) or (getElementData(localPlayer, "faction") > 0 and getElementData(localPlayer, "faction") == getElementData(vehicle, "faction")) then
		bLockUnlock = guiCreateButton(0.05, y, 0.87, 0.1, "Lezár/Kinyit", true, wRightClick)
		addEventHandler("onClientGUIClick", bLockUnlock, lockUnlock, false)
		y = y + 0.14
	end

	--if getElementData(localPlayer, "faction") == 52 then
		--bFix = guiCreateButton(0.05, y, 0.87, 0.1, "Szerelés/Tuning", true, wRightClick)
		--addEventHandler("onClientGUIClick", bFix, openMechanicWindow, false)
		--y = y + 0.14
	--end
	
	local vx,vy,vz = getElementVelocity(vehicle)
	if vx < 0.05 and vy < 0.05 and vz < 0.05 and not getPedOccupiedVehicle(localPlayer) and not isVehicleLocked(vehicle) then -- completely stopped
		local trailers = { [606] = true, [607] = true, [610] = true, [590] = true, [569] = true, [611] = true, [584] = true, [608] = true, [435] = true, [450] = true, [591] = true }
		if trailers[ getElementModel( vehicle ) ] then
			if exports.sas_global:hasItem(localPlayer, 38, getElementData(vehicle, "dbid")) then
				bPark = guiCreateButton(0.05, y, 0.87, 0.1, "Leparkol", true, wRightClick)
				addEventHandler("onClientGUIClick", bPark, parkTrailer, false)
				y = y + 0.14
			end
		else
			if exports.sas_global:hasItem(localPlayer, 57) then
				bFill = guiCreateButton(0.05, y, 0.87, 0.1, "Feltankol", true, wRightClick)
				addEventHandler("onClientGUIClick", bFill, fillFuelTank, false)
				y = y + 0.14
			end
		end
	end

	local entrance = getElementData( vehicle, "entrance" )
	if entrance and not isPedInVehicle( localPlayer ) then
		bEnter = guiCreateButton(0.05, y, 0.87, 0.1, "Belépés", true, wRightClick)
		addEventHandler("onClientGUIClick", bEnter, enterInterior, false)
		y = y + 0.14

		bKnock = guiCreateButton(0.05, y, 0.87, 0.1, "Kopogás", true, wRightClick)
		addEventHandler("onClientGUIClick", bKnock, knockVehicle, false)
		y = y + 0.14
	end
	
	bCloseMenu = guiCreateButton(0.05, y, 0.87, 0.1, "Menü bezárása", true, wRightClick)
	addEventHandler("onClientGUIClick", bCloseMenu, hideVehicleMenu, false)
end

function lockUnlock(button, state)
	if (button=="left") then
		if getPedSimplestTask(localPlayer) == "TASK_SIMPLE_CAR_DRIVE" and getPedOccupiedVehicle(localPlayer) == vehicle then
			triggerServerEvent("lockUnlockInsideVehicle", localPlayer, vehicle)
		elseif exports.sas_global:hasItem(localPlayer, 38, getElementData(vehicle, "dbid")) or (getElementData(localPlayer, "faction") > 0 and getElementData(localPlayer, "faction") == getElementData(vehicle, "faction")) then
			triggerServerEvent("lockUnlockOutsideVehicle", localPlayer, vehicle)
		end
		hideVehicleMenu()
	end
end

function parkTrailer(button, state)
	if (button=="left") then
		triggerServerEvent("parkVehicle", localPlayer, vehicle)
		hideVehicleMenu()
	end
end

function fillFuelTank(button, state)
	if (button=="left") then
		local _,_, value = exports.sas_global:hasItem(localPlayer, 57)
		if value > 0 then
			triggerServerEvent("fillFuelTankVehicle", localPlayer, vehicle, value)
			hideVehicleMenu()
		else
			outputChatBox("A benzines kanna üres...", 255, 0, 0)
		end
	end
end

function openMechanicWindow(button, state)
	if (button=="left") then
		triggerEvent("openMechanicFixWindow", localPlayer, vehicle)
		hideVehicleMenu()
	end
end

function hideVehicleMenu()
	if (isElement(bCloseMenu)) then
		destroyElement(bCloseMenu)
	end
	bCloseMenu = nil

	if (isElement(wRightClick)) then
		destroyElement(wRightClick)
	end
	wRightClick = nil
	
	ax = nil
	ay = nil

	vehicle = nil

	showCursor(false)
	triggerEvent("cursorHide", getLocalPlayer())
end

function enterInterior()
	triggerServerEvent( "enterVehicleInterior", getLocalPlayer(), vehicle )
	hideVehicleMenu()
end

function knockVehicle()
	triggerServerEvent("onVehicleKnocking", getLocalPlayer(), vehicle)
	hideVehicleMenu()
end