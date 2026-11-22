sX, sY = guiGetScreenSize()
pW, pH = 461, 247
moveX, moveY = sX - pW - 200, sY/2 - 123
local kepAlpha = 0
local showInventory = false
local tooltiptiltas = false

iFont = dxCreateFont("files/fonts/Roboto.ttf", 12, false, "cleartype")
iFont2 = dxCreateFont("files/fonts/RobotoL.ttf", 12, false, "cleartype")
iFont3 = dxCreateFont("files/fonts/RobotoBI.ttf", 12, false, "cleartype")

inventoryItems = {}

local actionItems = {}
local egerP = {}
local elementSource = nil
local selectedAmount = 1
local activeSide = nil
local lastClick = 0
local vehBoot = false
local amountBox = nil
local enabled = false

local actionOffsetX, actionOffsetY = 0, 0;

local hoverSlot = -1
local hoverItem = nil

local correctX = 0

local inMove = false
local moveTime = -1
local startTick = -1
local movedItem = nil
local movedSlot = -1

local inClone = false
local clonedItem = nil
local clonedSlot = -1

local weaponHot = 0
local randState = 0

-- Action Bar
local actionSlots = 6
local action_array     = {}
for i=1, actionSlots do action_array[i] = {-1, -1, "bag"} end
local isCursorInAction = false
local current_action_slot = -1

hotTable = {
	--WEAPID,NUM(1-től 100-ig)
	[22] = 1.0+10, --Colt
	[23] = 1.0+11, --Silenced
	[24] = 1.0+18, -- deagle
	[25] = 1.0+27, --Shotgun
	[26] = 1.0+23, --Sawed off
	[28] = 1.0+3, --Uzi
	[29] = 1.0+4, --MP5
	[30] = 1.0+4.5, --AK
	[31] = 1.0+3.2, --M4
	[32] = 1.0+3, --TEC-9
	[33] = 1.0+23, --Rifle
	[34] = 1.0+26, --Sniper
}

showCraft = false

local mozgat = false
local movingOffsetX, movingOffsetY = 0, 0;

bindKey("i", "down",
	function()
		if not getElementData(localPlayer, "loggedin") then return end

		if not showInventory and elementSource ~= localPlayer then
			pendingWeaponAttach = true
			triggerServerEvent("getElementItems", localPlayer, localPlayer, true)
			return
		end

		openInventory(localPlayer)
	end
)

function removeHex (text)
    return type(text)=="string" and string.gsub(text, "#%x%x%x%x%x%x", "") or text
end

function create_tooltip(text)
	local cx, cy = getCursorPosition()
	cx, cy = cx * sX, cy * sY
	if text then
		local textWidth = dxGetTextWidth(removeHex(text), 1)
        dxDrawRectangle(cx, cy, textWidth+40, 50, tocolor(0, 0, 0, 180), true)
        dxDrawText(text, cx, cy,cx + textWidth+40, cy+50 , tocolor(255, 255, 255, 255), 0.7, iFont, "center", "center", false, false, true, true)
	end
end

function saveActionItemsResource()
	saveAction()
end
addEventHandler("onClientResourceStop", resourceRoot, saveActionItemsResource)
addEventHandler("onClientPlayerQuit", resourceRoot, saveActionItemsResource)

function openInventory(pElement)
	if (pElement) then
		if (showInventory) then
			if isElement(amountBox) then
				destroyElement(amountBox)
			end
			if vehBoot then
				triggerServerEvent("getElementItems", localPlayer, localPlayer)
				triggerServerEvent("openCsomagtarto", localPlayer, vehBoot, 0)
			end
			showInventory = false
			showCraft = false
		else
			if activeSide == "all" then
				activeSide = "bag"
			end
			if craftPanel then
				showCraft = true
			end
			showInventory = true
			if not isElement(amountBox) then
				amountBox = guiCreateEdit (moveX+200, moveY-20,50,20,"", false)
				guiSetAlpha(amountBox,1)
			end
		end
		if getElementType(pElement) == "vehicle" then
			closeCraft()
			vehBoot = pElement
			activeSide = "all"
			if getVehicleDoorOpenRatio(vehBoot, 1) == 0 then
				triggerServerEvent("openCsomagtarto", localPlayer, vehBoot, 1)
			end
		else
			vehBoot = false
		end
	end
end

addEventHandler("onClientResourceStart",resourceRoot,function()
	setElementData(localPlayer,"handFlex",false)
	setElementData(localPlayer,"weap:hot",0)
end)

addEventHandler("onClientElementDataChange", getRootElement(), function(dataName, oldValue, newValue)
	if getElementType(source) == "vehicle" then
		if dataName == "Veh->bootOpened" then
			if not newValue then
				local rx, ry, rz = getVehicleComponentRotation(source, "boot_dummy")
				setVehicleComponentRotation(source, "boot_dummy", 360, ry, rz)
			else
				local rx, ry, rz = getVehicleComponentRotation(source, "boot_dummy")
				setVehicleComponentRotation(source, "boot_dummy", 327, ry, rz)
			end
		end
	end
end)

function setElementItems(itemsTable, pElement, open)
	inventoryItems = itemsTable

	if pendingWeaponAttach then
		createClientAttachWeapons()
		pendingWeaponAttach = false
		activeSide = "bag"
		enabled = true
	end

	if elementSource and getElementType(elementSource) == "vehicle" and pElement == localPlayer then
		activeSide = "bag"
	end

	elementSource = pElement

	if open then
		openInventory(pElement)
	end
end
addEvent("setElementItems", true)
addEventHandler("setElementItems", getRootElement(), setElementItems)

function getItemImg(itemID)
	if (tonumber(itemID)) then
		if (fileExists("files/items/" .. itemID .. ".png")) then
			return "files/items/" .. itemID .. ".png"
		end
		return "files/items/0.png"
	end
	return "files/items/0.png"
end

local inItem = false
local actionX, actionY = sX/2 - 269/2+7, sY - 56

for i=1, actionSlots do
	bindKey(i, "down", function()
		if not isChatBoxInputActive () and getElementData(localPlayer, "loggedin") then
			if action_array[i] and action_array[i][1] > -1 and hasItemOnSlot(action_array[i][1]) then
				useItem(inventoryItems[action_array[i][3]][action_array[i][1]], action_array[i][1])
				if not hasItemOnSlot(action_array[i][1]) then
					action_array[i] = {-1,-1, -1, -1, false}
				end
			end
		end
	end)
end

addEvent("setupInventory", true)
addEventHandler("setupInventory", getRootElement(), function()
	pendingWeaponAttach = true
	triggerServerEvent("getElementItems", localPlayer, localPlayer)
	elementSource = localPlayer
	loadActionItems()
end)

local allapotSzin
local hoverSoundOn = false

function radarKeret(x, y, sz, m)
	dxDrawRectangle(x, y, sz, 2, tocolor(0,0,0)) -- Felso
	dxDrawRectangle(x - 0.5, y, 2, m, tocolor(0,0,0)) -- Bal
	dxDrawRectangle(x+sz - 1.5, y, 2, m, tocolor(0,0,0)) -- Jobb
	dxDrawRectangle(x, y+m - 2, sz, 2, tocolor(0,0,0)) -- Also
