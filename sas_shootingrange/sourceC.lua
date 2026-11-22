local skillObjs = {
	{1586,319.4814453125, -58.5966796875, 1001.515625-1,-90,0,270}, -- alap
	{1585,315.6513671875, -70.162109375, 1001.515625-1,-90,0,270},
	{1584,314.66015625, -59.1904296875, 1001.515625-1,-90,0,270},
	{1583,326.322265625, -60.982421875, 1001.515625-1,-90,0,270}, -- alap
	{1584,321.15625, -61.4677734375, 1001.515625-1,-90,0,270}, -- alap
	{1584,314.658203125, -71.43359375, 1001.515625-1,-90,0,270},
	{1586,328.8232421875, -64.41796875, 1001.515625-1,-90,0,270},
}
local wallObjs = {
	{9339,306.3203125, -64.732421875, 1001.515625,0,0,0},
	{9339,306.3203125+4, -48.732421875, 1001.515625,0,0,0},
	{9339,306.3203125+4, -49.732421875-29, 1001.515625,0,0,0},
	{9339,306.3203125+8, -69.732421875, 1001.515625-0.2,0,0,0},
	{9339,306.3203125+8+3, -69.732421875-10, 1001.515625-0.2,0,0,0},
	{9339,306.3203125+8+4, -69.732421875+22, 1001.515625-0.2,0,0,0},
	{9339,306.3203125+16-0.5-0.5-0.5, -69.732421875, 1001.515625-0.2,0,0,0},
	{9339,306.3203125+16+2-0.5-0.5, -69.732421875, 1001.515625,0,0,0},
	{9339,306.3203125+16+4-0.5, -69.732421875, 1001.515625+0.2,0,0,0},
	{9339,306.3203125+16+6, -69.732421875, 1001.515625+0.4,0,0,0},
}


local s = {guiGetScreenSize()}
local x = s[1]/2-20
local y = s[2]-260
local box = {605,385}
local panel = {s[1]/2 -box[1]/2,s[2]/2 - box[2]/2}
local font = dxCreateFont(":sas_accounts/files/OpenSansSB.ttf", 12)
local fontR = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 15)
local lastClick = 0
local weapShow = false
local weapSelected = 0
local weapSelectedID = 0
local weapSelectedSkill = 0
local counter = 0
local hitpoints = 0
local seconds = 0
local secondShow = false
local theElement = nil
local started = false

addEventHandler("onClientClick", getRootElement(),
	function(button, state, x, y, wx, wy, wz, element)
		if button and state and state == "down" then
			if isElement(element) then
				if getElementData(element, "weapSkillPed") == true then
					pX,pY,pZ = getElementPosition(localPlayer)
					eX,eY,eZ = getElementPosition(element)
					if getDistanceBetweenPoints3D(pX,pY,pZ,eX,eY,eZ) <= 3 then
						if not weapShow then
							playSound("files/sounds/skillopen.mp3")
							weapShow = true
							theElement = element
						end
					end
				end
			end
		end
	end
)

bindKey("backspace","down",function()
	if weapShow == true then
		closePanel()
	end
end)

function secondRender()
	if secondShow == true then
		countTimer = countTimer + 1
		if countTimer > 50 then
			if not isTimer(theTimer) then
				theTimer = setTimer(function()
					seconds = seconds - 1
					if seconds < 0 then
						secondShow = false
						killTimer(theTimer)
						stopSkillGame(0)
						exports.sas_hud:addNotification("Lejárt az időd!", "error")
					end
				end, 1000, seconds)
			end
			local t1,t2 = secondsToMinutes(seconds)
			if t1 < 10 then
			t1 = "0" .. t1
			end
			if t2 < 10 then
				t2 = "0" .. t2
			end
			dxDrawText ("Idő:\n" .. t2 .. " perc és " .. t1.." másodperc.",1,s[2]-100+1,s[1],s[2],tocolor(0,0,0,255),0.70,fontR,"center","top",false,false,false,false)

			dxDrawText ("Idő:\n#32b3ef" .. t2 .. " #ffffffperc és #32b3ef" .. t1.." #ffffffmásodperc.",0,s[2]-100,s[1],s[2],tocolor(255,255,255,255),0.70,fontR,"center","top",false,false,false,true)

			dxDrawText ("Pontok: #32b3ef"..hitpoints.."#ffffff/#32b3ef25",0,20,s[1],0,tocolor(255,255,255,255),1,fontR,"center","top",false,false,false,true)
		end
	end
