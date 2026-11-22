--[[
bone felépítése = {Has, Bal kéz, Jobb kéz, Bal láb, Jobb láb}
]]

local damageTypes = {
	[19] = "Rocket",
	[37] = "Burnt",
	[49] = "Rammed",
	[50] = "Ranover/Helicopter Blades",
	[51] = "Explosion",
	[52] = "Driveby",
	[53] = "Drowned",
	[54] = "Fall",
	[55] = "Unknown",
	[56] = "Melee",
	--[57] = "Weapon",
	[59] = "Tank Grenade",
	[63] = "Blown"
}

local disabledWeapon = {
    --1,2,3,4,5,6,7,14,15,10,11,12
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [14] = true,
    [15] = true,
    [19] = true,
    [59] = true,
    [35] = true,
    [36] = true,
    [37] = true,
    [38] = true,
    [39] = true,
    [40] = true,
    [17] = true,
    [41] = true,
    [42] = true,
}

addEventHandler("onClientPlayerDamage", localPlayer,
    function(attacker, weapon, bodypart, loss)
        if not getElementData(localPlayer, "loggedin") then return end
        if getElementData(localPlayer, "adminduty") then return end
        if getElementData(localPlayer, "inDeath") then
            cancelEvent()
            return
        end
        --if getElementType(attacker) == "player" then
        local newBone = getElementData(localPlayer, "bone") or {true, true, true, true, true}
        if weapon == 54 then
            if not loss then
                loss = 0
            end
            if loss > 5 and loss < 15 then
                if newBone[4] then
                    newBone[4] = false
									--	outputChatBox("bal láb")
                    exports.sas_hud:addNotification("Eltörted a Bal lábadat!","warning")
                else
                    if newBone[5] then
                        newBone[5] = false
											--	outputChatBox("jobb láb")
                        exports.sas_hud:addNotification("Eltörted a Jobb lábadat!","warning")
                    end
                end
                setElementData(localPlayer, "bone", newBone)
            elseif loss > 15 then
                local d = false
                if newBone[4] then
                    newBone[4] = false
                    d = true
                end
                if newBone[5] then
                    newBone[5] = false
                    d = true
                end
                if d then
									--	outputChatBox("kétlában")
                    exports.sas_hud:addNotification("Eltörted mindkét lábadat a nagy esés következtében!","warning")
                    setElementData(localPlayer, "bone", newBone)
                end
            end
        elseif bodypart == 3 then -- Has
            if getPedOccupiedVehicle(localPlayer) then return end
            if disabledWeapon[weapon] then
                --cancelEvent()
                return
            end
            if newBone[1] and weapon > 0 then
                if attacker then
                    if getElementType(attacker) == "player" and getPedOccupiedVehicle(attacker) then
                        if getPedOccupiedVehicleSeat(attacker) == 0 then
                            return
                        end
                    elseif getElementType(attacker) == "vehicle" then
                        return
                    elseif damageTypes[weapon] then
                        return
                    end
                end
                local ammoInTorso = getElementData(localPlayer, "torsoAmmo") or 0
                setElementData(localPlayer, "torsoAmmo", ammoInTorso + 1)
                local ammoInTorso = getElementData(localPlayer, "torsoAmmo") or 0
                if ammoInTorso > math.random(2,3) then
                    if newBone[1] then
                        exports.sas_hud:addNotification("Mivel többször is mellkason lőttek ezért 30 másodpercig összeestél!","warning")
                        newBone[1] = false
                        toggleMoveControls(false)
                        setElementData(localPlayer, "bone", newBone)
                        triggerServerEvent("anim - give", localPlayer, localPlayer, {"sweet", "sweet_injuredloop"})
                        setTimer(
                            function()
                                newBone[1] = true
                                toggleMoveControls(true)
                                triggerServerEvent("anim - give", localPlayer, localPlayer, {"", ""})
                                setElementData(localPlayer, "torsoAmmo", 0)
                                setElementData(localPlayer, "bone", newBone)
                            end, 30 * 1000, 1
                        )
                    end
                end
            end
        elseif bodypart == 5 then -- Bal kéz
            if newBone[2] then
                newBone[2] = false
                setElementData(localPlayer, "bone", newBone)
                exports.sas_hud:addNotification("Eltörted a Bal kezedet!","warning")
            end
        elseif bodypart == 6 then -- Jobb kéz
            if newBone[3] then
                newBone[3] = false
                setElementData(localPlayer, "bone", newBone)
                exports.sas_hud:addNotification("Eltörted a Jobb kezedet!","warning")
            end
        elseif bodypart == 7 then -- Bal láb
            if newBone[4] then
                newBone[4] = false
                setElementData(localPlayer, "bone", newBone)
                exports.sas_hud:addNotification("Eltörted a Bal lábadat!","warning")
            end
        elseif bodypart == 8 then -- Jobb láb
            if newBone[5] then
                newBone[5] = false
                setElementData(localPlayer, "bone", newBone)
                exports.sas_hud:addNotification("Eltörted a Jobb lábadat!","warning")
            end
        end
        --end
    end
)