end

function renderInventory()
	if getElementData(localPlayer, "loggedin") then
		local activeItemID = getElementData(localPlayer,"char:fegyo")
		local activeitemSlot = getElementData(localPlayer, "Char->usingWeapon").weapon_slot or -1
		if activeItemID and activeitemSlot then
			if(activeItemID>-1) and (activeitemSlot>-1) then
				if weaponHot >= 0.1 then
					weaponHot = weaponHot-0.3
					setElementData(localPlayer,"weap:hot",getElementData(localPlayer,"weap:hot")-0.3)
				end

				if weaponHot+randState >= 89 then
					weaponHot = 88
					setElementData(localPlayer,"weap:hot",88)

					takeStatus(getElementData(localPlayer,"char:fegyo"),randState)
					randState = 0
					toggleControl("fire",false)
					playSound("files/overheat.mp3")
					exports["sas_hud"]:addNotification("Fegyvered túlmelegedett.","error")
				end
				if weaponHot <= 18 then
					toggleControl("fire",true)
				end
			end
		end
	end

	hoverSlot = -1
	hoverItem = nil

	if (isCursorShowing() and mozgat) then
		local egerW = {getCursorPosition()}
		local egerP = {egerW[1]*sX, egerW[2]*sY}
		moveX = egerP[1] - movingOffsetX
		moveY = egerP[2] - movingOffsetY
	end
	if showInventory then
		guiSetPosition ( amountBox, moveX+360, moveY-17, false )
	end

	if not getElementData(localPlayer, "enableall") then return end

	if enabled and activeSide ~= "all" then
		actionX, actionY = exports["sas_hud"]:getNode(9, "x"), exports["sas_hud"]:getNode(9, "y")
		if exports["sas_hud"]:getNode(9, "showing") or getElementData(localPlayer, "valaszto") then
			dxDrawRectangle(actionX,actionY,248,46,tocolor(0,0,0,180))
			radarKeret(actionX, actionY, 248, 46, 2, 255)

			current_action_slot = -1

			if isInBox(actionX , actionY, itemSize*actionSlots+20, itemSize+20) then
				isCursorInAction = true
			else
				isCursorInAction = false
			end

			for i=1,actionSlots do
				dxDrawRectangle(actionX + i * (itemSize + margin) - itemSize, actionY + 5, itemSize, itemSize,tocolor(47, 47, 46,200))
				if (not guiGetInputEnabled() and not isMTAWindowActive() and getKeyState(i)) or isInBox(actionX + i * (itemSize + margin) - itemSize + 5, actionY + 7, itemSize, itemSize) then
					dxDrawRectangle(actionX + i * (itemSize + margin) - itemSize, actionY + 5, itemSize, itemSize,tocolor(255,140,0,200))
					current_action_slot = i
				end

				if action_array[i] and action_array[i][1] > -1 and not hasItemOnSlot(action_array[i][1]) then
					action_array[i] = {-1, -1, "bag", -1, false}
				end

				if action_array[i] and action_array[i][1] > -1 and hasItemOnSlot(action_array[i][1]) then
					if (fileExists("files/items/" .. action_array[i][2] .. ".png")) then
						dxDrawImage(actionX + i * (itemSize + margin) - itemSize + 5-5, actionY +4.5, itemSize, itemSize, "files/items/" .. action_array[i][2] .. ".png")
						if action_array[i][5] then
							dxDrawImage(actionX + i * (itemSize + margin) - itemSize + 5-5, actionY +4.5, itemSize, itemSize, "files/items/0.png")
						end
						if tonumber(getElementData(localPlayer, "Char->usingWeapon").ammo_slot or -1) == action_array[i][1] then
							dxDrawImage(actionX + i * (itemSize + margin) - itemSize + 5-5-3, actionY +4.5-3, 42, 42, "files/used.png", 0, 0, 0, tocolor(255, 255, 255, 255))
						end
						if tonumber(getElementData(localPlayer, "Char->usingWeapon").weapon_slot or -1) == action_array[i][1] then
							dxDrawImage(actionX + i * (itemSize + margin) - itemSize + 5-5-3, actionY +4.5-3, 42, 42, "files/used.png", 0, 0, 0, tocolor(255, 255, 255, 255))
						end

						local itemCount = action_array[i][4]
						dxDrawText(itemCount, actionX + i * (itemSize + margin) - itemSize + 5-5, actionY +4.5,actionX + i * (itemSize + margin) + 5-5-1, actionY +4.5+itemSize-1,tocolor(255,255,255,255),0.7,iFont,"right","bottom")
					else
						dxDrawImage(actionX + i * (itemSize + margin) - itemSize + 5-5, actionY +4.5, itemSize, itemSize, "files/items/0.png")
					end
				end
			end
		end
	end

	if not showInventory then return end

	local itemWeight = getAllItemWeight()
	inItem = false
	if (isInBox(moveX, moveY, pW, pH)) then
		inItem = true
	end

	dxDrawRectangle(moveX-45,moveY-20,pW,pH,tocolor(0,0,0,150))
	radarKeret(moveX-45,moveY-20,pW,pH, 2, 255)

	if activeSide == "bag" then
		itemszam = getItemSzamB()
	elseif activeSide == "key" then
		itemszam = getItemSzamK()
	elseif activeSide == "licens" then
		itemszam = getItemSzamW()
	elseif activeSide == "all" then
		itemszam = getItemKocsa()
	end

	if activeSide == "bag" or activeSide == "licens" or activeSide == "key" then

		if selectedAmount <= 0 then
			selectedAmount = 1
			guiSetText(amountBox,1)
		end
		if isInBox(moveX+330,moveY+225,50,20) then
			if getKeyState("mouse1") and lastClick+200 <= getTickCount() then
				lastClick = getTickCount()
				if isElement(amountBox) then
					if guiEditSetCaretIndex(amountBox, string.len(guiGetText(amountBox))) then
						guiBringToFront(amountBox)
						guiEditSetMaxLength(amountBox, 4)
					end
				end
			end
		end
	end
	if not craftPanel then
		dxDrawText("#FFFFFFJelenleg "..itemszam.."/"..row*column.."db itemed van",moveX+37+correctX, moveY-13, pW + moveX-38, 23,tocolor(255,255,255,255),0.8,iFont,"left","top",false,false,true,true)
	end

	if not vehBoot then
		if activeSide == "bag" and not craftPanel then
			correctX = 0
			dxDrawText("#7cc576Tárgyak: #FFFFFF",moveX-38, moveY-17, 0, 0,tocolor(255,255,255,255),1,iFont,"left","top",false,false,true,true)
		elseif activeSide == "key" and not craftPanel then
			correctX = -5
			dxDrawText("#7cc576Kulcsok: #FFFFFF",moveX-38, moveY-17, pW + moveX-38, 23,tocolor(255,255,255,255),1,iFont,"left","top",false,false,true,true)
		elseif activeSide == "licens" and not craftPanel then
			correctX = -20
			dxDrawText("#7cc576Iratok: #FFFFFF",moveX-38, moveY-17, pW + moveX-38, 23,tocolor(255,255,255,255),1,iFont,"left","top",false,false,true,true)
		elseif craftPanel then
			correctX = 0
			dxDrawText("#7cc576Barkácsolás: #FFFFFF",moveX-38, moveY-17, pW + moveX-38, 23,tocolor(255,255,255,255),1,iFont,"left","top",false,false,true,true)
		end

		if isInBox(moveX-38, moveY+13, 40, 48) and activeSide ~= "bag" then
			dxDrawImage(moveX-38, moveY+13, 40, 48, "files/bag.png", 0, 0, 0, tocolor(255, 255, 255, 100))
		end
		if activeSide == "bag" and not showCraft then
			dxDrawImage(moveX-38, moveY+13, 40, 48, "files/bag.png", 0, 0, 0, tocolor(255, 255, 255, 190))
		else
			dxDrawImage(moveX-38, moveY+13, 40, 48, "files/bag.png", 0, 0, 0, tocolor(255, 255, 255, 50))
		end

		if isInBox(moveX-38, moveY+68, 40, 48) and activeSide ~= "key" then
			dxDrawImage(moveX-38, moveY+68, 40, 48, "files/key.png", 0, 0, 0, tocolor(255, 255, 255, 100))
		end
		if activeSide == "key" and not showCraft then
			dxDrawImage(moveX-38, moveY+68, 40, 48, "files/key.png", 0, 0, 0, tocolor(255, 255, 255, 190))
		else
			dxDrawImage(moveX-38, moveY+68, 40, 48, "files/key.png", 0, 0, 0, tocolor(255, 255, 255, 50))
		end

		if isInBox(moveX-38, moveY+123, 40, 48) then
			dxDrawImage(moveX-38, moveY+123, 40, 48, "files/wallet.png", 0, 0, 0, tocolor(255, 255, 255, 100))
		end
		if activeSide == "licens" and not showCraft then
			dxDrawImage(moveX-38, moveY+123, 40, 48, "files/wallet.png", 0, 0, 0, tocolor(255, 255, 255, 190))
		else
			dxDrawImage(moveX-38, moveY+123, 40, 48, "files/wallet.png", 0, 0, 0, tocolor(255, 255, 255, 50))
		end

		if isInBox(moveX-38, moveY+178, 40, 48) and not showCraft then
			dxDrawImage(moveX-38, moveY+178, 40, 48, "files/craft.png", 0, 0, 0, tocolor(255, 255, 255, 100))
		end
		if showCraft == true then
			dxDrawImage(moveX-38, moveY+178, 40, 48, "files/craft.png", 0, 0, 0, tocolor(255, 255, 255, 190))
		else
			dxDrawImage(moveX-38, moveY+178, 40, 48, "files/craft.png", 0, 0, 0, tocolor(255, 255, 255, 50))
		end
	else
		correctX = 40
		dxDrawText("#7cc576Csomagtartó: #FFFFFF",moveX-38, moveY-17, pW + moveX-38, 23,tocolor(255,255,255,255),1,iFont,"left","top",false,false,true,true)
		dxDrawImage(moveX-38, moveY+5, 40, 48, "files/car.png")
	end

	dxDrawText(math.ceil(itemWeight) .. "/"..getTypeOfElement(elementSource)[2].."kg", moveX+150, moveY + 210, pW + moveX+160, 23, tocolor(255, 255, 255, 255), 0.75, iFont, "center", "top", false, false, true, true)

	dxDrawRectangle(moveX+10, moveY + 213, 345, 10, tocolor(134, 133, 131, 200))
	dxDrawRectangle(moveX+10, moveY + 213, math.ceil(itemWeight)/getTypeOfElement(elementSource)[2] * (345), 10, tocolor(124, 197, 118, 255))

	if showCraft then return end

	local drawRow = 0
	local drawColumn = 0
	local typeOfInventory = activeSide
	moveTime = startTick > -1 and movedSlot and (getTickCount() - startTick >= 300)
	for i = 1, row * column do
		dxDrawRectangle(moveX + drawColumn * (itemSize + margin) + margin * 2.5, moveY + drawRow * (itemSize + margin) + margin * 2.5, itemSize, itemSize, tocolor(47, 47, 46,200))
		if isInBox(moveX + drawColumn * (itemSize + margin) + margin * 2.5, moveY + drawRow * (itemSize + margin) + margin * 2.5, itemSize, itemSize) then
			dxDrawRectangle(moveX + drawColumn * (itemSize + margin) + margin * 2.5, moveY + drawRow * (itemSize + margin) + margin * 2.5, itemSize, itemSize, tocolor(255,140,0, 180))

			hoverSlot = i
			if (inventoryItems[typeOfInventory][i]) then
				hoverItem = (inventoryItems[typeOfInventory][i])

			else
				hoverItem = nil
			end
		end
		local itemData = inventoryItems[activeSide][i]

		if vehBoot then
			if getElementType(vehBoot) == "vehicle" then
				itemData = inventoryItems["all"][i]
				typeOfInventory = "all"
			end
		end
		if (itemData) then
			local itemDbid = itemData["dbid"]
			local itemID = itemData["id"]
			local itemValue = itemData["value"]
			local itemCount = itemData["count"]
			local itemHealth = itemData["health"]
			if isInBox(moveX + drawColumn * (itemSize + margin) + margin * 2.5, moveY + drawRow * (itemSize + margin) + margin * 2.5, itemSize, itemSize) then
				if (inventoryItems[typeOfInventory][i]) then
					if not tooltiptiltas then
						if itemID == 298 then
							create_tooltip("#7cc576"..items[inventoryItems[typeOfInventory][i]["id"]].name.."#ffffff \n" .. getBluePrintNameByID(itemValue) .."")
						elseif itemID == 1 or itemID == 2 then
							create_tooltip("#7cc576"..items[inventoryItems[typeOfInventory][i]["id"]].name.."#ffffff \n((Azonosító: " .. itemValue .."))")
						elseif (itemID > 74 and itemID < 88) or (itemID > 263 and itemID < 286) then
							if itemHealth <= 100 and itemHealth >= 75 then
								allapotSzin = "#7cc576"
							elseif itemHealth <= 74 and itemHealth >= 35 then
								allapotSzin = "#c66600"
							elseif itemHealth <= 34 then
								allapotSzin = "#930000"
							end
							create_tooltip("#7cc576"..items[inventoryItems[typeOfInventory][i]["id"]].name.."#ffffff \n Állapot: " ..allapotSzin..""..itemHealth.. "% #FFFFFF\nSúly: #43bde0" .. getItemWeight(inventoryItems[typeOfInventory][i]["id"]) .." kg")
						else
							create_tooltip("#7cc576"..items[inventoryItems[typeOfInventory][i]["id"]].name.."#ffffff \nSúly: #43bde0" .. getItemWeight(inventoryItems[typeOfInventory][i]["id"]) .." kg")

						end
					end
				end
			end

			if ((movedSlot == i)) then
				inMove = true
				local actionegerW = {getCursorPosition()}
				local actionegerP = {actionegerW[1]*sX, actionegerW[2]*sY}
				newX = actionegerP[1] - actionOffsetX
			 	newY = actionegerP[2] - actionOffsetY
				if not (inClone) then
					dxDrawImage(newX, newY, itemSize, itemSize, getItemImg(tonumber(movedItem["id"])), 0, 0, 0, tocolor(255, 255, 255, 255), true)
					dxDrawText(itemCount, newX , newY, newX+itemSize-1 , newY+itemSize-1,tocolor(0,0,0,255/100*80),0.7,iFont,"right", "bottom", false,false,true)
					dxDrawText(itemCount, newX , newY, newX+itemSize-1, newY+itemSize-1 ,tocolor(255,255,255,255),0.7,iFont,"right", "bottom", false,false,true)
					tooltiptiltas = true
				end
			end
			if ((movedSlot ~= i)) or inClone then
				if guiGetText(amountBox) ~= itemCount then
					dxDrawImage(moveX + drawColumn * (itemSize + margin) + margin * 2.5, moveY + drawRow * (itemSize + margin) + margin * 2.5, itemSize, itemSize, getItemImg(tonumber(itemID)), 0, 0, 0, tocolor(255, 255, 255, 255))
					if itemCount > 0 then
						textWidth = dxGetTextWidth(removeHex(itemCount), 1)
						dxDrawText(itemCount, moveX + drawColumn * (itemSize + margin) + margin * 2.5, moveY + drawRow * (itemSize + margin) + margin * 2.5, moveX + drawColumn * (itemSize + margin) + margin * 2.5+itemSize-1, moveY + drawRow * (itemSize + margin) + margin * 2.5+itemSize-1,tocolor(255,255,255,255),0.7,iFont,"right","bottom")
					end
					if activeSide == "bag" then
						if tonumber(getElementData(localPlayer, "Char->usingWeapon").ammo_slot or -1) == i then
							dxDrawImage(moveX + drawColumn * (itemSize + margin) + margin * 2.5-3, moveY + drawRow * (itemSize + margin) + margin * 2.5-3, 42, 42, "files/used.png", 0, 0, 0, tocolor(255, 255, 255, 255))
						end
						if tonumber(getElementData(localPlayer, "Char->usingWeapon").weapon_slot or -1) == i then
							dxDrawImage(moveX + drawColumn * (itemSize + margin) + margin * 2.5-3, moveY + drawRow * (itemSize + margin) + margin * 2.5-3, 42, 42, "files/used.png", 0, 0, 0, tocolor(255, 255, 255, 255))
						end
					end
					if items[itemID] and items[itemID].statusbar then
						dxDrawRectangle(moveX + drawColumn * (itemSize + margin) + margin * 2.5 + 2, moveY + drawRow * (itemSize + margin) + margin * 2.5 + itemSize - 6, itemSize - 4, 4, tocolor(0, 0, 0, 255))
						dxDrawRectangle(moveX + drawColumn * (itemSize + margin) + margin * 2.5 + 2, moveY + drawRow * (itemSize + margin) + margin * 2.5 + itemSize - 6, itemHeath / 100 * (itemSize - 4), 4, tocolor(163, 93, 0, 255))
					end
				end
			end
		end
		drawColumn = drawColumn + 1
		if (drawColumn == column) then
			drawColumn = 0
			drawRow = drawRow + 1
		end
	end
	if (inClone) then
		--if selectedAmount < movedItem["count"] then
			local actionegerW = {getCursorPosition()}
			local actionegerP = {actionegerW[1]*sX, actionegerW[2]*sY}
			newX = actionegerP[1] - actionOffsetX
			newY = actionegerP[2] - actionOffsetY
			dxDrawImage(newX, newY, itemSize, itemSize, getItemImg(tonumber(clonedItem["id"])), 0, 0, 0, tocolor(255, 255, 255, 255))
			dxDrawText(guiGetText(amountBox),newX , newY, newX+itemSize-1, newY+itemSize-1, tocolor(255,255,255,255), 0.7, iFont, "right", "bottom")
		--end
	end
	if not inMove then
		tooltiptiltas = false
	end
