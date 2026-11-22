local sx,sy = guiGetScreenSize()

local font = dxCreateFont(":sas_rent/files/Roboto.ttf",14)
local font2 = dxCreateFont(":sas_accounts/files/OpenSansSB.ttf",13)
local font3 = dxCreateFont(":sas_accounts/files/OpenSans.ttf",11)
local handFont = dxCreateFont("files/hand.ttf",15)
local passportFont = dxCreateFont(":sas_accounts/files/OpenSansL.ttf", 20)
local signFont = dxCreateFont("files/lunabar.ttf",25)
local signFont2 = dxCreateFont("files/lunabar.ttf",27)

local identityPedPos = {
	{1155.3537597656, -1783.0959472656, 16.0625, 0, 0, 0,  "Kenneth Velasquez" , 30},
}

local identityRefreshMarker = createMarker(1155.166015625, -1781.494140625, 16.0625-1, "cylinder", 2, 0, 0, 0, 0)

local identityPed = {}
local panelState = false

if fileExists("sourceC.lua") then 
	fileDelete("sourceC.lua")
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function ()
	for index, value in ipairs (identityPedPos) do
		if isElement(identityPed[index]) then
			destroyElement(identityPed[index])
		else
			identityPed[index] = createPed(value[8], value[1], value[2], value[3])
			setElementRotation(identityPed[index], value[4], value[5], value[6])
			identityPed[index]:setData("ped:Identity", true)
			setElementFrozen(identityPed[index], true)
			identityPed[index]:setData("ped:name",value[7])
			--[[  Name Tag things  ]]--
			setElementData(identityPed[index], "nameEnabled", true)
			setElementData(identityPed[index],"tagName", "NPC")
			setElementData(identityPed[index],"name",identityPedPos[1][7])
			setElementData(identityPed[index],"visiblePedName", identityPedPos[1][7])
		end
	end
end)

function unfrozen()
	setElementFrozen(localPlayer, false)
end
addCommandHandler("unf", unfrozen)

--Személyi Igazolvány, útlevél
local loadServerToClient = false
local loadServerToClientUtlevel = false
local Elohoz = false
local ElohozUtlevel = false
local tableIndentity = {}
local tableUtlevel = {}
-- jogsi
local renderJogsi = false
local tableJogsi = {}
local loadServerToClientJogsi = false
local itemValue = 0

-- horgász
local tableHorgasz = {}
local loadServerToClientHorgasz = false
local renderHorgasz = false

function ShowIdentityCard(ItemV)
	if (Elohoz) then
		Elohoz = false
		loadServerToClient = false
		tableIndentity = {}
		itemValue = 0
	elseif not (Elohoz) then
		Elohoz = true
		itemValue = ItemV
		if not loadServerToClient then
			triggerServerEvent("getPlayerToIdentity",localPlayer,ItemV)
		end
	end
end

function ShowJogsi(ItemV)
	if (renderJogsi) then
		renderJogsi = false
		loadServerToClientJogsi = false
		tableJogsi = {}
		itemValue = 0
	elseif not (renderJogsi) then
		renderJogsi = true
		itemValue = ItemV
		if not loadServerToClientJogsi then
			triggerServerEvent("getPlayerToJogsi",localPlayer,ItemV)
		end
	end
end

function ShowHorgasz(ItemV)
	if (renderHorgasz) then
		renderHorgasz = false
		loadServerToClientHorgasz = false
		tableHorgasz = {}
		itemValue = 0
	elseif not (renderHorgasz) then
		renderHorgasz = true
		itemValue = ItemV
		if not loadServerToClientHorgasz then
			triggerServerEvent("getPlayerToHorgasz",localPlayer,ItemV)
		end
	end
end

function ShowUtlevelCard(ItemV)
	if (ElohozUtlevel) then
		ElohozUtlevel = false
		loadServerToClientUtlevel = false
		tableUtlevel = {}
	elseif not (ElohozUtlevel) then
		ElohozUtlevel = true
		if not loadServerToClientUtlevel then
			triggerServerEvent("getPlayerToUtlevel",localPlayer,ItemV)
		end
	end
end

