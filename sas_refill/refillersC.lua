local sX, sY = guiGetScreenSize()

hitted_vehicle_fuel_point = false
hitted_vehicle = false
vehicle_fuel = 0

local font = dxCreateFont("fonts/Roboto.ttf", 12)
local payFont = dxCreateFont("fonts/ThermalPrinter.ttf", 8)
local counter = dxCreateFont("fonts/counter.ttf", 20)
local handFont = dxCreateFont("fonts/lunabar.ttf", 22)

local circle_texture = dxCreateTexture("images/circle.png")
local animate_circle = true
local circle_anim = 0.5
local distance_vehicle = nil
local picked_pump = nil
local fuelfull = false

local start_refilling = false
local tanked_liters_prog = 0
local tanked_liters = 0
local tanked_liters2 = 0
local start_refilling2 = false
local drawFuelAnimation = false
local effect = {}
local loadingWidth = 0
local payDraw = false
local handWriting = false
local handWritingWidth = 0
local price = 5 -- dollar

local handWritingTick = 0
local tankingTick = 0

local refill_lines = {
	-- x, y, z, +linex, +liney, +linez, +markerx, +markery, +markerz, fuelpointused, +facingtowardx, +facingtowardy, +facingtowardz, +textX, +textX3d
	{1941.2,-1773.37,13.390598297119, 0,0,0,0,0,0,false,20,0,1,0},
	{1941.2,-1779.11,13.390598297119, 0,0,0,0,0,0,false,20,0,1,0},
	{1941.2, -1767.56, 13.390598297119, 0,0,0,0,0,0,false,20,0,1,0},
	{1940.55, -1767.56, 13.3828125, 0,0,0,0.6,0,0,false,-2.3,0,-1,0.24},
	{1940.55, -1773.374, 13.3828125, 0,0,0,0.6,0,0,false,-2.3,0,-1,0.24},
	{1940.55, -1779.11, 13.3828125, 0,0,0,0.6,0,0,false,-2.3,0,-1,0.24},
}

local refillMarkers = {}

local colshape = createColCuboid(1925, -1789.9814453125, 12.6, 32, 33, 5)

payPed = createPed(7, 1926.2216796875, -1781.537109375, 13.5859375)
setElementFrozen(payPed, true)
setElementData(payPed,"nameEnabled", true)
setElementData(payPed,"tagName", "NPC")
setElementData(payPed,"visiblePedName", "Ted Hower")
setElementData(payPed,"payPed", true)

addEventHandler("onClientColShapeHit", resourceRoot, function(theElement)
	if theElement ~= localPlayer or source ~= colshape then return end
	addEventHandler("onClientRender", getRootElement(), onRender)
	addEventHandler("onClientRender", getRootElement(), paymentDraw)
	addEventHandler("onClientRender", getRootElement(), drawTickCount)
	addEventHandler("onClientRender", getRootElement(), fillWithCan)
	addEventHandler("onClientKey", getRootElement(), playerPressedKey)
	addEventHandler("onClientClick", getRootElement(), handleClick)
	addEventHandler("onClientMarkerHit", getRootElement(), markerHitHandler)
	addEventHandler("onClientMarkerLeave", getRootElement(), markerLeaveHandler)
end)

addEventHandler("onClientColShapeLeave", resourceRoot, function(theElement)
	if theElement ~= localPlayer or source ~= colshape then return end
	removeEventHandler("onClientRender", getRootElement(), onRender)
	removeEventHandler("onClientRender", getRootElement(), paymentDraw)
	removeEventHandler("onClientRender", getRootElement(), drawTickCount)
	removeEventHandler("onClientRender", getRootElement(), fillWithCan)
	removeEventHandler("onClientKey", getRootElement(), playerPressedKey)
	removeEventHandler("onClientClick", getRootElement(), handleClick)
	removeEventHandler("onClientMarkerHit", getRootElement(), markerHitHandler)
	removeEventHandler("onClientMarkerLeave", getRootElement(), markerLeaveHandler)
end)

addEventHandler("onClientPedDamage",  getRootElement(), function()
	if getElementData(source, "payPed") then
		cancelEvent()
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
	if fileExists("models/pisztoly.txd") then
		txd = engineLoadTXD("models/pisztoly.txd", 14463 )
		engineImportTXD(txd, 14463)
	end

	if fileExists("models/pisztoly.dff") then
	  dff = engineLoadDFF("models/pisztoly.dff", 14463 )
	  engineReplaceModel(dff, 14463)
	end
end)

