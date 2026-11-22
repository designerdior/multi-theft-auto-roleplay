local db = exports.sas_mysql:getConnection()

local bins = {}

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(function(qh)
		local result = dbPoll(qh, 0)

		for _, data in ipairs(result) do
			bins[data.id] = createObject(1359, data.x, data.y, data.z)

			setElementInterior(bins[data.id], data.interior)
			setElementDimension(bins[data.id], data.dimension)
			setElementData(bins[data.id], "dbid", data.id)
		end
	end, db, "SELECT * FROM bins")
end)

addCommandHandler("addkuka", function(player)
	if getElementData(player, "adminlevel") >= 8 then
		local x, y, z = getElementPosition(player)
		local int = getElementInterior(player)
		local dim = getElementDimension(player)

		dbQuery(function(qh)
			local _, _, id = dbPoll(qh, 0)

			bins[id] = createObject(1359, x, y, z - 0.3)

			setElementInterior(bins[id], int)
			setElementDimension(bins[id], dim)
			setElementData(bins[id], "dbid", id)

			outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen létrehoztál egy kukát! #7cc576("..id..")", player, 255, 255, 255, true)
		end, db, "INSERT INTO bins SET x=?, y=?, z=?, interior=?, dimension=?", x, y, z, int, dim)
	end
end)

addCommandHandler("delkuka", function(player, cmd, id)
	if getElementData(player, "adminlevel") >= 8 then
		if tonumber(id) and isElement(bins[tonumber(id)]) then
			if bins[tonumber(id)] then
				dbExec(db, "DELETE FROM bins WHERE id=?", tonumber(id))
				destroyElement(bins[tonumber(id)])
				bins[tonumber(id)] = nil
				outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen töröltél egy kukát! #7cc576("..id..")", player, 255, 255, 255, true)
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem található ilyen IDvel kuka.", player, 255, 255, 255, true)
			end
		else
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/delkuka [ID]", player, 255, 255, 255, true)
		end
	end
end)