local connection = exports.sas_mysql:getConnection()

function loadPlayerGroupsCallback(queryHandler, thePlayer)

	local i = 0

	local result, numAffectedRows, errorMsg = dbPoll(queryHandler, -1)

	if numAffectedRows > 0 then

		for result, row in pairs (result) do

			setElementData(thePlayer, "group_" .. i, row["groupID"], true)

			setElementData(thePlayer, "group_" .. i .. "_leader", row["isLeader"], true)

			setElementData(thePlayer, "group_" .. i .. "_rank", row["rank"], true)

			i = i + 1

		end

	end

	setElementData(thePlayer, "groupCount", i, true)

end



addEvent("respawnPet", true)

addEventHandler("respawnPet", getRootElement(),

	function(petid)

		if getElementData(source, "pp") >= 100 then

			setElementData(source, "pp", getElementData(source, "pp")-100)

			exports.sas_pets:respawnPet(petid)

			triggerClientEvent(source, "respawnPetOK", source)

		else

			triggerClientEvent(source, "respawnPetNoPP", source)

		end

	end)



addEvent("spawnPet", true)

addEventHandler("spawnPet", getRootElement(),

	function(petid)

		exports.sas_pets:spawnPet(petid, source)

		setElementData(source, "spawnedPet", true)

	end)



	addEvent("despawnPet", true)

	addEventHandler("despawnPet", getRootElement(),

		function(petid)

			exports.sas_pets:despawnPet(petid)

			setElementData(source, "spawnedPet", false)

		end)



function debug(cmd, player)

	setElementData(cmd, "spawnedPet", false)

end

addCommandHandler("null", debug)



function prefixChange( playerSource, commandName )

	setElementData(playerSource, "prefix", true)

end

addCommandHandler ( "setprefix", prefixChange )



addEvent("buyPet", true)

addEventHandler("buyPet", getRootElement(),

	function(petName, petTypeNum)

		if getElementData(source, "pp") < 8000 then

			triggerClientEvent(source, "buyPetNoPP", source)

		else

			exports.sas_pets:createPetServer(source, petName, petTypeNum)

			triggerClientEvent(source, "buyPetOK", source)

			setElementData(source, "pp", getElementData(source, "pp")-8000)

			exports.sas_hud:addNotification(source, "Sikeres vásárlás.", "success")

		end

	end)



addEvent("buyVehSlot", true)

addEventHandler("buyVehSlot", getRootElement(),

	function(slot)

		if slot then

			if tonumber(slot) > 0 then

				dbQuery(

					function(queryHandler, thePlayer, price, slot)

						if isElement(thePlayer) then

							local result, numAffectedRows, errorMsg = dbPoll(queryHandler, -1)

							if numAffectedRows > 0 then

								for key, row in pairs(result) do

									if (row["pp"] - price) < 0 then

										triggerClientEvent(thePlayer, "buySlotNoPP", thePlayer)

									else



										dbQuery(

											function (qh, thePlayer, price, slot, row)

												dbFree(qh)



												if isElement(thePlayer) then

													setElementData(thePlayer, "pp", row["pp"] - price)



													local maxVehicles = getElementData(thePlayer, "maxvehicles") or 0



													setElementData(thePlayer, "maxvehicles", maxVehicles + slot)



													local result = {}



													result[1] = {}



													result[1]["pp"] = row["pp"] - price



													--result[1]["premiumPoints"]

													triggerClientEvent(thePlayer, "requestDatas", thePlayer, "premium", result)

													triggerClientEvent(thePlayer, "buySlotOK", thePlayer)

													if not dbPoll ( dbQuery( connection, "UPDATE characters SET maxvehicles='?' WHERE id='?'", maxVehicles + slot, getElementData(thePlayer, "dbid")), -1 ) then

														outputChatBox("hiba a Slot mentése közben")

													end

												end

											end, {thePlayer, slot * 100, slot, row}, connection, "UPDATE characters SET pp = ? WHERE id = ?", row["pp"] - tonumber(price), getElementData(thePlayer, "dbid"))

									end

								end

							end

						end

					end,

				{source, slot * 100, slot}, connection, "SELECT pp FROM characters WHERE id = ?", getElementData(source, "dbid"))

			end

		end

	end
)



