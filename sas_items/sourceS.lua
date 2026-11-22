mysqlConnection = exports.sas_mysql:getConnection()

local loadedItems = {{}, {}, {}}
local weapons = {}

addEventHandler("onResourceStart", resourceRoot,function()
	Async:setPriority("high")

	local start = getTickCount()

	Async:foreach(getElementsByType("vehicle"), function(veh)
		if getElementData(veh, "owner") > 0 then
			loadElementInventory(veh)
		end
	end, function()
		print("Loaded all car items in "..(getTickCount() - start).."ms!")

		local start = getTickCount()

		Async:foreach(getElementsByType("player"), function(player)
			if getElementData(player, "loggedin") then
				loadElementInventory(player)
			end
		end, function()
			print("Loaded all player items in "..(getTickCount() - start).."ms!")
		end)
	end)
end)

function loadElementInventory(elementSource)
	local elementType = getTypeOfElement(elementSource)[1]
	local elementOwnerID = getElementData(elementSource, "dbid")

	if elementType > 1 then
		loadedItems[elementType][elementOwnerID] = {["all"] = {}}
	else
		loadedItems[elementType][elementOwnerID] = {
			["bag"] = {},
			["key"] = {},
			["licens"] = {},
		}
	end

	dbQuery(function(qh, elementType, elementOwnerID)
		local result = dbPoll(qh, 0)

		for _, data in ipairs(result) do
			if elementType > 1 then
				loadedItems[elementType][elementOwnerID]["all"][tonumber(data["item_slot"])] = {
					["dbid"] = tonumber(data["id"]),
					["id"] = tonumber(data["item_id"]),
					["value"] = tonumber(data["item_value"]),
					["count"] = tonumber(data["item_count"]),
					["duty"] = tonumber(data["item_duty"]),
					["slot"] = tonumber(data["item_slot"]),
					["health"] = tonumber(data["item_health"])
				}
			else
				loadedItems[elementType][elementOwnerID][items[tonumber(data["item_id"])].typ][tonumber(data["item_slot"])] = {
					["dbid"] = tonumber(data["id"]),
					["id"] = tonumber(data["item_id"]),
					["value"] = tonumber(data["item_value"]),
					["count"] = tonumber(data["item_count"]),
					["duty"] = tonumber(data["item_duty"]),
					["slot"] = tonumber(data["item_slot"]),
					["health"] = tonumber(data["item_health"])
				}
			end
		end
	end, {elementType, elementOwnerID}, mysqlConnection, "SELECT * FROM items WHERE item_owner = ? and item_type = ?", elementOwnerID, elementType)
end

function getElementItems(elementSource, open)
	local elementType = getTypeOfElement(elementSource)[1]
	local elementOwnerID = getElementData(elementSource, "dbid")

	if not loadedItems[elementType][elementOwnerID] then
		loadElementInventory(elementSource)
	end

	triggerClientEvent(client, "setElementItems", client, loadedItems[elementType][elementOwnerID], elementSource, open)
end
addEvent("getElementItems", true)
addEventHandler("getElementItems", getRootElement(), getElementItems)

