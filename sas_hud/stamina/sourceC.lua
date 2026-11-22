local currentStamina = 100
displayStamina = 0
FPS = 0

local isJumped = false
local controlsState = true

local increaseValue = 0.0075
local decreaseValue = 0.00675

local adminDuty = false
local drugStaminaOff = false
local playerGlueState = false

addEventHandler("onClientResourceStart", resourceRoot, function()
	adminDuty = getElementData(localPlayer, "adminduty") or false
	drugStaminaOff = getElementData(localPlayer, "drugStaminaOff") or false
	playerGlueState = getElementData(localPlayer, "playerGlueState") or false
end)

addEventHandler("onClientElementDataChange", getRootElement(), function(dataName, oldValue, newValue)
	if dataName == "adminduty" and newValue then
		adminDuty = newValue
	end

	if dataName == "drugStaminaOff" then
		drugStaminaOff = newValue
	end

	if dataName == "playerGlueState" then
		playerGlueState = newValue
	end
end)

setTimer(function()
	FPS = math.floor(currentFPS or 0)
end, 1000, 0)

addEventHandler("onClientPreRender", getRootElement(), function(timeSlice)
	currentFPS = (1 / timeSlice) * 1000
	if not adminDuty then
		local playerVelX, playerVelY, playerVelZ = getElementVelocity(localPlayer)
		local actualSpeed = (playerVelX * playerVelX + playerVelY * playerVelY) ^ 0.5

		if playerVelZ >= 0.1 and not isJumped and not occupiedVehicle and not drugStaminaOff and not playerGlueState then
			isJumped = true
			currentStamina = currentStamina - 6.5

			if currentStamina <= 0 then
				currentStamina = 0

				if controlsState then
					triggerServerEvent("tiredAnimOn", localPlayer, localPlayer,true)
					controlsState = false
				end
			end
		end

		if playerVelZ < 0.05 then
			isJumped = false
		end
		displayStamina = currentStamina
		if actualSpeed < 0.05 and not isJumped then
			if currentStamina <= 100 then
				if currentStamina > 25 then
					if not controlsState then
						triggerServerEvent("tiredAnimOn", localPlayer, localPlayer, false)
						controlsState = true
					end

					currentStamina = currentStamina + increaseValue * timeSlice
				else
					currentStamina = currentStamina + increaseValue * timeSlice * 0.75
				end
			else
				currentStamina = 100
			end
		elseif actualSpeed >= 0.1 and not occupiedVehicle and not drugStaminaOff and not playerGlueState then
			if currentStamina >= 0 then
				currentStamina = currentStamina - decreaseValue * timeSlice
			else
				currentStamina = 0

				if controlsState then
					triggerServerEvent("tiredAnimOn", localPlayer, localPlayer,true)
					controlsState = false
				end
			end
		end
		setPedControlState("walk", true)
		displayStamina = currentStamina*getNode(4, "width")/100
	end
end)