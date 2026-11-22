local flexs = {}
local cans = {}


addEvent("giveFlex",true)
addEventHandler("giveFlex",getRootElement(),function()
	takeAllWeapons(client)
	if not isElement(flexs[client]) then
		flexs[client] = createObject(17613,0,0,0)
		setObjectScale(flexs[client],0.7)
		setElementCollisionsEnabled(flexs[client], false)
		exports.bone_attach:attachElementToBone(flexs[client],client,11,0.2,0,0.11,180,90,-120)
		setElementData(client,"flex",flexs[client])
		setElementInterior(flexs[client],getElementInterior(client))
		setElementDimension(flexs[client],getElementDimension(client))
	end
end)

addEvent("takeFlex",true)
addEventHandler("takeFlex",getRootElement(),function()
	takeAllWeapons(client)
	if isElement(flexs[client]) then
		exports.bone_attach:detachElementFromBone(flexs[client])
		destroyElement(flexs[client])
		flexs[client] = false
	end
end)

addEvent("giveCan",true)
addEventHandler("giveCan",getRootElement(),function()
	takeAllWeapons(client)
	if not isElement(cans[client]) then
		cans[client] = createObject(1329,0,0,0)
		setObjectScale(cans[client],1)
		setElementCollisionsEnabled(cans[client], false)
		exports.bone_attach:attachElementToBone(cans[client],client,12,0,0.07,0,180,90,0)
		setElementData(client,"can",cans[client])
		setElementInterior(cans[client],getElementInterior(client))
		setElementDimension(cans[client],getElementDimension(client))
	end
end)

addEvent("takeCan",true)
addEventHandler("takeCan",getRootElement(),function()
	takeAllWeapons(client)
	if isElement(cans[client]) then
		exports.bone_attach:detachElementFromBone(cans[client])
		destroyElement(cans[client])
		cans[client] = false
	end
end)

function itemAnims(typ)
	if typ == 1 then
		setPedAnimation(client, "FOOD", "eat_pizza", 4000,false,false,false,false)
	elseif typ == 2 then
		setPedAnimation(client, "VENDING", "vend_drink2_p", 4000,false,false,false,false)
	elseif typ == 3 then
		setPedAnimation(client, "SMOKING", "M_smkstnd_loop", 4000,false,false,false,false)
	end
end
addEvent("itemAnims", true)
addEventHandler("itemAnims",root,itemAnims)

addEvent("givePlayerArm",true)
addEventHandler("givePlayerArm",getRootElement(),function(num)
	if getPedArmor(client)+num > 100 then
		setPedArmor(client,100)
	else
		setPedArmor(client,getPedArmor(client)+num)
	end
end)

addEventHandler("onPlayerQuit",getRootElement(),function()
	if (flexs[source]) then
		exports.bone_attach:detachElementFromBone(flexs[source])
		destroyElement(flexs[source])
		flexs[source] = nil
	end
end)

