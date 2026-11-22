local skinID = 280
local panelState = false
local doingDrive = false
local allowed = false
local finishPanel = ""
local renderData = {}
local totalPoints = 0
local counter = 0
local shit = false

local sx, sy = guiGetScreenSize()
local sxF, syF = sx / 2, sy / 2
local schonGepasst = false
local activePanel = false

if fileExists("sourceC.lua") then
	fileDelete("sourceC.lua")
end

local font = dxCreateFont("files/OpenSansSB.ttf",16)--Felirat
local font2 = dxCreateFont("files/OpenSansSB.ttf",20)--Felirat

local vehicles = {
	{436, -863.10144042969, 553.01605224609, 10.888244628906,0,0,180},
}

licensePed = createPed(17, -2035.0947265625, -117.4814453125, 1035.171875, 270)
setElementDimension(licensePed, 1)
setElementInterior(licensePed, 3)
licenseMarker = createMarker(-2032.3134765625, -117.4931640625, 1034, "cylinder", 2, 51, 204, 255)
setElementDimension(licenseMarker, 1)
setElementInterior(licenseMarker, 3)

--útvonal
local route = {}
route[1] = {341.7431640625, -1351.0244140625, 14.5078125-1,}
route[2] = {1451.556640625, -1874.970703125, 13.390607833862}
route[3] = {1571.6943359375, -1783.43359375, 13.390607833862}
route[4] = {1495.1201171875, -1589.4375, 13.390607833862}
route[5] = {1456.408203125, -1462.01171875, 13.390607833862}
route[6] = {1456.69140625, -1252.8369140625, 13.390607833862}
route[7] = {1490.005859375, -1163.4931640625, 23.990606307983}
route[8] = {1733.16015625, -1163.9453125, 23.990606307983}
route[9] = {1886.9453125, -1263.59375, 12.990606307983}
route[10] = {1952.0068359375, -1133.318359375, 25.610771179199}
route[11] = {1864.7333984375, -1166.6318359375, 23.664896011353}
route[12] = {1664.595703125, -1158.4033203125, 23.661474227905}
route[13] = {1639.966796875, -1128.177734375, 23.661474227905}
route[14] = {1631.609375, -1046.1796875, 23.8984375}

route[15] = {1635.6796875, -1150.3662109375, 23.8984375}
route[16] = {1437.154296875, -1157.396484375, 23.65625}
route[17] = {1340.5341796875, -1239.77734375, 13.557636260986}
route[18] = {1295.0927734375, -1692.6923828125, 13.3828125}
route[19] = {1270.5625, -1843.8681640625, 13.390625}
route[20] = {1268.8896484375, -1816.6845703125, 13.137285232544}

renderData.routeCounter = 1


generatedQuestion = false
--jelenlegi kérdés index.

local questions = {
	{"Egy körforgalomban kinek van elsőbbsége?", "Balról érkezőnek", "Jobbról érkezőnek", "Mindkettőnek","Mindkettőnek", 1, false},
	{"Szabad-e hátramenetet végezni autópályán?", "Igen", "Nem", "Nemtudom","Mindkettőnek", 1, false},
	{"Kell-e irányjelzést adni forgalmisáv váltásakor?", "Nem", "Csak akkor, ha a sávokat útburkolati jel választja el","Mindkettőnek", "Igen", 1, false},
	{"Autópályán szabad-e jobbról előzni?", "Igen", "Nem", "Ha nemlát senki","Mindkettőnek", 1, false},
	{"Egy balra fordulónak el kell engednie a neki szembe jövőt?", "Igen", "Nem", "Belátása szerint dönthet","Mindkettőnek", 1, false},
	{"El kell engedni a megkülönböztető jelzéssel ellátott járműveket?", "Igen", "Nem", "Ha nem sietek","Mindkettőnek", 1, false},
	{"Kell-e irányjelzéssel jelezni az irányváltoztatással járó előzést?", "Nem", "Igen", "Csak ha rendőr látja","Mindkettőnek", 1, false},
	{"Egy balra kanyarodót milyen irányból előzhetünk meg?", "Balról", "Jobbról", "Ahonnan tudjuk","Mindkettőnek", 1, false},
	{"Egy balra kanyarodót milyen irányból előzhetünk meg?", "Balról", "Jobbról", "Ahonnan tudjuk","Mindkettőnek", 1, false},
	{"Egy balra kanyarodót milyen irányból előzhetünk meg?", "Balról", "Jobbról", "Ahonnan tudjuk","Mindkettőnek", 1, false},
	{"Egy balra kanyarodót milyen irányból előzhetünk meg?", "Balról", "Jobbról", "Ahonnan tudjuk","Mindkettőnek", 1, false},
	{"Egy balra kanyarodót milyen irányból előzhetünk meg?", "Balról", "Jobbról", "Ahonnan tudjuk","Mindkettőnek", 1, false},
	{"Egy balra kanyarodót milyen irányból előzhetünk meg?", "Balról", "Jobbról", "Ahonnan tudjuk","Mindkettőnek", 1, false},
}