setElementData(localPlayer, "Fuel->usingRefiller", false)

local refillerLines = {}

function loadRefillerLines()
	for k, v in ipairs(getElementsByType("object")) do
		if getElementData(v, "Fuel->isRefiller") then
			local data = getElementData(v, "Fuel->isRefiller")
			refillerLines[k] = v
			local startX, startY, startZ = getElementPosition(v)
			--refillerLines[k].secondPos = {startX, startY, startZ - 1.3}
		end
	end
	setTimer(function()
		for k, v in ipairs(refillerLines) do
			local x = getElementPosition(v[1])
			if math.ceil(v.def[1]) == math.ceil(x) then
				local startX, startY, startZ = getElementPosition(v[1])
				refillerLines[k] = v
				refillerLines[k].secondPos = {startX, startY, startZ - 1.3}
			end
		end
	end, 3000, 0)
end
setTimer(loadRefillerLines, 6000, 1)

function onRender()
	if getElementData(localPlayer, "Fuel->usingRefiller") then
		if getDistanceFromElement(localPlayer, selectedPoint) > 4.5 then
			triggerServerEvent("Fuel->getBackRefiller", localPlayer, selectedPointK)
		end
	end
	if start_refilling then
		tanked_liters_prog = tanked_liters_prog + 1
		if tanked_liters_prog == 3 then
			tanked_liters = tanked_liters + 0.1
			if (getElementData(hitted_vehicle, "fuel")+tanked_liters) >= 100 then
				--outputChatBox("A jármű tankja sikeresen megtelt!","car")
				exports.sas_hud:addNotification("A jármű tankja megtelt.", "success")
				start_refilling = false
				fuelfull = true
				tanked_liters_prog = 0
				triggerServerEvent("Fuel->open_animation", localPlayer, "start")
				playSound("sounds/tankfull.mp3")
				secondAnimationTimer = setTimer(function()
					triggerServerEvent("Fuel->open_animation", localPlayer, "stop")
				end, 2000, 1)
				hitted_vehicle_fuel_point = false
				vehicle_fuel = 0
				return
			end
			tanked_liters_prog = 0
		end
	end
	if start_refilling2 then
		tanked_liters_prog = tanked_liters_prog + 1
		if tanked_liters_prog == 3 then
			tanked_liters2 = tanked_liters2 + 0.1
			tanked_liters_prog = 0
		end
	end
	if hitted_vehicle_fuel_point and getElementData(localPlayer, "Fuel->usingRefiller") then
		vehicle_fuel = getElementData(hitted_vehicle, "fuel")
	end
	local i = 1
	for k, v in ipairs(getElementsByType("object"), getRootElement(), true) do
		if getElementData(v, "Fuel->isRefiller") then
			startX, startY, startZ = getElementPosition(v)
			endX, endY, endZ = refill_lines[i][1]-0.3+refill_lines[i][7],refill_lines[i][2]+refill_lines[i][8],refill_lines[i][3]-0.8+refill_lines[i][9]
			dxDrawLine3D(startX, startY, startZ, endX, endY, endZ, tocolor(0, 0, 0, 255), 1.5)
			i = i +1
		end
	end
	local markerText = ""
	for k,v in ipairs(refillMarkers) do
		if isElementWithinColShape(localPlayer,refillMarkers[k]) then
			dxDrawRectangle(sX/2-515/2, sY-150, 515, 50, tocolor(0,0,0,150))
			dxDrawRectangle(sX/2-515/2, sY-150+50, 515, 2, tocolor(124, 197, 118,255))
			if not getElementData(localPlayer, "Fuel->usingRefiller") then
				markerText = "Használd az E betűt a pisztoly kivételéhez."
			elseif getElementData(localPlayer, "Fuel->usingRefiller") then
				markerText = "Használd az E betűt a pisztoly visszarakásához."
			end
			dxDrawText(markerText, sX/2-515/2, sY-150, sX/2-515/2+515, sY-150+50, tocolor(255,255,255,255),1, font, "center", "center")
		end
	end
	if drawFuelAnimation then
		local now = getTickCount()
		local elapsedTime = now - tankingTick
		local progress = elapsedTime / 2000
		loadingWidth, _, _ = interpolateBetween(
			0,0,0,
			410,0,0,
			progress, "Linear"
		)
		if loadingWidth >= 410 then
			drawFuelAnimation = false
		end
		exports.sas_system:radarKeret(sX/2-415/2, sY-150, 415, 35, 2)
		dxDrawRectangle(sX/2-415/2, sY-150, 415, 35, tocolor(60, 106, 56, 180))
		dxDrawRectangle(sX/2-415/2, sY-150, loadingWidth, 35, tocolor(124, 197, 118, 255))
		dxDrawText("Tankolás megkezdése...", sX/2-415/2, sY-150, sX/2-415/2+415, sY-150+35, tocolor(0,0,0,255),1, font, "center", "center")
	end
	--
	if getElementData(localPlayer, "Fuel->usingRefiller") then
		for k, v in ipairs(getElementsByType("vehicle"), getRootElement(), true) do
			if getElementDimension(v) == getElementDimension(localPlayer) then
				if getDistanceFromElement(localPlayer, v) <= 4 then
					if getElementData(v, "Veh->fuelPos") then
						local posX, posY, posZ = getElementPosition(getElementData(v, "Veh->fuelPos"))
						local posZ_Veh = getGroundPosition(posX, posY, posZ) + 1 + 0.02
						local r, g, b = 255, 255, 255
						local sX, sY = getScreenFromWorldPosition(posX-0.1, posY, posZ + 1)
						if hitted_vehicle_fuel_point then
							r, g, b = 124, 197, 118
						end
						dxDrawMaterialLine3D (posX - 0.45, posY, posZ_Veh - 1, posX + 0.45, posY, posZ_Veh - 1, circle_texture, 0.45 * 2, tocolor(r, g, b, 200), posX, posY, posZ)
						if sX and sY then
							dxDrawImage(sX - 50/2, sY - 50/2, 128, 128, "images/fuel.png",0,0,0,tocolor(r,g,b,150))
						end
						--dxDrawMaterialLine3D (posX - 0.45, posY, posZ_Veh +1, posX + 0.45, posY, posZ_Veh+1 , fuel_texture, 0.45 * 2, tocolor(r, g, b, 200))
					end
				end
			end
		end
	end