end
addEventHandler("onClientRender", getRootElement(), renderInventory)

function playHoverSound()
	hoverSoundOn = true
	if hoverSoundOn then
		playSound("files/hover.mp3")
		hoverSoundOn = false
	end
end

local typeOfInventory = activeSide
addEventHandler("onClientClick", getRootElement(),
	function(pButton, pState, _, _, _, _, _, clickedElement)
		if (pButton == "left" and pState == "down" and showInventory) then
			if (tonumber(hoverSlot) > -1 and hoverItem and not inClone) then
				if tonumber(getElementData(localPlayer, "Char->usingWeapon").ammo_slot or -1) == hoverSlot then outputChatBox("#d9534f[SeeMTA]: #FFFFFFAmíg használatban van ez az item nem mozgathatod!",255,255,255,true) return end
				if tonumber(getElementData(localPlayer, "Char->usingWeapon").weapon_slot or -1) == hoverSlot then outputChatBox("#d9534f[SeeMTA]: #FFFFFFAmíg használatban van ez az item nem mozgathatod!",255,255,255,true) return end
				if activeSide ~= "bag" or activeWeaponSlot ~= hoverSlot and activeAmmoSlot ~= hoverSlot and activeMask ~= hoverSlot and activeShield ~= hoverSlot then
					startTick = getTickCount()
					movedItem = hoverItem
					movedSlot = tonumber(hoverSlot)

					if vehBoot then
						if getElementType(vehBoot) == "vehicle" then
							typeOfInventory = "all"
						end
					end
					local drawRow = 0
					local drawColumn = 0
					for i = 1, row * column do
						if isInBox(moveX + drawColumn * (itemSize + margin) + margin * 2.5, moveY + drawRow * (itemSize + margin) + margin * 2.5, itemSize, itemSize) then
							--if (inventoryItems["bag"][i]) or (inventoryItems["key"][i]) or (inventoryItems["licens"][i]) or (inventoryItems["all"][i]) then
								actionegerW = {getCursorPosition()}
								actionegerP = {actionegerW[1]*sX, actionegerW[2]*sY}
								actionOffsetX = actionegerP[1] - (moveX + drawColumn * (itemSize + margin) + margin * 2.5)
								actionOffsetY = actionegerP[2] - (moveY + drawRow * (itemSize + margin) + margin * 2.5)
							--end
						end
						drawColumn = drawColumn + 1
						if (drawColumn == column) then
							drawColumn = 0
							drawRow = drawRow + 1
						end
					end

					playSound("files/select.mp3")

					if guiGetText(amountBox) ~= "" and hoverItem["count"] > tonumber(guiGetText(amountBox)) then
						inClone = true
						clonedItem = hoverItem
						clonedSlot = tonumber(hoverSlot)
					end
				end
			end
			if not vehBoot then
				if (isInBox(moveX-38, moveY+13, 40, 48)) then
					closeCraft()
					activeSide = "bag"
					craftPanel = false
					playSound("files/bincoselect.mp3")
				end
				if (isInBox(moveX-38, moveY+68, 40, 48)) then
					closeCraft()
					activeSide = "key"
					craftPanel = false
					playSound("files/bincoselect.mp3")
				end
				if (isInBox(moveX-38, moveY+123, 40, 48)) then
					closeCraft()
					activeSide = "licens"
					craftPanel = false
					playSound("files/bincoselect.mp3")
				end
				if (isInBox(moveX-38, moveY+178, 40, 48)) then
					closeCraft()
					craftPanel = true
					activeSide = "licens"
					if elementSource == localPlayer then
						showCraft = true
					end
					playSound("files/bincoselect.mp3")
				end
			end
			if(isCursorInAction and current_action_slot > -1)then
				action_array[current_action_slot] = {-1, -1, "bag", -1, false}
			end
		elseif (pButton == "left" and pState == "up" and showInventory) then
			if (not inItem and isCursorInAction and movedItem and movedSlot > -1) then
				action_array[current_action_slot] = {movedSlot, movedItem["id"], activeSide, movedItem["count"], false}
				playSound("files/move.mp3")
			end
			if hoverSlot == movedSlot then
				hideClone()
			end

			if not hoverItem then
				if hoverSlot == -1 then
					hideClone()
				end
			end
			if (movedSlot > -1 and movedItem and not hoverItem and hoverSlot > -1 and hoverSlot ~= movedSlot and inItem and inMove) then
				playSound("files/move.mp3")
				if guiGetText(amountBox) ~= "" and movedItem["count"] > tonumber(guiGetText(amountBox)) then
					if movedItem["count"] >= selectedAmount then
						if movedItem["count"] - selectedAmount ~= 0 then
							setItemCount(hoverSlot, movedSlot, movedItem["count"] - selectedAmount, 1, selectedAmount)
						end
					end
				else
					setItemSlot(movedSlot, hoverSlot)
				end
				hideClone()
			elseif (movedSlot > -1 and movedItem and hoverItem and hoverSlot > -1 and hoverItem["id"] == movedItem["id"] and hoverSlot ~= movedSlot and inItem and inMove and items[movedItem["id"]].stackable) then
				if guiGetText(amountBox) ~= "" and movedItem["count"] > tonumber(guiGetText(amountBox)) then
					if hoverItem["id"] == clonedItem["id"] then
						if clonedItem["count"] >= selectedAmount then
							setItemCount(hoverSlot, movedSlot, hoverItem["count"] + selectedAmount, 2, movedItem["count"] - selectedAmount)
						end
					end
				else
					setItemCount(hoverSlot, movedSlot, hoverItem["count"] + movedItem["count"], 0)
				end
				hideClone()
			elseif (movedSlot > -1 and movedItem and not inAction and inMove and not inItem and clickedElement and getElementType(clickedElement) == "vehicle" and getElementData(clickedElement, "dbid") > 0) and not isCursorInAction then
				if not (isVehicleLocked(clickedElement)) then
					if movedItem["duty"] >= 1 then
						exports.sas_hud:addNotification("Ez a tárgy dutyitem, nem adhatod át!","warning")

					else
						if isPedInVehicle(localPlayer) then return end
						if getDistanceFromElement(elementSource, clickedElement) < 3 then
							triggerServerEvent("tradeItem", localPlayer, clickedElement, elementSource, movedItem)

							inventoryItems[activeSide][movedItem["slot"]] = nil
						end
					end
				else
					exports.sas_hud:addNotification("Jármű zárva!","warning")
				end
			elseif (movedSlot > -1 and movedItem and not inAction and inMove and not inItem and clickedElement and getElementType(clickedElement) == "player" and getElementData(clickedElement, "dbid") > 0) and not isCursorInAction then
				local typeOfInventory = activeSide

				if vehBoot then
					if getElementType(vehBoot) == "vehicle" then
						typeOfInventory = "all"
					end
				end

				if getDistanceFromElement(elementSource, clickedElement) < 5 then
					if typeOfInventory == "bag" or typeOfInventory == "key" or typeOfInventory == "wallet" then
						if clickedElement ~= localPlayer then
							if movedItem["duty"] >= 1 then
								exports.sas_hud:addNotification("Ez a tárgy dutyitem, nem adhatod át!","warning")
							else
								triggerServerEvent("tradeItem", localPlayer, clickedElement, elementSource, movedItem)
		
								inventoryItems[activeSide][movedItem["slot"]] = nil
							end
						end
					else
						if movedItem["duty"] >= 1 then
							exports.sas_hud:addNotification("Ez a tárgy dutyitem, nem adhatod át!","warning")
						else
							triggerServerEvent("tradeItem", localPlayer, clickedElement, elementSource, movedItem)
	
							inventoryItems["all"][movedItem["slot"]] = nil
						end
					end
				end
			elseif (movedSlot > -1 and movedItem and not inAction and inMove and not inItem and clickedElement and getElementType(clickedElement) == "object") and getElementModel(clickedElement) == 1359 and clickedElement ~= localPlayer and not isCursorInAction then
					if getDistanceFromElement(elementSource, clickedElement) < 5 then
						triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "kidob egy tárgyat a szemetesbe ("..items[movedItem["id"]].name ..")")

						if weaponModels[movedItem["id"]] then
							triggerServerEvent("delAttachWeapon",localPlayer,localPlayer,movedItem["id"],movedItem["value"],movedItem["dbid"])
						end

						triggerServerEvent("deleteItem", localPlayer, elementSource, movedItem)

						inventoryItems[activeSide][movedItem["slot"]] = nil
					end
			elseif (movedSlot > -1 and movedItem and not inAction and inMove and not inItem and clickedElement and getElementType(clickedElement) == "object") and getElementData(clickedElement, "Safe->isSafe") and clickedElement ~= localPlayer and not isCursorInAction then
				if movedItem["duty"] >= 1 then
					exports.sas_hud:addNotification("Ez a tárgy dutyitem, nem adhatod át!","warning")
				else
					if getDistanceFromElement(elementSource, clickedElement) < 5 then
						if getElementData(clickedElement, "Safe->owner") == getElementData(localPlayer, "dbid") then
							triggerServerEvent("tradeItem", localPlayer, clickedElement, elementSource, movedItem)

							inventoryItems["all"][movedItem["slot"]] = nil
						else
							exports.sas_hud:addNotification("Nem a tiéd a széf!","warning")
						end
					end
				end
			elseif (startTick > -1 and movedSlot and (getTickCount() - startTick < 300)) and getElementType(elementSource) == "object" and getElementData(elementSource, "Safe->isSafe") and elementSource ~= localPlayer then
				triggerServerEvent("tradeItem", localPlayer, localPlayer, elementSource, movedItem)

				inventoryItems["all"][movedItem["slot"]] = nil

				triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "kivesz egy tárgyat a széfből ("..items[movedItem["id"]].name ..")")
			end
			hideMove()
		elseif (pButton == "right" and pState == "down" and showInventory and not inMove and movedSlot < 0) then
			if hoverSlot >=1 then
				if hoverItem then
					if elementSource == localPlayer then
						useItem(hoverItem,hoverSlot)
					end
				end
			end

		elseif pButton == "right" and pState == "down" then
			if (clickedElement and getElementType(clickedElement) == "vehicle" and tonumber(getElementData(clickedElement, "dbid") or 0) > 0) then -- Kocsi
				if getDistanceFromElement(localPlayer, clickedElement) < 5 then
					if isPedInVehicle(localPlayer) then return end
					if (isVehicleLocked(clickedElement)) then
						exports.sas_hud:addNotification("Ez a jármű zárva van!","warning")
					else
						if elementSource ~= clickedElement then
							triggerServerEvent("getElementItems", localPlayer, clickedElement, true)
						else
							openInventory(clickedElement)
						end
					end
				end
			end
			if (clickedElement and getElementType(clickedElement) == "object" and tonumber(getElementData(clickedElement, "Safe->id") or 0) > 0) then -- Széf
				if getDistanceFromElement(localPlayer, clickedElement) < 5 then
					if (getElementData(clickedElement, "Safe->owner") == getElementData(localPlayer, "dbid")) or tonumber(getElementData(localPlayer, "acc:admin") or 0) >= 7 then
						if elementSource ~= clickedElement then
							triggerServerEvent("getElementItems", localPlayer, clickedElement, true)
						else
							openInventory(clickedElement)
						end
					else
						exports.sas_hud:addNotification("Nem a tiéd a széf!","warning")
					end
				end
			end
		end
	end
)