local tag1 = dxCreateTexture(":sas_hud/radar/files/blips/target.png")
function renderPanel()
	if panelState then
		if not allowed then
			if isInSlot(sx/2-206, sy/2+190, 201, 34) then
				dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_accept.png")
		--elseif isInSlot(sx/2-206, sy/2+190, 201, 34)
			elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
				dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_decline.png")
			else
				dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_inactive.png")
			end
			dxDrawText("Kezdés", sx/2-206, sy/2+190, sx/2-206+201, sy/2+190+34, tocolor(255,255,255,255),0.5, font2, "center", "center")
			dxDrawText("Mégsem", sx/2-206+201+10, sy/2+190, sx/2-206+201+10+201, sy/2+190+34, tocolor(255,255,255,255),0.5, font2, "center", "center")
			dxDrawText("Kedves vizsgázni vágyó tanuló!\n\nA sikeres autóvezetői engedély megszerzéséhez #d9534fkét\nvizsgát #ffffffis teljesíteni kell.\n#7cc576- Elméleti vizsga\n#ffffff(Vizsgadíj: #32b3ef120$#FFFFFF)\n#7cc576- Gyakorlati vizsga\n#ffffff(Vizsgadíj: #32b3ef240$#FFFFFF)\n\nAz elméleti vizsgán #d9534f10 kérdést #fffffffog kapni,\namiből legalább #7cc5768-ra helyesen #ffffffkell válaszoljon.\n\nAmennyiben készen áll az elméleti vizsgára,\nnyomjon a #32b3ef'Kezdés'#ffffff gombra.\n#7cc576Sok sikert!", sx/2, sy/2-95, sx/2, sy/2-100, tocolor(255,255,255,255),0.67, font, "center", "top",false,false,false,true)
		end
		if allowed then
				if isInSlot(sx/2-205, sy/2+58, 409, 33) then
					dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/quiz1.png")
				elseif isInSlot(sx/2-205, sy/2+58+33+12, 409, 33) then
					dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/quiz2.png")
				elseif isInSlot(sx/2-205, sy/2+58+33+33+10+13, 409, 33) then
					dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/quiz3.png")
				elseif isInSlot(sx/2-205, sy/2+58+33+33+33+10+10+14, 409, 33) then
					dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/quiz4.png")
				else
					dxDrawImage(sx/2-512/2, sy/2-512/2,512, 512, "files/quiz_inactive.png")
				end
				dxDrawText(questions[generatedQuestion][1], sx/2-205, sy/2+58-140, sx/2-205+409, sy/2+58-140+100, tocolor(255,255,255,255),0.75, font2, "center","center",false,true)
				dxDrawText(questions[generatedQuestion][2], sx/2-205, sy/2+58, sx/2-205+409, sy/2+58+33, tocolor(255,255,255,255),0.62, font, "center","center",false,true)
				dxDrawText(questions[generatedQuestion][3], sx/2-205, sy/2+58+33+12, sx/2-205+409, sy/2+58+33+12+33, tocolor(255,255,255,255),0.62, font, "center","center",false,true)
				dxDrawText(questions[generatedQuestion][4], sx/2-205, sy/2+58+33+33+10+13, sx/2-205+409, sy/2+58+33+33+10+13+33, tocolor(255,255,255,255),0.62, font, "center","center",false,true)
				dxDrawText(questions[generatedQuestion][5], sx/2-205, sy/2+58+33+33+33+10+10+14, sx/2-205+409, sy/2+58+33+33+33+10+10+14+33, tocolor(255,255,255,255),0.62, font, "center","center",false,true)
		end
	end
	if finishPanel == "success" then
		if isInSlot(sx/2-206, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_accept.png")
	--elseif isInSlot(sx/2-206, sy/2+190, 201, 34)
		elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_decline.png")
		else
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_inactive.png")
		end
		dxDrawText("Tovább", sx/2-206, sy/2+190, sx/2-206+201, sy/2+190+34, tocolor(255,255,255,255),0.5, font2, "center", "center")
		dxDrawText("Megszakítás", sx/2-206+201+10, sy/2+190, sx/2-206+201+10+201, sy/2+190+34, tocolor(255,255,255,255),0.5, font2, "center", "center")
		dxDrawText("Sikeresen kitöltötted a tesztet!\nEredményed: #7cc576"..totalPoints.."%\n#FFFFFFA tovább gombra kattintva elkezdheted a \nkarakterkészítést.", sx/2-206, sy/2-90, sx/2-206+410, sy/2-90+270, tocolor(255,255,255,255),0.8, font, "center","center",false,false,false,true)

	end
	if schonGepasst then
		if isInSlot(sx/2-206, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_accept.png")
	--elseif isInSlot(sx/2-206, sy/2+190, 201, 34)
		elseif isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_decline.png")
		else
			dxDrawImage(sx/2-512/2, sy/2-512/2, 512, 512, "files/acceptdecline_inactive.png")
		end
		dxDrawText("Folytatás", sx/2-206, sy/2+190, sx/2-206+201, sy/2+190+34, tocolor(255,255,255,255),0.5, font2, "center", "center")
		dxDrawText("Kilépés", sx/2-206+201+10, sy/2+190, sx/2-206+201+10+201, sy/2+190+34, tocolor(255,255,255,255),0.5, font2, "center", "center")
		dxDrawText("Már egyszer sikeresen letetted az\nelméleti vizsgát, de a\ngyakorlati vizsga még hátravan.\nHa szeretnéd megcsinálni a gyakorlati vizsgát\nkattints a #32b3ef'Folytatás' #ffffffgombra.", sx/2-206, sy/2-90, sx/2-206+410, sy/2-90+270, tocolor(255,255,255,255),0.8, font, "center","center",false,false,false,true)

	end
end
--[[
probaM = createMarker(354.4150390625, -1369.3662109375, 14.302742004395, "cylinder", 2, 217, 83, 79, 200)

function drawBlipOnMarker()
	dxDrawImageOnElement(probaM, tag1,1000,1,0.2, 217, 83, 79)
end
addEventHandler("onClientRender", root, drawBlipOnMarker)
]]
addEventHandler("onClientMarkerHit", licenseMarker,
	function(thePlayer)
		if thePlayer == localPlayer then
			if getElementData(thePlayer,"license.car") == 0 then
				if not panelState and not doingDrive then
					panelState = true
					addEventHandler("onClientRender", root, renderPanel, true, "low")
				end
			end
			if getElementData(thePlayer,"license.car") == 3 and not doingDrive and not activePanel then -- if the player leaves before he made the driving test
				schonGepasst = true
				addEventHandler("onClientRender", root, renderPanel, true, "low")
			end
		end
end)

addEventHandler("onClientMarkerLeave", licenseMarker,
	function(thePlayer)
		if thePlayer == localPlayer then
				panelState = false
				removeEventHandler("onClientRender", root, renderPanel, true, "low")
		end
end)

local okatatoSzovegek = {
	{"#7cc576*Oktató: #FFFFFFSok-sok km tapasztalat kell."},
	{"#7cc576*Oktató: #FFFFFFOké szépen lassan haladjunk a kijelölt útvonalon, tartsuk be a közlekedési szabályokat."},
	{"#7cc576*Oktató: #FFFFFFIndexet használjunk a közlekedésnél. (( Bal és jobb klikk ))"},
	{"#7cc576*Oktató: #FFFFFFNe terelje el a figyelmedet, ha hozzád beszélek..."},
	{"#7cc576*Oktató: #FFFFFFPIROS LÁMPÁNÁL MINDIG MEGÁLLUNK!"},
	{"#7cc576*Oktató: #FFFFFFA gettóba ne nagyon közlekedj, mert ezek kilopják minden vagyonod!"},
	{"#7cc576*Oktató: #FFFFFFNyugodj meg nem kell idegeskedni."},
	{"#7cc576*Oktató: #FFFFFFSpiclik, korruptok, kemények, maffiózók, kúrvák... Hadd ne soroljam... Ez See-City, jobb ha hozzászoksz."},
	{"#7cc576*Oktató: #FFFFFFNem zavar, ha rágyújtok?"},
	{"#7cc576*Oktató: #FFFFFFSokszor olyan sunyin mérnek, hogy észre se veszed csak kapod a bírságot."},
	{"#7cc576*Oktató: #FFFFFFHa széttöröd a kocsit a vizsga véget ér és a pénzt is buktad."},
	{"#7cc576*Oktató: #FFFFFFAz autókereskedést egyébként fent találod a motelltől nem messze."},
	{"#7cc576*Oktató: #FFFFFFAzt mondtam már, hogy a pirosnál mindig meg kell állni?!"},
	{"#7cc576*Oktató: #FFFFFFFigyelj mindig a sebbességkorlátra, mert ezek mindig mérnek."},
}

local speedCounter = 0

addEventHandler("onClientClick", getRootElement(),
	function(button, state, x, y, wx, wy, wz, element)
		if button == "left" and state == "down" then
			if panelState and not allowed then
				if isInSlot(sx/2-206, sy/2+190, 201, 34) then
					if getElementData(localPlayer, "money") >= 360 then
						allowed = true
						triggerServerEvent("payFee", localPlayer, 120)
						generateQuestion()
						setTimer(function()
							shit = true
						end, 1000,1)
					else
						exports.sas_hud:addNotification("Nincs nálad elég pénz! (360 $)", "error")
					end
				end
				if isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
					if panelState and not allowed then
						panelState = false
					end
				end
			end
			if allowed and shit and finishPanel == "" then
				if isInSlot(sx/2-205, sy/2+58, 409, 33) then
					processAnswering(1)
				elseif isInSlot(sx/2-205, sy/2+58+33+12, 409, 33) then
					processAnswering(2)
				elseif isInSlot(sx/2-205, sy/2+58+33+33+10+13, 409, 33) then
					processAnswering(3)
				elseif isInSlot(sx/2-205, sy/2+58+33+33+33+10+10+14,409,33) then
					processAnswering(4)
				end
			end
			if finishPanel == "success" or schonGepasst then
				if isInSlot(sx/2-206, sy/2+190, 201, 34) then
					if getElementData(localPlayer, "money") >= 240 then
					  startingMarker = createMarker(route[1][1], route[1][2], route[1][3], "cylinder", 2, 51, 204, 255, 255)
					  startingBlip = createBlip(route[1][1], route[1][2], route[1][3], 60, 1, 217, 83, 79, 255)
						setElementData(startingMarker, "license", true)
						setElementData(startingBlip, 'exclusiveBlip', true);
						setElementData(startingBlip, "license", true)
						setElementData(startingBlip, 'blipIcon', "target");
						setElementData(startingBlip, 'blipColor', {217, 83, 79,255});
						setElementData(startingBlip, 'blipSize', 15)
						setElementData(startingBlip, "blipSize2", 15)
						triggerServerEvent("payFee", localPlayer, 240)
						finishPanel = ""
						activePanel = true
						schonGepasst = false

						addEventHandler("onClientMarkerHit", startingMarker,
							function(hitPlayer)
								if hitPlayer == localPlayer then
									triggerServerEvent("createLicenseVehicle", localPlayer)
									outputChatBox("#7cc576[SeeMTA]: #FFFFFF Beszálltál a járművedbe!",255,255,255,true)
									outputChatBox("#7cc576*Oktató: #FFFFFFHa készen állsz, akkor indulhatunk!",255,255,255,true)
									outputChatBox("#7cc576*Oktató: #FFFFFFDe azért a kéziféket ne felejtsük el kiengedni!",255,255,255,true)
									outputChatBox("#7cc576(( ALT lenyomva, és az egeret előretolni a zöld mezőbe ))",255,255,255,true)
									outputChatBox("#7cc576*Oktató: #FFFFFFHaver, azt akarod, hogy megbüntesselek? Kösd be az övedet! ((F5))",255,255,255,true)
									textTimer = setTimer(function()
										local randomTextNum = math.random(1, 14)
										outputChatBox(okatatoSzovegek[randomTextNum][1], 255,255,255,true)
									end,20000, 0)
									checkSpeedTimer = setTimer(function()
										local veh = getPedOccupiedVehicle(localPlayer)
										local targetSpeed = getVehicleSpeed(veh)
										if math.floor(targetSpeed) >= 70 then
											outputChatBox("#7cc576*Oktató: #FFFFFFHaver, azt akarod, hogy megbuktassalak? LASSÍTS! Tartsd be a sebességet!", 255,255,255,true)
											speedCounter = speedCounter + 1
											if speedCounter == 4 then
												exports.sas_hud:addNotification("Túl gyorsan hajtasz! ("..math.floor(targetSpeed).."km/h)! Ha így folytatod, akkor meg fogsz bukni!", "error")
											end
											if speedCounter == 8 then
												exports.sas_hud:addNotification("Megbuktál, mivel túl sokszor kaptak gyorshajtáson.", "error")
												failedLicense()
											end
										end
									end,2000, 0)
									nextMarker()
								end
							end
						)

					else
						exports.sas_hud:addNotification("Nincs nálad elég pénz a gyakorlati vizsgára! (240 $)", "error")
					end
				end
				if isInSlot(sx/2-206+201+10, sy/2+190, 201, 34) then
						finishPanel = ""
				end
			end
		end
	end
)

oldBlip = false
currentMarker = 1

testVehicle = {[436]=true}

function nextMarker()

	currentMarker = currentMarker + 1
	for k, v in pairs(getElementsByType("marker")) do
		if getElementData(v, "license") then
			destroyElement(v)
		end
	end

	for k, v in pairs(getElementsByType("blip")) do
		if getElementData(v, "license") then
			destroyElement(v)
		end
	end


	if currentMarker < 21 then
		local startMarker = createMarker(route[currentMarker][1], route[currentMarker][2], route[currentMarker][3]-1, "cylinder", 2, 217, 83, 79, 200)
		local oldBlip = createBlip(route[currentMarker][1], route[currentMarker][2], route[currentMarker][3], 62, 1)
		setElementData(startMarker, "license", true)
		setElementData(oldBlip, 'blipColor',{217, 83, 79,255})
		setElementData(oldBlip, 'blipSize', 15)
		setElementData(oldBlip, 'blipSize2', 15)
		setElementData(oldBlip, "license", true)
		setElementData(oldBlip, 'blipIcon', "target");
		setElementData(oldBlip, 'exclusiveBlip', true);

		addEventHandler("onClientMarkerHit", startMarker,
			function(hitPlayer)
				if hitPlayer == localPlayer then
					if isPedInVehicle(localPlayer) then
						local vehicle = getPedOccupiedVehicle(localPlayer)
						local id = getElementModel(vehicle)
						if (testVehicle[id]) then
							nextMarker()
							--outputChatBox(route[currentMarker][4], 255,255,255, true)
						--	playSoundFrontEnd(12)

						end
					end
				end
			end
		)
	else
		finishLicense()
	end
end

function failedLicense()
	triggerServerEvent("failedLicense", localPlayer)
	if isTimer(checkSpeedTimer) then
		killTimer(checkSpeedTimer)
	end
	speedCounter = 0
	currentMarker = 1
	renderData.routeCounter = 1
	generatedQuestion = false
	if isTimer(textTimer) then
		killTimer(textTimer)
	end

	for k, v in pairs(getElementsByType("blip")) do
		if getElementData(v, "license") then
			destroyElement(v)
		end
	end

	for k, v in pairs(getElementsByType("marker")) do
		if getElementData(v, "license") then
			destroyElement(v)
		end
	end
end

function finishLicense()
	triggerServerEvent("finishLicense", localPlayer)
	exports.sas_hud:addNotification("Siker! A jogosítványod megtalálod az iratok között.","success")
	currentMarker = 1
	renderData.routeCounter = 1
	generatedQuestion = false

	triggerServerEvent("acceptLicense", localPlayer)

	if isTimer(textTimer) then
		killTimer(textTimer)
	end

	for k, v in pairs(getElementsByType("blip")) do
		if getElementData(v, "license") then
			destroyElement(v)
		end
	end

	for k, v in pairs(getElementsByType("marker")) do
		if getElementData(v, "license") then
			destroyElement(v)
		end
	end
end




function processAnswering(number)
	questions[generatedQuestion][7] = true
	counter = counter + 1

	if tonumber(number) == tonumber(questions[generatedQuestion][6]) then
		totalPoints = totalPoints + 10
	end

	if counter ~= 11 then
		generateQuestion()
	elseif counter == 11 then
		if totalPoints >= 80 then
			exports.sas_hud:addNotification("Sikeresen teljesítetted az elméleti tesztet. Most következzen a gyakorlati rész.","success")
			panelState = false
			finishPanel = "success"
			showCursor(false)
			showChat(true)
			doingDrive = true
			counter = 0
			triggerServerEvent("theoryComplete", localPlayer)
		else
			exports.sas_hud:addNotification("Sikertelen vizsga! Sajnos nem érted el a minimumot. (".. totalPoints .."%)","error")
			finishPanel = "failed"
			panelState = false
			allowed = false
		end
	end
end


function generateQuestion()
	if panelState and allowed then
		if counter < 10 then
			repeat
				generatedQuestion = math.random(#questions)
			until not questions[generatedQuestion][7]
		end
	end
end


function closePanel()
	if panelState then
		panelState = false
		allowed = false
		removeEventHandler("onClientRender", getRootElement(), renderPanel)
		showCursor(false)
		currentMarker = 1
		renderData.routeCounter = 1
		generatedQuestion = false
		counter = 0
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



function getVehicleSpeed()
    if isPedInVehicle(localPlayer) then
        local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(localPlayer))
        return math.sqrt(vx^2 + vy^2 + vz^2) * 187.5
    end
    return 0
end




function dxDrawImageOnElement(TheElement,Image,distance,height,width,R,G,B,alpha)
				local x, y, z = getElementPosition(TheElement)
				local x2, y2, z2 = getElementPosition(localPlayer)
				local distance = distance or 20
				local height = height or 1
				local width = width or 1
        local checkBuildings = checkBuildings or true
        local checkVehicles = checkVehicles or false
        local checkPeds = checkPeds or false
        local checkObjects = checkObjects or true
        local checkDummies = checkDummies or true
        local seeThroughStuff = seeThroughStuff or false
        local ignoreSomeObjectsForCamera = ignoreSomeObjectsForCamera or false
        local ignoredElement = ignoredElement or nil
				--if not (isLineOfSightClear(x, y, z, x2, y2, z2, checkBuildings, checkVehicles, checkPeds , checkObjects,checkDummies,seeThroughStuff,ignoreSomeObjectsForCamera,ignoredElement)) then
					local sx, sy = getScreenFromWorldPosition(x, y, z+height)
					if(sx) and (sy) then
						local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
						--if(distanceBetweenPoints < distance) then
							dxDrawMaterialLine3D(x, y, z+0.2+height-(distanceBetweenPoints/distance)+1.2, x, y, z+height+1.2, Image, width-(distanceBetweenPoints/distance), tocolor(R or 255, G or 255, B or 255, alpha or 255))
						--end
					end
			--s	end
	end
