local foodItems = {
	[1] = 50,
	[2] = 20,
	[3] = 25,
	[4] = 40,
	[5] = 30,
	[6] = 20,
}

local drinkItems = {
	[7] = 50,
	[9] = 30,
}

local alcoholDrink = {
	[10] = 10,
	[11] = 30,
	[12] = 10,
	[13] = 30,
}

local dropItems = {
	{10, 10},
	{11, 10},
	{12, 10},
	{13, 10},
}

local itemInProgressBar = false
local atvIData = {}
local progress = 60
local timer = false
local typeOfProgress = ""
local drugType = 0



function openPhone(item_value)
	exports["sas_phone"]:showPhoneFunction(item_value)
end
addEvent("Inventory->openPhone", true)
addEventHandler("Inventory->openPhone", root, openPhone)

function openSzemelyi(item_value)
	exports["sas_identity"]:ShowIdentityCard(item_value)
end
addEvent("Inventory->openSzemelyi",true)
addEventHandler("Inventory->openSzemelyi", root, openSzemelyi)

function openJogsi(item_value)
	exports["sas_identity"]:ShowJogsi(item_value)
end
addEvent("Inventory->openJogsi",true)
addEventHandler("Inventory->openJogsi", root, openJogsi)

function openHorgasz(item_value)
	exports["sas_identity"]:ShowHorgasz(item_value)
end
addEvent("Inventory->openHorgasz",true)
addEventHandler("Inventory->openHorgasz", root, openHorgasz)

function openUtlevel(item_value)
	exports["sas_identity"]:ShowUtlevelCard(item_value)
end
addEvent("Inventory->openUtlevel",true)
addEventHandler("Inventory->openUtlevel", root, openUtlevel)

setElementData(localPlayer, "item:weaponSlot",{false, -1})

function itemUsingProgressBar()
	if not getElementData(localPlayer, "enableall") then return end
	if itemInProgressBar then
		--if atvIData["id"] >= 4 and atvIData["id"] <= 7 then
			actionX, actionY = exports["sas_hud"]:getNode(9, "x"), exports["sas_hud"]:getNode(9, "y")
			exports.sas_system:radarKeret(actionX+124-itemSize/2, actionY-25-itemSize, itemSize, itemSize,2,255)
			if isInSlot(actionX+124-itemSize/2, actionY-25-itemSize, itemSize, itemSize) then
				dxDrawRectangle(actionX+124-itemSize/2, actionY-25-itemSize, itemSize, itemSize, tocolor(255,140,0,200))
			else
				dxDrawRectangle(actionX+124-itemSize/2, actionY-25-itemSize, itemSize, itemSize, tocolor(47, 47, 46,200))
			end
			dxDrawImage(actionX+124-itemSize/2, actionY-25-itemSize, itemSize, itemSize, "files/items/" .. atvIData["id"] .. ".png")
			dxDrawImage(actionX+124-46/2-10-itemSize, actionY-25-itemSize-5, 46, 46, "files/leftMouse.png")
			dxDrawImage(actionX+124-itemSize/2+itemSize+5, actionY-25-itemSize-5, 46, 46, "files/rightMouse.png")
			exports.sas_system:radarKeret(actionX+124-31, actionY-16-2, 60, 8,2,255)
			dxDrawRectangle(actionX+124-31, actionY-16-2, 60, 8, tocolor(0, 0, 0,255))
			dxDrawRectangle(actionX+124-31, actionY-16-2, 60, 8, tocolor(153, 204, 153,100))
			dxDrawRectangle(actionX+124-31, actionY-16-2, progress, 8, tocolor(153, 204, 153,255))
		--	dxDrawRectangle(int startX, startY, float width, float height [, int color = white, bool postGUI = false ])
	--	end
	end
end
addEventHandler("onClientRender", root, itemUsingProgressBar)

