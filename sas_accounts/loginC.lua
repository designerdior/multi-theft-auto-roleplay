local banned = false
local logininprogress = false
local font = dxCreateFont("files/myriadproregular.ttf", 20)
local seefont1 = dxCreateFont("files/OpenSans.ttf", 20)
local seefont2 = dxCreateFont("files/OpenSansB.ttf", 20)
local charFont = dxCreateFont("files/OpenSansB.ttf", 30)
local animFont = dxCreateFont("files/OpenSans.ttf", 30)
local seefont3 = dxCreateFont("files/OpenSansL.ttf", 20)
local seefont4 = dxCreateFont("files/OpenSansSB.ttf", 20)
local alairasFont = dxCreateFont("files/lunabar.ttf", 20)
local sx, sy = guiGetScreenSize()
local iW, iH = 512, 512
local allowedMskins = {7, 2, 1, 14, 15, 17, 20, 25, 147}
local allowedWskins = {11, 12, 31, 40, 41, 55, 56, 69, 76}
local Mskinnumber = 1
local Wskinnumber = 1
local lastTick5 = 0
local alphaCanGo = false
local cmCanEdit = false
local weightCanEdit = true
local descCanEdit = false
local atvHeight = ""
local atvWeight = ""
local atvDesc = ""
local registerScreen = false
local loginScreen = true

-- Edits
local invitingText = ""
local actualEditing = ""

-- Login
local userNameEdit = ""
local passWordEdit = ""

-- Register
local regUserNameEdit = ""
local regPassWordEdit = ""
local emailEdit = ""
local allowedShowingPassword = false

local cursorState = false
local lastChangeCursorState = 0

-- logo animation
local nyitasLoading = false
local lastTick2 = 0
local loginloadingWidth = 0
local loginloadingTick = 0
local characterloadingTick = 0

local logoAnim = false
local fologoTick = 0

local sizeAnim = false
local sizeTick = 0

local maximumLetter = 20

local charNameEdit = ""
local step = 1
local genderNum = 1

local acceptText = "Megértettem"
local declineText = "Nem értettem meg"
local infoText = ""
local infoStep = 1
local infoFont = dxCreateFont("files/OpenSansB.ttf", 15)
local questions = {
	{"Mit jelent a 'MetaGaming' kifejezés? ", "IC információ felhasználása OOC", "OOC információ felhasználása OOC", "OOC információ felhasználása IC","IC információ felhasználása IC", 3},
	{"Szituáció: Valaki megölt téged egy nyomós indokkal, majd miután te feléledsz, megkeresed és bosszúból megölöd. Melyik szabálysértést követed el?", "SpawnKill", "RevengeKill", "DeathMatch", "Drive-By", 2},
	{"Mit jelent a 'DeathMatch' kifejezés? ", "Ok nélküli ölés", "Este 9 utáni ölés", "Okkal való ölés", "Haláljátszma", 1},
	{"Mi a weboldalunk címe? ", "see-game.hu", "see-game.eu", "see-game.net", "see-game.com", 4},
	{"Mit jelent a 'Drive-By' kifejezés? ", "Autólopás", "Jogosítvány nélküli vezetés", "Járművel való ölés", "Autóvezetés", 3},
	{"Mit jelent az hogy 'RolePlay' ? ", "Szerencsejáték", "Szerepjáték, úgy kell viselkedni, mint a valóéletben", "A szabályok betartása", "Szabálysértés", 2},
	{"Hogyan használom az OOC, azaz karakteren kívüli Chatet? ", "'c' betű vagy /c", "'d' betű vagy /d", "'m' betű vagy /m", "'b' betű vagy /b", 4},
	{"Mit jelent az 'OOC' kifejezés? ", "Out Of Character", "Out Of Charism", "Out Of Change", "Out Of Control", 1},
	{"Hogyan jelented, ha egy játékos nem tartja be a szabályokat? ", "OOC szólok neki", "Nem szólok", "IC szólok neki", "Szólok adminnak vagy panaszkönyvet nyitok", 4},
	{"Mit jelent az 'IC' kifejezés? ", "In Charge", "In Character", "In Case", "In Custom", 2},
}

local camPos = {
	{2419.4853515625, -1713.462890625, 29.102661132813, 2455.763671875, -1737.6796875, 13.62636089325},
	{1804.9326171875, -1710.36328125, 31.542198181152,1829.212890625, -1748.248046875, 18.942230224609}
}
local camrandom = math.random(1,2)

local randomQuestionNumber = 1
local counter = 0
local point = 0

local loaded = false

local loadingSzoveg = {"SeeMTA v3 betöltése...", "Felhasználó hitelesítése...", "Karakter betöltése..."}
local szovegAlpha = 165
local szam = 1

local nyitasCharloading = false
local lastTick3 = 0
local characterloadingWidth = 0
local charloadingSzoveg = {"Adatok betöltése...", "Szinkronizációk folyamatban...", "Belépés See-Citybe..."}
local szovegAlpha2 = 165
local szam2 = 1

local sx, sy = guiGetScreenSize()
local viewStep = 0
local isOnShow = false

local spamTimer

local view = {
	[1] = {
		[1] = {
			["posX"] 	=  358.353515625-2,
			["posY"] 	=  -2026.806640625-1,
			["posZ"] 	=  13.393149375916,
			["lookX"] 	=  362.2490234375-2,
			["lookY"] 	= -2027-1,
			["lookZ"] 	=  11.593148231506,
			["speed"]	=  2000
		},
		[2] = {
			["posX"] 	=  372.4375-2,
			["posY"] 	= -2027.4482421875-1,
			["posZ"] 	=  9,
			["lookX"] 	=  375.736328125-2,
			["lookY"] 	= -2027.494140625-1,
			["lookZ"] 	=  9
		}
	}
}

local alapBeallitasok = {"", "", 0}

setCameraMatrix(1804.9326171875, -1710.36328125, 31.542198181152,1829.212890625, -1748.248046875, 18.942230224609)

function characterHandler(character)
	if actualEditing == "username" then
		maximumLetter = 20
	end
	if (string.len(invitingText) <= maximumLetter) then
		invitingText = invitingText .. character
	end

	if not loginScreen then
		if step == 1 then
			if (string.len(charNameEdit) <= 20) then
				charNameEdit = charNameEdit .. character
			end
		end
		if step == 4 then
			if (string.len(charNameEdit) <= 40) then
				charNameEdit = charNameEdit .. character
			end
		end

		if step == 2 then
			local newText = charNameEdit .. character

			if tonumber(newText) then
				if tonumber(newText) >= 1 and not string.find(newText, "e") and not string.find(newText, " ") and tonumber(newText) <= 90 then
					charNameEdit = newText
				end
			end
		end
		if step == 8 and not cmCanEdit and not descCanEdit and weightCanEdit then
			local newText = charNameEdit .. character

			if tonumber(newText) then
				if tonumber(newText) >= 1 and not string.find(newText, "e") and not string.find(newText, " ") and tonumber(newText) <= 90 then
					charNameEdit = newText
				end
			end
		end
		if step == 8 and cmCanEdit and not descCanEdit and not weightCanEdit then
			local newText = charNameEdit .. character

			if tonumber(newText) then
				if tonumber(newText) >= 1 and not string.find(newText, "e") and not string.find(newText, " ") and tonumber(newText) <= 230 then
					charNameEdit = newText
				end
			end
		end
		if step == 8 and not cmCanEdit and descCanEdit and not weightCanEdit then
			if (string.len(charNameEdit) <= 120) then
				charNameEdit = charNameEdit .. character
			end
		end
	end
end

function GTAcameramovement()
	toggleAllControls(false)
	local x,y,z = getElementPosition(localPlayer)
	setCameraMatrix(x,y,z+450,x,y,z)
	playSound("files/login/bong.mp3")
	setTimer(function()
		smoothMoveCamera(x,y,z+450,x,y,z,x,y,z+200,x,y,z,2500, "InQuad")
		setTimer(function()
			playSound("files/login/bong.mp3")
		end, 2500, 1)
		setTimer(function()
			smoothMoveCamera(x,y,z+200,x,y,z,x,y,z+60,x,y,z,2500, "InQuad")
			setTimer(function()
				playSound("files/login/bong.mp3")
			end, 2500, 1)
			setTimer(function()
				smoothMoveCamera(x,y,z+60,x,y,z,x,y,z,x,y,z,1500, "InQuad")
				setTimer(function()
					stopSmoothMoveCamera()
					setCameraTarget(localPlayer, localPlayer)
					toggleAllControls(true)
					triggerEvent("assignBones", localPlayer)
				end, 1450, 1)
			end, 3500, 1)
		end, 3500, 1)
	end, 1500, 1)
end

function getNetworkConnection()
	if getNetworkStats().packetlossLastSecond < 5 then
        return true
	end
	return false
end

function isSpam()
    if isTimer(spamTimer) then
        return true
    end
    spamTimer = setTimer(function() end, 5000, 1)
    return false
end

function isInSlot(rectX, rectY, rectW, rectH)
	local cursorX, cursorY = getCursorPosition()
	local cursorX, cursorY = cursorX * sx, cursorY * sy
	return (cursorX >= rectX and cursorX <= rectX+rectW) and (cursorY >= rectY and cursorY <= rectY+rectH)
end

addEventHandler("onClientResourceStop", resourceRoot, function()
	local posF = xmlLoadFile("remember.xml")
	if posF then
		xmlNodeSetValue(xmlFindChild(posF, "user", 0), alapBeallitasok[1])
		xmlNodeSetValue(xmlFindChild(posF, "pass", 0), alapBeallitasok[2])
		xmlNodeSetValue(xmlFindChild(posF, "vilagit", 0), alapBeallitasok[3])
		xmlSaveFile(posF)
	end
end)

