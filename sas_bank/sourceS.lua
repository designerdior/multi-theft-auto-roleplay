local sql = exports.sas_mysql:getConnection()
local obj = 2942
local atm = {}

addEvent("server->giveMoney", true)
addEventHandler("server->giveMoney", getRootElement(), function(amount, tax)
	if getElementData(client, "bankmoney") < amount then
		exports.sas_hud:addNotification(client, "Nincs elég pénz a bankszámládon!", "error")
		return
	end

	local newBankMoney = getElementData(client, "bankmoney") - amount

	setElementData(client, "money", getElementData(client, "money") + amount - tax)
	setElementData(client, "bankmoney", newBankMoney)
	exports.sas_hud:addNotification(client, "Sikeres tranzakció! Részletek a chatboxban!", "success")
	outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen kivettél #7cc576"..thousandsStepper(amount).." $-t #ffffffa számládról. Új egyenleged: #7cc576"..thousandsStepper(newBankMoney).." $ #ffffffKezelési költség: #7cc576"..thousandsStepper(tax).." $", client, 255, 255, 255, true)
end)

addEvent("server->takeMoney", true)
addEventHandler("server->takeMoney", getRootElement(), function(amount, tax)
	if getElementData(client, "money") < amount then
		exports.sas_hud:addNotification(client, "Nincs elég pénz nálad!", "error")
		return
	end

	local newBankMoney = getElementData(client, "bankmoney") + amount - tax

	setElementData(client, "money", getElementData(client, "money") - amount)
	setElementData(client, "bankmoney", newBankMoney)
	exports.sas_hud:addNotification(client, "Sikeres tranzakció! Részletek a chatboxban!", "success")
	outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen befizettél #7cc576"..thousandsStepper(amount).." $-t #ffffffa számládra. Új egyenleged: #7cc576"..thousandsStepper(newBankMoney).." $ #ffffffKezelési költség: #7cc576"..thousandsStepper(tax).." $", client, 255, 255, 255, true)
end)

addEvent("server->payMoney", true)
addEventHandler("server->payMoney", getRootElement(), function(to, amount, tax)
	if getElementData(client, "money") < amount then
		outputChatBox("#d75959[SeeMTA]: #ffffffNincs ennyi pénzed.", client, 255, 255, 255, true)
		return
	end

	setElementData(client, "money", getElementData(client, "money") - amount)
	setElementData(to, "money", getElementData(to, "money") + amount - tax)
	
	exports.sas_chat:sendLocalMeAction(client, "átadott egy kis pénzt neki: " .. getPlayerName(to):gsub("_", " "))
	outputChatBox("#7cc576[SeeMTA]: #2ab8e8"..getPlayerName(client):gsub("_", " ").." #ffffffadott neked #7cc576"..(amount - tax).." #ffffffdollárt. (Adó: #d75959"..tax.."#ffffff$)", to, 255, 255, 255, true)

	exports.sas_global:applyAnimation(client, "DEALER", "shop_pay", 4000, false, true, true)
end)

function loadOneATM(v)
	atm[tonumber(v["id"])] = createObject(obj, v["x"], v["y"], v["z"])
	setElementDimension(atm[tonumber(v["id"])], v["dimension"])
	setElementInterior(atm[tonumber(v["id"])], v["interior"])
	setElementRotation(atm[tonumber(v["id"])], 0, 0, tonumber(v["rotation"]))
	setElementData(atm[tonumber(v["id"])], "bankThing", true)
	setElementData(atm[tonumber(v["id"])], "bankID", tonumber(v["id"]))
end

dbQuery(function(qh)
	local result, rows = dbPoll(qh, 0)
	for k, v in ipairs(result) do
		loadOneATM(v)
	end
end, sql, "SELECT * FROM atms")

addCommandHandler("createatm", function(p)
	if getElementData(p, "adminlevel") >= 8 then
		local x, y, z = getElementPosition(p)
		local _, _, r = getElementRotation(p)
		local int, dim = getElementInterior(p), getElementDimension(p)
		dbExec(sql, "INSERT INTO atms SET x=?, y=?, z=?, dimension=?, interior=?, rotation=?", x, y, z-0.4, dim, int, r-180)

		dbQuery(function(qh)
			local result, rows = dbPoll(qh, -1)
			if rows > 0 then
				loadOneATM(result[1])
				outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen létrehoztál egy ATMet! #7cc576(" .. result[1].id .. ")", p, 25, 152, 139, true)
			else
				outputChatBox("#7cc576[SeeMTA]: #ffffffValami hiba történt!", p, 25, 152, 139, true)
			end
		end, sql, "SELECT * FROM atms WHERE id=LAST_INSERT_ID()")
	end
end)

addCommandHandler("delatm", function(p, cmd, id)
	if getElementData(p, "adminlevel") >= 8 then
		if tonumber(id) then
			local id = tonumber(id)
			if atm[id] then
				dbExec(sql, "DELETE FROM atms WHERE id=?", id)
				destroyElement(atm[id])
				outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen törölted az ATM-et!", p, 25, 152, 139, true)
			else
				outputChatBox("#7cc576[SeeMTA]: #ffffffNincs ilyen IDjű ATM!", p, 25, 152, 139, true)
			end
		end
	end
end)

addEventHandler("onElementDataChange", getRootElement(), function(theKey, oldValue, newValue)
	if getElementType(source) ~= "player" then return end

	if theKey == "money" or theKey == "bankmoney" then
		local oldValue = oldValue or 0
		
		if client then
			triggerClientEvent("sendMessageToAdmins", getRootElement(), "#7cc576[SeeMTA - #32b3efFigyelmeztetés#7cc576]: #ffffffKlienstől jövő pénz állítás: "..getPlayerName(source).." #7cc576["..theKey.."]")
			setElementData(source, theKey, oldValue)
			return
		end

		if newValue >= 10000000 or newValue <= -1000000 then
			triggerClientEvent("sendMessageToAdmins", getRootElement(), "#7cc576[SeeMTA - #32b3efFigyelmeztetés#7cc576]: #ffffffGyanús "..(theKey == "money" and "készpénz" or "bankszámla").." összeg: "..getPlayerName(source).." #7cc576["..newValue.."$]")
		end

		if math.abs(oldValue - newValue) >= 10000000 then
			triggerClientEvent("sendMessageToAdmins", getRootElement(), "#7cc576[SeeMTA - #32b3efFigyelmeztetés#7cc576]: #ffffffGyanús "..(theKey == "money" and "kész" or "bankszámla").."pénz változás: "..getPlayerName(source).." #7cc576["..oldValue.."$ - "..newValue.."$]")
		end
	end
end)