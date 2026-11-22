local nametags = { }
local nevekbe = false
-- settings
local _max_distance = 300
local _sub_rpguard_distance = 260

local _adminszoli_tavolsag = 20
local _adminszoli_textsize = 1.3

local _min_distance = 7.5
local _alpha_distance = 20
local _nametag_alpha = 170
local _bar_alpha = 300
local _scale = 0.2
local _nametag_textsize = 1.2
local _chatbubble_size = 15
local _bar_width = 40
local _bar_height = 6
local _bar_border = 1.2
local roboto = dxCreateFont ("files/roboto.ttf",10)
local robotolight = dxCreateFont ("files/roboto_light.ttf",10)

local chatState = true

bindKey("F9","down",function()
	if getElementData(localPlayer, "loggedin") then
		chatState = not chatState
		showChat(chatState)
	end
end)

local _, screenY = guiGetScreenSize( )
real_scale = screenY / ( _scale * 800 )
local _alpha_distance_diff = _max_distance - _alpha_distance

addEventHandler( 'onClientRender', root,
	function( )
		if nevekbe == true then
			local cx, cy, cz = getCameraMatrix( )
			local dimension = getElementDimension( localPlayer )
			local interior = getElementInterior( localPlayer )
			_max_distance = 300

			for player, chaticon in pairs( nametags ) do
				if isElement( player ) and getElementDimension( player ) == dimension and getElementInterior( player ) == interior and isElementOnScreen( player ) then
					_max_distance_localed = 300
					local px, py, pz = getElementPosition( player )
					local trpx, trpy, trpz = getElementPosition( localPlayer )
					local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
					local hit = isLineOfSightClear(px, py, pz, trpx, trpy, trpz, true, false, false, true, true, false, false, nil)
					local reconp = getCameraTarget ( localPlayer )
					if getElementData(localPlayer, "adminlevel") == 1 then
						hit = true
					else
						if reconp then
							trpx, trpy, trpz = getElementPosition( reconp )
							hit = isLineOfSightClear(px, py, pz, trpx, trpy, trpz, true, false, false, true, true, false, false, nil)
						end
					end
					if distance <= _max_distance and hit then
						local dz = 1 + 2 * math.min( 1, distance / _min_distance ) * _scale
						if isPedDucked( player ) then
							dz = dz / 2
						end
						pz = pz + dz
						local sx, sy = getScreenFromWorldPosition( px, py, pz )
						if sx and sy then
							local cx = sx

							distance = math.max( distance, _min_distance )
							local scale = 1

							local alpha = ( ( distance - _alpha_distance ) / _alpha_distance_diff )
							local bar_alpha = ( ( alpha < 0 ) and _bar_alpha or _bar_alpha - (alpha * _bar_alpha) ) * ( getElementData( localPlayer, "collisionless" ) and 1 or getElementAlpha( player ) / 255 )
							if bar_alpha > 0 then
								local nametag_alpha = 1000 --bar_alpha / _bar_alpha * _nametag_alpha

								local jatekosid = tonumber(getElementData(player, "playerid"))
								--dxDrawText("" .. getPlayerName(player):gsub("_", " ").." (".. jatekosid ..")", sx+1, sy+1, sx+1, sy+1, tocolor( 0, 0, 0), scale * _nametag_textsize, roboto, 'center', 'bottom' )
								--dxDrawText("" .. getPlayerName(player):gsub("_", " ").." (".. jatekosid ..")", sx, sy, sx, sy, tocolor( 255, 0, 0), scale * _nametag_textsize, robotolight, 'center', 'bottom' )

								--if tonumber(getElementData( localPlayer, "acc.rpGuard" )) > 0 then
									-- draw the health bar
									local width, height = math.ceil( _bar_width * scale ), math.ceil( _bar_height * scale )
									local sx = sx - width / 2
									local border = math.ceil( _bar_border * scale )

									-- draw the armor bar
									local armor = math.min( 100, getPedArmor( player ) )
									if armor > 0 then

										-- outer background
										--dxDrawRectangle( sx, sy, width, height, tocolor( 0, 0, 0, bar_alpha ) )

										-- get the colors
										local r, g, b = 255, 255, 255

										-- inner background, which fills the whole bar but is somewhat transparent
										--dxDrawRectangle( sx + border, sy + border, width - 2 * border, height - 2 * border, tocolor( r, g, b, 0.4 * bar_alpha ) )

										-- fill it with the actual armor
										--dxDrawRectangle( sx + border, sy + border, math.floor( ( width - 2 * border ) / 100 * getPedArmor( player ) ), height - 2 * border, tocolor( r, g, b, bar_alpha ) )

										-- set the nametag below
										sy = sy + 1.2 * height
									end

									-- outer background
									--dxDrawRectangle( sx, sy, width, height, tocolor( 0, 0, 0, bar_alpha ) )

									-- get the colors
									local health = math.min( 100, getElementHealth( player ) )
									local r, g, b = 255 - 255 * health / 100, 255 * health / 100, 0

									-- inner background, which fills the whole bar but is somewhat transparent
									--dxDrawRectangle( sx + border, sy + border, width - 2 * border, height - 2 * border, tocolor( r, g, b, 0.4 * bar_alpha ) )

									-- fill it with the actual health
									--dxDrawRectangle( sx + border, sy + border, math.floor( ( width - 2 * border ) / 100 * health ), height - 2 * border, tocolor( r, g, b, bar_alpha ) )
								--end
							end
						end
					end
				end
			end
		--else
		end
		-- get the camera position of the local player
			local cx, cy, cz = getCameraMatrix( )
			local dimension = getElementDimension( localPlayer )
			local interior = getElementInterior( localPlayer )

			-- loop through all players
			for player, chaticon in pairs( nametags ) do
				if isElement( player ) and getElementDimension( player ) == dimension and getElementInterior( player ) == interior and isElementOnScreen( player ) then
					local px, py, pz = getElementPosition( player )
					local distance = getDistanceBetweenPoints3D( px, py, pz, cx, cy, cz )
					local distanceadmin = distance
					local distancetraff = distance
					--local traffipaxlocal = getElementData ( localPlayer, "traffipax" ) or 0
					traffipaxlocal = 0
					if distance <= _adminszoli_tavolsag or traffipaxlocal == 1 then
						local dz = 1 + 2 * math.min( 1, distance / _min_distance ) * _scale
						if isPedDucked( player ) then
							dz = dz / 2
						end
						pz = pz + dz
						local sx, sy = getScreenFromWorldPosition( px, py, pz )
						if sx and sy then
							local cx = sx

							distance = math.max( distance, _min_distance )
							local scale = 1

							local alpha = ( ( distance - _alpha_distance ) / _alpha_distance_diff )
							local bar_alpha = ( ( alpha < 0 ) and _bar_alpha or _bar_alpha - (alpha * _bar_alpha) ) * ( getElementData( localPlayer, "collisionless" ) and 1 or getElementAlpha( player ) / 255 )
							if bar_alpha > 0 then
								local nametag_alpha = 1000

								local adminduty = getElementData ( player, "adminDuty" )
								local traffipax = getElementData ( player, "traffipax" ) or 0
								if traffipax == 1 and distancetraff <= 10 then
									local traffispeed = getElementData(player, "traffipaxspeed") or 0
									dxDrawText("-=[TRAFFIPAX]=- \n " .. traffispeed .." km/h \n ((Közeledésed MG gyanús!))", sx, sy+10, sx, sy+10, tocolor( 0, 128, 255, 255 ), scale * 1.4, 'default', 'center', 'bottom' )
								end
								local trpx, trpy, trpz = getElementPosition( localPlayer )
								local dtraf = getDistanceBetweenPoints3D( px, py, pz, trpx, trpy, trpz )
								local hit = isLineOfSightClear(px, py, pz, trpx, trpy, trpz, true, false, true, true, true, false, false, nil)
								hit = true -- hacky way
								local theVehicle = getPedOccupiedVehicle(player)
								if traffipaxlocal == 1 and dtraf <= 120 and hit then
									if theVehicle then
										local driver = getVehicleOccupant(theVehicle)
										if driver == player then
											--local actualspeed = exports.sas_global:getVehicleVelocity(theVehicle)
											if actualspeed ~= 0 then
												--dxDrawText("-=[TRAFFIPAX]=- \n Mérés -> " .. tonumber(math.ceil(actualspeed)) .." km/h <-", sx, sy+45, sx, sy+45, tocolor( 0, 128, 255, 255 ), scale * 1.0, 'default', 'center', 'bottom' )
												dxDrawText("-=[TRAFFIPAX]=- hatótávon belül", sx, sy+45, sx, sy+45, tocolor( 0, 128, 255, 255 ), scale * 1.0, 'default', 'center', 'bottom' )
											end
										end
									end
								end
							end
						end
					end
				end
			end
		--end
	end
)

