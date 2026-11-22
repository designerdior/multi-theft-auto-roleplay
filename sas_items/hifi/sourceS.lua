local count = 0
local hifi = {}
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

function createHifi()
	if isElement(client) then
		local x, y, z = getElementPosition(client)
		local rx, ry, rz = getElementRotation(client)
		local int = getElementInterior(client)
		local dim = getElementDimension(client)
		count = count + 1
		hifi = createObject(2103, x, y, z-1, rx, ry, rz-180)
		setElementInterior(hifi, int)
		setElementDimension(hifi, dim)
  --  triggerClientEvent( "replaceHifi", client, replaceHifi )
		if isElement(hifi) then
			setElementData(hifi, "hifi", hifi)
			setElementData(hifi, "hifi:id", count)
			--outputChatBox("#".. count .. " hifi lerakva")
			exports.sas_chat:sendLocalMeAction(client, "lerakott egy tárgyat a földre. (Hi-Fi)")
		end
	end
end
addEvent("createHifi", true)
addEventHandler("createHifi", getRootElement(), createHifi)

function delHifi(element, count)
	if isElement(element) then
		destroyElement(element)
		giveItem(source, 149, 1, 1, 0)
		exports.sas_chat:sendLocalMeAction(source, "felvett egy tárgyat a foldről. (Hi-Fi)")
	end
end
addEvent("delHifi", true)
addEventHandler("delHifi", getRootElement(), delHifi)

function startHifi(element)
	if isElement(element) then
		setElementData(element, "hifi:state", true)
		local x, y, z = getElementPosition(element)

		exports.sas_chat:sendLocalMeAction(source, "bekapcsolta a Hi-Fit.")
		triggerClientEvent(root, "clientStartHifi", root, element)


	end
end
addEvent("serverStartHifi", true)
addEventHandler("serverStartHifi", root, startHifi)

function stopHifi(element)
	if isElement(element) then
		setElementData(element, "hifi:state", false)
		local x, y, z = getElementPosition(element)

		exports.sas_chat:sendLocalMeAction(source, "kikapcsolta a Hi-Fit.")
		triggerClientEvent(root, "clientStopHifi", root, element)


	end
end
addEvent("serverStopHifi", true)
addEventHandler("serverStopHifi", root, stopHifi)

function changeChannelHifi(element, channel)
	if isElement(element) then

		triggerClientEvent(root, "clientChangeChannelHifi", root, element)
		exports.sas_chat:sendLocalMeAction(source, "csatornát váltott. (" .. adasok[channel+1][2] .. ")")
	end
end
addEvent("serverChangeChannelHifi", true)
addEventHandler("serverChangeChannelHifi", root, changeChannelHifi)