function panelFelrajzolas()
	if not panelState then return end

	local jX, jY, jZ = getElementPosition(getLocalPlayer())
	local bX, bY, bZ = identityPedPos[1][1],identityPedPos[1][2],identityPedPos[1][3]
	if (getDistanceBetweenPoints3D(jX, jY, jZ, bX, bY, bZ) > 5 ) then
		panelState = false
		removeEventHandler("onClientRender",root,panelFelrajzolas)
		return
	end


	dxDrawRectangle(sx/2-300,sy/2-455/2,600,35,tocolor(0,0,0,150))
	dxDrawText("See#7cc576MTA v3#FFFFFF - Okmányiroda",sx/2-300+10,sy/2-455/2,sx/2-300+600,sy/2-455/2+35,tocolor(255,255,255,255),1,font,"left","center",false,false,false,true)
	--dxDrawText("X",sx/2+250-20,sy/2-185,sx/2-250-20,sy/2-185,tocolor(255,255,255,255),1,font,"left","center",false,false,false,true)

	if isInSlot(sx/2+300-25,sy/2-455/2+7,20,20) then
		dxDrawText("X",sx/2+300-20,sy/2-455/2,sx/2-250-20,sy/2-455/2+35,tocolor(217, 83, 79,255),1,font,"left","center",false,false,false,true)
	else
		dxDrawText("X",sx/2+300-20,sy/2-455/2,sx/2-250-20,sy/2-455/2+35,tocolor(255,255,255,255),1,font,"left","center",false,false,false,true)
	end
	dxDrawRectangle(sx/2-300,sy/2-455/2+35,600,60,tocolor(0,0,0,70))
	dxDrawRectangle(sx/2-300,sy/2-455/2+95,600,60,tocolor(0,0,0,100))
	dxDrawRectangle(sx/2-300,sy/2-455/2+155,600,60,tocolor(0,0,0,70))
	dxDrawRectangle(sx/2-300,sy/2-455/2+35+180,600,60,tocolor(0,0,0,100))
  dxDrawRectangle(sx/2-300,sy/2-455/2+35+240,600,60,tocolor(0,0,0,70))
	dxDrawRectangle(sx/2-300,sy/2-455/2+35+300,600,60,tocolor(0,0,0,100))
	dxDrawRectangle(sx/2-300,sy/2-455/2+35+360,600,60,tocolor(0,0,0,70))
	dxDrawText("Személyi Igazolvány (100 $)",sx/2-300+10,sy/2-455/2+35,sx/2-300,sy/2-455/2+35+60,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)
	dxDrawText("Útlevél (350 $)",sx/2-300+10,sy/2-455/2+35+60,sx/2-300,sy/2-455/2+35+60+60,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)
	dxDrawText("Horgászengedély: Los Santos és környéke (200 $)",sx/2-300+10,sy/2-455/2+35+120,sx/2-300,sy/2-455/2+35+60+120,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)
	dxDrawText("Horgászengedély: San Fierro és környéke (200 $)",sx/2-300+10,sy/2-455/2+35+180,sx/2-300,sy/2-455/2+35+60+180,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)
	dxDrawText("Horgászengedély: Angel Pine és környéke (200 $)",sx/2-300+10,sy/2-455/2+35+240,sx/2-300,sy/2-455/2+35+60+240,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)
	dxDrawText("Horgászengedély: Red Country és környéke (200 $)",sx/2-300+10,sy/2-455/2+35+300,sx/2-300,sy/2-455/2+35+60+300,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)
	dxDrawText("Üres adásvételi (100 $)",sx/2-300+10,sy/2-455/2+35+360,sx/2-300,sy/2-455/2+35+60+360,tocolor(255,255,255,255),0.9,font,"left","center",false,false,false,true)

	if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30,100,30) then --Személyi
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30,100,30,tocolor(124,197,118,255))
	else
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30,100,30,tocolor(124,197,118,200))
	end

	dxDrawText("Kiváltás",sx/2-300+600-15-100,sy/2-455/2+35+30+15-30,sx/2-300+600-15-100+100,sy/2-455/2+35+30+15,tocolor(0,0,0,255),0.8,font,"center","center",false,false,false,true)


	if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60,100,30) then --Útlevél
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60,100,30,tocolor(124, 197, 118,255))
	else
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60,100,30,tocolor(124, 197, 118,200))
	end
	dxDrawText("Kiváltás",sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60,sx/2-300+600-15,sy/2-455/2+35+30+15-30+90,tocolor(0,0,0,255),0.8,font,"center","center",false,false,false,true)

	if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+120,100,30) then --horgászengedély1
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+120,100,30,tocolor(124, 197, 118,255))
	else
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+120,100,30,tocolor(124, 197, 118,200))
	end
	dxDrawText("Kiváltás",sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+120,sx/2-300+600-15,sy/2-455/2+35+30+15-30+150,tocolor(0,0,0,255),0.8,font,"center","center",false,false,false,true)

	if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+180,100,30) then --horgászengedély2
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+180,100,30,tocolor(124, 197, 118,255))
	else
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+180,100,30,tocolor(124, 197, 118,200))
	end
	dxDrawText("Kiváltás",sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+180,sx/2-300+600-15,sy/2-455/2+35+30+15-30+150+60,tocolor(0,0,0,255),0.8,font,"center","center",false,false,false,true)

	if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+240,100,30) then --horgászengedély3
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+240,100,30,tocolor(124, 197, 118,255))
	else
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+240,100,30,tocolor(124, 197, 118,200))
	end
	dxDrawText("Kiváltás",sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+240,sx/2-300+600-15,sy/2-455/2+35+30+15-30+150+120,tocolor(0,0,0,255),0.8,font,"center","center",false,false,false,true)

	if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+300,100,30) then --horgászengedély4
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+300,100,30,tocolor(124, 197, 118,255))
	else
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+300,100,30,tocolor(124, 197, 118,200))
	end
	dxDrawText("Kiváltás",sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+300,sx/2-300+600-15,sy/2-455/2+35+30+15-30+150+180,tocolor(0,0,0,255),0.8,font,"center","center",false,false,false,true)


	if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60+300,100,30) then --adásvételi
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60+300,100,30,tocolor(124, 197, 118,255))
	else
		dxDrawRectangle(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60+300,100,30,tocolor(124, 197, 118,200))
	end
	dxDrawText("Kiváltás",sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60+300,sx/2-300+600-15,sy/2-455/2+35+30+15-30+90+300,tocolor(0,0,0,255),0.8,font,"center","center",false,false,false,true)