function farkasgyogyit()
	setElementData(localPlayer, "bone", {true, true, true, true, true})
	outputChatBox("Farkas meggyógyítva")

end
addCommandHandler("farkasgyogyit", farkasgyogyit)

addEventHandler("onClientVehicleDamage", root,
    function(attacker, weapon)

       -- outputChatBox("Sebződik")
      --  outputChatBox("Weapon: "..weapon)
      --  outputChatBox("Player: "..tostring(isElement(attacker)))

        if getPedOccupiedVehicle(localPlayer) then
            if getPedOccupiedVehicleSeat(localPlayer) == 0 then
                if attacker and attacker ~= localPlayer and getElementType(attacker) == "player" then
                    if getPedOccupiedVehicle(attacker) then
                        if getElementData(attacker, "bornout") then return end
                    end
                    triggerServerEvent("GoServerToBackClient", localPlayer, getPedOccupiedVehicle(localPlayer), attacker, weapon)
                    return
                end
            end
        end
        if attacker and attacker ~= localPlayer and getElementType(attacker) == "player" then
            if getPedOccupiedVehicle(attacker) then
                if getElementData(attacker, "bornout") then return end
            end
            triggerServerEvent("GoServerToBackClient", localPlayer, source, attacker, weapon)
            return
        end
        if getPedOccupiedVehicle(localPlayer) then
            if getElementData(localPlayer, "bornout") then return end
        end
        if attacker == localPlayer and weapon == 0 then
            if getElementData(localPlayer, "loggedin") == 0 then return end
            if getElementData(localPlayer, "adminduty") == 1 then return end
          --  if getElementData(localPlayer, "inDeath") then
            --    cancelEvent()
            --    return
          --  end
            local x,y,z = getElementPosition(source)
            local px,py,pz = getElementPosition(localPlayer)
            local newBone = getElementData(localPlayer, "bone") or {true, true, true, true, true}
            if pz > z + 0.5 then
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[4] then
                        newBone[4] = false
                        setElementData(localPlayer, "bone", newBone)
                        exports.sas_hud:addNotification("Eltörted a Bal lábad!","warning")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[5] then
                            newBone[5] = false
                            setElementData(localPlayer, "bone", newBone)
                            exports.sas_hud:addNotification("Eltörted a Jobb lábad!","warning")
                            setElementData(localPlayer, "attackOnHand", 0)
                        end
                    end
                end
            else
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[2] then
                        newBone[2] = false
                        setElementData(localPlayer, "bone", newBone)
                        exports.sas_hud:addNotification("Eltörted a Bal kezedet!","warning")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[3] then
                            newBone[3] = false
                            setElementData(localPlayer, "bone", newBone)
                            exports.sas_hud:addNotification("Eltörted a Jobb kezedet!","warning")
                            setElementData(localPlayer, "attackOnHand", 0)
                        end
                    end
                end
            end
        end
    end
)