function giveItem(player, itemID, itemValue, itemCount, itemDuty, itemHealth)
	local elementType = getTypeOfElement(player)[1]
	local elementOwnerID = getElementData(player, "dbid")

	local itemID = tonumber(itemID)
	local itemValue = tonumber(itemValue)
	local itemCount = tonumber(itemCount)
	local itemDuty = tonumber(itemDuty)

	if not itemHealth then
		itemHealth = 100
	end

	local pSlotState, pSlotID = getFreeSlot(player, itemID)
	local weight = getElementItemsWeight(player)

	if weight + (getItemWeight(itemID) * itemCount) > getTypeOfElement(player)[2] then
		outputChatBox("#d9534f[SeeMTA]: #FFFFFFNincs elég helyed!", player, 255, 255, 255, true)
		return false
	end

	dbQuery(function(qh, itemID, itemValue, itemCount, itemDuty, itemHealth, elementOwnerID, pSlotID)
		local query, query_lines, id = dbPoll(qh, 0)

		loadedItems[elementType][elementOwnerID][items[itemID].typ][pSlotID] = {
			["dbid"] = id,
			["id"] = itemID,
			["value"] = itemValue,
			["count"] = itemCount,
			["duty"] = itemDuty,
			["slot"] = pSlotID,
			["health"] = itemHealth
		}

		triggerClientEvent(player, "setElementItems", player, loadedItems[elementType][elementOwnerID], player)

		if weaponModels[itemID] then
			addAttachWeapon(player, itemID, itemValue, id)
		end

		return true
	end, {itemID, itemValue, itemCount, itemDuty, itemHealth, elementOwnerID, pSlotID}, mysqlConnection, "INSERT INTO items SET item_id = ?, item_slot = ?, item_owner = ?, item_value = ?, item_count = ?, item_type = 1, item_duty = ?, item_health = ?", itemID, pSlotID, elementOwnerID, itemValue, itemCount, itemDuty, itemHealth)
end
addEvent("giveItem", true)
addEventHandler("giveItem", getRootElement(), giveItem)

function takeStatus(elementSource, itemDBID, newStatus)
	if (newStatus) then
		dbExec(mysqlConnection, "UPDATE items SET item_health = ? WHERE id = ?", newStatus, itemDBID)
	end
end
addEvent("takeStatus", true)
addEventHandler("takeStatus", getRootElement(), takeStatus)

function updateItemSlot(elementSource, newSlot, activeItem)
	local elementType = getTypeOfElement(elementSource)[1]
	local elementOwnerID = getElementData(elementSource, "dbid")

	dbExec(mysqlConnection, "UPDATE items SET item_slot = ? WHERE id = ?", newSlot, activeItem["dbid"])

	if elementType > 1 then
		loadedItems[elementType][elementOwnerID]["all"][activeItem["slot"]] = nil
		loadedItems[elementType][elementOwnerID]["all"][newSlot] = activeItem
		loadedItems[elementType][elementOwnerID]["all"][newSlot]["slot"] = newSlot
	else
		loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][activeItem["slot"]] = nil
		loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][newSlot] = activeItem
		loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][newSlot]["slot"] = newSlot
	end

	triggerClientEvent(client, "setElementItems", client, loadedItems[elementType][elementOwnerID], elementSource)
end
addEvent("updateItemSlot", true)
addEventHandler("updateItemSlot", getRootElement(), updateItemSlot)