addCommandHandler("openinv", function(c, target)
	if tonumber(getElementData(localPlayer, "adminlevel") or 0) >= 6 then
		local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(getLocalPlayer(), target)
		if not targetPlayer then
			outputChatBox("[SeeMTA]: /" .. c .. "[Név]",255,255,255,true)
			return
		end

		triggerServerEvent("getElementItems", localPlayer, targetPlayer, true)
	end
end)

function setItemSlot(oldSlot, newSlot)
	if (oldSlot > -1 and newSlot > -1) then
		local typeOfInventory = activeSide
		if vehBoot then
			if getElementType(vehBoot) == "vehicle" then
				typeOfInventory = "all"
			end
		end

		triggerServerEvent("updateItemSlot", localPlayer, elementSource, newSlot, inventoryItems[typeOfInventory][oldSlot])

		inventoryItems[typeOfInventory][newSlot] = inventoryItems[typeOfInventory][oldSlot]
		inventoryItems[typeOfInventory][newSlot]["slot"] = newSlot
		inventoryItems[typeOfInventory][oldSlot] = nil
	end
end

function setItemCount(newSlot, oldSlot, newCount, type, newItemCount)
	if (newSlot > -1 and newCount > -1) then
		local typeOfInventory = activeSide
		if vehBoot then
			if getElementType(vehBoot) == "vehicle" then
				typeOfInventory = "all"
			end
		end

		if type == 1 then
			local activeItem = inventoryItems[typeOfInventory][oldSlot]
			triggerServerEvent("updateItemCount", localPlayer, elementSource, newSlot, newCount, activeItem, 1, newItemCount)

			inventoryItems[typeOfInventory][oldSlot]["count"] = newCount
			inventoryItems[typeOfInventory][newSlot] = {
				["id"] = activeItem["id"],
				["value"] = activeItem["value"],
				["count"] = newItemCount,
				["duty"] = activeItem["duty"],
				["slot"] = activeItem["slot"],
				["health"] = activeItem["health"]
			}
		elseif type == 2 then
			triggerServerEvent("updateItemCount", localPlayer, elementSource, newSlot, newCount, inventoryItems[typeOfInventory][oldSlot], 2, newItemCount)

			inventoryItems[typeOfInventory][newSlot]["count"] = newCount
			inventoryItems[typeOfInventory][oldSlot]["count"] = newItemCount
		elseif type == 3 then
			triggerServerEvent("updateItemCount", localPlayer, elementSource, newSlot, oldSlot, newCount, 3)

			inventoryItems[typeOfInventory][newSlot]["count"] = oldSlot
		else
			triggerServerEvent("updateItemCount", localPlayer, elementSource, newSlot, newCount, inventoryItems[typeOfInventory][oldSlot], 0)

			inventoryItems[typeOfInventory][newSlot]["slot"] = newSlot
			inventoryItems[typeOfInventory][newSlot]["count"] = newCount
			inventoryItems[typeOfInventory][oldSlot] = nil
		end
	end