end

for k = 1, 3 do
	refillMarkers[k] = createColCuboid(refill_lines[k][1]+refill_lines[k][4] - 0.25, refill_lines[k][2]+refill_lines[k][5] - 0.5, refill_lines[k][3]+refill_lines[k][6] - 0.75, 1, 1, 1)
end

for k = 4, 6 do
	refillMarkers[k] = createColCuboid(refill_lines[k][1]+refill_lines[k][4] - 0.75, refill_lines[k][2]+refill_lines[k][5] - 0.5, refill_lines[k][3]+refill_lines[k][6] - 0.75, 1, 1, 1)
end

function playerPressedKey(button, press)
    if (press) and button == "e" then
		for k,v in ipairs(refillMarkers) do
			if isElementWithinColShape(localPlayer,refillMarkers[k]) then
				if tanked_liters == 0 then
					if not getElementData(localPlayer, "Fuel->usingRefiller") then
						selectedPoint = refillMarkers[k]
						selectedPointK = k
						refill_lines[k][10] = true
						triggerServerEvent("Fuel->pickDownRefiller", localPlayer, k, "diesel")
						toggleControl("fire", false)
						playSound("sounds/fuelpickupesoff.mp3")
					elseif getElementData(localPlayer, "Fuel->usingRefiller") then
						if (tanked_liters+tanked_liters2) == 0 then
							refill_lines[k][10] = false
						end
						triggerServerEvent("Fuel->getBackRefiller", localPlayer, k, "diesel")
						toggleControl("fire", true)
						playSound("sounds/fuelpickupesoff.mp3")
					end
				end
				if tanked_liters > 0 then
					if selectedPointK == k then
						if not getElementData(localPlayer, "Fuel->usingRefiller") then
							refill_lines[k][10] = true
							triggerServerEvent("Fuel->pickDownRefiller", localPlayer, k, "diesel")
							toggleControl("fire", false)
							playSound("sounds/fuelpickupesoff.mp3")
						elseif getElementData(localPlayer, "Fuel->usingRefiller") then
							triggerServerEvent("Fuel->getBackRefiller", localPlayer, k, "diesel")
							toggleControl("fire", true)
							playSound("sounds/fuelpickupesoff.mp3")
						end
					else
						exports.sas_hud:addNotification("Már van egy tartozásod az egyik kútnál.", "warning")
					end
				end
			end
		end
    end