function loadPlayerGroups(thePlayer)

	local count = getElementData(thePlayer, "groupCount") or false

	if count then

		for i=0, count-1 do

			removeElementData(thePlayer, "group_" .. i)

			removeElementData(thePlayer, "group_" .. i .. "_leader")

			removeElementData(thePlayer, "group_" .. i .. "_rank")

		end

	end



	charID = getElementData(thePlayer, "dbid")



	if charID then

		local query = dbQuery(loadPlayerGroupsCallback, {thePlayer}, connection, "SELECT * FROM groupAttach WHERE characterID = ?", charID)

	end

end



function reloadGroupDatasForPlayer(qh, player, sourcePlayer, sourceGroups, playerID, groupID)

	if isElement(player) then

		loadPlayerGroups(player)

	end



	if isElement(sourcePlayer) then

		requestGroupData(sourcePlayer, sourceGroups, playerID, groupID)

	end



	dbFree(qh)

end



addEvent("modifyRankForPlayer", true)

addEventHandler("modifyRankForPlayer", getRootElement(),

	function (playerID, currRank, groupID, state, player, sourceGroups)

		if playerID and currRank and groupID and state then

			if state == "up" then

				if currRank < 15 then

					dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups, playerID, groupID}, connection, "UPDATE groupAttach SET rank = ? WHERE groupID = ? AND characterID = ?", currRank + 1,  groupID, playerID)

				end

			elseif state == "down" then

				if currRank > 1 then

					dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups, playerID, groupID}, connection, "UPDATE groupAttach SET rank = ? WHERE groupID = ? AND characterID = ?", currRank - 1,  groupID, playerID)

				end

			end

		end

	end

)



addEvent("deletePlayerFromGroup", true)

addEventHandler("deletePlayerFromGroup", getRootElement(),

	function (playerID, groupID, player, sourceGroups)

		if playerID and groupID then

			dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups}, connection, "DELETE FROM groupAttach WHERE groupID = ? AND characterID = ?", groupID, playerID)

		end

	end

)



addEvent("invitePlayer", true)

addEventHandler("invitePlayer", getRootElement(),

	function (playerID, groupID, player, sourceGroups)

		if playerID and groupID then

			dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups}, connection, "INSERT INTO groupAttach (groupID, characterID) VALUES (?,?)", groupID, playerID)

		end

	end

)



local groups = {}

local groupCount = 0



addEvent("renameRank", true)

addEventHandler("renameRank", getRootElement(),

	function (rankId, rankName, groupId)

		dbQuery(

			function (qh)

				groups[groupId]["rank_" .. tonumber(rankId)] = rankName



				triggerClientEvent("renameGroupRank", getRootElement(), "rank_" .. tonumber(rankId), rankName, groupId)



				dbFree(qh)

			end, connection, "UPDATE groups SET rank_" .. tonumber(rankId) .. " = ? WHERE groupID = ?", rankName, groupId)

	end

)



addEvent("rewriteDescription", true)

addEventHandler("rewriteDescription", getRootElement(),

	function (description, groupId)

		dbQuery(

			function (qh)

				groups[groupId]["description"] = description



				triggerClientEvent("renameGroupRank", getRootElement(), "description", description, groupId)



				dbFree(qh)

			end, connection, "UPDATE groups SET description = ? WHERE groupID = ?", description, groupId)

	end

)



addEvent("setRankPayment", true)

addEventHandler("setRankPayment", getRootElement(),

	function (rankId, payment, groupId)

		dbQuery(

			function (qh)

				groups[groupId]["rank_" .. tonumber(rankId) .. "_pay"] = payment



				triggerClientEvent("renameGroupRank", getRootElement(), "rank_" .. tonumber(rankId) .. "_pay", payment, groupId)



				dbFree(qh)

			end, connection, "UPDATE groups SET rank_" .. tonumber(rankId) .. "_pay = ? WHERE groupID = ?", payment, groupId)

	end

)