end

function getAllItemWeight()
	local elementType = getTypeOfElement(elementSource)[1]
	if elementType > 1 then
		local allWeight = 0
		for i = 1, row * column do
			if (inventoryItems["all"][i]) then
				allWeight = allWeight + (getItemWeight(inventoryItems["all"][i]["id"]) * inventoryItems["all"][i]["count"])
			end
		end
		return allWeight
	else
		local bagWeight = 0
		local keyWeight = 0
		local licensWeight = 0
		for i = 1, row * column do
			if (inventoryItems["bag"][i]) then
				bagWeight = bagWeight + (getItemWeight(inventoryItems["bag"][i]["id"]) * inventoryItems["bag"][i]["count"])
			end
		end
		for i = 1, row * column do
			if (inventoryItems["key"][i]) then
				keyWeight = keyWeight + (getItemWeight(inventoryItems["key"][i]["id"]) * inventoryItems["key"][i]["count"])
			end
		end
		for i = 1, row * column do
			if (inventoryItems["licens"][i]) then
				licensWeight = licensWeight + (getItemWeight(inventoryItems["licens"][i]["id"]) * inventoryItems["licens"][i]["count"])
			end
		end
		return bagWeight + licensWeight + keyWeight
	end
end

function getItemSzamB()
	local bagSz = 0
	for i = 1, row * column do
		if (inventoryItems["bag"][i]) then
			bagSz = bagSz + (inventoryItems["bag"][i]["value"])
		end
	end
	return bagSz
