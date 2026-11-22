local x,y = guiGetScreenSize()
local rel = ((x/1920)+(y/1080))/2
local movingOffsetX, movingOffsetY = 0, 0;
local movingOffsetX2, movingOffsetY2 = 0, 0;
local mozgat = false
local mySavedConfig = {}
local actionwwidgets = ""
local startingcursorpos = 0
local startingcursorpos2 = 0

local cansizeRadar = false
local cansizeHud = false
local cansizeStamina = false
local cansizeChat = false

local atvisszukx = 0
local atvisszuky = 0
local atvisszukHudx = 0
local atvisszukHudy = 0
local atvisszukStaminaX = 0
local atvisszukStaminaY = 0
local atvisszukChatX = 0
local atvisszukChatY = 0

local moneyLosing = false
local getMoney = false
local moneyLoss = 0

local selectorOffSetX = {}
local selectorOffSetY = {}
local movingWithSelector = false
local selectedWithSelector = {}
local plusTable = {}

local selectorActivated = false
local plus = 1
--[[
if fileExists("client.lua") then
	fileDelete("client.lua")
end

if fileExists("chat/sourceC.lua") then
	fileDelete("chat/sourceC.lua")
end

if fileExists("radar/sourceC.lua") then
	fileDelete("radar/sourceC.lua")
end

if fileExists("radar/gps/sourceC.lua") then
	fileDelete("radar/gps/sourceC.lua")
end

if fileExists("scoreboard/sourceC.lua") then
	fileDelete("scoreboard/sourceC.lua")
end

if fileExists("displayStamina/sourceC.lua") then
	fileDelete("displayStamina/sourceC.lua")
end
]]

