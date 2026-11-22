min, max, cos, sin, rad, deg, atan2 = math.min, math.max, math.cos, math.sin, math.rad, math.deg, math.atan2
sqrt, abs, floor, ceil, random = math.sqrt, math.abs, math.floor, math.ceil, math.random
gsub = string.gsub

screenW, screenH = guiGetScreenSize()

reMap = function(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultiplier = math.min(1, reMap(screenW, 1024, 1920, 0.75, 1))

resp = function(value)
	return value * responsiveMultiplier
end

respc = function(value)
	return ceil(value * responsiveMultiplier)
end

deepcopy = function(original)
	local copy

	if type(original) == "table" then
		copy = {}

		for k, v in next, original, nil do
			copy[deepcopy(k)] = deepcopy(v)
		end

		setmetatable(copy, deepcopy(getmetatable(original)))
	else
		copy = original
	end

	return copy
end

local function rotateAround(angle, x, y)
	angle = math.rad(angle)
	local cosinus, sinus = math.cos(angle), math.sin(angle)
	return x * cosinus - y * sinus, x * sinus + y * cosinus
end



local mapTextureSize = 3072
local mapRatio = 6000 / mapTextureSize

local minimapPosX = 0
local minimapPosY = 0
local minimapWidth = respc(320)
local minimapHeight = respc(225)
local minimapCenterX = minimapPosX + minimapWidth / 2
local minimapCenterY = minimapPosY + minimapHeight / 2
local minimapRenderSize = 400
local minimapRenderHalfSize = minimapRenderSize * 0.5
local minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize)
local playerMinimapZoom = 0.5
local minimapZoom = playerMinimapZoom
local minimapIsVisible = true

local bigmapPosX = 30
local bigmapPosY = 30
local bigmapWidth = screenW - 60
local bigmapHeight = screenH - 60
local bigmapCenterX = bigmapPosX + bigmapWidth / 2
local bigmapCenterY = bigmapPosY + bigmapHeight / 2
local bigmapZoom = 0.5
local bigmapIsVisible = false

local lastCursorPos = false
local mapDifferencePos = false
local mapMovedPos = false
local lastDifferencePos = false
local mapIsMoving = false
local lastMapPosX, lastMapPosY = 0, 0
local mapPlayerPosX, mapPlayerPosY = 0, 0

local zoneLineHeight = respc(30)
local screenSource = dxCreateScreenSource(screenW, screenH)

local gpsLineWidth = respc(60)
local gpsLineIconSize = respc(40)
local gpsLineIconHalfSize = gpsLineIconSize / 2
local createdTextures = {}

settingsStorage = {
	show3DBlips = true,
}

createdFonts = {}

occupiedVehicle = false

createdBlips = {}
local mainBlips = {
  {1758.576171875, -1790.1455078125, 14.446235656738, "blips/tuning.png"},
	{1037.27734375, -915.96875, 42.415550231934, "blips/tuning.png"},
	{1186.3642578125, -1338.4306640625, 14.153672218323, "blips/korhaz.png"},
	{2129.96875, -1151.3203125, 24.039527893066, "blips/carshop.png"},
	{1197.32421875, -1781.9912109375, 16.729686737061, "blips/vh.png"},
	{1555.0703125, -1675.6728515625, 16.1953125, "blips/pd.png"},
	{1929.7763671875, -1776.333984375, 13.546875, "blips/fuel.png"},
	{1344.7783203125, -1556.767578125, 13.555365562439, "blips/fuel.png"},
	{998.6357421875, -929.0478515625, 42.2265625, "blips/fuel.png"},
	{-89.6513671875, -1170.7841796875, 2.362131357193, "blips/fuel.png"},

	{2102.751953125, -1808.412109375, 13.230278015137, "blips/burger.png"},
	{1974.72265625, -2308.7998046875, 39.546875, "blips/repter.png"},
	{1465.6015625, -1011.271484375, 26.84375, "blips/bank.png"},
	{51.474609375, -1531.3779296875, 5.2921543121338, "blips/hatar.png"},
	{-17.220703125, -1353.90625, 11.300708770752, "blips/hatar.png"},
	{2244.634765625, -1664.611328125, 15.4765625, "blips/binco.png"},
	{343.3818359375, -1360.9140625, 14.511895179749, "blips/autosiskola.png"},
	{1726.0634765625, -1145.25390625, 30.584747314453, "blips/szerelo.png"},
	{135.2998046875, -1787.9462890625, 5.7118921279907, "blips/kikoto.png"},
	{1809.42578125, -1166.8564453125, 24.2265625, "blips/loter.png"},
	{379.6181640625, -2082.6044921875, 7.8359375, "blips/fisherman.png"},

	{2770.6806640625, -1628.72265625, 12.177460670471, "blips/gyar.png"},
	{1631.619140625, -1172.1591796875, 24.078125, "blips/lottoblip.png"},
	{920.6376953125, -995.2431640625, 38.189720153809, "blips/templom.png"},
	{412.1005859375, -1748.5400390625, 9.15625, "blips/club.png"},
	{715.158203125, -1698.919921875, 2.4296875, "blips/boat.png"},
	{723.8818359375, -1503.984375, 2.4296851158142, "blips/szerelo_boat.png"},
	{1489.857421875, -1766.626953125, 16.729686737061, "blips/plaza.png"},
	{1452.822265625, -1763.578125, 20.729686737061, "blips/binco.png"},
	{1561.3310546875, -2315.384765625, 13.548420906067, "blips/carrent.png"},
	{115.1590423584, 2959.9367675781, 72.15119934082, "blips/north.png", true, 9999, 16.5},
}

local blipTooltips = {
	["blips/versenypalya.png"] = "Versenypálya",
	["blips/club.png"] = "Disco",
	["blips/shop_h.png"] = "Hobby bolt",
	["blips/carshop.png"] = "Autókereskedés",
	["blips/bank.png"] = "Bank",
	["blips/autosiskola.png"] = "Autósiskola",
	["blips/tuning.png"] = "Tuning",
	["blips/korhaz.png"] = "Kórház",
	["blips/pd.png"] = "Rendőrség",
	["blips/cb.png"] = "Cluckin' Bell",
	["blips/vh.png"] = "Városháza",
	["blips/szerelo.png"] = "Szerelőtelep",
	["blips/banya.png"] = "Bánya",
	["blips/gyar.png"] = "Gyár",
	["blips/repter.png"] = "Reptér",
	["blips/plaza.png"] = "See-City Mall",
	["blips/fuel.png"] = "Benzinkút",
	["blips/hatar.png"] = "Határátkelőhely",
	["blips/templom.png"] = "Templom",
	["blips/loter.png"] = "Lőtér",
	["blips/hunting.png"] = "Vadászat",
	["blips/favago.png"] = "Fatelep",
	["blips/kikoto.png"] = "Kikötő",
	["blips/kocsma.png"] = "Kocsma",
	["blips/burger.png"] = "Burger Shot",
	["blips/binco.png"] = "Ruhabolt",
	["blips/fisherman.png"] = "Horgászbolt",
	["blips/hunting2.png"] = "Vadász",
	["blips/change.png"] = "Pénzváltó",
	["blips/junkyard.png"] = "Roncstelep",
	["blips/lottoblip.png"] = "Lottózó",
	["blips/boat.png"] = "Hajóbolt",
	["blips/cblip.png"] = "Kaszinó",
	["blips/crab.png"] = "Rákászat",
	["blips/carrent.png"] = "Autóbérlő",
	["blips/szerelo_boat.png"] = "Szerelőtelep (hajó)",
	["blips/szerelo_heli.png"] = "Szerelőtelep (helikopter)",
	["blips/motel.png"] = "Motel",
	["blips/sheriffblip.png"] = "Sheriff",
	["blips/kosar.png"] = "Streetball pálya",
	["blips/markblip.png"] = "Kijelölt pont (Kattints a törléshez)",
	["blips/north.png"] = "Észak",
}