end
addEventHandler("onClientRender",getRootElement(),secondRender)

for k, v in pairs(wallObjs) do
	wallObj = createObject(v[1],v[2],v[3],v[4]-1,v[5], v[6], v[7])
	setElementInterior(wallObj,4)
	setElementDimension(wallObj,39)
end

function startSkillGame()
	setElementData(localPlayer, "enableall", false)
	playSound("files/sounds/skillstart.mp3")
	started = true
	secondShow = true
	countTimer = 0
	seconds = 150
	local dbid = getElementData(localPlayer,"playerid")
	setElementPosition(localPlayer,305.3095703125, -64.4189453125, 1001.515625)
	setElementRotation(localPlayer,0,0,270)
	setElementInterior(localPlayer,weapInt)
	setElementDimension(localPlayer,weapDim+dbid)
	setElementFrozen(localPlayer,true)

	for k, v in ipairs(skillObjs) do
		skillObj = createObject(v[1],v[2],v[3],v[4],v[5], v[6], v[7])
		setElementData(skillObj,"weapTable",true)
		setElementData(skillObj,"isFireTable",false)
		setElementData(skillObj,"weapTableID",k)
		setElementInterior(skillObj,weapInt)
		setElementDimension(skillObj,weapDim+dbid)
	end

	for k, v in pairs(wallObjs) do
		wallObj = createObject(v[1],v[2],v[3],v[4]-1,v[5], v[6], v[7])
		setElementInterior(wallObj,weapInt)
		setElementDimension(wallObj,weapDim+dbid)
	end


	local count = 0
	local oneObject = nil
	local oneObjX = 0
	local oneObjY = 0
	local oneObjZ = 0
	for k,v in ipairs(getElementsByType("object")) do
		if getElementData(v,"weapTable") == true then
			local objX,objY,objZ = getElementPosition(v)
			count = count+1
			randomTable = math.random(1, count)
			oneObject = v
			oneObjX = objX
			oneObjY = objY
			oneObjZ = objZ
		end
	end
	--moveObject(oneObject,1000,oneObjX,oneObjY,oneObjZ,90,0,0)
	setElementRotation(oneObject,0,0,90)

	if isTimer(fireTimer) then return end
	fireTimer = setTimer(function() end, 1200, 1)
	setElementData(oneObject,"isFireTable",true)
	killTimer(fireTimer)
end

function stopSkillGame(skillNum)
	setElementData(localPlayer, "enableall", true)
	if skillNum == 0 then
		playSound("files/sounds/roundfailed.mp3")
	elseif skillNum > 0 then
		playSound("files/sounds/roundcomplete.mp3")
	end
	started = false
	skillNum = tonumber(skillNum)
	weapDim = tonumber(weapDim)
	setElementPosition(localPlayer,295.8173828125, -64.7412109375, 1001.515625)
	setElementRotation(localPlayer,0,0,270.94073486328)
	setElementInterior(localPlayer,weapInt)
	setElementDimension(localPlayer,weapDim)
	setElementFrozen(localPlayer,false)
	hitpoints = 0
	for k,v in ipairs(getElementsByType("object")) do
		if getElementData(v,"weapTable") == true then
			if isElement(v) then
				destroyElement(v)
			end
		end
	end
	for k,v in ipairs(getElementsByType("object")) do
		if getElementData(v,"wallTable") == true then
			if isElement(v) then
				destroyElement(v)
			end
		end
	end
	triggerServerEvent("addSkillToClient",localPlayer,weapSelectedSkill,skillNum)
