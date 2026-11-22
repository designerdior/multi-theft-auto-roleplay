--[[
local ped = createPed(0, -2166.3759765625, 217.5732421875, 35.3203125, 180)

setCameraMatrix( -2166.3759765625, 214.1884765625, 36, -2166.3759765625, 217.5732421875, 36)

local skins = 312
local current = 0

function skinLoop()
	current = current + 1

	setTimer(setElementModel, 750, 1, ped, current)

	setTimer(outputChatBox, 750, 1, current)

	outputChatBox("capture")
end
bindKey('F12', 'up', skinLoop)

szkin baszás hagy benne!!!!!!!!!!!
egy macro kell 1500ms F12 gombnyomással, és done.
]]



--if fileExists("sourceC.lua") then
--	fileDelete("sourceC.lua")
--end

local renderData = {}
renderData.buyingVehicleSlot = false
renderData.buyingPet = false
renderData.buyingPetName = false
renderData.respawnPet = false
renderData.selectedTab = 0
renderData.shaders = {}
renderData.longestW = 0

local groupManaging = {}

local bankCol = createColSphere(1448.474609375, -990.33203125, 26.72611618042, 10)

local groups = {}

local playerGroups = {}
local playerRanksInGroups = {}

local groupMembers = {}
local groupVehicles = {}
local groupVehicleDatas = {}
local meInGroup = {}

local selectedGroupTab = 1
local selectedGroupSection = 1
local selectedMember = 1
local selectedRank = 1

local buttons = {}
local activeButton = false

local invitingErrorText = ""

local selectedGroupVeh = 1


local rankRenamingInProcess = false
local payManagingInProcess = false

local monitoredDatasForVehilce = {
	["dbid"] = true,
	["owner"] = true,
	["vehicle.maxFuel"] = true,
	["fuel"] = true,
	["vehicle.distance"] = true,
	["engine"] = true,
	["doorStates"] = true,
	["vehicle.nitroLevel"] = true,
	["interior"] = true,
	["handbrake"] = true,
	["vehicle.tuning.engine"] = true,
	["vehicle.tuning.turbo"] = true,
	["vehicle.tuning.ecu"] = true,
	["vehicle.tuning.valto"] = true,
	["vehicle.tuning.felfugg"] = true,
	["vehicle.tuning.brakes"] = true,
	["vehicle.tuning.tires"] = true,
	["vehicle.tuning.nitro"] = true,
	["vehicle.tuning.weightreduction"] = true,
	["vehicle.tuning.optical"] = true,
	["vehicle.tuning.airride"] = true,
	["tuning.neon"] = true
}

groupManaging[1] = false

function thousandsStepper(amount)
	local formatted = amount

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
		if (k==0) then
			break
		end
	end

	return formatted
end

local monitoredGroupVeh = {}

local datas = {}
local vehicleDatas = {}

function fetchGroups()
	local groupCount = getElementData(localPlayer, "groupCount")
	if tonumber(groupCount) and groupCount >= 1 then
		playerGroups = {}
		for i=0, groupCount-1 do
			local groupID = getElementData(localPlayer, "group_" .. i)
			if groupID then
				for k,v in pairs(groups) do
					if groupID == v["groupID"] then
						table.insert(playerGroups, groupID)
					end
				end
			end
		end
	end

	if #playerGroups >= 1 then
		triggerServerEvent("requestGroupData", localPlayer, playerGroups)
	end

	triggerServerEvent("requestGroups", localPlayer)

	local groupsKeyed = {}

	for k, v in pairs(playerGroups) do
		groupsKeyed[v] = true
		groupVehicles[v] = {}
	end

	for k, v in ipairs(getElementsByType("vehicle")) do
		local group = getElementData(v, "vehicle.group")

		if groupVehicles[group] then
			table.insert(groupVehicles[group], v)
			table.insert(monitoredGroupVeh, v)

			vehicleDatas[v] = {}

			for k in pairs(monitoredDatasForVehilce) do
				local data = getElementData(v, k)

				vehicleDatas[v][k] = data
			end
		end
	end
end

local leaderText = {"#7cc576igen"}
leaderText[0] = "#d9534fnem"

local rankCount = {}

local errorToDisplay = 0

addEvent("sendGroupMembers", true )
addEventHandler("sendGroupMembers", getRootElement(),
	function (members, playerID, groupID)
		local me = getElementData(localPlayer, "dbid")

		for k, v in pairs(members) do
			for k2, v2 in pairs(v) do
				if v2["id"] == me then
					meInGroup[k] = v2
				end
			end
		end

		local onlinePlayers = {}

		for k, v in pairs(getElementsByType("player")) do
			local id = getElementData(v, "playerid")

			onlinePlayers[id] = v
		end

		for k, v in pairs(members) do
			rankCount[k] = {}

			for k2, v2 in pairs(v) do
				local id = v2["id"]

				if onlinePlayers[id] then
					members[k][k2]["online"] = onlinePlayers[id]
				else
					members[k][k2]["online"] = false
				end

				local rank = v2["rank"]

				local current = rankCount[k][rank] or 0

				rankCount[k][rank] = current + 1

				if k == groupID and id == playerID then
					selectedMember = k2
				end
			end
		end

		groupMembers = members
	end)

addEvent("sendGroups", true )
addEventHandler("sendGroups", getRootElement(),
	function (datas)
		groups = datas

		if renderData.selectedTab == 3 then
			fetchGroups()
		end
	end
)

addEvent("renameGroupRank", true )
addEventHandler("renameGroupRank", getRootElement(),
	function (name, rankName, groupId)
		groups[groupId][name] = rankName

		if renderData.selectedTab == 3 then
			fetchGroups()
		end
	end)

	function isInGroup(groupID)
		fetchGroups()
		triggerServerEvent("requestGroups", localPlayer)

		if getElementData(localPlayer, "loggedin") then
			if meInGroup[groupID] then
				return true
			else
				return false
			end
		else
			return false
		end
	end

	function getPlayerGroupRank(groupID)
		if isInGroup(groupID) then
			return meInGroup[groupID]["rank"]
		else
			return false
		end
	end

	function isGroupLeader(groupID)
		if isInGroup(groupID) then
			if meInGroup[groupID]["isLeader"] == 1 then
				return true
			else
				return false
			end
		else
			return false
		end
	end

local screenX, screenY = guiGetScreenSize()

local myScreenSource = dxCreateScreenSource(screenX, screenY)


addEventHandler("onClientResourceStart", getResourceRootElement(),
	function()
		blurShader, blurTec = dxCreateShader("files/BlurShader.fx")

		if not blurShader then
			outputChatBox("[DASHBOARD] Hiba a blur shaderben.")
		end
	end)

local fontSizeMultipler = screenX / 1920

local OpenSans = dxCreateFont("files/OpenSans.ttf", 17.5 * fontSizeMultipler, false, "antialiased")
local OpenSansB = dxCreateFont("files/OpenSansB.ttf", 17.5 * fontSizeMultipler, false, "antialiased")
local OpenSansEB = dxCreateFont("files/OpenSansEB.ttf", 40 * fontSizeMultipler, false, "antialiased")
--						0			1 		  2 	     3 			4 			5
local captions = {"Információ", "Vagyon", "Prémium", "Frakciók", "Adminok", "Petek","Beállítások"}

local openAnimation = {}
local closeAnimation = {}

local premiumPoints = 0

local active = false

local monitoredDatas = {
	["dbid"] = true,
	["gameaccountid"] = true,
	["charactername"] = true,
	["gender"] = true,
	["age"] = true,
	["casualskin"] = true,
	["dimension_id"] = true,
	["interior_id"] = true,
	["health"] = true,
	["armor"] = true,
	["money"] = true,
	["bankmoney"] = true,
	["hoursplayed"] = true,
	["job"] = true,
	["description"] = true,
	["hunger"] = true,
	["timeinserver"] = true,
	["license.car"] = true,
	["license.gun"] = true,
	["char.slotCoins"] = true,
	["char.quests"] = true,
	["char.seePoints"] = true,
	["visibleName"] = true,
	["maxvehicles"] = true
}

local invitingInProcess = false

local playerVehicles = {}
local numOfPlayerHouses = 0
local playerInteriors = {}


local loadingData = true

local interiorsLoaded = false
local premiumLoaded = false

local selectedInt = 1

local selectedDollarTab = 1

local adminSlots = {}

local alpha = 1

local alphaAnim = false

local groupTabs = {"Tagok", "Rangok", "Járművek", "Egyéb"}

local groupTypes = {"#7cc576Rendvédelem", "#7cc576Tűzoltóság", "#7cc576Egészségügy", "#7cc576Önkormányzat", "#d9534fMaffia", "#d9534fBanda", "#7cc576Szervezet"}

local selectedGroup = 1

local invitingText = ""

local velocityMinus = 0

local lastVehGear = 0

local lastVelocityMinus = 0

function getAdmins()
	local gotAdmins = {}

	gotAdmins["as1"] = {}
	gotAdmins["as2"] = {}

	for i=1, 7 do
		gotAdmins[i] = {}
	end

	for k, v in ipairs(getElementsByType("player")) do
		local level = getElementData(v, "adminlevel")

		if tonumber(level) and level > 0 and level <= 7 then
			table.insert(gotAdmins[level], v)
		else
			local level2 = getElementData(v, "adminlevel")

			if tonumber(level2) and level2 == 1 then
				table.insert(gotAdmins["as" .. level2], v)
			end
		end
	end

	adminSlots = {}

	table.insert(adminSlots, {"title", "Ideiglenes adminsegédek"})

	if #gotAdmins["as1"] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins["as1"]) do
			table.insert(adminSlots, {"as", "#7cc576" .. getPlayerName(v):gsub("_", " ") .. "#ffffff (" .. getElementData(v, "playerid") .. ")"})
		end
	end

	table.insert(adminSlots, {"title", "S.G.H. adminsegédek"})

	if #gotAdmins["as2"] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins["as2"]) do
			table.insert(adminSlots, {"as", "#7cc576" .. getPlayerName(v):gsub("_", " ") .. "#ffffff (" .. getElementData(v, "playerid") .. ")"})
		end
	end

	table.insert(adminSlots, {"title", "1-es adminok"})

	if #gotAdmins[1] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[1]) do
			if getElementData(v, "adminduty") == 1 then
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)) .. "#ffffff (" .. getElementData(v, "playerid") .. ")", true})
			else
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)), false})
			end
		end
	end

	table.insert(adminSlots, {"title", "2-es adminok"})

	if #gotAdmins[2] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[2]) do
			if getElementData(v, "adminduty") == 1 then
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)) .. "#ffffff (" .. getElementData(v, "playerid") .. ")", true})
			else
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)), false})
			end
		end
	end


	table.insert(adminSlots, {"title", "3-as adminok"})

	if #gotAdmins[3] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[3]) do
			if getElementData(v, "adminduty") == 1 then
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)) .. "#ffffff (" .. getElementData(v, "playerid") .. ")", true})
			else
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)), false})
			end
		end
	end

	table.insert(adminSlots, {"title", "4-es adminok"})

	if #gotAdmins[4] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[4]) do
			if getElementData(v, "adminduty") == 1 then
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)) .. "#ffffff (" .. getElementData(v, "playerid") .. ")", true})
			else
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)), false})
			end
		end
	end

	table.insert(adminSlots, {"title", "5-ös adminok"})

	if #gotAdmins[5] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[5]) do
			if getElementData(v, "adminduty") == 1 then
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)) .. "#ffffff (" .. getElementData(v, "playerid") .. ")", true})
			else
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)), false})
			end
		end
	end


	table.insert(adminSlots, {"title", "Főadminok"})

	if #gotAdmins[6] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[6]) do
			if getElementData(v, "adminduty") == 1 then
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)) .. "#ffffff (" .. getElementData(v, "playerid") .. ")", true})
			else
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)), false})
			end
		end
	end

	table.insert(adminSlots, {"title", "SuperAdminok"})

	if #gotAdmins[7] < 1 then
		table.insert(adminSlots, {"center", "Nincs online"})
	else
		for k, v in ipairs(gotAdmins[7]) do
			if getElementData(v, "adminduty") == 1 then
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)) .. "#ffffff (" .. getElementData(v, "playerid") .. ")", true})
			else
				table.insert(adminSlots, {"admin", "#7cc576" .. (getElementData(v, "adminnick") or getPlayerName(v)), false})
			end
		end
	end
end

local alphaAnimDuration = 250
local openedTime = 0

function toggleDashboard()
	if getElementData(localPlayer, "loggedin") then
		if getTickCount() - openedTime <= 2000 and not active then
			outputChatBox("#d9534f[SeeMTA]: #FFFFFFMaximum 2 másodpercenként nyithatod meg a dashboard-ot.", 0, 0, 0, true)
			playDashboardSound("sounds/promptdecline")
			return
		end

		if not alphaAnim then
			active = not active

			if active then
				playDashboardSound("sounds/open")
			else
				playDashboardSound("sounds/close")
			end

			if active then
				for k, v in pairs(monitoredDatas) do
					datas[k] = getElementData(localPlayer, k)
				end

				playerVehicles = {}
				playerInteriors = {}
				playerPets = {}

				loadingData = true

				interiorsLoaded = false
				premiumLoaded = false

				for k, veh in ipairs(getElementsByType("vehicle")) do
					if getElementData(veh, "owner") == datas["dbid"] then
						table.insert(playerVehicles, veh)

						vehicleDatas[veh] = {}

						for k, v in pairs(monitoredDatasForVehilce) do
							vehicleDatas[veh][k] = getElementData(veh, k)
						end
					end
				end

				if renderData.selectedTab == 4 then
					getAdmins()
				end

				if renderData.selectedTab == 3 then
					fetchGroups()
					triggerServerEvent("requestGroups", localPlayer)
				end

				openedTime = getTickCount()

				triggerServerEvent("requestDatas", localPlayer, datas["gameaccountid"],  datas["dbid"])

				renderData.shaders = {}

				table.insert(renderData.shaders, {"Karosszéria tükröződés", exports.sas_shaders:getShaderSetting("cp"), "cp"})
				table.insert(renderData.shaders, {"HD Víz", exports.sas_shaders:getShaderSetting("water"), "water"})
				table.insert(renderData.shaders, {"Motion blur", exports.sas_shaders:getShaderSetting("blur"), "blur"})
				table.insert(renderData.shaders, {"HDR", exports.sas_shaders:getShaderSetting("con"), "con"})
				table.insert(renderData.shaders, {"HD Textúrák", exports.sas_shaders:getShaderSetting("tex"), "tex"})
				table.insert(renderData.shaders, {"Szürkeárnyalat", exports.sas_shaders:getShaderSetting("noire"), "noire"})
				table.insert(renderData.shaders, {"Szemcsézés", exports.sas_shaders:getShaderSetting("noise"), "noise"})
				table.insert(renderData.shaders, {"Fókusz", exports.sas_shaders:getShaderSetting("dof"), "dof"})
			--	table.insert(renderData.shaders, {"Napsugár", exports.sas_shaders:getShaderSetting("rays"), "rays"})
				--table.insert(renderData.shaders, {"Hó", exports.sas_shaders:getrenderData.ShaderSetting("snow"), "snow"}) nem működik + már szezona sincs

				--setShaderEnabled
			end

			setElementData(localPlayer, "dashboardState", true)

			showChat(false)

			if active then
				alphaAnim = {getTickCount(), 0, 1}
			else
				alphaAnim = {getTickCount(), 1, 0}
			end

			showCursor(active)
		end
	end
end
--toggleDashboard()

addEvent("requestDatas", true )
addEventHandler("requestDatas", getRootElement(),
	function (qType, result)
		if qType == "premium" then
			premiumPoints = getElementData(localPlayer, "pp")
			premiumLoaded = true
		elseif qType == "pets" then
			playerPets = result
			--petsLoaded = true
		else
			playerInteriors = result
			--outputChatBox(result)
			interiorsLoaded = true
		end

		if interiorsLoaded and premiumLoaded then
			loadingData = false
		end
	end)

function dxDrawDataRow(startX, startY, h, caption, data, scale)
	local w1 = dxGetTextWidth(caption, scale or 1, OpenSansB)
	local w2 = dxGetTextWidth(string.gsub(data, "#......", ""), scale or 1, OpenSans)

	h = h * fontSizeMultipler

	dxDrawText(caption, startX, startY, startX + w1, startY + h, tocolor(255, 255, 255, 255 * alpha), scale or 1, OpenSansB, "center", "center", false, false, false, true)
	dxDrawText(data, startX + w1, startY, startX + w1 + w2, startY + h, tocolor(124, 197, 118, 255 * alpha), scale or 1, OpenSans, "center", "center", false, false, false, true)

	return startY + h, w1 + w2
end

local jobNames = {}

jobNames[0] = "Munkanélküli"
jobNames[1] = "Buszsofőr (Városi)"
jobNames[2] = "Buszsofőr (Távolsági)"
jobNames[3] = "Postás"
jobNames[4] = "Áruszállító"
jobNames[5] = "Gyártósori munkás"
jobNames[6] = "Pizzafutár"


local bincoPos = {207.6728515625, -105.046875, 1005.1328125}
renderData.bincoColShape = createColSphere(bincoPos[1], bincoPos[2], bincoPos[3], 8)