end

function clickFunction(button, state, absX, absY, wx, wy, wz, element)
	if element and element:getData("ped:Identity") then
		if state == "down" and button == "right" then
			local x, y, z = getElementPosition(getLocalPlayer())
			if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz) <= 5 then
				if not panelState then
					panelState = true
					removeEventHandler("onClientRender", root, panelFelrajzolas)
					addEventHandler("onClientRender", root, panelFelrajzolas)
				end
			end
		end
	end
	if state == "down" and button == "left" then
		if panelState then
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30,100,30) then
				if getElementData(localPlayer,"money") >= 100 then
					exports.sas_hud:addNotification("Sikeresen igényeltél egy személyi igazolványt!","success")
					triggerServerEvent("InzertSQL", localPlayer)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60,100,30) then
				if getElementData(localPlayer,"money") >= 350 then
					exports.sas_hud:addNotification("Sikeresen kiváltottad!","success")
					triggerServerEvent("InzertSQLUtlevel", localPlayer)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+120,100,30) then
				if getElementData(localPlayer,"money") >= 200 then
					exports.sas_hud:addNotification("Sikeresen kiváltottad!","success")
					triggerServerEvent("InzertSQLHorgasz", localPlayer, 1)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+180,100,30) then
				if getElementData(localPlayer,"money") >= 200 then
					exports.sas_hud:addNotification("Sikeresen kiváltottad!","success")
					triggerServerEvent("InzertSQLHorgasz", localPlayer, 2)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+240,100,30) then
				if getElementData(localPlayer,"money") >= 200 then
					exports.sas_hud:addNotification("Sikeresen kiváltottad!","success")
					triggerServerEvent("InzertSQLHorgasz", localPlayer, 3)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+300,100,30) then
				if getElementData(localPlayer,"money") >= 200 then
					exports.sas_hud:addNotification("Sikeresen kiváltottad!","success")
					triggerServerEvent("InzertSQLHorgasz", localPlayer, 4)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+120,100,30) then
				if getElementData(localPlayer,"money") >= 200 then
					exports.sas_hud:addNotification("Sikeresen kiváltottad!","success")
					triggerServerEvent("InzertSQLHorgasz", localPlayer, 1)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2-300+600-15-100,sy/2-455/2+35+30+15-30+60+300,100,30) then
				if getElementData(localPlayer,"money") >= 100 then
					exports.sas_hud:addNotification("Sikeresen vettél egy üres adásvételit!","success")
					triggerServerEvent("adasveteliIgenyles", localPlayer)
				else
					exports.sas_hud:addNotification("Nincs elég pénzed!","error")
					return
				end
			end
			if isInSlot(sx/2+300-25,sy/2-455/2+7,20,20) then
				panelState = false
				removeEventHandler("onClientRender",root,panelFelrajzolas)
			end
		end
		if isElementWithinMarker(localPlayer, identityRefreshMarker) then
			if isInSlot(sx/2-85,sy/2+130, 170, 30) and renderJogsi then
				if tonumber(getElementData(localPlayer, "money")) >= 75 then
					triggerServerEvent("refreshLicense",localPlayer,itemValue, "driving")
				--outputChatBox(itemValue)
					ShowJogsi()
				else
					exports.sas_hud:addNotification("Nincs elég pénzed, hogy megújítsd a jogosítványodat!", "error")
				end
			end
			if isInSlot(sx/2-85,sy/2+130, 170, 30) and Elohoz then
				if tonumber(getElementData(localPlayer, "money")) >= 75 then
					triggerServerEvent("refreshLicense",localPlayer,itemValue, "identity")
				--outputChatBox(itemValue)
					ShowIdentityCard()
				else
					exports.sas_hud:addNotification("Nincs elég pénzed, hogy megújítsd a személyidet!", "error")
				end
			end
			if isInSlot(sx/2-85,sy/2+230, 170, 30) and renderHorgasz then
				if tonumber(getElementData(localPlayer, "money")) >= 150 then
					triggerServerEvent("refreshLicense",localPlayer,itemValue, "horgasz")
				--outputChatBox(itemValue)
					ShowHorgasz()
				else
					exports.sas_hud:addNotification("Nincs elég pénzed, hogy megújítsd a horgászengedélyedet!", "error")
				end
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickFunction, true)