function displayinOrdnung()
	local time = getTickCount() - lastChangeCursorState

	if time >= 500 then
		cursorState = not cursorState
		lastChangeCursorState = getTickCount()
	end

	if isInSlot(sx/2-250/2+35-43, sy/2+40+40+40, 266, 34) then
		dxDrawImage(sx/2-iW/2, sy/2-iH/2, iW, iH, "files/login/belepes.png")
	elseif isInSlot(sx/2-250/2+35-43, sy/2+40+80+44, 266, 34) then
		dxDrawImage(sx/2-iW/2, sy/2-iH/2, iW, iH, "files/login/reg.png")
	end
	-- seeloginrender
	dxDrawImage(sx/2-iW/2, sy/2-iH/2, iW, iH, "files/login/main.png")
	--logo
	local cTick = getTickCount ()
	local progressLoading = (cTick - fologoTick)/300
	if logoAnim then
		left,top,_ = interpolateBetween (
			0,0,0,
			50,24,0,
			progressLoading,"Linear"
		)
	end
	if not logoAnim then
		left,top,_ = interpolateBetween (
			50,22,0,
			0,0,0,
			progressLoading,"Linear"
		)
	end

	local progressLoading = (cTick - sizeTick)/200
	if sizeAnim then
		sizeX,sizeY,_ = interpolateBetween (
			0,0,0,
			50,50,0,
			progressLoading,"Linear"
		)
		if logoAnim then
			sizeX2,sizeY2,_ = interpolateBetween (
				0,0,0,
				5,2,0,
				progressLoading,"Linear"
			)
		else
			sizeX2 = 0
			sizeY2 = 0
		end
	end
	if not sizeAnim then
		sizeX,sizeY,_ = interpolateBetween (
			50,50,0,
			0,0,0,
			progressLoading,"Linear"
		)
		if logoAnim then
			sizeX2,sizeY2,_ = interpolateBetween (
				5,2,0,
				0,0,0,
				progressLoading,"Linear"
			)
		else
			sizeX2 = 0
			sizeY2 = 0
		end
	end

	dxDrawImage(sx/2-iW/2+left+sizeX/2-sizeX2, sy/2-iH/2+top+sizeY/2-sizeY2, iW-sizeX, iH-sizeY, "files/login/logo1.png")
	dxDrawImage(sx/2-iW/2-left+sizeX/2+sizeX2, sy/2-iH/2+top+sizeY/2-sizeY2, iW-sizeX, iH-sizeY, "files/login/logo2.png")
	dxDrawImage(sx/2-iW/2+sizeX/2, sy/2-iH/2+sizeY/2, iW-sizeX, iH-sizeY, "files/login/logo3.png",0,0,0,tocolor(255,255,255,255))

    if actualEditing == "username" then
      userNameEdit = invitingText
		if cursorState then
			local w = dxGetTextWidth(userNameEdit, 0.65, seefont1)

			dxDrawLine(sx/2-80+w, sy/2-5, sx/2-80+w, sy/2+19, tocolor(255, 255, 255, lineAlpha), 2)
		end
    end
    dxDrawText(userNameEdit, sx/2-250/2+35+5, sy/2-35/2+7, 0, sy/2-35/2+7+35, tocolor(255,255,255, 255), 0.65, seefont1, "left", "center")

    actualPassword = passWordEdit
    local visiblePassword = "", 0
    for i=1,#actualPassword do
        visiblePassword = visiblePassword .. "*"
    end

    if actualEditing == "password" then
      passWordEdit = invitingText
		if cursorState then
			local w = dxGetTextWidth(visiblePassword, 0.65, seefont1)
			dxDrawLine(sx/2-80+w, sy/2-5+50, sx/2-80+w, sy/2+19+50, tocolor(255, 255, 255, lineAlpha), 2)
		end
    end
    dxDrawText(visiblePassword, sx/2-250/2+35+5, sy/2+40, 0, sy/2+40+35, tocolor(255,255,255, 255), 0.65, seefont1, "left", "center")

		--kattintás helye
	if alapBeallitasok[3] == 1 then
		dxDrawImage(sx/2-iW/2, sy/2-iH/2, iW, iH, "files/login/remember_on.png")
	end

	if alapBeallitasok[3] == 1 then
		alapBeallitasok[1] = userNameEdit
		alapBeallitasok[2] = passWordEdit
	end
end

function displayLoginBox()
	fadeCamera(true)

	if alapBeallitasok[3] == 1 then
		if alapBeallitasok[1] and alapBeallitasok[2] then
			userNameEdit = alapBeallitasok[1]
			passWordEdit = alapBeallitasok[2]
		end
	end

	loginScreen = true
	exports.sas_system:elmosasBekapcsolasa()
end

function allowedRegister()
	removeEventHandler("onClientRender", getRootElement(), displayinOrdnung)
	addEventHandler("onClientRender", getRootElement(), renderRightsPanel)
	loginScreen = false
	showRights = true
end
addEvent("allowedRegister", true)
addEventHandler("allowedRegister", localPlayer, allowedRegister)

function renderRightsPanel()
	if isInSlot(sx/2-206, sy/2+190, 201, 34) then
		dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_accept.png")
	elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
		dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_decline.png")
	else
		dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_inactive.png")
	end
	dxDrawText("Elfogad", sx/2-130, sy/2+197, 0, 0, tocolor(255,255,255,255),0.5, seefont2)
	dxDrawText("Elutasít", sx/2+75, sy/2+197, 0, 0, tocolor(255,255,255,255),0.5, seefont2)
	dxDrawText("Üdvözöllek a #7cc576SeeMTA-n#FFFFFF, Magyarország\n legnagyobb valósélet szerverén.\n Amennyiben úgy döntesz, hogy kipróbálod \n játékunkat, jó szórakozást kíván a #7cc576csapatunk#FFFFFF!\n #d9534fFigyelem!\n #FFFFFFAhhoz, hogy továbblépj el kell fogadnod a\n szabályzatot és az ahhoz tartozó feltételeket.\n Bővebb infó szabályzatról és feltételekről:\n #32b3efwww.see-game.com-> Szabályzat\n #d9534fA szabályok nem ismerete nem\n mentesít a bűntetés alól!", sx/2, sy/2-90, sx/2, sy/2-100, tocolor(255,255,255,255),0.67, seefont2, "center", "top",false,false,false,true)
end

function clickOnThings(button, press)
	if not press then return end
	if button ~= "mouse_wheel_up" and button ~= "mouse_wheel_down" and button ~= "mouse1" and button ~= "mouse2" and button ~= "mouse3" and not getElementData(localPlayer, "loggedin") and actualEditing ~= "" then
		local keys = playSound("files/login/key1.mp3")
		setSoundVolume(keys, 1)
	end
	if button == "backspace" then
		if string.len(invitingText) >= 1 then
			invitingText = string.sub(invitingText, 1, string.len(invitingText)-1)
		end
	end
	if button == "mouse1" then
		actualEditing = ""
		if loginScreen then
			if isInSlot(sx/2-iW/2+125+1, sy/2+iH/2-150-13, 10,10) then
				if alapBeallitasok[3] == 0 then
					alapBeallitasok[3] = 1
					playSound("files/login/bubble.mp3")
				elseif alapBeallitasok[3] == 1 then
					alapBeallitasok[3] = 0
					playSound("files/login/bubble.mp3")
				end
			elseif isInSlot(sx/2-250/2+35, sy/2-35/2+7, 223, 35) then
				actualEditing = "username"
				invitingText = userNameEdit
			elseif isInSlot(sx/2-250/2+35, sy/2+40, 223, 35) then
				actualEditing = "password"
				invitingText = passWordEdit
			elseif isInSlot(sx/2-250/2+35-43, sy/2+40+40+40, 266, 34) then
				validateDetails(true)
			elseif isInSlot(sx/2-250/2+35-43, sy/2+40+80+44, 266, 34) then
				if not getNetworkConnection() or isSpam() then return end
				triggerServerEvent("allowRegister", localPlayer)
			end
		elseif registerScreen then
			if isInSlot(sx/2-512/2+125+1, sy/2+512/2-124, 10,10) then
				if not allowedShowingPassword then
					allowedShowingPassword = true
					playSound("files/login/bubble.mp3")
				elseif allowedShowingPassword then
					allowedShowingPassword = false
					playSound("files/login/bubble.mp3")
				end
			elseif isInSlot(sx/2-250/2+35, sy/2-35/2+7, 223, 35) then
				actualEditing = "reguser"
				invitingText = regUserNameEdit
			elseif isInSlot(sx/2-250/2+35, sy/2+40, 223, 35) then
				actualEditing = "regpass"
				invitingText = regPassWordEdit
			elseif isInSlot(sx/2-250/2+35, sy/2+40+13+35, 223, 35) then
				actualEditing = "email"
				invitingText = emailEdit
			elseif isInSlot(sx/2-250/2+35-43, sy/2+40+40+40+40, 266, 34) then
				validateDetails()
			end
		elseif showRights then
			if isInSlot(sx/2-206, sy/2+190, 201, 34) then
				removeEventHandler("onClientRender", getRootElement(), renderRightsPanel)
				addEventHandler("onClientRender", getRootElement(), charFirstRender)
				step = 1
				showRights = false
				showFirstCharacterCreation = true
				charCreateFirstStep()
			elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
				addEventHandler("onClientRender", getRootElement(), displayinOrdnung)
				removeEventHandler("onClientRender", getRootElement(), renderRightsPanel)
				showRights = false
				loginScreen = true
			end
		elseif testStep then
			if isInSlot(sx/2-206, sy/2+190, 201, 34) then
				if infoStep < 17 then
					infoStep = infoStep + 1
				end
				if infoStep == 17 then
					testStart()
				end
			elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
				if infoStep <= 17 then
					infoStep = infoStep - 1
				end
				if infoStep <= 1 then
					infoStep = 1
				end
			end
		elseif doingTest then
			if isInSlot(sx/2-205, sy/2+58, 409, 33) then
				isCorrect(1)
			end
			if isInSlot(sx/2-205, sy/2+58+33+12, 409, 33) then
				isCorrect(2)
			end
			if isInSlot(sx/2-205, sy/2+58+33+33+10+13, 409, 33) then
				isCorrect(3)
			end
			if isInSlot(sx/2-205, sy/2+58+33+33+33+10+10+14,409,33) then
				isCorrect(4)
			end
		elseif falschGemacht then
			if isInSlot(sx/2-206, sy/2+190, 201, 34) then -- újrakezdés
				point = 0
				randomQuestionNumber = 1
				counter = 0
				doingTest = true
				falschGemacht = false
			end
		elseif gutGemacht then
			if isInSlot(sx/2-206, sy/2+190, 201, 34) then -- tovább
				registerScreen = true
				removeEventHandler("onClientRender", getRootElement(), testStartRender)
				addEventHandler("onClientRender", getRootElement(), registerRender)
			end
		end
	end
	if button == "backspace" then
		if string.len(charNameEdit) >= 1 then
			charNameEdit = string.sub(charNameEdit, 1, string.len(charNameEdit)-1)
		end
  	end
	if button == "arrow_r" then
		if step == 3 then
			genderNum = 2
			if genderNum == 2 then
				setElementModel(localPlayer, 11)
			end
		end
		if step == 5 then
			if atvGender == 0 then
				Mskinnumber = Mskinnumber + 1
				if Mskinnumber >= 10 then -- muss ändern wenn man mehrere Skins eintragen will
					Mskinnumber = 1
				end
				setElementModel(localPlayer, allowedMskins[Mskinnumber])
			end
			if atvGender == 1 then
				Wskinnumber = Wskinnumber + 1
				if Wskinnumber >= 10 then -- muss ändern wenn man mehrere Skins eintragen will
					Wskinnumber = 1
				end
				setElementModel(localPlayer, allowedWskins[Wskinnumber])
			end
		end
	end
	if button == "arrow_l" then
		if step == 3 then
			genderNum = 1
			if genderNum == 1 then
				setElementModel(localPlayer, 7)
			end
		end
		if step == 5 then
			if atvGender == 0 then
				Mskinnumber = Mskinnumber - 1
				if Mskinnumber <= 0 then
					Mskinnumber = 9
				end
				setElementModel(localPlayer, allowedMskins[Mskinnumber])
			end
			if atvGender == 1 then
				Wskinnumber = Wskinnumber - 1
				if Wskinnumber <= 0 then
					Wskinnumber = 9
				end
				setElementModel(localPlayer, allowedWskins[Wskinnumber])
			end
		end
	end
	if button == "enter" then
		if loginScreen then
			validateDetails(true)
		elseif loginLoaded then
			if not getNetworkConnection() then return end
			addEventHandler("onClientRender", getRootElement(), characterLoading)
			stopSound(charSound)
			characterloadingTick = getTickCount()
			loginLoaded = false
			loadingSound = playSound(":sas_hud/files/loading.mp3")
		elseif registerScreen then
			validateDetails()
		elseif step == 1 and not showRights and canCreate then
			checkName()
		elseif step == 2 and not showRights and canCreate then
			if tonumber(charNameEdit) >= 17 and tonumber(charNameEdit) <= 90 then
				atvAge = charNameEdit
				charNameEdit = ""
				step = 3
			else
				exports.sas_hud:addNotification("Korodnak 17 és 90 év közé kell esnie!", "error")
			end
		elseif step == 3 and not showRights and canCreate then
			smoothMoveCamera(1230.9383544922, -2489.9848632813, 136.55610656738-0.4, 1230.5339355469, -2490.8918457031, 136.43827819824-0.4,1232.0759277344, -2491.4562988281, 136.87739562988, 1231.216796875, -2491.9045410156, 136.63075256348, 1000)
			if genderNum == 1 then
				atvGender = 0
			end
			if genderNum == 2 then
				atvGender = 1
			end
			step = 4
		elseif step == 4 and not showRights and canCreate then
			if (string.len(charNameEdit) >= 20) then
				step = 5
				charNameEdit = ""
			else
				exports.sas_hud:addNotification("Karaktered rövid leírásának 20 és 40 karakter között kell lennie!", "error")

			end
		elseif step == 5 and not showRights and canCreate then
			if atvGender == 0 then
				atvSkindID = allowedMskins[Mskinnumber]
			end
			if atvGender == 1 then
				atvSkindID = allowedWskins[Wskinnumber]
			end
			setElementAlpha(localPlayer, 0)
			planeFlight()
			step = 6
		elseif step == 8 and not showRights and canCreate and weightCanEdit then
			if tonumber(charNameEdit) >= 40 and tonumber(charNameEdit) <= 90 then
				atvWeight = charNameEdit
				weightCanEdit = false
				cmCanEdit = true
				charNameEdit = ""
				exports.sas_hud:addNotification("Add meg a karaktered magasságát! (120-230cm)", "warning")

			else
				exports.sas_hud:addNotification("Súlyodnak 40 kg és 90 kg között kell lennie!", "error")
			end
		elseif step == 8 and not showRights and canCreate and cmCanEdit then
			if tonumber(charNameEdit) >= 120 and tonumber(charNameEdit) <= 230 then
				atvHeight = charNameEdit
				cmCanEdit = false
				descCanEdit = true
				charNameEdit = ""
				exports.sas_hud:addNotification("Add meg a karaktered leírását! (minimum 10 karakter)", "warning")
			else
				exports.sas_hud:addNotification("Magasságod 120cm és 230cm között kell lennie!", "error")
			end
		elseif step == 8 and not showRights and canCreate and descCanEdit then
			if (string.len(charNameEdit) <= 10) then
				exports.sas_hud:addNotification("Karakter leírásodnak minimum 10 karakternek kell lennie!", "error")
			else
				atvDesc = charNameEdit
				descCanEdit = false
				charNameEdit = ""
				step = 9
				airportText = ""
				fadeCamera(false)
				airportEffect()
			end
		end
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	setElementData(localPlayer, "enableall", false)
	setElementData(localPlayer, "loggedin", false)

	engineImportTXD(engineLoadTXD("files/at400.txd"), 577)
	engineReplaceModel(engineLoadDFF("files/at400.dff", 0), 577)

	setElementDimension(localPlayer, 65500)
	setElementInterior(localPlayer, 0)

	if not xmlLoadFile("remember.xml") then
	  	local posF = xmlCreateFile("remember.xml", "root")
		xmlNodeSetValue(xmlCreateChild(posF, "user"), alapBeallitasok[1])
		xmlNodeSetValue(xmlCreateChild(posF, "pass"), alapBeallitasok[2])
		xmlNodeSetValue(xmlCreateChild(posF, "vilagit"), alapBeallitasok[3])
		xmlSaveFile(posF)
	else
		local posF = xmlLoadFile("remember.xml")
		alapBeallitasok[1] = xmlNodeGetValue(xmlFindChild(posF, "user", 0))
		alapBeallitasok[2] = xmlNodeGetValue(xmlFindChild(posF, "pass", 0))
		alapBeallitasok[3] = tonumber(xmlNodeGetValue(xmlFindChild(posF, "vilagit", 0)))
	end

	showChat(false)
	showCursor(true)
	addEventHandler("onClientRender", getRootElement(), displayinOrdnung)
	addEventHandler("onClientCharacter", getRootElement(), characterHandler)
	addEventHandler("onClientKey", getRootElement(), clickOnThings)
	displayLoginBox()
	
	timer = setTimer(function()
		if not nyitasCharloading then
			nyitasCharloading = true
			lastTick3 = getTickCount()
		elseif nyitasCharloading then
			nyitasCharloading = false
			lastTick3 = getTickCount()
		end
	end, 2000, 0)
	
	timer1 = setTimer(function()
		if not nyitasLoading then
			nyitasLoading = true
			lastTick2 = getTickCount()
		elseif nyitasLoading then
			nyitasLoading = false
			lastTick2 = getTickCount()
		end
	end, 2000, 0)
	
	timer2 = setTimer(function()
		if not logoAnim then
			logoAnim = true
			fologoTick = getTickCount()
		elseif logoAnim then
			logoAnim = false
			fologoTick = getTickCount()
		end
	end, 3500, 0)
	
	timer3 = setTimer(function()
		if not sizeAnim then
			sizeAnim = true
			sizeTick = getTickCount()
		end
		setTimer(function()
			sizeAnim = false
			sizeTick = getTickCount()
		end, 400, 1)
	end, 3000, 0)
