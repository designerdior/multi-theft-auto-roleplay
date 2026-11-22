local damage = {
    [4] = 100,
    [8] = 100,
    [22] = 15,
    [23] = 15,
    [24] = 25,
    [25] = 40,
    [26] = 40,
    [27] = 50,
    [28] = 15,
    [32] = 15,
    [29] = 20,
    [30] = 35,
    [31] = 35,
    [33] = 60,
    [34] = 80,
}

function playerDamage(attacker, weapon, bodypart, loss)
	if bodypart == 9 and getPedArmor(source) == 0 then
	    killPed(source, attacker, weapon, bodypart)
        setElementData(source, "char >> headless", true)
    elseif weapon == 8 then
        killPed(source, attacker, weapon, bodypart)
        setElementData(source, "char >> headless", true)
    elseif bodypart == 9 then
        local armor = getPedArmor(source)
        armor = armor - damage[weapon]
        if armor <= 0 then
            armor = 0
        end
        setPedArmor(source, armor)
	end
end
addEventHandler("onPlayerDamage", root, playerDamage)

addEvent("removePlayerFromVeh", true)
addEventHandler("removePlayerFromVeh", getRootElement(), function()
    removePedFromVehicle(client)
end)

local clones = {}

function clonePlayer(e, rot, veh, comPos, seat)
    if not clones[e] then
        setElementAlpha(e, 0)
        local skinid = getElementModel(e)
        local x,y,z = getElementPosition(e)
        local name =  getPlayerName(e)
        local type = getElementData(e, "dbid") or -1
        if isElement(veh) then
            --x,y,z = getElementPosition(veh)
            if comPos then
                x,y,z = unpack(comPos)
            else
                if getVehicleType(veh) == "BMX" or getVehicleType(veh) == "Bike" then
                    x,y,z = getElementPosition(veh)
                    if seat == 0 then
                        x = x + 0.5
                        y = y + 0.5
                    elseif seat == 1 then
                        x = x - 0.5
                        y = y - 0.5
                    end
                else
                    if getElementModel(veh) == 539 or getElementModel(veh) == 457 or getElementModel(veh) == 424 or getElementModel(veh) == 568 then
                        if seat == 1 then
                            x,y,z = getElementPosition(veh)
                            x = x + 1
                            y = y + 1
                        elseif seat == 0 then
                            x,y,z = getElementPosition(veh)
                            x = x - 1
                            y = y - 1
                        end
                    else
                        x,y,z = getElementPosition(veh)
                        x = x + 3
                        y = y + 3
                    end
                end
            end
        end
        z = z + 0.1
        local ped = createPed(skinid, x,y,z, rot)
        setElementData(ped, "ped.id", "Death-System")
        setElementData(ped, "ped.name", name)
        setElementData(ped, "ped.type", type)
        local deathReason = getElementData(e, "deathReason")
        local deathReasonAdmin = getElementData(e, "deathReason >> admin")
        setElementData(ped, "deathReason", deathReason)
        setElementData(ped, "deathReason >> admin", deathReasonAdmin)
        --setElementFrozen(ped, true)
        local headless = getElementData(e, "char >> headless")
        setPedHeadless(ped, headless)
        --setElementFrozen(ped, true)
        --[[
        local ped = ped
        setTimer(
            function()
                setElementFrozen(ped, false)
            end, 10000, 1
        )
        ]]
        setElementData(e, "char >> headless", false)
        --setElementCollisionsEnabled(e, false)
        local dimension = getElementData(e, "oldDimension")
        setElementDimension(ped, dimension)
        local interior = getElementDimension(e)
        setElementInterior(ped, interior)
        setElementAlpha(e, 255)
        setElementData(e, "clone", ped)
        --setPedAnimation(ped, "ped", "floor_hit_f", 0, false, false, false, true, 0)--,false,false,fals
        if isElementInWater(e) then
            setTimer(setPedAnimation, 50, 2, ped, "ped", "Drown", -1, false, true, false)
        else
            setTimer(setPedAnimation, 50, 2, ped, "ped", "FLOOR_hit_f", -1, false, true, false)
        end
        --[[
        local a, a, rot = getElementRotation(e)
        setElementRotation(ped, 0,0,rot)
        ]]
        setElementData(ped, "rot", rot)
        clones[e] = ped
        setElementData(e, "inDeath", false)
        spawnPlayer(e, 0,0,0, rot, skinid)
        setElementData(e, "oldPos", {x,y,z})
        setElementData(e, "inDeath", true)
    end
end
addEvent("clonePlayer", true)
addEventHandler("clonePlayer", root, clonePlayer)

