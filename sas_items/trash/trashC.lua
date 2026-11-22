addCommandHandler("nearbykuka", function()
	if getElementData(localPlayer, "adminlevel") >= 8 then
		local found = false
        local px, py, pz = getElementPosition(localPlayer)
        
        outputChatBox("#7cc576[SeeMTA]: #ffffffKözeledben lévő kukák:", 255, 255, 255, true)
        
		for k, v in ipairs(getElementsByType("object"), getRootElement(), true) do
            if getElementModel(v) == 1359 then
                local x, y, z = getElementPosition(v)
                
				if getDistanceBetweenPoints3D(px, py, pz, x, y, z) <= 10 then
					found = true
					outputChatBox("#7cc576[SeeMTA]: #ffffffID: "..getElementData(v, "dbid"), 255, 255, 255, true)
				end
			end
		end
		if not found then
			outputChatBox("#7cc576[SeeMTA]: #ffffffNincs a közeledben kuka.", 255, 255, 255, true)
		end
	end
end)