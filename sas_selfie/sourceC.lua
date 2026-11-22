
local rootElement = getRootElement ( )
local mplayer = getLocalPlayer ( )
local sw, sh = guiGetScreenSize ( )

local speed, strafespeed = 0, 0
local rotX, rotY = 0,0
local mouseFrameDelay = 0

local options =
{
    invertMouseLook = false,
    mouseSensitivity = 0.15
}

function math.clamp ( value, lower, upper )
 value, lower, upper = tonumber ( value ), tonumber ( lower ), tonumber ( upper )
 if value and lower and upper then
  if value < lower then
   value = lower
  elseif value > upper then
   value = upper
  end
  return value
 end
 return false
end

function getElementOffset ( entity, offX, offY, offZ )
 local posX, posY, posZ = 0, 0, 0
 if isElement ( entity ) and type ( offX ) == "number" and type ( offY ) == "number" and type ( offZ ) == "number" then
  local center = getElementMatrix ( entity )
  if center then
   posX = offX * center [ 1 ] [ 1 ] + offY * center [ 2 ] [ 1 ] + offZ * center [ 3 ] [ 1 ] + center [ 4 ] [ 1 ]
   posY = offX * center [ 1 ] [ 2 ] + offY * center [ 2 ] [ 2 ] + offZ * center [ 3 ] [ 2 ] + center [ 4 ] [ 2 ]
   posZ = offX * center [ 1 ] [ 3 ] + offY * center [ 2 ] [ 3 ] + offZ * center [ 3 ] [ 3 ] + center [ 4 ] [ 3 ]
  end
 end
 return posX, posY, posZ
end

addEventHandler ( "onClientResourceStart", getResourceRootElement ( getThisResource ( ) ),
function ( )
 bindKey ( "u", "up",
 function ( )
  if isElement ( getCameraTarget ( ) ) then
   setPedAnimation( mplayer, "PED", "gang_gunstand")
   addEventHandler ( "onClientPreRender", rootElement, render )
   addEventHandler ( "onClientCursorMove", rootElement, mousecalc )
  else
	setPedAnimation( mplayer, false)
   removeEventHandler ( "onClientPreRender", rootElement, render )
   removeEventHandler ( "onClientCursorMove", rootElement, mousecalc )
   setCameraTarget ( mplayer )
  end
 end )
end )

function callSelfieMode(state)
  if state then
    setPedAnimation( mplayer, "PED", "gang_gunstand")
    addEventHandler ( "onClientPreRender", rootElement, render )
    addEventHandler ( "onClientCursorMove", rootElement, mousecalc )
  else
    setPedAnimation( mplayer, false)
    removeEventHandler ( "onClientPreRender", rootElement, render )
    removeEventHandler ( "onClientCursorMove", rootElement, mousecalc )
    setCameraTarget ( mplayer )
  end
end
addEvent("callSelfieMode", true)
addEventHandler("callSelfieMode", getRootElement(), callSelfieMode)

function render ( )
 local PI = math.pi
 if getKeyState ( "a" ) then
  rotX = rotX - options.mouseSensitivity * 0.05745
elseif getKeyState ( "d" ) then
  rotX = rotX + options.mouseSensitivity * 0.05745
 end
 if getKeyState ( "w" ) then
  rotY = rotY + options.mouseSensitivity * 0.05745
  rotY = math.clamp ( rotY, -PI / 2.05, PI / 2.05 )
