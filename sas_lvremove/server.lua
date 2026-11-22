totalTempVehicles = 500
function allvehspawn(commName,thePlayer)
	local i = 1
	for id = 500,600 do 
         theVehicle = createVehicle(id, 1965.6591796875+i, -2493.8818359375, 13.53911781311,0,0,0,"LKS-111")
 
       	setElementData(theVehicle, "dbid",totalTempVehicles)
		setElementData(theVehicle, "job", -1)
		setElementData(theVehicle, "owner", -1,false)
		setElementData(theVehicle, "faction", -1)
		setElementData(theVehicle, "fuel", 100)
		setTimer(function()
		 setVehicleEngineState(theVehicle, false)
	    end,100,1)
		setVehiclePlateText(theVehicle, "RENT-"..totalTempVehicles)
		--setVehicleRespawnPosition(theVehicle, x,y,z,0,0,90)
		i = i -5
		totalTempVehicles = totalTempVehicles + 1
    end
end
addCommandHandler("allvehspawn", allvehspawn)