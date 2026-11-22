munkaInformaciok = {
	{1, "Buszsofőr (Városi)", "", ""},
	{2, "Buszsofőr (Vidéki)", "", ""},
	{3, "Postás (Hamarosan)", "", ""},
	{4, "Áruszállító (Hamarosan)", "", ""},
	{5, "Gyártósori munkás", "", ""},
	{6, "Pizzafutár (Hamarosan)", "", ""},
}

local munkaPanelMegjelenitve = false
local floodTiltas = false
local seefont = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 20)
local seefont2 = dxCreateFont(":sas_hud/files/fonts/Roboto.ttf", 20)
local jelenoldal = 1

npcPos = {1207.9482421875, -1783.931640625, 16.03125}
local valcsi = createPed( 62,  npcPos[1], npcPos[2], npcPos[3] )

local kepS = {guiGetScreenSize()}
local size = {500, 605}
--pPadding = {14, 0}
kilepesP = {}
local munkaX, munkaY = (kepS[1]/2-size[1]/2), (kepS[2]/2-size[2]/2)


setPedRotation( valcsi, 355.62463378906 )
setElementDimension( valcsi, 0 )
setElementInterior( valcsi , 0 )
setElementData( valcsi, "talk", 1 )
setElementData( valcsi, "name", "Marco Shirt" )
setElementData ( valcsi, "visiblePedName", "Marco Shirt")
setElementData ( valcsi,"tagName","NPC")
setElementData ( valcsi,"nameEnabled",true)
setElementFrozen(valcsi, true)

