local marks = { }
local default = false
local timer = false

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		local xml = xmlLoadFile( "Player/mark.xml" )
		if xml then
			for key, value in ipairs( xmlNodeGetChildren( xml ) ) do
				local name = xmlNodeGetValue( value )
				if name and #name == 0 then
					name = false
				end

				local data = { tonumber( xmlNodeGetAttribute( value, "x" ) ), tonumber( xmlNodeGetAttribute( value, "y" ) ), tonumber( xmlNodeGetAttribute( value, "z" ) ), tonumber( xmlNodeGetAttribute( value, "interior" ) ), tonumber( xmlNodeGetAttribute( value, "dimension" ) ), name }
				if not name then
					default = data
				else
					marks[ name ] = data
				end
			end
			xmlUnloadFile( xml )
		end
	end
)

addCommandHandler( "mark",
	function( commandName, ... )
		if exports.sas_global:isPlayerAdmin( localPlayer ) then
			-- store the mark
			local name = ( ... ) and table.concat( { ... }, " " ):lower( )
			local x, y, z = getElementPosition( localPlayer )
			local interior = getElementInterior( localPlayer )
			local dimension = getElementDimension( localPlayer )
			local data = { x, y, z, interior, dimension, name }
			if not name then
				default = data
			else
				marks[ name ] = data
			end

			-- save in the xml
			local xml = xmlCreateFile( "Player/mark.xml", "marks" )
			local function saveNode( data, name )
				if #data >= 5 then
					local xml = xmlCreateChild( xml, "mark" )
					if name then
						xmlNodeSetValue( xml, name )
					end
					xmlNodeSetAttribute( xml, "x", data[1] )
					xmlNodeSetAttribute( xml, "y", data[2] )
					xmlNodeSetAttribute( xml, "z", data[3] )
					xmlNodeSetAttribute( xml, "interior", data[4] )
					xmlNodeSetAttribute( xml, "dimension", data[5] )
				end
			end
			if default then
				saveNode( default )
			end
			for key, value in pairs( marks ) do
				saveNode( value, key )
			end
			xmlSaveFile( xml )
			xmlUnloadFile( xml )

			-- success message
			outputChatBox( "#7cc576[SeeMTA]: #FFFFFFTeleport " .. ( name and "'" .. name .. "' " or "" ) .. "sikeresen mentve.", 0, 255, 0 ,true)
		end
	end
)

addCommandHandler( "gotomark",
	function( commandName, ... )
		if exports.sas_global:isPlayerAdmin( localPlayer ) then
			-- store the mark
			local name = ( ... ) and table.concat( { ... }, " " ):lower( )
			if not name then
				if default then
					triggerServerEvent( "gotoMark", localPlayer, unpack( default ) )
				else
					outputChatBox( "#d9534f[SeeMTA]: #FFFFFFElõször meg kell jelölnöd a teleportot a /mark parancsal!", 255, 0, 0,true )
				end
			else
				if marks[ name ] then
					triggerServerEvent( "gotoMark", localPlayer, unpack( marks[ name ] ) )
				else
					outputChatBox( "#d9534f[SeeMTA]: #FFFFFFElõször meg kell jelölnöd a teleportot a /mark " .. name .. " parancsal!", 255, 0, 0,true )
				end
			end
		end
	end
)

local function requestFix( )
	triggerServerEvent( "fixRecon", localPlayer, getElementAttachedTo( localPlayer ) )
	setElementInterior( localPlayer, getElementInterior( getElementAttachedTo( localPlayer ) ) )
	setElementDimension( localPlayer, getElementDimension( getElementAttachedTo( localPlayer ) ) )
	timer = nil
end

addEventHandler( "onClientRender", getRootElement( ),
	function( )
		local element = getElementAttachedTo( localPlayer )
		if element then
			if getElementDimension( element ) ~= getElementDimension( localPlayer ) or getElementInterior( element ) ~= getElementInterior( localPlayer ) then
				if not timer then
					timer = setTimer( requestFix, 1000, 1 )
					return
				end
			end
		end
		if timer then
			killTimer( timer )
			timer = nil
		end
	end
)


