local drivers = {}
local blips = {}
local acCheck = { }

function updateBusBlips(line)
	local driversonline = 0
	for k, v in ipairs(drivers[line]) do
		driversonline = driversonline + #v
	end

	if driversonline > 0 then
		for k, v in ipairs(drivers[line]) do
			-- check back if see if a driver is nearing that
			if #(drivers[line][k-1] or {}) + #v > 0 then
				setBlipColor( blips[line][k], 127, 255, 63, 127 )
			else
				setBlipColor( blips[line][k], 255, 255, 63, 127 )
			end
		end
	else -- no drivers online
		for k, v in ipairs(blips[line]) do
			setBlipColor( v, 255, 63, 63, 127 )
		end
	end
end

function removeDriver()
	for k, v in ipairs(drivers) do
		for key, value in ipairs(v) do
			for i, player in pairs(value) do
				if player == source then
					table.remove(value, i)
				end
			end
		end
	end
end

function removeDriverOnAllLines()
	removeDriver()
	for line, v in pairs(drivers) do
		updateBusBlips(line)
	end
end
addEventHandler( "onPlayerQuit", getRootElement(), removeDriverOnAllLines )
addEventHandler("onCharacterLogin", getRootElement(), removeDriverOnAllLines )

function payBusDriver(line, stop)

	if (acCheck[client] == stop) and (stop ~= -1) then
		triggerBusCheatDetection(client,stop)
	end
	acCheck[client] = stop

	if stop == -2 then
		removeDriver()
		exports.sas_global:giveMoney(client, 2.3)
	elseif stop == -1 then
		removeDriverOnAllLines()
		return
	elseif stop == 0 then
		table.insert( drivers[line][1], client )
	else
		exports.sas_global:giveMoney(client, 18.2)

		if drivers[line][stop+1] then
			removeDriver()
			table.insert( drivers[line][stop+1], client )
		end
	end
	updateBusBlips(line)
end
addEvent("payBusDriver",true)
addEventHandler("payBusDriver", getRootElement(), payBusDriver)

function payForStop(player, amount)
	setElementData(player, "money", getElementData(player, "money")+amount)
end
addEvent("payForStop",true)
addEventHandler("payForStop", getRootElement(), payForStop)

function freezeBus(player, state)
	local veh = getPedOccupiedVehicle(player)
	if veh then
		setElementFrozen(veh, state)
	end
end
addEvent("freezeBus",true)
addEventHandler("freezeBus", getRootElement(), freezeBus)



-- BUS ROUTES BLIPS
function createBusBlips( )
	for routeID, route in ipairs( g_bus_routes ) do
		blips[routeID] = {}
		drivers[routeID] = {}
		for pointID, point in ipairs( route.points ) do
			if point[4] and #route.points ~= pointID then
				local stop = #blips[routeID]+1
				--blips[routeID][stop] = createBlip( point[1], point[2], point[3], 0, 1, 255, 63, 63, 127, -5, 65 )
				drivers[routeID][stop] = {}
			end
		end
	end
end
addEventHandler( "onResourceStart", getResourceRootElement(), createBusBlips )


local busPos = {
	{2200.0947265625, -2235.00390625, 12.546875},
	{2192.798828125, -2227.43359375, 12.528923988342},
	{2186.48828125, -2220.1396484375, 12.547735214233},
}

function addMarker(x,y,z)
	local aa = createMarker ( x,y,z, "cylinder", 4, 255, 255, 255, 50 )
	addEventHandler( "onMarkerHit", aa, function ( hitElement, matchingDimension )
		if (getElementType( hitElement )=="player") and getElementData(hitElement, "job")==3 then
			setElementData(hitElement, "job.busveh", true)
		end
	end)
	addEventHandler( "onMarkerLeave", aa, function ( hitElement, matchingDimension )
		if (getElementType( hitElement )=="player") then
			local veh = getPedOccupiedVehicle(hitElement)
			if veh then
				setElementData(hitElement, "job.busveh", false)
			end
		end
	end)
end
addEvent("addBusMarker", true)
addEventHandler("addBusMarker", getRootElement(), addMarker)

for i,v in pairs(busPos) do
	addMarker(v[1], v[2], v[3])
end