function updateItemCount(elementSource, itemSlot, newCount, activeItem, type, newItemCount)
	local elementType = getTypeOfElement(elementSource)[1]
	local elementOwnerID = getElementData(elementSource, "dbid")
	
	if type == 1 then
		dbExec(mysqlConnection, "UPDATE items SET item_count = ? WHERE id = ?", newCount, activeItem["dbid"])
		dbQuery(function(qh, client, itemSlot, activeItem, newItemCount)
			local result, rows, id = dbPoll(qh, 0)
	
			if elementType > 1 then
				loadedItems[elementType][elementOwnerID]["all"][activeItem["slot"]]["count"] = newCount
				loadedItems[elementType][elementOwnerID]["all"][itemSlot] = activeItem
				loadedItems[elementType][elementOwnerID]["all"][itemSlot]["dbid"] = id
				loadedItems[elementType][elementOwnerID]["all"][itemSlot]["slot"] = itemSlot
				loadedItems[elementType][elementOwnerID]["all"][itemSlot]["count"] = newItemCount
			else
				loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][activeItem["slot"]]["count"] = newCount
				loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot] = activeItem
				loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["dbid"] = id
				loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["slot"] = itemSlot
				loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["count"] = newItemCount
			end
	
			triggerClientEvent(client, "setElementItems", client, loadedItems[elementType][elementOwnerID], elementSource)
		end, {client, itemSlot, activeItem, newItemCount}, mysqlConnection, "INSERT INTO items SET item_id = ?, item_slot = ?, item_owner = ?, item_value = 1, item_count = ?, item_type = ?, item_duty = 0, item_health = 100", activeItem["id"], itemSlot, elementOwnerID, newItemCount, elementType)
	elseif type == 2 then
		dbExec(mysqlConnection, "UPDATE items SET item_count = ? WHERE id = ?", newItemCount, activeItem["dbid"])

		if elementType > 1 then
			loadedItems[elementType][elementOwnerID]["all"][itemSlot]["count"] = newCount
			loadedItems[elementType][elementOwnerID]["all"][activeItem["slot"]]["count"] = newItemCount
			dbExec(mysqlConnection, "UPDATE items SET item_count = ? WHERE id = ?", newCount, loadedItems[elementType][elementOwnerID]["all"][itemSlot]["dbid"])
		else
			loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["count"] = newCount
			loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][activeItem["slot"]]["count"] = newItemCount
			dbExec(mysqlConnection, "UPDATE items SET item_count = ? WHERE id = ?", newCount, loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["dbid"])
		end

		triggerClientEvent(client, "setElementItems", client, loadedItems[elementType][elementOwnerID], elementSource)
	elseif type == 3 then
		dbExec(mysqlConnection, "UPDATE items SET item_count = ? WHERE id = ?", newCount, activeItem)

		loadedItems[elementType][elementOwnerID]["bag"][itemSlot]["count"] = newCount

		triggerClientEvent(client, "setElementItems", client, loadedItems[elementType][elementOwnerID], elementSource)
	else
		dbExec(mysqlConnection, "DELETE FROM items WHERE id = ?", activeItem["dbid"])

		if elementType > 1 then
			loadedItems[elementType][elementOwnerID]["all"][itemSlot]["slot"] = itemSlot
			loadedItems[elementType][elementOwnerID]["all"][itemSlot]["count"] = newCount
			loadedItems[elementType][elementOwnerID]["all"][activeItem["slot"]] = nil
			dbExec(mysqlConnection, "UPDATE items SET item_count = ? WHERE id = ?", newCount, loadedItems[elementType][elementOwnerID]["all"][itemSlot]["dbid"])
		else
			loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["slot"] = itemSlot
			loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["count"] = newCount
			loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][activeItem["slot"]] = nil
			dbExec(mysqlConnection, "UPDATE items SET item_count = ? WHERE id = ?", newCount, loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][itemSlot]["dbid"])
		end

		triggerClientEvent(client, "setElementItems", client, loadedItems[elementType][elementOwnerID], elementSource)
	end
end
addEvent("updateItemCount", true)
addEventHandler("updateItemCount", getRootElement(), updateItemCount)

function updateItemValue(elementSource, itemSlot, newValue, itemDBID)
	if (newValue and itemDBID) then
		dbExec(mysqlConnection, "UPDATE items SET item_value = ? WHERE id = ?", newValue, itemDBID)
	end
end
addEvent("updateItemValue", true)
addEventHandler("updateItemValue", getRootElement(), updateItemValue)

function removeDutyItems(element)
	local playerItems = loadedItems[getTypeOfElement(element)[1]][getElementData(element, "dbid")]
	for k, v in ipairs(playerItems["bag"]) do
		if (tonumber(v["duty"]) >= 1) then
			deleteItem(element, v)
		end
	end
	for k, v in ipairs(playerItems["key"]) do
		if (tonumber(v["duty"]) >= 1) then
			deleteItem(element, v)
		end
	end
	for k, v in ipairs(playerItems["licens"]) do
		if (tonumber(v["duty"]) >= 1) then
			deleteItem(element, v)
		end
	end
end

