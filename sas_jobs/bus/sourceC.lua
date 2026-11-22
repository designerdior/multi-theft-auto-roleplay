local line, route, m_number, curCpType = nil

local busMarker, busNextMarker = nil
local busBlip, busNextBlip = nil
local busStopColShape = nil

local bus = { [431]=true, [437]=true }
local blip
local pedCounter = 1
local renderLoading = false
local loadingWidth = 0
local sx, sy = guiGetScreenSize()
local stopCounter = 0
local utasNumber = 0
local fahrerTable = {}
local numb = 1
local plusX = 0
local busStation = {
	{2299.7685546875, -2073.6875, 13.546875, 315},
	{1922.6714,-1759.9180,13.3752, 270},
	{2291.861328125, -1666.1162109375, 14.973188400269, 270},
	{2482.1796875, -1739.9150390625, 13.546875, 270},
	{2744.63671875, -1436.4814453125, 30.44783782959, 360},
	{1816.427734375, -1573.41015625, 13.546875, 170},
	{1491.37109375, -1585.4287109375, 13.546875, 90},
	{1364.6552734375, -1287.525390625, 13.546875, 360},
	{1111.9384765625, -939.4404296875, 42.983364105225, 95},
	{955.4501953125, -1119.51953125, 23.770112991333, 180},
	{570.919921875, -1219.328125, 17.653797149658, 115},
	{167.80078125, -1742.8037109375, 4.61559009552, 275},
	{856.90234375, -1604.658203125, 13.546875, 315},
	{1166.5595703125, -1412.8447265625, 13.512522697449, 270},
	{1289.9189453125, -1814.18359375, 13.546875, 180},
	{1460.0087890625, -1739.0107421875, 13.546875, 270},
	{1766.5439453125, -1832.1240234375, 13.554912567139, 255}

}

for k, v in pairs(busStation) do
	station = createObject(1257, busStation[k][1], busStation[k][2], busStation[k][3], 0,0,busStation[k][4])
end

function resetBusJob()
	if (isElement(vehCreationBlip)) then
		destroyElement(vehCreationBlip)
		removeEventHandler("onClientVehicleEnter", getRootElement(), startBusJob)
		blip = nil
	end

	if isElement(busMarker) then
		destroyElement(busMarker)
		busMarker = nil
	end

	if isElement(busBlip) then
		destroyElement(busBlip)
		busBlip = nil
	end

	if isElement(busNextMarker) then
		destroyElement(busNextMarker)
		busNextMarker = nil
	end

	if isElement(busNextBlip) then
		destroyElement(busNextBlip)
		busNextBlip = nil
	end

	m_number = 0
	--triggerServerEvent("payBusDriver", getLocalPlayer(), line, -1)
end

function displayBusJob()
	vehCreationBlip = createBlip(2315.25390625, -2078.2919921875, 13.546875, 1, 2, 255, 255, 255)
	getCarMarker = createMarker(2315.25390625, -2078.2919921875, 13.546875, "checkpoint", 2, 51, 204, 255, 200)
	addEventHandler ( "onClientMarkerHit", getCarMarker, createBus )
	addEventHandler ( "onClientMarkerLeave", getCarMarker, delPanel )
	setElementData(vehCreationBlip, 'tooltipText', 'Busz felvétel');
	outputChatBox("#7cc576[SeeMTA - Buszsofőr]: #ffffffMenj végig a #7cc576buszmegállókon #ffffffés szállítsd az utasokat.", 255, 194, 15, true)
	outputChatBox("#7cc576[SeeMTA - Buszsofőr]: #e7d264Munkajármű #ffffffkéréséhez menj a kis, #e7d264teherautó #ffffffjelzéshez.", 255, 194, 15, true)
end

function createBus ( hitPlayer, matchingDimension )
	if hitPlayer == localPlayer then
		if getElementData(localPlayer, "job") == 1 then
			exports.sas_jobvehicle:createPanelExport(true, "bus", 124, 197, 118)
		end
	end
end

function delPanel()
	exports.sas_jobvehicle:createPanelExport(false)
end



