if fileExists("sourceC.lua") then 
	fileDelete("sourceC.lua")
end

local minutes = 15
local seconds = 0
local fontsize = 1
local movingTimer, clockTimer
local state = false

local speedOnDeath = 0.5
local time = 10000

local font = dxCreateFont("fonts/Roboto.ttf", 20)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dName)
        if not getElementData(localPlayer, "inDeath") then return end
        if dName == "hudVisible" then
            setElementData(localPlayer, dName, false)
            showChat(false)
        elseif dName == "keysDenied" then
            setElementData(localPlayer, dName, true)
        end
    end
)

local seatNames = {
    [0] = "door_lf_dummy",
    [1] = "door_rf_dummy",
    [2] = "door_lr_dummy",
    [3] = "door_rr_dummy",
}


function startDeath()
    local veh = getPedOccupiedVehicle(localPlayer)
    local comPos = false
    local seat = nil
    if veh then
        seat = getPedOccupiedVehicleSeat(localPlayer)
        triggerServerEvent("removePlayerFromVeh", localPlayer)
        local name = seatNames[seat]
        local x,y,z = getVehicleComponentPosition(veh, name, "world")
        if x and y and z then
            comPos = {x,y,z}
        end
    end
    setElementData(localPlayer, "char >> death", true)
    setElementData(localPlayer, "inDeath", true)
    minutes = 15
    seconds = 0
    local interior = getElementInterior(localPlayer)
    toggleAllControls(false)
    setCameraInterior(interior)
    setElementData(localPlayer, "hudVisible", false)
    setElementData(localPlayer, "keysDenied", true)
    setElementCollisionsEnabled(localPlayer, false)
    local oldDimension = getElementDimension(localPlayer)
    setElementData(localPlayer, "oldDimension", oldDimension)
    local x,y,z = getElementPosition(localPlayer)
    state = true
    setCameraMatrix(x,y,z,x,y,z)
    exports['sas_system']:smoothMoveCamera(x,y,z+1,x,y,z+1,x,y,z+10,x,y,z,7000)
    startShader()
    local a,a,rot = getElementRotation(localPlayer)
    --local headless = getElementRotation(localPlayer)
    triggerServerEvent("clonePlayer", localPlayer, localPlayer, rot, veh, comPos, seat)
    movingTimer = setTimer(
        function()
            if not state then return end
          --  fadeCamera(false, 5, 0,0,0)
            movingTimer = setTimer(
                function()
                    if not state then return end
                  --  fadeCamera(true, 5)
                    movingTimer = setTimer(
                        function()
                            if not state then return end
                            setElementCollisionsEnabled(localPlayer, true)
                            triggerServerEvent("readyToMoveInNewWorld", localPlayer, localPlayer)
                            toggleAllControls(true)
                            setElementData(localPlayer, "bone", {true, true, true, true, true})
                            toggleControl("enter_exit", false)
                            stopShader()
                            startWhiteShader()
                            setElementData(localPlayer, "enableall", false)
                            setGameSpeed(speedOnDeath)
                            startClockTimer()
                            --[[
                            movingTimer = setTimer(
                                function()
                                    triggerServerEvent("readyToMoveInNewWorld", localPlayer, localPlayer)
                                    setCameraTarget(localPlayer, localPlayer) --setElementData(localPlayer, "char >> death", 0)
                                end, 10000, 1
                            )
                            ]]
                        end, 3000, 1
                    )
                end, 3000, 1
            )
        end, 3000, 1
    )
end

function startClockTimer()
    toggleControl("enter_exit", false)
    stopClockTimer()
    addEventHandler("onClientRender", root, drawnClock, true, "low-5")
    state = true
    backgroundSound = playSound("sounds/death.mp3", true)
    setSoundVolume(backgroundSound, 0.65)
  --[[ effectTimer = setTimer(
        function()
            createEffect()
        end, 1 * 60 * 1000, 0
    )]]
    clockTimer = setTimer(
        function()
            seconds = seconds - 1
            if seconds <= 0 then
                seconds = 59
                minutes = minutes - 1
                if minutes < 0 then
                    minutes = 0
                    --setGameSpeed(1)
                    --stopClockTimer()
                    --stopShader()
                    triggerServerEvent("goToMedical", localPlayer, localPlayer, time)
                    --setElementData(localPlayer, "keysDenied", false)
                    --setElementData(localPlayer, "hudVisible", true)
                end
            end
        end, 1000, 0
    )
end

local effect = 0

addEvent("Clear -> DeathEffect", true)
addEventHandler("Clear -> DeathEffect", root,
    function(e)
        if e == localPlayer then
            setGameSpeed(1)
            stopClockTimer()
            stopShader()
            fadeCamera(true)
            --setWeather(1)
            --setTime(12, 0)
            state = false
        end
    end
)

function stopClockTimer()
    if state then
        removeEventHandler("onClientRender", root, drawnClock)
        state = false
    end
    if isTimer(movingTimer) then
        killTimer(movingTimer)
    end
    if isTimer(effectTimer) then
        killTimer(effectTimer)
    end
    if isTimer(clockTimer) then
        killTimer(clockTimer)
    end
    if isElement(backgroundSound) then
        destroyElement(backgroundSound)
    end
end