addCommandHandler("asegit",
	function(thePlayer, cmd, who, targetPlayer)
		if (exports.sas_global:isPlayerAdmin(thePlayer)) then
			if not (who) then
				outputChatBox("#7cc576[SeeMTA]: #ffffff/" .. cmd .. " [Játékos neve]", thePlayer,0,0,0,true)
			else
				local targetPlayer, targetPlayerName = exports['sas_global']:findPlayerByPartialNick(thePlayer, who)
			--	if isPedDead(targetPlayer) then
                if getElementData(targetPlayer, "inDeath") then
					if (targetPlayer) then
                    --  local clone = getElementData(targetPlayer, "clone") or targetPlayer
                        local x,y,z = unpack(getElementData(targetPlayer, "oldPos"))
                        goToMedical(targetPlayer, 2000, x,y,z)
                        setElementData(targetPlayer, "bone", {true, true, true, true, true})
                        outputChatBox("#7cc576[SeeMTA]: #ffffffSikeresen felsegítetted #32b3ef"..targetPlayerName.."#ffffff-t.",thePlayer,0,0,0,true)
                        local adminTitle = exports.sas_global:getPlayerAdminTitle(thePlayer)
                        outputChatBox("#7cc576[SeeMTA]: #ffffff" .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer):gsub("_", " ") .. " felsegített téged.",targetPlayer,0,0,0,true)
                        exports.sas_global:sendMessageToAdmins(tostring(adminTitle) .. " " .. getPlayerName(thePlayer):gsub("_", " ") .. " felsegítette #32b3ef"..targetPlayerName.." #ffffff-t.")
					end
				else
					outputChatBox("#d9534f[SeeMTA]: #ffffffA megadott játékos nincs halálban.",thePlayer,0,0,0,true)
				end
			end
		end
	end
)

function destroyClone(e)
    if clones[e] then
        destroyElement(clones[e])
        clones[e] = nil
        setElementData(e, "clone", nil)
    end
end

function readyToMoveInNewWorld(e)
    local skinid = getElementModel(e)
    local x,y,z = unpack(getElementData(e, "oldPos"))
    local interior = getElementInterior(e)
    --setElementAlpha(e, 255)
    setElementData(e, "char >> death", true)
    setElementData(e, "inDeath", true)
    spawnPlayer(e, x-1,y-1,math.floor(z + 1), 0, skinid)
  --  setElementAlpha(e, 100)
    setElementDimension(e, math.random(1, 1000) * math.random(2, 10))
    setElementInterior(e, interior)
    setElementFrozen(e, true)
    setTimer(
        function()
            if isElement(e) then
                setElementFrozen(e, false)
            end
        end, 2000, 1
    )
end
addEvent("readyToMoveInNewWorld", true)
addEventHandler("readyToMoveInNewWorld", root, readyToMoveInNewWorld)

function goToMedical(e, time, x,y,z)
    if not x or not y or not z then
        x,y,z = 1188.48608, -1323.86096, 14.5668
    end
    triggerClientEvent(e, "Clear -> DeathEffect", e, e)
    local skinid = getElementModel(e)
    setElementData(e, "char >> death", false)
    setElementData(e, "inDeath", false)
    if isPedDead(e) then
        spawnPlayer(e, x,y,z)
    end
    setElementModel(e, skinid)
    setElementData(e, "char >> belt", false)
    destroyClone(e)
    setElementPosition(e, x, y, z+0.5)
    setElementRotation(e, 0, 0, 265)
    triggerClientEvent("spawn - event", e, e, time)
    setElementHealth(e, 100)
    setElementDimension(e, 0)
    setElementInterior(e, 0)
    setElementAlpha(e, 255)
    setElementFrozen(e, false)
end
addEvent("goToMedical", true)
addEventHandler("goToMedical", root, goToMedical)

addEventHandler("onElementDataChange", root,
    function(dName)
        if dName == "dimension" then
            local value = getElementData(source, dName)
            setElementDimension(source, value)
        elseif dName == "deathReason >> admin" and getElementType(source) == "player" then
            local clone = clones[source]
            if clone then
                local deathReason = getElementData(source, "deathReason")
                local deathReasonA = getElementData(source, dName)
                setElementData(clone, "deathReason", deathReason)
                setElementData(clone, "deathReason >> admin", deathReasonA)
            end
        end
    end
)

addEventHandler("onPlayerQuit", root,
    function()
        if getElementData(source, "char >> death") or getElementData(source, "inDeath") then
            destroyClone(source)
        end
    end
)