end


function getItemSzamK()
	local keySz = 0
	for i = 1, row * column do
		if (inventoryItems["key"][i]) then
			keySz = keySz + (inventoryItems["key"][i]["count"])
		end
	end
	return keySz
end

function getItemSzamW()
	local wallet = 0
	for i = 1, row * column do
		if (inventoryItems["licens"][i]) then
			wallet = wallet + (inventoryItems["licens"][i]["count"])
		end
	end
	return wallet
end

function getItemKocsa()
	local kocsi = 0
	for i = 1, row * column do
		if (inventoryItems["all"][i]) then
			kocsi = kocsi + (inventoryItems["all"][i]["count"])
		end
	end
	return kocsi
end

function takeStatus(itemID, statusMinus)
	if (itemID > -1) then
		local haveItem, _, _, itemSlot, itemType = hasItem(itemID)
		if haveItem then
			if tonumber(inventoryItems[itemType][itemSlot]["health"]) - tonumber(statusMinus) <= 0 then
				triggerServerEvent("deleteItem", localPlayer, elementSource, inventoryItems[activeSide][itemSlot])
			else
				triggerServerEvent("takeStatus", localPlayer, localPlayer, inventoryItems[itemType][itemSlot]["dbid"], tonumber(inventoryItems[itemType][itemSlot]["health"]) - statusMinus)
				inventoryItems[itemType][itemSlot]["health"] = tonumber(inventoryItems[itemType][itemSlot]["health"]) - statusMinus
			end
		end
	end