end

local flood
bindKey("mouse1", "both", function(_, state)
	if hitted_vehicle_fuel_point and getElementData(localPlayer, "Fuel->usingRefiller") and not isElementWithinColShape(localPlayer, refillMarkers[selectedPointK]) then
		if state == "down" then
			if isTimer(flood) then return end
			flood = setTimer(function() end, 1000, 1)
			toggleControl("fire", false)
			if not getElementData(localPlayer, "Fuel->usingRefiller") then
				exports.sas_hud:addNotification("Szükséged lesz pisztolyra is a tankoláshoz!","info")

				return
			end
			if getVehicleEngineState(hitted_vehicle) then
				exports.sas_hud:addNotification("Csak álló motorral tudsz tankolni!","info")
				return
			end
			if (getElementData(hitted_vehicle, "fuel")+tanked_liters) == 100 then
				exports.sas_hud:addNotification("A jármű üzemanyagtankja tele van!","error")
				return
			end
			triggerServerEvent("Fuel->open_animation", localPlayer, "start")
			drawFuelAnimation = true
			tankingTick = getTickCount()
			openSound = playSound("sounds/fuelstart.mp3")
			secondAnimationTimer = setTimer(function()
				triggerServerEvent("Fuel->refill_animation", localPlayer, "start")
				--triggerServerEvent("syncPlayereffect", localPlayer, localPlayer, "create")
				fuelfillSound = playSound("sounds/fuelfill.mp3", true)
				drawFuelAnimation = false
				tankingTick = 0
				start_refilling = true
				tanked_liters_prog = 0
			end, 2000, 1)
		end
		if state == "up" then
			--triggerServerEvent("syncPlayereffect", localPlayer, localPlayer, "delete")
			if isTimer(secondAnimationTimer) then
				killTimer(secondAnimationTimer)
			end
			if isElement(fuelfillSound) then
				stopSound(fuelfillSound)
			end
			if loadingWidth > 280 then
				if not fuelfull then
					triggerServerEvent("Fuel->open_animation", localPlayer, "start")
					playSound("sounds/fuelover.mp3")
					secondAnimationTimer = setTimer(function()
						triggerServerEvent("Fuel->open_animation", localPlayer, "stop")
					end, 2000, 1)
				end
			else
				if not fuelfull then
					triggerServerEvent("Fuel->open_animation", localPlayer, "stop")
				end
			end
			start_refilling = false
			loadingWidth = 0
			tankingTick = 0
			drawFuelAnimation =false
				--toggleControl("fire", true)
		end
	elseif getElementData(localPlayer, "Fuel->usingRefiller") and not hitted_vehicle_fuel_point and not isElementWithinColShape(localPlayer, refillMarkers[selectedPointK]) then
		if state == "down" then
			if isTimer(flood) then return end
			flood = setTimer(function() end, 1000, 1)
			toggleControl("fire", false)
			triggerServerEvent("syncPlayereffect", localPlayer, localPlayer, "create")
			triggerServerEvent("Fuel->refill_animation", localPlayer, "start")
			fuelfillSound = playSound("sounds/fuelfill.mp3", true)
			start_refilling2 = true
		end
		if state == "up" then
			if isElement(fuelfillSound) then
				stopSound(fuelfillSound)
			end
			triggerServerEvent("syncPlayereffect", localPlayer, localPlayer, "delete")
			triggerServerEvent("Fuel->refill_animation", localPlayer, "stop")
			toggleControl("fire", true)
			start_refilling2 = false
		end
	end
end)