addEvent("onClientVehicleDamageCopy", true)
addEventHandler("onClientVehicleDamageCopy", root,
    function(veh, attacker, weapon)
        local source = veh
        --[[
        outputChatBox("Sebződik")
        outputChatBox("Weapon: "..weapon)1
        outputChatBox("Player: "..tostring(isElement(attacker)))
        ]]
        if getPedOccupiedVehicle(localPlayer) then
            if getElementData(localPlayer, "bornout") then return end
        end
        if attacker == localPlayer and weapon == 0 then
            if getElementData(localPlayer, "loggedin") == 0 then return end
            if getElementData(localPlayer, "adminduty") == 1 then return end
            if getElementData(localPlayer, "inDeath") then
                cancelEvent()
                return
            end
            local x,y,z = getElementPosition(source)
            local px,py,pz = getElementPosition(localPlayer)
            local newBone = getElementData(localPlayer, "bone") or {true, true, true, true, true}
            if pz > z + 0.5 then
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[4] then
                        newBone[4] = false
                        setElementData(localPlayer, "bone", newBone)
                        exports.sas_hud:addNotification("Eltörted a Bal lábad!","warning")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[5] then
                            newBone[5] = false
                            setElementData(localPlayer, "bone", newBone)
                            exports.sas_hud:addNotification("Eltörted a Jobb lábad!","warning")
                            setElementData(localPlayer, "attackOnHand", 0)
                        end
                    end
                end
            else
                local attackOnHand = getElementData(localPlayer, "attackOnHand") or 0
                attackOnHand = attackOnHand + 1
                setElementData(localPlayer, "attackOnHand", attackOnHand)
                if attackOnHand >= 2 then
                    if newBone[2] then
                        newBone[2] = false
                        setElementData(localPlayer, "bone", newBone)
                        exports.sas_hud:addNotification("Eltörted a Bal kezedet!","warning")
                        setElementData(localPlayer, "attackOnHand", 0)
                    else
                        if newBone[3] then
                            newBone[3] = false
                            setElementData(localPlayer, "bone", newBone)
                            exports.sas_hud:addNotification("Eltörted a Jobb kezedet!","warning")
                            setElementData(localPlayer, "attackOnHand", 0)
                        end
                    end
                end
            end
        end
    end
)

function toggleMoveControls(value)
    toggleControl("forwards", value)
    toggleControl("backwards", value)
    toggleControl("left", value)
    toggleControl("right", value)
    toggleControl("jump", value)
    toggleControl("fire", value)
    toggleControl("aim_weapon", value)
    toggleControl("enter_exit", value)
end

addEventHandler("onClientElementDataChange", localPlayer, function(dName)
    if dName == "bone" then
        assignBones()
    end
end)

function assignBones()
    local value = getElementData(source, "bone")

    if value[4] or value[5] then -- Bal és Jobb láb megjavult -- Tud mozogni, futni újra
        toggleMoveControls(true)
    end

    if not value[2] and not value[3] then -- Bal és Jobb kéz eltörve -- Nem tud lőni
        toggleControl("fire", false)
    end

    if value[2] or value[3] then -- Bal és Jobb kéz megjavult -- Tud lőni, célozni újra
        toggleControl("aim_weapon", true)
    end

    if value[2] and value[3] then
        toggleControl("fire", true)
    end

    if not value[4] and not value[5] then -- Bal és Jobb láb eltörve -- Nem tud mozogni
        toggleMoveControls(false)
    end

    if value[4] and value[5] then
        toggleControl("sprint", true)
    end

    if not value[2] then
        toggleControl("aim_weapon", false)
    end

    if not value[3] then
        toggleControl("aim_weapon", false)
    end

    if not value[4] then
        toggleControl("sprint", false)
    end

    if not value[5] then
        toggleControl("sprint", false)
    end
end
addEvent("assignBones", true)
addEventHandler("assignBones", localPlayer, assignBones)