elseif getKeyState ( "s" ) then
  rotY = rotY - options.mouseSensitivity * 0.05745
  rotY = math.clamp ( rotY, -PI / 2.05, PI / 2.05 )
 end
 local cameraAngleX = rotX
 local cameraAngleY = rotY

 local freeModeAngleZ = math.sin(cameraAngleY)
 local freeModeAngleY = math.cos(cameraAngleY) * math.cos(cameraAngleX)
 local freeModeAngleX = math.cos(cameraAngleY) * math.sin(cameraAngleX)

 local camPosX, camPosY, camPosZ = getPedBonePosition ( mplayer, 25 )
 camPosZ = camPosZ + 0.29
 --Вытягиваем камеру перед животом
 if rotY < 0 and isPedInVehicle ( mplayer ) ~= true then --Если камера смотрит вниз
  local r = getPedRotation ( mplayer )
  camPosX = camPosX - math.sin ( math.rad(r) ) * (-rotY/4.5)
  camPosY = camPosY + math.cos ( math.rad(r) ) * (-rotY/4.5)
 end
 local camTargetX = camPosX + freeModeAngleX * 100
 local camTargetY = camPosY + freeModeAngleY * 100
 local camTargetZ = camPosZ + freeModeAngleZ * 100

 local camAngleX = camPosX - camTargetX
 local camAngleY = camPosY - camTargetY
 local camAngleZ = 0

 local angleLength = math.sqrt(camAngleX*camAngleX+camAngleY*camAngleY+camAngleZ*camAngleZ)

  local camNormalizedAngleX = camAngleX / angleLength
  local camNormalizedAngleY = camAngleY / angleLength
  local camNormalizedAngleZ = 0

  local normalAngleX = 0
  local normalAngleY = 0
  local normalAngleZ = 1

  local normalX = (camNormalizedAngleY * normalAngleZ - camNormalizedAngleZ * normalAngleY)
  local normalY = (camNormalizedAngleZ * normalAngleX - camNormalizedAngleX * normalAngleZ)
  local normalZ = (camNormalizedAngleX * normalAngleY - camNormalizedAngleY * normalAngleX)


  camPosX = camPosX + freeModeAngleX * speed
  camPosY = camPosY + freeModeAngleY * speed
  camPosZ = camPosZ + freeModeAngleZ * speed

  camPosX = camPosX + normalX * strafespeed
  camPosY = camPosY + normalY * strafespeed
  camPosZ = camPosZ + normalZ * strafespeed

  camTargetX = camPosX + freeModeAngleX * 100
  camTargetY = camPosY + freeModeAngleY * 100
  camTargetZ = camPosZ + freeModeAngleZ * 100

  --if isPedInVehicle ( mplayer ) and getKeyState ( "mouse1" ) ~= true then
  -- if getControlState ( "vehicle_look_behind" ) then
    camTargetX, camTargetY, camTargetZ = getElementOffset ( mplayer, 0, -3, 0 )
    --camTargetX = camTargetX + freeModeAngleX * 100
  --  camTargetY = camTargetY + freeModeAngleY * 100
    --camTargetZ = camTargetZ + freeModeAngleZ * 100
  -- else
  --  camTargetX, camTargetY, camTargetZ = getElementOffset ( mplayer, 0, 3, 0 )
--   end
--  end

 setPedAimTarget ( mplayer, camTargetX, camTargetY, camTargetZ )
 setCameraMatrix ( camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ )
end

function mousecalc ( _, _, aX, aY )
 if isCursorShowing ( ) or isMTAWindowActive ( ) then
  mouseFrameDelay = 5
  return
 elseif mouseFrameDelay > 0 then
  mouseFrameDelay = mouseFrameDelay - 1
  return
 end

 aX = aX - sw / 2
 aY = aY - sh / 2

 if options.invertMouseLook then
  aY = -aY
 end

 rotX = rotX + aX * options.mouseSensitivity * 0.01745
 rotY = rotY - aY * options.mouseSensitivity * 0.01745

 local PI = math.pi
 if rotX > PI then
  rotX = rotX - 2 * PI
 elseif rotX < -PI then
  rotX = rotX + 2 * PI
 end

 if rotY > PI then
  rotY = rotY - 2 * PI
 elseif rotY < -PI then
  rotY = rotY + 2 * PI
 end

 rotY = math.clamp ( rotY, -PI / 2.05, PI / 2.05 )
end

local UniStat = {
    items = { }
}

local sw, sh = guiGetScreenSize ( )

--Цветовые схемы
local colors = {
    white = tocolor ( 255, 255, 255, 255 )
}

