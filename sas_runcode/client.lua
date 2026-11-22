function runString(commandstring)
	outputDebugString("Kliens-oldali parancs lefuttatása: "..commandstring, 0)
	local notReturned
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		outputDebugString("Hiba: "..errorMsg, 1)
		return
	end
	local results = { pcall(commandFunction) }
	if not results[1] then
		outputDebugString("Hiba: "..results[2], 1)
		return
	end

	local resultsString = ""
	local first = true
	for i = 2, #results do
		if first then
			first = false
		else
			resultsString = resultsString..", "
		end
		local resultType = type(results[i])
		if isElement(results[i]) then
			resultType = "element:"..getElementType(results[i])
		end
		resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
	end

	if #results > 1 then
		outputDebugString("Eredmény: " ..resultsString, 3)
		return
	end
end

addCommandHandler("crun", function(cmd, ...)
	if getElementData(localPlayer, "admin") < 9 then return end
	runString(table.concat({...}, " "))
end)