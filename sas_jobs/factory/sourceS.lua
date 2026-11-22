countSaveMarker = createMarker(2559.0810546875, -1306.802734375, 1044.125, "cylinder", 1, 0,0,0,0)
setElementData(countSaveMarker, "countmarker", true)
setElementData(countSaveMarker, "radiocount", 0)
setElementData(countSaveMarker, "lampcount", 0)
setElementData(countSaveMarker, "diktafoncount", 0)

setElementData(countSaveMarker, "walkiecount", 0)
setElementData(countSaveMarker, "tapcount", 0)
setElementData(countSaveMarker, "countercount", 0)


function addCountToTable(counttype)
	if counttype == "radio" then
		setElementData(countSaveMarker, "radiocount", getElementData(countSaveMarker, "radiocount")+1)
	elseif counttype == "lamp" then
		setElementData(countSaveMarker, "lampcount", getElementData(countSaveMarker, "lampcount")+1)
	elseif counttype == "diktafon" then
		setElementData(countSaveMarker, "diktafoncount", getElementData(countSaveMarker, "diktafoncount")+1)
	elseif counttype == "walkie" then
		setElementData(countSaveMarker, "walkiecount", getElementData(countSaveMarker, "walkiecount")+1)
	elseif counttype == "tap" then
		setElementData(countSaveMarker, "tapcount", getElementData(countSaveMarker, "tapcount")+1)
	elseif counttype == "counter" then
		setElementData(countSaveMarker, "countercount", getElementData(countSaveMarker, "countercount")+1)
	end
end
addEvent("addCountToTable", true)
addEventHandler("addCountToTable", getRootElement(), addCountToTable)

function munkaAnimacio(tipus)
	if(tipus) then
		exports.sas_global:applyAnimation(source, "carry", "liftup", -1, true, true, true)
	else
		exports.sas_global:removeAnimation(source)
	end
end
addEvent("munkaAnimacio", true)
addEventHandler("munkaAnimacio", getRootElement(), munkaAnimacio)

function putDownAnim(tipus)
	if(tipus) then
		exports.sas_global:applyAnimation(source, "carry", "putdwn05", -1, true, true, true)
	else
		exports.sas_global:removeAnimation(source)
	end
end
addEvent("putDownAnim", true)
addEventHandler("putDownAnim", getRootElement(), putDownAnim)

function payForWork(player, amount)
		setElementData(player, "money", getElementData(player, "money")+amount)
end
addEvent("payForWork", true)
addEventHandler("payForWork", getRootElement(), payForWork)