local lexemes = {
    [ "health" ] = {
        getString = function ( arg, player )
            local health = math.floor ( getElementHealth ( player ) + 0.5 )

            return health
        end
    },
    [ "armor" ] = {
        getString = function ( arg, player )
            return math.floor ( getPedArmor ( player ) + 0.5 )
        end
    },
    [ "video" ] = {
        getString = function ( arg, player )
            if arg == "name" then
                return getElementData ( player, "vcName" )
            elseif arg == "ram" then
                return getElementData ( player, "vcRAM" )
            elseif arg == "ps" then
                return getElementData ( player, "vcPSVer" )
            end
        end,
        onInit = function ( player )
            local dxStat = dxGetStatus ( )

            setElementData ( player, "vcName", dxStat.VideoCardName )
            setElementData ( player, "vcRAM", dxStat.VideoCardRAM .. "MB" )
            setElementData ( player, "vcPSVer", dxStat.VideoCardPSVersion )
        end
    },
    [ "time" ] = {
        getString = function ( arg, player )
            local timestamp = getElementData ( player, "times" )
            local time = getRealTime ( timestamp )

            return time.hour .. ":" .. time.minute .. ":" .. time.second
        end,

    },
    [ "tl" ] = {
        getString = function ( arg, player )
            local timeLeft = getElementData ( player, "tl" )

            if arg == "min" then
                return math.floor ( timeLeft / 60000 )
            elseif arg == "sec" then
                return math.floor ( timeLeft / 1000 )
            elseif arg == "msec" then
                return math.floor ( timeLeft )
            end
        end,

    },
    [ "rot" ] = {
        getString = function ( arg, player )
            return math.floor ( getPedRotation ( player ) + 0.5 )
        end
    },
    [ "afk" ] = {
        getString = function ( arg, player )
            local isAFK = getElementData ( player, "afk" ) or 0
            local statusName = isAFK > 0 and "AFK" or "В ИГРЕ"

            return statusName
        end
    },
}

addEventHandler ( "onClientRender", root,
    function ( )
        local lpx, lpy, lpz = getCameraMatrix ( )

        for player, statStr in pairs ( UniStat.items ) do
            if isElement ( player ) then
                local px, py, pz = getPedBonePosition ( player, 25 )
                if isPedInVehicle ( player ) then
                    pz = pz + 0.5
                end

                local distance = getDistanceBetweenPoints3D ( lpx, lpy, lpz, px, py, pz )
                if distance <= 100 then
                    if isLineOfSightClear ( lpx, lpy, lpz, px, py, pz, true, false, false, true ) then
                        local scale = 5.9 / distance
                        if scale > 1.9 then
                            scale = 1.9
                        end

                        px, py = getScreenFromWorldPosition ( px, py, pz + 0.3 )
                        if px then
                            dxDrawText ( statStr, px - dxGetTextWidth ( statStr, scale, "default-bold" ) / 2, py, sw, sh, colors.white, scale, "default-bold" )
                        end
                    end
                end
            end
        end
    end
)

local function getStringFromLexeme ( lexemeName, lexemeArg, player )
    if lexemes [ lexemeName ] == nil then
        return
    end

    return lexemes [ lexemeName ].getString ( lexemeArg, player )
end

local function getPlayerStatString ( player )
    local statStr = getElementData ( player, "stat" )
    if not statStr then
        return
    end

    --Получаем слова, разделенные пробелом
    local words = split ( statStr, 32 ) --SPACE
    statStr = ""

    for _, word in ipairs ( words ) do
        local lexemeName = gettok ( word, 1, 64 ) --@

        if word == "$" then
            word = "\n"
        elseif lexemeName then
            local lexemeArg = gettok ( word, 2, 64 ) --@

            local lexemeResult = getStringFromLexeme ( lexemeName, lexemeArg, player )
            if lexemeResult then
                word = lexemeResult
            end

            word = word .. " "
        end

        statStr = statStr .. word
    end

    return statStr
end




addEventHandler ( "onClientResourceStart", resourceRoot,
    function ( )
        for _, lexeme in pairs ( lexemes ) do
            if lexeme.onInit then
                pcall ( lexeme.onInit, localPlayer )
            end
        end

        setTimer ( UniStat.updatePulse, 100, 0 )
    end
    )
