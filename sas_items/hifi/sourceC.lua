local monitorScreen = {guiGetScreenSize()}
local panelSize = {200, 200}
local panelX = monitorScreen[1]/2
local panelY = monitorScreen[2]/2
local wx, wy, wz
local radio
local Font = dxCreateFont("files/fonts/Roboto.ttf", 13)
local active_Menu = {{"Bekapcsolás"}, {"Következő Állomás"}, {"Felvétel!"}, {"Bezárás"}}
local show = false
local radioSound = {}
local soundElementsOutside = {}
local player
local channelCount = 1
local channel = {}
local adasok = {
    {"http://icast.connectmedia.hu/4784/live.mp3", "Class FM"},
    {"http://92.61.114.159:7812/slagerfm128.mp3", "Juventus FM"},
    {"http://79.172.241.238:8000/musicfm.mp3", "Music FM"},
    {"http://stream.webthings.hu:8000/fm95-x-128.mp3#.mp3", "Best FM"},
    {"http://212.108.220.144:1039/#.mp3", "Disco*S HIT"},
    {"http://stream.radio1.hu:8000/mid.mp3", "Ozone FM"},
    {"http://195.56.193.129:8100/;stream.nsv#.mp3", "Sunshine FM"},
    {"http://mediagw.e-tiger.net/stream/coolfm#.mp3", "Cool FM"},
    {"http://stream001.radio.hu:8080/mr2.mp3.m3u", "Petőfi FM"},
    {"http://listen.181fm.com/181-uktop40_128k.mp3?", "UK Top 40"},
    {"http://relay.181.fm:8068", "Old School"}
}


function replaceHifi ( )
  txd = engineLoadTXD ( "hifi/hifi.txd" )
  engineImportTXD ( txd, 2103 )
end
addEvent ( "replaceHifi", true )
addEventHandler ( "replaceHifi", root, replaceHifi )


addEventHandler("onClientClick", root, function(key, state, sx, sy, wx, wy, wz, element)
	if key=="right" and state=="down" and element and getElementType(element) == "object" and getElementData(element, "hifi") then
		local x, y, z = getElementPosition(localPlayer)
		local dist = getDistanceBetweenPoints3D ( x, y, z, wx, wy, wz )
		if dist < 3 then
			show = true
			removeEventHandler("onClientRender", root, showRadioMenu)
			addEventHandler("onClientRender", root, showRadioMenu)
			radio = element
			panelX, panelY = sx, sy
			wX, wY, wZ = wx, wy, wz
			player = localPlayer
			setElementData(localPlayer, "hifi:click", false)
		end
	elseif key == "left" and state == "down" and show then
		for index, value in ipairs(active_Menu) do

			if dobozbaVan(panelX+5, panelY+index*40, panelSize[1]-10, 25, sx, sy) then

				if value[1] == "Bekapcsolás" then 	--Be és kikapcsolás

					if getElementData(localPlayer, "hifi:click") == true then
				     -- setting timer
						return
					end

					if not getElementData(radio, "hifi:state") then
						triggerServerEvent("serverStartHifi", localPlayer, radio)

					elseif getElementData(radio, "hifi:state") then
						triggerServerEvent("serverStopHifi", localPlayer, radio)
					end

					setElementData(localPlayer, "hifi:click", true)

					setTimer(function()
						setElementData(localPlayer, "hifi:click", false)
					end, 1000, 1)

				elseif value[1] == "Felvétel!" then --Felvétel a földről
					triggerServerEvent("serverStopHifi", localPlayer, radio)
					triggerServerEvent("delHifi", localPlayer, radio, getElementData(radio, "hifi:id"))
					show = false
					removeEventHandler("onClientRender", root, showRadioMenu)

				elseif value[1] == "Következő Állomás" then --Csatorna váltás

						if getElementData(localPlayer, "hifi:click") == true then
							return
						end

					if getElementData(radio, "hifi:state") then
						if channel[getElementData(radio, "hifi:id")] < #adasok then
							channelT =  channel[getElementData(radio, "hifi:id")]
						elseif channel[getElementData(radio, "hifi:id")] == #adasok then
							channelT = 0
						end
						setElementData(localPlayer, "hifi:click", true)

							setTimer(function()
								setElementData(localPlayer, "hifi:click", false)
							end, 1000, 1)

						triggerServerEvent("serverChangeChannelHifi", localPlayer, radio, channelT)
					else
						outputChatBox("#d9534f[SeeMTA]: #FFFFFFElőbb kapcsold be!", 255, 255, 255, true)
					end

				elseif value[1] == "Bezárás" then --Panel bezárása
					show = false
					removeEventHandler("onClientRender", root, showRadioMenu)
				end

			end

		end
	end
end)

function panelBezar()
	show = false
	state = false
	removeEventHandler("onClientRender", root, showRadioMenu)
end

