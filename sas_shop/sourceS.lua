
local connection = exports.sas_mysql:getConnection()

addCommandHandler("makeshop", function(Player, cmd, skin, type, name )
	if (Player:getData("adminlevel") >= 8) then
		if not (skin) or not type or not name and tonumber(type) < 0 and tonumber(type) < #ShopTipus+1 then
			outputChatBox("#7cc576[SeeMTA]:#FFFFFF /".. cmd .." [NPC kinézet] [Típus] [NPC név]", Player,255,255,255,true)
			outputChatBox("#7cc576[SeeMTA]:#FFFFFF Típusok: 1-Vegyes, 2-Kaja, 3-Pia", Player,255,255,255,true)
			return
		end
		local x, y, z = getElementPosition(Player)
		local dim = getElementDimension(Player)
		local int = getElementInterior(Player)
		local rot = getPedRotation(Player)
		local name = name:gsub("_", " ")
		local Position = toJSON( {x, y, z, dim, int} )
		local beszurasQuery = dbQuery( connection, "INSERT INTO `shops` SET `Type`=?, `Pos`=?, `skin`=?, `name`=?, `Rot`=?", tonumber(type), Position, skin, name, rot)
		local beszurasQueryEredmeny, _, beszurasID = dbPoll ( beszurasQuery, -1 )
		if (beszurasQueryEredmeny) then
			local ped = createPed(skin,x,y,z)
			if not ped then return end
			setPedRotation(ped, rot)
			setElementDimension(ped, dim)
			setElementInterior(ped, int)
			setElementFrozen(ped,true)
			setElementData(ped, "shop:NPC", true)
			setElementData(ped, "Bolt:Tipus", tonumber(type))
			setElementData(ped, "nameEnabled", true)
			setElementData(ped, "tagName", "NPC")
			setElementData(ped, "visiblePedName", name)
		end
	end
end)

dbQuery(function(qh)
	local result = dbPoll(qh, 0)
	for key, data in ipairs(result) do
		local pos = fromJSON(data["Pos"])
		local ped = createPed(data["skin"], pos[1], pos[2], pos[3])
		
		setPedRotation(ped, data["Rot"])
		setElementDimension(ped, pos[4])
		setElementInterior(ped, pos[5])
		setElementFrozen(ped, true)
		setElementData(ped, "shop:NPC", true)
		setElementData(ped, "nameEnabled", true)
		setElementData(ped, "Bolt:Tipus", data["Type"])
		setElementData(ped, "visiblePedName", data["name"])
		setElementData(ped, "tagName", "NPC")
	end
end, connection, "SELECT * FROM shops")

addEvent("Vasarlas", true)
addEventHandler("Vasarlas", getRootElement(), function(item, value, count, levonas)
	if tonumber(item) == 36 then
		exports.sas_phone:addPhone(client)
	else
		if triggerEvent("giveItem", client, client, item, value, count, 0) then
			setElementData(client, "money", getElementData(client, "money") - tonumber(levonas*count))
			exports.sas_hud:addNotification(client, "Sikeres Vásárlás", "success")
		end
	end
end)