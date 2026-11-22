local pumps = {}
local pumps_marker = {}
local taroltPump = nil
local refillers = {}
local refiller_parents = {}
local refillers_lines = {}
local refillers_bounding = {}
local refill_pumps = {
	[1] = {
		pos = {x = 1941.2, y = -1773.37, z = 13.390598297119, rot = 360, newrot2 = 90, newrot3 = 0},
	},
	[2] = {
		pos = {x = 1941.2, y = -1779.11, z = 13.390598297119, rot = 360, newrot2 = 90,newrot3 = 0},
	},
	[3] = {
		pos = {x = 1941.2, y = -1767.56, z = 13.390598297119, rot = 360, newrot2 = 90,newrot3 = 0},
	},
	[4] = {
		pos = {x = 1940.55, y = -1767.56, z = 13.3828125, rot = 180, newrot2 = 90, newrot3 = 180},
	},
	[5] = {
		pos = {x = 1940.55, y = -1773.374, z = 13.3828125, rot = 180, newrot2 = 90, newrot3 = 180},
	},
	[6] = {
		pos = {x = 1940.55, y = -1779.11, z = 13.3828125, rot = 180, newrot2 = 90, newrot3 = 180},
	},
}

local refill_pumps2 = {
	[1] = {
		pos = {x = 1941.2, y = -1773.37, z = 13.390598297119, rot = 360, refiller_line_z_min = 0.12},
	},
	[2] = {
		pos = {x = 1941.568359375, y = -1779.09765625, z = 13.390598297119, rot = 90, refiller_line_z_min = -0.16},
	},
--	[3] = {
	--	pos = {x = 1001.5, y = -937.4, z = 41.54, rot = 8, refiller_line_z_min = -0.34},
--	},
--	[4] = {
--		pos = {x = 1006.5, y = -936.7, z = 41.54, rot = 188, refiller_line_z_min = -0.16},
--	},
}

function loadRefillers()
	for k, v in ipairs(refill_pumps) do
		refillers[k] = createObject(14463, v.pos.x, v.pos.y, v.pos.z, 0, 90, v.pos.rot)
		setElementData(refillers[k], "Fuel->isRefiller", true)
	end
	for k, v in ipairs(refill_pumps2) do
		refillers_lines[k] = createObject(14463, v.pos.x-0.3, v.pos.y, v.pos.z-1.4, 0, 90, v.pos.rot)
		setElementData(refillers_lines[k], "Fuel->isRefillerLine", true)
	end
end
loadRefillers()

function pickDownRefiller(element, type_)
	local player = source
		exports.bone_attach:attachElementToBone(refillers[element], player, 12, 0, 0.05, 0.05, 0, 150, 180)
		taroltPump = refillers[element]
		setElementData(refillers[element], "usedPump", true)
		setElementData(player, "Fuel->usingRefiller", true)
		--setElementData(player, "playerUsedPistol", false)
end
addEvent("Fuel->pickDownRefiller", true)
addEventHandler("Fuel->pickDownRefiller", root, pickDownRefiller)

function getBackRefiller(element, type_)
	local player = source
	exports.bone_attach:detachElementFromBone(refillers[element])
	setElementPosition(refillers[element], refill_pumps[element].pos.x,refill_pumps[element].pos.y, refill_pumps[element].pos.z)
	setElementRotation(refillers[element], 0,refill_pumps[element].pos.newrot2,refill_pumps[element].pos.newrot3)
	setElementData(player, "Fuel->usingRefiller", false)
end
addEvent("Fuel->getBackRefiller", true)
addEventHandler("Fuel->getBackRefiller", root, getBackRefiller)

function refill_animation(type_)
	local player = source
	if type_ == "start" then
		setPedAnimation(player, "SWORD", "sword_IDLE", -1, true, false, false)
	else
		setPedAnimation(player, nil, nil)
	end
end
addEvent("Fuel->refill_animation", true)
addEventHandler("Fuel->refill_animation", root, refill_animation)


function open_animation(type_)
	local player = source
	if type_ == "start" then
		setPedAnimation(player, "casino", "cards_win", -1, true, false, false)
	else
		setPedAnimation(player)
	end
end
addEvent("Fuel->open_animation", true)
addEventHandler("Fuel->open_animation", root, open_animation)


function syncPlayereffect (player, state )
	triggerClientEvent(root, "createEffectstoClient", root, player, state, taroltPump)
end
addEvent("syncPlayereffect", true)
addEventHandler("syncPlayereffect", getRootElement(), syncPlayereffect)

function paymentComplete (amount)
	local player = source
	setElementData(player, "money", getElementData(player, "money")-tonumber(amount))
end
addEvent("paymentComplete", true)
addEventHandler("paymentComplete", getRootElement(), paymentComplete)

function addTankedFuelToVeh (vehicle, fuelamount)
	setElementData(vehicle, "fuel", getElementData(vehicle, "fuel")+tonumber(fuelamount))
end
addEvent("addTankedFuelToVeh", true)
addEventHandler("addTankedFuelToVeh", getRootElement(), addTankedFuelToVeh)

local prices = {
	{label = "Super", price = 156.9},
	{label = "Super Plus", price = 170.9},
	{label = "Super E10", price = 151.9},
	{label = "Diesel", price = 135.9}
}

addEvent("onFuelPriceRequest", true)
addEventHandler("onFuelPriceRequest", getRootElement(), function()
    triggerClientEvent(source, "onFuelPriceUpdate", source, prices)
end)


function setVehicleFuelAmount(thePlayer, commandName, target, amount)
	if not (exports.sas_global:isPlayerAdmin(thePlayer)) then return end
	if not (target) or not amount then
		outputChatBox("#7cc576[SeeMTA]: #ffffff/" .. commandName .. " [ID], [Érték]", thePlayer, 255, 194, 14, true)
	else
		local username = getPlayerName(thePlayer)
		local targetPlayer, targetPlayerName = exports.sas_global:findPlayerByPartialNick(thePlayer, target)

		if targetPlayer then
			local logged = getElementData(targetPlayer, "loggedin")
			if (logged==0) then
				outputChatBox("#d9534f[SeeMTA]:#ffffff A játékos nincs bejelentkezve.", thePlayer, 255, 0, 0, true)
			else
				local veh = getPedOccupiedVehicle(targetPlayer)
				if (veh) then
					setElementData(veh, "fuel", tonumber(amount))
					outputChatBox("#7cc576[SeeMTA]:#ffffff Beállítottad #32b3ef" .. targetPlayerName .. " #ffffffjárművének üzemanyagszintjét: #32b3ef"..amount.."#ffffff.", thePlayer,0,0,0,true)
					outputChatBox("#7cc576[SeeMTA]:#ffffff A jármûved üzemanyagszintje átállítva #32b3ef" .. username .. " #ffffffáltal.", targetPlayer,0,0,0,true)
					-- Admin check
					local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
					exports.sas_global:sendMessageToAdmins("" .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " beállította #32b3ef"..targetPlayerName.." #ffffffkocsijának üzemanyagszintjét: #32b3ef"..amount.."#ffffff.")
				else
					outputChatBox("#d9534f[SeeMTA]:#ffffff Ez a játékos nincs jármûben.", thePlayer, 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("setfuel", setVehicleFuelAmount)