local fixTable = {
	{ -- Élet HUD
		["xplus"] = -30,
		["yplus"] = -50,
		["width"] = 40,
		["height"] = 0,
	},
	{ -- Body
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- Phone
		["xplus"] = 200,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- SPRINT
		["xplus"] = -30,
		["yplus"] = -6,
		["width"] = 40,
		["height"] = 15,
	},
	{ -- Money
		["xplus"] = -13,
		["yplus"] = 4,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- FPS
		["xplus"] = -10,
		["yplus"] = 3,
		["width"] = 20,
		["height"] = 10,
	},
	{ -- Minimap
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- Óra
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 10,
		["height"] = 5,
	},
	{ -- ActionBar
		["xplus"] = -5,
		["yplus"] = -5,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- Videókártya
		["xplus"] = -5,
		["yplus"] = -5,
		["width"] = 35,
		["height"] = 20,
	},
	{ -- OOC --11
		["xplus"] = -10,
		["yplus"] = 20,
		["width"] = 0,
		["height"] = -10,
	},
	{ -- speedo
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- benzin
		["xplus"] = 73,
		["yplus"] = 73,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- kijelzo
		["xplus"] = 75,
		["yplus"] = 120,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- kickban
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- jarmunev
		["xplus"] = -40,
		["yplus"] = 5,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- guns
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- name
		["xplus"] = -115,
		["yplus"] = -5,
		["width"] = 20,
		["height"] = 5,
	},
	{ -- ping
		["xplus"] = -5,
		["yplus"] = -5,
		["width"] = 20,
		["height"] = 5,
	},
	{ -- nitro
		["xplus"] = -5,
		["yplus"] = -5,
		["width"] = -220,
		["height"] = -185,
	},
	{ -- traffiradar
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
	{ -- customchat
		["xplus"] = 0,
		["yplus"] = 0,
		["width"] = 0,
		["height"] = 0,
	},
}

local boundingBoxes = {
	{ -- Élet HUD
		["name"] = "Életerő",
		["showing"] = true,
		["width"] = 226,
		["height"] = 60,
		["x"] = x - 246,
		["y"] = 70,
	},
	{ -- Body
		["name"] = "Body",
		["showing"] = true,
		["width"] = 18,
		["height"] = 46,
		["x"] = x - 295,
		["y"] = 35,
	},
	{ -- Phone
		["name"] = "TELEFON",
		["showing"] = true,
		["width"] = 300,
		["height"] = 512,
		["x"] = x - 512,
		["y"] = y/2-512/2,
	},
	{ -- SPRINT
		["name"] = "Stamina",
		["showing"] = true,
		["width"] = 226,
		["height"] = 8,
		["x"] = x-246,
		["y"] = 81,
	},
	{ -- Pénz
		["name"] = "Készpénz",
		["showing"] = true,
		["width"] = 220,
		["height"] = 30,
		["x"] = x - 220,
		["y"] = 95,
	},
	{ -- FPS
		["name"] = "FPS",
		["showing"] = false,
		["width"] = 80,
		["height"] = 22,
		["x"] = 50,
		["y"] = 125,
	},
	{ -- Minimap
		["name"] = "Radar",
		["showing"] = true,
		["width"] = 320,
		["height"] = 225,
		["x"] = 12,
		["y"] = y - 235,
	},
	{ -- Óra
		["name"] = "Óra",
		["showing"] = false,
		["width"] = 70,
		["height"] = 30,
		["x"] = 50,
		["y"] = 125,
	},
	{ -- ActionBar
		["name"] = "Action Bar",
		["showing"] = true,
		["width"] = 255+3,
		["height"] = 55+2,
		["x"] = x/2 - 269/2+20,
		["y"] = y - 54 - 10,
	},
	{ -- Videókártya
		["name"] = "Videókártya",
		["showing"] = false,
		["width"] = 256,
		["height"] = 80,
		["x"] = 50,
		["y"] = 125,
	},
	{ -- OOC --11
		["name"] = "OOC Chat",
		["showing"] = true,
		["width"] = 256,
		["height"] = 170,
		["x"] = 0.015625*x,
		["y"] = 16+15+25+100,
	},
	{ -- speedometer --12
		["name"] = "KILÓMÉTERÓRA",
		["showing"] = true,
		["width"] = 256,
		["height"] = 256,
		["x"] = x-256-5,
		["y"] = y-256-5,
	},
	{ -- benzinmeter 13
		["name"] = "ÜZEMANYAG",
		["showing"] = true,
		["width"] = 110,
		["height"] = 110,
		["x"] = x-440,
		["y"] = y-195,
	},
	{ -- speedometerkijelzo 14
		["name"] = "JÁRMŰIKONOK",
		["showing"] = true,
		["width"] = 110,
		["height"] = 70,
		["x"] = x-256,
		["y"] = y-256-5,
	},
	{ -- kickban notification
		["name"] = "Kick/Ban",
		["showing"] = true,
		["width"] = 324,
		["height"] = 120,
		["x"] = 12,
		["y"] = y - 235-80-70,
	},
	{ -- Járműnév
		["name"] = "JÁRMŰNÉV",
		["showing"] = true,
		["width"] = 300,
		["height"] = 45,
		["x"] = x-252,
		["y"] = y - 315,
	},
	{ -- guns
		["name"] = "Guns",
		["showing"] = true,
		["width"] = 256,
		["height"] = 128,
		["x"] = x-280,
		["y"] = 125,
	},
	{ -- name
		["name"] = "Name",
		["showing"] = false,
		["width"] = 300,
		["height"] = 30,
		["x"] = 50,
		["y"] = 125,
	},
	{ -- Ping
		["name"] = "Ping",
		["showing"] = false,
		["width"] = 80,
		["height"] = 30,
		["x"] = 50,
		["y"] = 125,
	},
	{ -- Nitro
		["name"] = "N2O",
		["showing"] = true,
		["width"] = 256,
		["height"] = 256,
		["x"] = x-256+226,
		["y"] = y-256-5,
	},
	{ -- TraffiRadar
		["name"] = "Traffipax radar",
		["showing"] = false,
		["width"] = 274,
		["height"] = 45,
		["x"] = 50,
		["y"] = 125,
	},
	{ -- customchat
		["name"] = "CustomChat",
		["showing"] = false,
		["width"] = 600,
		["height"] = 350,
		["x"] = 12,
		["y"] = 12,
	},
}




local hudhely = {(x/2*1.60), (y/2*0.111)}
local flickerStrength = 0
local myScreenSource = dxCreateScreenSource(x, y)
local Roboto2 = dxCreateFont("files/Roboto.ttf", 22)
local handfont = dxCreateFont("files/hand.ttf", 16)
local gtaFont = dxCreateFont("files/gtaFont.ttf", 20)
local Roboto = dxCreateFont("files/Roboto.ttf", 13)
local RobotoB = dxCreateFont("files/RobotoB.ttf", 24)
local ikonFont = dxCreateFont("files/fontawesome-webfont.ttf", 20)
local ikonFont2 = dxCreateFont("files/fontawesome2.otf", 27)

local szerkesztesmod = false
local kukaforgas = 0
local hudmozgatasba = false
local valaszto = false
local jobbra = false
local balra = false

local egeretnyomunk = false
local currentMoving = false
local resetColorRGB = {255,255,255}
local deleteColorRGB = {255,255,255}

local kijelolesR = false
local kijeloles = {(x/2), (y/2), 200, 200}


local stat = dxGetStatus()
local bit = nil

fontawesomeSheet = createBrowser(128, 256, true, true)
iconPOTSizes = {32, 32, 32, 32, 32, 32}
iconSizes = {14, 14, 14, 14, 14, 20}
iconList = {"heart", "shield", "cutlery", "bolt", "life-ring", "arrows-alt"}

local traf1 = nil
local detectedTraffipax = false

addEventHandler("onClientBrowserCreated", fontawesomeSheet,
	function ()
		loadBrowserURL(source, "http://mta/local/files/html/font-awesome/index.html?fa=" .. table.concat(iconList, ",") .. "&ps=" .. table.concat(iconPOTSizes, ",") .. "&s=" .. table.concat(iconSizes, ","))
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
    function()
        checkJSON_File()
		addEventHandler("onClientBrowserCreated", fontawesomeSheet, processFontAwesomeSheet)
		addEventHandler("onClientBrowserLoadingFailed", fontawesomeSheet, sheetLoadFail)
		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
    end
)

local plusX = 0

addEventHandler ( "onClientElementDataChange", localPlayer, function(dataName, oldValue, newValue)
	if not getElementData(localPlayer, "loggedin") then return end
	if dataName == "money" then
		local newValue = newValue or 0
		moneyLoss = newValue - (oldValue or 0)
		playSound("files/moneychange.mp3")
		if moneyLoss < 0 then
			moneyLosing = true
			setTimer ( function()
				moneyLosing = false
			end, 3500, 1 )
		elseif moneyLoss > 0 then
			getMoney = true
			setTimer ( function()
				getMoney = false
			end, 3500, 1 )
		end
	elseif dataName == "valaszto" then
		myDisabledWidgets = {}
		for k, v in pairs(mySavedConfig) do
			if not v["showing"] then
				myDisabledWidgets[#myDisabledWidgets+1] = k
			end
		end
		ordnenInSelector()
	end
end)

local counter = 0
local starttick
local currenttick

function convertToBool(string)
	if tostring(string) == "true" then
		return true
	else
		return false
	end
end

local plusYforUZI = 0
local plusX = 0
function hudrajzol ()
	if not getElementData(localPlayer, "enableall") then return end

	setElementData(localPlayer, "valaszto", valaszto)
	setPlayerHudComponentVisible("crosshair", true)

	if szerkesztesmod then
		if not isCursorShowing() then
			mozgat = false
			szerkesztesmod = false
			valaszto = false
			cansizeRadar = false
			cansizeHud = false
			canSizeStamina = false
			canSizeChat = false
			selectorActivated = false
			movingWithSelector = false
			kijelolesR = false
			egeretnyomunk = false
			if isElement(urmasound) then
				stopSound(urmasound)
			end
		end
		dxDrawRectangle(x/1920, y/1080, 1920, 1080 , tocolor(255,255,255,30))
	end

	if mozgat then  -- mozgatás ellenőrzése
		local egerW = {getCursorPosition()}
		local egerP = {egerW[1]*x, egerW[2]*y}
		mySavedConfig[currentMoving]["x"] = egerP[1] - movingOffsetX
		mySavedConfig[currentMoving]["y"] = egerP[2] - movingOffsetY
		hudmozgatasba = true
	else
		hudmozgatasba = false
	end

	if movingWithSelector then
		if selectorActivated then
			for i=1, plus-1 do
				local egerW = {getCursorPosition()}
				local egerP = {egerW[1]*x, egerW[2]*y}
				mySavedConfig[selectedWithSelector[i]]["x"] = egerP[1] - selectorOffSetX[i]
				mySavedConfig[selectedWithSelector[i]]["y"] = egerP[2] - selectorOffSetY[i]
			end
		end
	end
	-- Radar méretezés
	if cansizeRadar then
		egeretnyomunk = false
		local egerW2 = {getCursorPosition()}
		local egerP2 = {egerW2[1]*x, egerW2[2]*y}
		local egerszelesseg = {egerW2[1]*x, egerW2[2]*y}
		local proba = startingcursorposszor[1]-egerszelesseg[1]
		local proba2 = startingcursorposszor[2]-egerszelesseg[2]
		--outputDebugString(proba)
		mySavedConfig[7]["width"] = atvisszukx - proba
		mySavedConfig[7]["height"] = atvisszuky - proba2
	end
	-- Radar méretezés

	-- Hud méretezés
	if cansizeHud then
		egeretnyomunk = false
		local egerW3 = {getCursorPosition()}
		local egerP3 = {egerW3[1]*x, egerW3[2]*y}
		local egerszelesseg = {egerW3[1]*x, egerW3[2]*y}
		local proba = startingcursorposszor3[1]-egerszelesseg[1]
		local proba2 = startingcursorposszor3[2]-egerszelesseg[2]
		--outputDebugString(proba)
		mySavedConfig[1]["width"] = atvisszukHudx - proba
	end
	if canSizeStamina then
		egeretnyomunk = false
		local egerW3 = {getCursorPosition()}
		local egerP3 = {egerW3[1]*x, egerW3[2]*y}
		local egerszelesseg = {egerW3[1]*x, egerW3[2]*y}
		local proba = startingcursorposszor2[1]-egerszelesseg[1]
		local proba2 = startingcursorposszor2[2]-egerszelesseg[2]
		--outputDebugString(proba)
		mySavedConfig[4]["width"] = atvisszukStaminaX - proba
	end

	if canSizeChat then
		egeretnyomunk = false
		local egerW3 = {getCursorPosition()}
		local egerP3 = {egerW3[1]*x, egerW3[2]*y}
		local egerszelesseg = {egerW3[1]*x, egerW3[2]*y}
		local proba = startingcursorposszor2[1]-egerszelesseg[1]
		local proba2 = startingcursorposszor2[2]-egerszelesseg[2]
		--outputDebugString(proba)
		mySavedConfig[22]["width"] = atvisszukChatX - proba
		mySavedConfig[22]["height"] = atvisszukChatY - proba2
	end
	-- Hud méretezés
	if mySavedConfig[1]["width"] <= 80 then
		mySavedConfig[1]["width"] = 80
	elseif mySavedConfig[1]["width"] >= 330 then
		mySavedConfig[1]["width"] = 330
	end
	--radar stop
	if mySavedConfig[7]["width"] <= 204 then
		mySavedConfig[7]["width"] = 204
	elseif mySavedConfig[7]["width"] >= 629 then
		mySavedConfig[7]["width"] = 629
	end
	if mySavedConfig[7]["height"] <= 114 then
		mySavedConfig[7]["height"] = 114
	elseif mySavedConfig[7]["height"] >= 500 then
		mySavedConfig[7]["height"] = 500
	end
	-- stamina stop
	if mySavedConfig[4]["width"] <= 30 then
		mySavedConfig[4]["width"] = 30
	elseif mySavedConfig[4]["width"] >= 380 then
		mySavedConfig[4]["width"] = 380
	end

	if szerkesztesmod then
		if selectorActivated then
			for i=1, plus-1 do
				--outputDebugString("kiválasztottak "..selectedWithSelector[i])
				roundedRectangle(mySavedConfig[selectedWithSelector[i]]["x"]+fixTable[selectedWithSelector[i]]["xplus"], mySavedConfig[selectedWithSelector[i]]["y"]+fixTable[selectedWithSelector[i]]["yplus"], mySavedConfig[selectedWithSelector[i]]["width"]+fixTable[selectedWithSelector[i]]["width"], mySavedConfig[selectedWithSelector[i]]["height"]+fixTable[selectedWithSelector[i]]["height"], tocolor(153, 204, 153,100))
			end
		end
	end



	if kijelolesR and szerkesztesmod then
		roundedRectangle(kijeloles[1]+fixTable[currentMoving]["xplus"], kijeloles[2]+fixTable[currentMoving]["yplus"], kijeloles[3]+fixTable[currentMoving]["width"], kijeloles[4]+fixTable[currentMoving]["height"], tocolor(153, 204, 153,100))
		if currentMoving == 1 or currentMoving == 7 or currentMoving == 4 or currentMoving == 22 then
			drawTextWithBorder("", 1, mySavedConfig[currentMoving]["x"]+fixTable[currentMoving]["xplus"]+mySavedConfig[currentMoving]["width"]+fixTable[currentMoving]["width"]+15, mySavedConfig[currentMoving]["y"]+fixTable[currentMoving]["yplus"]+mySavedConfig[currentMoving]["height"]+15+fixTable[currentMoving]["height"], mySavedConfig[currentMoving]["x"]+fixTable[currentMoving]["xplus"]+mySavedConfig[currentMoving]["width"]+fixTable[currentMoving]["width"], mySavedConfig[currentMoving]["y"]+fixTable[currentMoving]["yplus"]+mySavedConfig[currentMoving]["height"]+fixTable[currentMoving]["height"], tocolor(0, 0, 0, 255), tocolor(200, 195, 191, 255), 0.6, 0.6, ikonFont, "center", "center", false, false,false, true)

		--	dxDrawRectangle(mySavedConfig[currentMoving]["x"]+fixTable[currentMoving]["xplus"]+mySavedConfig[currentMoving]["width"]+fixTable[1]["width"], mySavedConfig[currentMoving]["y"]+fixTable[currentMoving]["yplus"]+mySavedConfig[currentMoving]["height"], 20, 20)
		end
	elseif not szerkesztesmod then
		kijelolesR = false
	end
	if szerkesztesmod then
		for k, v in pairs(mySavedConfig) do
			if v["showing"] or valaszto then
				if k == 15 or k == 3 then
					drawTextWithBorder(v["name"], 1, v["x"]+fixTable[k]["xplus"], v["y"]+fixTable[k]["yplus"], v["x"]+v["width"]+fixTable[k]["xplus"], v["y"]+v["height"]+fixTable[k]["yplus"], tocolor(0, 0, 0, 255), tocolor(255, 255, 255, 255), 0.5, 0.5, Roboto2, "center", "center", false, false,false, true)
				end
				if not isPedInVehicle(localPlayer) then
					if k == 12 or k == 13 or k == 14 or k == 16 or k == 20 then
						drawTextWithBorder(v["name"], 1, v["x"]+fixTable[k]["xplus"]+fixTable[k]["width"], v["y"]+fixTable[k]["yplus"]+fixTable[k]["height"], v["x"]+v["width"]+fixTable[k]["xplus"], v["y"]+v["height"]+fixTable[k]["yplus"], tocolor(0, 0, 0, 255), tocolor(255, 255, 255, 255), 0.5, 0.5, Roboto2, "center", "center", false, false,false, true)
					end
				end
			end
		end
	end
		--dxDrawRectangle(mySavedConfig[4]["x"]+fixTable[4]["xplus"]+mySavedConfig[4]["width"]+fixTable[4]["width"], mySavedConfig[4]["y"]+fixTable[4]["yplus"]+mySavedConfig[4]["height"], 20, 20)
	if mozgat == true then
		kijeloles[1] = mySavedConfig[currentMoving]["x"]
		kijeloles[2] = mySavedConfig[currentMoving]["y"]
		kijeloles[3] = mySavedConfig[currentMoving]["width"]
		kijeloles[4] = mySavedConfig[currentMoving]["height"]
	end
	if currentMoving == 7 then
		kijeloles[3] = mySavedConfig[7]["width"]
		kijeloles[4] = mySavedConfig[7]["height"]
	end
	if currentMoving == 1 then
		kijeloles[3] = mySavedConfig[1]["width"]
		kijeloles[4] = mySavedConfig[1]["height"]
	end
	if currentMoving == 4 then
		kijeloles[3] = mySavedConfig[4]["width"]
		kijeloles[4] = mySavedConfig[4]["height"]
	end
	if currentMoving == 22 then
		kijeloles[3] = mySavedConfig[22]["width"]
		kijeloles[4] = mySavedConfig[22]["height"]
	end


	if jobbra then -- widget választóba jobbra mozgás
		hudhely[1] = hudhely[1] + 2
	end
	if balra then -- widget választóba balra mozgás
		hudhely[1] = hudhely[1] - 2
	end

	if szerkesztesmod == true then
		if valaszto == true then
			dxDrawRectangle(0, 0, 1920, 225, tocolor(0,0,0,160)) -- külön rajzoljuk ki
		end
	end

	if mySavedConfig[1]["showing"] or valaszto then -- hud kirajzolása
		local hp = getElementHealth(localPlayer)
		local armor = getPedArmor(localPlayer)
		local kaja = getElementData(localPlayer, "hunger") or 0
		local pia = getElementData(localPlayer, "thirst") or 0

		hp2 = hp * mySavedConfig[1]["width"]/100
		armor2 = armor * mySavedConfig[1]["width"]/100
		kaja2 = kaja * mySavedConfig[1]["width"]/200 - 1
		pia2 = pia * mySavedConfig[1]["width"]/200 - 1

		if kaja2 < 0 then kaja2 = 0 end
		if pia2 < 0 then pia2 = 0 end

		hudhely[1] = mySavedConfig[1]["x"]
		hudhely[2] = mySavedConfig[1]["y"]
		local hudWidth = mySavedConfig[1]["width"]

		--hp
		dxDrawRectangle(hudhely[1], hudhely[2]-45, hudWidth, 8, tocolor(0,0,0,170))
		radarKeret(hudhely[1], hudhely[2]-45, hudWidth, 8, 2, 200)
		dxDrawRectangle(hudhely[1], hudhely[2]-45, hp2, 8, tocolor(124, 197, 118, 200))
		dxDrawBorderedImageSection(hudhely[1]-32, hudhely[2]-57, 32, 32, 0, 0, 32, 32, fontawesomeSheet, 0, 0, 0, tocolor(124, 197, 118, 200))

		--armor
		dxDrawRectangle(hudhely[1], hudhely[2]-26, hudWidth, 8, tocolor(0,0,0,170))
		radarKeret(hudhely[1], hudhely[2]-26, hudWidth, 8, 2, 200)
		dxDrawRectangle(hudhely[1], hudhely[2]-26, armor2, 8, tocolor(50, 179, 239, 200))
		dxDrawBorderedImageSection(hudhely[1]-32, hudhely[2]-57+19, 32, 32, 0, 32, 32, 32, fontawesomeSheet, 0, 0, 0, tocolor(50, 179, 239, 200))

		--hunger
		dxDrawRectangle(hudhely[1], hudhely[2]-26+19, hudWidth/2 - 1, 8, tocolor(0,0,0,170))
		radarKeret(hudhely[1], hudhely[2]-26+19, hudWidth/2 - 1, 8, 2, 200)
		dxDrawRectangle(hudhely[1], hudhely[2]-26+19, kaja2, 8, tocolor(223, 181, 81, 200))
		dxDrawBorderedImageSection(hudhely[1]-32, hudhely[2]-57+38, 32, 32, 0, 32 * 2, 32, 32, fontawesomeSheet, 0, 0, 0, tocolor(223, 181, 81, 200))

		--thirst
		dxDrawRectangle(hudhely[1] + hudWidth/2 + 1, hudhely[2]-26+19, hudWidth/2 - 1, 8, tocolor(0,0,0,170))
		radarKeret(hudhely[1] + hudWidth/2 + 1, hudhely[2]-26+19, hudWidth/2 - 1, 8, 2, 200, true)
		dxDrawRectangle(hudhely[1] + hudWidth/2 + 1, hudhely[2]-26+19, pia2, 8, tocolor(51, 204, 255, 200))
	end
	if mySavedConfig[4]["showing"] or valaszto then
		--sprint
		local w = getNode(4, "width")
		local r, g, b = 255, 255, 255
		if displayStamina < 0.3*w then
			r, g, b = interpolateBetween(255, 255, 255, 215, 89, 89, 1 - displayStamina / (0.3*w) , "Linear")
		end

		dxDrawBorderedImageSection(mySavedConfig[4]["x"]-32, mySavedConfig[4]["y"]-12, 32, 32, 0, 32 * 3, 32, 32, fontawesomeSheet, 0, 0, 0, tocolor(r, g, b, 200))
		dxDrawRectangle(mySavedConfig[4]["x"], mySavedConfig[4]["y"], mySavedConfig[4]["width"], mySavedConfig[4]["height"], tocolor(0,0,0,170))
		radarKeret(mySavedConfig[4]["x"], mySavedConfig[4]["y"], mySavedConfig[4]["width"], mySavedConfig[4]["height"], 2, 200)
		dxDrawRectangle(mySavedConfig[4]["x"], mySavedConfig[4]["y"], displayStamina, 8, tocolor(r, g, b, 200))

	end
	if mySavedConfig[5]["showing"] or valaszto then
		local maxNulla = 11
		local playerMoney = getElementData(localPlayer, "money") or 0
		local actualCharAmount = maxNulla - string.len(tostring(playerMoney))
		local finalString = ""

		for i = 0, actualCharAmount, 1 do
				finalString = finalString .. "0"
		end
		local widthPlus = dxGetTextWidth(finalString, 1, gtaFont)
		local minusMoney = dxGetTextWidth("$", 1, gtaFont)
		local moneylosswidth = dxGetTextWidth(moneyLoss, 1, gtaFont)
		if not moneyLosing and not getMoney then
			drawTextWithBorder("#FFFFFF"..finalString.."#7cc576"..playerMoney.."#ffffff $", 1, mySavedConfig[5]["x"], mySavedConfig[5]["y"],mySavedConfig[5]["x"]+200, mySavedConfig[5]["y"]-2, tocolor(0, 0, 0, 255), tocolor(189, 227, 188, 255), 1, 1, gtaFont, "right", "top", false, false,false, true)
		elseif moneyLosing then
		--	local dollarPlus = dxGetTextWidth(" $", 1, gtaFont)
			drawTextWithBorder(""..moneyLoss.." $", 1, mySavedConfig[5]["x"]+widthPlus+minusMoney, mySavedConfig[5]["y"], mySavedConfig[5]["x"]+200, mySavedConfig[5]["y"]-2, tocolor(0, 0, 0, 255), tocolor(217, 83, 79, 255), 1, 1, gtaFont, "right", "top", false, false,false, true)
		elseif getMoney then
			drawTextWithBorder("+"..moneyLoss.." $", 1, mySavedConfig[5]["x"]+widthPlus, mySavedConfig[5]["y"], mySavedConfig[5]["x"]+200, mySavedConfig[5]["y"]-2, tocolor(0, 0, 0, 255), tocolor(124, 197, 118), 1, 1, gtaFont, "right", "top", false, false,false, true)

		end
	end
		--moneyrender
	if mySavedConfig[2]["showing"] or valaszto then
			--body
			dxDrawImage(mySavedConfig[2]["x"], mySavedConfig[2]["y"], 18, 46, "files/bone.png",0,0,0,tocolor(0,0,0,180))
			local bodyParts = getElementData(localPlayer, "bone") or {true, true, true, true, true}
			--outputDebugString(bodyParts[4])
			if not bodyParts[2] then
					dxDrawImage(mySavedConfig[2]["x"], mySavedConfig[2]["y"], 18, 46, "files/injureLeftArm.png",0,0,0,tocolor(255,255,255,255))
			end
			if not bodyParts[3] then
					dxDrawImage(mySavedConfig[2]["x"], mySavedConfig[2]["y"], 18, 46, "files/injureRightArm.png",0,0,0,tocolor(255,255,255,255))
			end
			if not bodyParts[4] then
					dxDrawImage(mySavedConfig[2]["x"], mySavedConfig[2]["y"], 18, 46, "files/injureLeftFoot.png",0,0,0,tocolor(255,255,255,255))
			end
			if not bodyParts[5] then
					dxDrawImage(mySavedConfig[2]["x"], mySavedConfig[2]["y"], 18, 46, "files/injureRightFoot.png",0,0,0,tocolor(255,255,255,255))
			end
			--body
		end
		if mySavedConfig[17]["showing"] or valaszto then
		-- guns draw
			local gunID = getPedWeapon(localPlayer)
			local ammo = getPedAmmoInClip ( localPlayer )
			local totalAmmo = getPedTotalAmmo ( localPlayer )
			local weaponJam = getElementData(localPlayer, "weap:hot")
			local weaponJamSzor = weaponJam/89*130
			dxDrawImage(mySavedConfig[17]["x"], mySavedConfig[17]["y"], mySavedConfig[17]["width"], mySavedConfig[17]["height"], "guns/"..gunID..".png")
			if gunID == 28 or gunID == 32 then
				plusYforUZI = 30
			else
				plusYforUZI = 0
			end
			if gunID >= 22 and gunID <= 38 then
				drawTextWithBorder(ammo.." | "..totalAmmo, 1, mySavedConfig[17]["x"], mySavedConfig[17]["y"]+mySavedConfig[17]["height"]-40+plusYforUZI,mySavedConfig[17]["x"]+mySavedConfig[17]["width"], 0, tocolor(0, 0, 0, 255), tocolor(255, 255, 255, 255), 1, 1, gtaFont, "right", "top", false, false,false, true)
			end
			if gunID > 21 and gunID < 39 then
				radarKeret(mySavedConfig[17]["x"]+120, mySavedConfig[17]["y"]+mySavedConfig[17]["height"]+plusYforUZI, 130, 10, 2, 200)
				dxDrawRectangle(mySavedConfig[17]["x"]+120, mySavedConfig[17]["y"]+mySavedConfig[17]["height"]+plusYforUZI, 130, 10, tocolor(0, 0, 0,180))
				dxDrawRectangle(mySavedConfig[17]["x"]+120, mySavedConfig[17]["y"]+mySavedConfig[17]["height"]+plusYforUZI, weaponJamSzor, 10, tocolor(217, 83, 79,255))
			end
		end
		--guns draw

		-- fps draw
		if mySavedConfig[6]["showing"] or valaszto then
			drawTextWithBorder("#7cc576"..FPS.." FPS", 1, mySavedConfig[6]["x"], mySavedConfig[6]["y"],mySavedConfig[6]["x"]+80, mySavedConfig[5]["y"]-2, tocolor(0, 0, 0, 255), tocolor(189, 227, 188, 255), 1, 1, gtaFont, "center", "top", false, false,false, true)
		end
		-- fps draw

		-- clock draw
		if mySavedConfig[8]["showing"] or valaszto then
			local time = getRealTime()
			local hours = time.hour
			local minutes = time.minute
			local plusNull = ""
			if minutes <= 9 then
				plusNull = "0"
			else
				plusNull = ""
			end
			--outputChatBox ( "Local Time: "..hours..":"..minutes )
			drawTextWithBorder("#ffffff"..hours..":"..plusNull..""..minutes, 1, mySavedConfig[8]["x"], mySavedConfig[8]["y"],mySavedConfig[8]["x"]+80, mySavedConfig[5]["y"]-2, tocolor(0, 0, 0, 255), tocolor(189, 227, 188, 255), 1, 1, gtaFont, "center", "top", false, false,false, true)
		end

		-- name draw
		if mySavedConfig[18]["showing"] or valaszto then
			drawTextWithBorder("#ffffff"..getPlayerName(localPlayer):gsub("_", " ").." ("..getElementData(localPlayer, "playerid")..") Szint: ".. 0, 1, mySavedConfig[18]["x"], mySavedConfig[18]["y"],mySavedConfig[18]["x"]+80, mySavedConfig[5]["y"]-2, tocolor(0, 0, 0, 255), tocolor(189, 227, 188, 255), 1, 1, handfont, "center", "top", false, false,false, true)
		end
		-- name draw

		-- videocard
		if mySavedConfig[10]["showing"] or valaszto then
			if stat["Setting32BitColor"] then
				bit = 32
			else
				bit = 16
			end
			drawTextWithBorder("#7cc576"..stat["VideoCardName"].."\n#ffffffVRAM:"..stat["VideoMemoryFreeForMTA"].."/"..stat["VideoCardRAM"].."MB, FONT:"..stat["VideoMemoryUsedByFonts"].."MB,\nTEXTURE:"..stat["VideoMemoryUsedByTextures"].."MB, RTARGET:"..stat["VideoMemoryUsedByRenderTargets"].."MB,\nRATIO:"..stat["SettingAspectRatio"]..", SIZE:"..x.."x"..y.."x"..bit,1, mySavedConfig[10]["x"],mySavedConfig[10]["y"],0,0,tocolor(0,0,0,255),tocolor(189, 227, 188, 255), 1,1,Roboto,"left","top",false,false,false,true)
		end
		--videocard

		-- ping
		if mySavedConfig[19]["showing"] or valaszto then
			local ping = getPlayerPing(localPlayer)
			drawTextWithBorder("#ffffffPING: #7cc576"..ping.." ms",1, mySavedConfig[19]["x"],mySavedConfig[19]["y"],0,0,tocolor(0,0,0,255),tocolor(189, 227, 188, 255), 1,1,Roboto,"left","top",false,false,false,true)
		end


		-- ping
		local enteredVehicle = getPedOccupiedVehicle(localPlayer)
		if mySavedConfig[20]["showing"] or valaszto then
			if enteredVehicle then
				local fNitroLevel = getElementData(enteredVehicle, "tuning.nitroLevel") or 0
				dxDrawImage(mySavedConfig[20]["x"],mySavedConfig[20]["y"],mySavedConfig[20]["width"],mySavedConfig[20]["height"], "files/nitro.png")
				if getVehicleUpgradeOnSlot(enteredVehicle, 8) then
					if fNitroLevel > 0 then
						local nitroCounter = fNitroLevel*33/100
						--outputDebugString(getElementData(enteredVehicle, "tuning.nitroLevel"))
						--dxDrawImage(mySavedConfig[20]["x"]+6,mySavedConfig[20]["y"]+9,12,nitroCounter, "files/nitrolevel.png")
						dxDrawImageSection(mySavedConfig[20]["x"]+6,mySavedConfig[20]["y"]+9+33, 12, -nitroCounter, 0, 0, 12,-nitroCounter, 'files/nitrolevel.png', 0, 0, 0, tocolor(255, 255, 255,255))
					end
				end
				--dxDrawImage(mySavedConfig[20]["x"]+6,mySavedConfig[20]["y"]+9,12,33, "files/nitrolevel.png")
				--dxDrawImageSection(mySavedConfig[20]["x"]-200,mySavedConfig[20]["y"],mySavedConfig[20]["width"]-200,mySavedConfig[20]["height"]-100,0,0,mySavedConfig[20]["width"]-200,mySavedConfig[20]["height"],"files/nitrolevel.png")
			end
		end

		 -- hud rész vége

	if szerkesztesmod == true then -- ha szerkesztésbe van
	  --dxDrawImage(x/1920, y/1080, 1920, 1080, "proba.png")
		drawTextWithBorder("Hud szerkesztés", 1, x/2, y/2, x/2, y/2, tocolor(0, 0, 0, 255), tocolor(230, 230, 230, 255), 0.70, 0.70, RobotoB, "center", "center", false, false,false, true)
		-- reset
		if mozgat or movingWithSelector and isInSlot(x/2 + 9, 33, 50, 50) then
			actionwwidgets = "reset"
			--outputDebugString("moved to "..actionwwidgets)
		end
		if not isInSlot(x/2 + 9, 33, 50, 50) then
			actionwwidgets = ""
		end

		if not valaszto and (mozgat or movingWithSelector) then -- ha a választóban vagyunk, akkor ne mutasson semmit
			if actionwwidgets == "reset" then
				if resetColorRGB[1] > 89 then
					resetColorRGB[1] = resetColorRGB[1] - 12
				end
				if resetColorRGB[2] > 142 then
					resetColorRGB[2] = resetColorRGB[2] - 12
				end
				if resetColorRGB[1] > 215 then
					resetColorRGB[1] = resetColorRGB[1] - 12
				end
			else
				resetColorRGB = {255,255,255}
			end
			drawTextWithBorder("", 1, x/2 + 10, 34, 0,0, tocolor(0, 0, 0, 255), tocolor(resetColorRGB[1], resetColorRGB[2], resetColorRGB[3], 255), 1, 1, ikonFont2, "left", "top", false, true,false, true)
			dxDrawImage(x/2 - 54, 25, 64, 64, "files/kuka.png",0,0,0,tocolor(deleteColorRGB[1],deleteColorRGB[2],deleteColorRGB[3],255))
			dxDrawImage(x/2 - 54, 25-kukaforgas/2, 64, 64, "files/kukateto.png", -kukaforgas,0,0,tocolor(deleteColorRGB[1],deleteColorRGB[2],deleteColorRGB[3],255))
		end

		if(isInSlot(x/2 - 45, 33, 44, 50)) then
			if kukaforgas < 45 then
				kukaforgas = kukaforgas + 3
			end
		else
			if kukaforgas > 0 then
				kukaforgas = kukaforgas - 3
			end
		end

		-- törlés
		if(isInSlot(x/2 - 45, 33, 44, 50)) and (mozgat or movingWithSelector) then -- kukára mozgatás
				actionwwidgets = "delete"
		end
		if actionwwidgets == "delete" then
			if deleteColorRGB[3] > 80 then
				deleteColorRGB[3] = deleteColorRGB[3] - 10
			end
			if deleteColorRGB[2] > 80 then
				deleteColorRGB[2] = deleteColorRGB[2] - 10
			end
		else
			deleteColorRGB = {255,255,255}
		end
		-- törlés


		-- választó aktiválás
		if(isInSlot(0, 0, 1920, 3)) then -- ha a monitor tetején van a kurzor
			if not mozgat then
				valaszto = true
			end
		elseif(isInSlot(0, 225, 1920, 1080)) then
			valaszto = false
		end
		--választó aktiválás

		-- widgetválasztó
		if valaszto == true then -- ha a widget választóban vagyunk
			if isInSlot(0, 0, 50, 225) then
				dxDrawRectangle(0, 0, 50, 225, tocolor(0,0,0,200))
				dxDrawImage(14-2.5, 101-2.5, 30, 30, "files/nyil.png")
			else
				dxDrawRectangle(0, 0, 50, 225, tocolor(0,0,0,150))
				dxDrawImage(14, 101, 25, 25, "files/nyil.png")
			end
			if isInSlot(x-50, 0, 50, 225) then
				dxDrawRectangle(x-50, 0, 50, 225, tocolor(0,0,0,200))
				dxDrawImage(x-36-2.5, 101-2.5, 30, 30, "files/nyil.png", 180)
			else
				dxDrawRectangle(x-50, 0, 50, 225, tocolor(0,0,0,150))
				dxDrawImage(x-36, 101, 25, 25, "files/nyil.png", 180)
			end
			for k, v in pairs(mySavedConfig) do
				if not mySavedConfig[k]["showing"] then
					if balra then
						mySavedConfig[k]["x"] = mySavedConfig[k]["x"] - 5
					elseif jobbra then
						mySavedConfig[k]["x"] = mySavedConfig[k]["x"] + 5
					end
				end
			end
		end
		-- widgetválasztó

		-- kijeloles
		if egeretnyomunk and not movingWithSelector then -- csak akkor rajzolja le, ha lenyomva tartjuk az egeret
			if not hudmozgatasba and not valaszto then -- ha a hud mozog ne jelenjen meg
				local egerW = {getCursorPosition()}
				local egerP = {egerW[1]*x, egerW[2]*y}
				local egerszelesseg = {egerW[1]*x, egerW[2]*y}
				dxDrawRectangle(startingcursorposszor[1], startingcursorposszor[2], egerszelesseg[1]-startingcursorposszor[1], egerszelesseg[2]-startingcursorposszor[2], tocolor(0,160,209,170))
			end
		end
		--kijeloles
	end
	-- szerkesztés idáig fut
	--outputDebugString("disabled "..#myDisabledWidgets)
	--outputDebugString("plus "..plus)
end
addEventHandler("onClientRender", getRootElement(), hudrajzol)

addEventHandler("onClientRender", getRootElement(), function()
			traffiRender(mySavedConfig[21]["x"], mySavedConfig[21]["y"], mySavedConfig[21]["width"], mySavedConfig[21]["height"])
end)

function traffiRender(x, y, w, h)
	if valaszto or mySavedConfig[21]["showing"] then
		if occupiedVehicle and getElementData(occupiedVehicle, "vehicle.tuning.trafiRadar") then

			dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 200))
			dxDrawInnerBorder(x, y, w, h, 2, tocolor(0, 0, 0, 255))

			if not traf1 then
				dxDrawImage(x, y, w, h, "files/traf1.png", 0, 0, 0, tocolor(50, 50, 50, 200))
				dxDrawImage(x, y, w, h, "files/traf2.png", 0, 0, 0, tocolor(50, 50, 50, 200))
				dxDrawText(floor(getVehicleSpeed(occupiedVehicle)) .. "KM/H", x, y + respc(34), x + w, y + h - respc(5), tocolor(50, 50, 50, 200), 0.75, getFont("Roboto"), "center", "center", false, false)
			else
				local vehiclePosX, vehiclePosY = getElementPosition(occupiedVehicle)
				local traffiPosX, traffiPosY = getElementPosition(detectedTraffipax)
				local traffiDistance = getDistanceBetweenPoints2D(vehiclePosX, vehiclePosY, traffiPosX, traffiPosY)

				--local beepProgress = (getTickCount() - trafTick) / (((750 / traffiDistance) * 1200) * (45 / 175)) --750 = távolság - kevesebb = gyorsabb
				local beepProgress = (getTickCount() - trafTick) / (750 * (math.abs((-10) - traffiDistance) / 175))

				if beepProgress > 0.1 then
					playTraffiSound = false
				end

				if beepProgress >= 1 then
					trafTick = getTickCount()

					if not playTraffiSound then
						playSound("files/sounds/traffi.mp3")
						playTraffiSound = true
					end
				end

				dxDrawImage(x, y, w, h, "files/traf1.png", 0, 0, 0, tocolor(50, 50, 50, 200))
				dxDrawImageSection(x + w / 2 - (w / 2 + 40) * beepProgress, y, 40, h, 137 - 177 * beepProgress, 0, 40, 45, traf1, 0, 0, 0, tocolor(124, 197, 118, 200))
				dxDrawImageSection(x + w / 2 - (w / 2 + 40) * beepProgress, y, 40, h, 137 - 177 * beepProgress, 0, 40, 45, traf1, 180, (w / 2 + 40) * beepProgress - 20, 0, tocolor(124, 197, 118, 200))
				dxDrawImage(x, y, w, h, "files/traf2.png", 0, 0, 0, tocolor(215, 89, 89, 200))
				dxDrawText(floor(getVehicleSpeed(occupiedVehicle)) .. "KM/H", x, y + 34, x + w, y + h - 5, tocolor(215, 89, 89, 200), 0.75, getFont("Roboto"), "center", "center", false, false)
			end
		else
			if szerkesztesmod then
				dxDrawBorderedText(mySavedConfig[21]["name"], x, y, x+w, y+h, tocolor(255,255,255,255),0.5, Roboto2, "center", "center")
			end
		end
	end
end

--local trafi = createColCuboid(1069.447265625, -951.294921875, 40.714153289795, 50, 10, 10)
--local trafi =	createColTube(1069.447265625, -951.294921875, 40.714153289795, 45, 45)
--local trafi =createColRectangle(1069.447265625, -951.294921875, 175, 175)
local trafi = createColSphere(1069.447265625, -951.294921875, 40.714153289795, 175)
local allo = createObject(2311, 1033.220703125, -970.2392578125, 42.63472366333)
setElementData(trafi, "bigSpeedCam", true)

addEventHandler("onClientColShapeHit", getRootElement(),
	function (element)
		if source and isElement(source) then
			if element == occupiedVehicle and not detectedTraffipax and getElementData(source, "bigSpeedCam") then
				trafTick = getTickCount()
				detectedTraffipax = source
				traf1 = dxCreateTexture("files/traf1.png")
				dxSetTextureEdge(traf1, "border", tocolor(0, 0, 0, 0))
			end
		end
	end
)

addEventHandler("onClientColShapeLeave", getRootElement(),
	function (element)
		if element == occupiedVehicle and source == detectedTraffipax then
			detectedTraffipax = false

			if isElement(traf1) then
				destroyElement(traf1)
			end
			traf1 = nil
		end
	end
)


function szerkesztes(key, state)
	if (key == "lctrl") then
		if isCursorShowing() then
			if state then
				urmasound = playSound("files/urmasound.mp3", true)
				szerkesztesmod = true
			else
				mozgat = false
				szerkesztesmod = false
				valaszto = false
				cansizeRadar = false
				cansizeHud = false
				canSizeStamina = false
				canSizeChat = false
				selectorActivated = false
				movingWithSelector = false
				kijelolesR = false
				egeretnyomunk = false
				if isElement(urmasound) then
					stopSound(urmasound)
				end
			end
		end
	end
end
addEventHandler("onClientKey", getRootElement(), szerkesztes)


myDisabledWidgets = {}
function kattint( key, state, aX, aY, wX, wY, wZ, element )
	if (key == "left" and state == "down") then
		if valaszto == true then
			if(isInSlot(0, 0, 50, 200)) then
				balra = true
			elseif(isInSlot(x-50, 0, 50, 200)) then
				jobbra = true
			end
		end
	else
		jobbra = false
		balra = false
	end
	if actionwwidgets ~= "" then
		if (key == "left" and state == "up") then
			if actionwwidgets == "reset" then
				if currentMoving then
					mozgat = false
					kijelolesR = false
					mySavedConfig[currentMoving]["x"] = boundingBoxes[currentMoving]["x"]
					mySavedConfig[currentMoving]["y"] = boundingBoxes[currentMoving]["y"]
					mySavedConfig[currentMoving]["width"] = boundingBoxes[currentMoving]["width"]
					mySavedConfig[currentMoving]["height"] = boundingBoxes[currentMoving]["height"]
					mySavedConfig[currentMoving]["showing"] = boundingBoxes[currentMoving]["showing"]
					currentMoving = false
				elseif selectorActivated then
					for i=1, plus-1 do
						mySavedConfig[selectedWithSelector[i]]["x"] = boundingBoxes[selectedWithSelector[i]]["x"]
						mySavedConfig[selectedWithSelector[i]]["y"] = boundingBoxes[selectedWithSelector[i]]["y"]
						mySavedConfig[selectedWithSelector[i]]["width"] = boundingBoxes[selectedWithSelector[i]]["width"]
						mySavedConfig[selectedWithSelector[i]]["height"] = boundingBoxes[selectedWithSelector[i]]["height"]
						mySavedConfig[selectedWithSelector[i]]["showing"] = boundingBoxes[selectedWithSelector[i]]["showing"]
					end
					selectorActivated = false
				end
			elseif actionwwidgets == "delete" then
				if currentMoving then
					mozgat = false
					kijelolesR = false
					mySavedConfig[currentMoving]["showing"] = false
				elseif selectorActivated then
					for i=1, plus-1 do
						mySavedConfig[selectedWithSelector[i]]["showing"] = false
					end
					selectorActivated = false
				end
			end
		end
	end
	if szerkesztesmod and not mozgat and not valaszto and not movingWithSelector then
		if (key == "left" and state == "down") then
			egeretnyomunk = true
			startingcursorpos = {getCursorPosition()}
			startingcursorposszor = {startingcursorpos[1]*x, startingcursorpos[2]*y}
		end
	end
	if key == "left" and state == "up" then
		if egeretnyomunk then-- még kérdéses
			if not movingWithSelector and not mozgat then
				plus = 1
				for k,v in pairs(mySavedConfig) do
					local egerW = {getCursorPosition()}
					local egerP = {egerW[1]*x, egerW[2]*y}
					local egerszelesseg = {egerW[1]*x, egerW[2]*y}
					if boxesIntersect(startingcursorposszor[1], startingcursorposszor[2], egerszelesseg[1]-startingcursorposszor[1], egerszelesseg[2]-startingcursorposszor[2], mySavedConfig[k]["x"]+fixTable[k]["xplus"], mySavedConfig[k]["y"]+fixTable[k]["yplus"], mySavedConfig[k]["width"]+fixTable[k]["width"], mySavedConfig[k]["height"]+fixTable[k]["height"]) then
						if v["showing"] then
							selectedWithSelector[plus] = k
							selectorActivated = true
							--outputDebugString(selectedWithSelector[plus])
							plus = plus + 1
						end
					end
				end
			end
			egeretnyomunk = false
		end
	end
		if szerkesztesmod then
			for k, v in pairs(mySavedConfig) do
				local egerW = {getCursorPosition()}
				local egerP = {egerW[1]*x, egerW[2]*y}
				local egerszelesseg = {egerW[1]*x, egerW[2]*y}
				if (key == "left" and state == "down") then
					if not (isInSlot(0, 0, 100, 200)) or not (isInSlot(x-100, 0, 100, 200)) then
						if mySavedConfig[k]["showing"] then
							if(isInSlot(mySavedConfig[k]["x"]+fixTable[k]["xplus"], mySavedConfig[k]["y"]+fixTable[k]["yplus"], mySavedConfig[k]["width"]+fixTable[k]["width"], mySavedConfig[k]["height"]+fixTable[k]["height"])) then
								if not selectorActivated and not valaszto then
									egerW = {getCursorPosition()}
									egerP = {egerW[1]*x, egerW[2]*y}
									mozgat = true
									movingOffsetX = egerP[1] - mySavedConfig[k]["x"]
									movingOffsetY = egerP[2] - mySavedConfig[k]["y"]
									currentMoving = k
									kijelolesR = true
									egeretnyomunk = false
								end
							end
						elseif not mySavedConfig[k]["showing"] then
							if(isInSlot(mySavedConfig[k]["x"]+fixTable[k]["xplus"], mySavedConfig[k]["y"]+fixTable[k]["yplus"], mySavedConfig[k]["width"]+fixTable[k]["width"], mySavedConfig[k]["height"]+fixTable[k]["height"])) then
								if valaszto and not (isInSlot(0, 0, 100, 200)) and not (isInSlot(x-100, 0, 100, 200)) then
									egerW = {getCursorPosition()}
									egerP = {egerW[1]*x, egerW[2]*y}
									mozgat = true
									--outputDebugString(k)
									movingOffsetX = egerP[1] - mySavedConfig[k]["x"]
									movingOffsetY = egerP[2] - mySavedConfig[k]["y"]
									currentMoving = k
									--table.remove(myDisabledWidgets, currentMoving)
									mySavedConfig[k]["showing"] = true
									myDisabledWidgets = {}
									for k, v in pairs(mySavedConfig) do
										if not v["showing"] then
											myDisabledWidgets[#myDisabledWidgets+1] = k
										end
									end
									valaszto = false
									kijelolesR = true
									egeretnyomunk = false
								end
							end
						end
					end
				else
					mozgat = false
				end
			end
			if currentMoving then
				if not (isInSlot(mySavedConfig[currentMoving]["x"]+fixTable[currentMoving]["xplus"], mySavedConfig[currentMoving]["y"]+fixTable[currentMoving]["yplus"], mySavedConfig[currentMoving]["width"]+fixTable[currentMoving]["width"], mySavedConfig[currentMoving]["height"]+fixTable[currentMoving]["height"])) and not (isInSlot(mySavedConfig[7]["x"]+mySavedConfig[7]["width"],mySavedConfig[7]["y"]+mySavedConfig[7]["height"],20,20)) then
					if not (isInSlot (mySavedConfig[currentMoving]["x"]+fixTable[currentMoving]["xplus"]+mySavedConfig[currentMoving]["width"]+fixTable[1]["width"], mySavedConfig[currentMoving]["y"]+fixTable[currentMoving]["yplus"]+mySavedConfig[currentMoving]["height"], 20, 20)) then
						if not(isInSlot(mySavedConfig[4]["x"]+fixTable[4]["xplus"]+mySavedConfig[4]["width"]+fixTable[4]["width"], mySavedConfig[4]["y"]+fixTable[4]["yplus"]+mySavedConfig[4]["height"]+fixTable[4]["height"], 20, 20)) then
							if not(isInSlot(mySavedConfig[22]["x"]+fixTable[22]["xplus"]+mySavedConfig[22]["width"]+fixTable[22]["width"], mySavedConfig[22]["y"]+fixTable[22]["yplus"]+mySavedConfig[22]["height"]+fixTable[22]["height"], 20, 20)) then

								if (key == "left" and state == "down") then
									kijelolesR = false
									currentMoving = false
								end
							end
						end
					end
				end
			end

			if (key == "left" and state == "down") then
				if selectorActivated then
						for i=1, plus-1 do
							if (isInSlot(mySavedConfig[selectedWithSelector[i]]["x"]+fixTable[selectedWithSelector[i]]["xplus"], mySavedConfig[selectedWithSelector[i]]["y"]+fixTable[selectedWithSelector[i]]["yplus"], mySavedConfig[selectedWithSelector[i]]["width"]+fixTable[selectedWithSelector[i]]["width"], mySavedConfig[selectedWithSelector[i]]["height"]+fixTable[selectedWithSelector[i]]["height"])) then
								movingWithSelector = true
							end
							egerW = {getCursorPosition()}
							egerP = {egerW[1]*x, egerW[2]*y}
							selectorOffSetX[i] = egerP[1] - mySavedConfig[selectedWithSelector[i]]["x"]
							selectorOffSetY[i] = egerP[2] - mySavedConfig[selectedWithSelector[i]]["y"]
						end
				end
			else
				 movingWithSelector = false
			end

			if selectorActivated and not movingWithSelector then
				for i=1, plus-1 do
					if not (isInSlot(mySavedConfig[selectedWithSelector[i]]["x"]+fixTable[selectedWithSelector[i]]["xplus"], mySavedConfig[selectedWithSelector[i]]["y"]+fixTable[selectedWithSelector[i]]["yplus"], mySavedConfig[selectedWithSelector[i]]["width"]+fixTable[selectedWithSelector[i]]["width"], mySavedConfig[selectedWithSelector[i]]["height"]+fixTable[selectedWithSelector[i]]["height"])) then
						if (key == "left" and state == "down") then
							selectorActivated = false
						end
					end
				end
			end

			if (key == "left" and state == "down") then
					if (isInSlot(mySavedConfig[7]["x"]+mySavedConfig[7]["width"],mySavedConfig[7]["y"]+mySavedConfig[7]["height"],20,20)) then
						startingcursorpos2 = {getCursorPosition()}
						startingcursorposszor2 = {startingcursorpos2[1]*x, startingcursorpos2[2]*y}
						atvisszukx = mySavedConfig[7]["width"]
						atvisszuky = mySavedConfig[7]["height"]
						cansizeRadar = true
					else
						cansizeRadar = false
					end
					if (isInSlot(mySavedConfig[1]["x"]+fixTable[1]["xplus"]+mySavedConfig[1]["width"]+fixTable[1]["width"], mySavedConfig[1]["y"]+fixTable[1]["yplus"]+mySavedConfig[1]["height"],20,20)) then
						startingcursorpos3 = {getCursorPosition()}
						startingcursorposszor3 = {startingcursorpos3[1]*x, startingcursorpos3[2]*y}
						atvisszukHudx = mySavedConfig[1]["width"]
						atvisszukHudy = mySavedConfig[1]["height"]
						cansizeHud = true
					else
						cansizeHud = false
					end
					if (isInSlot(mySavedConfig[4]["x"]+fixTable[4]["xplus"]+mySavedConfig[4]["width"]+fixTable[4]["width"], mySavedConfig[4]["y"]+fixTable[4]["yplus"]+mySavedConfig[4]["height"]+fixTable[4]["height"], 20, 20)) then
						startingcursorpos2 = {getCursorPosition()}
						startingcursorposszor2 = {startingcursorpos2[1]*x, startingcursorpos2[2]*y}
						atvisszukStaminaX = mySavedConfig[4]["width"]
						atvisszukStaminaY = mySavedConfig[4]["height"]
						canSizeStamina = true
					else
						canSizeStamina = false
					end
					if (isInSlot(mySavedConfig[22]["x"]+fixTable[22]["xplus"]+mySavedConfig[22]["width"]+fixTable[22]["width"], mySavedConfig[22]["y"]+fixTable[22]["yplus"]+mySavedConfig[22]["height"]+fixTable[22]["height"], 20, 20)) then
						startingcursorpos2 = {getCursorPosition()}
						startingcursorposszor2 = {startingcursorpos2[1]*x, startingcursorpos2[2]*y}
						atvisszukChatX = mySavedConfig[22]["width"]
						atvisszukChatY = mySavedConfig[22]["height"]
						canSizeChat = true
					else
						canSizeChat = false
					end
		end
		if (key == "left" and state == "up") then
				if cansizeRadar then
					cansizeRadar = false
				end
				if cansizeHud then
					cansizeHud = false
				end
				if canSizeStamina then
					canSizeStamina = false
				end
				if canSizeChat then
					canSizeChat = false
				end
		end
	else
		hudmozgatasba = false
		mozgat = false
	end
end
addEventHandler ( "onClientClick", getRootElement(), kattint )


-- Szerkesztési shader.
function startShader()
	oldFilmShader, oldFilmTec = dxCreateShader("files/shader.fx")
	addEventHandler("onClientPreRender", root, renderShader)
end

function renderShader()
	upDateScreenSource()
    if (oldFilmShader) then
        local flickering = math.random(100 - flickerStrength, 100)/100
        dxSetShaderValue(oldFilmShader, "ScreenSource", myScreenSource);
        dxSetShaderValue(oldFilmShader, "Flickering", flickering);
        dxDrawImage(0, 0, x, y, oldFilmShader)
    end
end

function stopShader()
	removeEventHandler("onClientPreRender", root, renderShader)
end

function upDateScreenSource()
    dxUpdateScreenSource(myScreenSource)
end
-- Shader vége.

-- egyéb kellékek


function toggleEditor()
 	if not getElementData(localPlayer, "loggedin") then return end
  -- if not isCursorShowing (localPlayer) then return end
	if szerkesztesmod then
		checkJSON_File()
		ordnenInSelector()
		--setElementData(localPlayer,"Panel->open",true)
	else
		fileDelete("hud.json")
		local file = fileCreate("hud.json")
		fileWrite(file, toJSON(mySavedConfig))
		fileClose(file)
		ordnenInSelector()
	--	setElementData(localPlayer,"Panel->open",false)
	end
end
bindKey("lctrl", "down", toggleEditor)
bindKey("rctrl", "down", toggleEditor)

bindKey("lctrl", "up", function()
		fileDelete("hud.json")
		local file = fileCreate("hud.json")
		fileWrite(file, toJSON(mySavedConfig))
		fileClose(file)
end)

bindKey("rctrl", "up", function()
	if szerkesztesmod then
		fileDelete("hud.json")
		local file = fileCreate("hud.json")
		fileWrite(file, toJSON(mySavedConfig))
		fileClose(file)
	--	setElementData(localPlayer,"Panel->open",false)
	end
end)

function ordnenInSelector()
	local rechner = 1
	for k, v in pairs(mySavedConfig) do
		if not v["showing"] then
			if rechner < 2 then
				mySavedConfig[myDisabledWidgets[1]]["x"] = 50
			else
				mySavedConfig[myDisabledWidgets[rechner]]["x"] = mySavedConfig[myDisabledWidgets[rechner-1]]["x"] + mySavedConfig[myDisabledWidgets[rechner-1]]["width"] + fixTable[myDisabledWidgets[rechner-1]]["xplus"] + 150
			end
			mySavedConfig[myDisabledWidgets[rechner]]["y"] = 225/2-mySavedConfig[myDisabledWidgets[rechner]]["height"]/2-fixTable[myDisabledWidgets[rechner]]["yplus"]
			rechner = rechner + 1
		end
	end
end
addEventHandler("onClientResourceStart", getRootElement(),ordnenInSelector )

function resetHud()
	if getElementData(localPlayer, "loggedin") then
		for i=1, #boundingBoxes do
				mySavedConfig[i]["x"] = boundingBoxes[i]["x"]
				mySavedConfig[i]["y"] = boundingBoxes[i]["y"]
				mySavedConfig[i]["width"] = boundingBoxes[i]["width"]
				mySavedConfig[i]["height"] = boundingBoxes[i]["height"]
				mySavedConfig[i]["showing"] = boundingBoxes[i]["showing"]
		end
		fileDelete("hud.json")
		local file = fileCreate("hud.json")
		fileWrite(file, toJSON(mySavedConfig))
		fileClose(file)
		ordnenInSelector()
	end
end
addCommandHandler("resethud", resetHud)

addCommandHandler("toghud", function()
	setElementData(localPlayer, "enableall", not getElementData(localPlayer, "enableall"))
end)

function checkJSON_File()
	myDisabledWidgets = {}
	mySavedConfig = {}
	if not fileExists("hud.json") then
		local file = fileCreate("hud.json")
		fileWrite(file, toJSON(boundingBoxes))
		fileClose(file)
		mySavedConfig = boundingBoxes
	else
		local file = fileOpen("hud.json")
		local config = fromJSON(fileRead(file, 9999))

		for k, v in ipairs(config) do
			mySavedConfig[tonumber(k)] = {
				["name"] = tostring(v["name"]),
				["showing"] = convertToBool(v["showing"]),
				["width"] = tonumber(v["width"]),
				["height"] = tonumber(v["height"]),
				["x"] = tonumber(v["x"]),
				["y"] = tonumber(v["y"]),
			}
			if not convertToBool(v["showing"]) then
				myDisabledWidgets[#myDisabledWidgets + 1] = k
			end
		end

		fileClose(file)
	end
end


function processFontAwesomeSheet()
	loadBrowserURL(source, "http://mta/local/files/html/font-awesome/index.html?fa=" .. table.concat(iconList, ",") .. "&ps=" .. table.concat(iconPOTSizes, ",") .. "&s=" .. table.concat(iconSizes, ","))
end

function sheetLoadFail(url, errorCode, errorDescription)
	if not isElement(fontawesomeSheet) then
		fontawesomeSheet = createBrowser(128, 256, true, true)
	end

	setTimer(
		function()
			loadBrowserURL(fontawesomeSheet, "http://mta/local/files/html/font-awesome/index.html?fa=" .. table.concat(iconList, ",") .. "&ps=" .. table.concat(iconPOTSizes, ",") .. "&s=" .. table.concat(iconSizes, ","))
		end,
	1000, 1)
end

function getNode(id, node)
	if mySavedConfig[id] and mySavedConfig[id][node] then
		return mySavedConfig[id][node]
	end
end


function getCursorPositionAdded()
    return cursorX, cursorY
end

local cursorState = isCursorShowing()
local cursorX, cursorY = x/2, y/2
if cursorState then
    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * x, cursorY * y
end

addEventHandler("onClientCursorMove", root,
    function(_, _, xadd, yadd)
        cursorX, cursorY = xadd, yadd
    end
)


function boxesIntersect(x1, y1, w1, h1, x2, y2, w2, h2)
	local horizontal = (x1 < x2) ~= (x1 < x2 + w2) or (x1 + w1 < x2) ~= (x1 + w1 < x2 + w2) or (x1 < x2) ~= (x1 + w1 < x2) or (x1 < x2 + w2) ~= (x1 + w1 < x2 + w2)
	local vertical = (y1 < y2) ~= (y1 < y2 + h2) or (y1 + h1 < y2) ~= (y1 + h1 < y2 + h2) or (y1 < y2) ~= (y1 + h1 < y2) or (y1 < y2 + h2) ~= (y1 + h1 < y2 + h2)

	return (horizontal and vertical)
end

function radarKeret(x, y, sz, m, vastagsag, alpha, nofront)
	dxDrawRectangle ( x, y-vastagsag, sz, vastagsag, tocolor(0,0,0,alpha) ) -- Felso
	if not nofront then
		dxDrawRectangle ( x-vastagsag, y-vastagsag, vastagsag, m+(vastagsag*2), tocolor(0,0,0,alpha) ) -- Bal
	end
	dxDrawRectangle ( x+sz, y-vastagsag, vastagsag, m+(vastagsag*2), tocolor(0,0,0,alpha) ) -- Jobb
	dxDrawRectangle ( x, y+m, sz, vastagsag, tocolor(0,0,0,alpha) ) -- Also
end

function dxDrawBorderedImageSection(x, y, w, h, ux, uy, uw, uh, path, rx, ry, rz, color, postGUI)
	dxDrawImageSection(x - 1, y - 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x - 1, y + 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x + 1, y - 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x + 1, y + 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x, y, w, h, ux, uy, uw, uh, path, rx, ry, rz, color, postGUI)
end



function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end

		if (not bgColor) then
			bgColor = borderColor;
		end

		--> Background
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);

		--> Border
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
end


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

function dxDrawBorderedText(text, x, y, w, h, color, ...)
	local textWithoutHEX = gsub(text, "#%x%x%x%x%x%x", "")
	dxDrawText(textWithoutHEX, x - 1, y - 1, w - 1, h - 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(textWithoutHEX, x - 1, y + 1, w - 1, h + 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(textWithoutHEX, x + 1, y - 1, w + 1, h - 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(textWithoutHEX, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(text, x, y, w, h, color, ...)
end

function drawTextWithBorder(text, offset, x, y, w, h, borderColor, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
	for offsetX = -offset, offset do
		for offsetY = -offset, offset do
			dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), x + offsetX, y + offsetY, w + offsetX, h + offsetY, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
		end
	end

	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end
