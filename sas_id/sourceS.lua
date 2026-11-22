local ids = { }

function playerJoin()
	local slot = nil

	for i = 1, 400 do
		if (ids[i]==nil) then
			slot = i
			break
		end
	end

	ids[slot] = source
	setElementData(source, "playerid", slot)
end
addEventHandler("onPlayerJoin", getRootElement(), playerJoin)

function prefixChange( playerSource, commandName )
	setElementData(playerSource, "prefix", true)
end
addCommandHandler ( "setprefix", prefixChange )

function playerQuit()
	local slot = getElementData(source, "playerid")

	if (slot) then
		ids[slot] = nil
	end
end
addEventHandler("onPlayerQuit", getRootElement(), playerQuit)

function resourceStart()
	for key, value in ipairs(getElementsByType("player")) do
		ids[key] = value
		setElementData(value, "playerid", key)
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), resourceStart)