addEventHandler("onClientPlayerDamage", localPlayer, function( attacker, weapon, bodypart )
	if getElementData(localPlayer, "adminduty") then
		cancelEvent()
	end
end)

addEventHandler( "onClientElementStreamIn", getRootElement( ),
	function ( )
		if getElementType( source ) == "player" then
			setPedVoice( source, "PED_TYPE_DISABLED" )
		end
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement(),
	function ( startedRes )
		for key, value in ipairs( getElementsByType( "player" ) ) do
			if getElementDimension( value ) < 65000 then
				setPedVoice( value, "PED_TYPE_DISABLED" )
			end
		end
	end
)

addEvent( "fixRecon", true )
addEventHandler( "fixRecon", getRootElement( ), 
	function( element )
		setElementDimension( client, getElementDimension( element ) )
		setElementInterior( client, getElementInterior( element ) )
		setCameraInterior( client, getElementInterior( element ) )
	end
)

function putPlayerInPosition(timeslice)
    if isChatBoxInputActive() or isConsoleActive() then return end
    
    local cx,cy,cz,ctx,cty,ctz = getCameraMatrix()
    ctx,cty = ctx-cx,cty-cy
    timeslice = timeslice*0.1

    if getKeyState("mouse1") then timeslice = timeslice*10 end
    if getKeyState("lshift") then timeslice = timeslice*4 end
    if getKeyState("lalt") then timeslice = timeslice*0.25 end
    local mult = timeslice/math.sqrt(ctx*ctx+cty*cty)
    ctx,cty = ctx*mult,cty*mult
    if getKeyState("w") then
        abx,aby = abx+ctx,aby+cty
        local a = rotFromCam(0)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("s") then
        abx,aby = abx-ctx,aby-cty
        local a = rotFromCam(180)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("d") then
        abx,aby = abx+cty,aby-ctx
        local a = rotFromCam(90)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("a") then
        abx,aby = abx-cty,aby+ctx
        local a = rotFromCam(-90)
        setElementRotation(element,0,0,a)
    end
    if getKeyState("space") then
        abz = abz+timeslice
    end
    if getKeyState("lctrl") then
        abz = abz-timeslice
    end

    tempPos = abx, aby, abz
    setElementPosition(element,abx,aby,abz)
end

function toggleAirBrake()
    air_brake = not air_brake or nil
    if air_brake then
        abx,aby,abz = getElementPosition(element)
        setElementFrozen(element, true)
        setElementCollisionsEnabled(element,false)
        addEventHandler("onClientPreRender",root,putPlayerInPosition)
    else
        abx,aby,abz = nil
        setElementFrozen(element, false)
        setElementCollisionsEnabled(element,true)
        removeEventHandler("onClientPreRender",root,putPlayerInPosition)
        element = nil
    end
end

function rotFromCam(rzOffset)
    local cx,cy,_,fx,fy = getCameraMatrix(localPlayer)
    local deltaY,deltaX = fy-cy,fx-cx
    local rotZ = math.deg(math.atan((deltaY)/(deltaX)))
    if deltaY >= 0 and deltaX <= 0 then
        rotZ = rotZ+180
    elseif deltaY <= 0 and deltaX <= 0 then
        rotZ = rotZ+180
    end
    return -rotZ+90 + rzOffset
end

addEventHandler("onClientVehicleExit", getRootElement(), function()
    if source == element then
        toggleAirBrake()
    end
end)

addCommandHandler("fly", function()
	if getElementData(localPlayer, "adminlevel") < 1 then return end
	local veh = getPedOccupiedVehicle(localPlayer)
	element = veh and veh or localPlayer
	toggleAirBrake()
end)