function paymentDraw()
	if getDistanceFromElement(localPlayer, payPed) > 2 then
		if not handWriting then
			payDraw = false
		end
	end
	if payDraw then
		local liters = math.round(tanked_liters + tanked_liters2)
		dxDrawImage(sX/2-150, sY/2-423/2, 300, 423, "images/deli.jpg")
		dxDrawText(liters.." L 5 $/L", sX/2-120, sY/2-60,0, 0, tocolor(0,0,0,255), 1, payFont)
		dxDrawText("00001", sX/2+50, sY/2+23-5,sX/2+130, sY/2+23, tocolor(0,0,0,255), 1, payFont, "right", "top")
		dxDrawText((liters*price).." $", sX/2+50, sY/2+40-5,sX/2+130, sY/2+23, tocolor(0,0,0,255), 1, payFont, "right", "top")
		dxDrawText((liters*price).." $", sX/2+50, sY/2+40+17-5,sX/2+130, sY/2+23, tocolor(0,0,0,255), 1, payFont, "right", "top")
		--dxDrawRectangle(sX/2-30+10, sY/2+145, 160, 40, tocolor(0,0,0,255))
		if handWriting then
			local now = getTickCount()
			local elapsedTime = now - handWritingTick
			local progress = elapsedTime / 3500
			handWritingWidth, _, _ = interpolateBetween(
				0,0,0,
				220,0,0,
				progress, "Linear"
			)
			if handWritingWidth >= 220 then
				triggerServerEvent("paymentComplete", localPlayer, liters*price)
				if tanked_liters > 0 then
					triggerServerEvent("addTankedFuelToVeh", localPlayer, hitted_vehicle, tanked_liters)
				end
				resetAllPayment()
			end
			dxDrawText(getPlayerName(localPlayer):gsub("_", " "),sX/2, sY/2+145+10,sX/2+handWritingWidth, sY/2+145+40+10 , tocolor(51, 204, 255,255), 1, handFont, "left", "center", true)

		end
	end
end

function resetAllPayment()
	payDraw = false
	handWriting = false
	handWritingWidth = 0
	tanked_liters = 0
	handWritingTick = 0
	tanked_liters2 = 0
	tanked_liters_prog = 0
	refill_lines[selectedPointK][10] = false
	fuelfull = false
	--hitted_vehicle = false
	if isElement(signSound) then
		stopSound(signSound)
	end
	exports.sas_hud:addNotification("Sikeres fizetés! A tankolt üzemanyag a kocsidba került!", "success")
end

function handleClick(button, state, x, y, wx, wy, wz, element)
	if button == "right" and state == "down" then
		if element and getElementData(element, "payPed") then
			local x, y, z = getElementPosition(getLocalPlayer())
			if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz) <= 5 then
				if tanked_liters > 0 then
					payDraw = true
				end
			end
		end
	elseif button == "left" and state == "down" then
			if payDraw then
				if isInSlot(sX/2-30+10, sY/2+145, 160, 40) then
					handWritingTick = getTickCount()
					handWriting = true
					signSound = playSound("sounds/sign.mp3", true)
				end
			end
	end
end

function math.round(number)
    local _, decimals = math.modf(number)
    if decimals < 0.5 then return math.floor(number) end
    return math.ceil(number)
end

local renderTarget = dxCreateRenderTarget(500, 500, true)
local renderTarget2 = dxCreateRenderTarget(500, 500, true)
local startResTickCount = getTickCount()
function drawTickCount()
	dxSetRenderTarget(renderTarget, true)
	local liters = math.round(tanked_liters + tanked_liters2)
	dxDrawText((liters*price).." $", 0, 5, 370, 500, tocolor(255,255,255,255), 1, counter, "right", "center", false, false, false, true, false)
	dxDrawText(liters.." L", 160, 160, 370, 500, tocolor(255,255,255,255), 1, counter, "right", "center", false, false, false, true, false)
	dxDrawText(price.." $/L", -20, -20+40+375, 230, 370+45, tocolor(255,255,255,255), 1, counter, "right", "center", false, false, false, true, false)
	dxSetRenderTarget()

	dxSetRenderTarget(renderTarget2, true)
	dxDrawText("0 $", 0, 5, 370, 500, tocolor(255,255,255,255), 1, counter, "right", "center", false, false, false, true, false)
	dxDrawText("0 L", 160, 160, 370, 500, tocolor(255,255,255,255), 1, counter, "right", "center", false, false, false, true, false)
	dxDrawText(price.." $/L", -20, -20+40+375, 230, 370+45, tocolor(255,255,255,255), 1, counter, "right", "center", false, false, false, true, false)
	dxSetRenderTarget()
	for k,v in ipairs(refill_lines) do
		if refill_lines[k][10] then

			dxDrawMaterialLine3D(refill_lines[k][1]-0.1+refill_lines[k][14], refill_lines[k][2]-0.08, refill_lines[k][3]+1.6,refill_lines[k][1]-0.1+refill_lines[k][14], refill_lines[k][2]-0.08, refill_lines[k][3]+1.6-0.8, renderTarget, 0.8, tocolor(255,255,255,255), refill_lines[k][1]+refill_lines[k][11], refill_lines[k][2]+refill_lines[k][12], refill_lines[k][3]+refill_lines[k][13])
		else
			dxDrawMaterialLine3D(refill_lines[k][1]-0.1+refill_lines[k][14], refill_lines[k][2]-0.08, refill_lines[k][3]+1.6,refill_lines[k][1]-0.1+refill_lines[k][14], refill_lines[k][2]-0.08, refill_lines[k][3]+1.6-0.8, renderTarget2, 0.8, tocolor(255,255,255,255), refill_lines[k][1]+refill_lines[k][11], refill_lines[k][2]+refill_lines[k][12], refill_lines[k][3]+refill_lines[k][13])
		end
	end