function formatString(n)
    if n < 10 then
        n = "0" .. n
    end
    return n
end

local sx, sy = guiGetScreenSize()

function drawnClock()
    local minutesS = formatString(minutes)
    local secondsS = formatString(seconds)
    local x, y = sx - 70, sy - 50
    dxDrawText(minutesS .. ":" .. secondsS,x,y+1,x,y+1,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Fent
    dxDrawText(minutesS .. ":" .. secondsS,x,y-1,x,y-1,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Lent
    dxDrawText(minutesS .. ":" .. secondsS,x-1,y,x-1,y,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Bal
    dxDrawText(minutesS .. ":" .. secondsS,x+1,y,x+1,y,tocolor(0,0,0,245),size, font, "center", "top", false, false, false, true) -- Jobb
    local r,g,b = 255,255,255
    if minutes <= 3 then
        r,g,b = 255,87,87
    end
    dxDrawText(minutesS .. ":" .. secondsS, x, y, x, y, tocolor(r,g,b,255), fontsize, font, "center", "top")
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if getElementData(localPlayer, "char >> death") then
            if getElementData(localPlayer, "oldDimension") ~= getElementDimension(localPlayer) then
                setElementData(localPlayer, "dimension", getElementData(localPlayer, "oldDimension"))
            end
            startDeath()
        end
    end
)

addEventHandler("onClientPlayerWasted", localPlayer,
    function(killer,weapon,bodypart)
        if not state then
            startDeath()
        end
    end
)

addEventHandler("onClientPlayerSpawn", localPlayer,
    function()
        if getElementData(localPlayer, "inDeath") then
            toggleAllControls(false)
            showChat(false)
            setElementData(localPlayer, "hudVisible", false)
            setElementData(localPlayer, "char >> headless", false)
            --setElementData(localPlayer, "loggedIn", false)
            setGameSpeed(speedOnDeath)
            --setElementFrozen(localPlayer, true)
            local x,y,z = getElementPosition(localPlayer)
            --setElementPosition(localPlayer, x, y, z)
            --exports['sas_system']:smoothMoveCamera(x, y, z + 250, x, y, z, x, y, z + 4, x, y, z + 3, time)
            setTimer(
                function()
                    setCameraTarget(localPlayer, localPlayer)
                    toggleAllControls(true)
                    toggleControl("enter_exit", false)
                    --setElementData(localPlayer, "loggedIn", true)
                    --setElementFrozen(localPlayer, false)
                end, 2000, 1
            )
        end
    end
)

addEvent("spawn - event", true)
addEventHandler("spawn - event", root,
    function(e)
        if e ~= localPlayer then return end
        stopClockTimer()
        --local time = 7000
        exports['sas_system']:stopSmoothMoveCamera()
        setCameraTarget(localPlayer, localPlayer)
        setElementData(localPlayer, "char >> death", false)
        toggleAllControls(true)
        setElementData(localPlayer, "char >> bone", {true, true, true, true, true})
        setElementData(localPlayer, "inDeath", false)
        toggleAllControls(false)
        showChat(false)
        setGameSpeed(1)
        setElementData(localPlayer, "char >> food", 100)
        setElementData(localPlayer, "char >> drink", 100)
        setElementData(localPlayer, "hudVisible", false)
        setElementData(localPlayer, "keysDenied", true)
        setElementData(localPlayer, "char >> headless", false)
        setElementData(localPlayer, "enableall", true)
        stopWhiteShader()
        --setElementData(localPlayer, "loggedIn", false)
        local x,y,z = getElementPosition(localPlayer)
        setElementPosition(localPlayer, x, y, z)
        setCameraTarget(localPlayer, localPlayer)
        toggleAllControls(true)
        showChat(true)
        setElementData(localPlayer, "hudVisible", true)
        setElementData(localPlayer, "keysDenied", false)
        setElementFrozen(localPlayer, false)
        toggleControl("enter_exit", true)
    end
)


addEventHandler("onClientPedDamage",getRootElement(),
	function(att,weapon,part,loss)
        local id = getElementData(source, "ped.id") or "Invalid-4"
		if id == "Death-System" then
            cancelEvent()
        end
	end
)



addEventHandler("onClientElementStreamIn", root,
    function()
        if getElementType(source) == "ped" then
            if getElementData(source, "deathReason") then
                if isElementInWater(source) then
                    setTimer(setPedAnimation, 50, 2, source, "ped", "Drown", -1, false, true, false)
                else
                    setTimer(setPedAnimation, 50, 2, source, "ped", "FLOOR_hit_f", -1, false, true, false)
                end
                --[[
                local a,a2 = nil
                local rot = getElementData(source, "rot")
                if not rot then
                    a, a2, rot = getElementRotation(source)
                end
                setElementRotation(source, 0,0,rot)
                ]]
            end
        --[[
        elseif getElementType(source) == "player" then
            if getElementData(source, "inDeath") then
                local clone = getElementData(source, "clone")
                if isElementInWater(source) then
                    setTimer(setPedAnimation, 50, 2, source, "ped", "Drown", -1, false, true, false)
                else
                    setTimer(setPedAnimation, 50, 2, source, "ped", "FLOOR_hit_f", -1, false, true, false)
                end
                setElementCollisionsEnabled(source, false)
            end]]
        end
    end
)
