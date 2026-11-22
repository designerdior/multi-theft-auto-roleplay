-- Ped Creation --
local factoryPed = createPed(62, 1489.041015625, 1305.76171875, 1093.2963867188, 271.84161376953)
setElementData(factoryPed, "visiblePedName", "Műszakvezető")
setElementData(factoryPed, "tagName", "NPC (Munka)")
setElementData ( factoryPed,"nameEnabled",true)
setElementData ( factoryPed,"factoryped",true)
setElementDimension(factoryPed, 5)
setElementInterior(factoryPed, 3)
setPedAnimation(factoryPed, "cop_ambient", "coplook_think")

local colshape = createColCuboid(-916, 1801, 1.5, 32, 27, 3)
local colshape2 = createColCuboid(2529.294921875, -1307.2, 1043.4, 42, 27.2, 7)
--setElementInterior(colshape, 17)

-- Ped Creation --
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

availableItemsToCreate = {
	{"Diktafon", 338},
	{"Elemlámpa", 337},
	{"Rádió", 336},
	{"Számológép", 335},
	{"Tápegység", 334},
	{"Walkie Talkie", 333},
}

startedJob = false
itemsToCreate = {}
itemIDtoCreate = -1
itemCountToCreate = -1
leadottItemCount = 0
egyszerreLeadottItemCount = 0
finishedWork = false

--counters
radioCount = 0
lampCount = 0
diktafonCount = 0

walkieCount = 0
tapCount = 0
counterCount = 0

local font = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 10)
local wallFont = dxCreateFont("factory/files/ocr.ttf", 13)
local floodStop = false

addEventHandler("onClientColShapeHit", resourceRoot, function(theElement)
	if theElement ~= localPlayer then return end
	if source == colshape then
		addEventHandler("onClientRender", getRootElement(), drawClickableItems)
		addEventHandler("onClientRender", getRootElement(), drawItemsToCrates)
	elseif source == colshape2 then
		addEventHandler("onClientPreRender", getRootElement(), renderTargetRender)
		addEventHandler("onClientPreRender", getRootElement(), drawCounterOnWall)
	end
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(theElement)
	if theElement ~= localPlayer then return end
	if source == colshape then
		removeEventHandler("onClientRender", getRootElement(), drawClickableItems)
		removeEventHandler("onClientRender", getRootElement(), drawItemsToCrates)
	elseif source == colshape2 then
		removeEventHandler("onClientPreRender", getRootElement(), renderTargetRender)
		removeEventHandler("onClientPreRender", getRootElement(), drawCounterOnWall)
	end
end)

