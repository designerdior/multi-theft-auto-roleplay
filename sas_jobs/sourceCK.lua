jelenlegiMunka = 0
localPlayer = getLocalPlayer()

function jatekosSpawnMunka()
	if getElementData(localPlayer, "loggedin") then
		jelenlegiMunka = tonumber(getElementData(localPlayer, "job"))
		if (jelenlegiMunka == 1) then -- Buszos
			displayBusJob()
		else
			resetBusJob()
		end
		if (jelenlegiMunka == 2) then

		else

		end
		if (jelenlegiMunka == 3) then

		else

		end
		if (jelenlegiMunka == 4) then
		--	showTruckThings()
		else
		--	deleteTruckThings()
		end
		if (jelenlegiMunka == 5) then -- gyártósori
			showFactoryThings()
		else
			deleteFactoryThings()
		end
		if (jelenlegiMunka == 6) then

		else

		end
	end
end

addEventHandler("onClientPlayerSpawn", localPlayer,
	function()
		setTimer(jatekosSpawnMunka, 1000, 1)
	end
)

function munkaKilepesKliensOldal(munkaID)
	if(munkaID == 1) then
		resetBusJob()
	elseif(munkaID == 2) then

	elseif(munkaID == 3) then

	elseif(munkaID == 4) then
	--	deleteTruckThings()
	elseif(munkaID == 5) then
	  deleteFactoryThings()
	elseif(munkaID == 6) then

	end
end
addEvent( "munkaKelepesKliens", true )
addEventHandler( "munkaKelepesKliens", getRootElement(), munkaKilepesKliensOldal )

addEventHandler( "onClientResourceStart", getRootElement( ),
    function ( resource )
		if (resource ~= getThisResource()) then return end
        setTimer(jatekosSpawnMunka, 1000, 1)
    end
)

function showFactoryThings()
	outputChatBox("#7cc576[SeeMTA - Gyártósori munkás]: #FFFFFFA feladatod az, hogy összeszereld a termékeket a #d9534fgyárban#FFFFFF.", 0,0,0,true)
	outputChatBox("#7cc576[SeeMTA - Gyártósori munkás]: #FFFFFFMenj az irodába, és vedd fel a munkát a műszakvezetőtől. (Kattints az NPC-re.)", 0,0,0,true)
	factoryBlip = createBlip(-1997.3408203125, -2415.7900390625, 30.625, 60, 1, 217, 83, 79, 255)
end

function deleteFactoryThings()
	if isElement(factoryBlip) then
		destroyElement(factoryBlip)
	end
end