function progressBarClick(button, state)
	if button == "right" and state == "down" then
			if itemInProgressBar and not timer then
				if isInSlot(actionX+124-itemSize/2, actionY-25-itemSize, itemSize, itemSize) then
					if typeOfProgress == "food" then
						if getElementData(localPlayer, "hunger") < 100  then
							if progress ~= 0 then
								progress = progress - 15
								triggerServerEvent("eatItemServer", localPlayer, 20)
								timer = true
								setTimer(function()
									timer = false
								end, 4000, 1)
							end
							if progress == 0 then
								itemInProgressBar = false
								atvIData = {}
								progress = 60
							end
						else
							exports.sas_hud:addNotification("Már nem vagy éhes!", "error")
						end
					elseif typeOfProgress == "drug" then
						if not getElementData(localPlayer,"drugUsing") then
							if progress ~= 0 then
								progress = progress - 15
								if drugType == 1 then
									setMarijuanaScreen(true)
								elseif drugType == 2 then
									setLsdScreen(true)
								elseif drugType == 3 then
									setSpeedScreen(true)
								elseif drugType == 4 then
									setMushroomScreen(true)
								end
								triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "szívott egy slukkot.")
								setElementData(localPlayer,"drugUsing",true)
								local randomHealth = math.random(3,7)
								if getElementHealth(localPlayer)+randomHealth > 100 then
									setElementHealth(localPlayer,100)
								else
									setElementHealth(localPlayer,getElementHealth(localPlayer)+randomHealth)
								end
								givePlayerArmor(math.random(4,9))
								triggerServerEvent("itemAnims",localPlayer,localPlayer,3)
								timer = true
								setTimer(function()
									timer = false
								end, 4000, 1)
							end
							if progress == 0 then
								itemInProgressBar = false
								atvIData = {}
								progress = 60
							end
						end
					end
				end
			end
	elseif button == "left" and state == "down" then
		actionX, actionY = exports["sas_hud"]:getNode(9, "x"), exports["sas_hud"]:getNode(9, "y")
		if isInSlot(actionX+124-itemSize/2, actionY-25-itemSize, itemSize, itemSize) then
			itemInProgressBar = false
			atvIData = {}
			progress = 60
		end
	end
end
addEventHandler("onClientClick", root, progressBarClick)

function givePlayerArmor(num)
	triggerServerEvent("givePlayerArm",localPlayer,localPlayer,num)
end

setPlayerHudComponentVisible("crosshair", true)