end)

function airportEffect()
	fadeCamera(true)
	setCameraMatrix(1673.4250488281, -2320.1997070313, 16.455625534058, 1740.6979980469, -2386.4812011719, -16.42506980896)
	setElementPosition(playerClone, 1685.693359375, -2335.49609375, 13.546875)
	setElementRotation(playerClone, 0,0,358)
	setElementDimension(playerClone, 0)
	setElementInterior(playerClone, 0)
	setElementDimension(localPlayer, 0)
	setElementInterior(localPlayer, 0)
	pedTimer = setTimer(function()
		setPedAnimation(playerClone, "PED", "WALK_player", -1)
		pedTimer = setTimer(function()
			setPedAnimation(playerClone)
			fadeCamera(false)
			pedTimer = setTimer(function()
				cityEffect()
				destroyElement(playerClone)
				removeEventHandler("onClientRender", getRootElement(), charFirstRender)
				addEventHandler("onClientRender", getRootElement(), cityEffectRender)
			end, 1000, 1)
		end, 4000, 1)
	end, 1000, 1)
end

local building = ""
local cityText = ""
local titleText = ""
local timeOut = 1000

function cityEffect()
	fadeCamera(false)
	cityTimer = setTimer(
		function()
			fadeCamera(true)
			building = "varoshaza"
			smoothMoveCamera(1108.298828125, -1728.3402099609, 69.708740234375, 1189.0279541016, -1759.9434814453, 19.868497848511, 1170.1547851563, -1693.4051513672, 55.209022521973, 1222.5037841797, -1771.2277832031, 20.521728515625, 2000)
			cityTimer = setTimer(
				function()
					fadeCamera(false)
					cityTimer = setTimer(
							function()
								fadeCamera(true)
								building = "deli"
								smoothMoveCamera(2001.8000488281, -1718.2373046875, 49.875686645508, 1933.9064941406, -1778.8198242188, 8.4002227783203, 1970.2102050781, -1740.2888183594, 23.774597167969, 1899.3542480469, -1807.3940429688, 1.94986140728, 2000)
								cityTimer = setTimer(
										function()
											fadeCamera(false)
											cityTimer = setTimer(
													function()
															fadeCamera(true)
															building = "bonto"
															smoothMoveCamera(2252.5830078125, -2025.4766845703, 45.967998504639, 2165.9130859375, -1990.4371337891, 10.463704109192,2230.44140625, -1986.4916992188, 23.066955566406, 2137.48046875, -1965.1760253906, -6.9981298446655, 2000)
															cityTimer = setTimer(
																	function()
																		fadeCamera(false)
																		cityTimer = setTimer(
																				function()
																					fadeCamera(true)
																					building = "taxi"
																					smoothMoveCamera(2090.1423339844, -1781.7156982422, 34.157871246338, 2188.1264648438, -1778.7855224609, 14.395816802979,2106.6708984375, -1782.5349121094, 30.25749206543, 2206.5532226563, -1780.4200439453, 25.896377563477, 2000)
																					cityTimer = setTimer(
																							function()
																								fadeCamera(false)
																								cityTimer = setTimer(
																										function()
																											fadeCamera(true)
																											building = "binco"
																											smoothMoveCamera(2288.9208984375, -1639.3394775391, 40.157608032227, 2220.6201171875, -1707.8948974609, 14.955324172974,2264.7795410156, -1652.9167480469, 17.958019256592, 2187.1999511719, -1715.3095703125, 8.5489587783813 ,2000)
																											cityTimer = setTimer(
																													function()
																														fadeCamera(false)
																														cityTimer = setTimer(
																																function()
																																	fadeCamera(true)
																																	building = "autoker"
																																	smoothMoveCamera(2159.4711914063, -1076.56640625, 58.407028198242, 2134.927734375, -1168.1696777344, 26.6823387146 , 2136.353515625, -1099.5102539063, 36.206016540527, 2121.6313476563, -1196.8541259766, 18.67261505127,2000)
																																	cityTimer = setTimer(
																																			function()
																																				fadeCamera(false)
																																				cityTimer = setTimer(
																																						function()
																																							fadeCamera(true)
																																							building = "szerelo"
																																							smoothMoveCamera(1717.9154052734, -1253.4916992188, 60.106842041016, 1716.7127685547, -1159.3502197266, 26.403423309326, 1716.9689941406, -1184.162109375, 34.00704574585, 1716.4122314453, -1088.0843505859, 6.2806735038757,2000)
																																							cityTimer = setTimer(
																																								function()
																																									fadeCamera(false)
																																									cityTimer = setTimer(
																																									function()
																																										fadeCamera(true)
																																										building = "bank"
																																										smoothMoveCamera(1577.857421875, -1060.2624511719, 74.206634521484, 1487.2858886719, -1027.6311035156, 47.151561737061,1507.3693847656, -1036.4907226563, 41.105834960938, 1420.3865966797, -1000.6163330078, 7.2381768226624,2000)
																																										cityTimer = setTimer(
																																												function()
																																													fadeCamera(false)
																																													cityTimer = setTimer(
																																															function()
																																																fadeCamera(true)
																																																building = "tuning"
																																																smoothMoveCamera(992.58093261719, -956.48901367188, 64.017295837402, 1037.2559814453, -874.29925537109, 28.676187515259,1016.4141235352, -930.31011962891, 49.016792297363, 1076.9851074219, -856.37176513672, 19.618143081665,2000)
																																																cityTimer = setTimer(
																																																		function()
																																																			fadeCamera(false)
																																																			cityTimer = setTimer(
																																																					function()
																																																						fadeCamera(true)
																																																						building = "korhaz"
																																																						smoothMoveCamera(1227.1716308594, -1277.2121582031, 39.007019042969, 1149.2895507813, -1330.6278076172, 6.1263265609741,1206.4206542969, -1303.513671875, 28.806606292725, 1131.9326171875, -1351.2327880859, -17.823961257935,2000)
																																																						cityTimer = setTimer(
																																																								function()
																																																									fadeCamera(false)
																																																									cityTimer = setTimer(
																																																											function()
																																																												fadeCamera(true)
																																																												building = "autosuli"
																																																												smoothMoveCamera(342.48883056641, -1402.0695800781, 38.216800689697, 341.90231323242, -1310.7137451172, -2.4496445655823,342.49996948242, -1377.2365722656, 25.616760253906, 345.91891479492, -1285.3836669922, -13.77041053772,2000)
																																																												cityTimer = setTimer(
																																																														function()
																																																															fadeCamera(false)
																																																															cityTimer = setTimer(
																																																																	function()
																																																																		removeEventHandler("onClientRender", getRootElement(), cityEffectRender)
																																																																		addEventHandler("onClientRender", getRootElement(), beforeTestRender)
																																																																		beforeTest()
																																																																	end, 1000, 1
																																																															)
																																																														end, timeOut, 1
																																																												)
																																																											end, 1000, 1
																																																									)
																																																								end, timeOut, 1
																																																						)
																																																					end, 1000, 1
																																																			)
																																																		end, timeOut, 1
																																																)
																																															end, 1000, 1
																																													)
																																												end, timeOut, 1
																																										)
																																									end, 1000, 1
																																									)
																																								end, timeOut, 1
																																							)
																																						end, 1000, 1
																																				)
																																			end, timeOut, 1
																																	)
																																end, 1000, 1
																														)
																													end, timeOut, 1
																											)
																										end, 1000, 1
																								)
																							end, timeOut, 1
																					)
																				end, 1000, 1
																		)
																	end, timeOut, 1
															)
													end, 1000, 1
											)
										end, timeOut, 1
								)
							end, 1000, 1
					)
				end, timeOut, 1
		)
		end, 1000, 1
	)
