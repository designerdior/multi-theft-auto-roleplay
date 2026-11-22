local sx, sy = guiGetScreenSize()

local moveType = "left"
local spacer = 0

addEventHandler("onClientResourceStart", resourceRoot, function()
	blurShader, blurTec = dxCreateShader("files/blur.fx")
end)

--- LSD

function setLsdScreen(state)
	if state then
		addEventHandler("onClientRender", root, renderLsdScreen)
		screen = dxCreateScreenSource(sx, sy)

		setGameSpeed(0.6)
		setCameraGoggleEffect("nightvision")

		setTimer(function()
			setElementData(localPlayer,"drugUsing",false)
			setLsdScreen(false)
		end, 120000, 1)
	else
		removeEventHandler("onClientRender", root, renderLsdScreen)

		setGameSpeed(1)
		setCameraGoggleEffect("normal")
	end
end
addEvent("setLsdScreen", true)
addEventHandler("setLsdScreen", getRootElement(), setLsdScreen)

function renderLsdScreen()
	dxUpdateScreenSource(screen, true)

	if screen then
		if spacer == -50 and moveType == "left" then
			moveType = "right"
		elseif spacer == 0 and moveType == "right" then
			moveType = "left"
		end

		if moveType == "left" then
			spacer = spacer - 0.5
		elseif moveType == "right" then
			spacer = spacer + 0.5
		end

		dxDrawImage(spacer, -25, sx + 250, sy + 50, screen)
		dxDrawRectangle(0, 0, sx, sy, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end
end

--- SPEED

function setSpeedScreen(state)
	if state then
		addEventHandler("onClientRender", root, renderSpeedScreen)
		screen = dxCreateScreenSource(sx, sy)

		setGameSpeed(1.2)
		setCameraGoggleEffect("thermalvision")

		setTimer(function()
			setElementData(localPlayer,"drugUsing",false)
			setSpeedScreen(false)
		end, 60000*(math.random(1,3)), 1)
	else
		removeEventHandler("onClientRender", root, renderSpeedScreen)

		setGameSpeed(1)
		setCameraGoggleEffect("normal")
	end
end

function renderSpeedScreen()
	dxUpdateScreenSource(screen, true)

	if screen then
		if spacer == -50 and moveType == "left" then
			moveType = "right"
		elseif spacer == 0 and moveType == "right" then
			moveType = "left"
		end

		if moveType == "left" then
			spacer = spacer - 5
		elseif moveType == "right" then
			spacer = spacer + 5
		end

		dxDrawImage(spacer, -25, sx + 50, sy + 100, screen)
	end
end

--- FÜVES CIGI

function setMarijuanaScreen(state)
	if state then
		addEventHandler("onClientRender", root, renderMarijuanaScreen)
		screen = dxCreateScreenSource(sx, sy)

		setTimer(function()
			setElementData(localPlayer,"drugUsing",false)
			setMarijuanaScreen(false)
		end, 20000, 1)
	else
		removeEventHandler("onClientRender", root, renderMarijuanaScreen)
	end
end

function renderMarijuanaScreen()
	if blurShader then
		dxUpdateScreenSource(screen)

		dxSetShaderValue(blurShader, "ScreenSource", screen)
		dxSetShaderValue(blurShader, "BlurStrength", 25)
		dxSetShaderValue(blurShader, "UVSize", sx, sy)

		dxDrawImage(0, 0, sx, sy, blurShader)
	end

	dxUpdateScreenSource(screen, true)

	if screen then
		if spacer == -50 and moveType == "left" then
			moveType = "right"
		elseif spacer == 0 and moveType == "right" then
			moveType = "left"
		end

		if moveType == "left" then
			spacer = spacer - 0.5
		elseif moveType == "right" then
			spacer = spacer + 0.5
		end

		dxDrawImage(spacer, -25, sx + 50, sy + 50, screen)
	end
end

--- HEROIN

function setHeroinScreen(state)
	if state then
		addEventHandler("onClientRender", root, renderHeroinScreen)
		screen = dxCreateScreenSource(sx, sy)

		setTimer(function()
			setElementData(localPlayer,"drugUsing",false)
			setHeroinScreen(false)
		end, 60000*(math.random(1,3)), 1)

		setGameSpeed(0.8)
	else
		removeEventHandler("onClientRender", root, renderHeroinScreen)

		setGameSpeed(1)
	end
end

function renderHeroinScreen()
	if blurShader then
		dxUpdateScreenSource(screen)

		dxSetShaderValue(blurShader, "ScreenSource", screen)
		dxSetShaderValue(blurShader, "BlurStrength", 15)
		dxSetShaderValue(blurShader, "UVSize", sx, sy)

		dxDrawImage(0, 0, sx, sy, blurShader)
	end

	dxUpdateScreenSource(screen, true)
end

--- GOMBA

function setMushroomScreen(state)
	if state then
		addEventHandler("onClientRender", root, renderMushroomScreen)
		screen = dxCreateScreenSource(sx, sy)

		setGameSpeed(0.6)
		setCameraGoggleEffect("nightvision")

		setTimer(function()
			setElementData(localPlayer,"drugUsing",false)
			setMushroomScreen(false)
		end, 120000, 1)

		createdElements = {}
	else
		removeEventHandler("onClientRender", root, renderMushroomScreen)

		for key, value in ipairs(createdElements) do
			if isElement(value) then
				destroyElement(value)
			end
		end

		setGameSpeed(1)
		setCameraGoggleEffect("normal")
	end
end
addEvent("setMushroomScreen", true)
addEventHandler("setMushroomScreen", getRootElement(), setMushroomScreen)

function renderMushroomScreen()
	dxUpdateScreenSource(screen, true)

	if screen then
		if spacer == -50 and moveType == "left" then
			moveType = "right"
		elseif spacer == 0 and moveType == "right" then
			moveType = "left"
		end

		if moveType == "left" then
			spacer = spacer - 0.5
		elseif moveType == "right" then
			spacer = spacer + 0.5
		end

		dxDrawImage(spacer, -25, sx + 250, sy + 50, screen)
		dxDrawRectangle(0, 0, sx, sy, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))

		if getTickCount() % 60 == 0 then
			for key, value in ipairs(createdElements) do
				if isElement(value) then
					destroyElement(value)
				end
			end

			local x, y, z = getElementPosition(localPlayer)
			for key = 1, 12 do
				createdElements[key] = createPed(264, x + math.random(-2, 2), y + math.random(-2, 2), z, math.random(0, 360))
			end
		end
	end
end