function deleteItem(elementSource, activeItem, player)
	local elementType = getTypeOfElement(elementSource)[1]
	local elementOwnerID = getElementData(elementSource, "dbid")

	dbExec(mysqlConnection, "DELETE FROM items WHERE id = ?", activeItem["dbid"])

	if elementType > 1 then
		loadedItems[elementType][elementOwnerID]["all"][activeItem["slot"]] = nil
	else
		loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][activeItem["slot"]] = nil
	end

	if weaponModels[activeItem["id"]] then
		delAttachWeapon(client, activeItem["id"], activeItem["value"], activeItem["dbid"])
	end

	if not client then client = player end
	triggerClientEvent(client, "setElementItems", client, loadedItems[elementType][elementOwnerID], elementSource)
end
addEvent("deleteItem", true)
addEventHandler("deleteItem", getRootElement(), deleteItem)

function takeWeaponFromPlayer(element)
	takeAllWeapons(element)
	setElementData(element, "Char->usingWeapon", {false, -1, -1, -1, -1, -1})
end
addEvent("takeWeaponFromPlayer", true)
addEventHandler("takeWeaponFromPlayer", getRootElement(), takeWeaponFromPlayer)

addEventHandler("onPlayerQuit", root, function()
	if weapons[source] then
		for k, v in ipairs(weapons[source]) do
			if isElement(v[1]) then
				destroyElement(v[1])
				weapons[source] = {}
			end
		end
	end
end)

function tradeItem(elementSource, activeElementSource, activeItem)
	if (client and isElement(elementSource) and activeItem) then
		local elementType = getTypeOfElement(elementSource)[1]
		local activeElementType = getTypeOfElement(activeElementSource)[1]

		local elementOwnerID = getElementData(elementSource, "dbid")
		local activeElementOwnerID = getElementData(activeElementSource, "dbid")

		local weight = getElementItemsWeight(elementSource)

		if weight + (getItemWeight(activeItem["id"]) * activeItem["count"]) > getTypeOfElement(elementSource)[2] then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFNincs elég hely nála, hogy át tudd neki adni ezt a tárgyat!", client, 255, 255, 255, true)
			return
		end

		if elementType > 1 then
			pSlotState, pSlotID = getFreeSlotFromCar(elementSource, activeItem["id"])
		else
			pSlotState, pSlotID = getFreeSlot(elementSource, activeItem["id"])
		end

		if (pSlotState and pSlotID) then
			dbExec(mysqlConnection, "UPDATE items SET item_type = ?, item_owner = ?, item_slot = ? WHERE id = ?", elementType, elementOwnerID, pSlotID, activeItem["dbid"])

			if activeElementType > 1 then
				loadedItems[activeElementType][activeElementOwnerID]["all"][activeItem["slot"]] = nil
			else
				loadedItems[activeElementType][activeElementOwnerID][items[activeItem["id"]].typ][activeItem["slot"]] = nil
			end

			if elementType > 1 then
				loadedItems[elementType][elementOwnerID]["all"][pSlotID] = activeItem
				loadedItems[elementType][elementOwnerID]["all"][pSlotID]["slot"] = pSlotID
			else
				loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][pSlotID] = activeItem
				loadedItems[elementType][elementOwnerID][items[activeItem["id"]].typ][pSlotID]["slot"] = pSlotID
			end

			triggerClientEvent(client, "setElementItems", client, loadedItems[activeElementType][activeElementOwnerID], activeElementSource)
		end

		if elementType == 1 and getElementType(activeElementSource) ~= "vehicle" and elementSource ~= client then
			itemAnim(client,elementSource)
			if weaponModels[activeItem["id"]] then
				delAttachWeapon(client,activeItem["id"],activeItem["value"],activeItem["dbid"])
				addAttachWeapon(elementSource,activeItem["id"],activeItem["value"],activeItem["dbid"])
			end
			exports.sas_chat:sendLocalMeAction(client, "átadott egy tárgyat "..getPlayerName(elementSource):gsub("_", " ").."-nak/nek. ("..items[activeItem["id"]].name ..")")
			triggerClientEvent(elementSource, "setElementItems", elementSource, loadedItems[elementType][elementOwnerID], elementSource)
		elseif elementType == 2 and elementSource ~= client then
			if weaponModels[activeItem["id"]] then
				delAttachWeapon(client,activeItem["id"],activeItem["value"],activeItem["dbid"])
			end
			exports.sas_chat:sendLocalMeAction(client, "berak egy tárgyat a kocsiba ("..items[activeItem["id"]].name ..")")
		elseif getElementType(activeElementSource) == "vehicle" and elementSource == client then
			if weaponModels[activeItem["id"]] then
				addAttachWeapon(client,activeItem["id"],activeItem["value"],activeItem["dbid"])
			end
			exports.sas_chat:sendLocalMeAction(client,"kivett egy tárgyat a jármű csomagtartójából. ("..items[activeItem["id"]].name..")")
		end
	end
