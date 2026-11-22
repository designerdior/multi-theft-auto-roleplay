local abKapcsolat = exports.sas_mysql:getConnection()

function createLicenseVehicle()
	local x, y, z = 341.7431640625, -1351.0244140625, 14.5078125
	local vehicle = createVehicle(436, x, y, z,0,0,122.16162109375)
	pedLicencer = createPed(62, x, y, z)

  	setElementData(pedLicencer,	"nameEnabled",true)
  	setElementData(pedLicencer, "visiblePedName", "Oktató" )
	setElementData(pedLicencer, "tagName", "NPC" )
  --setElementData(identityPed, "isLicencerPed", true )
	warpPedIntoVehicle(pedLicencer, vehicle, 1)

	setElementHealth(vehicle, 1000)
	setVehicleColor ( vehicle, 255, 255, 255, 255, 255, 255)
	setVehicleHeadLightColor ( vehicle, 255, 255, 255 )

	setElementData(vehicle, "enginebroke", 0)
	setElementData(vehicle, "dbid", -1)
	setElementData(vehicle, "owner", -1)
	setElementData(vehicle, "fuel", 100)
	setElementData(vehicle, "engine", 0)
	setElementData(vehicle, "lights", 0)
	setElementData(vehicle, "faction", -1)
	setElementData(vehicle, "handbrake", 1)
	setElementFrozen(vehicle, true)
	setTimer(function()
		setVehicleEngineState(vehicle, false)
	end, 100, 1)
	setVehicleRespawnPosition(vehicle, x,y,z,0,0,90)
	warpPedIntoVehicle(client, vehicle, 0)
end

addEvent("createLicenseVehicle", true)
addEventHandler("createLicenseVehicle", getRootElement(), createLicenseVehicle)

addEvent("finishLicense", true)
addEventHandler("finishLicense", getRootElement(),
	function()
		if client then
			destroyElement(getPedOccupiedVehicle(client))
			setTimer(function()
				if isElement(pedLicencer) then
					destroyElement(pedLicencer)
				end
			end,200, 0)
			triggerEvent("InzertSQLJogsi", client, client)
		end
	end
)

addEvent("failedLicense", true)
addEventHandler("failedLicense", getRootElement(),
	function()
		if client then
			destroyElement(getPedOccupiedVehicle(client))
			setTimer(function()
				if isElement(pedLicencer) then
					destroyElement(pedLicencer)
				end
			end,200, 0)
		end
	end
)




function giveLicense()
	setElementData(source, "license.car", 1)
	dbExec(abKapcsolat, "UPDATE characters SET car_license=1 WHERE charname=?", getPlayerName(source))
end
addEvent("acceptLicense", true)
addEventHandler("acceptLicense", getRootElement(), giveLicense)

function payFee(amount)
	setElementData(source, "money", getElementData(source, "money") - amount)
end
addEvent("payFee", true)
addEventHandler("payFee", getRootElement(), payFee)

function passTheory()
	setElementData(source, "license.car", 3) -- Set data to "theory passed"
	dbExec(abKapcsolat, "UPDATE characters SET car_license=3 WHERE charname=?", getPlayerName(source))
end
addEvent("theoryComplete", true)
addEventHandler("theoryComplete", getRootElement(), passTheory)