local visibleBlipTooltip = false
local hoveredWaypointBlip = false

local farshowBlips = {}
local farshowBlipsData = {}

carCanGPSVal = false
local gpsHello = false
local gpsLines = {}
local gpsRouteImage = false
local gpsRouteImageData = {}

local state3DBlip = true
local hover3DBlipCb = false

local playerCanSeePlayers = false

local getZoneNameEx = getZoneName
function getZoneName(x, y, z, citiesonly)
	local zoneName = getZoneNameEx(x, y, z, citiesonly)
	if zoneName == "Greenglass College" then
		return "Las Venturas City Hall"
	else
		return zoneName
	end
end

function getTexture(name)
	if createdTextures[name] then
		return createdTextures[name]
	end

	return false
end

addCommandHandler("showplayers",
	function ()
		if getElementData(localPlayer, "adminlevel") >= 3 then
			playerCanSeePlayers = not playerCanSeePlayers
		end
	end
)

local textura = dxCreateTexture("radar/files/radar.jpg")

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
    createdTextures = {
			minimapMap = textura,
			bigmapMap = textura,
		}
		initFont("Roboto", "Roboto.ttf", 12)
		initFont("RobotoB", "RobotoB.ttf", 24)
		--initFont("iconsNormal", "FontAwesome.otf", 14)
		--initFont("iconsBig", "FontAwesome.otf", 32)
		initFont("pricedown", "gtaFont.ttf", 40)
		initFont("BrushScriptStd", "BrushScriptStd.ttf", 30)
		--initFont("bitsu", "bitsu.ttf", 14)
		occupiedVehicle = getPedOccupiedVehicle(localPlayer)
		if getTexture("minimapMap") then
			dxSetTextureEdge(getTexture("minimapMap"), "border", tocolor(128, 167, 208))
		end

		if getTexture("bigmapMap") then
			dxSetTextureEdge(getTexture("bigmapMap"), "border", tocolor(128, 167, 208))
		end

		for k,v in ipairs(getElementsByType("blip")) do
			blipTooltips[v] = getElementData(v, "tooltipText")
		end

		for k,v in ipairs(mainBlips) do
			createCustomBlip(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
		end

		if occupiedVehicle then
			carCanGPS()
		end

		state3DBlip = settingsStorage.show3DBlips

		if settingsStorage.show3DBlips then
			addEventHandler("onClientHUDRender", getRootElement(), render3DBlips, true, "low-99999999")
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if source == occupiedVehicle then
			if dataName == "vehicle.tuning.seeGO" then
				local dataValue = getElementData(source, dataName) or false

				if dataValue then
					carCanGPSVal = dataValue
				else
					if oldValue then
						carCanGPSVal = false
					end
				end

				if not carCanGPSVal then
					if getElementData(source, "gpsDestination") then
						endRoute()
					end
				end
			elseif dataName == "gpsDestination" then
				local dataValue = getElementData(source, dataName) or false

				if dataValue then
					gpsThread = coroutine.create(makeRoute)
					coroutine.resume(gpsThread, unpack(dataValue))
					waypointInterpolation = false
				else
					endRoute()
				end
			end
		end

		if getElementType(source) == "blip" and dataName == "tooltipText" then
			blipTooltips[source] = getElementData(source, dataName)
		end
	end
)

addEventHandler("onClientPlayerDamage", getLocalPlayer(),
	function ()
		damageEffectStart = getTickCount()
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		renderTheBigmap()
		mapWidth = exports.sas_hud:getNode(7, "width")
		mapHeight = exports.sas_hud:getNode(7, "height");
		mapX = exports.sas_hud:getNode(7, "x");
		mapY = exports.sas_hud:getNode(7, "y");
		if (exports["sas_hud"]:getNode(7, "showing") or getElementData(localPlayer, "valaszto")) and getElementData(localPlayer, "loggedin") then
			if getElementData(localPlayer, "enableall") then
				renderMinimap(mapX, mapY, mapWidth, mapHeight)
			end
		end
	end
)