end
addEvent("tradeItem", true)
addEventHandler("tradeItem", getRootElement(), tradeItem)

function itemAnim(element, targetElement)
	if isElement(element) and isElement(targetElement) then
		setPedAnimation(element,"DEALER","DEALER_DEAL",3000,false,false,false,false)
		setPedAnimation(targetElement,"DEALER","DEALER_DEAL",3000,false,false,false,false)
	end
end
addEvent("itemAnim", true)
addEventHandler("itemAnim", root, itemAnim)

function getElementItemsWeight(element)
	local elementType = getTypeOfElement(element)[1]
	local playerItems = loadedItems[elementType][getElementData(element, "dbid")]

	if elementType > 1 then
		local allWeight = 0
		for i = 1, row * column do
			if (playerItems["all"][i]) then
				allWeight = allWeight + (getItemWeight(playerItems["all"][i]["id"]) * playerItems["all"][i]["count"])
			end
		end
		return math.ceil(allWeight)
	else
		local bagWeight = 0
		local keyWeight = 0
		local licensWeight = 0
		for i = 1, row * column do
			if (playerItems["bag"][i]) then
				bagWeight = bagWeight + (getItemWeight(playerItems["bag"][i]["id"]) * playerItems["bag"][i]["count"])
			end
		end
		for i = 1, row * column do
			if (playerItems["key"][i]) then
				keyWeight = keyWeight + (getItemWeight(playerItems["key"][i]["id"]) * playerItems["key"][i]["count"])
			end
		end
		for i = 1, row * column do
			if (playerItems["licens"][i]) then
				licensWeight = licensWeight + (getItemWeight(playerItems["licens"][i]["id"]) * playerItems["licens"][i]["count"])
			end
		end
		return math.ceil(bagWeight + licensWeight + keyWeight)
	end
end

function hasKey(itemID, itemValue)
	local playerItems = loadedItems[1][getElementData(client, "dbid")]
	if (client and itemID) then
		if itemValue then
			for k, v in ipairs(playerItems["key"]) do
				local pItemID = v["id"]
				local pItemCount = v["count"]
				local pItemValue = v["value"]

				if (tonumber(itemID) == pItemID and tonumber(pItemValue) == itemValue) then
					return true, (k - 1), pItemID, pItemValue, pItemCount
				end
			--	outputChatBox("item value: ".. pItemValue.. "lekért value "..itemValue)
			end
		end
	end
	return false
end