addEvent("setBalance", true)

addEventHandler("setBalance", getRootElement(),

	function (set, groupId)

		local currentBalance = groups[groupId]["balance"]



		currentBalance = currentBalance + set



		local currentMoney = getElementData(source, "money")

		if currentBalance < 0 then

			triggerClientEvent(source, "setErrorMessage", source, "#d9534fNincs elegendő pénz a számlán.")

		else

			if set > 0 and currentMoney < set then

				triggerClientEvent(source, "setErrorMessage", source, "#d9534fNincs elég pénzed.")

			else

				setElementData(source, "money", currentMoney - set)



				groups[groupId]["balance"] = currentBalance



				dbQuery(

					function (qh, player)

						triggerClientEvent("renameGroupRank", getRootElement(), "balance", currentBalance, groupId)

						triggerClientEvent(player, "setErrorMessage", player, "#acd373Sikeres tranzakció!")

						dbFree(qh)

					end, {source}, connection, "UPDATE groups SET balance = ? WHERE groupID = ?", currentBalance, groupId)

			end

		end

	end

)







function requestGroupData(source, groups, playerID, groupID)

	local members = {}

	local vehicles = {}



	dbQuery(

		function (qh, client)

			local result = dbPoll(qh, 0)



			for k, row in ipairs(result) do

				if row["characterName"] then

					local group = row["groupId"]



					if not members[group] then

						members[group] = {}

					end



					table.insert(members[group], row)

				end

			end

			dbFree(qh)

			triggerClientEvent(client, "sendGroupMembers", client, members, playerID, groupID)

		end, {source}, connection, "SELECT groupAttach.groupID as groupId, groupAttach.rank as rank, groupAttach.isLeader as isLeader, groupAttach.dutySkin as dutySkin, characters.charactername as characterName, characters.id as id FROM groupAttach LEFT JOIN characters ON characters.id=groupAttach.characterID WHERE groupAttach.groupID in (" .. table.concat(groups, ",") .. ") ORDER BY groupAttach.groupID, groupAttach.rank, characters.charactername", groupId)

end



function getGroupBalance(groupId)

	if tonumber(groupId) then

		if groups[tonumber(groupId)] then

			return tonumber(groups[tonumber(groupId)]["balance"])

		else

			return false

		end

	else

		return false

	end

end



function setGroupBalance(groupId, balance)

	if tonumber(groupId) and tonumber(balance) then

		if groups[tonumber(groupId)] then

			dbExec(connection, "UPDATE groups SET balance = ? WHERE groupID = ?", tonumber(balance), tonumber(groupId))

			groups[tonumber(groupId)]["balance"] = tonumber(balance)

		else

			return false

		end

	else

		return false

	end

end



function getGroupRankPay(groupId, groupRank)

	if tonumber(groupId) and groupRank then

		if groups[tonumber(groupId)] then

			return groups[tonumber(groupId)]["rank_" .. groupRank .. "_pay"] or false

		else

			return false

		end

	else

		return false

	end

end





function callback(qh, client, type)

	local result = dbPoll(qh, 0)

	--result[1]["premiumPoints"]

	triggerClientEvent(client, "requestDatas", client, type, result)

end



addEvent("requestDatas", true )

addEventHandler("requestDatas", getRootElement(),

	function (accID, id)

		dbQuery(callback, {client, "premium"}, connection, "SELECT pp FROM characters WHERE id=?", accID)



		dbQuery(callback, {client, "interiors"}, connection, "SELECT * FROM interiors WHERE owner=?", id)



		dbQuery(callback, {client, "pets"}, connection, "SELECT * FROM pets WHERE owner=?", id)

	end)



addEvent("requestGroupData", true )

addEventHandler("requestGroupData", getRootElement(),

		function (groups)

			requestGroupData(source, groups)

		end

	)