function renderMinimap(x, y, w, h)
	if bigmapIsVisible or not minimapIsVisible then
		return
	end

	minimapWidth = w
	minimapHeight = h

	if (minimapWidth > respc(445) or minimapHeight > respc(400)) and minimapRenderSize < 800 then
		minimapRenderSize = 800
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize)
	end
	if minimapWidth <= respc(445) and minimapHeight <= respc(400) and minimapRenderSize > 600 then
		minimapRenderSize = 600
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize)
	end
	if (minimapWidth > respc(325) or minimapHeight > respc(235)) and minimapRenderSize < 600 then
		minimapRenderSize = 600
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize)
	end
	if minimapWidth <= respc(325) and minimapHeight <= respc(235) and minimapRenderSize > 400 then
		minimapRenderSize = 400
		minimapRenderHalfSize = minimapRenderSize * 0.5
		destroyElement(minimapRender)
		minimapRender = dxCreateRenderTarget(minimapRenderSize, minimapRenderSize)
	end

	if minimapPosX ~= x or minimapPosY ~= y then
		minimapPosX = x
		minimapPosY = y
	end

	minimapCenterX = minimapPosX + minimapWidth / 2
	minimapCenterY = minimapPosY + minimapHeight / 2

	dxUpdateScreenSource(screenSource, true)

	if getKeyState("num_add") and playerMinimapZoom < 1.2 then
		playerMinimapZoom = playerMinimapZoom + 0.01
	elseif getKeyState("num_sub") and playerMinimapZoom > 0.31 then
		playerMinimapZoom = playerMinimapZoom - 0.01
	end

	minimapZoom = playerMinimapZoom

	if occupiedVehicle then
		local vehicleZoom = getVehicleSpeed(occupiedVehicle) / 1300
		if vehicleZoom >= 0.4 then
			vehicleZoom = 0.4
		end
		minimapZoom = minimapZoom - vehicleZoom
	end

	local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
	local playerDimension = getElementDimension(localPlayer)
	local cameraX, cameraY, _, faceTowardX, faceTowardY = getCameraMatrix()
	local cameraRotation = deg(atan2(faceTowardY - cameraY, faceTowardX - cameraX)) + 360 + 90

	local minimapRenderSizeOffset = respc(minimapRenderSize * 0.75)

	farshowBlips = {}
	farshowBlipsData = {}

	if playerDimension == 0 or playerDimension == 65000 or playerDimension == 33333 then
		local remapPlayerPosX, remapPlayerPosY = remapTheFirstWay(playerPosX), remapTheFirstWay(playerPosY)
		local farBlips = {}
		local farBlipsCount = 10000
		local manualBlipsCount = 1
		local defaultBlipsCount = 1

		dxSetRenderTarget(minimapRender)
		dxDrawImageSection(0, 0, minimapRenderSize, minimapRenderSize, remapTheSecondWay(playerPosX) - minimapRenderSize / minimapZoom / 2, remapTheFirstWay(playerPosY) - minimapRenderSize / minimapZoom / 2, minimapRenderSize / minimapZoom, minimapRenderSize / minimapZoom, getTexture("minimapMap"))

		if gpsRouteImage then
			--dxSetBlendMode("add")
			dxDrawImage(minimapRenderSize / 2 + (remapTheFirstWay(playerPosX) - (gpsRouteImageData[1] + gpsRouteImageData[3] / 2)) * minimapZoom - gpsRouteImageData[3] * minimapZoom / 2, minimapRenderSize / 2 - (remapTheFirstWay(playerPosY) - (gpsRouteImageData[2] + gpsRouteImageData[4] / 2)) * minimapZoom + gpsRouteImageData[4] * minimapZoom / 2, gpsRouteImageData[3] * minimapZoom, -(gpsRouteImageData[4] * minimapZoom), gpsRouteImage, 180, 0, 0, tocolor(220, 163, 30))
			--dxSetBlendMode("blend")
		end

		for i = 1, #createdBlips do
			if createdBlips[i] then
				if createdBlips[i].farShow then
					farBlips[farBlipsCount + manualBlipsCount] = createdBlips[i].icon
				end

				renderBlip(createdBlips[i].icon, createdBlips[i].posX, createdBlips[i].posY, remapPlayerPosX, remapPlayerPosY, createdBlips[i].iconSize, createdBlips[i].iconSize, createdBlips[i].color, cameraRotation, createdBlips[i].farShow, i)

				manualBlipsCount = manualBlipsCount + 1
			end
		end

		local defaultBlips = getElementsByType("blip")
		for i = 1, #defaultBlips do
			if defaultBlips[i] then
				local tableId = farBlipsCount + manualBlipsCount + defaultBlipsCount
				farBlips[tableId] = "blips/target.png"

				local blipPosX, blipPosY = getElementPosition(defaultBlips[i])

				if getBlipIcon(defaultBlips[i]) == 1 then
					renderBlip("blips/munkajarmu.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 18, 15, 0xFFFFFFFF, cameraRotation, true, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 2 then
					renderBlip("blips/kukamunka.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 22, 22, 0xFFFFFFFF, cameraRotation, true, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 3 then
					renderBlip("jobblips/247.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 4 then
					renderBlip("jobblips/abc.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 5 then
					renderBlip("jobblips/bb.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 6 then
					renderBlip("jobblips/burger.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 7 then
					renderBlip("jobblips/carshop.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 8 then
					renderBlip("jobblips/cluckin.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 9 then
					renderBlip("jobblips/donut.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 10 then
					renderBlip("jobblips/electro.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 11 then
					renderBlip("jobblips/fcbbq.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 12 then
					renderBlip("jobblips/fch.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 13 then
					renderBlip("jobblips/fix.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 14 then
					renderBlip("jobblips/fruit.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 15 then
					renderBlip("jobblips/gasso.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 16 then
					renderBlip("jobblips/hobby.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 17 then
					renderBlip("jobblips/jefferson.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 18 then
					renderBlip("jobblips/ls.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 19 then
					renderBlip("jobblips/lvh.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 20 then
					renderBlip("jobblips/lvoil.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 21 then
					renderBlip("jobblips/oil.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 22 then
					renderBlip("jobblips/rockshore.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 23 then
					renderBlip("jobblips/seeburger.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 24 then
					renderBlip("jobblips/sf.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 25 then
					renderBlip("jobblips/sh.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 26 then
					renderBlip("jobblips/warehouse.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 27 then
					renderBlip("jobblips/wh.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 28 then
					renderBlip("jobblips/xoomer.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				elseif getBlipIcon(defaultBlips[i]) == 29 then
					renderBlip("jobblips/zoldseges.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 64, 64, 0xFFFFFFFF, cameraRotation, false, tableId)
				else
					renderBlip("blips/target.png", blipPosX, blipPosY, remapPlayerPosX, remapPlayerPosY, 14.3, 14.3, tocolor(getBlipColor(defaultBlips[i])), cameraRotation, true, tableId)
				end

				defaultBlipsCount = defaultBlipsCount + 1
			end
		end

		dxSetRenderTarget()
		dxDrawImage(minimapPosX - minimapRenderSize / 2 + minimapWidth / 2, minimapPosY - minimapRenderSize / 2 + minimapHeight / 2, minimapRenderSize, minimapRenderSize, minimapRender, cameraRotation - 180)

		for k in pairs(farshowBlips) do
			if createdBlips[k] then
				dxDrawImage(farshowBlipsData[k].posX, farshowBlipsData[k].posY, createdBlips[k].iconSize, createdBlips[k].iconSize, "radar/files/" .. createdBlips[k].icon, 0, 0, 0, farshowBlipsData[k].color)
			else
				table.insert(farBlips, k)
			end
		end

		for i = 1, #farBlips do
			if farshowBlipsData[farBlips[i]] then
				dxDrawImage(farshowBlipsData[farBlips[i]].posX, farshowBlipsData[farBlips[i]].posY, farshowBlipsData[farBlips[i]].iconWidth, farshowBlipsData[farBlips[i]].iconHeight, "radar/files/" .. farshowBlipsData[farBlips[i]].icon, 0, 0, 0, farshowBlipsData[farBlips[i]].color)
			end
		end
	end

	dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY - minimapRenderSizeOffset, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
	dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, minimapPosX - minimapRenderSizeOffset, minimapPosY + minimapHeight, minimapWidth + minimapRenderSizeOffset * 2, minimapRenderSizeOffset, screenSource)
	dxDrawImageSection(minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX - minimapRenderSizeOffset, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
	dxDrawImageSection(minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, minimapPosX + minimapWidth, minimapPosY, minimapRenderSizeOffset, minimapHeight, screenSource)
	dxDrawOuterBorder(minimapPosX, minimapPosY, minimapWidth, minimapHeight, 2, tocolor(0, 0, 0, 200))

	if playerDimension == 0 then
		local playerArrowSize = 60 / (4 - minimapZoom) + 3
		local playerArrowHalfSize = playerArrowSize / 2
		local _, _, playerRotation = getElementRotation(localPlayer)

		dxDrawImage(minimapCenterX - playerArrowHalfSize, minimapCenterY - playerArrowHalfSize, playerArrowSize, playerArrowSize, "radar/files/arrow.png", abs(360 - playerRotation) + (cameraRotation - 180))
		dxDrawRectangle(minimapPosX, minimapPosY + minimapHeight - zoneLineHeight, minimapWidth, zoneLineHeight, tocolor(0, 0, 0, 200))
		dxDrawText(getZoneName(playerPosX, playerPosY, playerPosZ), minimapPosX, minimapPosY + minimapHeight - zoneLineHeight, minimapPosX + minimapWidth - resp(10), minimapPosY + minimapHeight, tocolor(255, 255, 255, 255), 0.5, getFont("BrushScriptStd"), "right", "center")

		if gpsRoute or (not gpsRoute and waypointEndInterpolation) then
			local naviX = minimapPosX + minimapWidth - gpsLineWidth
			local naviCenterY = minimapPosY + (minimapHeight - zoneLineHeight) / 2

			if waypointEndInterpolation then
				local interpolationProgress = (getTickCount() - waypointEndInterpolation) / 500
				local interpolateAlpha = interpolateBetween(1, 0, 0, 0, 0, 0, interpolationProgress, "Linear")

				dxDrawRectangle(naviX, minimapPosY, gpsLineWidth, minimapHeight - zoneLineHeight, tocolor(0, 0, 0, 150 * interpolateAlpha))
				dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), naviCenterY - gpsLineIconHalfSize, gpsLineIconSize, gpsLineIconSize, "radar/gps/images/end.png", 0, 0, 0, tocolor(124, 197, 118, 255 * interpolateAlpha))
				dxDrawText("0 m", naviX, naviCenterY + gpsLineIconHalfSize, minimapPosX + minimapWidth, naviCenterY + gpsLineIconHalfSize + respc(16), tocolor(124, 197, 118, 255 * interpolateAlpha), 0.9, getFont("Roboto"), "center", "center")

				if interpolationProgress > 1 then
					waypointEndInterpolation = false
				end
			end

			if nextWp then
				dxDrawRectangle(naviX, minimapPosY, gpsLineWidth, minimapHeight - zoneLineHeight, tocolor(0, 0, 0, 150))

				if currentWaypoint ~= nextWp and not tonumber(reRouting) then
					if nextWp > 1 then
						waypointInterpolation = {getTickCount(), currentWaypoint}
					end

					currentWaypoint = nextWp
				end

				if tonumber(reRouting) then
					currentWaypoint = nextWp

					local reRouteProgress = (getTickCount() - reRouting) / 1250
					local refreshAngle, refreshDots = interpolateBetween(360, 0, 0, 0, 3, 0, reRouteProgress, "Linear")

					dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), naviCenterY - gpsLineIconHalfSize, gpsLineIconSize, gpsLineIconSize, "radar/gps/images/refresh.png", refreshAngle, 0, 0, tocolor(124, 197, 118))

					if refreshDots > 2 then
						dxDrawText("•••", naviX, naviCenterY + gpsLineIconHalfSize, minimapPosX + minimapWidth, naviCenterY + gpsLineIconHalfSize + respc(16), tocolor(124, 197, 118), 0.9, getFont("Roboto"), "center", "center")
					elseif refreshDots > 1 then
						dxDrawText("••", naviX, naviCenterY + gpsLineIconHalfSize, minimapPosX + minimapWidth, naviCenterY + gpsLineIconHalfSize + respc(16), tocolor(124, 197, 118), 0.9, getFont("Roboto"), "center", "center")
					elseif refreshDots > 0 then
						dxDrawText("•", naviX, naviCenterY + gpsLineIconHalfSize, minimapPosX + minimapWidth, naviCenterY + gpsLineIconHalfSize + respc(16), tocolor(124, 197, 118), 0.9, getFont("Roboto"), "center", "center")
					end

					if reRouteProgress > 1 then
						reRouting = getTickCount()
					end
				elseif turnAround then
					currentWaypoint = nextWp

					dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), naviCenterY - gpsLineIconHalfSize, gpsLineIconSize, gpsLineIconSize, "radar/gps/images/around.png", 0, 0, 0, tocolor(124, 197, 118))
					dxDrawText("Fordulj\nvissza!", naviX, naviCenterY + gpsLineIconHalfSize + respc(8), minimapPosX + minimapWidth, naviCenterY + gpsLineIconHalfSize + respc(8) + respc(16), tocolor(124, 197, 118), 0.9, getFont("Roboto"), "center", "center")
				elseif not waypointInterpolation then
					dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), naviCenterY - gpsLineIconHalfSize, gpsLineIconSize, gpsLineIconSize, "radar/gps/images/" .. gpsWaypoints[nextWp][2] .. ".png", 0, 0, 0, tocolor(124, 197, 118))
					dxDrawText(floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10 .. " m", naviX, naviCenterY + gpsLineIconHalfSize, minimapPosX + minimapWidth, naviCenterY + gpsLineIconHalfSize + respc(16), tocolor(124, 197, 118, 255), 0.9, getFont("Roboto"), "center", "center")

					if gpsWaypoints[nextWp + 1] then
						dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), minimapPosY + minimapHeight - zoneLineHeight - gpsLineIconSize - respc(8), gpsLineIconSize, gpsLineIconSize, "radar/gps/images/" .. gpsWaypoints[nextWp + 1][2] .. ".png", 0, 0, 0, tocolor(220, 163, 30))
					end
				else
					local startPolation, endPolation = (getTickCount() - waypointInterpolation[1]) / 750, 0
					local firstAlpha, firstOffset, secondOffset = interpolateBetween(255, (minimapHeight - zoneLineHeight) / 2 - gpsLineIconHalfSize, minimapHeight - zoneLineHeight - gpsLineIconSize - respc(8), 0, 0, (minimapHeight - zoneLineHeight) / 2 - gpsLineIconHalfSize, startPolation, "Linear")

					dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), minimapPosY + firstOffset, gpsLineIconSize, gpsLineIconSize, "radar/gps/images/" .. gpsWaypoints[waypointInterpolation[2]][2] .. ".png", 0, 0, 0, tocolor(124, 197, 118, firstAlpha))
					dxDrawText(floor((gpsWaypoints[waypointInterpolation[2]][3] or 0) / 10) * 10 .. " m", naviX, minimapPosY + firstOffset + gpsLineIconSize, minimapPosX + minimapWidth, minimapPosY + firstOffset + gpsLineIconSize + respc(16), tocolor(124, 197, 118, firstAlpha), 0.9, getFont("Roboto"), "center", "center")

					if gpsWaypoints[waypointInterpolation[2] + 1] then
						local r, g, b = interpolateBetween(220, 163, 30, 124, 197, 118, startPolation, "Linear")
						local alpha = interpolateBetween(0, 0,0, 255, 0, 0, startPolation, "Linear")

						dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), minimapPosY + secondOffset, gpsLineIconSize, gpsLineIconSize, "radar/gps/images/" .. gpsWaypoints[waypointInterpolation[2] + 1][2] .. ".png", 0, 0, 0, tocolor(r, g, b))
						dxDrawText(floor((gpsWaypoints[waypointInterpolation[2] + 1][3] or 0) / 10) * 10 .. " m", naviX, minimapPosY + secondOffset + gpsLineIconSize, minimapPosX + minimapWidth, minimapPosY + secondOffset + gpsLineIconSize + respc(16), tocolor(r, g, b, alpha), 0.9, getFont("Roboto"), "center", "center")
					end

					if startPolation > 1 then
						endPolation = (getTickCount() - waypointInterpolation[1] - 750) / 500
					end

					if gpsWaypoints[waypointInterpolation[2] + 2] then
						local thirdAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, endPolation, "Linear")

						dxDrawImage(naviX + ((gpsLineWidth - gpsLineIconSize) / 2), minimapPosY + minimapHeight - zoneLineHeight - gpsLineIconSize - respc(8), gpsLineIconSize, gpsLineIconSize, "radar/gps/images/" .. gpsWaypoints[waypointInterpolation[2] + 2][2] .. ".png", 0, 0, 0, tocolor(220, 163, 30, thirdAlpha))
					end

					if endPolation > 1 then
						waypointInterpolation = false
					end
				end
			end
		end
	else
		dxDrawRectangle(minimapPosX, minimapPosY, minimapWidth, minimapHeight, tocolor(0, 0, 0))

		if not lostSignalStartTick then
			lostSignalStartTick = getTickCount()
		end

		local fadeAlpha = 255
		if not lostSignalFadeIn then
			fadeAlpha = 255
		else
			fadeAlpha = 0
		end

		local lostSignalTick = (getTickCount() - lostSignalStartTick) / 1500
		if lostSignalTick > 1 then
			lostSignalStartTick = getTickCount()
			lostSignalFadeIn = not lostSignalFadeIn
		end

		dxDrawImage(minimapCenterX - 32, minimapCenterY - 32 - 16, 64, 64, "radar/files/gpslosticon.png", 0, 0, 0, tocolor(255, 255, 255, interpolateBetween(fadeAlpha, 0, 0, 255 - fadeAlpha, 0, 0, lostSignalTick, "Linear")))
		dxDrawImage(minimapCenterX - 128, minimapCenterY + 16 + 8, 256, 16, "radar/files/gpslosttext.png")
		dxDrawImage(minimapPosX + minimapWidth - 64, minimapPosY, 64, 16, "radar/files/nosignaltext.png")
	end

	if damageEffectStart then
		if tonumber(damageEffectStart) then
			if getTickCount() - damageEffectStart >= 1000 then
				damageEffectStart = false
				return
			end
		else
			damageEffectStart = false
			return
		end

		local effectProgress = (getTickCount() - damageEffectStart) / 500
		if effectProgress > 1 then
			damageEffectStart = false
			return
		end

		dxDrawRectangle(minimapPosX, minimapPosY, minimapWidth, minimapHeight, tocolor(255, 0, 0, interpolateBetween(150, 0, 0, 0, 0, 0, effectProgress, "Linear")))
	end
end

function renderTheBigmap()
	if not bigmapIsVisible then
		return
	end

	if hoveredWaypointBlip then
		hoveredWaypointBlip = false
	end

	if hover3DBlipCb then
		hover3DBlipCb = false
	end

	dxDrawOuterBorder(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, 5, tocolor(0, 0, 0, 125))

	if getElementDimension(localPlayer) == 0 then
		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)

		cursorX, cursorY = getHudCursorPos()
		if cursorX and cursorY then
			cursorX, cursorY = cursorX * screenW, cursorY * screenH

			if getKeyState("mouse1") then
				if not lastCursorPos then
					lastCursorPos = {cursorX, cursorY}
				end

				if not mapDifferencePos then
					mapDifferencePos = {0, 0}
				end

				if not lastDifferencePos then
					if not mapMovedPos then
						lastDifferencePos = {0, 0}
					else
						lastDifferencePos = {mapMovedPos[1], mapMovedPos[2]}
					end
				end

				mapDifferencePos = {mapDifferencePos[1] + cursorX - lastCursorPos[1], mapDifferencePos[2] + cursorY - lastCursorPos[2]}

				if not mapMovedPos then
					if abs(mapDifferencePos[1]) >= 3 or abs(mapDifferencePos[2]) >= 3 then
						mapMovedPos = {lastDifferencePos[1] - mapDifferencePos[1] / bigmapZoom, lastDifferencePos[2] + mapDifferencePos[2] / bigmapZoom}
						mapIsMoving = true
					end
				elseif mapDifferencePos[1] ~= 0 or mapDifferencePos[2] ~= 0 then
					mapMovedPos = {lastDifferencePos[1] - mapDifferencePos[1] / bigmapZoom, lastDifferencePos[2] + mapDifferencePos[2] / bigmapZoom}
					mapIsMoving = true
				end

				lastCursorPos = {cursorX, cursorY}
			else
				if mapMovedPos then
					lastDifferencePos = {mapMovedPos[1], mapMovedPos[2]}
				end

				lastCursorPos = false
				mapDifferencePos = false
			end
		end

		mapPlayerPosX, mapPlayerPosY = lastMapPosX, lastMapPosY

		if mapMovedPos then
			mapPlayerPosX = mapPlayerPosX + mapMovedPos[1]
			mapPlayerPosY = mapPlayerPosY + mapMovedPos[2]
		else
			mapPlayerPosX, mapPlayerPosY = playerPosX, playerPosY
			lastMapPosX, lastMapPosY = mapPlayerPosX, mapPlayerPosY
		end

		dxDrawImageSection(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2, remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2, bigmapWidth / bigmapZoom, bigmapHeight / bigmapZoom, getTexture("bigmapMap"))

		if gpsRouteImage then
			dxUpdateScreenSource(screenSource, true)
			--dxSetBlendMode("add")
			dxDrawImage(bigmapCenterX + (remapTheFirstWay(mapPlayerPosX) - (gpsRouteImageData[1] + gpsRouteImageData[3] / 2)) * bigmapZoom - gpsRouteImageData[3] * bigmapZoom / 2, bigmapCenterY - (remapTheFirstWay(mapPlayerPosY) - (gpsRouteImageData[2] + gpsRouteImageData[4] / 2)) * bigmapZoom + gpsRouteImageData[4] * bigmapZoom / 2, gpsRouteImageData[3] * bigmapZoom, -(gpsRouteImageData[4] * bigmapZoom), gpsRouteImage, 180, 0, 0, tocolor(220, 163, 30))
			--dxSetBlendMode("blend")
			dxDrawImageSection(0, 0, bigmapPosX, screenH, 0, 0, bigmapPosX, screenH, screenSource)
			dxDrawImageSection(screenW - bigmapPosX, 0, bigmapPosX, screenH, screenW - bigmapPosX, 0, bigmapPosX, screenH, screenSource)
			dxDrawImageSection(bigmapPosX, 0, screenW - 2 * bigmapPosX, bigmapPosY, bigmapPosX, 0, screenW - 2 * bigmapPosX, bigmapPosY, screenSource)
			dxDrawImageSection(bigmapPosX, screenH - bigmapPosY, screenW - 2 * bigmapPosX, bigmapPosY, bigmapPosX, screenH - bigmapPosY, screenW - 2 * bigmapPosX, bigmapPosY, screenSource)
		end

		for i = 1, #createdBlips do
			if createdBlips[i] then
				renderBigBlip(createdBlips[i].icon, createdBlips[i].posX, createdBlips[i].posY, mapPlayerPosX, mapPlayerPosY, createdBlips[i].renderDistance, createdBlips[i].iconSize, createdBlips[i].iconSize, createdBlips[i].color, false, i, playerRotation)
			end
		end

		for k,v in ipairs(getElementsByType("blip")) do
			if getElementAttachedTo(v) ~= localPlayer then
				local blipPosX, blipPosY = getElementPosition(v)

				if getBlipIcon(v) == 1 then
					renderBigBlip("blips/munkajarmu.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 18, 15, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 2 then
					renderBigBlip("blips/kukamunka.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 3 then
					renderBigBlip("jobblips/247.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 4 then
					renderBigBlip("jobblips/abc.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 5 then
					renderBigBlip("jobblips/bb.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 6 then
					renderBigBlip("jobblips/burger.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 7 then
					renderBigBlip("jobblips/carshop.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 8 then
					renderBigBlip("jobblips/cluckin.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 9 then
					renderBigBlip("jobblips/donut.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 10 then
					renderBigBlip("jobblips/electro.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 11 then
					renderBigBlip("jobblips/fcbbq.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 12 then
					renderBigBlip("jobblips/fch.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 13 then
					renderBigBlip("jobblips/fix.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 14 then
					renderBigBlip("jobblips/fruit.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 15 then
					renderBigBlip("jobblips/gasso.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 16 then
					renderBigBlip("jobblips/hobby.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 17 then
					renderBigBlip("jobblips/jefferson.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 18 then
					renderBigBlip("jobblips/ls.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 19 then
					renderBigBlip("jobblips/lvh.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 20 then
					renderBigBlip("jobblips/lvoil.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 21 then
					renderBigBlip("jobblips/oil.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 22 then
					renderBigBlip("jobblips/rockshore.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 23 then
					renderBigBlip("jobblips/seeburger.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 24 then
					renderBigBlip("jobblips/sf.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 25 then
					renderBigBlip("jobblips/sh.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 26 then
					renderBigBlip("jobblips/warehouse.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 27 then
					renderBigBlip("jobblips/wh.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 28 then
					renderBigBlip("jobblips/xoomer.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				elseif getBlipIcon(v) == 29 then
					renderBigBlip("jobblips/zoldseges.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 64, 64, 0xFFFFFFFF, v, k)
				else
					renderBigBlip("blips/target.png", blipPosX, blipPosY, mapPlayerPosX, mapPlayerPosY, 9999, 14.5, 14.5, tocolor(getBlipColor(v)), v, k)
				end
			end
		end

		if playerCanSeePlayers then
			for k,v in ipairs(getElementsByType("player")) do
				if v ~= localPlayer then
					local playerPosX, playerPosY = getElementPosition(v)
					renderBigBlip("blips/target.png", playerPosX, playerPosY, mapPlayerPosX, mapPlayerPosY, 9999, 14.5, 14.5, tocolor(99, 39, 90), v, k)
				end
			end
		end

		renderBigBlip("arrow.png", playerPosX, playerPosY, mapPlayerPosX, mapPlayerPosY, false, 20, 20)

		if mapMovedPos then
			renderBigBlip("cross.png", mapPlayerPosX, mapPlayerPosY, mapPlayerPosX, mapPlayerPosY, false, 128, 128)
		end

		if occupiedVehicle and carCanGPSVal then
			dxDrawImage(bigmapPosX + bigmapWidth - respc(144), bigmapPosY + bigmapHeight - respc(174), respc(128), respc(128), "radar/gps/images/sgo.png", 0, 0, 0, tocolor(255, 255, 255, 200))
		end

		dxDrawRectangle(bigmapPosX, bigmapPosY + bigmapHeight - zoneLineHeight, bigmapWidth, zoneLineHeight, tocolor(0, 0, 0, 200))

		if cursorX and cursorY then
			local zoneX = reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000)
			local zoneY = reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)

			dxDrawText(getZoneName(zoneX, zoneY, 0), bigmapPosX + 10, bigmapPosY + bigmapHeight - zoneLineHeight, bigmapPosX + bigmapWidth, bigmapPosY + bigmapHeight, 0xFFFFFFFF, 0.5, getFont("BrushScriptStd"), "left", "center")

			if visibleBlipTooltip then
				dxDrawRectangle(cursorX + respc(12.5), cursorY, dxGetTextWidth(visibleBlipTooltip, 0.75, getFont("Roboto")) + respc(10), respc(25), tocolor(0, 0, 0, 150))
				dxDrawText(visibleBlipTooltip, cursorX + respc(12.5), cursorY, cursorX + (dxGetTextWidth(visibleBlipTooltip, 0.75, getFont("Roboto")) + respc(10)) + respc(12.5), cursorY + respc(25), 0xFFFFFFFF, 0.75, getFont("Roboto"), "center", "center")
			end
		else
			dxDrawText(getZoneName(playerPosX, playerPosY, playerPosZ), bigmapPosX + 10, bigmapPosY + bigmapHeight - zoneLineHeight, bigmapPosX + bigmapWidth, bigmapPosY + bigmapHeight, 0xFFFFFFFF, 0.5, getFont("BrushScriptStd"), "left", "center")
		end

		dxDrawText("3D blipek  ", bigmapPosX, bigmapPosY + bigmapHeight - zoneLineHeight, bigmapPosX + bigmapWidth - zoneLineHeight, bigmapPosY + bigmapHeight, 0xFFFFFFFF, 0.75, getFont("Roboto"), "right", "center")

		if isCursorShowing() and cursorX >= bigmapPosX + bigmapWidth - zoneLineHeight - dxGetTextWidth("  3D blipek  ", 0.75, getFont("Roboto")) and cursorX <= bigmapPosX + bigmapWidth and cursorY >= bigmapPosY + bigmapHeight - zoneLineHeight and cursorY <= bigmapPosY + bigmapHeight then
			hover3DBlipCb = true
		end

		if state3DBlip then
			dxDrawImage(bigmapPosX + bigmapWidth - zoneLineHeight, bigmapPosY + bigmapHeight - zoneLineHeight, zoneLineHeight, zoneLineHeight, "radar/files/tick_on.png")
		else
			dxDrawImage(bigmapPosX + bigmapWidth - zoneLineHeight, bigmapPosY + bigmapHeight - zoneLineHeight, zoneLineHeight, zoneLineHeight, "radar/files/tick.png")
		end

		if visibleBlipTooltip then
			visibleBlipTooltip = false
		end

		if mapMovedPos then
			dxDrawText("A nézet visszaállításához nyomd meg a 'SPACE' gombot.", bigmapPosX, bigmapPosY + bigmapHeight - zoneLineHeight, bigmapPosX + bigmapWidth, bigmapPosY + bigmapHeight, 0xFFFFFFFF, 1, getFont("Roboto"), "center", "center")

			if getKeyState("space") then
				mapMovedPos = false
				lastDifferencePos = false
			end
		end
	else
		dxDrawRectangle(bigmapPosX, bigmapPosY, bigmapWidth, bigmapHeight, tocolor(0, 0, 0))
		dxDrawImage(bigmapCenterX - 32, bigmapCenterY - 32 - 16, 64, 64, "radar/files/gpslosticon.png")
		dxDrawImage(bigmapCenterX - 128, bigmapCenterY + 16 + 8, 256, 16, "radar/files/gpslosttext.png")
		dxDrawImage(bigmapPosX + bigmapWidth - 64, bigmapPosY, 64, 16, "radar/files/nosignaltext.png")
	end
end

addEventHandler("onClientKey", getRootElement(),
	function (key, pressDown)
		if key == "F11" and pressDown then
		--	if pressDown and getElementData(localPlayer, "loggedIn") then
				bigmapIsVisible = not bigmapIsVisible
				setElementData(localPlayer, "bigmapIsVisible", bigmapIsVisible, false)
				if bigmapIsVisible then
					playSound("radar/files/f11radaropen.mp3")
				--	hideHUD()
					setElementData(localPlayer, "enableall", false)
					if not gpsThread and occupiedVehicle and carCanGPS() then
						gpsHello = playSound("radar/gps/sounds/" .. carCanGPSVal .. "/hello.mp3")
					end
				else
					playSound("radar/files/f11radarclose.mp3")
					--showHUD()
					setElementData(localPlayer, "enableall", true)
					if gpsHello and isElement(gpsHello) then
						destroyElement(gpsHello)
					end
					gpsHello = false
				end
		--	end

			cancelEvent()
		elseif key == "mouse_wheel_up" then
			if pressDown then
				if bigmapIsVisible and bigmapZoom + 0.1 <= 2.1 then
					bigmapZoom = bigmapZoom + 0.1
				end
			end
		elseif key == "mouse_wheel_down" then
			if pressDown then
				if bigmapIsVisible and bigmapZoom - 0.1 >= 0.1 then
					bigmapZoom = bigmapZoom - 0.1
				end
			end
		end
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, cursorX, cursorY)
		if not bigmapIsVisible then
			return
		end

		if hover3DBlipCb then
			if state == "up" then
				state3DBlip = not state3DBlip

				if state3DBlip then
					addEventHandler("onClientHUDRender", getRootElement(), render3DBlips, true, "low-99999999")
				else
					removeEventHandler("onClientHUDRender", getRootElement(), render3DBlips)
				end

				settingsStorage.show3DBlips = state3DBlip
			end
			return
		end

		if state == "up" and mapIsMoving then
			mapIsMoving = false
			return
		end

		local gpsRouteProcess = false

		if button == "left" and state == "up" then
			if occupiedVehicle and carCanGPS() then
				if getElementData(occupiedVehicle, "gpsDestination") then
					setElementData(occupiedVehicle, "gpsDestination", false)
				else
					setElementData(occupiedVehicle, "gpsDestination", {
						reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000),
						reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)
					})
				end
				gpsRouteProcess = true
			end
		end

		if not gpsRouteProcess then
			if state == "up" then
				if hoveredWaypointBlip then
					table.remove(createdBlips, hoveredWaypointBlip)
				else
					local blipPosX = reMap((cursorX - bigmapPosX) / bigmapZoom + (remapTheSecondWay(mapPlayerPosX) - bigmapWidth / bigmapZoom / 2), 0, mapTextureSize, -3000, 3000)
					local blipPosY = reMap((cursorY - bigmapPosY) / bigmapZoom + (remapTheFirstWay(mapPlayerPosY) - bigmapHeight / bigmapZoom / 2), 0, mapTextureSize, 3000, -3000)
					local blipPosZ = getGroundPosition(blipPosX, blipPosY, 400) + 3

					createCustomBlip(blipPosX, blipPosY, blipPosZ, "blips/markblip.png", true, 9999, 18, 0xFFFFFFFF)
				end
			end
		end
	end
)

addEventHandler("onClientRestore", getRootElement(),
	function ()
		if gpsRoute then
			processGPSLines()
		end
	end
)

function renderBlip(icon, blipX, blipY, playerPosX, playerPosY, blipWidth, blipHeight, blipColor, cameraRotation, farShow, blipTableId)
	local blipPosX = minimapRenderHalfSize + (playerPosX - remapTheFirstWay(blipX)) * minimapZoom
	local blipPosY = minimapRenderHalfSize - (playerPosY - remapTheFirstWay(blipY)) * minimapZoom

	if not farShow and (blipPosX > minimapRenderSize or 0 > blipPosX or blipPosY > minimapRenderSize or 0 > blipPosY) then
		return
	end

	local blipIsVisible = true
	if farShow then
		if blipPosX > minimapRenderSize then
			blipPosX = minimapRenderSize
		end
		if blipPosX < 0 then
			blipPosX = 0
		end
		if blipPosY > minimapRenderSize then
			blipPosY = minimapRenderSize
		end
		if blipPosY < 0 then
			blipPosY = 0
		end

		local angle = rad((cameraRotation - 270) + 90)
		local cosinus, sinus = cos(angle), sin(angle)

		local blipScreenPosX = minimapPosX - minimapRenderHalfSize + minimapWidth / 2 + (minimapRenderHalfSize + cosinus * (blipPosX - minimapRenderHalfSize) - sinus * (blipPosY - minimapRenderHalfSize) - blipWidth / 2)
		local blipScreenPosY = minimapPosY - minimapRenderHalfSize + minimapHeight / 2 + (minimapRenderHalfSize + sinus * (blipPosX - minimapRenderHalfSize) + cosinus * (blipPosY - minimapRenderHalfSize) - blipHeight / 2)

		farshowBlips[blipTableId] = nil

		if blipScreenPosX < minimapPosX or blipScreenPosX > minimapPosX + minimapWidth - blipWidth then
			farshowBlips[blipTableId] = true
			blipIsVisible = false
		end

		if blipScreenPosY < minimapPosY or blipScreenPosY > minimapPosY + minimapHeight - zoneLineHeight - blipHeight then
			farshowBlips[blipTableId] = true
			blipIsVisible = false
		end

		if farshowBlips[blipTableId] then
			farshowBlipsData[blipTableId] = {
				posX = max(minimapPosX, min(minimapPosX + minimapWidth - blipWidth, blipScreenPosX)),
				posY = max(minimapPosY, min(minimapPosY + minimapHeight - zoneLineHeight - blipHeight, blipScreenPosY)),
				icon = icon,
				iconWidth = blipWidth,
				iconHeight = blipHeight,
				color = blipColor
			}
		end
	end

	if blipIsVisible then
		dxDrawImage(blipPosX - blipWidth / 2, blipPosY - blipHeight / 2, blipWidth, blipHeight, "radar/files/" .. icon, 180 - cameraRotation, 0, 0, blipColor)
	end
end

function renderBigBlip(icon, blipX, blipY, playerPosX, playerPosY, renderDistance, blipWidth, blipHeight, blipColor, blipElement, blipId)
	if renderDistance and getDistanceBetweenPoints2D(playerPosX, playerPosY, blipX, blipY) > renderDistance then
		return
	end

	blipWidth = (blipWidth / (4 - bigmapZoom) + 3) * 2.25
	blipHeight = (blipHeight / (4 - bigmapZoom) + 3) * 2.25

	local blipHalfWidth = blipWidth / 2
	local blipHalfHeight = blipHeight / 2

	blipX = max(bigmapPosX + blipHalfWidth, min(bigmapPosX + bigmapWidth - blipHalfWidth, bigmapCenterX + (remapTheFirstWay(playerPosX) - remapTheFirstWay(blipX)) * bigmapZoom))
	blipY = max(bigmapPosY + blipHalfHeight, min(bigmapPosY + bigmapHeight - blipHalfHeight - zoneLineHeight, bigmapCenterY - (remapTheFirstWay(playerPosY) - remapTheFirstWay(blipY)) * bigmapZoom))

	if icon == "arrow.png" then
		local _, _, playerRotation = getElementRotation(localPlayer)
		dxDrawImage(blipX - blipHalfWidth, blipY - blipHalfHeight, blipWidth, blipHeight, "radar/files/" .. icon, abs(360 - playerRotation))
	else
		dxDrawImage(blipX - blipHalfWidth, blipY - blipHalfHeight, blipWidth, blipHeight, "radar/files/" .. icon, 0, 0, 0, blipColor)
	end

	if cursorX and cursorY then
		if isElement(blipElement) then
			if isCursorWithinArea(cursorX, cursorY, blipX - blipHalfWidth, blipY - blipHalfHeight, blipWidth, blipHeight) then
				if blipTooltips[blipElement] then
					visibleBlipTooltip = blipTooltips[blipElement]
				elseif getElementType(blipElement) == "player" and playerCanSeePlayers then
					visibleBlipTooltip = string.gsub(string.gsub(getElementData(blipElement, "visibleName") or getPlayerName(blipElement), "#%x%x%x%x%x%x", ""), "_", " ") .. " (" .. getElementData(blipElement, "playerID") .. ")"
				end
			end
		else
			if blipTooltips[icon] and isCursorWithinArea(cursorX, cursorY, blipX - blipHalfWidth, blipY - blipHalfHeight, blipWidth, blipHeight) then
				visibleBlipTooltip = blipTooltips[icon]

				if icon == "blips/markblip.png" then
					hoveredWaypointBlip = blipId
				end
			end
		end
	end
end

function render3DBlips()
	if getElementDimension(localPlayer) == 0 then
		local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)

		for i = 1, #createdBlips do
			if createdBlips[i] then
				local screenX, screenY = getScreenFromWorldPosition(createdBlips[i].posX, createdBlips[i].posY, createdBlips[i].posZ)

				if createdBlips[i].icon == "blips/markblip.png" and screenX and screenY then
					local distanceBetweenBlip = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, createdBlips[i].posX, createdBlips[i].posY, createdBlips[i].posZ)
					local blipHalfSize = createdBlips[i].iconSize / 2

					dxDrawText(floor(distanceBetweenBlip) .. " m\nKijelölt pont", screenX + 1, screenY + 1 + blipHalfSize + respc(4), screenX, 0, tocolor(0, 0, 0, 255), 0.75, getFont("Roboto"), "center", "top")
					dxDrawText(floor(distanceBetweenBlip) .. " m#e0e0e0\nKijelölt pont", screenX, screenY + blipHalfSize + respc(4), screenX, 0, 0xFFFFFFFF, 0.75, getFont("Roboto"), "center", "top", false, false, false, true)
					dxDrawImage(screenX - blipHalfSize, screenY - blipHalfSize, createdBlips[i].iconSize, createdBlips[i].iconSize, "radar/files/blips/markblip2.png", 0, 0, 0, tocolor(255, 255, 255, 200))
				end

				if string.find(createdBlips[i].icon, "jobblips") and screenX and screenY then
					local distanceBetweenBlip = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, createdBlips[i].posX, createdBlips[i].posY, createdBlips[i].posZ)
					local blipHalfSize = createdBlips[i].iconSize / 2

					dxDrawText(floor(distanceBetweenBlip) .. " m", screenX + 1, screenY + 1 + blipHalfSize + respc(4), screenX, 0, tocolor(0, 0, 0, 255), 0.75, getFont("Roboto"), "center", "top")
					dxDrawText(floor(distanceBetweenBlip) .. " m", screenX, screenY + blipHalfSize + respc(4), screenX, 0, 0xFFFFFFFF, 0.75, getFont("Roboto"), "center", "top")
					dxDrawImage(screenX - blipHalfSize, screenY - blipHalfSize, createdBlips[i].iconSize, createdBlips[i].iconSize, "radar/files/" .. createdBlips[i].icon, 0, 0, 0, tocolor(255, 255, 255, 200))
				end
			end
		end

		local blipTable = getElementsByType("blip")
		for i = 1, #blipTable do
			if blipTable[i] then
				if getElementAttachedTo(blipTable[i]) ~= localPlayer then
					local blipPosX, blipPosY, blipPosZ = getElementPosition(blipTable[i])
					local screenX, screenY = getScreenFromWorldPosition(blipPosX, blipPosY, blipPosZ)

					if screenX and screenY then
						local distanceBetweenBlip = getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, blipPosX, blipPosY, blipPosZ)
						local blipIcon = (getBlipIcon(blipTable[i]) == 1 and "munkajarmu") or "target"

						dxDrawText(floor(distanceBetweenBlip) .. " m\n" .. (blipTooltips[blipTable[i]] or ""), screenX + 1, screenY + 1 + 7.5 + respc(4), screenX, 0, tocolor(0, 0, 0, 255), 0.75, getFont("Roboto"), "center", "top")
						dxDrawText(floor(distanceBetweenBlip) .. " m#e0e0e0\n" .. (blipTooltips[blipTable[i]] or ""), screenX, screenY + 7.5 + respc(4), screenX, 0, 0xFFFFFFFF, 0.75, getFont("Roboto"), "center", "top", false, false, false, true)
						dxDrawImage(screenX - 9, screenY - 7.5, 18, 15, "radar/files/blips/" .. blipIcon .. ".png", 0, 0, 0, tocolor(255, 255, 255, 200))
					end
				end
			end
		end
	end
end

function createCustomBlip(x, y, z, icon, farShow, visibleDistance, size, color)
	table.insert(createdBlips, {
		posX = x,
		posY = y,
		posZ = z,
		icon = icon,
		farShow = farShow,
		renderDistance = visibleDistance or 9999,
		iconSize = size or 22,
		color = color or tocolor(255, 255, 255)
	})
end

function deleteCustomBlip(count)
	table.remove(createdBlips, count)
end

function remapTheFirstWay(coord)
	return (-coord + 3000) / mapRatio
end

function remapTheSecondWay(coord)
	return (coord + 3000) / mapRatio
end

function carCanGPS()
	if getElementData(occupiedVehicle, "dbid") then
		carCanGPSVal = getElementData(occupiedVehicle, "vehicle.tuning.seeGO") or false
	else
		carCanGPSVal = 1
	end

	return carCanGPSVal
end

function addGPSLine(x, y)
	table.insert(gpsLines, {remapTheFirstWay(x), remapTheFirstWay(y)})
end

function processGPSLines()
	local routeStartPosX, routeStartPosY = 99999, 99999
	local routeEndPosX, routeEndPosY = -99999, -99999

	for i = 1, #gpsLines do
		if gpsLines[i][1] < routeStartPosX then
			routeStartPosX = gpsLines[i][1]
		end

		if gpsLines[i][2] < routeStartPosY then
			routeStartPosY = gpsLines[i][2]
		end

		if gpsLines[i][1] > routeEndPosX then
			routeEndPosX = gpsLines[i][1]
		end

		if gpsLines[i][2] > routeEndPosY then
			routeEndPosY = gpsLines[i][2]
		end
	end

	local routeWidth = (routeEndPosX - routeStartPosX) + 16
	local routeHeight = (routeEndPosY - routeStartPosY) + 16

	if isElement(gpsRouteImage) then
		destroyElement(gpsRouteImage)
	end

	gpsRouteImage = dxCreateRenderTarget(routeWidth, routeHeight, true)
	gpsRouteImageData = {routeStartPosX - 8, routeStartPosY - 8, routeWidth, routeHeight}

	dxSetRenderTarget(gpsRouteImage)
	dxSetBlendMode("modulate_add")

	dxDrawImage(gpsLines[1][1] - routeStartPosX + 8 - 4, gpsLines[1][2] - routeStartPosY + 8 - 4, 8, 8, "radar/gps/images/dot.png")

	for i = 2, #gpsLines do
		if gpsLines[i - 1] then
			local startX = gpsLines[i][1] - routeStartPosX + 8
			local startY = gpsLines[i][2] - routeStartPosY + 8
			local endX = gpsLines[i - 1][1] - routeStartPosX + 8
			local endY = gpsLines[i - 1][2] - routeStartPosY + 8

			dxDrawImage(startX - 4, startY - 4, 8, 8, "radar/gps/images/dot.png")
			dxDrawLine(startX, startY, endX, endY, tocolor(255, 255, 255), 9)
		end
	end

	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function clearGPSRoute()
	gpsLines = {}

	if isElement(gpsRouteImage) then
		destroyElement(gpsRouteImage)
	end
	gpsRouteImage = false
end


function dxDrawInnerBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)

	dxDrawRectangle(x, y, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h - borderSize, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + borderSize, borderSize, h - (borderSize * 2), borderColor, postGUI)
	dxDrawRectangle(x + w - borderSize, y + borderSize, borderSize, h - (borderSize * 2), borderColor, postGUI)
end

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)

	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

function dxDrawBorderedImageSection(x, y, w, h, ux, uy, uw, uh, path, rx, ry, rz, color, postGUI)
	dxDrawImageSection(x - 1, y - 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x - 1, y + 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x + 1, y - 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x + 1, y + 1, w, h, ux, uy, uw, uh, path, rx, ry, rz, tocolor(0, 0, 0, 200), postGUI)
	dxDrawImageSection(x, y, w, h, ux, uy, uw, uh, path, rx, ry, rz, color, postGUI)
end

function dxDrawBorderedText(text, x, y, w, h, color, ...)
	local textWithoutHEX = gsub(text, "#%x%x%x%x%x%x", "")
	dxDrawText(textWithoutHEX, x - 1, y - 1, w - 1, h - 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(textWithoutHEX, x - 1, y + 1, w - 1, h + 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(textWithoutHEX, x + 1, y - 1, w + 1, h - 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(textWithoutHEX, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, 255), ...)
	dxDrawText(text, x, y, w, h, color, ...)
end

function dxDrawRoundedRectangle(x, y, w, h, color, postGUI, subPixelPositioning, radius)
	radius = radius or 5

	dxDrawImage(x, y, radius, radius, getTexture("round"), 0, 0, 0, color, postGUI)
	dxDrawRectangle(x, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
	dxDrawImage(x, y + h - radius, radius, radius, getTexture("round"), 270, 0, 0, color, postGUI)
	dxDrawRectangle(x + radius, y, w - radius * 2, h, color, postGUI, subPixelPositioning)
	dxDrawImage(x + w - radius, y, radius, radius, getTexture("round"), 90, 0, 0, color, postGUI)
	dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
	dxDrawImage(x + w - radius, y + h - radius, radius, radius, getTexture("round"), 180, 0, 0, color, postGUI)
end

function getHudCursorPos()
	if isCursorShowing() then
		return getCursorPosition()
	end
	return false
end

function getFont(name)
	if createdFonts[name] then
		return createdFonts[name]
	end

	return "default"
end

function initFont(name, path, size)
	if not createdFonts[name] then
		createdFonts[name] = dxCreateFont("files/fonts/" .. path, resp(size), false, "antialiased")
	else
		return createdFonts[name]
	end
end

function isCursorWithinArea(cx, cy, x, y, w, h)
	if isCursorShowing() then
		if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
			return true
		end
	end

	return false
end

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (player)
		if player == localPlayer then
			if occupiedVehicle ~= source then
				occupiedVehicle = source
			end
		end
	end
)

addEventHandler("onClientVehicleExit", getRootElement(),
	function (player)
		if player == localPlayer then
			if occupiedVehicle == source then
				occupiedVehicle = false
			end
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if occupiedVehicle == source then
			occupiedVehicle = false
		end
	end
)

addEventHandler("onClientVehicleExplode", getRootElement(),
	function ()
		if occupiedVehicle == source then
			occupiedVehicle = false
		end
	end
)

function getVehicleSpeed(vehicle)
	local velocityX, velocityY, velocityZ = getElementVelocity(vehicle)
	return ((velocityX * velocityX + velocityY * velocityY + velocityZ * velocityZ) ^ 0.5) * 187.5
end