end

function createEffects(player, state, pisztoly )
	if state == "delete" then
		if isElement(effect[player]) then
			destroyElement(effect[player])
		end
	else
		local rotx, roty, rotz = getElementRotation(player)
		local playerX, playerY, playerZ = getPedBonePosition(localPlayer, 12)
		effect[player] = createEffect("petrolcan", playerX, playerY, playerZ, 0, 0, 0)
		exports.bone_attach:attachElementToBone(effect[player], player , 12, -0.1,0.05, 0.30, rotx, roty, 2*rotz*math.pi/360)
	end
end
addEvent("createEffectstoClient", true)
addEventHandler("createEffectstoClient", root, createEffects)

function markerHitHandler(hitElement)
	if hitElement ~= localPlayer then return end
	if (getElementData(source, "Fuel->tankMarker") and getElementData(localPlayer, "Fuel->usingRefiller")) or getElementData(localPlayer, "handCan") then
		hitted_vehicle_fuel_point = source
		hitted_vehicle = getElementData(source, "Fuel->tankMarker")
		toggleControl("fire", false)
	end
end

function markerLeaveHandler(hitElement)
	if hitElement ~= localPlayer then return end
	if getElementData(source, "Fuel->tankMarker") then
		hitted_vehicle_fuel_point = false
	end
end



local tanked_liters_can = 0
local tanked_liters_can_progress = 0
local startFillWithCan = false

function fillWithCan()
	if startFillWithCan then
		tanked_liters_can_progress = tanked_liters_can_progress + 1
		if tanked_liters_can_progress == 3 then

			tanked_liters_can = tanked_liters_can + 0.1

			if (getElementData(hitted_vehicle, "fuel")+tanked_liters_can) == 100 then
				exports.sas_hud:addNotification("A jármű tankja megtelt.", "success")
				startFillWithCan = false
				fuelfull = true
				tanked_liters_can_progress = 0
				triggerServerEvent("Fuel->open_animation", localPlayer, "start")
				playSound("sounds/tankfull.mp3")
				secondAnimationTimer = setTimer(function()
					triggerServerEvent("Fuel->open_animation", localPlayer, "stop")
				end, 2000, 1)
			--	toggleControl("fire", true)
				hitted_vehicle_fuel_point = false
				--hitted_vehicle = false
				vehicle_fuel = 0
				return
			end
			if tanked_liters_can >= 10 then
				startFillWithCan = false
				tanked_liters_can_progress = 0
				triggerServerEvent("Fuel->open_animation", localPlayer, "start")
				playSound("sounds/tankfull.mp3")
				secondAnimationTimer = setTimer(function()
					triggerServerEvent("Fuel->open_animation", localPlayer, "stop")
					triggerServerEvent("addTankedFuelToVeh", localPlayer, hitted_vehicle, tanked_liters_can)
					tanked_liters_can = 0
					setElementData(localPlayer, "handCan", false)
				end, 2000, 1)
				hitted_vehicle_fuel_point = false
				vehicle_fuel = 0
				return
			end
			tanked_liters_can_progress = 0
		end
	end
	if getElementData(localPlayer, "handCan") and hitted_vehicle_fuel_point then
		vehicle_fuel = getElementData(hitted_vehicle, "fuel")
	end
	if drawFuelAnimation then
		local now = getTickCount()
		local elapsedTime = now - tankingTick
		local progress = elapsedTime / 2000
		loadingWidth, _, _ = interpolateBetween(
			0,0,0,
			410,0,0,
			progress, "Linear"
		)
		if loadingWidth >= 410 then
			drawFuelAnimation = false
		end
		exports.sas_system:radarKeret(sX/2-415/2, sY-150, 415, 35, 2)
		dxDrawRectangle(sX/2-415/2, sY-150, 415, 35, tocolor(60, 106, 56, 180))
		dxDrawRectangle(sX/2-415/2, sY-150, loadingWidth, 35, tocolor(124, 197, 118, 255))
		dxDrawText("Tankolás megkezdése...", sX/2-415/2, sY-150, sX/2-415/2+415, sY-150+35, tocolor(0,0,0,255),1, font, "center", "center")

	end
	--
	if getElementData(localPlayer, "handCan") then
		for k, v in ipairs(getElementsByType("vehicle"), getRootElement(), true) do
			if getElementDimension(v) == getElementDimension(localPlayer) then
				if getDistanceFromElement(localPlayer, v) <= 4 then
					local posX, posY, posZ = getElementPosition(getElementData(v, "Veh->fuelPos"))
					local posZ_Veh = getGroundPosition(posX, posY, posZ) + 1 + 0.02
					local r, g, b = 255, 255, 255
					local sX, sY = getScreenFromWorldPosition(posX-0.1, posY, posZ + 1)
					if hitted_vehicle_fuel_point then
						r, g, b = 124, 197, 118
					end
					dxDrawMaterialLine3D (posX - 0.45, posY, posZ_Veh - 1, posX + 0.45, posY, posZ_Veh - 1, circle_texture, 0.45 * 2, tocolor(r, g, b, 200), posX, posY, posZ)
					if sX and sY then
						dxDrawImage(sX - 50/2, sY - 50/2, 128, 128, "images/fuel.png",0,0,0,tocolor(r,g,b,150))
					end
				end
			end
		end
	end