addEvent("requestGroups", true )

addEventHandler("requestGroups", getRootElement(),

	function ()

		triggerClientEvent(source, "sendGroups", source, groups)

	end)



function loadGroups()

	local query = dbQuery(loadGroupsCallback, {playerSource}, connection, "SELECT * FROM groups")



	for _, v in ipairs(getElementsByType("player")) do

		loadPlayerGroups(v)

	end

end

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), loadGroups)



function loadGroupsCallback(queryHandler, thePlayer)

	local result, numAffectedRows, errorMsg = dbPoll(queryHandler, 0)

	if (numAffectedRows > 0) then

		local i = 1

		for result, row in pairs ( result ) do

			local id = row["groupID"]



			groups[id] = {}

			groups[id]["groupID"] = id

			groups[id]["name"] = row["Name"]

			groups[id]["type1"] = row["type1"]

			groups[id]["type2"] = row["type2"]



			groups[id]["balance"] = row["balance"]



			groups[id]["rank_1"] = row["rank_1"]

			groups[id]["rank_2"] = row["rank_2"]

			groups[id]["rank_3"] = row["rank_3"]

			groups[id]["rank_4"] = row["rank_4"]

			groups[id]["rank_5"] = row["rank_5"]

			groups[id]["rank_6"] = row["rank_6"]

			groups[id]["rank_7"] = row["rank_7"]

			groups[id]["rank_8"] = row["rank_8"]

			groups[id]["rank_9"] = row["rank_9"]

			groups[id]["rank_10"] = row["rank_10"]

			groups[id]["rank_11"] = row["rank_11"]

			groups[id]["rank_12"] = row["rank_12"]

			groups[id]["rank_13"] = row["rank_13"]

			groups[id]["rank_14"] = row["rank_14"]

			groups[id]["rank_15"] = row["rank_15"]



			groups[id]["rank_1_pay"] = row["rank_1_pay"]

			groups[id]["rank_2_pay"] = row["rank_2_pay"]

			groups[id]["rank_3_pay"] = row["rank_3_pay"]

			groups[id]["rank_4_pay"] = row["rank_4_pay"]

			groups[id]["rank_5_pay"] = row["rank_5_pay"]

			groups[id]["rank_6_pay"] = row["rank_6_pay"]

			groups[id]["rank_7_pay"] = row["rank_7_pay"]

			groups[id]["rank_8_pay"] = row["rank_8_pay"]

			groups[id]["rank_9_pay"] = row["rank_9_pay"]

			groups[id]["rank_10_pay"] = row["rank_10_pay"]

			groups[id]["rank_11_pay"] = row["rank_11_pay"]

			groups[id]["rank_12_pay"] = row["rank_12_pay"]

			groups[id]["rank_13_pay"] = row["rank_13_pay"]

			groups[id]["rank_14_pay"] = row["rank_14_pay"]

			groups[id]["rank_15_pay"] = row["rank_15_pay"]



			groups[id]["description"] = row["description"]



			i = i + 1

		end

		groupCount = i

	end

	setElementData(root, "FactionData", groups)

end



--duty skin



addEvent("onUpdateModel", true)

addEventHandler("onUpdateModel", getRootElement(),

	function (modelId)

		if tonumber(modelId) then

			setElementModel(source, tonumber(modelId))

			setElementData(source, "char.Skin", tonumber(modelId))

		end

	end

)



addEvent("updateDutySkin", true)

addEventHandler("updateDutySkin", getRootElement(),

	function (groupID, skin)

		if groupID and skin then

			local dbID = getElementData(source, "dbid")

			if dbID then

				dbExec(connection, "UPDATE groupAttach SET dutySkin = ? WHERE groupID = ? AND characterID = ?", tonumber(skin), tonumber(groupID), tonumber(dbID))

			end

		end

	end

)





function loginn(data)

	if data == "loggedin" then

		if getElementData(source,"loggedin") == 1 then

		outputDebugString("[Dash]: "..getPlayerName(source).." loginolt - frakik lekérve")

		loadPlayerGroups(source)

		end

	end