addEventHandler( 'onClientResourceStart', getResourceRootElement( ),
	function( )
		for _, player in pairs( getElementsByType( 'player' ) ) do
			if player ~= localPlayer then
				setPlayerNametagShowing( player, false )

				if isElementStreamedIn( player ) then
					nametags[ player ] = false
				end
			end
		end
	end
)

addEventHandler( 'onClientResourceStop', getResourceRootElement( ),
	function( )
		for player in pairs( nametags ) do
			setPlayerNametagShowing( player, true )

			nametags[ player ] = nil
		end
	end
)

addEventHandler ( 'onClientPlayerJoin', root,
	function( )
		setPlayerNametagShowing( source, false )
	end
)

addEventHandler ( 'onClientElementStreamIn', root,
	function( )
		if source ~= localPlayer and getElementType( source ) == "player" then
			nametags[ source ] = false

			--triggerServerEvent( "nametags:chatbubble", source )
		end
	end
)

addEventHandler ( 'onClientElementStreamOut', root,
	function( )
		if nametags[ source ] then
			nametags[ source ] = nil
		end
	end
)

addEventHandler ( 'onClientPlayerQuit', root,
	function( )
		if nametags[ source ] then
			nametags[ source ] = nil
		end
	end
)


--

function TogNevek()
	local adminszint = getElementData( localPlayer, "adminlevel" ) or 0
	if adminszint > 0 then
		nevekbe = not nevekbe
		if nevekbe == true then
			outputChatBox ("#7cc576[SeeMTA]: #FFFFFF Nevek bekapcsolva.",0,0,0,true)
		else
			outputChatBox ("#7cc576[SeeMTA]: #FFFFFFNevek kikapcsolva.",0,0,0,true)
		end
	end
end
addCommandHandler("nevek",TogNevek, false)