end

bindKey("mouse1", "both", function(_, state)
	if hitted_vehicle_fuel_point and getElementData(localPlayer, "handCan") then
		if state == "down" then
			if isTimer(flood) then return end
			flood = setTimer(function() end, 1000, 1)
			toggleControl("fire", false)
			if getVehicleEngineState(hitted_vehicle) then
				exports.sas_hud:addNotification("Csak álló motorral tudsz tankolni!","info")
				return
			end
			if (getElementData(hitted_vehicle, "fuel")+tanked_liters_can) == 100 then
				exports.sas_hud:addNotification("A jármű üzemanyagtankja tele van!","error")
				return
			end
			triggerServerEvent("Fuel->open_animation", localPlayer, "start")

			drawFuelAnimation = true
			tankingTick = getTickCount()
			openSound = playSound("sounds/fuelstart.mp3")
			secondAnimationTimer = setTimer(function()
			triggerServerEvent("Fuel->refill_animation", localPlayer, "start")

			drawFuelAnimation = false
			tankingTick = 0
			startFillWithCan = true
			tanked_liters_can_progress = 0

			end, 2000, 1)
		end
		if state == "up" then
			--triggerServerEvent("syncPlayereffect", localPlayer, localPlayer, "delete")
			--triggerEvent("takeCan",localPlayer,localPlayer)
			if isTimer(secondAnimationTimer) then
				killTimer(secondAnimationTimer)
			end
			stopSound(openSound)
			if loadingWidth > 280 then
				if not fuelfull then
					triggerServerEvent("Fuel->open_animation", localPlayer, "start")
					playSound("sounds/fuelover.mp3")
					secondAnimationTimer = setTimer(function()
						triggerServerEvent("Fuel->open_animation", localPlayer, "stop")
						setElementData(localPlayer, "handCan", false)
						triggerServerEvent("addTankedFuelToVeh", localPlayer, hitted_vehicle, tanked_liters_can)
						tanked_liters_can = 0
						tanked_liters_can_progress = 0
					end, 2000, 1)
				end
			else
				if not fuelfull then
					triggerServerEvent("Fuel->open_animation", localPlayer, "stop")
					--setElementData(localPlayer, "handCan", false)
				end
			end
			startFillWithCan = false
			loadingWidth = 0
			tankingTick = 0
			drawFuelAnimation =false
		end
	end
end)

-- ASSETS

removeWorldModel(7448, 999999, 0, 0, 0)
addEventHandler("onClientObjectBreak", getRootElement(), function()
	if getElementInterior(source) == 0 then
		cancelEvent()
	end
end)

function getDistanceFromElement(from, to)
	if not from or not to then return end
	local x, y, z = getElementPosition(from)
	local x1, y1, z1 = getElementPosition(to)
	return getDistanceBetweenPoints3D(x, y, z, x1, y1, z1)
end


function isInSlot(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(isInBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end