addEventHandler ( "onClientPedDamage", getRootElement(),
	function ()
		if getElementData(source,"ped:Identity") then
			cancelEvent ()
		end
	end
)


addEvent("ReceiveIdentity", true)
addEventHandler("ReceiveIdentity", root , function (value)
	tableIndentity = value
	loadServerToClient = true
end)

addEvent("ReceiveJogsi", true)
addEventHandler("ReceiveJogsi", root , function (value)
	tableJogsi = value
	loadServerToClientJogsi = true
end)

addEvent("ReceiveUtlevel", true)
addEventHandler("ReceiveUtlevel", root , function (value)
	tableUtlevel = value
	loadServerToClientUtlevel = true
end)

addEvent("ReceiveHorgasz", true)
addEventHandler("ReceiveHorgasz", root , function (value)
	tableHorgasz = value
	loadServerToClientHorgasz = true
end)

addEventHandler("onClientKey", root, function(k,v)
	if panelState then
		if k == "backspace" and v then
			panelState = false
			removeEventHandler("onClientRender",root,panelFelrajzolas)
		end
	end
end)
local locationText = ""
function horgaszRender()
	if renderHorgasz and loadServerToClientHorgasz then
		if tableHorgasz["Type"] == 1 then
			locationText = "Los Santos és környéke"
		elseif tableHorgasz["Type"] == 2 then
			locationText = "San Fierro és környéke"
		elseif tableHorgasz["Type"] == 3 then
			locationText = "Angel Pine és környéke"
		elseif tableHorgasz["Type"] == 4 then
			locationText = "Red Country és környéke"
		end
		dxDrawImage(sx/2-140,sy/2-373/2,280,373,"files/fishing.png")
		dxDrawText("Név: "..tableHorgasz['Name'], sx/2-140+18+5,sy/2+17,sx/2-140+18+250,sy/2+17+38, tocolor(0,0,0,255), 0.5, handFont, "left", "center", false, false, false)
		dxDrawText("Területek: "..locationText, sx/2-140+18+5,sy/2+17+35,sx/2-140+18+250,sy/2+17+38+35, tocolor(0,0,0,255), 0.5, handFont, "left", "center", false, false, false)
		dxDrawText("Érvényesség: "..tableHorgasz['Lejarat']:gsub("-", ".")..".", sx/2-140+18+5,sy/2+17+38+30,sx/2-140+18+250,sy/2+17+38+38+30, tocolor(0,0,0,255), 0.5, handFont, "left", "center", false, false, false)
		dxDrawText(tableHorgasz['Name'], sx/2-140+80,sy/2-373/2+325,sx/2-140+80+190,0, tocolor(102, 153, 204,255), 1, signFont2, "center", "top", false, false, false)
		if isElementWithinMarker(localPlayer, identityRefreshMarker) then
			if isInSlot(sx/2-85,sy/2+230, 170, 30) then
				dxDrawRectangle(sx/2-85,sy/2+230, 170, 30, tocolor(124, 197, 118, 255))
			else
				dxDrawRectangle(sx/2-85,sy/2+230, 170, 30, tocolor(124, 197, 118, 200))
			end
			dxDrawText("Megújítás (75 $)",sx/2-85,sy/2+230,sx/2-85+170,sy/2+230+30, tocolor(0,0,0,255),1, font3, "center", "center", false, false, false)
			exports.sas_system:radarKeret(sx/2-85,sy/2+230, 170, 30, 3)
		end
	end