function itemUse(data, realslot)
	local item_id = tonumber(data["id"] or -1)
	local item_count = tonumber(data["count"] or -1)
	local item_value = tonumber(data["value"] or -1)
	local item_slot = tonumber(data["slot"] or -1)
	local item_dbid = tonumber(data["dbid"] or -1)

	local item_isWeapon = items[tonumber(data["id"] or -1)].isWeapon
	local item_isWeapon_Ammo = items[tonumber(data["id"] or -1)].ammo
	-- FegyverHasználat
	if item_isWeapon and not item_isWeapon_Ammo and weaponIndexByID[item_id] then
		if not getElementData(client, "Char->usingWeapon")[1] then
			giveWeapon(client, weaponIndexByID[item_id], tar_value, true)
			setElementData(client, "Char->usingWeapon", {true, weapon_slot = realslot, ammo_slot = -1, ammo_value = 1, itemID = item_id})
			setElementData(client,"char:fegyo",item_id)
			if item_id == 279 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"knife", "knife1", "knife")
			elseif item_id == 280 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"knife", "knife2", "knife")
			elseif item_id == 281 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"knife", "knife3", "knife")
			end
			delAttachWeapon(client,item_id,item_value,item_dbid)
			return
		end
		if getElementData(client, "Char->usingWeapon")[1] and getElementData(client,"char:fegyo") == item_id then
			takeWeaponFromPlayer(client)
			exports["sas_weapontuning"]:removeWeaponStickers(client)
			addAttachWeapon(client,item_id,item_value,item_dbid)
			return
		end
	end
	if item_isWeapon and tonumber(item_isWeapon_Ammo) and item_isWeapon_Ammo > 1 and weaponIndexByID[item_id] then
		takeAllWeapons(client)
		local tar_have = hasPlayerAmmo(client, item_isWeapon_Ammo)[1]
		local tar_slot = hasPlayerAmmo(client, item_isWeapon_Ammo)[2]
		local tar_value = hasPlayerAmmo(client, item_isWeapon_Ammo)[3]

		if not tar_have or (tar_have and tar_value <= 0) then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFA fegyverhez nincs töltényed, ezért nem tudod elővenni.",client,255,255,255,true)
			return
		end
		if tar_have and tar_value > 0 and not getElementData(client, "Char->usingWeapon")[1] then
			delAttachWeapon(client,item_id,item_value,item_dbid)
			giveWeapon(client, weaponIndexByID[item_id], tar_value, true)
			setElementData(client, "Char->usingWeapon", {true, weapon_slot = realslot, ammo_slot = tar_slot, ammo_value = tar_value})
			exports.sas_chat:sendLocalMeAction(client, "elővesz egy fegyvert. (("..getWeaponNameFromID(weaponIndexByID[item_id]) .."))")
			setElementData(client,"char:fegyo",item_id)
			if item_id == 264 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"ak", "camo3")
			elseif item_id == 265 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"ak", "camo2", "ak")
			elseif item_id == 266 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"ak", "camo", "ak")
			elseif item_id == 267 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"ak", "gold", "ak")
			elseif item_id == 268 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"ak", "gold2", "ak")
			elseif item_id == 269 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"ak", "silver", "ak")
			elseif item_id == 270 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"ak", "kitty", "ak")
			end

			if item_id == 271 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"deagle", "camo", "deagle")
			elseif item_id == 272 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"deagle", "gold", "deagle")
			end
			if item_id == 273 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"tekstura", "camo", "sniper")
			elseif item_id == 274 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"tekstura", "camo2", "sniper")
			end

			if item_id == 275 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"mp5", "mp51", "mp5")
			elseif item_id == 276 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"mp5", "mp52", "mp5")
			elseif item_id == 277 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"mp5", "mp53", "mp5")
			elseif item_id == 278 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"mp5", "mp54", "mp5")
			end


			if item_id == 282 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"9mm_c", "tec1", "tec")
			elseif item_id == 283 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"9mm_c", "tec2", "tec")
			elseif item_id == 284 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"9mm_c", "tec3", "tec")
			elseif item_id == 285 then
				exports["sas_weapontuning"]:setStickerOnWeapon(client,"9mm_c", "tec4", "tec")
			end
			return
		end
		if getElementData(client, "Char->usingWeapon")[1] and getElementData(client,"char:fegyo") == item_id then
			takeWeaponFromPlayer(client)
			exports.sas_chat:sendLocalMeAction(client, "eltesz egy fegyvert. (("..getWeaponNameFromID(weaponIndexByID[item_id]) .."))")
			exports["sas_weapontuning"]:removeWeaponStickers(client)
			setElementData(client,"char:fegyo",false)
			addAttachWeapon(client,item_id,item_value,item_dbid)
			return
		end
	end
	-- Itemek
	if item_id > -1 and item_count > -1 and item_value > -1 and item_slot > -1 then
		if item_id == 206 then
			triggerClientEvent(client, "Inventory->openSzemelyi", client, item_value)
		elseif item_id == 207 then
			triggerClientEvent(client, "Inventory->openJogsi", client, item_value)
		elseif item_id == 309 then
			triggerClientEvent(client, "Inventory->openHorgasz", client, item_value)
		elseif item_id == 263 then
			triggerClientEvent(client, "Inventory->openUtlevel", client, item_value)
		elseif item_id == 8 then
			triggerClientEvent(client, "Inventory->openPhone", client, item_value)

		elseif item_id == 298 then
			local printsTable = getElementData(client, "blueprints") or {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
			if item_value == 1 then
				if not printsTable[1] then
					setElementData(client, "blueprints", {true, printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 2 then
				if not printsTable[2] then
					setElementData(client, "blueprints", {printsTable[1], true, printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 3 then
				if not printsTable[3] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], true, printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 4 then
				if not printsTable[4] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], true, printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 5 then
				if not printsTable[5] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], true,printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 6 then
				if not printsTable[6] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],true, printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 7 then
				if not printsTable[7] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], true, printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 8 then
				if not printsTable[8] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], true, printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 9 then
				if not printsTable[9] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], true, printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 10 then
				if not printsTable[10] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], true, printsTable[11], printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 11 then
				if not printsTable[11] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], true, printsTable[12], printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 12 then
				if not printsTable[12] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], true, printsTable[13], printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 13 then
				if not printsTable[13] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], true, printsTable[14], printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 14 then
				if not printsTable[14] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], true, printsTable[15]})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			elseif item_value == 15 then
				if not printsTable[15] then
					setElementData(client, "blueprints", {printsTable[1], printsTable[2], printsTable[3], printsTable[4], printsTable[5],printsTable[6], printsTable[7], printsTable[8], printsTable[9], printsTable[10], printsTable[11], printsTable[12], printsTable[13], printsTable[14], true})
					deleteItem(client, data, client)
					
					saveBluePrints()
					exports.sas_hud:addNotification(client, "Sikeresen elsajátítottad ezt a receptet.", "success")
				else
					exports.sas_hud:addNotification(client, "Te már rendelkezel ezzel a blueprinttel.", "error")
				end
			end
		end
	end