end

addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer(),function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	local activeItemID = getElementData(localPlayer,"char:fegyo")
	local activeitemSlot = getElementData(localPlayer, "Char->usingWeapon").weapon_slot or -1
	local witem = getElementData(localPlayer,"char:fegyo")
	local wslot = tonumber(getElementData(localPlayer, "Char->usingWeapon").weapon_slot or -1)
	if (items[witem].isWeapon) then
		if hotTable[getPedWeapon(localPlayer)] then
			randState = math.random(1,7)
			weaponHot = weaponHot+hotTable[getPedWeapon(localPlayer)]
			setElementData(localPlayer,"weap:hot",getElementData(localPlayer,"weap:hot")+hotTable[getPedWeapon(localPlayer)])
		end
	end
end)

function takeItem(itemID)
	if (itemID > -1) then
		local haveItem, _, _, itemSlot, itemType = hasItem(itemID)
		if haveItem then
			triggerServerEvent("deleteItem", localPlayer, localPlayer, inventoryItems[itemType][itemSlot])
		end
	end
end

function hideMove()
	startTick = -1
	movedItem = nil
	movedSlot = -1
	inMove = false
end

function hideClone()
	clonedItem = nil
	clonedSlot = -1
	inClone = false
end

function hasActionItem(actionItem)
	hasTheItem = false
	if (actionItem) then
		if (inventoryItems["bag"] and inventoryItems["key"] and inventoryItems["licens"]) then
			for i = 1, row * column do
				if (inventoryItems["bag"][i]) then
					if (actionItem["dbid"] == inventoryItems["bag"][i]["dbid"]) then
						hasTheItem = true
					end
				end
			end
			for i = 1, row * column do
				if (inventoryItems["key"][i]) then
					if (actionItem["dbid"] == inventoryItems["key"][i]["dbid"]) then
						hasTheItem = true
					end
				end
			end
			for i = 1, row * column do
				if (inventoryItems["licens"][i]) then
					if (actionItem["dbid"] == inventoryItems["licens"][i]["dbid"]) then
						hasTheItem = true
					end
				end
			end
			if hasTheItem then
				return true
			else
				return false
			end
			return false
		end
		return false
	end
	return false
end


function deleteItemFromActionSlot(slot)
	for k, v in pairs(action_array) do
		if slot == action_array[k][1] then
			action_array[k] = {-1, -1, "bag", -1, false}
		end
	end
end

function hasItem(itemID, itemValue)
	if (not itemValue) then
		if (inventoryItems["bag"] and inventoryItems["key"] and inventoryItems["licens"]) then
			for i = 1, row * column do
				if (inventoryItems["bag"][i]) then
					if (itemID == inventoryItems["bag"][i]["id"]) then
						return true, itemID, itemValue, i, "bag", countItemsInInventory(itemID)
					end
				end
			end
			for i = 1, row * column do
				if (inventoryItems["key"][i]) then
					if (itemID == inventoryItems["key"][i]["id"]) then
						return true, itemID, itemValue, i, "key"
					end
				end
			end
			for i = 1, row * column do
				if (inventoryItems["licens"][i]) then
					if (itemID == inventoryItems["licens"][i]["id"]) then
						return true, itemID, itemValue, i, "licens"
					end
				end
			end
			return false
		end
		return false
	else
		if (inventoryItems["bag"] and inventoryItems["key"] and inventoryItems["licens"]) then
			for i = 1, row * column do
				if (inventoryItems["bag"][i]) then
					if (itemID == inventoryItems["bag"][i]["id"] and itemValue == inventoryItems["bag"][i]["value"]) then
						return true, itemID, itemValue, i
					end
				end
			end
			for i = 1, row * column do
				if (inventoryItems["key"][i]) then
					if (itemID == inventoryItems["key"][i]["id"] and itemValue == inventoryItems["key"][i]["value"]) then
						return true, itemID, itemValue, i
					end
				end
			end
			for i = 1, row * column do
				if (inventoryItems["licens"][i]) then
					if (itemID == inventoryItems["licens"][i]["id"] and itemValue == inventoryItems["licens"][i]["value"]) then
						return true, itemID, itemValue, i
					end
				end
			end
			return false
		end
		return false
	end
	return false
end

function countItemsInInventory(itemID, count)
	if (inventoryItems["bag"]) then
		local count = 0
		for i = 1, row * column do
			if (inventoryItems["bag"][i]) then
				if (itemID == inventoryItems["bag"][i]["id"]) then
					count = count + 1
				end
			end
		end
		return count
	end
	return false
end

function hasItemOnSlot(slot)
	if (inventoryItems["bag"][slot] and tonumber(inventoryItems["bag"][slot]["id"] or -1) > -1) then
		return true
	end
	if (inventoryItems["key"][slot] and tonumber(inventoryItems["key"][slot]["id"] or -1) > -1) then
		return true
	end
	if (inventoryItems["licens"][slot] and tonumber(inventoryItems["licens"][slot]["id"] or -1) > -1) then
		return true
	end
	return false
end

function isSlotUsedByAction(slot)
	if getElementType(elementSource) ~= "player" then return false end
	for k, v in ipairs(action_array) do
		if v[1] == slot and v[3] == activeSide then
			return true
		end
	end
	return false
end

function loadActionItems()
	if not fileExists("action.json") then
		local createFile = fileCreate("action.json")
		if createFile then
			for k=1, actionSlots do
				fileWrite(createFile, toJSON({-1, -1, "bag",-1, false}) .. " | ")
			end
			fileClose(createFile)
		end
	else
		setTimer(function()
			local hFile = fileOpen("action.json", true)
			if hFile then
				local buffer
				while not fileIsEOF(hFile) do
					buffer = fileRead(hFile, 500)
					local splitted_result = split(buffer, " | ")
					for k, v in ipairs(splitted_result) do
						local data = fromJSON(string.gsub(v, " ", ""))
						if data then
							action_array[k] = {tonumber(data[1]), tonumber(data[2]), tostring(data[3]), tonumber(data[4]), data[5]}
						end
					end
				end
				fileClose(hFile)
			end
		end, 200, 1)
	end
end
setTimer(loadActionItems, 200, 1)