end

function weapSkillRender()

	if getElementData(localPlayer,"loggedin") == 1 then
		if isElement(theElement) then
			pX,pY,pZ = getElementPosition(localPlayer)
			eX,eY,eZ = getElementPosition(theElement)
			if getDistanceBetweenPoints3D(pX,pY,pZ,eX,eY,eZ) >= 3.1 then
				if weapShow then
					weapShow = false
					theElement = nil
				end
			end
		end
	end

	if weapShow == true then
		dxDrawRectangle(panel[1],panel[2],box[1],box[2],tocolor(0,0,0,140))
		exports.sas_system:radarKeret(panel[1],panel[2],box[1],box[2], 3)
		dxDrawImage(panel[1]+320,panel[2]+10,272,250,"files/logo.png",0,0,0,tocolor(255,255,255,255))
		local count = 0
		for k,v in ipairs(skillWeaps) do
			count=count+1
			if isInSlot(panel[1]+10,(panel[2]+10)+(count*30),300,30) then
				dxDrawRectangle(panel[1]+10,(panel[2]+10)+(count*30),300,30,tocolor(217, 83, 79,200))
				if getKeyState("mouse1") and lastClick+200 <= getTickCount() then
					playSound("files/sounds/skillselect.mp3")
					lastClick = getTickCount()
					weapSelected = k
					weapSelectedID = v[2]
					weapSelectedSkill = v[4]
				end
			else
				if weapSelected == k then
					dxDrawRectangle(panel[1]+10,(panel[2]+10)+(count*30),300,30,tocolor(217, 83, 79,200))
				else
					if count % 2 ~= 0 then
						dxDrawRectangle(panel[1]+10,(panel[2]+10)+(count*30),300,30,tocolor(70,70,70,100))
					else
						dxDrawRectangle(panel[1]+10,(panel[2]+10)+(count*30),300,30,tocolor(0,0,0,160))
					end
				end
			end
		--	["..getPedStat(localPlayer,v[4]).."/1000]
			dxDrawText(v[1],panel[1]+15,(panel[2]+10)+(count*30),0,(panel[2]+10)+(count*30)+30,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)
			dxDrawText("[#32b3ef"..getPedStat(localPlayer,v[4]).."#ffffff/#7cc5761000#ffffff]",panel[1]+15,(panel[2]+10)+(count*30),panel[1]+300,(panel[2]+10)+(count*30)+30,tocolor(255,255,255,255),0.9,font,"right","center",false,false,false,true)
		end
		dxDrawText("SeeMTA v3 #ffffff- Lőtér",panel[1]+5,panel[2]-23,0,0,tocolor(124, 197, 118,255),0.7,fontR,"left","top",false,false,false,true)
		dxDrawText("Elérhető fegyverek:",panel[1]+15,panel[2]+10,0,0,tocolor(124, 197, 118,255),0.8,fontR,"left","top",false,false,false,true)

		if isInSlot(panel[1]+320,panel[2]+270+10,272,30) then
			dxDrawRectangle(panel[1]+320,panel[2]+270+10,272,30,tocolor(153, 204, 153,150))
			if getKeyState("mouse1") and lastClick+200 <= getTickCount() then
				lastClick = getTickCount()
				if getPedWeapon(localPlayer) == tonumber(weapSelectedID) then
				--	if getElementData(localPlayer,"money") >= 12 then
						setElementData(localPlayer,"money",getElementData(localPlayer,"money")-12)
						closePanel()
						startSkillGame()
				--	else
					--	outputChatBox("#d9534f[SeeMTA]: #FFFFFF Nincs nálad elég pénz. (12 $.).",61,122,188,true)
					--end
				else
					outputChatBox("#d9534f[SeeMTA]: #FFFFFF A kiválasztott fegyvernek a kezedben kell lennie.",61,122,188,true)
				end
			end
		else
			dxDrawRectangle(panel[1]+320,panel[2]+270+10,272,30,tocolor(0,0,0,200))
		end
		dxDrawText("Indítás",panel[1]+320,panel[2]+270+10,panel[1]+320+272,panel[2]+270+30+10,tocolor(255,255,255,255),1,font,"center","center",false,false,false,true)

		if isInSlot(panel[1]+320,panel[2]+310-5+10,272,30) then
			dxDrawRectangle(panel[1]+320,panel[2]+310-5+10,272,30,tocolor(217, 83, 79,150))
			if getKeyState("mouse1") and lastClick+200 <= getTickCount() then
				lastClick = getTickCount()
				closePanel()
			end
		else
			dxDrawRectangle(panel[1]+320,panel[2]+310-5+10,272,30,tocolor(0,0,0,200))
		end
		dxDrawText("Kilépés",panel[1]+320,panel[2]+310-5+10,panel[1]+320+272,panel[2]+310+30-5+10,tocolor(255,255,255,255),1,font,"center","center",false,false,false,true)

	end