local tuningName = {"#d9534nincs", "#FF9600alap", "#FF9600profi", "#FF9600verseny", "#7cc576venom"}
tuningName[0] = "#d9534fnincs"

local selectedVeh = 1


--0 -> Ház | 1-> Biznisz (Passzív) | 2 -> Középület | 3 -> Garázs | 4 -> Biznisz (Aktív)

local interiorTypes = {"Passzív biznisz", "Középület", "Garázs", "Garázs"}
interiorTypes[0] = "Ház"

local groupButtonCaptions = {"Előléptetés", "Lefokozás", "Kirúgás", "Új tag hozzáadása"}
local groupButtonCaptions2 = {"Átnevezés", "Fizetés módosítása"}
local groupButtonCaptions3 = {"Leírás módosítása", "Pénzügyek"}

groupManaging[2] = false

local skinSecondSideMultipler = 689 / 345

local cursorState = false
local lastChangeCursorState = 0

local buttonSizeX = 0
local buttonSizeY = 0

renderData.tabSizeX = 300 * fontSizeMultipler
selectedPets = 1
wantToBuyPetNum = 0
playerPets = {}
petNames = {"Huski", "Doberman", "Doberman", "Pitbull", "petType5", "petType6"}
atvPetID = 0
atvSpawned = 0
atvHealth = 0
spawned = false
OpenSansPET = dxCreateFont("files/OpenSansB.ttf", 23)