end

function cityEffectRender()
	dxDrawImage(sx/2-150, sy-300, 300, 200, "files/bg.png")
	dxDrawText(titleText, sx/2, sy/2+257, sx/2, sy/2+257,tocolor(255,255,255,255), 0.8, seefont2, "center", "top")
	dxDrawText(cityText, sx/2-130, sy-250, sx/2+130, sy-100-10,tocolor(255,255,255,255), 0.5, seefont3, "center", "center", false, true)
	if building == "varoshaza" then
		titleText = "Városháza"
		cityText = "Íme a városháza, a város egyik legfontosabb helyszíne. Itt tudsz munkát szerezni, vállalkozással foglalkozni, személyi igazolványt kiváltani. Munka felvételhez menj be és a bal oldali épület földszintjére menj, ahol az ügyintézővel kell beszélgetned (beszélgetéshez jobb klikk az ügyintézőn)"
	elseif building == "deli" then
		titleText = "Déli benzinkút"
		cityText = "Üzemanyagot tudsz tankolni, vagy a shopban vásárolni fontos dolgokat."
	elseif building == "bonto" then
		titleText = "Autóbontó"
		cityText = "Nem tudod eladni a járművedet és csak útban van? Semmi pánik, hozd be a bontóba és add le, még némi pénzt is kapsz cserébe."
	elseif building == "taxi" then
		titleText = "Taxi"
		cityText = "Amennyiben még nincs jogosítványod és nem tudsz vezetni, vagy nincs járműved, hívd a taxisokat, ehhez a telefonodba tárcsázd a 3612-333-333-at."
	elseif building == "binco" then
		titleText = "Ruhabolt"
		cityText = "Öltözködj stílusosan. Ezen a helyen tudsz új ruhákat - kinézetet vásárolni."
	elseif building == "autoker" then
		titleText = "Autókereskedés"
		cityText = "Új autót akarsz vásárolni? Itt mindent megtalálsz ami szem - szájnak ingere. Belépéshez csak menj a kereskedés bejáratához."
	elseif building == "szerelo" then
		titleText = "Szerelőtelep"
		cityText = "Amennyiben járműved megsérült, itt tudod megjavíttatni a szerelőkkel."
	elseif building == "bank" then
		titleText = "Bank"
		cityText = "Itt tudsz bankszámlaszámot nyitni, és számládat kezelni."
	elseif building == "tuning" then
		titleText = "Tuning műhely"
		cityText = "Amennyiben járművedet kicsit egyedibbé akarod tenni, itt ezt megteheted. A teljesítmény tuningtól kezdve az optikai tuningon át, itt mindent megtalálsz."
	elseif building == "korhaz" then
		titleText = "Kórház"
		cityText = "Ha megsérülsz - műtétre szorulsz, akkor menj a kórházba, ha meghalsz, akkor is ide fogsz kerülni."
	elseif building == "autosuli" then
		titleText = "Autós iskola"
		cityText = "Ha a jogosítványt akarod letenni, akkor ide kell jönnöd. Az elméleti vizsgával kezd, majd menj a városi vizsgára. Figyelj arra, amit az oktatód mond neked."
	end
end

function beforeTest()
	fadeCamera(true)
	setCameraMatrix(1141.5557861328, -1712.0080566406, 17.854267120361, 1225.5632324219, -1763.1038818359, 36.074420928955)
	testStep = true
end