end

addEventHandler("onElementDataChange",getRootElement(),loginn)





------------------------PARANCSOK------------------------



function createGroup(playerSource, commandName, typ1, typ2, ...)

	if getElementData(playerSource,"adminlevel") >= 8 then

		if typ1 and typ2 and ... then

			typ1 = tonumber(typ1)

			typ2 = tonumber(typ2)

			groupName = table.concat({...}, " ")



			local theTeam = createTeam(tostring(groupName))

			if theTeam then

				local query, _, id = dbPoll ( dbQuery( connection, "INSERT INTO groups SET Name=?, balance='0', type1='?', type2='?'", groupName, typ1, typ2), -1 )



				if query then





					outputChatBox("#7cc576[SeeMTA - Csoport]: #4aabd0"..groupName.." #fffffffrakció sikeresen létrehozva! #7cc576(ID: ".. id .. " - Típus 1: ".. typ1 .." - Típus 2: ".. typ2 ..")", playerSource, 124, 197, 118, true)

				else



					outputChatBox("#7cc576[SeeMTA - Hiba]: SQL létrehozás hiba.", playerSource, 255, 0, 0,true)

				end

			else

				outputChatBox("#7cc576[SeeMTA - Hiba]: Ez a csoport már létezik. #4aabd0(" .. tostring(groupName) .. ")", playerSource, 255, 0, 0,true)

			end

		else

			outputChatBox("#7cc576[SeeMTA - Használat]: #ffffff/" .. commandName .. " [Típus 1] [Típus 2] [Név]", playerSource, 124, 197, 118, true)

			outputChatBox("#7cc576[Típus 1]: #ffffffBanda/Maffia = 2, Egyéb típus = 1", playerSource, 124, 197, 118, true)

			outputChatBox("#7cc576[Típus 2]: #ffffffRendvédelem = 1, Tűzoltóság = 2, Egészségügy = 3, Önkormányzat = 4, Maffia = 5, Banda = 6, Szervezet = 7", playerSource, 124, 197, 118, true)

		end

	end

end

addCommandHandler("makefrakcio", createGroup)





function setPlayerFaction(playerSource, commandName, targetPlayer, groupID, groupLeader)

	if getElementData(playerSource,"adminlevel") >= 6 then

		if targetPlayer and tonumber(groupID) and tonumber(groupLeader) then

			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(playerSource, targetPlayer)



			local selectQuery = dbPoll(dbQuery(connection, "SELECT * FROM groupAttach WHERE characterID = ? AND groupID = ?", getElementData(targetPlayer, "dbid"), groupID), -1)

			if #selectQuery > 0 then

				outputChatBox("#7cc576[SeeMTA - Csoport]: #FFFFFFJátékos már ebben a frakcióban van.", playerSource, 0, 0, 0, true)

			else



			  dbExec(connection, "INSERT INTO groupAttach (groupID, characterID, isLeader) VALUES (?,?,?)", tonumber(groupID), getElementData(targetPlayer, "dbid"), tonumber(groupLeader))



			  local groupQuery = dbQuery(connection, "SELECT * FROM groupAttach WHERE characterID = ?", getElementData(targetPlayer, "dbid"))

			  local groupResult, groupRows, groupError = dbPoll(groupQuery, -1)



			  if groupRows > 0 then

				local iGroup = 0

				for index, value in pairs(groupResult) do

				  setElementData(targetPlayer, "group_" .. iGroup, value["groupID"], true)

				  setElementData(targetPlayer, "group_" .. iGroup .. "_leader", value["isLeader"], true)

				  setElementData(targetPlayer, "group_" .. iGroup .. "_rank", value["rank"], true)

				  setElementData(targetPlayer, "group_" .. iGroup .. "_dutyskin", value["dutyskin"], true)

				  iGroup = iGroup + 1

				end

				setElementData(targetPlayer, "groupCount", iGroup, true)

			  end



			  local posText



			  if tonumber(groupLeader) == 1 then

				posText = "vezetőként"

			  else

				posText = "tagként"

			  end

				dbFree(groupQuery)

				loadPlayerGroups(targetPlayer)

			  outputChatBox("#7cc576[SeeMTA - Csoport]: #FFFFFFA kiválasztott játékos sikeresen felvéve a frakcióba " .. posText .. "!", playerSource, 0, 0, 0, true)

			end

		else

			outputChatBox("#7cc576[SeeMTA - Használat]: #ffffff/setfrakcio [Név/ID] [Frakció azonosító] [Leader 0/1]", playerSource, 255, 0, 0, true)

		end

	end

