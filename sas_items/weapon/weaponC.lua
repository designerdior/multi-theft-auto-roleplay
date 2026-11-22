setElementData(localPlayer, "Char->usingWeapon", {false, -1, -1, -1, -1, -1})

local spamTimer

-- Lövés Fegyverrel
addEventHandler("onClientPlayerWeaponFire",getRootElement(),
     function(weapon, ammo, ammoInClip)
		if source == localPlayer then
			local usingWeapon = getElementData(localPlayer, "Char->usingWeapon")
			if usingWeapon and usingWeapon.ammo_slot > 0 then
				local oldAmmo = usingWeapon.ammo_value
				if oldAmmo > 0 then
					local newAmmo = oldAmmo - 1
					inventoryItems["bag"][usingWeapon.ammo_slot]["count"] = newAmmo
					usingWeapon.ammo_value = newAmmo
					if isTimer(spamTimer) then killTimer(spamTimer) end
					spamTimer = setTimer(function()
						triggerServerEvent("updateItemCount", localPlayer, localPlayer, usingWeapon.ammo_slot, newAmmo, inventoryItems["bag"][usingWeapon.ammo_slot]["dbid"], 3)
					end, 1000, 1)
					setElementData(localPlayer, "Char->usingWeapon", usingWeapon)
					if newAmmo == 0 then
						triggerServerEvent("deleteItem", localPlayer, localPlayer, inventoryItems["bag"][usingWeapon.ammo_slot])
						deleteItemFromActionSlot(inventoryItems["bag"][usingWeapon.ammo_slot]["slot"])
						--outputChatBox(inventoryItems["bag"][usingWeapon.ammo_slot])
						triggerServerEvent("addAttachWeapon",localPlayer,localPlayer,inventoryItems["bag"][usingWeapon.weapon_slot]["id"],inventoryItems["bag"][usingWeapon.weapon_slot]["value"],inventoryItems["bag"][usingWeapon.weapon_slot]["dbid"])
						inventoryItems["bag"][usingWeapon.ammo_slot] = nil
						setElementData(localPlayer, "Char->usingWeapon", {false, -1, -1, -1, -1, -1})
						triggerServerEvent("takeWeaponFromPlayer", localPlayer, localPlayer)
					end
				end
			end
		end
     end
)

addEventHandler("onClientKey", getRootElement(), function(button,state)
	if button == "mouse1" and state and getElementData(localPlayer, "Char->blockFire") then
		cancelEvent()
		return
	end
end)

addEventHandler ( "onClientPlayerSpawn", getLocalPlayer(), function()
	setElementData(localPlayer, "Char->blockFire", false)
	toggleControl("next_weapon",false)
	toggleControl("previous_weapon",false)
end)

setElementData(localPlayer, "Char->blockFire", false)