function beforeTestRender()
	if testStep then
		if infoStep == 1 then
			infoText = "Amennyiben #ff7f00új #FFFFFFjátékos vagy, kapsz egy kis bevezetőt a játékból,\n hogy mégis, ne tapasztalatlanul csöppenj bele a nagyvárosi életbe! \n \n#d75959Felhívjuk figyelmedet #FFFFFFarra is, hogy megfelelő hozzáállás\n és komolyság nélkül ez nem fog sikerülni."
		end
		if infoStep == 2 then
			infoText = "#6699ccA játék alap koncepciója, hogy szinte bármit megtehetsz.\n\n#FFFFFFEz lehet akár a második életed is,\negyszerű munkásból lehetsz a város egyik legnagyobb maffiózója,\nnetán egy banda vezére, esetleg egy sikeres üzlet ember, avagy a rend \néber őreinek legnagyobb alakja... \n\n#d9534fDe vigyázz#FFFFFF, hamar nincstelen koldussá is válhatsz, ha nem figyelsz oda. \nA lehetőség csak rajtad áll, kérdés, hogy élni tudsz-e vele."
		end
		if infoStep == 3 then
			infoText = "A játék megkívánja a szabályzat teljes ismeretét. Amennyiben ezt nem\ntetted volna meg eddig, kérjük most pótold hiányosságodat\n(#ff7f00see-game.com #FFFFFF-> #6699ccszabályzat#FFFFFF), ugyanis aki nem tartja be a szabályokat,\nrövid időn belül büntetést, (#ff7f00admin zárkát#FFFFFF) vagy teljes, végleges kitiltást\nvonhat maga után (#6699ccÖrök bann#FFFFFF), mely után nem tudsz már visszajönni\nide.\n\nHa már a szabályoknál tartunk, nézzünk át pár alap dolgot együtt,\nérthető példákkal, még ezek után is választhatod azt,\nhogy újra egyszer áttanulmányozod ezeket."
		end
		if infoStep == 4 then
			infoText = "#6699ccIC-OOC:\n#FFFFFFHangzatos kifejezések és egy új játékosnak bizony bonyolult lehet,\nviszont két nagyon fontos fogalomról beszélünk.\nAz #6699ccIC '#ff7f00In Character#FFFFFF'-t jelent, (a karakterben) melyet legjobban úgy\ntudunk szemléltetni, hogy az nem te vagy, hanem az általad kreált\n karakter élete-beszéde-élményei, egyszóval minden.\n\nAz #6699ccOOC '#ff7f00Out of Character#FFFFFF' (karakteren kívüli) eseményeket jelenti.\nEgy szóval, ez te vagy. TE, aki a számítógépen vezérli ezt a karaktert.\nEzek a karakteren kívüli események,beszélgetések,\ntörténések stb. összessége."
		end
		if infoStep == 5 then
			infoText = "Nézzünk erre egy konkrét példát:\nTételezzük fel, hogy a fórumon megnézted, hogy hol található a bank,\nEzt te most #6699ccOOC(#ff7f00out of character#FFFFFF) tudod,\nmivel nem a akaraktered ment fel egy játékban található weboldalra,\nhanem te magad, aki a karaktert irányítja.\nÍgy ez a tudás nem száll át a karakteredre, csak te tudod."
		end
		if infoStep == 6 then
			infoText = "Nézzünk még egy példát, ez magában foglalja az #6699ccIC #FFFFFFChatet\nés az #6699ccOOC #FFFFFFchatet. Téged most a példa kedvéért\nNagy Bélának hívnak a valóságban,\nmíg te Nagy Béla csinálsz a #6699ccSeeMTA#FFFFFF-n egy karaktert,\nakit úgy hívnak, hogy James Everton.\nAmennyiben a játékban NEKED, azaz NAGYBÉLÁNAK van kérdése,\nakkor az#6699cc OOC#FFFFFF chatet kell használnod 'b' betű, vagy /b-vel,\nmelyet ekkor a rendszer érzékel és nem a játékhoz kapcsolja,\nhanem egy külön chat mezőrészen jeleníti meg,\npéldául 'Hogyan kell leülni?'\nvagy 'Milyen gombbal hozom be a tárgyaimat?'."
		end
		if infoStep == 7 then
			infoText = "Azonban ha a karaktereddel akarsz mondani valamit,\nvagyis James Evertonnal akkor simán lenyomod a 't' betűt\nés leírod, amit a karaktered mond 'Szép időnk van', 'jó napot' stb stb.\n\nEz a karaktered és a karaktereden kívüli chat alapja."
		end
		if infoStep == 8 then
			infoText = "Íme a következő fogalom, a #6699ccPG#FFFFFF, (#ff7f00Power Gaming#FFFFFF).\nNagyon sok helyen más és mást jelent,\nnálunk abszolút értelembe a következőket jelenti: #ff7f00hősködés#FFFFFF.\nAzaz úgy játszol, mint ha valami akciófilm szuperhőse lennél\n(4 ember az 1 ellen stb.) Mindig érezned kell a realitás határait,\nmikor van az, mikor megfogtak, mikor van az,\naminek bejátszása már súrolja a realitás- #6699ccjózanész határait."
		end
		if infoStep == 9 then
			infoText = "Nézzünk erre egy példát.\nSétálsz a #6699ccgettó#FFFFFFban mint egy ártatlan melós, épp arra van dolgot,\n ahol 3-4 elég veszélyesnek tűnő fickó kiszúr téged\nés elkezd beszólogatni neked.\nFelmerül a kérdés, visszaszólhatsz nekik?\nVégül is az még nem #6699ccPG#FFFFFF-nek számít,\nhanem idiótaságnak véleményem szerint, ezért ezt csinálod,\nerre persze ők felhúzzák magukat, odamennek hozzád,\nelkapnak és a #d9534ffegyvert#FFFFFF a tarkódhoz tartják...\nBeszóltál nekik, ezért viseled a következményeit,\nitt most két lehetőséged van.\n 1.: nem tartod be a szabályokat és neki állsz #ff7f00hősködni#FFFFFF, azaz #6699ccPG#FFFFFF-zni,\nés pl: ököllel elkezded csapkodni őket...\n#d9534fEZ HIBA! #FFFFFFAmennyiben ezt teszed,\n#6699ccPG#FFFFFF-zel és örök kitiltásban is részesülhetsz a játékból."
		end
		if infoStep == 10 then
			infoText = "Mit kell tenned? Amit a valóságban, ha sehonnani civilként neked,\na tarkódhoz fogják a fegyvert, azaz félned!\nEz egy fontos eleme a játéknak, hogy tudj veszíteni és\nfélni a játékban, nem tehetsz meg akármit!"
		end
		if infoStep == 11 then
			infoText = "Ha ezeket mind értetted, akkor már jó úton jársz,\nde azért van itt még tudnivaló.\n Nézzük a következőt: '#6699ccMG#FFFFFF', azaz #ff7f00Metagaming#FFFFFF,\nEmlékszel az első fogalmunkra, az #6699ccIC #FFFFFF(#ff7f00karakterben#FFFFFF)\nés az #6699ccOOC#FFFFFF(#ff7f00karakteren kívül#FFFFFF) eseményekre?\nNos ez a szabály pont erre épül. Ne keverd össze soha a kettőt.\nAz '#6699ccMG#FFFFFF' hivatalosan #6699ccOOC#FFFFFF információ #6699ccIC#FFFFFF-ben való felhasználását jelenti\n(és fordítva is természetesen él a dolog),\nde ez elég bonyolult lehet így elsőre, úgyhogy nézzünk rá egy példát.\nA játékban például látod\nbizonyos határokon belül mások neveit a feje felett.\nEzek a dolgok nem azért vannak, hogy ezt te felhasználd #6699ccIC#FFFFFF,\nazaz a karaktereddel, hanem azért, hogy ha ő szabályt szeg,\nakkor tudd jelenteni vagy #ff7f00Panaszkönyvbe #FFFFFFegy fejezetet írni rá a \nfórumon. Konkrétan tudni fogod, hogy ki volt az illető.\nDe ezt szigorúan #d9534fCSAK #6699ccOOC #d9534fTUDOD#FFFFFF azaz karaktereden kívűl!"
		end
		if infoStep == 12 then
			infoText = "Tehát attól mert te látod a nevét a játékban\na feje felett, vagy a chatben,\nahogy beszél még a karaktered nem tudja az ő nevét,\namíg be nem mutatkozik neked a játékban, azaz #6699ccIC#FFFFFF!\nHa te őt nem ismered, mégis a nevén szólítod,\nmert kiolvasod a nevét és felhasználod az #6699ccIC#FFFFFF,\nakkor egy #6699ccOOC#FFFFFF infót használtál fel #6699ccIC#FFFFFF,azaz #6699ccMG#FFFFFF-ztél.\nEz szintén #d9534fSZIGORÚAN TILOS, BÜNTETÉST VONHAT MAGA UTÁN,\n AKÁR ÖRÖKÖS KITILTÁST IS!"
		end
		if infoStep == 13 then
			infoText = "Fáradsz már? Nem gond, megéri ezt a pár órás - esetleg pár napos\nbeletanulási időszakot, mert utána a #6699ccrabja #FFFFFFleszel feltehetően ennek,\nde a teljes élvezethez ezeket tudnod kell."
		end
		if infoStep == 14 then
			infoText = "Tehát jöhet a következő fogalom: #6699ccRK#FFFFFF (#ff7f00Revenge kill#FFFFFF),\nröviden halál utáni bosszút jelent.\nNa de nézzük mit is jelent ez.\nTételezzük fel, hogy Te valakinek nagyon keresztbe tettél\n(pl egy maffiózónak) és úgy dönt, nincs más megoldás csak az,\nha kivégzésre kerül a sor... Becsal téged valahova, ahol szembesít azzal,\nhogy most véged lesz. Pár golyó és a történetnek vége\n(kórházba fogsz kerülni).\nMivel te #6699ccmeghaltál#FFFFFF nyílván nem fogsz emlékezni arra,\nhogy ki ölt meg téged,\ncsak Te, a számítógép előtt ülő ember,\nde ezt az információt már nem használhatod fel,\nazaz nem mehetsz vissza bosszút állni,\nhisz karaktered nem emlékszik a történetekre.\nHa mégis így teszel,\nakkor'#6699ccRK#FFFFFF'-zol és #d9534fÖRÖK KITILTÁSBAN RÉSZESÜLHETSZ!"
		end
		if infoStep == 15 then
			infoText = "Nézzünk még két fontos #6699ccRP körökből#FFFFFF származó fogalmakat,\na #6699cc/me#FFFFFF-t és a #6699cc/do#FFFFFF-t.\nEz a két parancs arra való, hogy szemléltess egyéb eseményeket,\nmelyeket nem láttunk.\nA #6699cc/me#FFFFFF minden esetben a karaktereddel történt,\nnem látható eseményeket szimbolizálja,\na #6699cc/do #FFFFFFpedig a láthatatlan indirekt dolgokra,\nvagy környezetedre vonatkozik első sorban.\nPélda: Valakivel éppen társalogsz, akkor szinesítik az #ff7f00RP#FFFFFF-t,\nazaz nyomsz egy 't' betűt és chatbe beírod:\n#6699cc/me #FFFFFFvégig méri akivel beszélget és fura vigyor ül ki az arcára\n#6699cc/me #FFFFFFpislog egyet\n#6699cc/me#FFFFFF beleszív egy nagy slukkot a cigijébe\n#6699cc/me #FFFFFFfelnéz az égre és a felhőket nézi"
		end
		if infoStep == 16 then
			infoText = "Ezek mind nagyon színesítik a játék élményt, bátran ajánlom a\nhasználatát. Ha ütközöl egy kocsival például,\nakkor egyenesen kötelező a nem látható események bemutatása, azaz\n#6699cc/me #FFFFFFlefejelte a kormányt és felreped a szemöldöke,\n#6699cc/me#FFFFFF megijed a koccanástól stb stb.\nA #6699cc/do#FFFFFF egy összetettebb parancs már, de sokat dob az eseményeken.\nPéldául szintén tárgyalsz mondjuk valakivel\nés egy kis eseményt viszünk a dolgokba\n#6699cc/do#FFFFFF reccsen egy ág a tag lába alatt\n#6699cc/do#FFFFFF üvölt a zene a szomszéd házból\nvagy egy sérülés esetén #6699cc/do#FFFFFF eltört egy csont a lábában\nMind-mind kis figyelem elterelő, vagy eseményt színező dolgok!"
		end
		if infoStep == 17 then
			infoText = "Nos, nagyjából ezek azok a fogalmak amik nélkülözhetetlenek\n a #7cc576SeeMTA#FFFFFF-hoz.\nTermészetesen ez csak egy alap szint, de arra\nelég, hogy elindulj.\nTudásodat folyamatosan tudod bővíteni, használd a \nfórumunkat amit megtalálsz a weboldalon\n#6699cc(see-game.com).#FFFFFF\nMost pedig megmutathatod mennyire figyeltél oda,\nhisz egy kvíz következik, ahol elválik, mennyire értetted meg\naz alapvető dolgokat.\n\nSok sikert a teszthez!"
			acceptText = "Teszt kezdése"
			declineText = "Átolvasom újra a szabályokat"
		end
		if infoStep < 17 then
			acceptText = "Megértettem"
			declineText = "Nem értettem meg"
		end
		exports.sas_system:elmosasBekapcsolasa()
		if isInSlot(sx/2-206, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_accept.png")
		--elseif isInSlot(sx/2-206, sy/2+190, 201, 34)
		elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_decline.png")
		else
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_inactive.png")
		end
		--dxDrawRectangle(sx/2-206, sy/2-90, 410, 270)
		dxDrawText(acceptText, sx/2-206, sy/2+190, sx/2-206+201, sy/2+190+34, tocolor(255,255,255,255),0.5, seefont2, "center", "center")
		dxDrawText(declineText, sx/2-206+201+10, sy/2+190, sx/2-206+201+10+201, sy/2+190+34, tocolor(255,255,255,255),0.5, seefont2, "center", "center")
		dxDrawText(infoText, sx/2-206, sy/2-90, sx/2-206+410, sy/2-90+270, tocolor(255,255,255,255),0.62, infoFont, "center","center",false,false,false,true)
	end
end

function randomizeQuestion()
	if doingTest then
		counter = counter + 1
		if counter < 10  then
			randomQuestionNumber = randomQuestionNumber + 1
		end
	end
end

function testStart()
	setCameraMatrix(1804.9326171875, -1710.36328125, 31.542198181152,1829.212890625, -1748.248046875, 18.942230224609)
	setElementDimension(localPlayer, 65500)
	testStep = false
	removeEventHandler("onClientRender", getRootElement(), beforeTestRender)
	doingTest = true
	addEventHandler("onClientRender", getRootElement(), testStartRender)
end

function testStartRender()
	if doingTest then
		if isInSlot(sx/2-205, sy/2+58, 409, 33) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/quiz1.png")
		--elseif isInSlot(sx/2-206, sy/2+190, 201, 34)
		elseif isInSlot(sx/2-205, sy/2+58+33+12, 409, 33) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/quiz2.png")
		elseif isInSlot(sx/2-205, sy/2+58+33+33+10+13, 409, 33) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/quiz3.png")
		elseif isInSlot(sx/2-205, sy/2+58+33+33+33+10+10+14, 409, 33) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/quiz4.png")
		else
			dxDrawImage(sx/2-512/2, sy/2-512/2,512, 512, "files/login/quiz_inactive.png")
		end
		dxDrawText(questions[randomQuestionNumber][1], sx/2-205, sy/2+58-140, sx/2-205+409, sy/2+58-140+100, tocolor(255,255,255,255),0.75, seefont2, "center","center",false,true)
		dxDrawText(questions[randomQuestionNumber][2], sx/2-205, sy/2+58, sx/2-205+409, sy/2+58+33, tocolor(255,255,255,255),0.62, infoFont, "center","center",false,true)
		dxDrawText(questions[randomQuestionNumber][3], sx/2-205, sy/2+58+33+12, sx/2-205+409, sy/2+58+33+12+33, tocolor(255,255,255,255),0.62, infoFont, "center","center",false,true)
		dxDrawText(questions[randomQuestionNumber][4], sx/2-205, sy/2+58+33+33+10+13, sx/2-205+409, sy/2+58+33+33+10+13+33, tocolor(255,255,255,255),0.62, infoFont, "center","center",false,true)
		dxDrawText(questions[randomQuestionNumber][5], sx/2-205, sy/2+58+33+33+33+10+10+14, sx/2-205+409, sy/2+58+33+33+33+10+10+14+33, tocolor(255,255,255,255),0.62, infoFont, "center","center",false,true)
	elseif gutGemacht then
		if isInSlot(sx/2-206, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_accept.png")
		elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_decline.png")
		else
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_inactive.png")
		end
		local pointInProzent = point * 10
		dxDrawText("Tovább", sx/2-206, sy/2+190, sx/2-206+201, sy/2+190+34, tocolor(255,255,255,255),0.5, seefont2, "center", "center")
		dxDrawText("Kilépés a játékból", sx/2-206+201+10, sy/2+190, sx/2-206+201+10+201, sy/2+190+34, tocolor(255,255,255,255),0.5, seefont2, "center", "center")
		dxDrawText("Sikeresen kitöltötted a tesztet!\nEredményed: #7cc576"..pointInProzent.."%\n#FFFFFFA tovább gombra kattintva elkezdheted a \nkarakterkészítést.", sx/2-206, sy/2-90, sx/2-206+410, sy/2-90+270, tocolor(255,255,255,255),0.65, seefont2, "center","center",false,false,false,true)
	elseif falschGemacht then
		if isInSlot(sx/2-206, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_accept.png")
		elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_decline.png")
		else
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/login/acceptdecline_inactive.png")
		end
		local pointInProzent = point * 10
		dxDrawText("Újrakezdés", sx/2-206, sy/2+190, sx/2-206+201, sy/2+190+34, tocolor(255,255,255,255),0.5, seefont2, "center", "center")
		dxDrawText("Kilépés a játékból", sx/2-206+201+10, sy/2+190, sx/2-206+201+10+201, sy/2+190+34, tocolor(255,255,255,255),0.5, seefont2, "center", "center")
		dxDrawText("Sikertelen tesztkitöltés!\nEredményed: #d9534f"..pointInProzent.."%#FFFFFF\nAz újrakezdés gombra kattintva kitöltheted \nújra a tesztet.", sx/2-206, sy/2-90, sx/2-206+410, sy/2-90+270, tocolor(255,255,255,255),0.65, seefont2, "center","center",false,false,false,true)
	end
end

local actualquestion = 1
function isCorrect(answer)
	actualquestion = actualquestion + 1
	if answer == questions[randomQuestionNumber][6] then
		point = point + 1
	end
	if actualquestion - 1 >= #questions then
		if (point >= 8) then
			exports.sas_hud:addNotification("Sikeresen kitöltötted a tesztet! Folytathatod a regisztrációt.", "success")
			doingTest = false
			gutGemacht = true
			counter = 0
			--point = 0
			actualquestion = 1
		else
			exports.sas_hud:addNotification("Nem teljesítetted a teszthez elvárt minimumot (80%), kezdd újra!", "error")
			doingTest = false
			falschGemacht = true
			counter = 0
			actualquestion = 1
		end
	else
		randomizeQuestion()
	end
end

function planeFlight()
	planeCampos = 1
	local playerid = getElementData(localPlayer, "playerid")
	heli = createVehicle (577,1411.5595703125, -2494.599609375, 64.254531860352) --Vehicle
	pilot = createPed(61, 0,0,0)
	setElementDimension(pilot, 65500+playerid)
	warpPedIntoVehicle(pilot, heli)
	setVehicleDamageProof(heli, true)
	heli2 = createObject (6959,1411.5595703125, -2494.599609375, 64.254531860352) --Object
	setObjectScale (heli2, 0) --Scale 0 (object invisible)
	attachElements (heli, heli2) --Attach the Vehicle with the Object
	setElementFrozen (heli, true)

	setElementDimension(heli, 65500+playerid)
	setElementDimension(heli2, 65500+playerid)
	setElementRotation(heli, 0, 0, 268)
	setElementRotation(heli2, 0, 0, 268)

	moveObject(heli2, 10000, 1659.19921875, -2493.841796875, 13.5546875)

	alphaTimer = setTimer(function()
		alphaCanGo = true
	end, 5000, 1)

	planeTimer = setTimer(function()
		planeCampos = 2
		moveObject(heli2, 10000, 1839.1875, -2493.9072265625, 13.5546875)
		planeTimer = setTimer(function()
			fadeCamera(false)
			planeTimer = setTimer(function()
				atAirport()
				setElementAlpha(localPlayer, 255)
			end, 1000, 1)
		end, 8500, 1)
	end, 10000, 1)
end

-- folytatni
function atAirport()
	playerClone = createPed(atvSkindID, -1856.6585693359, 46.256233215332, 1055.1890869141)
	setElementDimension(playerClone, 0)
	setElementInterior(playerClone, 14)
	setPedAnimation(playerClone, "PED", "WALK_player", -1)
	setPedControlState(playerClone, "forward", true)
	setElementRotation(playerClone,0,0,90)

	setCameraMatrix(-1863.0720214844, 51.768550872803, 1056.861328125, -1921.1687011719, -27.438688278198, 1038.1265869141)
	setElementDimension(localPlayer, 0)
	setElementInterior(localPlayer, 14)

	officer = createPed(17, -1870.7269287109, 46.285530090332, 1055.1890869141)
	setElementInterior(officer, 14)
	setPedRotation (officer, 270.51226806641)
	setElementDimension(officer, 0)
	fadeCamera(true, 0)

	animChangeTimer = setTimer(function()
		setPedAnimation(playerClone, "PED", "IDLE_CHAT", 5000, true, false, false)
		setPedAnimation(officer, "PED", "IDLE_CHAT", 5000, true, false, false)
		canSpeak = true
		animChangeTimer = setTimer(function()
			setPedAnimation(playerClone,"DEALER","SHOP_PAY",3000,false,false,false,false)
			animChangeTimer = setTimer(function()
				step = 8
				setPedAnimation(officer)
				setPedAnimation(playerClone)
			end, 3000, 1)
		end, 5000, 1)
	end, 8000, 1)

	alphaTimer = setTimer(function()
		alphaCanGo = true
	end, 5000, 1)

	step = 7
	alphaCanGo = false
	alpha = 255
end

local firstText = ""

function charCreateFirstStep()
	if showFirstCharacterCreation then
		fadeCamera(false, 0)
		firstText = "Egy új élet?"
		setCameraMatrix(1568.484375, -1773.4501953125, 64.95467376709, 1555.8837890625, -1749.5771484375, 64.95467376709)
		exports.sas_system:elmosasKikapcsolasa()
		movingTimer = setTimer(function()
			fadeCamera(true)
			firstText = ""
			movingTimer = setTimer(function()
				firstText = "Talán most sikerül..."
				fadeCamera(false)

				--repülő létrehozása
				at400 = createVehicle(577, 1219.8720703125, -2490.2822265625, 131.31733703613)
				local playerid = getElementData(localPlayer, "playerid")
				setElementDimension(at400, 65500+playerid)
				setElementFrozen(at400, true)
				setElementRotation(at400, 0, 0, 268)

				-- repülőben ülők létrehozása

				utas1 = createPed(13, 1229.8251953125, -2491.6982421875, 135.59938049316, 268)
				setPedAnimation( utas1, "ped", "SEAT_idle", -1, true, false, false)
				setElementDimension(utas1, 65500+playerid)
				utas2 = createPed(24, 1228.2724609375, -2491.646484375, 135.60639953613,268)
				setPedAnimation( utas2, "ped", "SEAT_idle", -1, true, false, false)
				setElementDimension(utas2, 65500+playerid)
				utas3 = createPed(242, 1228.2080078125, -2492.6845703125, 135.60639953613,268)
				setPedAnimation( utas3, "ped", "SEAT_idle", -1, true, false, false)
				setElementDimension(utas3, 65500+playerid)
				utas4 = createPed(303, 1226.7705078125, -2491.65, 135.60639953613, 268)
				setPedAnimation( utas4, "ped", "SEAT_idle", -1, true, false, false)
				setElementDimension(utas4, 65500+playerid)
				utas5 = createPed(192, 1226.7861328125, -2492.568359375, 135.60639953613, 268)
				setPedAnimation( utas5, "ped", "SEAT_idle", -1, true, false, false)
				setElementDimension(utas5, 65500+playerid)
				utas6 = createPed(93, 1231.34375, -2492.763671875, 135.60639953613, 268)
				setPedAnimation( utas6, "ped", "SEAT_idle", -1, true, false, false)
				setElementDimension(utas6, 65500+playerid)

				-- repülőben ülők létrehozása
				movingTimer = setTimer(function()
					firstText = ""
					charNameEdit = ""
					local playerid = getElementData(localPlayer, "playerid")
					fadeCamera(true)
					setElementModel(localPlayer, 7)
					setElementDimension(localPlayer, 65500+playerid)
					setElementPosition(localPlayer, 1229.73828125, -2492.67578125, 135.60639953613)
					setPedAnimation( localPlayer, "ped", "SEAT_idle", -1, true, false, false)
					setElementRotation(localPlayer, 0,0,270)
					setCameraMatrix(1230.9455566406, -2491.4309082031, 136.41329956055, 1230.2542724609, -2492.1437988281, 136.29484558105-0.4)
					canCreate = true
				end, 3000, 1)
			end, 3000, 1)
		end, 3000, 1)
	end
end

local genderSelect = {"férfi", "nő"}

local charCreateBottomText = ""
local timeText = ""
local airportText = ""
local alpha = 255

function charFirstRender()
	if showFirstCharacterCreation then
		dxDrawText(firstText, sx/2, sy/2-10, sx/2, sy/2-10, tocolor(255,255,255,255), 1, charFont, "center", "center")
	end
	if canCreate then
		dxDrawRectangle(0, sy-154, sx, 154, tocolor(0,0,0,255)) -- alsó
		dxDrawRectangle(0, 0, sx, 154, tocolor(0,0,0,255)) -- felső fekete
		dxDrawText(charCreateBottomText, sx/2, sy-35, sx/2, sy-35, tocolor(255,255,255,255), 0.7,seefont3, "center", "center",false,false,false,true)
		if step == 1 then
			charCreateBottomText = "(Írd be a karaktered nevét szóközzel elválasztva, majd nyomd meg az ENTERT)"
			dxDrawText("A nevem #999999"..charNameEdit, sx/2, sy-103, sx/2, sy-103, tocolor(255,255,255,255), 1,charFont, "center", "center",false,false,false,true)
		--	dxDrawText("(Írd be a karaktered nevét szóközzel elválasztva, majd nyomd meg az ENTERT)", sx/2, sy-35, sx/2, sy-35, tocolor(255,255,255,255), 0.7,seefont3, "center", "center")
		end
		if step == 2 then
			dxDrawText("Én egy #999999"..charNameEdit.. " #FFFFFFéves...", sx/2, sy-103, sx/2, sy-103, tocolor(255,255,255,255), 1,charFont, "center", "center",false,false,false,true)
			charCreateBottomText = "(Írd be a karaktered életkorát, majd nyomd meg az ENTERT)"
		end
		if step == 3 then
			dxDrawText("Én egy "..atvAge.. " #FFFFFFéves #999999"..genderSelect[genderNum].. " #FFFFFFvagyok, ...", sx/2, sy-103, sx/2, sy-103, tocolor(255,255,255,255), 1,charFont, "center", "center",false,false,false,true)
			charCreateBottomText = "(válaszd ki a karaktered nemét a nyilakkal, majd nyomd meg az ENTERT)"
		end
		if step == 4 then
			dxDrawText("... és azért jöttem ide, #999999"..charNameEdit.. "#FFFFFF.", sx/2, sy-103, sx/2, sy-103, tocolor(255,255,255,255), 1,charFont, "center", "center",false,false,false,true)
			charCreateBottomText = "(Írd be karaktered rövid célját, majd nyomd meg az ENTERT)"
		end
		if step == 5 then
			dxDrawText("Ez vagyok én.", sx/2, sy-103, sx/2, sy-103, tocolor(255,255,255,255), 1,charFont, "center", "center",false,false,false,true)
			charCreateBottomText = "(válaszd ki a skinedet a jobbra-balra nyilakkal, majd nyomd meg az ENTERT)"
		end
		dxDrawText(timeText, sx-43, sy-59, sx-43, sy-59, tocolor(255,255,255,alpha), 1, charFont, "right", "bottom")
		if step == 6 then
			if planeCampos == 1 then
				timeText = "1 óra múlva"
				charCreateBottomText = ""
				local rX, rY, rZ = getElementPosition(heli)
				setCameraMatrix(1542.0732421875, -2447.4111328125, 50.051597595215, rX, rY, rZ)
				if alphaCanGo then
					alpha = alpha - 5
				end
				if alpha == 0 then
					alphaCanGo = false
				end
			end
			if planeCampos == 2 then
				local rX, rY, rZ = getElementPosition(heli)
				setCameraMatrix(1863.9697265625, -2524.10546875, 27.353155136108, rX, rY, rZ)
			end
		end
		dxDrawText(airportText, sx/2, sy-103, sx/2, sy-103, tocolor(255,255,255,255), 1,charFont, "center", "center",false,false,false,true)
		if step == 7 then
			timeText = "15 perc múlva..."
			if canSpeak then
				airportText = "#6699ccAlkalmazott: #FFFFFFÜdv "..(atvGender == 0 and "uram" or "hölgyem").."! Láthatnám a papírjait?"
			end
		end
		if step == 8 then
			if weightCanEdit then
				airportText = "Add meg a karaktered testsúlyát, majd nyomd meg az ENTERT."
			elseif cmCanEdit then
				airportText = "Add meg a karaktered magasságát, majd nyomd meg az ENTERT."
			elseif descCanEdit then
				airportText = "Add meg a karaktered vizuális leírását, majd nyomd meg az ENTERT."
			end

			dxDrawImage(sx/2-481/2, sy/2-277/2, 481, 277, "files/passport.png")
			dxDrawImage(sx/2-481/2+20, sy/2-277/2+42, 122, 123, "skins/"..atvSkindID..".jpg")
			if atvGender == 0 then
				genderText = "férfi"
			else
				genderText = "nő"
			end
			local firstName = string.gsub(atvCharname, "%s+%w+%w", "")
			local secondName = string.gsub(atvCharname, "%w+%s", "")
			local cmEdit = ""
			local weightEdit = ""
			local descEdit = ""
			if cmCanEdit then
				cmEdit = charNameEdit
			elseif not cmCanEdit then
				cmEdit = atvHeight
			end
			if weightCanEdit then
				weightEdit = charNameEdit
			elseif not weightCanEdit then
				weightEdit = atvWeight
			end
			if descCanEdit then
				descEdit = charNameEdit
			elseif not descCanEdit then
				descEdit = atvDesc
			end

			dxDrawText(cmEdit.." cm", sx/2+28, sy/2+19, sx/2+28, sy/2+19,tocolor(0,0,0,255), 0.55, seefont3, "left", "center")
			dxDrawText(weightEdit.." kg", sx/2+28, sy/2-2, sx/2+28, sy/2-2,tocolor(0,0,0,255), 0.55, seefont3, "left", "center")
			dxDrawText(genderText, sx/2+28, sy/2-23, sx/2+28, sy/2-23,tocolor(0,0,0,255), 0.55, seefont3, "left", "center")
			dxDrawText(atvAge.. " év", sx/2+28, sy/2-44, sx/2+28, sy/2-44,tocolor(0,0,0,255), 0.55, seefont3, "left", "center")
			dxDrawText(secondName, sx/2+28, sy/2-65, sx/2+28, sy/2-65,tocolor(0,0,0,255), 0.55, seefont3, "left", "center")
			dxDrawText(firstName, sx/2+28, sy/2-86, sx/2+28, sy/2-86,tocolor(0,0,0,255), 0.55, seefont3, "left", "center")
			dxDrawText(descEdit, sx/2-220, sy/2+47, sx/2+25, sy/2+47,tocolor(0,0,0,255), 0.55, seefont3, "left", "top", false,true)
			dxDrawText(atvCharname,sx/2-481/2-20, sy/2-277/2-20, sx/2-481/2+481-20, sy/2-277/2+277-20,tocolor(0,0,0,255),1,alairasFont, "right", "bottom")
		end
		if step == 9 then
			airportText = "See-City... Nézzünk csak szét!"
		end
	end
end

function registerRender()
	if registerScreen then
		local time = getTickCount() - lastChangeCursorState

		if time >= 500 then
			cursorState = not cursorState
			lastChangeCursorState = getTickCount()
		end

		if isInSlot(sx/2-250/2+35-43, sy/2+40+40+40+40, 266, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512,512, "files/login/registerprompt_active.png")
		else
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512,512, "files/login/registerprompt_inactive.png")
		end

		if actualEditing == "reguser" then
			regUserNameEdit = invitingText
			if cursorState then
				local w = dxGetTextWidth(regUserNameEdit, 0.65, seefont1)

				dxDrawLine(sx/2-80+w, sy/2-5, sx/2-80+w, sy/2+19, tocolor(255, 255, 255, lineAlpha), 2)
			end
    	end
    	dxDrawText(regUserNameEdit, sx/2-250/2+35+5, sy/2-35/2+7, 0, sy/2-35/2+7+35, tocolor(255,255,255, 255), 0.65, seefont1, "left", "center")


		actualPassword = regPassWordEdit
		local visiblePassword = "", 0
		for i=1,#actualPassword do
			visiblePassword = visiblePassword .. "*"
		end

		if actualEditing == "regpass" then
			regPassWordEdit = invitingText
			if cursorState then
				local w = dxGetTextWidth(visiblePassword, 0.65, seefont1)

				dxDrawLine(sx/2-80+w, sy/2-5+50, sx/2-80+w, sy/2+19+50, tocolor(255, 255, 255, lineAlpha), 2)
			end
		end

		if allowedShowingPassword then
			dxDrawImage(sx/2-iW/2, sy/2-iH/2+39, iW, iH, "files/login/remember_on.png")
			dxDrawText(regPassWordEdit, sx/2-250/2+35+5, sy/2+40, 0, sy/2+40+35, tocolor(255,255,255, 255), 0.65, seefont1, "left", "center")
		else
			dxDrawText(visiblePassword, sx/2-250/2+35+5, sy/2+40, 0, sy/2+40+35, tocolor(255,255,255, 255), 0.65, seefont1, "left", "center")
		end

		if actualEditing == "email" then
			emailEdit = invitingText
			if cursorState then
				local w = dxGetTextWidth(emailEdit, 0.65, seefont1)

				dxDrawLine(sx/2-80+w, sy/2-5+50+48, sx/2-80+w, sy/2+19+50+47, tocolor(255, 255, 255, lineAlpha), 2)
			end
		end
		dxDrawText(emailEdit, sx/2-250/2+35+5, sy/2+40+47, 0, sy/2+40+50.5+31, tocolor(255,255,255, 255), 0.65, seefont1, "left", "center")
	end
end

function validateDetails(bejelentkez)
	if not getNetworkConnection() or isSpam() then return end
	if not bejelentkez then
		local username = regUserNameEdit
		local password = regPassWordEdit
		local email = emailEdit

		if (string.len(username)<3) then
			exports.sas_hud:addNotification("A felhasználónevednek minimum 3 karaktert kell tartalmaznia.", "error");
		elseif (string.find(username, ";", 0)) or (string.find(username, "'", 0)) or (string.find(username, "@", 0)) or (string.find(username, ",", 0)) then
			exports.sas_hud:addNotification("A neved nem tartalmazhat ;,@'. szimbólumokat.", "error");
		elseif (string.len(password)<6) then
			exports.sas_hud:addNotification("A jelszavadnak minimum 6 karaktert kell tartalmaznia.", "error");
		elseif (string.len(password)>=30) then
			exports.sas_hud:addNotification("A jelszavad maximum 30 karakter lehet.", "error");
		elseif (string.find(password, ";", 0)) or (string.find(password, "'", 0)) or (string.find(password, "@", 0)) or (string.find(password, ",", 0)) then
			exports.sas_hud:addNotification("A jelszavad nem tartalmazhat ;,@'. szimbólumokat.", "error");
		elseif (string.len(email)<5) then
			exports.sas_hud:addNotification("Az e-mail címnek legalább 5 karakterbõl kell álnia.", "error");
		elseif (not string.find(email, "@", 0))  then
			exports.sas_hud:addNotification("Az e-mail címednek tartalmaznia kell @ szimbólumot.", "error");
		else
			triggerServerEvent("attemptRegister", localPlayer, username, password, email, atvCharname:gsub(" ", "_"), atvGender, atvWeight, atvHeight, atvDesc, atvAge, atvSkindID)
		end
	else
		local username = userNameEdit
		local password = passWordEdit

		if (string.len(username)<3) then
			exports.sas_hud:addNotification("A felhasználónevednek minimum 3 karaktert kell tartalmaznia!", "error");
		elseif (string.find(username, ";", 0)) or (string.find(username, "'", 0)) or (string.find(username, "@", 0)) or (string.find(username, ",", 0)) then
			exports.sas_hud:addNotification("A neved nem tartalmazhat ;,@'. szimbólumokat.", "error");
		elseif (string.len(password)<6) then
			exports.sas_hud:addNotification("A jelszavadnak minimum 6 karaktert kell tartalmaznia.", "error");
		elseif (string.find(password, ";", 0)) or (string.find(password, "'", 0)) or (string.find(password, "@", 0)) or (string.find(password, ",", 0)) then
			exports.sas_hud:addNotification("A jelszavad nem tartalmazhat ;,@'. szimbólumokat.", "error");
		else
			triggerServerEvent("attemptLogin", localPlayer, username, password)
		end
	end
end

addEvent("successfulRegister", true)
addEventHandler("successfulRegister", localPlayer, function()
	registerScreen = false
	removeEventHandler("onClientRender", getRootElement(), registerRender)

	if alapBeallitasok[3] == 1 then
		userNameEdit = alapBeallitasok[1]
		passWordEdit = alapBeallitasok[2]
	end

	addEventHandler("onClientRender", getRootElement(), displayinOrdnung)
	loginScreen = true
	exports.sas_system:elmosasBekapcsolasa()
	killTimer(spamTimer)
end)

function loginLoading()
	dxDrawRectangle(0, 0, sx+5,sy+5, tocolor(0,0,0,255))
	if szovegAlpha > 0 and not kovetkezo then
		szovegAlpha = szovegAlpha -1.5
	elseif szovegAlpha == 0 and not kovetkezo then
		kovetkezo = true
	end
	if kovetkezo and not kovetkezo2 and szovegAlpha < 165 then
		szam = 2
		szovegAlpha = szovegAlpha+1.5
	elseif szovegAlpha == 165 then
		kovetkezo2 = true
	end
	if szovegAlpha > 0 and kovetkezo2 and kovetkezo4 ~= 1 then
		szovegAlpha = szovegAlpha -1.5
		kovetkezo3 = 1
	end
	if kovetkezo3 == 1 and szovegAlpha == 0 then
		szam = 3
		kovetkezo4 = 1
	end
	if kovetkezo4 == 1 and szovegAlpha < 165 and not kovetkezo6 then
		szovegAlpha = szovegAlpha +1.5
		kovetkezo5 = true
	elseif kovetkezo5 and szovegAlpha == 165 then
		kovetkezo6 = true
	end
	if kovetkezo6 and szovegAlpha > 0 then
		szovegAlpha = szovegAlpha -1.5
	end

	local cTick = getTickCount ()
	local progressLoading = (cTick - lastTick2)/300
	exports.sas_system:addV3logo(sx/2-128/2,sy/2-128/2-50,nyitasLoading,progressLoading)
	dxDrawText(loadingSzoveg[szam], sx/2,sy/2+30, sx/2,sy/2+15, tocolor(255,255,255,szovegAlpha), 0.7, seefont1,"center", "center")

	dxDrawText("Betöltés...", sx-265, sy-25-18, sx-265, sy-25, tocolor(255,255,255,255), 0.5, seefont1)
	dxDrawRectangle(sx-265, sy-25, 255, 10, tocolor(100,100,100,255))

	local widthProgress = (cTick - loginloadingTick)/5000
	loginloadingWidth,_,_ = interpolateBetween (
		0,0,0,
		255,0,0,
		widthProgress,"Linear"
	)
	dxDrawRectangle(sx-265, sy-25, loginloadingWidth, 10, tocolor(255,255,255,255))

	if loginloadingWidth == 255 then
		removeEventHandler("onClientRender", getRootElement(), loginLoading)
		addEventHandler("onClientRender", getRootElement(), showCharacterBoreder)
		loginLoaded = true
		startView()
		fadeCamera( false, 10,0,0,0 )
		setTimer(fadeCamera, 2000, 10, true, 2)
		triggerServerEvent("setPlayerDatas", localPlayer)
		stopSound(loadingSound)
		charSound = playSound("files/avicii.mp3")
	end
end

addEvent("loginLoadingCall", true)
addEventHandler("loginLoadingCall", localPlayer, function()
	loginloadingTick = getTickCount()
	loginScreen = false
	exports.sas_system:elmosasKikapcsolasa()
	removeEventHandler("onClientRender", getRootElement(), displayinOrdnung)
	addEventHandler("onClientRender", getRootElement(), loginLoading)
	loadingSound = playSound(":sas_hud/files/loading.mp3")
end)

addEventHandler("onClientPlayerDamage", localPlayer, function()
	if not getElementData(localPlayer, "loggedin") then
		cancelEvent()
	end
end)

function showCharacterBoreder()
	local accountID = getElementData(localPlayer, "gameaccountid") or 0
	local charID = getElementData(localPlayer, "dbid") or 0
	local playedminutes = getElementData(localPlayer, "timeinserver") or 0
	local hp = math.floor(getElementHealth(localPlayer))
	local armor = math.floor(getPedArmor(localPlayer))
	local kaja = getElementData(localPlayer, "hunger") or 0
	local money = getElementData(localPlayer, "money") or 0
	local bankmoney = getElementData(localPlayer, "bankmoney") or 0
	
	dxDrawImage(sx/2+400-20, sy/2-80, 250, 310, "files/login/charcreate.png")
	dxDrawText(getPlayerName(localPlayer):gsub("_", " "), sx/2+650-20-10-5, sy/2-50-3, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.6, seefont4, "center", "center")
	dxDrawText("ID: #7cc576"..charID, sx/2+400, sy/2-80+80, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("AccountID: #7cc576"..accountID, sx/2+400, sy/2-80+80+40, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("Játszott percek: #7cc576"..playedminutes, sx/2+400, sy/2-80+80+40+40, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("Életerő: #7cc576"..hp.."%", sx/2+400, sy/2-80+80+40+40+40, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("Páncél: #7cc576"..armor.."%", sx/2+400, sy/2-80+80+40+40+40+40, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("Éhség: #7cc576"..kaja.."%", sx/2+400, sy/2-80+80+40+40+40+40+40, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("Pénz: #7cc576 "..formatNumber(money, ".").." $", sx/2+400, sy/2-80+80+40+40+40+40+40+40, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("Banki egyenleg: #7cc576"..formatNumber(bankmoney, ".").." $", sx/2+400, sy/2-80+80+40+40+40+40+40+40+40, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.55, seefont4, "left", "center", false,false,false,true)
	dxDrawText("Nyomj ENTER-t a kiválasztáshoz.", sx/2+385+10, sy/2-80+80+40+40+40+20+80+40+40+40+40+100, sx/2+400, sy/2-80, tocolor(255,255,255,255), 0.53, seefont2, "left", "center", false,false,false,true)
end

function characterLoading()
	dxDrawRectangle(0, 0, sx+5,sy+5, tocolor(0,0,0,255))
	if szovegAlpha2 > 0 and not kovetkezoChar then
		szovegAlpha2 = szovegAlpha2 -1.5
	elseif szovegAlpha2 == 0 and not kovetkezoChar then
		kovetkezoChar = true
	end
	if kovetkezoChar and not kovetkezoChar2 and szovegAlpha2 < 165 then
		szam2 = 2
		szovegAlpha2 = szovegAlpha2+1.5
	elseif szovegAlpha2 == 165 then
		kovetkezoChar2 = true
	end
	if szovegAlpha2 > 0 and kovetkezoChar2 and kovetkezoChar4 ~= 1 then
		szovegAlpha2 = szovegAlpha2 -1.5
		kovetkezoChar3 = 1
	end
	if kovetkezoChar3 == 1 and szovegAlpha2 == 0 then
		szam2 = 3
		kovetkezoChar4 = 1
	end
	if kovetkezoChar4 == 1 and szovegAlpha2 < 165 and not kovetkezoChar6 then
		szovegAlpha2 = szovegAlpha2 +1.5
		kovetkezoChar5 = true
	elseif kovetkezoChar5 and szovegAlpha2 == 165 then
		kovetkezoChar6 = true
	end
	if kovetkezoChar6 and szovegAlpha2 > 0 then
		szovegAlpha2 = szovegAlpha2 -1.5
	end
	local cTick = getTickCount ()
	local progressLoading = (cTick - lastTick3)/300

	exports.sas_system:addV3logo(sx/2-128/2,sy/2-128/2-50,nyitasCharloading,progressLoading)
	dxDrawText(charloadingSzoveg[szam2], sx/2,sy/2+30, sx/2,sy/2+15, tocolor(255,255,255,szovegAlpha2), 0.7, seefont1,"center", "center")
	dxDrawText("Betöltés...", sx-265, sy-25-18, sx-265, sy-25, tocolor(255,255,255,255), 0.5, seefont1)
	dxDrawRectangle(sx-265, sy-25, 255, 10, tocolor(100,100,100,255))

	local characterWidthProgress = (cTick - characterloadingTick)/5000
	characterloadingWidth,_,_ = interpolateBetween (
		0,0,0,
		255,0,0,
		characterWidthProgress,"Linear"
	)
	dxDrawRectangle(sx-265, sy-25, characterloadingWidth, 10, tocolor(255,255,255,255))

	if characterloadingWidth > 160 and not loadedChar then
		loadedChar = true
		stopView()
		triggerServerEvent("spawnCharacter", localPlayer)
	end

	if characterloadingWidth == 255 then
		removeEventHandler("onClientRender", getRootElement(), characterLoading)
		removeEventHandler("onClientRender", getRootElement(), showCharacterBoreder)
		removeEventHandler("onClientKey", getRootElement(), clickOnThings)
		setElementData(localPlayer, "enableall", true)
		showChat(true)
		showCursor(false)
		GTAcameramovement()
		triggerEvent("setupInventory", localPlayer)
		for k, v in ipairs({timer1, timer2, timer3, timer4}) do
			killTimer(v)
		end
		stopSound(loadingSound)
	end
end

function checkName()
	local theText = charNameEdit

	local foundSpace, valid = false, true
	local lastChar, current = ' ', ''
	for i = 1, #theText do
		local char = theText:sub( i, i )
		if char == ' ' then
			if i == #theText then
				valid = false
				break
			else
				foundSpace = true
			end

			if #current < 3 then
				valid = false
				break
			end
			current = ''
		elseif lastChar == ' ' then
			if char < 'A' or char > 'Z' then
				valid = false
				break
			end
			current = current .. char
		elseif ( char >= 'a' and char <= 'z' ) or ( char >= 'A' and char <= 'Z' ) then
			current = current .. char
		else
			valid = false
			break
		end
		lastChar = char
	end

	if valid and foundSpace and #theText < 35 and #current >= 2 then
		if not getNetworkConnection() or isSpam() then return end
		triggerServerEvent("doesCharacterExist", localPlayer, charNameEdit:gsub(" ", "_"))
	else
		exports.sas_hud:addNotification("Nevedet szóközzel válaszd el, és kezd nagybetűkkel!", "error")
	end
end

function characterNameK(exists)
	if (exists) then
		exports.sas_hud:addNotification("Ez a karakternév foglalt.", "error")
	elseif not (exists) then
		atvCharname = charNameEdit
		step = 2
		charNameEdit = ""
		smoothMoveCamera(1230.9455566406, -2491.4309082031, 136.41329956055, 1230.2542724609, -2492.1437988281, 136.29484558105-0.4, 1230.9383544922, -2489.9848632813, 136.55610656738-0.4, 1230.5339355469, -2490.8918457031, 136.43827819824-0.4, 1000)
	end
end
addEvent("characterExist", true )
addEventHandler("characterExist", localPlayer, characterNameK)

function formatNumber(amount, spacer)
	if not spacer then
		spacer = ","
	end

	amount = math.floor(amount)

	local left, num, right = string.match(tostring(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. (num:reverse():gsub("(%d%d%d)", "%1 "):reverse()) .. right
end

local sm = {}
sm.moov = 0
sm.object1, sm.object2 = nil, nil

local Plaetze = {
	{},
	{}
}

local function camRender()
	local x1, y1, z1 = getElementPosition(sm.object1)
	local x2, y2, z2 = getElementPosition(sm.object2)
	local randomPlatz = math.random(#Plaetze)
	setCameraMatrix(x1,y1,z1,x2,y2,z2)
end

local function removeCamHandler()
	if (sm.moov == 1) then
		sm.moov = 0
		removeEventHandler("onClientPreRender", root, camRender)
	end
end

function stopSmoothMoveCamera()
	if (sm.moov == 1) then
		if (isTimer(sm.timer1)) then killTimer(sm.timer1) end
		if (isTimer(sm.timer2)) then killTimer(sm.timer2) end
		if (isTimer(sm.timer3)) then killTimer(sm.timer3) end
		if (isElement(sm.object1)) then destroyElement(sm.object1) end
		if (isElement(sm.object2)) then destroyElement(sm.object2) end
		removeCamHandler()
		sm.moov = 0
	end
end

function smoothMoveCamera(x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, time, easing)
	if (sm.moov == 1) then return false end
	sm.object1 = createObject(1337, x1, y1, z1)
	sm.object2 = createObject(1337, x1t, y1t, z1t)
	setElementAlpha(sm.object1, 0)
	setElementAlpha(sm.object2, 0)
	setObjectScale(sm.object1, 0.01)
	setObjectScale(sm.object2, 0.01)
	moveObject(sm.object1, time, x2, y2, z2, 0, 0, 0, (easing and easing or "InOutQuad"))
	moveObject(sm.object2, time, x2t, y2t, z2t, 0, 0, 0, (easing and easing or "InOutQuad"))

	addEventHandler("onClientPreRender", root, camRender)
	sm.moov = 1
	sm.timer1 = setTimer(removeCamHandler, time, 1)
	sm.timer2 = setTimer(destroyElement, time, 1, sm.object1)
	sm.timer3 = setTimer(destroyElement, time, 1, sm.object2)

	return true
end

function startView()
	if (isTimer(amazingViewTimer)) then
		stopView()
	end

	setElementFrozen(localPlayer, true)
	setElementPosition(localPlayer, 379.7490234375-2, -2027.478515625-1.2, 7.8300905227661)
	setPedRotation(localPlayer, 87.735412597656)
	setPedAnimation(localPlayer, "on_lookers", "wave_loop", -1, true, false, false)

	viewStep = 1
	setCameraMatrix(view[viewStep][1]["posX"], view[viewStep][1]["posY"], view[viewStep][1]["posZ"], view[viewStep][1]["lookX"], view[viewStep][1]["lookY"], view[viewStep][1]["lookZ"])

	launcherTimer = setTimer(function()
		smoothMoveCamera(view[viewStep][1]["posX"], view[viewStep][1]["posY"], view[viewStep][1]["posZ"], view[viewStep][1]["lookX"], view[viewStep][1]["lookY"], view[viewStep][1]["lookZ"], view[viewStep][2]["posX"], view[viewStep][2]["posY"], view[viewStep][2]["posZ"], view[viewStep][2]["lookX"], view[viewStep][2]["lookY"], view[viewStep][2]["lookZ"], view[viewStep][1]["speed"])

		amazingViewTimer = setTimer(function()
			if (isOnShow) then
				if (viewStep == #view) then
					viewStep = 1
				else
					viewStep = viewStep+1
				end

				smoothMoveCamera(view[viewStep][1]["posX"], view[viewStep][1]["posY"], view[viewStep][1]["posZ"], view[viewStep][1]["lookX"], view[viewStep][1]["lookY"], view[viewStep][1]["lookZ"], view[viewStep][2]["posX"], view[viewStep][2]["posY"], view[viewStep][2]["posZ"], view[viewStep][2]["lookX"], view[viewStep][2]["lookY"], view[viewStep][2]["lookZ"], view[viewStep][1]["speed"])
			else
				stopView()
			end
		end, view[viewStep][1]["speed"]+90000, 0)
	end, 100, 1)

	isOnShow = true
end

function stopView()
	if (isTimer(launcherTimer)) then
		killTimer(launcherTimer)
	end

	if (isTimer(amazingViewTimer)) then
		killTimer(amazingViewTimer)
	end

	isOnShow = false
	viewStep = 0
	setElementFrozen(localPlayer, false)
	setCameraTarget(localPlayer)
	stopSmoothMoveCamera()
end