end
addEventHandler("onClientRender", root, horgaszRender)

function jogsiRender()
	if renderJogsi and loadServerToClientJogsi then
		dxDrawImage(sx/2-204,sy/2-124,408,248,"files/car.png")
		dxDrawText("Név: "..tableJogsi['Name'], sx/2-170+100,sy/2-55-50,sx,sy/2-55+105, tocolor(0,0,0,255), 0.7, font, "left", "center", false, false, false)
		dxDrawText("Lakhely: See-City", sx/2-170+100,sy/2-55,sx,sy/2-55+105-20+5, tocolor(0,0,0,255), 0.7, font, "left", "center", false, false, false)
		dxDrawText("Azonosító: "..tableJogsi['cardID'], sx/2-170+100,sy/2-55,sx,sy/2-55+105+10+5+5, tocolor(0,0,0,255), 0.7, font, "left", "center", false, false, false)
		dxDrawText("Érvényesség: "..tableJogsi['Lejarat']:gsub("-", ".")..".", sx/2-170+100,sy/2-55,sx,sy/2-55+105+60, tocolor(0,0,0,255), 0.7, font, "left", "center", false, false, false)
		dxDrawText(tableJogsi['Name'], sx,sy/2+70,sx/2+180,sy, tocolor(0,0,0,255), 0.7, signFont, "right", "top", false, false, false)
		local skinID = tableJogsi['Skin']
		dxDrawImage(sx/2-288+100,sy/2-55, 105, 105, ":sas_accounts/skins/".. skinID ..".jpg", 0, 0, 0)
		if isElementWithinMarker(localPlayer, identityRefreshMarker) then
			if isInSlot(sx/2-85,sy/2+130, 170, 30) then
				dxDrawRectangle(sx/2-85,sy/2+130, 170, 30, tocolor(124, 197, 118, 255))
			else
				dxDrawRectangle(sx/2-85,sy/2+130, 170, 30, tocolor(124, 197, 118, 200))
			end
			dxDrawText("Megújítás (75 $)",sx/2-85,sy/2+130,sx/2-85+170,sy/2+130+30, tocolor(0,0,0,255),1, font3, "center", "center", false, false, false)
			exports.sas_system:radarKeret(sx/2-85,sy/2+130, 170, 30, 3)
		end
	end
end
addEventHandler("onClientRender", root, jogsiRender)

