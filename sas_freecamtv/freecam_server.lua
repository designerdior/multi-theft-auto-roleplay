-- Default position on start of the resource
local x = 1309.3671875
local y = -1393.1240234375
local z = 1022.1019897461
local int = 3
local dim = 127

-- Some variables needed
local marker = nil
local cameraRadius = 15

function setPlayerFreecamEnabled(player)
	if not isPlayerFreecamEnabled(player) then
		removePedFromVehicle(player)
		setElementData(player, "realinvehicle", 0, false)
		local startX, startY, startZ = getElementPosition(player)
		setElementData(player, "tv:dim", getElementDimension(player), false)
		setElementData(player, "tv:int", getElementInterior(player), false)
		setElementData(player, "tv:x", startX, false)
		setElementData(player, "tv:y", startY, false)
		setElementData(player, "tv:z", startZ, false)
		setElementDimension(player, dim)
		setElementInterior(player, int)
		setElementAlpha(player, 0)
		setElementData(player, "reconx", true)
		return triggerClientEvent(player,"doSetFreecamEnabledTV", getRootElement(), x,y,z, false)
	else
		return false
	end
end

function moveCamera(newx, newy, newz, newint, newdim)
	if (marker) then
		destroyElement(marker)
	end
	
	marker = createMarker( newx, newy, newz, 'corona', 1, 255, 127, 0, 127)
	setElementInterior(marker, newint)
	setElementDimension(marker, 65535)
	
	x = newx
	y = newy
	z = newz
	int = newint
	dim = newdim
	return true
end

-- Move to the default position
moveCamera(x, y, z, int, dim)

function setPlayerFreecamDisabled(player)
	if isPlayerFreecamEnabled(player) then
		setElementDimension(player, getElementData(player, "tv:dim"))
		setElementInterior(player, getElementData(player, "tv:int"))
		setElementAlpha(player, 255)
		removeElementData(player, "reconx", true)
		
		return triggerClientEvent(player,"doSetFreecamDisabledTV", getRootElement(), false)
	else
		return false
	end
end

function setPlayerFreecamOption(player, theOption, value)
	return triggerClientEvent(player,"doSetFreecamOptionTV", getRootElement(), theOption, value)
end

function isPlayerFreecamEnabled(player)
	return getElementData(player,"freecamTV:state")
end



-- 

local earnings = 0
local watching = 0

--







function isTVRunning()
	if getElementDimension(marker) == 65535 then
		return false
	end
	return true
end

function isPlayerInCameraRadius(sourceplayer)
	local x,y,z = getElementPosition(sourceplayer)  
	local xx, xy, xz = getElementPosition(marker) 
	if (getDistanceBetweenPoints2D ( x, y, xx, xy ) < cameraRadius) then
		return true
	end
	return false
end

function add( shownto, message, sourceplayer )
	if isTVRunning() and (isPlayerInCameraRadius(sourceplayer)) then
		watching = math.max( shownto, watching )
		earnings = earnings + 10 * shownto
		
		exports.sas_global:giveMoney(getTeamFromName"San Andreas Network", 10 * shownto)
	end
end