function hasItem(itemID, itemValue)
	local playerItems = loadedItems[1][getElementData(client, "dbid")]
	if (client and itemID) then
		if itemValue then
			for i = 1, row * column do
				if (playerItems["bag"][i]) then
					if (itemID == playerItems["bag"][i]["id"]) then
					--	if (itemID == v[i]["id"]) then
						--if (tonumber(itemID) == tonumber(pItemID) and tonumber(pItemValue) == itemValue) then
						if (itemID == playerItems["bag"][i]["id"]) and (itemValue == playerItems["bag"][i]["value"]) then
							--outputChatBox("lejon")
							return true
						end
					end
				end
			end
			for k, v in ipairs(playerItems["key"]) do
				local pItemID = v["id"]
				local pItemCount = v["count"]
				local pItemValue = v["value"]

				if (tonumber(itemID) == pItemID and tonumber(pItemValue) == itemValue) then
					return true, (k - 1), pItemID, pItemValue, pItemCount
				end
			--	outputChatBox("item value: ".. pItemValue.. "lekért value "..itemValue)
			end
			for k, v in ipairs(playerItems["licens"]) do
				local pItemID = v["id"]
				local pItemCount = v["count"]
				local pItemValue = v["value"]

				if (tonumber(itemID) == pItemID and tonumber(pItemValue) == itemValue) then
					return true, (k - 1), pItemID, pItemValue, pItemCount
				end
			end

		else
			--outputChatBox("itemek lekérve")
			for k, v in ipairs(playerItems["bag"]) do
				local pItemID = v["id"]
				local pItemCount = v["count"]
				local pItemValue = v["value"]
				if (tonumber(itemID) == pItemID) then
					--outputChatBox("itemek lekérve")
					return true, (k - 1), pItemID, pItemValue, pItemCount
				end
			end
			for k, v in ipairs(playerItems["key"]) do
				local pItemID = v["id"]
				local pItemCount = v["count"]
				local pItemValue = v["value"]
				if (tonumber(itemID) == pItemID) then
					return true, (k - 1), pItemID, pItemValue, pItemCount
				end
			end
			for k, v in ipairs(playerItems["licens"]) do
				local pItemID = v["id"]
				local pItemCount = v["count"]
				local pItemValue = v["value"]
				if (tonumber(itemID) == pItemID) then
					return true, (k - 1), pItemID, pItemValue, pItemCount
				end
			end
		end
	end
	return false
end

function hasItemBag(itemID)
	local items = loadedItems[1][getElementData(client, "dbid")]
	for k, v in pairs( items["key"] ) do
		if v["id"] == tonumber(itemID) then
			return true
		end
	end
	return false
end

addCommandHandler("giveitem", function(player, cmd, target, id, value, count, duty)
	if tonumber(getElementData(player, "adminlevel")) <= 6 then return end
	if target and id and value and count and duty then
		local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(player, target)
		if targetPlayer then
			giveItem(targetPlayer, tonumber(id), tonumber(value), tonumber(count), tonumber(duty))
		elseif not targetPlayer then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFNem található ilyen játékos!",player,255,255,255,true)
		end
	else
		outputChatBox("#7cc576[SeeMTA]: #FFFFFF/"..cmd.." [Játékos ID] [Item ID] [Item Value = 1 / Kocsi,Ház = ID / Tárnál = 30] [DB] [Duty Item = 1, 0]", player,255,255,255,true)
	end
end)

function hasPlayerAmmo(player, item_id)
	local playerItems = loadedItems[1][getElementData(player, "dbid")]
	if playerItems then
		for i=1, (row*column) do
			if(playerItems["bag"][i] and tonumber(playerItems["bag"][i]["id"] or -1) > 0)then
				if tonumber(playerItems["bag"][i]["id"]) == item_id and tonumber(playerItems["bag"][i]["count"]) > 0 then
					return {true, i, playerItems["bag"][i]["count"]}
				end
			end
		end
		return {false, -1, 0}
	end
end

function getFreeSlot(elementSource, forItemID)
	local playerItems = loadedItems[getTypeOfElement(elementSource)[1]][getElementData(elementSource, "dbid")]
	local nextSlot = 1
	for i = 1, (row * column) do
		if not (playerItems[items[forItemID].typ][i]) then
			return true, nextSlot
		else
			nextSlot = nextSlot  + 1
		end
	end

	return false, -1
end

function getFreeSlotFromCar(elementSource, forItemID)
	local playerItems = loadedItems[getTypeOfElement(elementSource)[1]][getElementData(elementSource, "dbid")]
	local nextSlot = 1
	for i = 1, (row * column) do
		if not (playerItems["all"][i]) then
			return true, nextSlot
		else
			nextSlot = nextSlot  + 1
		end
	end

	return false, -1
end