function showRadioMenu()
	if not show then return end
		local x, y, z = getElementPosition(localPlayer)
		wx, wy, wz = wx, wy, wz
		if (getDistanceBetweenPoints3D(x, y, z, wX, wY, wZ) > 3) then panelBezar() return end

		dxDrawRectangle(panelX, panelY, panelSize[1], panelSize[2], tocolor(0, 0, 0, 180))
		dxDrawText("", panelX+75, panelY, panelX+75, panelY+15, tocolor(0, 0, 0, 230), 0.8, Font, "center", "center", false, false, true, true)

		for index, value in ipairs(active_Menu) do

			if isInSlot(panelX+5, panelY+index*40, 190, 30) then
				if value[1] == "Bekapcsolás" then
					if getElementData(radio, "hifi:state") then
						dxDrawRectangle(panelX+5, panelY+index*40, 190, 30, tocolor(202, 84, 84, 230))
					else
						dxDrawRectangle(panelX+5, panelY+index*40, 190, 30, tocolor(172, 211, 115, 230))
					end
				elseif value[1] == "Következő Állomás" then
					dxDrawRectangle(panelX+5, panelY+index*40, 190, 30, tocolor(172, 211, 115, 230))
				elseif value[1] == "Felvétel!" or value[1] == "Bezárás" then
					dxDrawRectangle(panelX+5, panelY+index*40, 190, 30, tocolor(202, 84, 84, 230))
				end
			else
				dxDrawRectangle(panelX+5, panelY+index*40, 190, 30, tocolor(0, 0, 0, 230))
			end

			if value[1] == "Bekapcsolás" then
				if getElementData(radio, "hifi:state") then
					text = "Kikapcsolás"
				else
					text = "Bekapcsolás"
				end
			else
				text = value[1]
			end
			dxDrawText(text, panelX+192/2+2, panelY+index*40+30, panelX+192/2+2, panelY+index*40, tocolor(255, 255, 255, 230), 1, Font, "center", "center", false, false, false, true)
		end
	if getElementData(radio, "hifi:state") then
		adasP = adasok[channel[getElementData(radio, "hifi:id")]][2]
	else
		adasP = "#dc143cKikapcsolva"
	end
	if adasP == "#dc143cKikapcsolva" then
		dxDrawText("#ca5454N/A", panelX+192/2, panelY,panelX+192/2, panelY+50, tocolor(255, 255, 255, 230), 1, Font, "center", "center", false, false, true, true)
	else
		dxDrawText("#4aabd0" .. adasP, panelX+192/2, panelY, panelX+192/2, panelY+50, tocolor(255, 255, 255, 230), 1, Font, "center", "center", false, false, true, true)
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

function dobozbaVan(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function startHifi(element)
	if isElement(element) then

		local x, y, z = getElementPosition(element)

		radioSound[getElementData(element, "hifi:id")] = playSound3D(adasok[channelCount][1], x, y, z)
		channel[getElementData(element, "hifi:id")] = 1
		setSoundMaxDistance( radioSound[getElementData(element, "hifi:id")], 60 )

		setElementInterior(radioSound[getElementData(element, "hifi:id")], getElementInterior(element))
		setElementDimension(radioSound[getElementData(element, "hifi:id")], getElementDimension(element))

		--outputChatBox("Hifi bekapcsolva: #"..getElementData(element, "hifi:id"))


	end
end
addEvent("clientStartHifi", true)
addEventHandler("clientStartHifi", root, startHifi)

function stopHifi(element)
	if isElement(element) then

		if isElement(radioSound[getElementData(element, "hifi:id")]) then
			stopSound(radioSound[getElementData(element, "hifi:id")])
			--outputChatBox("Hifi kikapcsolva: #"..getElementData(element, "hifi:id"))
		end

	end
end
addEvent("clientStopHifi", true)
addEventHandler("clientStopHifi", root, stopHifi)

function changeChannelHifi(element)
	if isElement(element) then

		local x, y, z = getElementPosition(element)
		stopSound(radioSound[getElementData(element, "hifi:id")])

		if channel[getElementData(element, "hifi:id")] < #adasok then

			channel[getElementData(element, "hifi:id")] = channel[getElementData(element, "hifi:id")] + 1
			radioSound[getElementData(element, "hifi:id")] = playSound3D(adasok[channel[getElementData(element, "hifi:id")]][1], x, y, z)
			setSoundMaxDistance( radioSound[getElementData(element, "hifi:id")], 60 )
			setElementInterior(radioSound[getElementData(element, "hifi:id")], getElementInterior(element))
			setElementDimension(radioSound[getElementData(element, "hifi:id")], getElementDimension(element))

		elseif channel[getElementData(element, "hifi:id")] == #adasok then

			channel[getElementData(element, "hifi:id")] = 1
			radioSound[getElementData(element, "hifi:id")] = playSound3D(adasok[channel[getElementData(element, "hifi:id")]][1], x, y, z)
			setSoundMaxDistance( radioSound[getElementData(element, "hifi:id")], 60 )
			setElementInterior(radioSound[getElementData(element, "hifi:id")], getElementInterior(element))
			setElementDimension(radioSound[getElementData(element, "hifi:id")], getElementDimension(element))
		end
		--outputChatBox("Hifi csatorna váltva: #"..getElementData(element, "hifi:id").. " csatorna: " .. adasok[channel[getElementData(element, "hifi:id")]][2] .. "")

	end
end
addEvent("clientChangeChannelHifi", true)
addEventHandler("clientChangeChannelHifi", root, changeChannelHifi)
