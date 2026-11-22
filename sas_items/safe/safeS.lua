Safes = {}

function Safes.load()
	local query = dbPoll(dbQuery(mysqlConnection, "SELECT * FROM safes"), -1)
	if query then
		for index, v in ipairs (query) do
			local safe = createObject(2332, tonumber(v["x"]), tonumber(v["y"]), tonumber(v["z"] - 0.4))
			setElementRotation(safe, tonumber(v["rx"]), tonumber(v["ry"]), tonumber(v["rz"]))
			setElementInterior(safe, tonumber(v["interior"]))
			setElementDimension(safe, tonumber(v["dimension"]))
			setElementDoubleSided(safe, true)
			
			setElementData(safe, "Safe->isSafe", true)
			setElementData(safe, "Safe->id", v["id"])
			setElementData(safe, "Safe->owner", tonumber(v["owner"]))
		end
	end	
end
Safes.load()

function Safes.addSafe(player, x, y, z, rz, interior, dimension, owner)
	local qh, _, last_id = dbPoll(dbQuery(mysqlConnection, "INSERT INTO safes SET x = ?, y = ?, z = ?, rx = ?, ry = ?, rz = ?, interior = ?, dimension = ?, owner = ?", x, y, z, 0, 0, rz, interior, dimension, owner), -1)
	if qh then
		local id = last_id
		local safe = createObject(2332, tonumber(x), tonumber(y), tonumber(z - 0.4))
		setElementRotation(safe, 0, 0, tonumber(rz))
		setElementInterior(safe, tonumber(interior))
		setElementDimension(safe, tonumber(dimension))
		setElementDoubleSided(safe, true)
			
		setElementData(safe, "Safe->isSafe", true)
		setElementData(safe, "Safe->id", id)
		setElementData(safe, "Safe->owner", tonumber(owner))
	end
end