function addAttachWeapon(player,item,value,dbid)
	if not weapons[player] then
		weapons[player] = {}
	end
	if not isElement(weapons[player][dbid]) or not weapons[player][dbid] then
		local x,y,z = getElementPosition(player)
		if weaponModels[item] then
			weapons[player][dbid] = createObject(weaponModels[item][1],0,0,0)
			setElementCollisionsEnabled(weapons[player][dbid], false)
			setElementPosition(weapons[player][dbid], x, y, z)
			setElementInterior(weapons[player][dbid],getElementInterior(player))
			setElementDimension(weapons[player][dbid],getElementDimension(player))
			setElementData(weapons[player][dbid],"attachedObject",true)

			if tonumber(item) == 264 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"ak", "camo3")
			elseif tonumber(item) == 265 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"ak", "camo2")
			elseif tonumber(item) == 266 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"ak", "camo")
			elseif tonumber(item) == 267 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"ak", "gold")
			elseif tonumber(item) == 268 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"ak", "gold2")
			elseif tonumber(item) == 269 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"ak", "silver")
			elseif tonumber(item) == 270 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"ak", "kitty")
				--outputChatBox("létrejött item")
			end

			if tonumber(item) == 271 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"deagle", "camo", "deagle")
				--outputChatBox("rajta item")
			elseif tonumber(item) == 272 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"deagle", "gold", "deagle")
			end
			if tonumber(item) == 273 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"tekstura", "camo", "sniper")
			elseif tonumber(item) == 274 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"tekstura", "camo2", "sniper")
			end

			if tonumber(item) == 275 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"mp5", "mp51", "mp5")
			elseif tonumber(item) == 276 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"mp5", "mp52", "mp5")
			elseif tonumber(item) == 277 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"mp5", "mp53", "mp5")
			elseif tonumber(item) == 278 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"mp5", "mp54", "mp5")
			end

			if tonumber(item) == 279 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"kabar", "knife1", "knife")
			elseif tonumber(item) == 280 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"kabar", "knife2", "knife")
			elseif tonumber(item) == 281 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"kabar", "knife3", "knife")
			end

			if tonumber(item) == 282 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"9mm_c", "tec1", "tec")
			elseif tonumber(item) == 283 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"9mm_c", "tec2", "tec")
			elseif tonumber(item) == 284 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"9mm_c", "tec3", "tec")
			elseif tonumber(item) == 285 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"9mm_c", "tec4", "tec")
			end

			if tonumber(weaponIndexByID[item]) == 23 and tonumber(value) == 20 then
				exports["sas_weapontuning"]:setObjectPaintjob(weapons[player][dbid],"1911", "silenced1")
			end

			exports.bone_attach:attachElementToBone(weapons[player][dbid], player, weaponPositions[tonumber(weaponIndexByID[item])][1], weaponPositions[tonumber(weaponIndexByID[item])][2] ,weaponPositions[tonumber(weaponIndexByID[item])][3], weaponPositions[tonumber(weaponIndexByID[item])][4], weaponPositions[tonumber(weaponIndexByID[item])][5], weaponPositions[tonumber(weaponIndexByID[item])][6], weaponPositions[tonumber(weaponIndexByID[item])][7])
		end
	end
end
addEvent("addAttachWeapon",true)
addEventHandler("addAttachWeapon",getRootElement(),addAttachWeapon)

function delAttachWeapon(player, item, value, dbid)
	if weapons[player] then
		if isElement(weapons[player][dbid]) then
			exports.bone_attach:detachElementFromBone(weapons[player][dbid])
			destroyElement(weapons[player][dbid])
			weapons[player][dbid] = {}
		end
	end
end
addEvent("delAttachWeapon",true)
addEventHandler("delAttachWeapon",getRootElement(),delAttachWeapon)

function openCsomagtarto(vehicle, ratio)
	setVehicleDoorOpenRatio(vehicle, 1, ratio, 800)
end
addEvent("openCsomagtarto",true)
addEventHandler("openCsomagtarto",getRootElement(),openCsomagtarto)