function panelRender()
	if Elohoz and loadServerToClient then

		dxDrawImage(sx/2-204,sy/2-124,408,248,"files/identity.png")
		dxDrawText(tableIndentity['Name'], sx/2-130+100,sy/2-48,sx,sy, tocolor(0,0,0,255), 0.8, font, "left", "top", false, false, false)
		dxDrawText("See-City", sx/2-110+100,sy/2-25,sx,sy, tocolor(255,255,255,255), 1.0, font3, "left", "top", false, false, false)
		dxDrawText(tableIndentity['cardID'], sx/2-95+100,sy/2,sx,sy, tocolor(255,255,255,255), 1, font3, "left", "top", false, false, false)
		dxDrawText(tableIndentity['Lejarat']:gsub("-", ".")..".", sx/2-80+100,sy/2+25,sx,sy, tocolor(255,255,255,255), 1.0, font3, "left", "top", false, false, false)
		dxDrawText(tableIndentity['Name'], sx/2-280+100-10,sy/2+70,sx,sy, tocolor(255,255,255,255), 0.8, signFont, "left", "top", false, false, false)
		local skinID = tableIndentity['Skin']
		dxDrawImage(sx/2-288+100,sy/2-55, 105, 105, ":sas_accounts/skins/".. skinID ..".jpg", 0, 0, 0)
		if isElementWithinMarker(localPlayer, identityRefreshMarker) then
			if isInSlot(sx/2-85,sy/2+130, 170, 30) then
				dxDrawRectangle(sx/2-85,sy/2+130, 170, 30, tocolor(124, 197, 118, 255))
			else
				dxDrawRectangle(sx/2-85,sy/2+130, 170, 30, tocolor(124, 197, 118, 200))
			end
			dxDrawText("Megújítás (75 $)",sx/2-85,sy/2+130,sx/2-85+170,sy/2+130+30, tocolor(0,0,0,255),1, font3, "center", "center", false, false, false)
			exports.sas_system:radarKeret(sx/2-85,sy/2+130, 170, 30, 3)
		end
	end
end
addEventHandler("onClientRender", root, panelRender)

function UtlevelDraw()
	if ElohozUtlevel and loadServerToClientUtlevel then
		local pName = getPlayerName(localPlayer):gsub("_", " ")
		local pDesc = getElementData(localPlayer, "description")
		local pAge = getElementData(localPlayer, "age")
		local pGender = getElementData(localPlayer, "gender")
		local pWeight = getElementData(localPlayer, "weight")
		local pHeight = getElementData(localPlayer, "height")
		if pGender == 0 then
			pGenderText = "férfi"
		elseif pGender == 1 then
			pGenderText = "nő"
		end
		dxDrawImage(sx/2-481/2, sy/2-277/2, 481, 277, "files/passport.png")
		dxDrawText(tableUtlevel['Name']:gsub(" ","\n"), sx/2+28, sy/2-86,sx/2+28, sy/2-66, tocolor(0,0,0,255), 0.55, passportFont, "left", "center", false, false, false)

			dxDrawText(pHeight.." cm", sx/2+28, sy/2+19, sx/2+28, sy/2+19,tocolor(0,0,0,255), 0.55, passportFont, "left", "center")
			dxDrawText(pWeight.." kg", sx/2+28, sy/2-2, sx/2+28, sy/2-2,tocolor(0,0,0,255), 0.55, passportFont, "left", "center")
			dxDrawText(pGenderText, sx/2+28, sy/2-23, sx/2+28, sy/2-23,tocolor(0,0,0,255), 0.55, passportFont, "left", "center")
			dxDrawText(pAge.. " év", sx/2+28, sy/2-44, sx/2+28, sy/2-44,tocolor(0,0,0,255), 0.55, passportFont, "left", "center")
			dxDrawText(pDesc, sx/2-220, sy/2+47, sx/2+25, sy/2+47,tocolor(0,0,0,255), 0.55, passportFont, "left", "top", false,true)
			dxDrawText(pName,sx/2-481/2-20, sy/2-277/2-20, sx/2-481/2+481-20, sy/2-277/2+277-20,tocolor(0,0,0,255),1,signFont, "right", "bottom")
		--dxDrawText("Los Santos", sx/2-110,sy/2-25,sx,sy, tocolor(255,255,255,255), 1.0, font3, "left", "top", false, false, false)
	--	dxDrawText(tableIndentity['Lejarat']:gsub("-", ".")..".", sx/2-80,sy/2+25,sx,sy, tocolor(255,255,255,255), 1.0, font3, "left", "top", false, false, false)
		--dxDrawText(tableIndentity['Name'], sx/2-280,sy/2+70,sx,sy, tocolor(255,255,255,255), 1.0, signFont, "left", "top", false, false, false)
		local skinID = tableUtlevel['Skin']
		dxDrawImage(sx/2-481/2+20, sy/2-277/2+42, 122, 123, ":sas_accounts/skins/"..skinID..".jpg")
	end
end
addEventHandler("onClientRender", root, UtlevelDraw)
------------------------------------------------------------------------------------------------------------------
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
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end
end