addEventHandler('onClientRender', getRootElement(),  -- main renderer
	function()
		if alphaAnim then
			local now = getTickCount()
			local elapsedTime = now - alphaAnim[1]
			local progress = elapsedTime / alphaAnimDuration

			alpha = interpolateBetween(
				alphaAnim[2], 0, 0,
				alphaAnim[3], 0, 0,
				progress, "Linear")

			if progress >= 1 then
				alphaAnim = false
				showChat(not active)

				setElementData(localPlayer, "dashboardState", active)
			end
		end

		if blurShader and (active or alphaAnim or renderData.buyingVehicleSlot or renderData.buyingPet or renderData.buyingPetName or renderData.respawnPet) then
			dxUpdateScreenSource(myScreenSource)

			dxSetShaderValue(blurShader, "ScreenSource", myScreenSource);
			dxSetShaderValue(blurShader, "BlurStrength", 5);
			dxSetShaderValue(blurShader, "UVSize", screenX, screenY);

			dxDrawImage(0, 0, screenX, screenY, blurShader)
		else
			blurShader = nil

		end
		if renderData.respawnPet then
			buttons = {}

			local formattedText = tonumber(invitingText) or 0

			local boxSizeX, boxSizeY = 600, 210


			dxDrawRectangle(screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, boxSizeX, boxSizeY, tocolor(0, 0, 0, 150))

			if renderData.respawnNoPP then
				dxDrawText("#d9534fHiba: nincs elég PP-d!", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			elseif renderData.respawnProcessing then
				dxDrawText("#7cc576Feldolgozás...", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			else
				dxDrawText("#FFFFFFTényleg szeretnéd feléleszteni a peted?\n#acd383A felélesztés ára 100PP!", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			end

			if activeButton == "cancel_respawn_pet" then
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(217, 83, 79, 200 * alpha))
			else
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(217, 83, 79, 150 * alpha))
			end
			dxDrawText("Mégsem", screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2, tocolor(0, 0, 0, 255 * alpha), 0.4, OpenSansEB, "center", "center", false, false, false, true)

			buttons["cancel_respawn_pet"] = {screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2}

			if activeButton == "respawn_pet_accept" then
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(124, 197, 118, 200 * alpha))
			else
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(124, 197, 118, 150 * alpha))
			end

			dxDrawText("Vásárlás", screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2, tocolor(0, 0, 0, 255 * alpha), 0.4, OpenSansEB, "center", "center", false, false, false, true)

			buttons["respawn_pet_accept"] = {screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2}

			dxDrawText("#acd383SeeMTA - #FF9600Pet felélesztése", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2 - 20, screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, tocolor(255, 255, 255, 255 * alpha), 0.4, OpenSansEB, "left", "center", false, false, false, true)
			dxDrawText("#7cc576Prémium egyenleg: #ffffff" .. (premiumPoints or 0) .. " #4aabd0PP", screenX / 2 - boxSizeX / 2, screenY / 2 + boxSizeY / 2, screenX / 2 + boxSizeX / 2, screenY / 2 + boxSizeY / 2 + 20, tocolor(255, 255, 255, 255 * alpha), 0.35, OpenSansEB, "center", "center", false, false, false, true)



			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx, cy = cx * screenX, cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[3] and cy >= v[2] and cy <= v[4] then
						activeButton = k
					end
				end
			else
				activeButton = false
			end
		end
		if renderData.buyingPet then
			buttons = {}
			local maxPets = 6
			local boxSizeX, boxSizeY = 1235, 360
			dxDrawRectangle(screenX/2-boxSizeX/2, screenY/2-boxSizeY/2, boxSizeX, boxSizeY, tocolor(0,0,0,160))

			for i=1, maxPets do

				if activeButton == "pet_" .. i then
					dxDrawRectangle(screenX/2-boxSizeX/2-80+(i-1)*200+110, screenY/2-93, 165, 195, tocolor(0,0,0,150))
				end
				buttons["pet_" .. i] = {screenX/2-boxSizeX/2-80+(i-1)*200+110, screenY/2-93, screenX/2-boxSizeX/2-80+(i-1)*200+110+165, screenY/2-93+195}
				dxDrawImage(screenX/2-boxSizeX/2-80+(i-1)*200, screenY/2-73, 365, 140, "files/dogs/"..i..".png")
			end
			if activeButton == "cancel_buying_pet" then
				dxDrawRectangle(screenX/2-boxSizeX/2+25, screenY/2-boxSizeY/2+boxSizeY-70, 1175, 40, tocolor(217, 83, 79, 200 * alpha))
			else
				dxDrawRectangle(screenX/2-boxSizeX/2+25, screenY/2-boxSizeY/2+boxSizeY-70, 1175, 40, tocolor(217, 83, 79, 150 * alpha))
			end
			dxDrawText("Mégsem", screenX/2-boxSizeX/2+25, screenY/2-boxSizeY/2+boxSizeY-70,screenX/2-boxSizeX/2+25+1175, screenY/2-boxSizeY/2+boxSizeY-30 ,tocolor(0, 0, 0, 255 * alpha), 0.4, OpenSansEB, "center", "center", false, false, false, true)

			buttons["cancel_buying_pet"] = {screenX/2-boxSizeX/2+25, screenY/2-boxSizeY/2+boxSizeY-70,screenX/2-boxSizeX/2+25+1175, screenY/2-boxSizeY/2+boxSizeY-30}

			dxDrawText("Kattints egy kutyára a típus kiválasztásához.",screenX/2-boxSizeX/2, screenY/2-boxSizeY/2+40,screenX/2-boxSizeX/2+boxSizeX, 0 ,tocolor(255, 255, 255, 255 * alpha), 0.9, OpenSans, "center", "top", false, false, false, true)
			dxDrawText("#7cc576SeeMTA - #ff9600Pet vásárlás",screenX/2-boxSizeX/2, screenY/2-boxSizeY/2-25,0, 0 ,tocolor(255, 255, 255, 255 * alpha), 1, OpenSansB, "left", "top", false, false, false, true)

			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx, cy = cx * screenX, cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[3] and cy >= v[2] and cy <= v[4] then
						activeButton = k
					end
				end
			else
				activeButton = false
			end
		end

		if renderData.buyingPetName then
			buttons = {}

			local formattedText = invitingText or ""

			local boxSizeX, boxSizeY = 600, 300


			dxDrawRectangle(screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, boxSizeX, boxSizeY, tocolor(0, 0, 0, 150))

			if renderData.buyPetNoPP then
				dxDrawText("#d9534fHiba: nincs elég PP-d!", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			elseif renderData.buyPetProcessing then
				dxDrawText("#7cc576Feldolgozás...", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			else
				dxDrawText("#FFFFFFAdd meg a vásárolni kívánt kutya nevét.\n#7cc576A kutya 8000 PP-be kerül", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			end


			dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30 + dxGetTextWidth("Név: ", 0.4, OpenSansEB), screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5, boxSizeX - 30 * 2 - dxGetTextWidth("Név: ", 0.4, OpenSansEB), 40, tocolor(0, 0, 0, 150))
			dxDrawText("#FFFFFF" .. formattedText, screenX / 2 - boxSizeX / 2 + 30 + dxGetTextWidth("Név: ", 0.4, OpenSansEB) + 5, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 40, tocolor(255, 255, 255, 255 * alpha), 1, OpenSansB, "left", "center", false, false, false, true)

			dxDrawText("#FFFFFFNév: ", screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 40, tocolor(255, 255, 255, 255 * alpha), 0.4, OpenSansEB, "left", "center", false, false, false, true)


			if cursorState then
				local w = dxGetTextWidth(formattedText, 1, OpenSansB)
				local startX = screenX / 2 - boxSizeX / 2 + 30 + dxGetTextWidth("Név: ", 0.4, OpenSansEB) + 5 + 5

				dxDrawLine(startX + w, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 5, startX + w, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 40 - 5, tocolor(255, 255, 255, 255 * alpha), 2)
			end

			local time = getTickCount() - lastChangeCursorState

			if time >= 500 then
				cursorState = not cursorState
				lastChangeCursorState = getTickCount()
			end

			if activeButton == "cancel_entering_petname" then
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(217, 83, 79, 200 * alpha))
			else
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(217, 83, 79, 150 * alpha))
			end
			dxDrawText("Mégsem", screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2, tocolor(0, 0, 0, 255 * alpha), 0.4, OpenSansEB, "center", "center", false, false, false, true)

			buttons["cancel_entering_petname"] = {screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2}

			if activeButton == "buy_pet" then
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(124, 197, 118, 200 * alpha))
			else
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(124, 197, 118, 150 * alpha))
			end

			dxDrawText("Vásárlás", screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2, tocolor(0, 0, 0, 255 * alpha), 0.4, OpenSansEB, "center", "center", false, false, false, true)

			buttons["buy_pet"] = {screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2}

			dxDrawText("#acd383SeeMTA - #FF9600Pet vásárlás", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2 - 20, screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, tocolor(255, 255, 255, 255 * alpha), 0.4, OpenSansEB, "left", "center", false, false, false, true)
			dxDrawText("#7cc576Prémium egyenleg: #ffffff" .. (premiumPoints or 0) .. " #4aabd0PP", screenX / 2 - boxSizeX / 2, screenY / 2 + boxSizeY / 2, screenX / 2 + boxSizeX / 2, screenY / 2 + boxSizeY / 2 + 20, tocolor(255, 255, 255, 255 * alpha), 0.35, OpenSansEB, "center", "center", false, false, false, true)



			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx, cy = cx * screenX, cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[3] and cy >= v[2] and cy <= v[4] then
						activeButton = k
					end
				end
			else
				activeButton = false
			end
		end


		if renderData.buyingVehicleSlot then
			buttons = {}

			local formattedText = tonumber(invitingText) or 0

			local boxSizeX, boxSizeY = 600, 300


			dxDrawRectangle(screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, boxSizeX, boxSizeY, tocolor(0, 0, 0, 150))

			if renderData.buySlotNoPP then
				dxDrawText("#d9534fHiba: nincs elég PP-d!", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			elseif renderData.buySlotProcessing then
				dxDrawText("#7cc576Feldolgozás...", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			else
				dxDrawText("#FFFFFFAdd meg a vásárolni kívánt slotok számát.\n#7cc576(1db slot = #4aabd0100PP#7cc576)\n#7cc576Összesen:\n#FF9600"..  formattedText .. "#7cc576slot = #4aabd0" .. formattedText * 100 .. "PP\n#FF9600(használd a számokat a mennyiség megadásához)", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, screenX / 2 - boxSizeX / 2 + boxSizeX, screenY / 2 - boxSizeY / 2 + boxSizeY - 100, tocolor(255, 255, 255, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)
			end


			dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30 + dxGetTextWidth("Összesen: ", 0.4, OpenSansEB), screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5, boxSizeX - 30 * 2 - dxGetTextWidth("Összesen: ", 0.4, OpenSansEB) - dxGetTextWidth(" slot", 0.4, OpenSansEB), 40, tocolor(0, 0, 0, 150))

			dxDrawText("#FFFFFF" .. formattedText, screenX / 2 - boxSizeX / 2 + 30 + dxGetTextWidth("Összesen: ", 0.4, OpenSansEB) + 5, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 40, tocolor(255, 255, 255, 255 * alpha), 1, OpenSansB, "left", "center", false, false, false, true)

			dxDrawText("#FFFFFFÖsszesen: ", screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 40, tocolor(255, 255, 255, 255 * alpha), 0.4, OpenSansEB, "left", "center", false, false, false, true)
			dxDrawText("#FFFFFF slot", screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 40, tocolor(255, 255, 255, 255 * alpha), 0.4, OpenSansEB, "right", "center", false, false, false, true)

			if cursorState then
				local w = dxGetTextWidth(formattedText, 1, OpenSansB)
				local startX = screenX / 2 - boxSizeX / 2 + 30 + dxGetTextWidth("Összesen: ", 0.4, OpenSansEB) + 5 + 5

				dxDrawLine(startX + w, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 5, startX + w, screenY / 2 - boxSizeY / 2 + boxSizeY - 125 + 5 + 40 - 5, tocolor(255, 255, 255, 255 * alpha), 2)
			end

			local time = getTickCount() - lastChangeCursorState

			if time >= 500 then
				cursorState = not cursorState
				lastChangeCursorState = getTickCount()
			end

			if activeButton == "cancel_veh_slot" then
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(217, 83, 79, 200 * alpha))
			else
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(217, 83, 79, 150 * alpha))
			end
			dxDrawText("Mégsem", screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2, tocolor(0, 0, 0, 255 * alpha), 0.4, OpenSansEB, "center", "center", false, false, false, true)

			buttons["cancel_veh_slot"] = {screenX / 2 - boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2}

			if activeButton == "buy_veh_slot" then
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(124, 197, 118, 200 * alpha))
			else
				dxDrawRectangle(screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, boxSizeX / 2 - 30 * 2, 100 - 30 * 2, tocolor(124, 197, 118, 150 * alpha))
			end

			dxDrawText("Vásárlás", screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2, tocolor(0, 0, 0, 255 * alpha), 0.4, OpenSansEB, "center", "center", false, false, false, true)

			buttons["buy_veh_slot"] = {screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30, screenX / 2 - boxSizeX / 2 + boxSizeX / 2 + 30 + boxSizeX / 2 - 30 * 2, screenY / 2 - boxSizeY / 2 + boxSizeY - 100 + 30 + 100 - 30 * 2}

			dxDrawText("#acd383SeeMTA - #FF9600Járműslot vásárlás", screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2 - 20, screenX / 2 - boxSizeX / 2, screenY / 2 - boxSizeY / 2, tocolor(255, 255, 255, 255 * alpha), 0.4, OpenSansEB, "left", "center", false, false, false, true)
			dxDrawText("#7cc576Prémium egyenleg: #ffffff" .. (premiumPoints or 0) .. " #4aabd0PP", screenX / 2 - boxSizeX / 2, screenY / 2 + boxSizeY / 2, screenX / 2 + boxSizeX / 2, screenY / 2 + boxSizeY / 2 + 20, tocolor(255, 255, 255, 255 * alpha), 0.35, OpenSansEB, "center", "center", false, false, false, true)



			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx, cy = cx * screenX, cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[3] and cy >= v[2] and cy <= v[4] then
						activeButton = k
					end
				end
			else
				activeButton = false
			end
		end

		if (active or alphaAnim) and not renderData.buyingVehicleSlot and not renderData.buyingPet and not renderData.buyingPetName and not renderData.respawnPet then
			buttons = {}
			local groupButtonColors = {tocolor(124, 197, 118, 155 * alpha), tocolor(217, 83, 79, 155 * alpha), tocolor(217, 83, 79, 155 * alpha), tocolor(124, 197, 118, 155 * alpha), tocolor(255, 150, 0, 155 * alpha)}


			local marginTop = screenY / 6
			local marginSide = marginTop

			local holderY = screenY - marginTop * 2
			local oneTabSize = holderY / 7

			--dxDrawRectangle(marginSide, marginTop, screenX - marginSide * 2, oneTabSize * 6)

			for i=0,6 do
				if tonumber(openAnimation[i]) then
					local now = getTickCount()
					local elapsedTime = now - openAnimation[i]
					local duration = 250
					local progress = elapsedTime / duration

					local x1, x2, x3 = interpolateBetween(
						marginSide * 1.5, oneTabSize - 10, marginSide * 1.5,
						marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10, renderData.tabSizeX, marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10,
						progress, "Linear")

					dxDrawRectangle(x1, 5 + marginTop + i * 5 + i * (oneTabSize - 5), x2, oneTabSize - 10, tocolor(0, 0, 0, 200 * alpha))
					dxDrawText(captions[i + 1], x3, 5 + marginTop + i * 5 + i * (oneTabSize - 5), marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10 + renderData.tabSizeX - oneTabSize, 5 + marginTop + i * 5 + i * (oneTabSize - 5) + oneTabSize - 10, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", true)

					if progress >= 1 then
						openAnimation[i] = false
					end
				elseif tonumber(closeAnimation[i]) then
					local now = getTickCount()
					local elapsedTime = now - closeAnimation[i]
					local duration = 250
					local progress = elapsedTime / duration

					local x1, x2, x3 = interpolateBetween(
						marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10, renderData.tabSizeX, marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10,
						marginSide * 1.5, oneTabSize - 10, marginSide * 1.5,
						progress, "Linear")

					dxDrawRectangle(x1, 5 + marginTop + i * 5 + i * (oneTabSize - 5), x2, oneTabSize - 10, tocolor(0, 0, 0, 200 * alpha))
					dxDrawText(captions[i + 1], x3, 5 + marginTop + i * 5 + i * (oneTabSize - 5), marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10 + renderData.tabSizeX - oneTabSize, 5 + marginTop + i * 5 + i * (oneTabSize - 5) + oneTabSize - 10, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", true)

					if progress >= 1 then
						closeAnimation[i] = false
					end
				else
					if i == renderData.selectedTab then
						--dxDrawRectangle(marginSide - oneTabSize + 20, 5 + marginTop + i * 5 + i * (oneTabSize - 5), renderData.tabSizeX, oneTabSize - 10, tocolor(0, 0, 0, 200 * alpha))

						dxDrawRectangle(marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10, 5 + marginTop + i * 5 + i * (oneTabSize - 5), renderData.tabSizeX, oneTabSize - 10, tocolor(0, 0, 0, 200 * alpha))

						dxDrawText(captions[i + 1], marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10, 5 + marginTop + i * 5 + i * (oneTabSize - 5), marginSide * 1.5 - renderData.tabSizeX + oneTabSize - 10 + renderData.tabSizeX - oneTabSize, 5 + marginTop + i * 5 + i * (oneTabSize - 5) + oneTabSize - 10, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", true)
					else
						dxDrawRectangle(marginSide * 1.5, 5 + marginTop + i * 5 + i * (oneTabSize - 5), oneTabSize - 10, oneTabSize - 10, tocolor(0, 0, 0, 200 * alpha))

						buttons["selectTab|" .. i] = {marginSide * 1.5, 5 + marginTop + i * 5 + i * (oneTabSize - 5), marginSide * 1.5 + oneTabSize - 10, 5 + marginTop + i * 5 + i * (oneTabSize - 5) + oneTabSize - 10}
					end
				end

				dxDrawImage(marginSide * 1.5, 5 + marginTop + i * 5 + i * (oneTabSize - 5), oneTabSize - 10, oneTabSize - 10, "files/tabs/" .. i .. ".png", 0, 0, 0, tocolor(124, 197, 118, 255 * alpha))
			end

			local holderSizeX, holderSizeY = screenX - marginSide * 2 - renderData.tabSizeX - 10, oneTabSize * 7 - 10
			local holderX, holderY = marginSide * 1.5 + oneTabSize, 5 + marginTop

			dxDrawRectangle(holderX, holderY, holderSizeX, holderSizeY, tocolor(0, 0, 0, 200 * alpha))

			--local w = dxGetTextWidth("PageUp, PageDown, le nyíl, fel nyíl és a kurzor segítségével navigálhatsz.", 0.75, OpenSans) + 50
			--local height = holderSizeY / 25

			--dxDrawRectangle(holderX + holderSizeX - w, holderY + holderSizeY, w, height, tocolor(0, 0, 0, 200 * alpha))

			--dxDrawText("PageUp, PageDown, le nyíl, fel nyíl és a kurzor segítségével navigálhatsz.", holderX + holderSizeX - w, holderY + holderSizeY * 0.99, holderX + holderSizeX, holderY + holderSizeY + height, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSans, "center", "center", false, false, false, true)

			dxDrawImage(screenX / 2 - 931 / 2, screenY - 25 - 72, 931, 72, "files/seedashnav.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))

			if renderData.selectedTab == 0 then --Infó
				dxDrawText("Információ", holderX, holderY, holderX + holderSizeX, holderY + 75, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)

				local startX = holderX + 25
				local startY = holderY + 75

				local sideX = holderSizeX / 7
				local sideY = sideX * skinSecondSideMultipler

			--	dxDrawImage(holderX + holderSizeX - sideX - 25, startY, sideX, sideY, "files/skins/" .. 0 .. ".jpg", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))

				if 0 == getElementModel(localPlayer) then
					dxDrawText("Skined", holderX + holderSizeX - sideX - 25, startY + sideY, holderX + holderSizeX - sideX - 25 + sideX, startY + sideY + 30, tocolor(255, 255, 255, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				--else
				--	dxDrawText("Állandó skined", holderX + holderSizeX - sideX - 25, startY + sideY, holderX + holderSizeX - sideX - 25 + sideX, startY + sideY + 30, tocolor(255, 255, 255, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				end

				if 0 ~= getElementModel(localPlayer) then
					dxDrawImage(holderX + holderSizeX - sideX * 2 - 25 * 2, startY, sideX, sideY, "files/skins/" .. getElementModel(localPlayer) .. ".jpg", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))
					dxDrawText("Jelenlegi skined", holderX + holderSizeX - sideX * 2 - 25 * 2, startY + sideY, holderX + holderSizeX - sideX * 2 - 25 * 2 + sideX, startY + sideY + 30, tocolor(255, 255, 255, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				end

				local height = 30

				--[[
					["dbid"] = true,
					["gameaccountid"] = true,
					["charactername"] = true,
					["gender"] = true,
					["char.Age"] = true,
					["casualskin"] = true,
					["dimension_id"] = true,
					["interior_id"] = true,
					["char.Health"] = true,
					["armor"] = true,
					["money"] = true,
					["bankmoney"] = true,
					["hoursplayed"] = true,
					["job"] = true,
					["chardescription"] = true,
					["hunger"] = true,
					["timeinserver"] = true,
					["license.car"] = true,
					["license.gun"] = true,
					["char.slotCoins"] = true,
					["char.quests"] = true,
					["char.seePoints"] = true,
					["visibleName"] = true
				]]

				--if datas["charactername"] ~= datas["visibleName"] then
				--	dxDrawDataRow(startX, startY, height, "Név: ", datas["charactername"]:gsub("_", " "))
				--	dxDrawDataRow(startX, startY + height, height, "Megjelenő név: ", "#4aabd0" .. datas["visibleName"])
				--	startY = startY + height
			--	else
				--	dxDrawDataRow(startX, startY, height, "Név: ", datas["charactername"]:gsub("_", " "))
			--	end

				startY = startY + height

				startY = dxDrawDataRow(startX, startY, height, "Kor: ", datas["age"] .. " év")

				startY = dxDrawDataRow(startX, startY, height, "Munka: ", "#4aabd0" .. (jobNames[datas["job"]] or "hozzáadatlan munka"))

				startY = dxDrawDataRow(startX, startY, height, "AccountID: ", "#FF9600" .. datas["gameaccountid"])

				startY = dxDrawDataRow(startX, startY, height, "KarakterID: ", "#FF9600" .. datas["dbid"])

				if 0 ~= getElementModel(localPlayer) then
					startY = dxDrawDataRow(startX, startY, height, "Állandó skin: ", 0)
					startY = dxDrawDataRow(startX, startY, height, "Jelenlegi skin: ", getElementModel(localPlayer))
				else
					startY = dxDrawDataRow(startX, startY, height, "Skin: ", 0)
				end

				startY = dxDrawDataRow(startX, startY, height, "Játszott percek: ", 0 .. " #ffffffperc")

				startY = dxDrawDataRow(startX, startY, height, "Idő a fizetésig: ", 60 - datas["timeinserver"] .. " #ffffffperc")

				startY = dxDrawDataRow(startX, startY, height, "Készpénz: ", thousandsStepper(datas["money"]) .. " #ffffff$")

				startY = dxDrawDataRow(startX, startY, height, "Banki egyenleg: ", thousandsStepper(datas["bankmoney"]) .. " #ffffff$")

				if loadingData then
					startY = dxDrawDataRow(startX, startY, height, "Prémium egyenleg: ", "betöltés...")
				else
					startY = dxDrawDataRow(startX, startY, height, "Prémium egyenleg: ", "#4aabd0" .. thousandsStepper(premiumPoints) .. " #ffffffPP")
				end

				startY = dxDrawDataRow(startX, startY, height, "Járműveid száma: ", #playerVehicles .. " #ffffffdb")

				if loadingData then
					startY = dxDrawDataRow(startX, startY, height, "Ingatlanjaid száma: ", "betöltés...")
				else
					startY = dxDrawDataRow(startX, startY, height, "Ingatlanjaid száma: ", #playerInteriors .. " #ffffffdb")
				end

				startY = dxDrawDataRow(startX, startY, height, "Karaktered leírása: ", "")

				dxDrawText(datas["description"], startX + 15, startY, holderX + holderSizeX - 25, holderY + holderSizeY, tocolor(250, 150, 0, 255 * alpha), 0.9, OpenSans, "left", "top", false, true)

			elseif renderData.selectedTab == 1 then --Vagyon
				dxDrawText("Vagyon", holderX, holderY, holderX + holderSizeX, holderY + 75, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)

				local startY = holderY + 75

				local height = 30

				local w = dxGetTextWidth("Prémium egyenleg: ", 1, OpenSansB)
				local w2 = 0

				if loadingData then
					w2 = dxGetTextWidth("betöltés...", 1, OpenSans)
				else
					w2 = dxGetTextWidth(premiumPoints .. " PP", 1, OpenSans)
				end

				local w3 = dxGetTextWidth("Készpénz: ", 1, OpenSansB)
				local w4 = dxGetTextWidth(thousandsStepper(datas["money"]) .. " $", 1, OpenSans)

				local w5 = dxGetTextWidth("Banki egyenleg: ", 1, OpenSansB)
				local w6 = dxGetTextWidth(thousandsStepper(datas["bankmoney"]) .. " $", 1, OpenSans)

				local allW = w + w2 + w3 + w4 + w5 + w6 + 20

				local startX = holderX + holderSizeX / 2 - allW / 2

				local s = 0

				s, w = dxDrawDataRow(startX, startY, height, "Készpénz: ", "#FF9600" .. thousandsStepper(datas["money"]) .. " #7cc576$")

				s, w2 = dxDrawDataRow(startX + w + 10, startY, height, "Banki egyenleg: ", "#FF9600" .. thousandsStepper(datas["bankmoney"]) .. " #7cc576$")

				if loadingData then
					startY = dxDrawDataRow(startX + w + w2 + 20, startY, height, "Prémium egyenleg: ", "betöltés...")
				else
					startY = dxDrawDataRow(startX + w + w2 + 20, startY, height, "Prémium egyenleg: ", thousandsStepper(premiumPoints) .. " #4aabd0PP")
				end

				local oneSegmentSize = holderSizeX / 2

				if activeButton == "button_more_vehslot" then
					dxDrawRectangle(holderX + oneSegmentSize - 100 - 15, startY + 20, 100, 75 - 20 * 2, tocolor(255, 150, 0, 200 * alpha))
				else
					dxDrawRectangle(holderX + oneSegmentSize - 100 - 15, startY + 20, 100, 75 - 20 * 2, tocolor(124, 197, 118, 200 * alpha))
				end

				dxDrawText("+slot", holderX + oneSegmentSize - 100 - 15, startY + 20, holderX + oneSegmentSize - 15, startY + 75 - 20, tocolor(0, 0, 0, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)

				buttons["button_more_vehslot"] = {holderX + oneSegmentSize - 100 - 15, startY + 20, holderX + oneSegmentSize - 15, startY + 75 - 20}

				dxDrawText("#7cc576Járműveim (" .. #playerVehicles .. " db/" .. datas["maxvehicles"] .. " db)", holderX, startY, holderX + oneSegmentSize, startY + 75, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)

				if loadingData then
					dxDrawText("#7cc576Ingatlanjaim (betöltés...)", holderX + oneSegmentSize, startY, holderX + oneSegmentSize * 2, startY + 75, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)
				else
					dxDrawText("#7cc576Ingatlanjaim (" .. #playerInteriors .. " db)", holderX + oneSegmentSize, startY, holderX + oneSegmentSize * 2, startY + 75, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)
				end

				startY = startY + 75

				local tabNum = 10
				local sizeForTabs = (holderY + holderSizeY) - startY - 25 - 150 - 25
				local oneSize = sizeForTabs / tabNum

				startX = holderX

				local offset = 0

				if selectedVeh > tabNum then
					offset = math.ceil((selectedVeh - tabNum) / tabNum) * 10
				end

				if #playerVehicles > 0 then
					for i=1, tabNum do
						local colorOfText = tocolor(124, 197, 118, 255 * alpha)
						local font = OpenSans

						if i + offset == selectedVeh then
							if selectedDollarTab == 1 then
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(124, 197, 118, 150 * alpha))
							else
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(255, 150, 0, 150 * alpha))
							end

							colorOfText = tocolor(0, 0, 0, 255 * alpha)
							font = OpenSansB
						else
							if i % 2 ~= 0 then
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 100 * alpha))
							else
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 150 * alpha))
							end
						end

						local veh = playerVehicles[i + offset]

						if isElement(veh) then
							local datas = vehicleDatas[veh]

							if i + offset == selectedVeh then
								dxDrawText("#" .. datas["dbid"] .. " " .. (exports.sas_vehicle:getVehicleNames(getElementModel(veh)) or getVehicleNameFromModel(getElementModel(veh))), startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, OpenSansB, "left", "center")
							else
								dxDrawText("#" .. datas["dbid"] .. " #FF9600" .. (exports.sas_vehicle:getVehicleNames(getElementModel(veh)) or getVehicleNameFromModel(getElementModel(veh))), startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, OpenSansB, "left", "center", false, false, false, true)
							end

							buttons["selectVehicle|" .. i + offset] = {startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize}

							if i + offset == selectedVeh then
								dxDrawText("Állapot: " .. math.floor(getElementHealth(veh) / 10) .. "%" .. " Benzin: " .. math.floor(datas["fuel"] or 100) .. "%", startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "right", "center")
							else
								dxDrawText("#FF9600Állapot: " .. math.floor(getElementHealth(veh) / 10) .. "%" .. " Benzin: " .. math.floor(datas["fuel"] or 100) .. "%", startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "right", "center", false, false, false, true)
							end
						elseif veh then
							local datas = vehicleDatas[veh]

							local colorOfText = tocolor(255, 150, 0, 255 * alpha)

							dxDrawText("Hiányzó jármű.", startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "left", "center")
						end
					end
				else
					for i=1, tabNum do
						if i ~= 6 then
							local colorOfText = tocolor(124, 197, 118, 255 * alpha)
							local font = OpenSans

							if i % 2 ~= 0 then
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 100 * alpha))
							else
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 150 * alpha))
							end
						end
					end

					local i = 6
					local colorOfText = tocolor(124, 197, 118, 255 * alpha)
					local font = OpenSans

					if selectedDollarTab == 1 then
						dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(124, 197, 118, 150 * alpha))
					else
						dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(255, 150, 0, 150 * alpha))
					end

					colorOfText = tocolor(0, 0, 0, 255 * alpha)
					font = OpenSansB

					local datas = vehicleDatas[veh]

					dxDrawText("Nincs autód :(", startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "center", "center")
				end

				dxDrawRectangle(startX + 25, startY + 10 * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 100 * alpha))

				if #playerVehicles > 0 then
					dxDrawText(offset / 10 + 1 .. "/" .. math.ceil(#playerVehicles / 10) .. ". oldal", startX + 25 + 10, startY + 10 * oneSize, startX + oneSegmentSize - 25 - 10, startY + 10 * oneSize + oneSize, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansB, "center", "center")
				end

				startX = startX + oneSegmentSize - 25/2

				offsetInt = 0

				tabNum = 14

				if selectedInt > tabNum then
					offsetInt = math.ceil((selectedInt - tabNum) / tabNum) * 10
				end

				sizeForTabs = (holderY + holderSizeY) - startY - 25 - 25
				oneSize = sizeForTabs / tabNum

				if #playerInteriors > 0 then
					for i=1, tabNum do
						local colorOfText = tocolor(124, 197, 118, 255 * alpha)
						local font = OpenSans
						local colorCoded = true

						if i + offsetInt == selectedInt then
							if selectedDollarTab == 2 then
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(124, 197, 118, 150 * alpha))
							else
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(255, 150, 0, 150 * alpha))
							end

							colorOfText = tocolor(0, 0, 0, 255 * alpha)
							font = OpenSansB
							colorCoded = false
						else
							if i % 2 ~= 0 then
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 100 * alpha))
							else
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 150 * alpha))
							end
						end

						local int = playerInteriors[i + offsetInt]

						if loadingData and i==1 then
							dxDrawText("Betöltés...", startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, OpenSansB, "center", "center")
						else
							if int then
								if i + offsetInt == selectedInt then
									dxDrawText("#" .. int["id"] ..  " " .. int["name"], startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, OpenSansB, "left", "center")
								else
									dxDrawText("#" .. int["id"] ..  " #4aabd0" .. int["name"], startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, OpenSansB, "left", "center", false, false, false, true)
								end

								buttons["selectInterior|" .. i + offsetInt] = {startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize}

								local locked = "#d9534fnem"

								if int["locked"] == 1 then
									locked = "#7cc576igen"
								end

								if not colorCoded then
									locked = string.gsub(locked, "#......", "")
								end

								if i + offsetInt == selectedInt then
									dxDrawText("Típus: " .. interiorTypes[int["type"]] .. " " .. " Zárva: " .. locked, startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "right", "center", false, false, false, colorCoded)
								else
									dxDrawText("#ffffffTípus: #FF9600" .. interiorTypes[int["type"]] .. " " .. " #ffffffZárva: " .. locked, startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "right", "center", false, false, false, true)
								end
							end
						end
					end
				else
					for i=1, tabNum do
						if i ~= 6 then
							local colorOfText = tocolor(124, 197, 118, 255 * alpha)
							local font = OpenSans

							if i % 2 ~= 0 then
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 100 * alpha))
							else
								dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 150 * alpha))
							end
						end
					end

					local i = 6
					local colorOfText = tocolor(124, 197, 118, 255 * alpha)
					local font = OpenSans

					if selectedDollarTab == 1 then
						dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(124, 197, 118, 150 * alpha))
					else
						dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(255, 150, 0, 150 * alpha))
					end

					colorOfText = tocolor(0, 0, 0, 255 * alpha)
					font = OpenSansB

					local datas = vehicleDatas[veh]

					dxDrawText("Nincs ingatlanod :(", startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "center", "center")
				end

				dxDrawRectangle(startX + 25, startY + 14 * oneSize, oneSegmentSize - 25 - (25/2), oneSize, tocolor(0, 0, 0, 100 * alpha))

				if #playerInteriors > 0 then
					dxDrawText(math.ceil(offsetInt / 14) + 1 .. "/" .. math.ceil(#playerInteriors / 14) .. ". oldal", startX + 25 + 10, startY + 14 * oneSize, startX + oneSegmentSize - 25 - 10, startY + 14 * oneSize + oneSize, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansB, "center", "center")
				end

				tabNum = 10
				sizeForTabs = (holderY + holderSizeY) - startY - 25 - 150 - 25
				oneSize = sizeForTabs / tabNum

				startY = startY + sizeForTabs + 25

				local veh = playerVehicles[selectedVeh]

				if isElement(veh) then
					local datas = vehicleDatas[veh]

					dxDrawText("#7cc576#" .. datas["dbid"] .. " " .. (exports.sas_vehicle:getVehicleNames(getElementModel(veh)) or getVehicleNameFromModel(getElementModel(veh))), holderX + 25, startY, holderX + oneSegmentSize, startY + 50, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "left", "center", false, false, false, true)

					startY = startY + 40

					--startY = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Kilóméterszámláló állása: ", math.floor(datas["vehicle.distance"] * 10) / 10, 0.85)

					local s = 0

					if datas["engine"] == 1 then
						s, w1 = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Motor: ", "#7cc576elindítva", 0.85)
					else
						s, w1 = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Motor: ", "#d9534fleállítva", 0.85)
					end

					if getVehicleOverrideLights(veh) == 2 then
						s, w2 = dxDrawDataRow(holderX + 25 + w1 + 10, startY, height * 0.85, "Lámpa: ", "#7cc576felkapcsolva", 0.85)
					else
						s, w2 = dxDrawDataRow(holderX + 25 + w1 + 10, startY, height * 0.85, "Lámpa: ", "#d9534flekapcsolva", 0.85)
					end

					if datas["handbrake"] then
						startY = dxDrawDataRow(holderX + 25 + w1 + w2 + 20, startY, height * 0.85, "Kézifék: ", "#7cc576behúzva", 0.85)
					else
						startY = dxDrawDataRow(holderX + 25 + w1 + w2 + 20, startY, height * 0.85, "Kézifék: ", "#d9534fkiengedve", 0.85)
					end

					if datas["vehicle.tuning.nitro"] == 0 then
						s, w1 = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Nitro: ", "#d9534f" .. datas["vehicle.tuning.nitro"] .. "%", 0.85)
					elseif datas["vehicle.tuning.nitro"] <= 50 then
						s, w1 = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Nitro: ", "#FF9600" .. datas["vehicle.tuning.nitro"] .. "%", 0.85)
					elseif datas["vehicle.tuning.nitro"] > 50 then
						s, w1 = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Nitro: ", "#7cc576" .. datas["vehicle.tuning.nitro"] .. "%", 0.85)
					end

					if datas["vehicle.tuning.airRide"] == 1 then
						s, w2 = dxDrawDataRow(holderX + 25 + w1 + 10, startY, height * 0.85, "AirRide: ", "#7cc576van", 0.85)
					else
						s, w2 = dxDrawDataRow(holderX + 25 + w1 + 10, startY, height * 0.85, "AirRide: ", "#d9534fnincs", 0.85)
					end

					if datas["vehicle.tuning.neon"] then
						s, w3 = dxDrawDataRow(holderX + 25 + w1 + w2 + 20, startY, height * 0.85, "Neon: ", "#7cc576van", 0.85)
					else
						s, w3 = dxDrawDataRow(holderX + 25 + w1 + w2 + 20, startY, height * 0.85, "Neon: ", "#d9534fnincs", 0.85)
				 	end


					--outputChatBox(datas["vehicle.tuning.engine"])
					startY, w1 = dxDrawDataRow(holderX + 25 + w1 + w2 + w3 + 30, startY, height * 0.85, "Motor: ", tuningName[datas["vehicle.tuning.engine"]], 0.85)
					s, w5 = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Fék: ", tuningName[datas["vehicle.tuning.brakes"]], 0.85)
					s, w2 = dxDrawDataRow(holderX + 25 + w5 + 10, startY, height * 0.85, "Turbo: ", tuningName[datas["vehicle.tuning.turbo"]], 0.85)
					s, w3 = dxDrawDataRow(holderX + 25 + w5 + w2 + 20, startY, height * 0.85, "ECU: ", tuningName[datas["vehicle.tuning.ecu"]], 0.85)
					startY, w4 = dxDrawDataRow(holderX + 25 + w5 + w2 + w3 + 30, startY, height * 0.85, "Váltó: ", tuningName[datas["vehicle.tuning.valto"]], 0.85)
					s, w6 = dxDrawDataRow(holderX + 25, startY, height * 0.85, "Kerék: ", tuningName[datas["vehicle.tuning.tires"]], 0.85)
					s, w7 = dxDrawDataRow(holderX + 25 + w6 + 10, startY, height * 0.85, "Súlycsökkentés: ", tuningName[datas["vehicle.tuning.weightreduction"]], 0.85)
					s, w8 = dxDrawDataRow(holderX + 25 + w6 + w7 + 20, startY, height * 0.85, "Felfüggesztés: ", tuningName[datas["vehicle.tuning.felfugg"]], 0.85)
				else
					dxDrawText("#FF9600Nincs jármű kiválasztva", holderX, startY, holderX + oneSegmentSize, startY + 75, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				end
			elseif renderData.selectedTab == 2 then --pépé
				local oneSegmentSize = holderSizeX / 3

				dxDrawText("Prémium", holderX, holderY, holderX + holderSizeX, holderY + 75, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)

				local startY = holderY + 75

				local w1 = dxGetTextWidth("Egyenleged: ", 1, OpenSansB)
				local w2 = dxGetTextWidth(thousandsStepper(premiumPoints) .. " PP", 1, OpenSans)

				local startX = holderX + holderSizeX / 2 - (w1 + w2) / 2

				dxDrawText("#FFFFFFEgyenleged: ", startX, startY, startX + w1, startY + 50, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText(thousandsStepper(premiumPoints) .. " #4aabd0PP", startX + w1, startY, startX + w1 + w2, startY + 50, tocolor(124, 197, 118, 255 * alpha), 1, OpenSans, "center", "center", false, false, false, true)

				startX = holderX
				startY = holderY + 125

				dxDrawText("Támogatás", startX, startY, startX + holderSizeX, startY + 50, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)

				startY = holderY + 175

				dxDrawText("#ACACACEzüst", holderX, startY, holderX + oneSegmentSize, startY + 50, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFPrémiumPont: #7cc5761000PP", holderX, startY + 50, holderX + oneSegmentSize, startY + 100, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFÁr: #7cc576800Ft+Áfa #FF9600(Bruttó 1016Ft)", holderX, startY + 100, holderX + oneSegmentSize, startY + 125, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFTelefonszám: #7cc57606 90/888-309", holderX, startY + 125, holderX + oneSegmentSize, startY + 175, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#7cc576Küldendő üzenet: #FF9600seerp " .. datas["gameaccountid"], holderX, startY + 175, holderX + oneSegmentSize, startY + 200, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)

				dxDrawText("#DAA520Arany", holderX + oneSegmentSize, startY, holderX + oneSegmentSize * 2, startY + 50, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFPrémiumPont: #7cc5762000PP", holderX + oneSegmentSize, startY + 50, holderX + oneSegmentSize * 2, startY + 100, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFÁr: #7cc5761600Ft+Áfa #FF9600(Bruttó 2032Ft)", holderX + oneSegmentSize, startY + 100, holderX + oneSegmentSize * 2, startY + 125, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFTelefonszám: #7cc57606 90/888-409", holderX + oneSegmentSize, startY + 125, holderX + oneSegmentSize * 2, startY + 175, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#7cc576Küldendő üzenet: #FF9600seerp " .. datas["gameaccountid"], holderX + oneSegmentSize, startY + 175, holderX + oneSegmentSize * 2, startY + 200, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)

				dxDrawText("#4AABD0Gyémánt", holderX + oneSegmentSize * 2, startY, holderX + oneSegmentSize * 3, startY + 50, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFPrémiumPont: #7cc5766000PP", holderX + oneSegmentSize * 2, startY + 50, holderX + oneSegmentSize * 3, startY + 100, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFÁr: #7cc5764000Ft+Áfa #FF9600(Bruttó 5080Ft)", holderX + oneSegmentSize * 2, startY + 100, holderX + oneSegmentSize * 3, startY + 125, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#FFFFFFTelefonszám: #7cc57606 90/649-549", holderX + oneSegmentSize * 2, startY + 125, holderX + oneSegmentSize * 3, startY + 175, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)
				dxDrawText("#7cc576Küldendő üzenet: #FF9600seerp " .. datas["gameaccountid"], holderX + oneSegmentSize * 2, startY + 175, holderX + oneSegmentSize * 3, startY + 200, tocolor(124, 197, 118, 255 * alpha), 1, OpenSansB, "center", "center", false, false, false, true)

				startY = holderY + 375

				dxDrawText("Felhasználási feltételek", startX, startY, startX + holderSizeX, startY + 75, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)

				startY = holderY + 400

				dxDrawText("Az SMS elküldésével beleegyezel a felhasználási feltételekbe.", startX, startY + 50, startX + holderSizeX, startY + 75, tocolor(255, 150, 0), 1, OpenSansB, "center", "center", false, false, false, true)

				dxDrawText("Az SMS-ben az adott telefonszámra a 'seerp' szócskát idéző jelek nélkül és a felhasználói azonosítódat (ACCOUNT ID) kell elküldeni. Minden esetben kapsz válasz SMS-t, ha nem kaptad meg az ellenszolgáltatást, vedd fel a kapcsolatot a szerver tulajdonosával! A támogatás - vásárlás teljesen önkényes jellegű, csak lehetőség. A támogatás - vásárlás nem jogosítja fel a játékost más viselkedésre, a szabályok ugyanúgy vonatkoznak rá is, amennyiben szabályt szeg a játékos nem részesül külön elbírálásban, ugyanolyan súlyú ítéletet kap mint bárki más. Elrontott SMS-ekért felelősséget nem vállalunk! Elrontott vásárlásért felelősséget nem vállalunk, nem térítjük vissza sem az összeget, sem a prémiumpontot! A szolgáltatás csak a telefonszámlát fizető, felelős személy beleegyezésével használható, általunk nem ellenőrizhető, tehát ezesetben reklamációt nem fogadunk el!"
							, startX + 200, startY + 75, startX + holderSizeX - 200, holderY + holderSizeY, tocolor(255, 255, 255, 255 * alpha), 0.75, OpenSans, "center", "center", false, true)
			elseif renderData.selectedTab == 3 then --Frakik
				dxDrawText("Frakciók", holderX, holderY, holderX + holderSizeX, holderY + 75, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)

				local startY = holderY + 75
				local startX = holderX

				local height = 30

				local groupTypeSize = holderSizeX / 3.5

				local sizeForTabs = holderSizeY - 25 - 75
				local tabNum = 20
				local oneSize = sizeForTabs / tabNum
				local scale = 0.75

				for i=1, tabNum do
					local rowColor = tocolor(0, 0, 0, 150 * alpha)
					local font = OpenSans
					local colorOfText = tocolor(124, 197, 118, 255 * alpha)
					local colorCoded = true

					if i % 2 ~= 0 then
						rowColor = tocolor(0, 0, 0, 100 * alpha)
					end

					if #playerGroups >= 1 and i == selectedGroup then
						if selectedGroupSection == 1 then
							rowColor = tocolor(124, 197, 118, 150 * alpha)
						else
							rowColor = tocolor(255, 150, 0, 150 * alpha)
						end

						colorOfText = tocolor(0, 0, 0, 255 * alpha)
						font = OpenSansB
						colorCoded = false
					end

					dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, groupTypeSize - 25, oneSize, rowColor)

					local groupId = playerGroups[i]

					if #playerGroups < 1 and i == 1 then
						dxDrawText("#FF9600Nem vagy frakcióban!", startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, textColor, scale, OpenSansB, "center", "center", false, false, false, true)
					end

					if tonumber(groupId) then
						dxDrawText(groups[groupId]["name"], startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, colorOfText, scale, OpenSansB, "left", "center")

						buttons["group_select|" .. i] = {startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize}

						if colorCoded then
							dxDrawText(groupTypes[groups[groupId]["type2"]], startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "right", "center", false, false, false, true)
						else
							dxDrawText(string.gsub(groupTypes[groups[groupId]["type2"]], "#......", ""), startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, tocolor(0, 0, 0, 255 * alpha), scale, font, "right", "center", false, false, false, true)
						end
					end
				end

				local groupId = playerGroups[selectedGroup]

				if tonumber(groupId) and meInGroup[groupId] then
					local rank = meInGroup[groupId]["rank"]
					dxDrawText(groups[groupId]["name"], holderX + groupTypeSize, startY, holderX + holderSizeX, startY + 50, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)

					startY = startY + 50
					startX = holderX + groupTypeSize + 25

					local s = 0

					local w1, w2 = 0, 0

					s, w1 = dxDrawDataRow(startX, startY, height * 0.85, "Rangod: ", "#7cc576" .. groups[groupId]["rank_" .. rank] .. " (#4aabd0" .. rank .. "#7cc576)", 0.85)
					s, w2 = dxDrawDataRow(startX + w1 + 10, startY, height * 0.85, "Fizetésed: ", "#7cc576" .. thousandsStepper(groups[groupId]["rank_" .. rank .. "_pay"]) .. "$", 0.85)

					if meInGroup[groupId]["dutySkin"] == 0 then
						startY = dxDrawDataRow(startX + w1 + w2 + 20, startY, height * 0.85, "Duty skined: ", "#d9534fnincs beállítva", 0.85)
					else
						startY = dxDrawDataRow(startX + w1 + w2 + 20, startY, height * 0.85, "Duty skined: ", "#7cc576" .. meInGroup[groupId]["dutySkin"], 0.85)
					end

					startY = startY + 25

					local oneSize = (holderX + holderSizeX - startX - 25) / 4

					for i=0,3 do
						if (i+1) == selectedGroupTab then -- rowColor = tocolor(124, 197, 118, 150 * alpha)
							if selectedGroupSection == 1 then
								dxDrawRectangle(startX + oneSize * i, startY, oneSize, 30, tocolor(255, 150, 0, 150 * alpha))
							else
								dxDrawRectangle(startX + oneSize * i, startY, oneSize, 30, tocolor(124, 197, 118, 150 * alpha))
							end

							dxDrawText(groupTabs[i+1], startX + oneSize * i, startY, startX + oneSize * i + oneSize, startY + 30, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "center", "center")
						else
							dxDrawRectangle(startX + oneSize * i, startY, oneSize, 30, tocolor(0, 0, 0, 150 * alpha))
							dxDrawText(groupTabs[i+1], startX + oneSize * i, startY, startX + oneSize * i + oneSize, startY + 30, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSans, "center", "center")
						end

						buttons["group_select.groupTabs|" .. i+1] = {startX + oneSize * i, startY, startX + oneSize * i + oneSize, startY + 30}
					end

					local oldStartX = startX
					local oldStartY = startY

					if selectedGroupTab == 1 or buttonSizeY < 1 then -- tagok/buttonSize
						startX = oldStartX - 25

						startY = oldStartY + 30 + 25

						local oldGroupTypeSize = groupTypeSize

						groupTypeSize = holderSizeX / 3

						sizeForTabs = holderSizeY - (startY - holderY) - 25
						tabNum = 14
						oneSize = sizeForTabs / (tabNum+1)
						scale = 0.7

						local offset = 0

						if selectedMember > tabNum then
							offset = math.ceil((selectedMember - tabNum) / tabNum) * tabNum
						end

						local thisMembers = groupMembers[groupId]

						for i=1, tabNum do
							local rowColor = tocolor(0, 0, 0, 150 * alpha)
							local font = OpenSans
							local colorOfText = tocolor(124, 197, 118, 255 * alpha)
							local colorCoded = true

							if i % 2 ~= 0 then
								rowColor = tocolor(0, 0, 0, 100 * alpha)
							end

							local member = thisMembers[i + offset]

							if i + offset == selectedMember then
								if selectedGroupSection == 1 then
									rowColor = tocolor(255, 150, 0, 150 * alpha)
								else
									rowColor = tocolor(124, 197, 118, 150 * alpha)
								end

								colorOfText = tocolor(0, 0, 0, 255 * alpha)
								font = OpenSansB
								colorCoded = false
							elseif member then
								if not member["online"] then
									colorOfText = tocolor(255, 150, 0, 255 * alpha)
								end
							end

							dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, groupTypeSize - 25, oneSize, rowColor)

							if selectedMember > #thisMembers then
								selectedMember = #thisMembers
							end

							if member then
								dxDrawText(member["characterName"]:gsub("_", " "), startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, colorOfText, scale, OpenSansB, "left", "center")

								local rank = member["rank"]

								buttons["group_select.member|" .. i + offset] = {startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize}

								if colorCoded then
									dxDrawText("#7cc576" .. groups[groupId]["rank_" .. rank] .. " (#4aabd0" .. rank .. "#7cc576)", startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "right", "center", false, false, false, true)
								else
									dxDrawText(groups[groupId]["rank_" .. rank] .. " (" .. rank .. ")", startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, tocolor(0, 0, 0, 255 * alpha), scale, font, "right", "center", false, false, false, true)
								end
							end
						end

						dxDrawRectangle(startX + 25, startY + 14 * oneSize, groupTypeSize - 25, oneSize, tocolor(0, 0, 0, 100 * alpha))
						dxDrawText(offset/tabNum + 1 .. "/" .. math.ceil(#thisMembers / tabNum) .. ". oldal (" .. selectedMember .. "/" .. #thisMembers .. "db tag)", startX + 25 + 10, startY + 14 * oneSize, startX + groupTypeSize - 25, startY + 14 * oneSize + oneSize, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansB, "center", "center")

						local member = thisMembers[selectedMember]

						dxDrawText(member["characterName"]:gsub("_", " "), holderX + groupTypeSize + oldGroupTypeSize, startY, holderX + holderSizeX, startY + 40, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)

						startY = startY + 50
						startX = holderX + groupTypeSize + oldGroupTypeSize + 25

						local rank = member["rank"]

						local lastOnline = split(member["lastOnline"] or "#d9534fnem_volt_még_online", " ")

						startY = dxDrawDataRow(startX, startY, height * 0.85, "Rang: ", "#7cc576" .. groups[groupId]["rank_" .. rank] .. " (" .. rank .. ")", 0.85)
						startY = dxDrawDataRow(startX, startY, height * 0.85, "Fizetés: ", "#7cc576" .. thousandsStepper(groups[groupId]["rank_" .. rank .. "_pay"]) .. "$", 0.85)

						if member["dutySkin"] == 0 then
							startY = dxDrawDataRow(startX, startY, height * 0.85, "Duty skin: ", "#d9534fnincs beállítva", 0.85)
						else
							startY = dxDrawDataRow(startX, startY, height * 0.85, "Duty skin: ", "#7cc576" .. member["dutySkin"], 0.85)
						end

						startY = dxDrawDataRow(startX, startY, height * 0.85, "Utoljára online: ", "#7cc576" .. lastOnline[1]:gsub("_", " "), 0.85)
						startY = dxDrawDataRow(startX, startY, height * 0.85, "Leader: ", leaderText[member["isLeader"]], 0.85)

						if member["online"] then
							startY = dxDrawDataRow(startX, startY, height * 0.85, "Online: ", "#7cc576igen", 0.85)
						else
							startY = dxDrawDataRow(startX, startY, height * 0.85, "Online: ", "#d9534fnem", 0.85)
						end

						local multiplerEx = (fontSizeMultipler - 0.52) * (1 - 0) / (1 - 0.52) + 0
						local buttonMargin = 25 * multiplerEx

						buttonSizeX = holderX + holderSizeX - startX - buttonMargin
						buttonSizeY = (holderY + holderSizeY - startY - buttonMargin) / 4

						if meInGroup[groupId]["isLeader"] == 1 then
							for i=0, 3 do
								if i == 3 and invitingInProcess then
									local acceptWidth = 75

									if activeButton == "group_invite" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[i+1])
									end

									dxDrawText("Hozzáad", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group_invite"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}

									dxDrawRectangle(startX, startY + buttonSizeY * i + buttonMargin, buttonSizeX - acceptWidth - 10, buttonSizeY - buttonMargin, tocolor(124, 197, 118, 150 * alpha))

									if cursorState then
										local w = dxGetTextWidth(invitingText, 0.75, OpenSansB)
										dxDrawLine(startX + 10 + w, startY + buttonSizeY * i + buttonMargin + 5, startX + 10 + w, startY + buttonSizeY * i + buttonSizeY - 5, tocolor(0, 0, 0, 255 * alpha), 2)
									end

									local time = getTickCount() - lastChangeCursorState

									if time >= 500 then
										cursorState = not cursorState
										lastChangeCursorState = getTickCount()
									end

									if string.len(invitingText) < 1 then
										dxDrawText("Hozzáadandó névrészlete/id-je", startX + 10, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(30, 30, 30, 200 * alpha), 0.75, OpenSans, "left", "center", false, false, false, true)
									else
										dxDrawText(invitingText, startX + 10, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
									end
								elseif i == 2 and renderData.memberFireAccept then
									local acceptWidth = 75

									if activeButton == "cancelFire" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[2])
									end

									if activeButton == "fireMember" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[1])
									end

									dxDrawText("Mégsem", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)
									dxDrawText("Kirúgás", startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX - acceptWidth - 10, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["cancelFire"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}
									buttons["fireMember"] = {startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX - acceptWidth - 10, startY + buttonSizeY * i + buttonSizeY}

									dxDrawText(invitingErrorText, startX + 10, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
								elseif i == 3 and string.len(invitingErrorText) > 0 and not renderData.memberFireAccept then
									local acceptWidth = 75

									if activeButton == "group_ok" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, acceptWidth, buttonSizeY - buttonMargin, groupButtonColors[i+1])
									end

									dxDrawText("OK", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group_ok"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}

									dxDrawText(invitingErrorText, startX + 10, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
								else
									if activeButton == "group_" .. i then
										dxDrawRectangle(startX, startY + buttonSizeY * i + buttonMargin, buttonSizeX, buttonSizeY - buttonMargin, groupButtonColors[5])
									else
										dxDrawRectangle(startX, startY + buttonSizeY * i + buttonMargin, buttonSizeX, buttonSizeY - buttonMargin, groupButtonColors[i+1])
									end

									dxDrawText(groupButtonCaptions[i+1], startX, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group_" .. i] = {startX, startY + buttonSizeY * i + buttonMargin, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}
								end
							end
						end
					elseif selectedGroupTab == 2 then -- rangok
						startX = oldStartX - 25

						startY = oldStartY + 30 + 25

						local oldGroupTypeSize = groupTypeSize

						groupTypeSize = holderSizeX / 3

						sizeForTabs = holderSizeY - (startY - holderY) - 25
						tabNum = 15
						oneSize = sizeForTabs / (tabNum)
						scale = 0.7

						local thisGroup = groups[groupId]

						for i=1, tabNum do
							local rowColor = tocolor(0, 0, 0, 150 * alpha)
							local font = OpenSans
							local colorOfText = tocolor(124, 197, 118, 255 * alpha)
							local colorCoded = true

							if i % 2 ~= 0 then
								rowColor = tocolor(0, 0, 0, 100 * alpha)
							end

							if i == selectedRank then
								if selectedGroupSection == 1 then
									rowColor = tocolor(255, 150, 0, 150 * alpha)
								else
									rowColor = tocolor(124, 197, 118, 150 * alpha)
								end

								colorOfText = tocolor(0, 0, 0, 255 * alpha)
								font = OpenSansB
								colorCoded = false
							end

							dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, groupTypeSize - 25, oneSize, rowColor)

							if i <= 15 then
								local rank = thisGroup["rank_" .. i]

								dxDrawText("[" .. i .. "] " .. rank, startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, colorOfText, scale, OpenSansB, "left", "center")

								local pay = thisGroup["rank_" .. i .. "_pay"]

								buttons["group_select.rank|" .. i] = {startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize}

								if colorCoded then
									dxDrawText("#7cc576" .. thousandsStepper(pay) .. "$", startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "right", "center", false, false, false, true)
								else
									dxDrawText(thousandsStepper(pay) .. "$", startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, tocolor(0, 0, 0, 255 * alpha), scale, font, "right", "center", false, false, false, true)
								end
							end
						end

						local rank = thisGroup["rank_" .. selectedRank]

						dxDrawText(rank, holderX + groupTypeSize + oldGroupTypeSize, startY, holderX + holderSizeX, startY + 40, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)

						startY = startY + 50
						startX = holderX + groupTypeSize + oldGroupTypeSize + 25

						startY = dxDrawDataRow(startX, startY, height * 0.85, "Fizetés: ", "#7cc576" .. thousandsStepper(groups[groupId]["rank_" .. selectedRank .. "_pay"]) .. "$", 0.85)
						startY = dxDrawDataRow(startX, startY, height * 0.85, "Tagok száma ezen a rangon: ", "#7cc576" .. (rankCount[groupId][selectedRank] or 0) .. "db", 0.85)

						if meInGroup[groupId]["isLeader"] == 1 then
							for i=0, 1 do
								if (i == 0 and rankRenamingInProcess) or (i == 1 and payManagingInProcess) then
									local acceptWidth = 75

									if activeButton == "group_rank_rename" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[i+1])
									end

									dxDrawText("Módosít", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group_rank_rename"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}

									dxDrawRectangle(startX, startY + buttonSizeY * i + 25, buttonSizeX - acceptWidth - 10, buttonSizeY - 25, tocolor(124, 197, 118, 150 * alpha))

									if cursorState then
										local w = dxGetTextWidth(invitingText, 0.75, OpenSansB)
										dxDrawLine(startX + 10 + w, startY + buttonSizeY * i + 25 + 5, startX + 10 + w, startY + buttonSizeY * i + buttonSizeY - 5, tocolor(0, 0, 0, 255 * alpha), 2)
									end

									local time = getTickCount() - lastChangeCursorState

									if time >= 500 then
										cursorState = not cursorState
										lastChangeCursorState = getTickCount()
									end

									dxDrawText(invitingText, startX + 10, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
								elseif i == errorToDisplay and string.len(invitingErrorText) > 0 then
									local acceptWidth = 75

									if activeButton == "group_ok" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[i+1])
									end

									dxDrawText("OK", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group_ok"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}

									dxDrawText(invitingErrorText, startX + 10, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
								else
									if activeButton == "group2_" .. i then
										dxDrawRectangle(startX, startY + buttonSizeY * i + 25, buttonSizeX, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX, startY + buttonSizeY * i + 25, buttonSizeX, buttonSizeY - 25, groupButtonColors[1])
									end

									dxDrawText(groupButtonCaptions2[i+1], startX, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group2_" .. i] = {startX, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}
								end
							end
						end
					elseif selectedGroupTab == 3 then -- kocsi
						startX = oldStartX - 25

						startY = oldStartY + 30 + 25

						local oldGroupTypeSize = groupTypeSize

						groupTypeSize = holderSizeX / 3

						sizeForTabs = holderSizeY - (startY - holderY) - 25
						tabNum = 14
						oneSize = sizeForTabs / (tabNum+1)
						scale = 0.7

						local offset = 0

						if selectedGroupVeh > tabNum then
							offset = math.ceil((selectedGroupVeh - tabNum) / tabNum) * tabNum
						end

						local vehicles = groupVehicles[groupId]

						for i=1, tabNum do
							local rowColor = tocolor(0, 0, 0, 150 * alpha)
							local font = OpenSans
							local colorOfText = tocolor(124, 197, 118, 255 * alpha)
							local colorCoded = true

							if i % 2 ~= 0 then
								rowColor = tocolor(0, 0, 0, 100 * alpha)
							end

							local veh = vehicles[i + offset]

							if i + offset == selectedGroupVeh then
								if selectedGroupSection == 1 then
									rowColor = tocolor(255, 150, 0, 150 * alpha)
								else
									rowColor = tocolor(124, 197, 118, 150 * alpha)
								end

								colorOfText = tocolor(0, 0, 0, 255 * alpha)
								font = OpenSansB
								colorCoded = false
							end

							dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, groupTypeSize - 25, oneSize, rowColor)

							local datas = vehicleDatas[veh]

							if isElement(veh) then
								local datas = vehicleDatas[veh]
								if datas then
									dxDrawText("#" .. datas["vehicle.dbID"] .. " " .. (exports.sas_vehicle:getVehicleNames(getElementModel(veh)) or getVehicleNameFromModel(getElementModel(veh))), startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, colorOfText, scale, OpenSansB, "left", "center")

									buttons["group_select.vehicle|" .. i] = {startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize}

									dxDrawText("Állapot: " .. math.floor(getElementHealth(veh) / 10) .. "%" .. " Benzin: " .. math.floor(datas["fuel"] or 100) .. "%", startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, colorOfText, scale, font, "right", "center")
								end
							elseif veh then
								local datas = vehicleDatas[veh]

								if colorOfText ~= tocolor(0, 0, 0) then
									colorOfText = tocolor(255, 150, 0)
								end

								dxDrawText("Hiányzó jármű.", startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + groupTypeSize - 25, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, font, "left", "center")
							end
						end

						dxDrawRectangle(startX + 25, startY + 14 * oneSize, groupTypeSize - 25, oneSize, tocolor(0, 0, 0, 100 * alpha))
						dxDrawText(offset/tabNum + 1 .. "/" .. math.ceil(#vehicles / tabNum) .. ". oldal", startX + 25 + 10, startY + 14 * oneSize, startX + groupTypeSize - 25, startY + 14 * oneSize + oneSize, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansB, "center", "center")

						local veh = groupVehicles[groupId][selectedGroupVeh]
						local datas = vehicleDatas[veh]

						if datas then
							dxDrawText("#7cc576#" .. datas["vehicle.dbID"] .. " " .. (exports.sas_vehicle:getVehicleNames(getElementModel(veh)) or getVehicleNameFromModel(getElementModel(veh))), holderX + groupTypeSize + oldGroupTypeSize, startY, holderX + holderSizeX, startY + 40, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)

							startY = startY + 40
							startX = holderX + groupTypeSize + oldGroupTypeSize

							if datas["engine"] == 1 then
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Motor: ", "#7cc576elindítva", 0.85)
							else
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Motor: ", "#d9534fleállítva", 0.85)
							end

							if getVehicleOverrideLights(veh) == 2 then
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Lámpa: ", "#7cc576felkapcsolva", 0.85)
							else
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Lámpa: ", "#d9534flekapcsolva", 0.85)
							end

							if datas["handbrake"] then
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Kézifék: ", "#7cc576behúzva", 0.85)
							else
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Kézifék: ", "#d9534fkiengedve", 0.85)
							end

							--if datas["vehicle.nitroLevel"] == 0 then
							--	startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Nitro: ", "#d9534f" .. datas["vehicle.nitroLevel"] .. "%", 0.85)
						--	elseif datas["vehicle.nitroLevel"] <= 50 then
							--	startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Nitro: ", "#FF9600" .. datas["vehicle.nitroLevel"] .. "%", 0.85)
						--	elseif datas["vehicle.nitroLevel"] > 50 then
								--startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Nitro: ", "#7cc576" .. datas["vehicle.nitroLevel"] .. "%", 0.85)
						--	end

							if datas["vehicle.tuning.airRide"] == 1 then
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "AirRide: ", "#7cc576van", 0.85)
							else
								startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "AirRide: ", "#d9534fnincs", 0.85)
							end

						--	if datas["tuning.neon"] > 10000 then
							--	startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Neon: ", "#7cc576van", 0.85)
							--else
							--	startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Neon: ", "#d9534fnincs", 0.85)
						--	end
							outputChatBox(tuningName[datas["vehicle.tuning.engine"]])
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Motor: ", tuningName[datas["vehicle.tuning.engine"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Fék: ", tuningName[datas["vehicle.tuning.brakes"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Turbo: ", tuningName[datas["vehicle.tuning.turbo"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "ECU: ", tuningName[datas["vehicle.tuning.ecu"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Váltó: ", tuningName[datas["vehicle.tuning.valto"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Kerék: ", tuningName[datas["vehicle.tuning.tires"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Súlycsökkentés: ", tuningName[datas["vehicle.tuning.weightreduction"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Felfüggesztés: ", tuningName[datas["vehicle.tuning.felfugg"]], 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Állapot: ", math.floor(getElementHealth(veh) / 10) .. "%", 0.85)
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Benzin: ",  math.floor(datas["fuel"] or 100) .. "%", 0.85)
						end
					elseif selectedGroupTab == 4 then -- egyéb
						startX = oldStartX - 25

						startY = oldStartY + 30 + 25

						startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Megjegyzés: ", groups[groupId]["description"], 0.85)

						if meInGroup[groupId]["isLeader"] == 1 then
							startY = dxDrawDataRow(startX + 25, startY, height * 0.85, "Egyenleg: ", thousandsStepper(groups[groupId]["balance"]) .. "$", 0.85)
						end

						startX = startX + 25

						--"Duty skin"

						if isElementWithinColShape(localPlayer, renderData.bincoColShape) then
							if activeButton == "setDutySkin" then
								dxDrawRectangle(startX, startY + 25, buttonSizeX, buttonSizeY - 25, groupButtonColors[5])
							else
								dxDrawRectangle(startX, startY + 25, buttonSizeX, buttonSizeY - 25, groupButtonColors[1])
							end

							dxDrawText("Duty skin beállítása", startX, startY + 25, startX + buttonSizeX, startY + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

							buttons["setDutySkin"] = {startX, startY + 25, startX + buttonSizeX, startY + buttonSizeY}

							startY = startY + buttonSizeY
						end

						if meInGroup[groupId]["isLeader"] == 1 then
							for i=0, 1 do
								if i == 0 and groupManaging[2] then
									local acceptWidth = 75

									if activeButton == "group_description_rewrite" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[i+1])
									end

									dxDrawText("Módosít", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group_description_rewrite"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}

									dxDrawRectangle(startX, startY + buttonSizeY * i + 25, buttonSizeX - acceptWidth - 10, buttonSizeY - 25, tocolor(124, 197, 118, 150 * alpha))

									if cursorState then
										local w = dxGetTextWidth(invitingText, 0.75, OpenSansB)
										dxDrawLine(startX + 10 + w, startY + buttonSizeY * i + 25 + 5, startX + 10 + w, startY + buttonSizeY * i + buttonSizeY - 5, tocolor(0, 0, 0, 255 * alpha), 2)
									end

									local time = getTickCount() - lastChangeCursorState

									if time >= 500 then
										cursorState = not cursorState
										lastChangeCursorState = getTickCount()
									end

									dxDrawText(invitingText, startX + 10, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
								elseif i == 1 and groupManaging[1] then
									local acceptWidth = 75

									if activeButton == "getOut" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[2])
									end

									if activeButton == "putBack" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[1])
									end

									dxDrawText("Kivétel", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)
									dxDrawText("Berakás", startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + 25, startX + buttonSizeX - acceptWidth - 10, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["getOut"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}
									buttons["putBack"] = {startX + buttonSizeX - acceptWidth * 2 - 10, startY + buttonSizeY * i + 25, startX + buttonSizeX - acceptWidth - 10, startY + buttonSizeY * i + buttonSizeY}

									dxDrawRectangle(startX, startY + buttonSizeY * i + 25, buttonSizeX - acceptWidth * 2 - 20, buttonSizeY - 25, tocolor(124, 197, 118, 150 * alpha))

									if cursorState then
										local w = dxGetTextWidth(invitingText, 0.75, OpenSansB)
										dxDrawLine(startX + 10 + w, startY + buttonSizeY * i + 25 + 5, startX + 10 + w, startY + buttonSizeY * i + buttonSizeY - 5, tocolor(0, 0, 0, 255 * alpha), 2)
									end

									local time = getTickCount() - lastChangeCursorState

									if time >= 500 then
										cursorState = not cursorState
										lastChangeCursorState = getTickCount()
									end

									dxDrawText(invitingText, startX + 10, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
								elseif i == errorToDisplay and string.len(invitingErrorText) > 0 then
									local acceptWidth = 75

									if activeButton == "group_ok" then
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, acceptWidth, buttonSizeY - 25, groupButtonColors[i+1])
									end

									dxDrawText("OK", startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group_ok"] = {startX + buttonSizeX - acceptWidth, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}

									dxDrawText(invitingErrorText, startX + 10, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 255 * alpha), 0.75, OpenSansB, "left", "center", false, false, false, true)
								else
									if activeButton == "group3_" .. i then
										dxDrawRectangle(startX, startY + buttonSizeY * i + 25, buttonSizeX, buttonSizeY - 25, groupButtonColors[5])
									else
										dxDrawRectangle(startX, startY + buttonSizeY * i + 25, buttonSizeX, buttonSizeY - 25, groupButtonColors[1])
									end

									dxDrawText(groupButtonCaptions3[i+1], startX, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY, tocolor(0, 0, 0, 225 * alpha), 0.75, OpenSansB, "center", "center", false, false, false, true)

									buttons["group3_" .. i] = {startX, startY + buttonSizeY * i + 25, startX + buttonSizeX, startY + buttonSizeY * i + buttonSizeY}
								end
							end
						end
					end
				else
					dxDrawText("Nincs kiválasztva frakció.", holderX + groupTypeSize - 25, startY, holderX + holderSizeX, startY + 25, tocolor(124, 197, 118, 255 * alpha), 0.5, OpenSansEB, "center", "center", false, false, false, true)
				end
			elseif renderData.selectedTab == 4 then --adminok
				dxDrawText("Online adminok és adminsegédek", holderX, holderY, holderX + holderSizeX, holderY + 75, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)

				local startY = holderY + 75
				local startX = holderX

				local oneSegmentSize = holderSizeX / 3

				local sizeForTabs = holderSizeY - 75 - 25 - 100
				local tabNum = 20
				local oneSize = sizeForTabs / tabNum

				for i=1, tabNum do
					local rowColor = tocolor(0, 0, 0, 150 * alpha)
					local textColor = tocolor(255, 150, 0)
					local slot = i
					local font = OpenSansB
					local scale = 0.65

					if i % 2 ~= 0 then
						rowColor = tocolor(0, 0, 0, 100 * alpha)
					end

					if adminSlots[slot] then
						if adminSlots[slot][1] == "title" then
							rowColor = tocolor(0, 0, 0, 255 * alpha)
							textColor = tocolor(124, 197, 118, 255 * alpha)

							font = OpenSansEB
							scale = 0.3
						else
							if adminSlots[slot][1] == "admin" or adminSlots[slot][1] == "as" then
								font = OpenSans

								textColor = tocolor(255, 255, 255, 255 * alpha)
							end
						end
					end

					dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 50/3, oneSize, rowColor)

					if adminSlots[slot] then
						if adminSlots[slot][1] == "admin" or adminSlots[slot][1] == "as" then
							dxDrawText(adminSlots[slot][2], startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "left", "center", false, false, false, true)

							local text = "Szolgálatban: #d9534fnem"

							if adminSlots[slot][3] then
								text = "Szolgálatban: #7cc576igen"
							end

							if adminSlots[slot][1] == "admin" then
								dxDrawText(text, startX + 25 + 10, startY + (i-1) * oneSize, startX - 10  + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "right", "center", false, false, false, true)
							end
						else
							dxDrawText(adminSlots[slot][2], startX + 25, startY + (i-1) * oneSize, startX + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "center", "center", false, false, false, true)
						end
					end
				end

				startX = startX + oneSegmentSize - 50/3

				for i=1, tabNum do
					local rowColor = tocolor(0, 0, 0, 150 * alpha)
					local textColor = tocolor(255, 150, 0)
					local slot = i + tabNum
					local font = OpenSansB
					local scale = 0.65

					if i % 2 == 0 then
						rowColor = tocolor(0, 0, 0, 100 * alpha)
					end

					if adminSlots[slot] then
						if adminSlots[slot][1] == "title" then
							rowColor = tocolor(0, 0, 0)
							textColor = tocolor(124, 197, 118, 255 * alpha)

							font = OpenSansEB
							scale = 0.35
						else
							if adminSlots[slot][1] == "admin" then
								font = OpenSans

								textColor = tocolor(255, 255, 255, 255 * alpha)
							end
						end
					end

					dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 50/3, oneSize, rowColor)

					if adminSlots[slot] then
						if adminSlots[slot][1] == "admin" then
							dxDrawText(adminSlots[slot][2], startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "left", "center", false, false, false, true)

							local text = "Szolgálatban: #d9534fnem"

							if adminSlots[slot][3] then
								text = "Szolgálatban: #7cc576igen"
							end

							dxDrawText(text, startX + 25 + 10, startY + (i-1) * oneSize, startX - 10  + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "right", "center", false, false, false, true)
						else
							dxDrawText(adminSlots[slot][2], startX + 25, startY + (i-1) * oneSize, startX + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "center", "center", false, false, false, true)
						end
					end
				end

				startX = startX + oneSegmentSize - 50/3

				for i=1, tabNum do
					local rowColor = tocolor(0, 0, 0, 150 * alpha)
					local textColor = tocolor(255, 150, 0)
					local slot = i + tabNum * 2
					local font = OpenSansB
					local scale = 0.65

					if i % 2 ~= 0 then
						rowColor = tocolor(0, 0, 0, 100 * alpha)
					end

					if adminSlots[slot] then
						if adminSlots[slot][1] == "title" then
							rowColor = tocolor(0, 0, 0)
							textColor = tocolor(124, 197, 118, 255 * alpha)

							font = OpenSansEB
							scale = 0.35
						else
							if adminSlots[slot][1] == "admin" then
								font = OpenSans

								textColor = tocolor(255, 255, 255, 255 * alpha)
							end
						end
					end

					dxDrawRectangle(startX + 25, startY + (i-1) * oneSize, oneSegmentSize - 50/3, oneSize, rowColor)

					if adminSlots[slot] then
						if adminSlots[slot][1] == "admin" then
							dxDrawText(adminSlots[slot][2], startX + 25 + 10, startY + (i-1) * oneSize, startX - 10 + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "left", "center", false, false, false, true)

							local text = "Szolgálatban: #d9534fnem"

							if adminSlots[slot][3] then
								text = "Szolgálatban: #7cc576igen"
							end

							dxDrawText(text, startX + 25 + 10, startY + (i-1) * oneSize, startX - 10  + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "right", "center", false, false, false, true)
						else
							dxDrawText(adminSlots[slot][2], startX + 25, startY + (i-1) * oneSize, startX + 25 + oneSegmentSize - 50/3, startY + (i-1) * oneSize + oneSize, textColor, scale, font, "center", "center", false, false, false, true)
						end
					end
				end

				dxDrawText('Az alábbi panelen a szerveren lévő adminokat/adminsegédeket láthatod. Amennyiben probléma van keress egy admint, aki szolgálatban van, majd a "/pm ID ÜZENETED" paranccsal tudsz írni nekik. Az adminisztrátor ID-jét ezen a panelen akkor látod, ha az adott online adminisztrátor szolgálatban van.', holderX + 25, startY + holderSizeY - 200, holderX + holderSizeX - 25, holderY + holderSizeY, tocolor(124, 197, 118, 255 * alpha), 0.9, OpenSans, "left", "center", false, true)
			elseif renderData.selectedTab == 5 then
				local startY = holderY + 75
				local tabNummer = 20

				dxDrawText("Petek", holderX, holderY, holderX + holderSizeX, holderY + 75, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)


				local oneSegmentSize = holderSizeX / 2
				local sizeForTabs = (holderY + holderSizeY) - startY - 25 - 150 - 25
				local oneSize = sizeForTabs / tabNummer
				startX = holderX+holderSizeX-485
				for i =1, tabNummer do
					if i % 2 ~= 0 then
						dxDrawRectangle(startX + 25, startY + (i-1) * 30, 430, 30, tocolor(0, 0, 0, 100 * alpha))
					else
						dxDrawRectangle(startX + 25, startY + (i-1) * 30, 430, 30, tocolor(0, 0, 0, 150 * alpha))
					end
					if i == selectedPets then
						dxDrawRectangle(startX + 25, startY + (i-1) * 30, 430, 30, tocolor(122,209,117, 255 * alpha))
					end
				end

				offsetPet = 0
				if selectedPets > tabNummer then
					offsetPet = math.ceil((selectedPets - tabNummer) / tabNummer) * 10
				end


				for i =1, tabNummer do
					local pets = playerPets[i + offsetPet]
					local colorOfText = tocolor(124, 197, 118, 255 * alpha)
					if #playerPets > 0 then
						if pets then
							if i + offsetPet == selectedPets then
								colorOfText = tocolor(0, 0, 0, 255 * alpha)
								if pets["spawned"] == 0 then
									dxDrawText("#" .. pets["id"] ..  " " .. pets["name"], startX + 25 + 10, startY + (i-1) * 30, startX + oneSegmentSize - 25 - 10, startY + (i-1) * 30+30, colorOfText, 0.7, OpenSansB, "left", "center")
								elseif pets["spawned"] == 1 then
									dxDrawText("#" .. pets["id"] ..  " " .. pets["name"] .. " (Aktív)", startX + 25 + 10, startY + (i-1) * 30, startX + oneSegmentSize - 25 - 10, startY + (i-1) * 30+30, colorOfText, 0.7, OpenSansB, "left", "center")
								end
								dxDrawText("Típus: " .. petNames[pets["type"]], startX + 25 + 10, startY + (i-1) * 30, startX + oneSegmentSize - 25 - 155, startY + (i-1) * 30+30, colorOfText, 0.7, OpenSansB, "right", "center")

								dxDrawText(pets["name"],holderX-holderSizeX/2+50, startY, holderX + holderSizeX+50, startY + 65, tocolor(124, 197, 118, 255 * alpha), 0.45, OpenSansEB, "center", "center", false, false, false, true)
								dxDrawImage(holderX+holderSizeX/2-230, startY, 371, 146, "files/dogs/"..pets["type"]..".png")
								dxDrawText("#FFFFFFID: #7cc576"..pets["id"],holderX+25, startY+50, 0, startY + 95+20, tocolor(124, 197, 118, 255 * alpha), 0.8, OpenSansB, "left", "center", false, false, false, true)
								dxDrawText("#FFFFFFTípus: #7cc576"..petNames[pets["type"]],holderX+25, startY+50+20, 0, startY + 95+20+30, tocolor(124, 197, 118, 255 * alpha), 0.8, OpenSansB, "left", "center", false, false, false, true)
								dxDrawText("#FFFFFFÉlet: #7cc576"..pets["health"].."%",holderX+25, startY+50+40, 0, startY + 95+20+60, tocolor(124, 197, 118, 255 * alpha), 0.8, OpenSansB, "left", "center", false, false, false, true)
								dxDrawText("#FFFFFFÉhség: #7cc576"..pets["food"].."%",holderX+25, startY+95+60+85-40, 0, startY + 95+20+90, tocolor(124, 197, 118, 255 * alpha), 0.8, OpenSansB, "left", "top", false, false, false, true)
								dxDrawText("#FFFFFFSzeretet: #7cc576"..pets["love"].."%",holderX+25, startY+95+60+85+40, 0, startY + 95+20+90, tocolor(124, 197, 118, 255 * alpha), 0.8, OpenSansB, "left", "top", false, false, false, true)
								dxDrawText("#FFFFFFElkölthető prémiumpontok: #7cc576"..(premiumPoints or 0).." PP",holderX+25, startY+95+60+85+80+40, 0, startY + 95+20+90, tocolor(124, 197, 118, 255 * alpha), 0.8, OpenSansB, "left", "top", false, false, false, true)


								hpCounter = 7.4*pets["health"]
								hungerCounter = 7.4*pets["food"]
								loveCounter = 7.4*pets["love"]
								dxDrawRectangle(holderX+25,startY+95+60, hpCounter,30, tocolor(122,209,117,255))
								dxDrawRectangle(holderX+25,startY+95+60+80, hungerCounter,30, tocolor(83,145,227,255))
								dxDrawRectangle(holderX+25,startY+95+60+80+80, loveCounter,30, tocolor(217, 83, 79,255))
								atvPetID = pets["id"]
								atvSpawned = pets["spawned"]
								atvHealth = pets["health"]
								if activeButton == "spawn_pet" then
									triggerServerEvent("requestDatas", localPlayer, datas["gameaccountid"],  datas["dbid"])
									if pets["spawned"] == 0 then
										dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30-40, 740, 30, tocolor(124, 197, 118, 255 * alpha))
									elseif pets["spawned"] == 1 then
										dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30-40, 740, 30, tocolor(217, 83, 79, 255 * alpha))
									end
								else
									dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30-40, 740, 30, tocolor(255, 150, 0, 255 * alpha))
								end
								buttons["spawn_pet"] = {holderX+25, startY+(tabNummer-1)*30-40, holderX+25+740, startY+(tabNummer-1)*30-40+30}

								if pets["spawned"] == 0 then
									dxDrawText("Spawn", holderX+25, startY+(tabNummer-1)*30-40, holderX+765, startY+(tabNummer-1)*30+30-40, tocolor(0, 0, 0, 255 * alpha), 0.7, OpenSansB, "center", "center", false, false, false, true)
								elseif pets["spawned"] == 1 then
									dxDrawText("Despawn", holderX+25, startY+(tabNummer-1)*30-40, holderX+765, startY+(tabNummer-1)*30+30-40, tocolor(0, 0, 0, 255 * alpha), 0.7, OpenSansB, "center", "center", false, false, false, true)
								end

								if activeButton == "respawn_pet" then
									dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30-80, 740, 30, tocolor(124, 197, 118, 255 * alpha))
								else
									dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30-80, 740, 30, tocolor(255, 150, 0, 255 * alpha))
								end
								buttons["respawn_pet"] = {holderX+25, startY+(tabNummer-1)*30-80, holderX+25+740, startY+(tabNummer-1)*30-80+30}
								dxDrawText("Felélesztés", holderX+25, startY+(tabNummer-1)*30-80, holderX+765, startY+(tabNummer-1)*30+30-80, tocolor(0, 0, 0, 255 * alpha), 0.7, OpenSansB, "center", "center", false, false, false, true)

								if activeButton == "sell_pet" then
									dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30-120, 740, 30, tocolor(124, 197, 118, 255 * alpha))
								else
									dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30-120, 740, 30, tocolor(255, 150, 0, 255 * alpha))
								end
								buttons["sell_pet"] = {holderX+25, startY+(tabNummer-1)*30-120, holderX+25+740, startY+(tabNummer-1)*30-120+30}
								dxDrawText("Eladás", holderX+25, startY+(tabNummer-1)*30-120, holderX+765, startY+(tabNummer-1)*30+30-120, tocolor(0, 0, 0, 255 * alpha), 0.7, OpenSansB, "center", "center", false, false, false, true)

							else
								dxDrawText("#" .. pets["id"] ..  " " .. pets["name"], startX + 25 + 10, startY + (i-1) * 30, startX + oneSegmentSize - 25 - 10, startY + (i-1) * 30+30, colorOfText, 0.75, OpenSansB, "left", "center")
							--	dxDrawText("#" .. pets["id"] ..  " #4aabd0" .. pets["name"], startX + 25 + 10, startY + (i-1) * oneSize, startX + oneSegmentSize - 25 - 10, startY + (i-1) * oneSize + oneSize, colorOfText, 0.75, OpenSansB, "left", "center", false, false, false, true)
							end
						end
					else
						dxDrawText("Nincs kiválasztva pet.", holderX-holderSizeX/2+50, startY, holderX + holderSizeX+90, startY + 65, tocolor(255, 150, 0, 255 * alpha), 0.8, OpenSansPET, "center", "center", false, false, false, true)
					end
				end


				if activeButton == "buy_pet" then
					dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30, 740, 30, tocolor(124, 197, 118, 255 * alpha))
				else
					dxDrawRectangle(holderX+25, startY+(tabNummer-1)*30, 740, 30, tocolor(255, 150, 0, 255 * alpha))
				end
				buttons["buy_pet"] = {holderX+25, startY+(tabNummer-1)*30, holderX+25+740, startY+(tabNummer-1)*30+30}
				dxDrawText("Pet vásárlása", holderX+25, startY+(tabNummer-1)*30, holderX+765, startY+(tabNummer-1)*30+30, tocolor(0, 0, 0, 255 * alpha), 0.7, OpenSansB, "center", "center", false, false, false, true)

				--outputChatBox(#playerPets)

			elseif renderData.selectedTab == 6 then --shaderek
				dxDrawText("Shaderek", holderX, holderY, holderX + holderSizeX, holderY + 75, tocolor(124, 197, 118, 255 * alpha), 0.75, OpenSansEB, "center", "center", false, false, false, true)

				startY = holderY + 75
				startX = holderX

				for k, v in pairs(renderData.shaders) do
					local text = "Bekapcsolás"

					if v[2] then
						text = "Kikapcsolás"
					end

					local w, startYN = 0, 0

					startYN, w = dxDrawDataRow(startX + 25, startY, 50, v[1], "", 1)

					if w > renderData.longestW then
						renderData.longestW = w
					end

					if not v[2] then
						dxDrawRectangle(startX + 25 + renderData.longestW + 25, startY + 10, 200, 50 - 20, tocolor(124, 197, 118, 255 * alpha))
					else
						dxDrawRectangle(startX + 25 + renderData.longestW + 25, startY + 10, 200, 50 - 20, tocolor(217, 83, 79, 255 * alpha))
					end

					buttons["shader_" .. v[3] .. "_" .. k] = {startX + 25 + renderData.longestW + 25, startY + 10, startX + 25 + renderData.longestW + 25 + 200, startY + 10 + 50 - 20}

					local font = OpenSans

					if activeButton == "shader_" .. v[3] .. "_" .. k then
						font = OpenSansB
					end

					dxDrawText(text, startX + 25 + renderData.longestW + 25, startY + 10, startX + 25 + renderData.longestW + 25 + 200, startY + 10 + 50 - 20, tocolor(0, 0, 0, 255 * alpha), 0.8, font, "center", "center", false, false, false, true)

					startY = startYN
				end

			--	dxDrawText("A Shaderek ezen esetben a grafika - vizuális megjelenítés fokozását szolgálják.\nSzabd teljesen személyre a grafikát - megjelenést!\nBármelyik shader-t - opciót, bármikor ki-és be tudod kapcsolni!\nAmennyiben a zöld BEKAPCSOLÁS gombra kattintunk, a shader - opció üzembe lép.\nKikapcsolásához kattintsunk a piros KIKAPCSOLÁS gombra.", startX + 25 + renderData.longestW + 25 * 2 + 200, holderY + 75, holderX + holderSizeX - 25, startY, tocolor(124, 197, 118, 255 * alpha), 0.9, OpenSans, "left", "center", false, true)
			end

			local cx, cy = getCursorPosition()

			if tonumber(cx) and tonumber(cy) then
				cx, cy = cx * screenX, cy * screenY

				activeButton = false

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[3] and cy >= v[2] and cy <= v[4] then
						activeButton = k
					end
				end
			else
				activeButton = false
			end
		end
	end)


function tableFind(table, find)
	for k, v in pairs(table) do
		if v == find then
			return k
		end
	end

	return false
end

addEventHandler('onClientElementDataChange', getRootElement(),
	function(data)
		if source == localPlayer and monitoredDatas[data] then
			datas[data] = getElementData(localPlayer, data)
		end

		if getElementType(source) == "vehicle" then
			local key = tableFind(playerVehicles, source)
			if tonumber(key) and monitoredDatasForVehilce[data] then
				if getElementData(source, "owner") == datas["dbid"] or monitoredGroupVeh[source] then
					if not vehicleDatas[source] then
						vehicleDatas[source] = {}
					end

					vehicleDatas[source][data] = getElementData(source, data)
				else
					playerVehicles[key] = nil
				end
			end
		end
	end)

addEvent("setErrorMessage", true )
addEventHandler("setErrorMessage", getRootElement(),
	function (msg)
		errorToDisplay = 1
		invitingErrorText = msg
		playDashboardSound("sounds/notification")
	end)

addEvent("buySlotNoPP", true )
addEventHandler("buySlotNoPP", getRootElement(),
	function (msg)
		renderData.buySlotNoPP = true
		renderData.buySlotProcessing = false
		playDashboardSound("sounds/notification")
	end)

addEvent("buySlotNoPP", true )
addEventHandler("buySlotNoPP", getRootElement(),
	function (msg)
		renderData.respawnPetNoPP = true
		renderData.respawnProcessing = false
		playDashboardSound("sounds/notification")
end)

	addEvent("buyPetNoPP", true )
	addEventHandler("buyPetNoPP", getRootElement(),
		function (msg)
			renderData.buyPetNoPP = true
			renderData.buyPetProcessing = false
			playDashboardSound("sounds/notification")
		end)

addEvent("respawnPetOK", true )
addEventHandler("respawnPetOK", getRootElement(),
	function (msg)
		renderData.respawnPet = false
		renderData.respawnProcessing = false
		invitingText = ""
		buttons = {}
		activeButton = ""
		toggleDashboard()
end)

addEvent("buySlotOK", true )
addEventHandler("buySlotOK", getRootElement(),
	function (msg)
		renderData.buyingVehicleSlot = false
		invitingText = ""
		buttons = {}
		activeButton = ""
	end)

	addEvent("buyPetOK", true )
	addEventHandler("buyPetOK", getRootElement(),
		function (msg)
			renderData.buyingPetName = false
			invitingText = ""
			buttons = {}
			activeButton = ""
			toggleDashboard()
		end)

addEventHandler("onClientClick", getRootElement(),
	function(button, state)
		if button == "left" and state == "up" then
			if activeButton and renderData.buyingVehicleSlot then
				local soundAlreadyPlayed = false

				if activeButton == "cancel_veh_slot" then
					renderData.buyingVehicleSlot = false
					invitingText = ""
					buttons = {}
					activeButton = ""
					soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
				elseif activeButton == "buy_veh_slot" then
					invitingText = tonumber(invitingText)
					triggerServerEvent("buyVehSlot", localPlayer, invitingText)

					renderData.buySlotProcessing = true
					renderData.buySlotNoPP = false

					soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
				end
			elseif activeButton and renderData.respawnPet then
				if activeButton == "cancel_respawn_pet" then
					renderData.respawnPet = false
					buttons = {}
					activeButton = ""
					soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
				elseif activeButton == "respawn_pet_accept" then
					if atvHealth == 0 then
						triggerServerEvent("respawnPet", localPlayer, atvPetID)
						renderData.respawnProcessing = true
						renderData.respawnNoPP = false
					else
						exports.sas_hud:addNotification("Ez a kutya nem halott!", "error")
					end
				end
			elseif activeButton and renderData.buyingPet then
				local soundAlreadyPlayed = false

				if activeButton == "cancel_buying_pet" then
					renderData.buyingPet = false
					invitingText = ""
					buttons = {}
					activeButton = ""
					soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
				end
				for i=1, 6 do
					if activeButton == "pet_" .. i then
						wantToBuyPetNum = i
						renderData.buyingPet = false
						renderData.buyingPetName = true
						invitingText = ""
						buttons = {}
						activeButton = ""
						soundAlreadyPlayed = playDashboardSound("sounds/prompt")
					end
				end
			elseif activeButton and renderData.buyingPetName then
				if activeButton == "buy_pet" then
					if string.len(invitingText) < 15 and string.len(invitingText) >= 2 then
						triggerServerEvent("buyPet", localPlayer, invitingText, wantToBuyPetNum)

						renderData.buyPetProcessing = true
						renderData.buyPetNoPP = false

						soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
					else
						exports.sas_hud:addNotification("A kutya nevének 2 és 15 karakter közé kell esnie.", "error")
					end
				elseif activeButton == "cancel_entering_petname" then
					renderData.buyingPet = false
					renderData.buyingPetName = false
					invitingText = ""
					buttons = {}
					activeButton = ""
					soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
				end

			elseif activeButton and selectedGroup and not renderData.buyingVehicleSlot and not renderData.buyingPet and not renderData.buyingPetName and not renderData.respawnPet then
				local groupId = playerGroups[selectedGroup]
				local soundAlreadyPlayed = false

				if activeButton == "button_more_vehslot" then
					renderData.buyingVehicleSlot = true
					invitingText = ""
					buttons = {}
					activeButton = ""
					renderData.buySlotNoPP = false
					renderData.buySlotProcessing = false
					soundAlreadyPlayed = playDashboardSound("sounds/prompt")
				elseif activeButton == "buy_pet" then
					renderData.buyingPet = true
					invitingText = ""
					buttons = {}
					activeButton = ""
					soundAlreadyPlayed = playDashboardSound("sounds/prompt")
				elseif activeButton == "respawn_pet" then
				--	if atvHealth == 0 then
						renderData.respawnPet = true
						invitingText = ""
						buttons = {}
						activeButton = ""
						soundAlreadyPlayed = playDashboardSound("sounds/prompt")
					--else
						--exports.sas_hud:addNotification("Ez a kutya nem halott!", "error")
					--end
				elseif activeButton == "group_ok" then
					invitingErrorText = ""
					soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
				elseif activeButton == "cancelFire" then
					invitingErrorText = ""
					soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					renderData.memberFireAccept = false
				elseif activeButton == "fireMember" then
					invitingErrorText = ""
					renderData.memberFireAccept = false
					soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
					local thisMembers = groupMembers[groupId]
					local member = thisMembers[selectedMember]

					if member and meInGroup[groupId]["isLeader"] == 1 then
						triggerServerEvent("deletePlayerFromGroup", localPlayer, member["id"], groupId, member["online"], playerGroups)
					end
				elseif activeButton == "setDutySkin" then
					toggleDutySkinSelect(true)
				elseif activeButton == "group_invite" and meInGroup[groupId]["isLeader"] == 1 then
					invitingInProcess = false


					if string.len(invitingText) < 1 then
						invitingErrorText = "#d9534fNem hagyhatod üresen a mezőt!"
					else
						local found = false
						local multipleFounds = false
						local invitingText = string.lower(string.gsub(invitingText, " ", "_"))

						for k, v in ipairs(getElementsByType("player")) do
							if getElementData(v, "loggedin") then
								local id = getElementData(v, "playerid")
								local name = string.lower(getElementData(v, "visibleName"):gsub(" ", "_"))

								if id == tonumber(invitingText) or string.find(name, invitingText) then
									if found then
										found = false
										multipleFounds = true
										break
									else
										found = v
									end
								end
							end
						end

						if multipleFounds then
							invitingErrorText = "#d9534fTöbb találat!"
							soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
						elseif isElement(found) then
							local name = getElementData(found, "visibleName")
							invitingErrorText = "#7cc576" .. name:gsub("_", " ") .. " felvétele sikeres!"

							triggerServerEvent("invitePlayer", localPlayer, getElementData(found, "dbid"), groupId, found, playerGroups)
							soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
						else
							invitingErrorText = "#d9534fNincs találat!"
							soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
						end
					end

					invitingText = ""
				elseif activeButton == "group_rank_rename" and meInGroup[groupId]["isLeader"] == 1 and rankRenamingInProcess then
					rankRenamingInProcess = false
					payManagingInProcess = false

					errorToDisplay = 0

					if string.len(invitingText) < 1 then
						invitingErrorText = "#d9534fNem hagyhatod üresen a mezőt!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					else
						invitingErrorText = "#7cc576Sikeresen átnevezve!"
						triggerServerEvent("renameRank", localPlayer, selectedRank, invitingText, groupId)
						soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
					end

					invitingText = ""
				elseif activeButton == "group_description_rewrite" and meInGroup[groupId]["isLeader"] == 1 and groupManaging[2] then
					groupManaging[2] = false

					errorToDisplay = 0

					invitingErrorText = "#7cc576Sikeresen átírva!"

					groups[groupId]["description"] = invitingText

					triggerServerEvent("rewriteDescription", localPlayer, invitingText, groupId)

					invitingText = ""

					soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
				elseif activeButton == "group_rank_rename" and meInGroup[groupId]["isLeader"] == 1 and payManagingInProcess then
					rankRenamingInProcess = false
					payManagingInProcess = false

					errorToDisplay = 1

					if string.len(invitingText) < 1 then
						invitingErrorText = "#d9534fNem hagyhatod üresen a mezőt!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					elseif not tonumber(invitingText) then
						invitingErrorText = "#d9534fEz nem szám!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					elseif string.find(invitingText, "e") then
						invitingErrorText = "#d9534fEz nem szám!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					elseif tonumber(invitingText) < 0 then
						invitingErrorText = "#d9534fMinuszba?!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					elseif tonumber(invitingText) > 10000000 then
						invitingErrorText = "#d9534fSok lesz ez!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					else
						invitingErrorText = "#7cc576Sikeresen átállítva!"
						triggerServerEvent("setRankPayment", localPlayer, selectedRank, math.floor(tonumber(invitingText)), groupId)
						soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
					end

					invitingText = ""
				elseif activeButton == "group_3" then
					invitingInProcess = true
					soundAlreadyPlayed = playDashboardSound("sounds/prompt")
				elseif activeButton == "group2_0" then
					rankRenamingInProcess = true
					payManagingInProcess = false

					invitingText = groups[groupId]["rank_" .. selectedRank]
					soundAlreadyPlayed = playDashboardSound("sounds/prompt")
				elseif activeButton == "group2_1" then
					payManagingInProcess = true
					rankRenamingInProcess = false

					invitingText = groups[groupId]["rank_" .. selectedRank .. "_pay"]
					soundAlreadyPlayed = playDashboardSound("sounds/prompt")
				elseif activeButton == "putBack" or activeButton == "getOut" then
					groupManaging[1] = false
					errorToDisplay = 1

					if not isElementWithinColShape(localPlayer, bankCol) then
						invitingErrorText = "#d9534fNem vagy bankban!"
						playDashboardSound("sounds/promptdecline")
						return
					end

					if string.len(invitingText) < 1 then
						invitingErrorText = "#d9534fNem hagyhatod üresen a mezőt!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					elseif not tonumber(invitingText) then
						invitingErrorText = "#d9534fEz nem szám!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					elseif string.find(invitingText, "e") then
						invitingErrorText = "#d9534fEz nem szám!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					elseif tonumber(invitingText) < 1000 then
						invitingErrorText = "#d9534fMinimum 1000$-t kezelhetsz!"
						soundAlreadyPlayed = playDashboardSound("sounds/promptdecline")
					else
						invitingText = math.floor(tonumber(invitingText))

						if activeButton == "getOut" then
							invitingText = -invitingText
						end

						invitingErrorText = "#7cc576Feldolgozás..."
						triggerServerEvent("setBalance", localPlayer, invitingText, groupId)
						soundAlreadyPlayed = playDashboardSound("sounds/promptaccept")
					end
				elseif activeButton == "group3_0" then
					groupManaging[1] = false
					groupManaging[2] = true

					invitingText = groups[groupId]["description"]

					soundAlreadyPlayed = playDashboardSound("sounds/prompt")
				elseif activeButton == "group3_1" then
					groupManaging[1] = true
					groupManaging[2] = false

					invitingText = 0
					soundAlreadyPlayed = playDashboardSound("sounds/prompt")
				elseif string.find(activeButton, "shader") then
					local shader = split(activeButton, "_")

					local key = tonumber(shader[3])

					local state = renderData.shaders[key][2]

					renderData.shaders[key][2] = not state

					exports.sas_shaders:setShaderEnabled(shader[2], renderData.shaders[key][2])
				elseif string.find(activeButton, "group_select") then
					if not(invitingInProcess or rankRenamingInProcess or payManagingInProcess or groupManaging[2] or groupManaging[1]) then
						if string.find(activeButton, "group_select|") then
							local selected = split(activeButton, "|")

							selectedGroup = tonumber(selected[2])
							selectedGroupTab = 1
							selectedGroupSection = 1
						elseif string.find(activeButton, "group_select.member|") then
							local selected = split(activeButton, "|")

							selectedMember = tonumber(selected[2])
							selectedGroupSection = 2
						elseif string.find(activeButton, "group_select.rank|") then
							local selected = split(activeButton, "|")

							selectedRank = tonumber(selected[2])
							selectedGroupSection = 2
						elseif string.find(activeButton, "group_select.vehicle|") then
							local selected = split(activeButton, "|")

							selectedGroupVeh = tonumber(selected[2])
							selectedGroupSection = 2
						elseif string.find(activeButton, "group_select.groupTabs|") then
							local selected = split(activeButton, "|")

							selectedGroupTab = tonumber(selected[2])
							selectedGroupSection = 2
						end
					end
				elseif string.find(activeButton, "selectVehicle|") then
					local selected = split(activeButton, "|")

					selectedVeh = tonumber(selected[2])
					selectedDollarTab = 1
				elseif string.find(activeButton, "selectInterior|") then
					local selected = split(activeButton, "|")

					selectedInt = tonumber(selected[2])
					selectedDollarTab = 2
				elseif string.find(activeButton, "selectTab|") then
					local selected = split(activeButton, "|")

					closeAnimation[renderData.selectedTab] = getTickCount()
					renderData.selectedTab = tonumber(selected[2])
					openAnimation[renderData.selectedTab] = getTickCount()

					if renderData.selectedTab == 4 then
						getAdmins()
					end

					if renderData.selectedTab == 3 then
						fetchGroups()
						triggerServerEvent("requestGroups", localPlayer)
					end

					invitingInProcess = false
					rankRenamingInProcess = false
					payManagingInProcess = false
					groupManaging[2] = false
					groupManaging[1] = false

					invitingErrorText = ""

					invitingText = ""
				--elseif activeButton and renderData.selectedTab then

					soundAlreadyPlayed = playDashboardSound("sounds/tabswitch")
				elseif activeButton and renderData.selectedTab == 5 then
						--	triggerServerEvent("requestDatas", localPlayer, datas["gameaccountid"],  datas["dbid"])
							if activeButton == "spawn_pet" then
								for k, v in pairs(monitoredDatas) do
									datas[k] = getElementData(localPlayer, k)
								end
								triggerServerEvent("requestDatas", localPlayer, datas["gameaccountid"],  datas["dbid"])
								if atvSpawned == 0 then
									triggerServerEvent("spawnPet", localPlayer, atvPetID)
												outputChatBox("spawned")
								elseif atvSpawned == 1 then
									triggerServerEvent("despawnPet", localPlayer, atvPetID)
								end
								for k, v in pairs(monitoredDatas) do
									datas[k] = getElementData(localPlayer, k)
								end
								triggerServerEvent("requestDatas", localPlayer, datas["gameaccountid"],  datas["dbid"])
							end
				else
					local thisMembers = groupMembers[groupId]
					local member = thisMembers[selectedMember]

					if member and meInGroup[groupId]["isLeader"] == 1 then
						if activeButton == "group_0" then
							triggerServerEvent("modifyRankForPlayer", localPlayer, member["id"], member["rank"], groupId, "up", member["online"], playerGroups)
						elseif activeButton == "group_1" then
							triggerServerEvent("modifyRankForPlayer", localPlayer, member["id"], member["rank"], groupId, "down", member["online"], playerGroups)
						elseif activeButton == "group_2" then
							renderData.memberFireAccept = true
							invitingErrorText = "#d9534fTényleg ki szeretnéd rúgni?"
							--triggerServerEvent("deletePlayerFromGroup", localPlayer, member["id"], groupId, member["online"], playerGroups)
							soundAlreadyPlayed = playDashboardSound("sounds/prompt")
						end
					end
				end

				if not string.find(activeButton, "selectTab|") then
					playDashboardSound("sounds/switchoption")
				end
			end
		end
	end)

addEventHandler('onClientCharacter', getRootElement(),
	function(character)
		if (invitingInProcess or rankRenamingInProcess or payManagingInProcess or groupManaging[2] or groupManaging[1] or renderData.buyingPetName) then
			if (string.len(invitingText) <= 20) then
				invitingText = invitingText .. character
			end
		end

		if renderData.buyingVehicleSlot then
			local newText = invitingText .. character

			if tonumber(newText) then
				if tonumber(newText) >= 1 and not string.find(newText, "e") and tonumber(newText) <= 1000 then
					invitingText = newText
				end
			end
		end
	end)

addEventHandler('onClientKey', getRootElement(),
	function(button, state)
		if state and button == "home" and not renderData.buyingVehicleSlot and not renderData.buyingPet and not renderData.buyingPetName then
			if getElementData(localPlayer, "loggedin") then
				toggleDashboard()
			end
			cancelEvent()
		end

		if state and button == "F3" and not renderData.buyingVehicleSlot and not renderData.buyingPet and not renderData.buyingPetName and not renderData.respawnPet then
			if getElementData(localPlayer, "loggedin") then
				if active and renderData.selectedTab == 3 then
					toggleDashboard()
				else
					if active then
						closeAnimation[renderData.selectedTab] = getTickCount()
						openAnimation[3] = getTickCount()
					end
					renderData.selectedTab = 3
				end

				if not active then
					toggleDashboard()
				end
			end
			cancelEvent()
		end

		if state and button == "backspace" and (invitingInProcess or rankRenamingInProcess or payManagingInProcess or groupManaging[2] or groupManaging[1] or renderData.buyingVehicleSlot or renderData.buyingPet or renderData.buyingPetName) then
			if string.len(invitingText) >= 1 then
				invitingText = string.sub(invitingText, 1, string.len(invitingText)-1)
			end
		end

		if renderData.buyingVehicleSlot or renderData.buyingPet or renderData.buyingPetName then
			cancelEvent()
		end

		if state and active and not renderData.buyingVehicleSlot and not renderData.buyingPet and not renderData.buyingPetName then
			cancelEvent()

			if button =="pgup" or button == "pgdn" then
				closeAnimation[renderData.selectedTab] = getTickCount()

				playDashboardSound("sounds/tabswitch")

				invitingInProcess = false
				rankRenamingInProcess = false
				payManagingInProcess = false
				groupManaging[2] = false
				groupManaging[1] = false

				invitingErrorText = ""

				invitingText = ""

				if button =="pgup" then
					renderData.selectedTab = renderData.selectedTab - 1

					if renderData.selectedTab < 0 then
						renderData.selectedTab = 6
					end
					--playDashboardSound("sounds/tabswitch")
				elseif button =="pgdn" then
					renderData.selectedTab = renderData.selectedTab + 1

					if renderData.selectedTab > 6 then
						renderData.selectedTab = 0
					end
					--playDashboardSound("sounds/tabswitch")
				end

				if renderData.selectedTab == 4 then
					getAdmins()
				end

				if renderData.selectedTab == 3 then
					fetchGroups()
					triggerServerEvent("requestGroups", localPlayer)
				end

				openAnimation[renderData.selectedTab] = getTickCount()
				cancelEvent()
			end

			if renderData.selectedTab == 1 then -- vagyon
				if button == "arrow_l" then
					selectedDollarTab = 1
					playDashboardSound("sounds/switchoption")
					cancelEvent()
				elseif button == "arrow_r" then
					selectedDollarTab = 2
					playDashboardSound("sounds/switchoption")
					cancelEvent()
				elseif button == "arrow_u" or button == "arrow_d" then
					local count = 0

					if selectedDollarTab == 1 then
						count = selectedVeh
					else
						count = selectedInt
					end

				--	local maxThings = #playerInteriors

					if selectedDollarTab == 1 then
						maxThings = #playerVehicles
					else
						maxThings = #playerInteriors
					end

					if button == "arrow_u" and active then
						if count > 1 then
							count = count - 1
						end
						cancelEvent()
					elseif button == "arrow_d" and active then
						if count < maxThings then
							count = count + 1
						end
						cancelEvent()
					end

					if selectedDollarTab == 1 then
						selectedVeh = count
					else
						selectedInt = count
					end

					playDashboardSound("sounds/switchoption")
				end
			elseif renderData.selectedTab == 5 then
				local count = 0
				if button == "arrow_u" or button == "arrow_d" then
					if button == "arrow_u" and active then
						if selectedPets > 1 then
							selectedPets = selectedPets - 1
						end
						cancelEvent()
					elseif button == "arrow_d" and active then
						if selectedPets < #playerPets then
							selectedPets = selectedPets + 1
						end
						cancelEvent()
					end


					playDashboardSound("sounds/switchoption")
				end
			elseif renderData.selectedTab == 3 and not (invitingInProcess or rankRenamingInProcess or payManagingInProcess or groupManaging[2] or groupManaging[1]) then -- frakik
				if button == "arrow_l" then
					if selectedGroupTab-1 < 1 then
						selectedGroupSection = 1
					else
						selectedGroupTab = selectedGroupTab - 1
					end

					cancelEvent()
					playDashboardSound("sounds/switchoption")
				elseif button == "arrow_r" then
					if selectedGroupSection == 1 then
						selectedGroupSection = 2
					else
						if selectedGroupTab+1 <= 4 then
							selectedGroupTab = selectedGroupTab + 1
						end
					end

					cancelEvent()
					playDashboardSound("sounds/switchoption")
				elseif button == "arrow_u" or button == "arrow_d" and not rankRenamingInProcess and not payManagingInProcess then
					local count = 0

					local resetSelectedMember = false

					if selectedGroupSection == 1 then
						count = selectedGroup
						resetSelectedMember = true
					elseif selectedGroupTab == 1 then
						count = selectedMember
					elseif selectedGroupTab == 2 then
						count = selectedRank
					elseif selectedGroupTab == 3 then
						count = selectedGroupVeh
					end

					local maxThings = #playerGroups

					if selectedGroupSection == 2 and selectedGroupTab == 1 then
						maxThings = #groupMembers[playerGroups[selectedGroup]]
					elseif selectedGroupSection == 2 and selectedGroupTab == 2 then
						maxThings = 15
					elseif selectedGroupSection == 2 and selectedGroupTab == 3 then
						maxThings = #groupVehicles[playerGroups[selectedGroup]]
					end

					if button == "arrow_u" and active then
						if count > 1 then
							count = count - 1
						end
						cancelEvent()
					elseif button == "arrow_d" and active then
						if count < maxThings then
							count = count + 1
						end
						cancelEvent()
					end

					if selectedGroupSection == 1 then
						selectedGroup = count
					elseif selectedGroupTab == 1 then
						selectedMember = count
					elseif selectedGroupTab == 2 then
						selectedRank = count
					elseif selectedGroupTab == 3 then
						selectedGroupVeh = count
					end
					playDashboardSound("sounds/switchoption")
				end
			end
		end
	end)

addCommandHandler("admins",
	function ()
		if getElementData(localPlayer, "loggedin") then
			if active and renderData.selectedTab == 4 then
				toggleDashboard()
			else
				if active then
					closeAnimation[renderData.selectedTab] = getTickCount()
					openAnimation[4] = getTickCount()
				end
				renderData.selectedTab = 4
			end

			if not active then
				toggleDashboard()
			end
		end
	end)

--dutySkin


local x, y, z = 0, 0, 0
local interior = 0
local dimension = 0
local dutySkinSelectState = false
local currentSkin = 0
local skin = 1

local groupSkins = {
	[1] = {71,288,280,281,282,284,60,283}, -- SCPD
	[12] = {163,164,165,166,10}, -- NNI
	[22] = {57,96,154,199,2,13,15}, -- HellsAngels
	[16] = {170,171,172,176,177,179,180}, -- M-18
	[10] = {173,174,175,116,138,139,140}, -- Mara Salvatrucha
	[6] = {102,103,104,20,7,182,80,83,84}, -- Bloods
	[2] = {274,275,276,90}, -- SCMD
	[3] = {62,66,187,229,230,228}, -- Önkormányzat
	[18] = {108, 109, 110, 30, 44, 35, 36}, -- Las Surenos 13
	[11] = {270,269,271,195,107,106,105,82,81,78}, -- Crips
	[4] = {24,29,31,33,49,50,54,55}, -- Serbian
	[5] = {20}, -- Riporter
	[8] = {128, 131, 133, 114, 115, 184, 52}, -- russian
	[7] = {277,278,279}, -- Tűzoltóság
	[9] = {58,202,122,38,39,40,70}, -- LCN
	[15] = {50, 227}, -- Szerelő
	[17] = {212,213,214,215,217,218,219,216}, -- BPL
	[13] = {265, 287, 191}, -- NAV
	[21] = {113,32,59,16}, -- Katonaság
	[20] = {158,159,161,162,200,150,34}, -- Hickeys
	[23] = {124,241,240,126,125,259,46}, -- TVH
	[14] = {146,210,118,290,14,17,18}, -- Triad
	[25] = {120,186,123,121,117,220,132}, -- Losmonte
	[26] = {285}, -- TEK
	[29] = {67,136,143,222,142,53,56}, -- Deutsche Maffia
	[30] = {19,23,41,48,63,64,69}, -- Ballas
	[31] = {72,75,77,88,89,97,98}, -- VLA
	[32] = {134,145,148,183,190,153,167}, -- Abu Nidal
	[35] = {196,197,205,207,209,224,225}, -- Orosz
	[36] = {237,238,239,243,244,245,251}, -- Sicilian
	[37] = {76,85,87,92,169,181,198}, -- Yaku
	[38] = {201,206,156,223,226,246,247}, -- LCNUJ
}

function toggleDutySkinSelect(state)
	if dutySkinSelectState ~= state then
		active = not state

		if state == true then
			x, y, z = getElementPosition(localPlayer)
			interior = getElementInterior(localPlayer)
			dimension = getElementDimension(localPlayer)
			skin = getElementModel(localPlayer)

			local dimension2 = 65000 + getElementData(localPlayer, "gameaccountid")
			setElementDimension(localPlayer, dimension2)
			setElementInterior(localPlayer, 0)
			setElementPosition(localPlayer, 2373.1181640625, 972.830078125, 18.318904876709)
			setPedRotation(localPlayer, 0)
			toggleAllControls(false, true, false)
			setCameraMatrix(2373.0029296875, 976.880859375, 18.318904876709, 2373.1181640625, 972.830078125, 18.318904876709)
			bindKey("arrow_r", "up", nextSkin)
			bindKey("arrow_l", "up", previousSkin)
			bindKey("enter", "up", processDutySkinSelection)
			dutySkinSelectState = true
		elseif state == false then
			setCameraTarget(localPlayer)
			setElementPosition(localPlayer, x, y, z)
			setElementInterior(localPlayer, interior)
			setElementDimension(localPlayer, dimension)
			unbindKey("arrow_r", "up", nextSkin)
			unbindKey("arrow_l", "up", previousSkin)
			unbindKey("enter", "up", processDutySkinSelection)
			toggleAllControls(true, true, true)
			dutySkinSelectState = false
		end
	end
end
local selectedSkin = 0
function nextSkin()
	local groupId = playerGroups[selectedGroup]
	for k,v in pairs(groupSkins) do
		if tonumber(k) == tonumber(groupId) then
			if currentSkin + 1 <= #v then
				currentSkin = currentSkin + 1
				setElementModel(localPlayer, v[currentSkin])
				selectedSkin = v[currentSkin]
			end
		end
	end
end

function previousSkin()
	local groupId = playerGroups[selectedGroup]
	for k,v in pairs(groupSkins) do
		if k == groupId then
			if currentSkin - 1 >= 1 then
				currentSkin = currentSkin - 1
				setElementModel(localPlayer, v[currentSkin])
				selectedSkin = v[currentSkin]
			end
		end
	end
end

function processDutySkinSelection()
	local groupId = playerGroups[selectedGroup]
	if groups[groupId]["type1"] == 2 then
		if groups[groupId]["type2"] == 5 or groups[groupId]["type2"] == 6 then
			triggerServerEvent("updateDutySkin", localPlayer, groupId, selectedSkin)
			--triggerServerEvent("onUpdateModel", localPlayer, selectedSkin)
		else
			triggerServerEvent("updateDutySkin", localPlayer, groupId, selectedSkin)
			--triggerServerEvent("onUpdateModel", localPlayer, skin)
		end
	else
		triggerServerEvent("updateDutySkin", localPlayer, groupId, selectedSkin)
		--triggerServerEvent("onUpdateModel", localPlayer, skin)
	end
	toggleDutySkinSelect(false)
	exports.sas_infobox:showBox("info", "Sikeresen megváltoztattad a csoporthoz tartozó szolgálati öltözékedet.")
end

function playDashboardSound(string)
	playSound(string..".mp3")
end
