local craftSize = 5 * 5
showCraft = false

--local bluePrints = {}
local myPrints = {}

local craftSlotItems = {}
local craftFont = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 13)
local craftStarted = false
local craftTick = 0

local selectedCraftRecipe = -1
local scroll = 0
local itemsWantToCraft = 0
local maxShowed = 8
local schongeclickt = false

local itemToGive = 0
local buttonText = "Elkészít"

local tablePlaces = {
	-- erste Reihe
	{2562.884765625, -1291.7626953125, 1044.125},
	{2562.884765625-4, -1291.7626953125, 1044.125},
	{2562.884765625-8, -1291.7626953125, 1044.125},
	{2562.884765625-12, -1291.7626953125, 1044.125},
	{2562.884765625-16, -1291.7626953125, 1044.125},
	-- zweite Reihe
	{2562.884765625, -1291.7626953125-5, 1044.125},
	{2562.884765625-4, -1291.7626953125-5, 1044.125},
	{2562.884765625-8, -1291.7626953125-5, 1044.125},
	{2562.884765625-12, -1291.7626953125-5, 1044.125},
	{2562.884765625-16, -1291.7626953125-5, 1044.125},
}

local r, g, b = 217, 83, 79

function drawCraft()
	if not showCraft then return end
	local row = 0
	local column = 0
	local r,g,b,alpha = 23, 23, 23, 255
	if not schongeclickt then
		selectedCraftRecipe = 1
		craftSlotItems = bluePrints[1].itemSlots
		itemsWantToCraft = #bluePrints[1].itemsWant
	end

	for i=1, craftSize do
		row = row + 1
		dxDrawRectangle(moveX + row * (itemSize + margin) - 30, moveY + column * (itemSize + margin) + margin * 2.5, itemSize, itemSize, tocolor(r,g,b,alpha))
		if craftSlotItems[i] and craftSlotItems[i] > 0 and fileExists("files/items/" .. craftSlotItems[i] .. ".png") then
			dxDrawImage(moveX + row * (itemSize + margin) - 30, moveY + column * (itemSize + margin) + margin * 2.5, itemSize, itemSize, "files/items/" .. craftSlotItems[i] .. ".png")
			if isInSlot(moveX + row * (itemSize + margin) - 30, moveY + column * (itemSize + margin) + margin * 2.5, itemSize, itemSize) then
				local itemName = getItemName(craftSlotItems[i])
				create_tooltip("#7cc576"..itemName.. "\n#FFFFFFSzükséges a recepthez")
			end
			if hasItem(craftSlotItems[i], 1) then
				dxDrawImage(moveX + row * (itemSize + margin) - 30-2, moveY + column * (itemSize + margin) + margin * 2.5-2, 42, 42, "files/used.png")
			else
				dxDrawImage(moveX + row * (itemSize + margin) - 30-2, moveY + column * (itemSize + margin) + margin * 2.5-2, 42, 42, "files/used2.png")
			end
		end
		if row == 5 then
			row = 0
			column = column + 1
		end
		if isInSlot(moveX + row * (itemSize + margin) - 30, moveY + column * (itemSize + margin) + margin * 2.5, itemSize, itemSize) then
			--outputChatBox(row.." "..column)

		end
		if (column == 1 or column == 2 or column == 3) and (row == 1 or row == 2 or row == 3) then
			alpha = 200
			r,g,b = 47, 47, 46
		else
			alpha = 255
			r,g,b = 23, 23, 23
		end
	end

	--dxDrawRectangle(moveX + 200, moveY + 15, 140, 170, tocolor(0, 0, 0, 120))
	--dxDrawRectangle(moveX + 200, moveY + 15, 140, 15, tocolor(0, 0, 0, 120))

	dxDrawText("Receptek:", moveX + 220, moveY+ margin * 2.5, 0, 0, tocolor(255, 255, 255, 255), 0.8, craftFont, "left", "top", false, false, true, true)
	dxDrawRectangle(moveX + 220, moveY + 35-4, 190-10, 160, tocolor(0, 0, 0, 100))

	local haveItem, count = getHaveItems(bluePrints[selectedCraftRecipe].itemsWant)
	if haveItem >= itemsWantToCraft then
		r, g, b = 124, 197, 118
	else
		r, g, b = 217, 83, 79
	end

	if craftStarted then
		r, g, b = 217, 83, 79
	end

	if bluePrints[selectedCraftRecipe].needBlueprint then
		if not getElementData(localPlayer, "blueprints")[bluePrints[selectedCraftRecipe].needBlueprint] then
			r, g, b = 217, 83, 79
		end
	end

	if isInSlot(moveX + 220, moveY + 35+165+3-8-2, 197-12, 20) then
		dxDrawRectangle(moveX + 220, moveY + 35+165+3-8-2, 197-12, 16, tocolor(r, g, b, 255))
	else
		dxDrawRectangle(moveX + 220, moveY + 35+165+3-8-2, 197-12, 16, tocolor(r, g, b, 200))
	end
	dxDrawText(buttonText, moveX + 220, moveY + 35+165+3-8-2, moveX + 220+197-12, moveY + 35+165+3-8-2+16, tocolor(0, 0, 0, 255), 0.8, iFont, "center", "center", false, false, true, true)

	exports['sas_system']:gorgetesRajzolas(moveX + 220+190-10, moveY + 35-4, 5, 160, #bluePrints, 8, scroll, tocolor(0, 0, 0, 255))

	local line = 0
	local tr, tg, tb = 255,255,255
	local talpha = 255
	for k, v in ipairs(bluePrints) do
		if k == selectedCraftRecipe then
				dxDrawText(v.name, moveX+70, moveY-17+3,0,0, tocolor(255,255,255, 255), 0.85, craftFont, "left", "top", false, false, false, true)
		end
		if (k > scroll and line < 8) then
			line = line + 1
			if v.needGroup then
				groupText = "#d9534fSzükséges"
			elseif not v.needGroup then
				groupText = "#7cc576Nem szükséges"
			end

			if v.craftDimension then
				placeText = "#d9534fSzükséges"
			else
				placeText = "#7cc576Nem szükséges"
			end
			--dxDrawRectangle(moveX + 205, moveY + line * 21 + 18, 130, 20, tocolor(255, 255, 255, 10))


			if bluePrints[k].needBlueprint then
				if not getElementData(localPlayer, "blueprints")[bluePrints[k].needBlueprint] then
					talpha = 100
				else
					talpha = 255
				end
			else
				talpha = 255
			end

			if isInSlot(moveX + 220, moveY + 15-4 + line * 20, 180, 20) then
				dxDrawRectangle(moveX + 220, moveY + 15-4 + line * 20, 180, 20, tocolor(0,0,0,100))
				tr, tg, tb = 153, 204, 153
				talpha = 255
				if k >= 18 and k <= 23 then
					create_tooltip("Munka: #d9534fSzükséges\n#FFFFFFPozíció: #d9534fSzükséges")
				else
					create_tooltip("Csoport: "..groupText.."\n#FFFFFFPozíció: "..placeText)
				end
			else
				tr, tg, tb = 255, 255, 255
			end

			if k == selectedCraftRecipe then
				dxDrawRectangle(moveX + 220, moveY + 15-4 + line * 20, 180, 20, tocolor(0,0,0,180))
				tr, tg, tb = 153, 204, 153
				dxDrawText(v.name, moveX + 220, moveY + 15-4 + line * 20, moveX + 220+180, moveY + 15-4 + line * 20 + 20, tocolor(tr, tg, tb, 255), 0.67, craftFont, "center", "center", false, false, false, true)
			else
				--tr, tg, tb = 255, 255, 255
				dxDrawText(v.name, moveX + 220, moveY + 15-4 + line * 20, moveX + 220+180, moveY + 15-4 + line * 20 + 20, tocolor(tr, tg, tb, talpha), 0.67, craftFont, "center", "center", false, false, false, true)

			end
		end
	end

	if craftStarted then
		craftTick = craftTick + 1
		--dxDrawRectangle(moveX + 220, moveY + 35+165+3-7-2, 200, 25, tocolor(0, 0, 0, 180))
		dxDrawRectangle(moveX + 220, moveY + 35+165+3-8-2, (craftTick / bluePrints[selectedCraftRecipe].craftProgressTick) * 185, 16, tocolor(124, 197, 118, 200))
		if craftTick >= bluePrints[selectedCraftRecipe].craftProgressTick then
			craftStarted = false
			craftTick = 0
			for k, v in ipairs(bluePrints[selectedCraftRecipe].itemsWant) do
				for i = 1, v[2] do
					if v[1] ~= 33 and v[1] ~= 19 and v[1] ~= 244 then
							takeItem(v[1])
					end
				end
			end
			triggerServerEvent("giveItem", localPlayer, localPlayer, itemToGive, 1, 1, 0)
			triggerServerEvent("setCraftingAnim", localPlayer, false)
		end
	end
end
addEventHandler("onClientRender", root, drawCraft)


function handleKey(key, state)
	if not showCraft then return end
	if key == "mouse_wheel_down" then
		if scroll < #bluePrints - maxShowed then
			scroll = scroll + 1
		end
	end
	if key == "mouse_wheel_up" then
		if scroll > 0 then
			scroll = scroll - 1
		end
	end
end
addEventHandler("onClientKey", root, handleKey)

function handleClick(button, state)
	if not showCraft then return end
	if button == "left" and state == "down" then
		if not craftStarted then
			local line = 0
			for k, v in ipairs(bluePrints) do
				if (k > scroll and line < 8) then
					line = line + 1
					if isInBox(moveX + 220, moveY + 15-4 + line * 20, 180, 20) then
						schongeclickt = true
						selectedCraftRecipe = k
						craftSlotItems = v.itemSlots
						itemsWantToCraft = #v.itemsWant
						if bluePrints[k].needBlueprint then
							if not getElementData(localPlayer, "blueprints")[bluePrints[k].needBlueprint] then
								buttonText = "Nincs elsajátítva a recept!"
							else
								buttonText = "Elkészít"
							end
						else
							buttonText = "Elkészít"
						end
						return
					end
				end
			end
		end
		if isInBox(moveX + 220, moveY + 35+165+3-7-2, 197-12, 20) and not craftStarted then
			if selectedCraftRecipe > -1 then
				if bluePrints[selectedCraftRecipe].craftDimension then
					if getElementDimension(localPlayer) ~= bluePrints[selectedCraftRecipe].craftDimension then
						return
					end
				end
				if bluePrints[selectedCraftRecipe].needBlueprint then
					if not getElementData(localPlayer, "blueprints")[bluePrints[selectedCraftRecipe].needBlueprint] then
							--outputChatBox("no bp")
							return
					end
				end
				if selectedCraftRecipe >= 18 and selectedCraftRecipe <= 23 then
					if not getElementData(localPlayer, "factorymarker") then
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFHogy ezt az itemet el tudd készíteni, menj a gyárba és állj egy ottlévő munkaasztalhoz.",0,0,0,true)
						return
					end
				end
				local haveItem, count = getHaveItems(bluePrints[selectedCraftRecipe].itemsWant)
				-- outputChatBox(haveItem .. " - " .. itemsWantToCraft)
				if haveItem < itemsWantToCraft then
					-- Ami nincs a crafthoz listazasa!!!!
					local brakeString = ""
					local str_ = ""
					local item_have = {}
					for k, v in ipairs(bluePrints[selectedCraftRecipe].itemsWant) do
						local has, count = hasItemWithCount(v[1], v[2])
						if not has then
							item_have[#item_have + 1] = {v[1], v[2] - count}
						end
					end
					for k, v in ipairs(item_have) do
						if k == 1 then else brakeString = ", " end
						str_ = str_ .. brakeString .. items[v[1]].name .. " (".. v[2] .. "x) "
					end
					-- outputChatBox(str_)
					return
				end
				craftStarted = true
				itemToGive = bluePrints[selectedCraftRecipe].itemGive
				triggerServerEvent("setCraftingAnim", localPlayer, true)
				triggerServerEvent("sendLocalMeAction", localPlayer, localPlayer, "összerak egy tárgyat.")
			end
		end
	end
end
addEventHandler("onClientClick", root, handleClick)

function getHaveItems(itemsWant)
	local have = 0
	for k, v in ipairs(itemsWant) do
		if hasItemWithCount(v[1], v[2]) then
			have = have + 1
		end
	end
	return have
end

function hasItemWithCount(itemID, count)
	local c = 0
	local slots = {}
	if inventoryItems["bag"] then
		for i = 1, row * column do
			if inventoryItems["bag"][i] then
				if itemID == inventoryItems["bag"][i]["id"] and not slots[i] then
					c = c + 1
					slots[i] = i
				end
			end
		end
		if c >= count then
			return true, c
		end
		return false, c
	end
end

function closeCraft()
	showCraft = false
	craftSlotItems = {}
	craftStarted = false
	craftTick = 0
	selectedCraftRecipe = -1
	scroll = 0
	itemsWantToCraft = 0
	itemToGive = 0
	schongeclickt = false
end