function dobozbaKattint(dX, dY, dSz, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSz and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function munkaFelvetel(munkaID)
	local jelenlegiMunka = getElementData(getLocalPlayer(), "job")
	if (jelenlegiMunka == 0) then
		if((munkaID == 2 and getElementData(getLocalPlayer(), "license.car") == 1) or (munkaID ~= 2)) then
			triggerServerEvent ( "munkaFelvetel", getLocalPlayer(), munkaID )
			munkaPanelElrejtes()

			-- Munkák megjelenítése
			if (munkaID == 1) then
				displayBusJob()
			elseif (munkaID == 2) then

			elseif (munkaID == 3) then

			elseif (munkaID == 4) then
			--	showTruckThings()
			elseif (munkaID == 5) then
				showFactoryThings()
			elseif (munkaID == 6) then

			end
		else
			exports.sas_hud:addNotification("Ehhez a munkához jogosítvány szükséges!", "error")
		end
	else
		exports.sas_hud:addNotification("Már van munkád. Először mond fel a jelenlegi állásodat!", "error")
	end
end

function klikkVezerles( gomb, statusz, aX, aY, wX, wY, wZ, element )
	local jelenlegiMunka = getElementData(getLocalPlayer(), "job")
	if (munkaPanelMegjelenitve and statusz == "down") then
		-- Kilépés gomb
		if isInSlot(munkaX-30+size[1]-5, munkaY+8, 20, 20) then
			munkaPanelElrejtes()
		end
		-- Munka felvétel
		for i, e in ipairs(munkaInformaciok) do
			if(e[1] == jelenlegiMunka) then
				gombNev = "Felmondás"
			else
				gombNev = "Elfogadás"
			end


			if(dobozbaKattint(munkaX+size[1]-15-155, munkaY+35+15+ ((i-1)*95), 155, 70, aX, aY)) then
				if(e[1] == jelenlegiMunka) then
					exports.sas_hud:addNotification("Előbb mondd fel a jelenlegi állásod.", "error")
				else
					munkaFelvetel(e[1])
				end
			end
		end
	else
		if(element == valcsi and statusz == "down" and not floodTiltas) then
			munkaPanelMegjelenites()
		end
	end
end
addEventHandler ( "onClientClick", getRootElement(), klikkVezerles )

function felmondasClient()
	if getElementData(localPlayer, "loggedin") then
		if getElementData(localPlayer, "job") == 0 then
			outputChatBox("Jelenleg munkanélküli vagy. Hogy szeretnél felvenni munkát?", 255, 0, 0)
		else
			triggerServerEvent ( "munkaFelmondas", localPlayer )
			exports.sas_hud:addNotification("Sikeresen felmondtál!", "success")
		end
	end
end
addCommandHandler("felmondas", felmondasClient)

function munkaPanelMegjelenites()
	if munkaPanelMegjelenitve then return end
	floodTiltas = true
	--triggerServerEvent ( "amikorAJatekosErdeklodik", getLocalPlayer() )
	setTimer ( function() floodTiltas = false end, 2500, 1)
	munkaPanelMegjelenitve = true
	addEventHandler( "onClientRender", getRootElement(), munkaRender )
end

function munkaPanelElrejtes()
	if not munkaPanelMegjelenitve then return end
	munkaPanelMegjelenitve = false
	removeEventHandler( "onClientRender", getRootElement(), munkaRender )
end

function munkaRender()
	local jx, jy, jp = getElementPosition(getLocalPlayer())
	if (getDistanceBetweenPoints3D(jx, jy, jp, npcPos[1], npcPos[2], npcPos[3]) > 4 ) then munkaPanelElrejtes() return end
	local jelenlegiMunka = getElementData(getLocalPlayer(), "job")
	local interfacecolor = {255,255,255}
	--dxDrawImage ( munkaX+35, munkaY, p[1], p[2], 'kepek/munka.png', 0, 0, 0 )
	dxDrawRectangle(munkaX, munkaY+35, size[1], 95, tocolor(0,0,0,200)) -- alap doboz
	dxDrawRectangle(munkaX, munkaY+130, size[1], 95, tocolor(0,0,0,170)) -- alap doboz
	dxDrawRectangle(munkaX, munkaY+130+95, size[1], 95, tocolor(0,0,0,200)) -- alap doboz
	dxDrawRectangle(munkaX, munkaY+130+95+95, size[1], 95, tocolor(0,0,0,170)) -- alap doboz
	dxDrawRectangle(munkaX, munkaY+130+95+95+95, size[1], 95, tocolor(0,0,0,200)) -- alap doboz
	dxDrawRectangle(munkaX, munkaY+130+95+95+95+95, size[1], 95, tocolor(0,0,0,170)) -- alap doboz

	dxDrawRectangle(munkaX, munkaY, size[1], 35, tocolor(0,0,0,255)) -- top
	-- szövegek
	dxDrawText("See#7cc576MTA v3 #FFFFFF- Munka",munkaX+10, munkaY, 0, munkaY+35, tocolor(255,255,255,255), 0.7, seefont2,"left","center", false,false,false,true)

	if isInSlot(munkaX-30+size[1]-5, munkaY+8, 20, 20) then
		dxDrawText("X",munkaX-30+size[1], munkaY, 0, munkaY+35, tocolor(217, 83, 79,255), 0.7, seefont2,"left","center", false,false,false,true)
	else
		dxDrawText("X",munkaX-30+size[1], munkaY, 0, munkaY+35, tocolor(255,255,255,255), 0.7, seefont2,"left","center", false,false,false,true)
	end
--	dxDrawRectangle(munkaX-30+size[1]-5, munkaY+8, 20, 20)

	for i, e in ipairs(munkaInformaciok) do
		local dobozHossz = dxGetTextWidth(e[2], 1.02,"default-bold")+20
		dxDrawText ( e[2], munkaX+15, munkaY+35 + ((i-1)*95), 0, munkaY+35+ ((i-1)*95)+95, tocolor ( 255, 255, 255, 255 ), 0.6, seefont, "left", "center",false,false,true,false,true, 0,0,0)

			-- Elvállal/Felmond Gomb
		local munkaID = munkaInformaciok[1]
		local gombNev = "Elvállal"
		local szinKombinacio = {  0, 136, 204 }
		if (e[1] == jelenlegiMunka) then
			gombNev = "Felmondás"
			szinKombinacio = { 204, 0, 0 }
		end
		--155 80
		if isInSlot(munkaX+size[1]-15-155, munkaY+35+15+ ((i-1)*95), 155, 70) then
			dxDrawRectangle(munkaX+size[1]-15-155, munkaY+35+15+ ((i-1)*95), 155, 70, tocolor(124, 197, 118, 255))
		else
			dxDrawRectangle(munkaX+size[1]-15-155, munkaY+35+15+ ((i-1)*95), 155, 70, tocolor(124, 197, 118, 200))
		end
		dxDrawText ( "Munka felvétele", munkaX+size[1]-15-155, munkaY+35+15+ ((i-1)*95), munkaX+size[1]-15, munkaY+35+15+ ((i-1)*95)+70, tocolor ( 0, 0, 0, 255 ), 0.7, seefont, "center", "center",false,false,true,false,true, 0,0,0)
	end
end

--[[function munkaHelp()
	local jelenlegiMunka = getElementData(getLocalPlayer(), "job")
	if(jelenlegiMunka > 0) then
		if(jelenlegiMunka == 1) then
			outputChatBox("Kövesd a térképen látható sárga ember ikont, és az ott található épületben vedd fel a munkaruhád! (( Az épületen belül marker jelzi, \"F\" betű lenyomásával tudsz átöltözni ))", 229, 229, 229)
		elseif (jelenlegiMunka == 2) then
			outputChatBox("Kövesd a térképen látható furgon ikont, majd szállj be egy furgonba a munka megkezdéséhez!", 229, 229, 229)
		elseif(jelenlegiMunka == 3) then
			outputChatBox("Kövesd a térképen látható gyár ikont, és az ott található épületben vedd fel a munkaruhád! (( Az épületen belül marker jelzi, \"F\" betű lenyomásával tudsz átöltözni ))", 229, 229, 229)
		elseif(jelenlegiMunka == 4) then
			outputChatBox(munkaInformaciok[4][3], 229, 229, 229)
		else
			outputChatBox("Ehhez a melóhoz nem tartozik információ.", 229, 229, 229)
		end
	else
		outputChatBox("Nincs munkád...")
	end
end
addCommandHandler ( "munka", munkaHelp )--]] -- dashboardba került

bindKey("backspace", "down", function()
  munkaPanelElrejtes()
	showCursor(false)
end)

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