function clickOnPed( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	if button == "right" and state == "down" then
		if clickedElement and getElementData(clickedElement, "factoryped") then
			if getElementData(localPlayer, "job") == 5 then
				if not startedJob then
					finishedWork = false
					startedJob = true
					itemIDtoCreate = math.random(1,6)
					itemCountToCreate = math.random(1,15)
					itemsToCreate = {availableItemsToCreate[itemIDtoCreate][1], availableItemsToCreate[itemIDtoCreate][2], itemCountToCreate}
					outputChatBox("#7cc576[SeeMTA - Munka]: #FFFFFFElkezdtél dolgozni. A következő tárgyakat kell összeszerelned:    - #7cc576"..itemCountToCreate.. " #FFFFFFdarab #7cc576"..itemsToCreate[1], 0,0,0,true)
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFFElőbb végezd el az eddig rád bízott munkát mielőtt újat kérsz.", 0,0,0,true)
				end
			else
				outputChatBox("#d9534f[SeeMTA]: #FFFFFFAhhoz, hogy munkát bírj kérni a műszakvezetőtől a városházán fel kell venned ezt a munkát.", 0,0,0,true)
			end
		end
	end
end
addEventHandler("onClientClick",getRootElement(), clickOnPed)

for k, v in pairs(tablePlaces) do
	randomObj = createObject(937, v[1], v[2], v[3]-0.5)
	setElementDimension(randomObj, 11)
	setElementInterior(randomObj, 2)
end

addEventHandler("onClientElementStreamIn", randomObj, function()
	removeWorldModel(922,10000,0,0,0, 2)
	removeWorldModel(934,10000,0,0,0, 2)
	removeWorldModel(936,10000,0,0,0, 2)
	removeWorldModel(937,10000,0,0,0, 2)
	removeWorldModel(941,10000,0,0,0, 2)
end)

local atvX = 0
local tableTraget = dxCreateRenderTarget(300, 500, true)
local putdownTraget = dxCreateRenderTarget(300, 500, true)
local stripeTexture = dxCreateTexture("factory/files/stripe.png")

function renderTargetRender()
	dxSetRenderTarget(tableTraget, true)
	for i = 1, 10 do
		for row = 1, 15 do
			dxDrawImage(220-(i*64)+64, 15+(row*64)-64, 64, 64, stripeTexture, 270,0,0, tocolor(217, 83, 79, 255))
		end
	end
	radarKeret(15, 15, 260, 460, 15, 217, 83, 79, 255)
	dxSetRenderTarget()
	dxSetRenderTarget(putdownTraget, true)
	for i = 1, 10 do
		for row = 1, 15 do
			dxDrawImage(220-(i*64)+64, 15+(row*64)-64, 64, 64, stripeTexture, 270,0,0, tocolor(255, 255, 255, 255))
		end
	end
	radarKeret(15, 15, 260, 460, 15, 255, 255, 255, 255)
	dxSetRenderTarget()
	for k, v in pairs(tablePlaces) do
		local pX, pY, pZ = getElementPosition(localPlayer)
		if pX <= v[1]+0.8 and pX >= v[1]+0.8-1.8 and pY >= v[2]+1 and pY <= v[2]+1+1 then
			atvX = v[1]
			atvY = v[2]
			atvZ = v[3]
		end
		dxDrawMaterialLine3D(v[1]+0.8, v[2]+1.3, v[3]-0.95, v[1]+1-1.8, v[2]+1.3, v[3]-0.95, tableTraget, 1, tocolor(255,255,255,255), v[1]+0.8, v[2]+1.3, v[3])
	end
	dxDrawMaterialLine3D(2559.134765625+0.8, -1304.580078125+1.3, 1044.125-0.95, 2559.134765625+1-1.8, -1304.580078125+1.3, 1044.125-0.95, putdownTraget, 1, tocolor(255,255,255,255), 2559.134765625+0.8, -1304.580078125+1.3, 1044.125)
	if getElementData(localPlayer, "loggedin") then
		local pX, pY, pZ = getElementPosition(localPlayer)
		if pX <= atvX+0.8 and pX >= atvX+0.8-1.8 and pY >= atvY+1 and pY <= atvY+1+1 then
			setElementData(localPlayer, "factorymarker", true)
		else
			setElementData(localPlayer, "factorymarker", false)
		end
		local itemCountCopy = itemCountToCreate
		if pX <= 2559.134765625+0.8 and pX >= 2559.134765625+0.8-1.8 and pY >= -1304.580078125+1 and pY <= -1304.580078125+1+1 then
			if itemsToCreate[2] == 336 or itemsToCreate[2] == 337 or itemsToCreate[2] == 338 then
				if leadottItemCount ~= itemCountToCreate and not finishedWork then
					for i = 1, 5 do
						if exports.sas_items:hasItem(itemsToCreate[2]) then
							exports.sas_items:takeItem(itemsToCreate[2])
							itemCountCopy = itemCountCopy - 1
							leadottItemCount = leadottItemCount + 1
							egyszerreLeadottItemCount = egyszerreLeadottItemCount + 1
							if itemsToCreate[2] == 336 then
								radioCount = radioCount + 1
								triggerServerEvent("addCountToTable", localPlayer, "radio")
							elseif itemsToCreate[2] == 337 then
								lampCount = lampCount + 1
								triggerServerEvent("addCountToTable", localPlayer, "lamp")
							elseif itemsToCreate[2] == 338 then
								diktafonCount = diktafonCount + 1
								triggerServerEvent("addCountToTable", localPlayer, "diktafon")
							end
						end
					end
				end
			end
		end
		dxDrawMaterialLine3D(2559.134765625+0.8-8.5, -1304.580078125+1.3, 1044.125-0.95, 2559.134765625+1-1.8-8.5, -1304.580078125+1.3, 1044.125-0.95, putdownTraget, 1, tocolor(255,255,255,255), 2559.134765625+0.8, -1304.580078125+1.3, 1044.125)
		if pX <= 2559.134765625+0.8-8.5 and pX >= 2559.134765625+0.8-8.5-1.8 and pY >= -1304.580078125+1 and pY <= -1304.580078125+1+1 then
			if itemsToCreate[2] == 333 or itemsToCreate[2] == 334 or itemsToCreate[2] == 335 then
				if leadottItemCount ~= itemCountToCreate and not finishedWork then
					for i = 1, 5 do
						if exports.sas_items:hasItem(itemsToCreate[2]) then
							exports.sas_items:takeItem(itemsToCreate[2])
							itemCountCopy = itemCountCopy - 1
							leadottItemCount = leadottItemCount + 1
							egyszerreLeadottItemCount = egyszerreLeadottItemCount + 1
							if itemsToCreate[2] == 333 then
								triggerServerEvent("addCountToTable", localPlayer, "walkie")
							elseif itemsToCreate[2] == 334 then
								triggerServerEvent("addCountToTable", localPlayer, "tap")
							elseif itemsToCreate[2] == 335 then
								triggerServerEvent("addCountToTable", localPlayer, "counter")
							end
						end
					end
				end
			end
		end
	end
end

local leadMarker = createMarker(2559.185546875, -1303.263671875, 1044.125-1, "cylinder", 1,0,0,0,0)
local leadMarker2 = createMarker(2559.185546875-8.5, -1303.263671875, 1044.125-1, "cylinder", 1,0,0,0,0)

function MarkerHit ( hitPlayer, matchingDimension )
	if itemsToCreate[2] == 336 or itemsToCreate[2] == 337 or itemsToCreate[2] == 338 then
		if leadottItemCount ~= itemCountToCreate and not finishedWork then
			if exports.sas_items:hasItem(itemsToCreate[2]) then
				triggerServerEvent("putDownAnim", localPlayer, true)
				setTimer(function()
					triggerServerEvent("putDownAnim", localPlayer, false)
					outputChatBox("#7cc576[SeeMTA - Munka]: #FFFFFFLeadtál #7cc576"..egyszerreLeadottItemCount.." #ffffffdarab #7cc576"..itemsToCreate[1].. "#ffffff-t.",0,0,0,true)
					finishedWork = true
					itemIDtoCreate = -1
					itemCountToCreate = -1
					itemsToCreate = {}
					startedJob = false
					egyszerreLeadottItemCount = 0
					leadottItemCount = 0
					if itemCountToCreate > 8 then
						payAmount = math.random(600, 1000)
					else
						payAmount = math.random(200, 600)
					end
					triggerServerEvent("payForWork", localPlayer, localPlayer, payAmount)
					outputChatBox("#7cc576[SeeMTA - Munka]: #FFFFFFA munkád elvégezted, fizetséged #7cc576"..payAmount.."$.",0,0,0,true)
				end, 600, 1)
			end
		end
	end
end
addEventHandler ( "onClientMarkerHit", leadMarker, MarkerHit )

function MarkerHit2 ( hitPlayer, matchingDimension )
	if itemsToCreate[2] == 333 or itemsToCreate[2] == 334 or itemsToCreate[2] == 335 then
		if leadottItemCount ~= itemCountToCreate and not finishedWork then
			if exports.sas_items:hasItem(itemsToCreate[2]) then
				triggerServerEvent("putDownAnim", localPlayer, true)
				setTimer(function()
					triggerServerEvent("putDownAnim", localPlayer, false)
					outputChatBox("#7cc576[SeeMTA - Munka]: #FFFFFFLeadtál #7cc576"..egyszerreLeadottItemCount.." #ffffffdarab #7cc576"..itemsToCreate[1].. "#ffffff-t.",0,0,0,true)
					finishedWork = true
					itemIDtoCreate = -1
					itemCountToCreate = -1
					itemsToCreate = {}
					startedJob = false
					egyszerreLeadottItemCount = 0
					leadottItemCount = 0
					if itemCountToCreate > 8 then
						payAmount = math.random(600, 1000)
					else
						payAmount = math.random(200, 600)
					end
					triggerServerEvent("payForWork", localPlayer, localPlayer, payAmount)
					outputChatBox("#7cc576[SeeMTA - Munka]: #FFFFFFA munkád elvégezted, fizetséged #7cc576"..payAmount.."$.",0,0,0,true)
				end, 600, 1)
			end
		end
	end
end
addEventHandler ( "onClientMarkerHit", leadMarker2, MarkerHit2 )

local counterTarget = dxCreateRenderTarget(600, 300, false)
local counterTarget2 = dxCreateRenderTarget(600, 300, false)

function drawCounterOnWall()
	dxSetRenderTarget(counterTarget, true)
	dxDrawRectangle(10, 10, 580, 280, tocolor(70,73,9,255))
	for k, v in pairs(getElementsByType("marker"), resourceRoot) do
		if getElementData(v, "countmarker") then
			dxDrawText("Rádió: "..getElementData(v, "radiocount").." db", 30, 10, 565, 200,tocolor(0,0,0,255), 2, wallFont, "center", "center")
			dxDrawText("Elemlámpa: "..getElementData(v, "lampcount").." db", 30, 10, 565, 290,tocolor(0,0,0,255), 2, wallFont, "center", "center")
			dxDrawText("Diktafon: "..getElementData(v, "diktafoncount").." db", 30, 10, 565, 380,tocolor(0,0,0,255), 2, wallFont, "center", "center")
		end
	end
	dxSetRenderTarget()

	dxSetRenderTarget(counterTarget2, true)
	dxDrawRectangle(10, 10, 580, 280, tocolor(70,73,9,255))
	for k, v in pairs(getElementsByType("marker"), resourceRoot) do
		if getElementData(v, "countmarker") then
			dxDrawText("Walkie Talkie: "..getElementData(v, "walkiecount").." db", 30, 10, 565, 200,tocolor(0,0,0,255), 2, wallFont, "center", "center")
			dxDrawText("Tápegység: "..getElementData(v, "tapcount").." db", 30, 10, 565, 290,tocolor(0,0,0,255), 2, wallFont, "center", "center")
			dxDrawText("Számológép: "..getElementData(v, "countercount").." db", 30, 10, 565, 380,tocolor(0,0,0,255), 2, wallFont, "center", "center")
		end
	end
	dxSetRenderTarget()
	dxDrawMaterialLine3D(2559.3837890625-0.3-8.5, -1307-0.3, 1044.125+1.4, 2559.3837890625-0.3-8.5, -1307-0.3, 1044.125+1.4-1, counterTarget2, 2, tocolor(255,255,255,255), 2559.3017578125-0.3-8.5, -1300.0716552734, 1045.2224121094)
	dxDrawMaterialLine3D(2559.3837890625-0.3, -1307-0.3, 1044.125+1.4, 2559.3837890625-0.3, -1307-0.3, 1044.125+1.4-1, counterTarget, 2, tocolor(255,255,255,255), 2559.3017578125-0.3, -1300.0716552734, 1045.2224121094)
end

function drawClickableItems()
	if floodStop then return end
	
	local px, py, pz = getElementPosition(localPlayer)

    local x1,y1,z1 = -896.47088623047, 1806.5826416016, 2.3078124523163
    local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
    if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/321.png")
		dxDrawText("Tranzisztor", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Tranzisztor", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end
	
	local x1,y1,z1 = -896.47088623047, 1804.4693603516, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/322.png")
		dxDrawText("Nyák", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Nyák", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -899.56463623047+1, 1806.4918212891, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/319.png")
		dxDrawText("Antenna", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Antenna", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -899.56463623047+1, 1804.2037353516, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/320.png")
		dxDrawText("Ventillátor", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Ventillátor", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -899.53045654297+1, 1821.1197509766, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/332.png")
		dxDrawText("Műanyag doboz", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Műanyag doboz", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -899.53045654297+1, 1823.2301025391, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/331.png")
		dxDrawText("Elem", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Elem", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -904.97088623047, 1806.7320556641, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/325.png")
		dxDrawText("Mikrofon", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Mikrofon", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -904.96990966797, 1804.4078369141, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/326.png")
		dxDrawText("Elemlámpa LSD", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Elemlámpa LSD", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -908.06463623047+1, 1806.5152587891, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/323.png")
		dxDrawText("Mikroprocesszor", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Mikroprocesszor", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -908.06463623047+1, 1804.4683837891, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/324.png")
		dxDrawText("Mini kijelző", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Mini kijelző", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -904.93572998047, 1821.1793212891, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/330.png")
		dxDrawText("Ellenállás", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Ellenállás", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -904.93572998047, 1823.3502197266, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/329.png")
		dxDrawText("Nyomógomb", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Nyomógomb", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -908.03045654297+1, 1821.2047119141, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/328.png")
		dxDrawText("Hangszóró", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Hangszóró", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end

	local x1,y1,z1 = -908.03045654297+1, 1823.4263916016, 2.3078124523163
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
		if isInSlot(x2+2, y2+1,46, 46) then
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(124, 197, 118,200))
		else
			dxDrawRectangle(x2+2, y2+1,46, 46, tocolor(0,0,0,200))
		end
		dxDrawImage(x2+2, y2+1, 46, 46, ":sas_items/files/items/327.png")
		dxDrawText("Kondenzátor", x2+2+1, y2+1, x2+2+46+1, y2+1+65+1, tocolor(0,0,0,255), 1, font, "center", "bottom")
		dxDrawText("Kondenzátor", x2+2, y2+1, x2+2+46, y2+1+65, tocolor(255,255,255,255), 1, font, "center", "bottom")
	end
end

function clickOnItems(button, state)
	local x1,y1,z1 = -896.47088623047, 1806.5826416016, 2.3078124523163
	local px, py, pz = getElementPosition(localPlayer)
	local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
	if not floodStop then
		if button == "left" and state == "down" then
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(321, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -896.47088623047, 1804.4693603516, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(322, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -899.56463623047+1, 1806.4918212891, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(319, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -899.56463623047+1, 1804.2037353516, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(320, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -899.53045654297+1, 1821.1197509766, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(332, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -899.53045654297+1, 1823.2301025391, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(331, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -904.97088623047, 1806.7320556641, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(325, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -904.96990966797, 1804.4078369141, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(326, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -908.06463623047+1, 1806.5152587891, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(323, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -908.06463623047+1, 1804.4683837891, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(324, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -904.93572998047, 1821.1793212891, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(330, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -904.93572998047, 1823.3502197266, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(329, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -908.03045654297+1, 1821.2047119141, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(328, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
			local x1,y1,z1 = -908.03045654297+1, 1823.4263916016, 2.3078124523163
			local x2, y2, dis = getScreenFromWorldPosition( x1-0.4, y1-0.1, z1+0.6 )
			if x2 and getDistanceBetweenPoints3D(x1,y1,z1, px, py, pz) <= 2 then
				if isInSlot(x2+2, y2+1,46, 46) then
					giveItem(327, 1, 1, 0)
					triggerServerEvent("munkaAnimacio", localPlayer, true)
					floodStop = setTimer(function()
						floodStop = false
						triggerServerEvent("munkaAnimacio", localPlayer, false)
					end, 1000, 1)
				end
			end
		end
	end
end
addEventHandler("onClientClick",getRootElement(),clickOnItems)

------------------
-- drawonthings --
------------------

local item1 = dxCreateTexture(":sas_items/files/items/321.png")
local item2 = dxCreateTexture(":sas_items/files/items/322.png")
local item3 = dxCreateTexture(":sas_items/files/items/319.png")
local item4 = dxCreateTexture(":sas_items/files/items/320.png")
--
local item5 = dxCreateTexture(":sas_items/files/items/331.png")
local item6 = dxCreateTexture(":sas_items/files/items/332.png")
--
local item7 = dxCreateTexture(":sas_items/files/items/325.png")
local item8 = dxCreateTexture(":sas_items/files/items/326.png")
local item9 = dxCreateTexture(":sas_items/files/items/323.png")
local item10 = dxCreateTexture(":sas_items/files/items/324.png")
--
local item11 = dxCreateTexture(":sas_items/files/items/327.png")
local item12 = dxCreateTexture(":sas_items/files/items/328.png")
local item13 = dxCreateTexture(":sas_items/files/items/329.png")
local item14 = dxCreateTexture(":sas_items/files/items/330.png")

function drawItemsToCrates()
	-- erstes Block
	dxDrawMaterialLine3D(-897.21405029297-0.15-0.05, 1808.3531494141-0.60, 2.3078124523163+1.2, -897.21405029297-0.15-0.05, 1808.3531494141-0.60, 2.3078124523163+1, item1, 0.2, tocolor(255,255,255,255),-898.22827148438, 1825, 3.0804998874664)
	dxDrawMaterialLine3D(-897.21405029297-0.55, 1808.3531494141-0.61, 2.3078124523163+1.2, -897.21405029297-0.55, 1808.3531494141-0.61, 2.3078124523163+1, item2, 0.2, tocolor(255,255,255,255),-898.22827148438, 1825, 3.0804998874664)
	dxDrawMaterialLine3D(-897.21405029297-1.1, 1808.3531494141-0.61, 2.3078124523163+1.2, -897.21405029297-1.1, 1808.3531494141-0.61, 2.3078124523163+1, item3, 0.2, tocolor(255,255,255,255),-898.22827148438, 1825, 3.0804998874664)
	dxDrawMaterialLine3D(-897.21405029297-1.4, 1808.3531494141-0.61, 2.3078124523163+1.2, -897.21405029297-1.4, 1808.3531494141-0.61, 2.3078124523163+1, item4, 0.2, tocolor(255,255,255,255),-898.22827148438, 1825, 3.0804998874664)
	-- zweites Block
	dxDrawMaterialLine3D(-897.21405029297-1.3, 1808.3531494141+11.6, 2.3078124523163+1.2, -897.21405029297-1.3, 1808.3531494141+11.6, 2.3078124523163+1, item5, 0.2, tocolor(255,255,255,255),-897.98541259766, 1800, 3.0775001049042)
	dxDrawMaterialLine3D(-897.21405029297-1.3+0.3, 1808.3531494141+11.6, 2.3078124523163+1.2, -897.21405029297-1.3+0.3, 1808.3531494141+11.6, 2.3078124523163+1, item6, 0.2, tocolor(255,255,255,255),-897.98541259766, 1800, 3.0775001049042)
	-- drittes Block
	dxDrawMaterialLine3D(-897.21405029297-0.15-8.5-0.05, 1808.3531494141-0.61, 2.3078124523163+1.2, -897.21405029297-0.15-8.5-0.05, 1808.3531494141-0.61, 2.3078124523163+1, item7, 0.2, tocolor(255,255,255,255),-906, 1817.9134521484, 3.2730000019073)
	dxDrawMaterialLine3D(-897.21405029297-0.55-8.5, 1808.3531494141-0.61, 2.3078124523163+1.2, -897.21405029297-0.55-8.5, 1808.3531494141-0.61, 2.3078124523163+1, item8, 0.2, tocolor(255,255,255,255),-906.705078125, 1817.9134521484, 3.2730000019073)
	dxDrawMaterialLine3D(-897.21405029297-1.1-8.5, 1808.3531494141-0.61, 2.3078124523163+1.2, -897.21405029297-1.1-8.5, 1808.3531494141-0.61, 2.3078124523163+1, item9, 0.2, tocolor(255,255,255,255),-906.705078125, 1817.9134521484, 3.2730000019073)
	dxDrawMaterialLine3D(-897.21405029297-1.4-8.5, 1808.3531494141-0.61, 2.3078124523163+1.2, -897.21405029297-1.4-8.5, 1808.3531494141-0.61, 2.3078124523163+1, item10, 0.2, tocolor(255,255,255,255),-906.705078125, 1817.9134521484, 3.2730000019073)
	-- viertes Block
	dxDrawMaterialLine3D(-897.21405029297-1.3-8.5, 1808.3531494141+11.6, 2.3078124523163+1.2, -897.21405029297-1.3-8.5, 1808.3531494141+11.6, 2.3078124523163+1, item11, 0.2, tocolor(255,255,255,255),-907.12762451172, 1811.8981933594, 3.2158000469208)
	dxDrawMaterialLine3D(-897.21405029297-1.3+0.3-8.5, 1808.3531494141+11.6, 2.3078124523163+1.2, -897.21405029297-1.3+0.3-8.5, 1808.3531494141+11.6, 2.3078124523163+1, item12, 0.2, tocolor(255,255,255,255),-907.12762451172, 1811.8981933594, 3.2158000469208)
	dxDrawMaterialLine3D(-897.21405029297-1.3-8.5+0.8, 1808.3531494141+11.6, 2.3078124523163+1.2, -897.21405029297-1.3-8.5+0.8, 1808.3531494141+11.6, 2.3078124523163+1, item13, 0.2, tocolor(255,255,255,255),-905.93572998047, 1814.5289306641, 2.3078124523163)
	dxDrawMaterialLine3D(-897.21405029297-1.3+0.3-8.5+0.8, 1808.3531494141+11.6, 2.3078124523163+1.2, -897.21405029297-1.3+0.3-8.5+0.8, 1808.3531494141+11.6, 2.3078124523163+1, item14, 0.2, tocolor(255,255,255,255),-905.93572998047, 1814.5289306641, 2.3078124523163)
end

--[[
local cucc = createObject(2567, -899.51678466797, 1812.5797119141, 2.3078124523163)
setElementDimension(cucc, 36)
setElementInterior(cucc, 17)
]]

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

function radarKeret(x, y, sz, m, vastagsag,r,g,b, alpha)
	if not alpha then
		alpha = 255
	end
	dxDrawRectangle ( x, y-vastagsag, sz+10, vastagsag+10, tocolor(r,g,b,alpha) ) -- Felso
	dxDrawRectangle ( x-vastagsag, y-vastagsag, vastagsag+10, m+(vastagsag*2), tocolor(r,g,b,alpha) ) -- Bal
	dxDrawRectangle ( x+sz, y-vastagsag, vastagsag+10, m+(vastagsag*2)+10, tocolor(r,g,b,alpha) ) -- Jobb
	dxDrawRectangle ( x-20, y+m, sz+20, vastagsag+10, tocolor(r,g,b,alpha) ) -- Also
end

function giveItem(itemID, value, count, duty)
	triggerServerEvent("giveItem", localPlayer, localPlayer, itemID, value, count, duty)
end