
local currentWeather = 10
local interior = false
function ChangePlayerWeather(weather)
	currentWeather = weather
	interior = false
end
addEvent( "onServerChangesWeather", true )
addEventHandler( "onServerChangesWeather", getRootElement(), ChangePlayerWeather )

addEventHandler( "onClientRender", getRootElement( ),
	function( )
		if getElementInterior( getLocalPlayer( ) ) > 0 and not interior then
			interior = true
			setWeather( 3 )
			setSkyGradient( 0, 0, 0, 0, 0, 0 )
		elseif getElementInterior( getLocalPlayer( ) ) == 0 and interior then
			interior = false
			setWeather( currentWeather )
			resetSkyGradient( )
		end
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement( ),
	function( )
		triggerServerEvent( "requestCurrentWeather", getLocalPlayer( ) )
	end
)
