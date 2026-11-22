
local kepernyom = {guiGetScreenSize()}
local sx,sy = guiGetScreenSize()
local panelSize = {300, 450}
local panelPosX, panelPosY = kepernyom[1]/2-panelSize[1]/2, kepernyom[2]/2-panelSize[2]/2
local font = dxCreateFont("files/Roboto.ttf",9)
local font2 = dxCreateFont("files/Roboto.ttf",10)

local roboto = dxCreateFont("files/Roboto.ttf",11)
local roboto2 = dxCreateFont("files/Roboto.ttf",11)

local autoFont = dxCreateFont("files/mesmerize.ttf",25)

local carposX, carposY, carposZ = 2129.236328125, -1147.71875, 1419.4497070313

local panelType = "CarShop"

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
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

local selectedColor = 7
local Jelenkocsi = 0

-- cam movement things
local cameraMoveable = false
local camMovement = "freemode"
local fpsX = 0
local fpsY = 0
-- cam movement things

local color = {--Szín ,Összeg
 {228,119,25,50},
 {107, 165, 180,50},
 {5,81,164,50},
 {10,163,78,50},
 {197,19,23,50},
 {116,3,1,50},
 {255,255,255,50},
 {108,108,108,50},
 {0,0,0,50},
}

if fileExists("sourceC.lua") then
	fileDelete("sourceC.lua")
end


local create = false

local pickup = createPickup(2131.7783203125, -1151.0703125, 24.087491989136,3, 1239)

function pickupHit(element)
	if element ~= localPlayer then return end
	if getPedOccupiedVehicle(element) then return end
	if not create then
		fadeCamera(false)
		setElementFrozen(localPlayer, true)
		setTimer(function()
			fadeCamera(true, 0)
			--backgroundmusic = playSound("files/showroom.mp3", true)
			addEventHandler("onClientRender", root, createCarshopPanel)
			create = true
			showChat(false)
			setElementData(localPlayer, "enableall", false)

			--showCursor(true)
			setElementDimension(localPlayer, getElementData(localPlayer, "dbid"))

			showroom = createObject(16642,2131.82421875, -1147.75, 1418.4497070313)
			setElementDimension(showroom, getElementData(localPlayer, "dbid"))


			createVehicleFunction ()
			updateCamPosition(true)
		end, 1000, 1)
		--addEventHandler ("onClientPreRender",getRootElement(),updateCamPosition)
	end

end
addEventHandler("onClientPickupHit", pickup, pickupHit)