function useItem(itemData, slot)
	if (itemData) then
		if (itemData["id"] >= 5 and itemData["id"] <= 7) or (itemData["id"] >= 166 and itemData["id"] <= 185) then
			if getElementData(localPlayer, "hunger") < 100 then
				 itemInProgressBar = true
				 atvIData = itemData
				 typeOfProgress = "food"
				 if (itemData["count"] - 1 > 0) then
					 setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
				 else
					 triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
				 end
			else
				exports.sas_hud:addNotification("Nem vagy éhes!", "error")
			end
		elseif itemData["id"] == 262 then
			if not getElementData(localPlayer,"drugUsing") then
				setHeroinScreen(true)
			else
				exports.sas_hud:addNotification("Már drog hatása alatt vagy!", "error")
			end
		elseif itemData["id"] == 64 then
			if not getElementData(localPlayer,"drugUsing") then
				itemInProgressBar = true
				atvIData = itemData
				typeOfProgress = "drug"
				drugType = 1
				if (itemData["count"] - 1 > 0) then
					setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
				else
					triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
				end
			else
				exports.sas_hud:addNotification("Már drog hatása alatt vagy!", "error")
			end
		elseif itemData["id"] == 16 then
			if not getElementData(localPlayer,"drugUsing") then
				itemInProgressBar = true
				atvIData = itemData
				typeOfProgress = "drug"
				drugType = 2
				if (itemData["count"] - 1 > 0) then
					setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
				else
					triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
				end
			else
				exports.sas_hud:addNotification("Már drog hatása alatt vagy!", "error")
			end
		elseif itemData["id"] == 147 then
			if gyogyitItem(itemData["id"], 30) then
				if (itemData["count"] - 1 > 0) then
						setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
				else
						triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
				end
			end
		elseif itemData["id"] == 148 then
			if gyogyitItem(itemData["id"], 15) then
				if (itemData["count"] - 1 > 0) then
						setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
				else
						triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
				end
			end

		elseif itemData["id"] == 187 then
			local veh = getPedOccupiedVehicle(localPlayer)
			if (veh) then
				 	triggerServerEvent("fixVehicleWithCard", localPlayer, veh)
				 	if (itemData["count"] - 1 > 0) then
 						setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
 					else
 						triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
 					end
			else
				exports.sas_hud:addNotification("Ezt az itemet csak a kocsiban használhatod.", "error")
			end
		elseif itemData["id"] == 188 then
			local veh = getPedOccupiedVehicle(localPlayer)
			if (veh) then
					triggerServerEvent("fuelVehicleWithCard", localPlayer, veh)
					if (itemData["count"] - 1 > 0) then
						setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
					else
						triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
					end
			else
				exports.sas_hud:addNotification("Ezt az itemet csak a kocsiban használhatod.", "error")
			end
		elseif(itemData["id"]==500) then
				local playerInterior = getElementInterior(localPlayer)
				local playerDimension = getElementDimension(localPlayer)
				if playerInterior > 0 and playerDimension > 0 then
					for k,v in ipairs(getElementsByType("marker")) do
						if getElementData(v,"isIntOutMarker") then
							if getElementDimension(v) == playerDimension and getElementInterior(v) == playerInterior then
								if not isTimer(plantTimer) then
									plantTimer = setTimer(function() end,3000,1)
									--outputMeMessage("lerakott egy cserepes növényt a földre.")
									exports["sas_plants"]:createPlant("marihuana")
									if (itemData["count"] - 1 > 0) then
										setItemCount(itemSlot, itemData["count"] - 1, itemData["dbid"], 3)
									else
										triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
									end
									return
								else
									outputChatBox("[SeeMTA]:#ffffff Várj egy kicsit, elöbb raktál le egy növényt.",61,122,188,true)
									return
								end
							end
						end
					end
				else
					exports["sas_hud"]:addNotification("Nem vagy interior-ban.","error")
					return
				end
			elseif(itemData["id"]==61) then
				local playerInterior = getElementInterior(localPlayer)
				local playerDimension = getElementDimension(localPlayer)
				if playerInterior > 0 and playerDimension > 0 then
					for k,v in ipairs(getElementsByType("marker")) do
						if getElementData(v,"isIntOutMarker") then
							if getElementDimension(v) == playerDimension and getElementInterior(v) == playerInterior then
							--	if not isTimer(plantTimer) then
									plantTimer = setTimer(function() end,3000,1)
									--outputMeMessage("lerakott egy cserepes növényt a földre.")
									exports["sas_plants"]:createPlant("cocaine")
									if (itemData["count"] - 1 > 0) then
										setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
									else
										triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
									end
									return
							--	else
								--	outputChatBox("[SeeMTA]:#ffffff Várj egy kicsit, elöbb raktál le egy növényt.",61,122,188,true)
								--	return
							--	end
							end
						end
					end
				else
					exports["sas_hud"]:addNotification("Nem vagy interior-ban.","error")
					return
				end
		elseif (itemData["id"]) == 37 then
			if isElement(localPlayer) then
			if not getElementData(localPlayer, "jelveny:state") then
				setElementData(localPlayer, "jelveny:state", true)
				if exports.sas_dashboard:isInGroup(2) then
					local rootTable = getElementData(root, "FactionData")
					local orgRankName = rootTable[exports.sas_dashboard:isInGroup(2)]["rank_" .. exports.sas_dashboard:getPlayerGroupRank(2)]

				setElementData(localPlayer, "jelveny:text", "Rendőrség | " .. orgRankName.. " | #"..itemData["value"])
				exports.sas_chat:sendLocalMeMessage(localPlayer, "felhelyezi a jelvényét.")
				setElementData(localPlayer, "char:badge"..itemSlot, true)
				elseif getElementData(localPlayer,"group_3") then
					local rootTable = getElementData(root, "FactionData")
					local orgRankName = rootTable[getElementData(localPlayer, "group_3")]["rank_" .. getElementData(localPlayer, "group_3_rank")]

					setElementData(localPlayer, "jelveny:text", "Mentőszolgálat | "..orgRankName.." | #"..itemData["value"])
					exports.sas_chat:sendLocalMeMessage(localPlayer, "felhelyezi a jelvényét.")
					setElementData(localPlayer, "char:badge"..itemSlot, true)
				elseif getElementData(localPlayer,"group_16") then
					local rootTable = getElementData(root, "FactionData")
					local orgRankName = rootTable[getElementData(localPlayer, "group_16")]["rank_" .. getElementData(localPlayer, "group_16_rank")]

					setElementData(localPlayer, "jelveny:text", "NAV | "..orgRankName.." | #"..itemData["value"])
					exports.sas_chat:sendLocalMeMessage(localPlayer, "felhelyezi a jelvényét.")
					setElementData(localPlayer, "char:badge"..itemSlot, true)

				else
					setElementData(localPlayer, "jelveny:text", itemData["value"])
					exports.sas_chat:sendLocalMeMessage(localPlayer, "felhelyezi a jelvényét.")
					setElementData(localPlayer, "char:badge"..itemSlot, true)
				end
			else
				if getElementData(localPlayer, "jelveny:state") then
					setElementData(localPlayer, "jelveny:state", false)
					setElementData(localPlayer, "jelveny:text", false)
					exports.sas_chat:sendLocalMeMessage(localPlayer, "leveszi a jelvényét.")
					setElementData(localPlayer, "char:badge"..itemSlot, false)
				end
			end
		end
		elseif (itemData["id"]) == 214 then
			exports.sas_fishing:createStick(itemData["slot"])
			exports.sas_fishing:setPecaState(true, itemData["slot"])
			if not getElementData(localPlayer, "char:pecabotInHand") then
				setElementData(localPlayer, "char:pecabotInHand", true)
			else
				setElementData(localPlayer, "char:pecabotInHand", false)
			end
		elseif (itemData["id"]) == 192 then

			if (itemData["count"] - 1 > 0) then
				setItemCount(slot, itemData["count"] - 1, itemData["dbid"], 3)
			else
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
			end
			local randomDropNumber = math.random(1,4)
			local givenItem = dropItems[randomDropNumber][1]
			giveItem(givenItem, 1, 1, 0)
			triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "kinyitott egy húsvéti tojást.")
			outputChatBox("#7cc576[SeeMTA]: #FFFFFFA húsvéti tojás egy "..getItemName(givenItem).."-t rejtett.", 255,255,255, true)
		elseif itemData["id"] == 244 then
			if activeWeaponSlot == itemSlot then
				activeWeaponSlot = -1
				setElementData(localPlayer,"handFlex",false)
				triggerServerEvent("takeFlex",localPlayer,localPlayer)
				exports.sas_chat:sendLocalMeMessage(localPlayer,"elrakott egy flexet.")
			elseif activeWeaponSlot == -1 then
				activeWeaponSlot = itemSlot
				setElementData(localPlayer,"handFlex",true)
				triggerServerEvent("giveFlex",localPlayer,localPlayer)
				exports.sas_chat:sendLocalMeMessage(localPlayer,"elővett egy flexet.")
			end
		elseif itemData["id"] == 124 then
			--if activeWeaponSlot == -1 then
				--activeWeaponSlot = itemSlot
				setElementData(localPlayer,"handCan",true)
				triggerServerEvent("giveCan",localPlayer)
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
				--exports.sas_chat:sendLocalMeMessage(localPlayer,"elővett egy benzines kannát.")
		--	end
		elseif itemData["id"] == 149 then
		    triggerServerEvent("createHifi",localPlayer)
			exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
		    triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 233 then
				triggerServerEvent("addSkillToClient",localPlayer,69,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 234 then
				triggerServerEvent("addSkillToClient",localPlayer,70,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 235 then
				triggerServerEvent("addSkillToClient",localPlayer,71,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 236 then
				triggerServerEvent("addSkillToClient",localPlayer,75,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 237 then
				triggerServerEvent("addSkillToClient",localPlayer,76,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 238 then
				triggerServerEvent("addSkillToClient",localPlayer,77,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 239 then
				triggerServerEvent("addSkillToClient",localPlayer,78,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif itemData["id"] == 240 then
				triggerServerEvent("addSkillToClient",localPlayer,72,999)
				exports.sas_hud:addNotification("Sikeresen aktiváltad a fegyvermesterkönyvet!", "success")
				triggerServerEvent("deleteItem", localPlayer, localPlayer, itemData)
		elseif (itemData["id"]) == 46 then

		else
			triggerServerEvent("useItem", localPlayer, itemData, slot)
		end

	end
end



function takeCanClient(dataName)
	if getElementType ( source ) == "player" and dataName == "handCan" then
		if not getElementData(source, "handCan") then
			triggerServerEvent("takeCan", localPlayer)
		end
	end
end
addEventHandler ( "onClientElementDataChange", getRootElement(),takeCanClient)


function drinkItem(itemID)
	if (tonumber(itemID) > -1) then
		local pHunger = getElementData(localPlayer, "char:drink")
		if (pHunger < 100) then
			if ((pHunger + drinkItems[itemID]) > 100) then
				setElementData(localPlayer, "char:drink", 100)
			else
				setElementData(localPlayer, "char:drink", pHunger + drinkItems[itemID])
			end
			triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "iszik egy " .. getItemName(itemID) .."-t")
			return true
		else
			exports.sas_hud:addNotification("Nincs szükséged erre az itemre!","warning")
			return false
		end
	end
end

function gyogyitItem(itemID, plushealth)
	if (tonumber(itemID) > -1) then
		local health = getElementHealth(localPlayer)
		if (health < 100) then
			if ((health + plushealth) > 100) then
				setElementHealth(localPlayer, 100)
			else
				setElementHealth(localPlayer, health+plushealth)
			end
			triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "bevesz egy " .. getItemName(itemID) .."-t")
			return true
		else
			exports.sas_hud:addNotification("Nincs szükséged gyógyszerre!","warning")
			return false
		end
	end
end

function eatItem(itemID)
	if (tonumber(itemID) > -1) then
		local pHunger = getElementData(localPlayer, "char:hunger")
		if (pHunger < 100) then
			if ((pHunger + foodItems[itemID]) > 100) then
				setElementData(localPlayer, "char:hunger", 100)
			else
				setElementData(localPlayer, "char:hunger", pHunger + foodItems[itemID])
			end
			triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "eszik egy " .. getItemName(itemID) .."-t")
			return true
		else
			exports.sas_hud:addNotification("Nincs szükséged erre az itemre!","warning")
			return false
		end
	end
end

function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(dobozbaVan(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end