function kattint( key, state, aX, aY, wX, wY, wZ, element )
	if(isInSlot(moveX-45,moveY-20,pW,25)) and showInventory then
		if (key == "left" and state == "down") then
			egerW = {getCursorPosition()}
			egerP = {egerW[1]*sX, egerW[2]*sY}
			mozgat = true
			movingOffsetX = egerP[1] - moveX
			movingOffsetY = egerP[2] - moveY
		else
			mozgat = false
		end
	end
end
addEventHandler ( "onClientClick", getRootElement(), kattint )

function split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function saveAction()
	if fileExists("action.json") then
		fileDelete("action.json")
		local createFile = fileCreate("action.json")
		if createFile then
			for k, v in ipairs(action_array) do
				fileWrite(createFile, toJSON({v[1] , v[2], v[3], v[4], v[5]}) .. " | ")
			end
			fileClose(createFile)
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

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function isInBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*sX, cursorY*sY
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end
end

addEventHandler("onClientGUIChanged", getRootElement(),function()
	if source == amountBox  then
		local currentAmount = guiGetText (source)
		if string.len(currentAmount) > 0 then
			local am = tonumber(currentAmount)
			if am then
				selectedAmount = removeDecimal(am)
			else
				guiSetText(source, currentAmount)
			end
		end
		if not (tostring(type(tonumber(guiGetText(amountBox)))) == "number") then
			guiSetText(source, "")
		end
	end
end)

function removeDecimal(number)
    local num = number
    local num2 = tostring(num)
    local found = nil
    for i=1,100000 do
        if string.sub(num2,i,i) == "." then
            found = i
        end
    end
    if type(found) == "number" then
        num2 = string.sub(num2,1,found-1)
    end
    num = tonumber(num2)
    return num
end

function dxDrawLinedRectangle( x, y, width, height, color, _width, postGUI )
	_width = _width or 1
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom
	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end
function getDistanceFromElement(from, to)
	if not from or not to then return end
	local x, y, z = getElementPosition(from)
	local x1, y1, z1 = getElementPosition(to)
	return getDistanceBetweenPoints3D(x, y, z, x1, y1, z1)
end

local iMenuT = nil
pJobbKlikk = nil

function itemMenuMegjelenites(targy, kx, ky)
    local targyID = getElementData(targy, "itemID")
    if not targyID then return end
    iMenuT = targy
    local y = 0.13
    local targyInfo = itemInformaciok[targyID]
    itemMenuElrejtes(targy)
    pJobbKlikk = guiCreateWindow(kx, ky, 150, 200, targyInfo[1], false)
    local vanMegfelelo = true
    if targyID == 50 then
        -- HIFI
        if getElementData(targy, "itemErtek") > 0 then
            bToggle = guiCreateButton(0.05, y, 0.9, 0.1, "Kikapcsolás", true, pJobbKlikk)

            y = y + 0.14

            bPreviousTrack = guiCreateButton(0.05, y, 0.42, 0.1, "Előző", true, pJobbKlikk)
            addEventHandler("onClientGUIClick", bPreviousTrack, function() triggerServerEvent("hifiSzamValtas", getLocalPlayer(), targy, -1) end, false)

            bNextTrack = guiCreateButton(0.53, y, 0.42, 0.1, "Következő", true, pJobbKlikk)
            addEventHandler("onClientGUIClick", bNextTrack, function() triggerServerEvent("hifiSzamValtas", getLocalPlayer(), targy, 1) end, false)
        else
            bToggle = guiCreateButton(0.05, y, 0.9, 0.1, "Bekapcsolás", true, pJobbKlikk)
        end
        addEventHandler("onClientGUIClick", bToggle, function() triggerServerEvent("togHifi", getLocalPlayer(), targy) end, false)

        y = y + 0.14
    else
        vanMegfelelo = false
    end

    menuBezaras = guiCreateButton(0.05, y, 0.9, 0.1, "Menü bezárása", true, pJobbKlikk)
    addEventHandler("onClientGUIClick", menuBezaras, function() itemMenuElrejtes(iMenuT) end, false)
    if not vanMegfelelo then
        itemMenuElrejtes(targy)
    end
end

function megjelenitettTargyMenuFrissitese()
    local iMenuX, iMenuY = guiGetPosition(pJobbKlikk,false)
    itemMenuMegjelenites(iMenuT, iMenuX, iMenuY)
end
addEvent("megjelenitettTargyMenuFrissitese", true)
addEventHandler("megjelenitettTargyMenuFrissitese", getRootElement(), megjelenitettTargyMenuFrissitese)

function itemMenuElrejtes(targy)
    if targy ~= iMenuT then return end
    if (isElement(pJobbKlikk)) then
        destroyElement(pJobbKlikk)
    end
    pJobbKlikk = nil
end

addCommandHandler("addweaponsxd", function()
	createClientAttachWeapons()
end)

addCommandHandler("addweaponsxd1", function()
	destroyClientAttachWeapons()
end)

function createClientAttachWeapons()
	if (inventoryItems["bag"]) then
		for i = 1, row * column do
			if (inventoryItems["bag"][i]) then
				if weaponModels[inventoryItems["bag"][i]["id"]] then
					triggerServerEvent("addAttachWeapon",localPlayer,localPlayer,inventoryItems["bag"][i]["id"],inventoryItems["bag"][i]["value"],inventoryItems["bag"][i]["dbid"])
				end
			end
		end
	end
end

function destroyClientAttachWeapons()
	if (inventoryItems["bag"]) then
		for i = 1, row * column do
			if (inventoryItems["bag"][i]) then
				if weaponModels[inventoryItems["bag"][i]["id"]] then
					triggerServerEvent("delAttachWeapon",localPlayer,localPlayer,inventoryItems["bag"][i]["id"],inventoryItems["bag"][i]["value"],inventoryItems["bag"][i]["dbid"])
				end
			end
		end
	end
end

function getBluePrintNameByID(itemValue)
	if itemValue == 1 then
		bluePrintName = "Cserepes növény: Mák"
	elseif itemValue == 2 then
		bluePrintName = "Cserepes növény: Kokacserje"
	elseif itemValue == 3 then
		bluePrintName = "Cserepes növény: Kender"
	elseif itemValue == 4 then
		bluePrintName = "Szárított marihuána"
	elseif itemValue == 5 then
		bluePrintName = "Füves cigi"
	elseif itemValue == 6 then
		bluePrintName = "Kokain"
	elseif itemValue == 7 then
		bluePrintName = "Heroin por"
	elseif itemValue == 8 then
		bluePrintName = "Heroinos fecskendő"
	elseif itemValue == 9 then
		bluePrintName = "Colt-45"
	elseif itemValue == 10 then
		bluePrintName = "AK-47"
	elseif itemValue == 11 then
		bluePrintName = "Sörétes puska"
	elseif itemValue == 12 then
		bluePrintName = "Vadászpuska"
	elseif itemValue == 13 then
		bluePrintName = "UZI"
	elseif itemValue == 14 then
		bluePrintName = "TEC-9"
	elseif itemValue == 15 then
		bluePrintName = "Kés"
	end
	return bluePrintName
end