function onPedKatt(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if create and button == "left" and state == "down" and panelType == "CarShop" then
		for index, value in ipairs (color) do
			if dobozbaVan(sx-index*47, 160, 30, 30, absoluteX, absoluteY) then
				setVehicleColor(car, value[1], value[2], value[3])
				selectedColor = index
			end
		end
	elseif create and button == "left" and state == "down" and panelType == "Vasarlas" then
		if isInSlot(sx/2-225,sy/2-20,212.5,35) then
			if sellVehicle[Jelenkocsi][5] > 0 then
				if getVehicleLimits(sellVehicle[Jelenkocsi][1]) >= sellVehicle[Jelenkocsi][5] and sellVehicle[Jelenkocsi][5] > 0 then
					panelType = "CarShop"
					exports.sas_hud:addNotification("Ennek a járműnek megtelt a limitje!","error")
				elseif getVehicleLimits(sellVehicle[Jelenkocsi][1]) < sellVehicle[Jelenkocsi][5] or sellVehicle[Jelenkocsi][5] == 0 then
					local amount = sellVehicle[Jelenkocsi][3] + color[selectedColor][4]
					if getElementData(localPlayer, "money") >= amount then
						triggerServerEvent("buyVehicle", localPlayer, sellVehicle[Jelenkocsi][1], color[selectedColor][1], color[selectedColor][2], color[selectedColor][3], amount, Jelenkocsi)
					else
						exports.sas_hud:addNotification("Nincs elég pénzed!", "error")
					end
					panelType = "CarShop"
				end
			end
			if sellVehicle[Jelenkocsi][5] == -1 then
				local amount = sellVehicle[Jelenkocsi][3] + color[selectedColor][4]
				if getElementData(localPlayer, "money") >= amount then
					triggerServerEvent("buyVehicle", localPlayer, sellVehicle[Jelenkocsi][1], color[selectedColor][1], color[selectedColor][2], color[selectedColor][3], amount, Jelenkocsi)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!", "error")
				end
				panelType = "CarShop"
			end
		elseif isInSlot(sx/2+12.5,sy/2-20,212.5,35) then
			local pp = sellVehicle[Jelenkocsi][4] + color[selectedColor][4]
			if getElementData(localPlayer, "pp") >= pp then
				triggerServerEvent("buyVehiclePP", localPlayer, sellVehicle[Jelenkocsi][1], color[selectedColor][1], color[selectedColor][2], color[selectedColor][3], pp, Jelenkocsi)
			else
				exports.sas_hud:addNotification("Nincs elég PP-d!", "error")
			end
			panelType = "CarShop"
		end
		if isInSlot(sx/2-225,sy/2+30,450,35) then
			panelType = "CarShop"
		end
	end
end
addEventHandler("onClientClick", getRootElement(), onPedKatt)

addEvent("paymentCompleted",true)
addEventHandler("paymentCompleted",root,function()
	exports.sas_hud:addNotification("Sikeresen megvásároltad a kiválasztott járművet!","success")
	if isElement(car) then
		destroyElement(car)
	end
	fadeCamera(false)
	setTimer(function()
		removeEventHandler("onClientRender", root, createCarshopPanel)
		create = false
		showChat(true)
		setElementData(localPlayer, "enableall", true)
		--showCursor(false)
		updateCamPosition(false)
		panelType = "CarShop"
		fadeCamera(true)
	end, 1000, 1)
end)

function createVehicleFunction ()
	if isElement(car) then
		destroyElement(car)
	end
	Jelenkocsi = 1--math.random(1, #sellVehicle)
	car = createVehicle(sellVehicle[Jelenkocsi][1],carposX, carposY, carposZ)
	randomcolor = math.random(1, #color)
	setVehicleColor(car, color[7][1], color[7][2], color[7][3], 0, 0 ,0)
	setElementDimension(car, getElementData(localPlayer, "dbid"))
	setElementRotation(car, 0,0,1)
end
local textYplus = 0
local logoIndex = "gta-sa"
function createCarshopPanel ()
	--if panelType == "CarShop" then
	if not cameraMoveable and camMovement ~= "fps" then
		--	dxDrawImage(0, 0, 1920, 1080, "files/see.png")
			if sellVehicle[Jelenkocsi][6] then
				logoIndex = sellVehicle[Jelenkocsi][6]
			else
				logoIndex = "gta-sa"
			end
			dxDrawRectangle(0,0,sx,150,tocolor(0,0,0,200))
			dxDrawImage(0,10,128,128,"files/logos/"..logoIndex..".png")
			dxDrawText("AUTÓSZALON",148,0,sx,150,tocolor(255,255,255,255),1,autoFont,"left","center")
			dxDrawText("<",128,sy-130-25-20,sx,sy,tocolor(255,255,255,255),1,autoFont,"left")
			dxDrawText(">",sx-128,sy-130-25-20,sx,sy,tocolor(255,255,255,255),1,autoFont,"left")
			dxDrawRectangle(0,sy-100,sx,100,tocolor(0,0,0,200))


			dxDrawText(sellVehicle[Jelenkocsi][2],0,sy-130-25-20,sx,sy,tocolor(255,255,255,255),1.1,autoFont,"center")

			dxDrawText("Ár: "..penz_darabolas(sellVehicle[Jelenkocsi][3]).." $ vagy "..penz_darabolas(sellVehicle[Jelenkocsi][4]).." prémium pont",10,sy-95+textYplus,sx,sy,tocolor(255,255,255,255),1,roboto,"left")

			--dxDrawRectangle(sx-430,sy-80-20,435,42,tocolor(0,0,0,100))
			dxDrawText("Kilépés",0,sy-68-20,sx-10-15,sy,tocolor(255,255,255,255),1,roboto2,"right")
			dxDrawText("Navigáció",0,sy-68-20,sx-10-140-20,sy,tocolor(255,255,255,255),1,roboto2,"right")
			dxDrawText("Vásárlás",0,sy-68-20,sx-626+128,sy,tocolor(255,255,255,255),1,roboto2,"right")
			dxDrawText("Szabad kamera",0,sy-68-20,sx-355+20,0,tocolor(255,255,255,255),1,roboto2,"right")
			dxDrawImage(sx-145-20,sy-75-20,128,32,"files/keys/bcksp.png")
			dxDrawImage(sx-260-20,sy-75-20,32,32,"files/keys/right.png")
			dxDrawImage(sx-290-20-5,sy-75-20,32,32,"files/keys/left.png")
			dxDrawImage(sx-480,sy-75-20,32,32,"files/keys/q.png")
			dxDrawImage(sx-626,sy-75-20,128,32,"files/keys/enter.png")



			dxDrawRectangle(sx-430,150,430,50,tocolor(0,0,0,200))

			if sellVehicle[Jelenkocsi][5] > 0 then
				dxDrawText("Limit: "..getVehicleLimits(sellVehicle[Jelenkocsi][1]).."/"..sellVehicle[Jelenkocsi][5],10,sy-75,sx,sy,tocolor(255,255,255,255),1,roboto,"left")
				textYplus = 0
			elseif sellVehicle[Jelenkocsi][5] == 0 then
				dxDrawText("Limit: "..getVehicleLimits(sellVehicle[Jelenkocsi][1]).."/"..sellVehicle[Jelenkocsi][5],10,sy-75,sx,sy,tocolor(255,255,255,255),1,roboto,"left")
				textYplus = 0
			else
				textYplus = 10
			end
			for index, value in ipairs(color) do
			--	if isInSlot(sx-index*47, 150, 30, 30) then
				--	dxDrawRectangle(sx-index*35, 135, 32, 32, tocolor(value[1], value[2], value[3]))
				--else
					dxDrawRectangle(sx-index*47, 160, 30, 30, tocolor(value[1], value[2], value[3]))
			--	end
			end

			dxDrawText("Készpénz:\n"..penz_darabolas(getElementData(localPlayer,"money")).." $\nPrémium egyenleg:\n"..penz_darabolas(getElementData(localPlayer,"pp")).." PP",sx-180,35,sx,sy,tocolor(255,255,255,255),1,roboto,"left")

		if panelType == "Vasarlas" then

				dxDrawRectangle(sx/2-250,sy/2-75,500,150,tocolor(0,0,0,180))
				dxDrawText("#7cc576SeeMTA - #FF8C00Jármű vásárlás",sx/2-250,sy/2-95,500,150,tocolor(255,255,255,255),1,roboto2,"left","top",false,false,false,true)

			if isInSlot(sx/2-225,sy/2-20,212.5,35) then
				dxDrawRectangle(sx/2-225,sy/2-20,212.5,35,tocolor(51, 204, 255,180))
			else
				dxDrawRectangle(sx/2-225,sy/2-20,212.5,35,tocolor(124, 197, 118,180))
			end
			if isInSlot(sx/2+12.5,sy/2-20,212.5,35) then
				dxDrawRectangle(sx/2+12.5,sy/2-20,212.5,35,tocolor(51, 204, 255,180))
			else
				dxDrawRectangle(sx/2+12.5,sy/2-20,212.5,35,tocolor(124, 197, 118,180))
			end
			if isInSlot(sx/2-225,sy/2+30,450,35) then
				dxDrawRectangle(sx/2-225,sy/2+30,450,35,tocolor(51, 204, 255,180))
			else
				dxDrawRectangle(sx/2-225,sy/2+30,450,35,tocolor(122, 36, 45,180))
			end
			dxDrawText("Vásárlás [Dollár]",sx/2-225,sy/2-20,sx/2-225+212.5,sy/2-20+35,tocolor(0,0,0,255),1,roboto2,"center","center")
			dxDrawText("Vásárlás [Prémium Pont]",sx/2+12.5,sy/2-20,sx/2+12.5+212.5,sy/2-20+35,tocolor(0,0,0,255),1,roboto2,"center","center")
			dxDrawText("Mégsem",sx/2-225,sy/2+30,sx/2-225+450,sy/2+30+35,tocolor(0,0,0,255),1,roboto2,"center","center")
			dxDrawText("Biztosan megszeretnéd vásárolni a kiválasztott járművet?",sx/2,sy/2-50,sx/2,sy/2-50,tocolor(255,255,255,255),1.1,roboto2,"center","center")
		end
	end
end

function getVehicleLimits(vehicleID)
	local ammount = 0
	local breake = false
	for i, v in ipairs (getElementsByType("vehicle")) do
		if getElementModel(v) == vehicleID then
			ammount = ammount + 1
			if ammount > 1 then
				breake = true
			end
			if ammount == 1 and breake then
				break
			end
		end
	end
	ammount = ammount -1
	return ammount
end

function penz_darabolas(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
    if (k==0) then
      break
    end
  end
  return formatted
end

--killTimer(cameraTimer)
--updateCamPosition (true)

function updateCamPosition (turning)
	--setCameraMatrix (2131.8215332031, -1147.7175292969, 1419.2426757813, 2131.8215332031, -1047.7175292969, 1419.2426757813)
	if turning then
			fadeCamera(true)
			exports.sas_system:smoothMoveCamera(2123.3249511719, -1143.9187011719, 1419.943359375, 2210.2468261719, -1191.462890625, 1406.3743896484,2123.3173828125, -1145.7888183594, 1419.943359375, 2218.5229492188, -1171.9772949219, 1404.1306152344 ,6000)
			cameraTimer = setTimer(function()
				fadeCamera(false)
				cameraTimer = setTimer(function()
					fadeCamera(true)
					exports.sas_system:smoothMoveCamera(2129.1508789063, -1142.5146484375, 1421.7429199219, 2131.4328613281, -1227.7458496094, 1369.4893798828,2129.2783203125, -1147.0057373047, 1421.7438964844, 2131.5603027344, -1232.2369384766, 1369.490234375 ,6000)
					cameraTimer = setTimer(function()
						fadeCamera(false)
						cameraTimer = setTimer(function()
								fadeCamera(true)
								exports.sas_system:smoothMoveCamera(2128.1186523438, -1143.0627441406, 1419.3438720703, 2190.0141601563, -1219.6978759766, 1402.1395263672,2127.4304199219, -1143.5853271484, 1419.3436279297, 2206.6176757813, -1202.1297607422, 1401.9674072266 ,6000)
								cameraTimer = setTimer(function()
									fadeCamera(false)
									cameraTimer = setTimer(function()
										fadeCamera(true)
										exports.sas_system:smoothMoveCamera(2130.380859375, -1151.7014160156, 1419.6430664063, 2081.9938964844, -1068.2103271484, 1393.4146728516,2131.6828613281, -1151.5612792969, 1419.6435546875, 2055.6313476563, -1089.2926025391, 1401.2373046875 ,6000)
										cameraTimer = setTimer(function()
											fadeCamera(false)
											cameraTimer = setTimer(function()
												killTimer(cameraTimer)
												updateCamPosition (true)
											end, 1000, 1)
										end, 5000, 1)
									end, 1000, 1)
								end, 5000, 1)
						end, 1000, 1)
					end, 5000, 1)
				end, 1000, 1)
			end, 5000, 1)
	elseif not turning then
		exports.sas_system:stopSmoothMoveCamera()
		killTimer(cameraTimer)
		setElementPosition(localPlayer,2131.8981933594, -1148.7214355469, 24.346748352051)
		setElementDimension(localPlayer, 0)
		setElementFrozen(localPlayer, false)
		local x,y,z = getElementPosition(getLocalPlayer())
		setCameraMatrix(x,y,z,x,y,z)
		setCameraTarget(localPlayer, localPlayer)
		offtimer = setTimer(function()
			fadeCamera(true)
		end, 1000, 1)
	end
end
--[[
cameraTimer = setTimer(function()

end, 5000, 1)
]]

local stoped = false
local stop = false
addEventHandler("onClientKey", root, function(k,v)
	if not create then return end
	if k == "backspace" and v then
	--	killTimer(cameraTimer)
		if not cameraMoveable and camMovement ~= "fps" then
			if panelType == "CarShop" then
				fadeCamera(false)
				setTimer(function()
						if isElement(car) then
							destroyElement(car)
						end
						removeEventHandler("onClientRender", root, createCarshopPanel)
						create = false
						showChat(true)
						setElementData(localPlayer, "enableall", true)
						--selectedColor = 0
						--showCursor(false)
						updateCamPosition(false)
						panelType = "CarShop"
						stopSound(backgroundmusic)
						--outputChatBox("key")
				end, 1000, 1)
			else
				panelType = "CarShop"
			end
		end
	if isTimer(timer) then return end
	timer = setTimer(function() end, 300, 1)
	elseif k == "arrow_l" and not stoped and panelType == "CarShop" then
		if not cameraMoveable and camMovement ~= "fps" then
			--outputChatBox(Jelenkocsi)
			fadeCamera(false)
			stoped = true
			setTimer(function()
				if Jelenkocsi > 1 then
					Jelenkocsi = Jelenkocsi - 1
				else
					Jelenkocsi = 1
				end
				setElementModel(car, sellVehicle[Jelenkocsi][1])
				--fadeCamera(true)
				exports.sas_system:stopSmoothMoveCamera()
				killTimer(cameraTimer)
				updateCamPosition (true)
				setTimer(function()
					stoped = false
				end, 1000, 1)
			end , 1000, 1 )
		end
	elseif k == "arrow_r" and not stoped and panelType == "CarShop" then
		if not cameraMoveable and camMovement ~= "fps" then
			fadeCamera(false)
			stoped = true
			setTimer(function()
				if Jelenkocsi < #sellVehicle then
					Jelenkocsi = Jelenkocsi + 1
				else
					Jelenkocsi = 1
				end
				setElementModel(car, sellVehicle[Jelenkocsi][1])
				--fadeCamera(true)
					exports.sas_system:stopSmoothMoveCamera()
					killTimer(cameraTimer)
					updateCamPosition (true)
					setTimer(function()
	    			stoped = false
					end, 1000, 1)
				end , 1000, 1 )
		end
	elseif k == "enter" and not cameraMoveable and camMovement ~= "fps" then
		--outputChatBox(selectedColor)
		if panelType == "CarShop" then
			if selectedColor > 0 then
				panelType = "Vasarlas"
			end
		end
	elseif k == "q" and v and panelType == "CarShop" then
	---	if camMovement ~= "fps" and cameraMoveable then
		--	updateCamPosition(true)
		--	cameraMoveable = false
		--	camMovement = ""
		--else
		if camMovement ~= "fps" then
				if not cameraMoveable then
					exports.sas_system:stopSmoothMoveCamera()
				--	if isElement(cameraTimer) then
					playSound("files/cammove.mp3")
					killTimer(cameraTimer)
				--	end
					--updateCamPosition(false)
					cameraMoveable = true
					camMovement = "freemode"
				elseif cameraMoveable then
					playSound("files/cammove.mp3")
					updateCamPosition(true)
					cameraMoveable = false
					camMovement = ""
					for i = 0, 5 do
						setVehicleDoorOpenRatio(car, i, 0)
					end
					setVehicleOverrideLights(car, 1)
				end
		end
	elseif k == "l" and v and cameraMoveable and camMovement ~= "fps" then
		playSound("files/lightswitch.mp3")
		local lights = getVehicleOverrideLights(car)
		if (lights~=2) then
				setVehicleOverrideLights(car, 2)
		elseif (lights~=1) then
				setVehicleOverrideLights(car, 1)
		end
	end

end)

-- custom cameraMovement


addEventHandler ( "onClientRender", root,
function()
	if camMovement == "fps" and not cameraMoveable then
		dxDrawText("A #d9534fvisszalépéshez #FFFFFFnyomd meg az #7cc576[E] #FFFFFFgombot.",0,sy-100,sx,0,tocolor(255,255,255,255),1,roboto2,"center", "top",false,false,false,true)
	end
	if cameraMoveable then
		--dxDrawImage(0, 0, 1920, 1080, "files/see.png")
		dxDrawRectangle(sx-600, sy-100, 600, 50, tocolor(0,0,0,200))

		dxDrawImage(sx-593-2,sy-90-2,32,32,"files/keys/q.png")
	  local kamX = dxGetTextWidth("Cinematic kamera", 1, roboto2)
		dxDrawText("Cinematic kamera",0,sy-100,sx-593+32+5+kamX,sy-100+50,tocolor(255,255,255,255),1,roboto2,"right", "center")

		dxDrawImage(sx-405,sy-90-2,32,32,"files/keys/w.png")
		dxDrawImage(sx-405+37,sy-90-2,32,32,"files/keys/a.png")
		dxDrawImage(sx-405+37+37,sy-90-2,32,32,"files/keys/s.png")
		dxDrawImage(sx-405+37+37+37,sy-90-2,32,32,"files/keys/d.png")

		local kamX2 = dxGetTextWidth("Kamera mozgás", 1, roboto2)
		dxDrawText("Kamera mozgás",0,sy-100,sx-405+37+37+37+37+5+kamX2,sy-100+50,tocolor(255,255,255,255),1,roboto2,"right", "center")

		dxDrawImage(sx-125,sy-90-2,32,32,"files/keys/e.png")
		local kamX3 = dxGetTextWidth("Interakció", 1, roboto2)
		dxDrawText("Interakció",0,sy-100,sx-125+37+kamX3,sy-100+50,tocolor(255,255,255,255),1,roboto2,"right", "center")


		for v in pairs ( getVehicleComponents(car) ) do
			if v == "door_lf_dummy" or v == "door_rf_dummy" or v == "door_rf_dummy" or v == "door_lr_dummy" or v == "boot_dummy" or v == "bonnet_dummy" then
					local x,y,z = getVehicleComponentPosition ( car, v, "world" )
					local wx,wy,wz = getScreenFromWorldPosition ( x, y, z )
					if wx and wy then
						if dobozbaVan(wx-10, wy-10, 20, 20, sx/2, sy/2) then
							dxDrawImage(wx-75, wy-75, 150, 150, "files/hover.png", 0,0,0)
						else
							dxDrawImage(wx-75, wy-75, 150, 150, "files/circle.png", 0,0,0)
						end
						if v == "door_lf_dummy" then
							if getVehicleDoorOpenRatio ( car, 2 ) == 1 then
								if dobozbaVan(wx+65, wy-10, 20,20, sx/2, sy/2) then
									dxDrawImage(wx, wy-75, 150, 150, "files/hover.png", 0,0,0)
								else
									dxDrawImage(wx, wy-75, 150, 150, "files/circle.png", 0,0,0)
								--dxDrawRectangle(wx+65, wy-10, 20,20)
								end
							end
						end
					end
				end
			end
		end
end)

local _, _, vehicleRotation = 0,0,1
local cameraRotation = vehicleRotation + 60


			cameraSettings = {
				["distance"] = 9,
				["movingSpeed"] = 2,
				["currentX"] = math.rad(cameraRotation),
				["defaultX"] = math.rad(cameraRotation),
				["currentY"] = math.rad(cameraRotation),
				["currentZ"] = math.rad(15),
				["maximumZ"] = math.rad(35),
				["minimumZ"] = math.rad(0),
				["freeModeActive"] = false,
				["zoomTick"] = 0,
				["zoom"] = 60
			}

local nyitasTiltas = false
local differentX, differentY = 0, 0

function kattint( button, press )
	if create then
				if button == "e" and press and camMovement == "fps" then
						fadeCamera(false)
						setTimer(function()
							fadeCamera(true)
							camMovement = "freemode"
							cameraMoveable = true
							destroyElement(utas)
						end, 1000, 1)
				end
				if button == "e" and press and not nyitasTiltas and camMovement == "freemode" then
				--	outputChatBox("e-t nyom")
					for v in pairs ( getVehicleComponents(car) ) do
						if v == "door_lf_dummy" or v == "door_rf_dummy" or v == "door_rr_dummy" or v == "door_lr_dummy" or v == "boot_dummy" or v == "bonnet_dummy" then
								local x,y,z = getVehicleComponentPosition ( car, v, "world" )
								local wx,wy,wz = getScreenFromWorldPosition ( x, y, z )
								if wx and wy then
								--	outputChatBox(wx)
									if dobozbaVan(wx-10, wy-10, 20, 20, sx/2, sy/2) then
										if v == "door_lf_dummy" then
											doorToOpen = 2
										end
										if v == "door_rf_dummy" then
											doorToOpen = 3
										end
										if v == "door_rr_dummy" then
											doorToOpen = 5
										end
										if v == "door_lr_dummy" then
											doorToOpen = 4
										end
										if v == "boot_dummy" then
											doorToOpen = 1
										end
										if v == "bonnet_dummy" then
											doorToOpen = 0
										end
										if getVehicleDoorOpenRatio ( car, doorToOpen ) == 0 then
											playSound("files/dooropen.mp3")
										elseif getVehicleDoorOpenRatio ( car, doorToOpen ) == 1 then
											playSound("files/doorclose.mp3")
										end
										setVehicleDoorOpenRatio ( car, doorToOpen, 1 - getVehicleDoorOpenRatio ( car, doorToOpen ), 500 )
										nyitasTiltas = true
										tiltasTimer =	setTimer(function()
											nyitasTiltas = false
										end, 1000, 1)
									--outputChatBox(v)
									end
								end
							end
							if v == "door_lf_dummy" then
								local x,y,z = getVehicleComponentPosition ( car, v, "world" )
								local wx,wy,wz = getScreenFromWorldPosition ( x, y, z )
								if wx and wy then
									if getVehicleDoorOpenRatio ( car, 2 ) == 1 then
										if dobozbaVan(wx+65, wy-10, 20,20, sx/2, sy/2) then
												fadeCamera(false)
												setTimer(function()
													fadeCamera(true)
													sitinSound = playSound("files/sitin.mp3")
													cameraMoveable = false
													utas = createPed(7,0,0,0)
													setElementAlpha(utas, 0)
													setElementDimension(utas, getElementData(localPlayer,"dbid"))
													warpPedIntoVehicle(utas, car, 0)
													camMovement = "fps"
													--debug against the ped
													setVehicleEngineState(car, false)
													setVehicleOverrideLights(car, 1)
												end, 1000, 1)
										end
									end
								end
							end
					end
				end
	end
end
addEventHandler ( "onClientKey", getRootElement(), kattint )

local plus = 60
--local vehX, vehY, vehZ = getElementPosition(car)
--local moveX,moveY,moveZ = vehX + math.cos(2126.986328125), vehY+math.sin(-1141.3154296875), 1420.9494628906
function cameraMoveToVehicle()
	if cameraMoveable and camMovement == "freemode" then

		dxDrawImage(sx/2-128/2, sy/2-128/2, 128, 128, "files/arc.png")

		-- camera assets
		local vehX, vehY, vehZ = getElementPosition(car)
		local cameraX = vehX + math.cos(cameraSettings["currentX"]) * cameraSettings["distance"]
		local cameraY = vehY + math.sin(cameraSettings["currentY"]) * cameraSettings["distance"]
		local cameraZ = vehZ + math.sin(cameraSettings["currentZ"]) * cameraSettings["distance"]
	--	setCameraMatrix(moveX+plus,moveY,moveZ, vehX, vehY, vehZ)
		setCameraMatrix(cameraX, cameraY, cameraZ, vehX, vehY, vehZ)


		if getKeyState("s") then
			differentY = (-0.01)
		else
			if not getKeyState("w") then
				differentY = 0
			end
		end
		if getKeyState("w") then
			differentY = 0.01
		else
			if not getKeyState("s") then
				differentY = 0
			end
		end

		if getKeyState("d") then
			differentX =  (-0.01)
		else
			if not getKeyState("a") then
				differentX = 0
			end
		end
		if getKeyState("a") then
			differentX = 0.01
		else
			if not getKeyState("d") then
				differentX = 0
			end
		end
		--outputChatBox(differentX)
		local cameraX = cameraSettings["currentX"]-  differentX --* cameraSettings["movingSpeed"]
		local cameraY = cameraSettings["currentY"]-  differentX --* cameraSettings["movingSpeed"]
		local cameraZ = cameraSettings["currentZ"] + (differentY * cameraSettings["movingSpeed"])	/	math.pi

		cameraZ = math.max(cameraSettings["minimumZ"], math.min(cameraSettings["maximumZ"], cameraZ))

		cameraSettings["currentX"] = cameraX
		cameraSettings["currentY"] = cameraY
		cameraSettings["currentZ"] = cameraZ
	end
	if camMovement == "fps" then
		local uX, uY, uZ = getElementPosition(utas)
		local x1,y2,z2,lx,ly,lz = getCameraMatrix(utas)
		--outputChatBox(uX..""..uY..""..uZ)
		--setCameraMatrix(uX-0.45, uY, uZ+0.3,lx-0.45,ly,lz+0.3)
		setCameraMatrix(uX, uY, uZ+0.5,2125.9208984375+fpsX, -1043.7624511719, 1415.6937255859+0.5+fpsY)

		if getKeyState("d") then
			fpsX =fpsX + 1.5
		else
			--fpsX = 0
		end
		if getKeyState("a") then
			fpsX =fpsX - 1.5
		else
			--fpsX = 0
		end
		if getKeyState("w") then
			fpsY =fpsY + 1.5
		else
			--fpsX = 0
		end
		if getKeyState("s") then
			fpsY =fpsY - 1.5
		else
			--fpsX = 0
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), cameraMoveToVehicle )

function fadeGenyo()
	fadeCamera(true)
end
addCommandHandler("fadegenyo", fadeGenyo)