end

addCommandHandler("setfrakcio", setPlayerFaction)



function setPlayerLeader(playerSource, commandName, targetPlayer, groupLeader, groupID)

	if getElementData(playerSource,"adminlevel") >= 7 then

		if targetPlayer and tonumber(groupID) and tonumber(groupLeader) then

			local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(playerSource, targetPlayer)



				dbExec(connection, "UPDATE groupAttach SET isLeader = ? WHERE groupID = ? AND characterID = ?", tonumber(groupLeader), tonumber(groupID), getElementData(targetPlayer, "dbid"))



				local posText



			  if tonumber(groupLeader) == 1 then

				posText = "vezetőként"

			  else

				posText = "tagként"

			  end



			  outputChatBox("#7cc576[SeeMTA - Csoport]: #FFFFFFA kiválasztott játékos sikeresen felvéve a frakcióba " .. posText .. "!", playerSource, 0, 0, 0, true)



		else

			outputChatBox("#7cc576[SeeMTA - Használat]: #ffffff/setleader [Név/ID] [Ad/elvesz=0/1] [Frakció ID] ", playerSource,255,0,0,true)

		end

	end

end

addCommandHandler("setleader", setPlayerLeader)



function setFactionName(playerSource, commandName, groupID, nev)

	if getElementData(playerSource,"adminlevel") >= 6 then

		if nev and tonumber(groupID) then

			dbExec(connection, "UPDATE groups SET Name = ? WHERE groupID = ?", nev, tonumber(groupID))

			outputChatBox("#7cc576[SeeMTA - Csoport]: #FFFFFFFrakciónév sikeresen beállítva.", playerSource, 0, 0, 0, true)

		else

			outputChatBox("#7cc576[SeeMTA - Használat]: #ffffff/setfrakcionev [Azonosító] [Név]", playerSource,255,0,0,true)

		end

	end

end

addCommandHandler("setfrakcionev", setFactionName)



addCommandHandler("showfactions", function (playerSource)

	if tonumber(getElementData(playerSource, "adminlevel"))  >= 6 then

		local getPool = dbPoll(dbQuery(connection,"SELECT * FROM groups"), -1)

		if getPool then

			outputChatBox(" ", playerSource, 255, 255, 255, true)

			outputChatBox("Frakciók:", playerSource, 255, 255, 255, true)

			for i,v in ipairs(getPool) do

				outputChatBox("ID: #7cc576"..v['groupID'].. " #ffffffNeve: #7cc576".. v['Name'], playerSource, 255, 255, 255, true)

			end

		end

	end

end)



------------------------Exportált funkciók------------------------



function isInGroup(element, groupId)

	if isElement(element) and getElementType(element) == "player" then

		local groupCount = getElementData(element, "groupCount")

		if groupCount > 0 then

			for key = 0, groupCount do

				if getElementData(element, "group_"..key) == tonumber(groupId) then

					return true

				end

			end

		else

			return false

		end

	else

		return false

	end

end



function isGroupLeader(element, groupId)

	if isInGroup(element, groupId) then

		local groupCount = getElementData(element, "groupCount")

		if groupCount > 0 then

			for key = 0, groupCount do

				if getElementData(element, "group_"..key) == tonumber(groupId) and getElementData(element, "group_"..key.."_leader") == 1 then

					return true

				end

			end

		else

			return false

		end

	else

		return false

	end

end