end
addEventHandler("onClientRender",getRootElement(),weapSkillRender)

function closePanel()
	--setCameraTarget(localPlayer)
	playSound("files/sounds/skillclose.mp3")
	weapShow = false
	weapSelected = 0
	theElement = nil
end

function onClientTableFire(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	if isElement(hitElement) and getElementsByType("object") then
		if getElementData(hitElement,"weapTable") == true then
			if getElementModel(hitElement) == 1583 or getElementModel(hitElement) == 1584 or getElementModel(hitElement) == 1585 or getElementModel(hitElement) == 1586 then
				if getElementData(hitElement,"isFireTable") == true then
					setElementData(hitElement,"isFireTable",false)
					local objX,objY,objZ = getElementPosition(hitElement)
					hitpoints = hitpoints+1
					playSound("files/sounds/tabletalalt.mp3")
					if hitpoints == 25 then
						outputChatBox("#7cc576[SeeMTA]: #FFFFFFSikeresen teljesítetted a feladatod. +10 fegyver tapasztalat a jutalmad",61,122,188,true)
						stopSkillGame(10)
						secondShow = false
						killTimer(theTimer)
					else
						counter = counter+1
						if counter == 3 then
							counter = 1
						end
						moveTableObj(hitElement,objX,objY,objZ,counter)
					end
				end
			end
		else
			if started then
				playSound("files/sounds/tablefailed.mp3")
			end
		end
	end
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer(), onClientTableFire)

function moveTableObj(obj,objX,objY,objZ,num)
	num = tonumber(num)
	--moveObject(obj,1000,objX,objY,objZ,-90,0,0)
	--setElementRotation(obj,-90,0,0)
	setElementRotation(obj,-270,0,270)
	local randomID = math.random(1, 7)
	if isTimer(fireFuncTimer) then return end
		fireFuncTimer = setTimer(function()
		for k,v in ipairs(getElementsByType("object")) do
			if tonumber(randomID) == getElementData(v,"weapTableID") then
				local oX,oY,oZ = getElementPosition(v)
				--moveObject(v,1000,oX,oY,oZ,90,0,0)
				--setElementRotation(v,90,0,0)
				setElementRotation(v,0,0,90)
				setElementData(v,"isFireTable",true)
			end
		end
		killTimer(fireFuncTimer)
	end, 1200, 1)
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

-- robbanó object fix
local disabledObjects = {
[1584] = true,
[13028] = true,
[1583] = true,
}
addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "object" and disabledObjects[getElementModel(source)] then
		setObjectBreakable(source, false)
	end
end)

addEventHandler("onClientResourceStart", root, function()
	for k, v in ipairs(getElementsByType("object", root, true)) do
		if disabledObjects[getElementModel(v)] then
			setObjectBreakable(v, false)
		end
	end
end)

function secondsToMinutes(seconds)
	local totalSec = tonumber(seconds)
	if totalSec then
		local seconds = math.fmod(math.floor(totalSec), 60)
		local minutes = math.fmod(math.floor(totalSec/60), 60)
		if seconds and minutes then
			return seconds,minutes
		end
	end
end