function startBusJob()
	local job = getElementData(getLocalPlayer(), "job")
	if (job == 1) then
		if blip then
			destroyElement(blip)
			blip = nil
		end
		if busMarker then

		else
			local vehicle = getPedOccupiedVehicle(getLocalPlayer())
			if vehicle and getVehicleController(vehicle) == getLocalPlayer() and bus[getElementModel(vehicle)] then
				line = math.random( 1, #g_bus_routes )
				route = g_bus_routes[line]
				curCpType = 0

				local x, y, z = 2220.2705078125, -2134.806640625, 13.546875 -- Depot start point
				busBlip = createBlip(x, y, z, 31, 3, 124, 197, 118, 255)

				busMarker = createMarker(x, y, z, "checkpoint", 4, 124, 197, 118, 200) -- start marker.
				setElementData(busBlip, "blipSize", 15)
				setElementData(busBlip, "blipSize2", 15)
				setElementData(busBlip, "exclusiveBlip", true)
				busStopColShape = createColSphere(0, 0, 0, 5)

				addEventHandler("onClientMarkerHit", busMarker, updateBusCheckpointCheck)
				addEventHandler("onClientMarkerLeave", busMarker, checkWaitAtStop)
				addEventHandler("onClientColShapeHit", busStopColShape,
					function(element)
						if getElementType(element) == "vehicle" and bus[getElementModel(element)] then
							setVehicleLocked(vehicle, false)
						end
					end
				)
				addEventHandler("onClientColShapeLeave", busStopColShape,
					function(element)
						if getElementType(element) == "vehicle" and bus[getElementModel(element)] then
							setVehicleLocked(vehicle, true)
						end
					end
				)


				m_number = 0
				--triggerServerEvent("payBusDriver", getLocalPlayer(), line, 0)
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFA következő megálló: #7cc576"..g_bus_routes[line].stops[stopCounter+1],0,0,0,true)
				updateBusCheckpoint()
			end
		end
	end
end

function drawLoading()
	if renderLoading then
		exports.sas_system:radarKeret(sx/2-380/2,sy-100, 385, 15, 3)
		dxDrawRectangle(sx/2-380/2,sy-100, 385, 15, tocolor(0,0,0,200))
		if loadingWidth < 385 then
			loadingWidth = loadingWidth + 1
			dxDrawRectangle(sx/2-380/2,sy-100, loadingWidth, 15, tocolor(124, 197, 118,200))
			--setElementFrozen(element theElement, bool freezeStatus)
		elseif loadingWidth >= 385 then
			renderLoading = false
			loadingWidth = 0
			stopCounter = stopCounter + 1
			payAmount = utasNumber*90
			pedCounter = 1
			triggerServerEvent("payForStop", localPlayer, localPlayer, payAmount)
			triggerServerEvent("freezeBus", localPlayer, localPlayer, false)
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFA következő megálló: #7cc576"..g_bus_routes[line].stops[stopCounter+1],0,0,0,true)
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFÖsszesen felszállt #32b3ef"..utasNumber.." db #ffffffutas, és kerestél #7cc576"..payAmount.."$#ffffff-t ezen a megállóhelyen.",0,0,0,true)
			updateBusCheckpointAfterStop()
		end
	end
end
addEventHandler("onClientRender", getRootElement(), drawLoading)


function updateBusCheckpointCheck(thePlayer)
	if thePlayer == getLocalPlayer() then
		local vehicle = getPedOccupiedVehicle(thePlayer)
		if vehicle and bus[getElementModel(vehicle)] then
			if curCpType == 3 then
				--busStopTimer = setTimer(updateBusCheckpointAfterStop, 8000, 1, true)
				triggerServerEvent("freezeBus", localPlayer, localPlayer, true)
				renderLoading = true
				exports.sas_hud:addNotification("Várd meg, amíg felszállnak az utasok!", "info")
				setTimer(function()
					destroyElement(fahrerTable[pedCounter][1])
					pedCounter = pedCounter + 1
				end, 2000, utasNumber)
				--outputChatBox("#d9534f[SeeMTA]: #FFFFFFA következő megálló: "..g_bus_routes[line].stops[m_number+1],0,0,0,true)
			elseif curCpType == 2 then
				endOfTheLine()
			elseif curCpType == 1 then
				triggerServerEvent("freezeBus", localPlayer, localPlayer, true)
				renderLoading = true
				setTimer(function()
					destroyElement(fahrerTable[pedCounter][1])
					pedCounter = pedCounter + 1
				end, 2000, utasNumber)
			--	busStopTimer = setTimer(updateBusCheckpointAfterStop, 8000, 1, false)
				exports.sas_hud:addNotification("Várd meg, amíg felszállnak az utasok!", "info")
				--outputChatBox("#d9534f[SeeMTA]: #FFFFFFA következő megálló: "..g_bus_routes[line].stops[m_number+1],0,0,0,true)
			else
				updateBusCheckpoint()
			end
		end
	end
end

function updateBusCheckpoint()
	-- Find out which marker is next.
	local max_number = #route.points
	local newnumber = m_number+1
	local nextnumber = m_number+2
	local x, y, z = nil
	local nx, ny, nz = nil

	x = route.points[newnumber][1]
	y = route.points[newnumber][2]
	z = route.points[newnumber][3]

	if (tonumber(max_number-1) == tonumber(m_number)) then -- if the next checkpoint is the final checkpoint.
		setElementPosition(busMarker, x, y, z)
		setElementPosition(busBlip, x, y, z)
		local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
		if occupiedVehicle then
			if getElementModel ( occupiedVehicle ) == 431 then
				setElementData(occupiedVehicle, "gpsDestination", false)
				setElementData(occupiedVehicle, "gpsDestination", {x,y})
			end
		end

		if (route.points[newnumber][4]==true) then -- If it is a stop.
			curCpType = 3
			setElementPosition(busStopColShape, x, y, z)
		else -- it is just a route.
			curCpType = 2
		end
	else
		nx = route.points[nextnumber][1]
		ny = route.points[nextnumber][2]
		nz = route.points[nextnumber][3]

		setElementPosition(busMarker, x, y, z)
		setElementPosition(busBlip, x, y, z)
		local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
		if occupiedVehicle then
			if getElementModel ( occupiedVehicle ) == 431 then
				setElementData(occupiedVehicle, "gpsDestination", false)
				setElementData(occupiedVehicle, "gpsDestination", {x,y})
			end
		end
		utasNumber = math.random(2,6)
		for i=1, utasNumber do
			local skinS = math.random(1, 27)
		--	fahrer = createPed(skinS, busStation[numb][1]+plusX,busStation[numb][2]+0.2, busStation[numb][3], busStation[numb][4]+90)
		--	table.insert( fahrerTable, { fahrer } )
			plusX = plusX +0.3
			--outputChatBox("leftu")
		end
		if (route.points[newnumber][4]==true) then -- If it is a stop.
			curCpType = 1
			setElementPosition(busStopColShape, x, y, z)
		else -- it is just a route.
			curCpType = 0
		end
	end
--	outputChatBox(utasNumber)
	numb = numb+1
	m_number = m_number + 1
end

function probaDelete(amount)
	destroyElement(fahrerTable[1][1])
end
addCommandHandler("delproba", probaDelete)

function checkWaitAtStop(thePlayer)
	if thePlayer == getLocalPlayer() then
		if busStopTimer then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFTúl gyorsan hajtottál!", 255, 0, 0, true)
			if isTimer(busStopTimer) then
				killTimer(busStopTimer)
				busStopTimer = nil
			end
		end
	end
end

function updateBusCheckpointAfterStop(endOfLine)
	if isTimer(busStopTimer) then
		killTimer(busStopTimer)
		busStopTimer = nil
	end
	local stopNumber = route.points[m_number][5]
	--triggerServerEvent("payBusDriver", getLocalPlayer(), line, stopNumber)
	if endOfLine then
		endOfTheLine(getLocalPlayer())
	else
		updateBusCheckpoint(getLocalPlayer())
	end
end

function endOfTheLine()
	if busNextBlip then
		if busStopColShape then
			destroyElement(busStopColShape)
			busStopColShape = nil
		end

		local x, y, z = 1811, -1890, 13 -- Depot start point
		setElementPosition(busMarker, x, y, z)
		setElementPosition(busBlip, x, y, z)
		local occupiedVehicle = getPedOccupiedVehicle(localPlayer)
		if occupiedVehicle then
			if getElementModel ( occupiedVehicle ) == 431 then
				setElementData(occupiedVehicle, "gpsDestination", false)
				setElementData(occupiedVehicle, "gpsDestination", {x,y})
			end
		end
		setMarkerColor(busMarker, 255, 0, 0, 150)
		setBlipColor(busBlip, 255, 0, 0, 255)
		setMarkerIcon(busMarker, "finish")
		curCpType = 2
	else
		if busBlip then
			-- Remove the old marker.
			destroyElement(busBlip)
			destroyElement(busMarker)
			busBlip = nil
			busMarker = nil
		end
		--triggerServerEvent("payBusDriver", getLocalPlayer(), line, -2)
		setVehicleLocked(vehicle, false)
		outputChatBox("#00c8cb[SeeMTA]: #ffffffVége a munkának. ", 0, 255, 0, true )
	end
end


function startEnterBus(thePlayer, seat)
	if seat == 0 and bus[getElementModel(source)] then
		if getVehicleController(source) then -- if someone try to jack the driver stop him
			cancelEvent()
			if thePlayer == getLocalPlayer() then
				outputChatBox("#cb1919[SeeMTA]: #ffffffAz ajtók zárva.", 255, 0, 0, true)
			end
		else
			setVehicleLocked(source, false)
		end
	end
end
addEventHandler("onClientVehicleStartEnter", getRootElement(), startEnterBus)

function onPlayerQuit()
	if getElementData(source, "job") == 1 then
		vehicle = getPedOccupiedVehicle(source)
		if vehicle and bus[getElementModel(vehicle)] and getVehicleOccupant(vehicle) == source then
			setVehicleLocked(vehicle, false)
		end
	end
end
addEventHandler("onClientPlayerQuit", getRootElement(), onPlayerQuit)

function open()
	if (getElementData(getLocalPlayer(), "job.busveh") or false) and not getPedOccupiedVehicle(getLocalPlayer()) then
		triggerServerEvent("createBus", getLocalPlayer(), getLocalPlayer())
	end
end
bindKey("enter","down",open)
bindKey("f","down",open)