end
addEvent("useItem", true)
addEventHandler("useItem", root, itemUse)

function fuelVehicleWithCard(player, veh)
	setElementData(veh, "fuel", 100)
end
addEvent("fuelVehicleWithCard", true)
addEventHandler("fuelVehicleWithCard", root, fuelVehicleWithCard)

function fixVehicleWithCard(player, veh)
	fixVehicle(veh)
end
addEvent("fixVehicleWithCard", true)
addEventHandler("fixVehicleWithCard", root, fixVehicleWithCard)

function saveBluePrints()
	local blueprints = toJSON( {getElementData(source, "blueprints")[1], getElementData(source, "blueprints")[2], getElementData(source, "blueprints")[3], getElementData(source, "blueprints")[4], getElementData(source, "blueprints")[4], getElementData(source, "blueprints")[5], getElementData(source, "blueprints")[6], getElementData(source, "blueprints")[7], getElementData(source, "blueprints")[8], getElementData(source, "blueprints")[9], getElementData(source, "blueprints")[10], getElementData(source, "blueprints")[11], getElementData(source, "blueprints")[12], getElementData(source, "blueprints")[13], getElementData(source, "blueprints")[14], getElementData(source, "blueprints")[15]} )
	local update = dbPoll ( dbQuery( mysqlConnection, "UPDATE characters SET `blueprints`=?  WHERE id='?'", blueprints, getElementData(source, "dbid")), -1 )
	if (update) then
		--outputDebugString( "Blueprintek mentve "..getElementData(source, "dbid"))
	end
end

function sendMeChat(chatMsg)
	exports.sas_chat:sendLocalMeAction(client,chatMsg)
end
addEvent("sendMeChat", true)
addEventHandler("sendMeChat", getRootElement(), sendMeChat)

function eatItem(amount)
	if getElementData(client, "hunger") +amount <= 100 then
		setElementData(client, "hunger", getElementData(client, "hunger")+amount)
	end
	if getElementData(client, "hunger") + amount > 100 then
		setElementData(client, "hunger", 100)
	end
	setPedAnimation(client, "food", "eat_pizza", -1, false)
	setTimer(function()
		setPedAnimation(client)
	end, 4000, 1)
end
addEvent("eatItemServer", true)
addEventHandler("eatItemServer", getRootElement(), eatItem)

function setHunger(player,cmd, newamount)
	if exports.sas_global:isPlayerAdmin(player) then
		if not tonumber(newamount) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/sethunger [Érték]", player, 255,255,255,true)
		else
			setElementData(player, "hunger", tonumber(newamount))
		end
	end
end
addCommandHandler("sethunger", setHunger)

function setDrink(player,cmd, newamount)
	if exports.sas_global:isPlayerAdmin(player) then
		if not tonumber(newamount) then
			outputChatBox("#7cc576[SeeMTA]: #FFFFFF/setdrink [Érték]", player, 255,255,255,true)
		else
			setElementData(player, "thirst", tonumber(newamount))
		end
	end
end
addCommandHandler("setdrink", setDrink)