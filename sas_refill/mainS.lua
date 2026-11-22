setTimer(function()
	local newPetrol = math.random(1, 6)
	setElementData(root, "Fuel->petrol_price", newPetrol)
	local newDiesel = math.random(1, 4)
	setElementData(root, "Fuel->diesel_price", newDiesel)

	for k, v in ipairs(getElementsByType("player")) do
		setElementData(v, "Fuel->refreshTable", false)
	end
end, 1000 * 60 * 60, 0)

for k, v in ipairs(getElementsByType("player")) do
	setElementData(v, "Fuel->refreshTable", false)
end
-- setElementData(root, "Fuel->refreshTable", false)
setElementData(root, "Fuel->petrol_price", math.random(1, 6))
setElementData(root, "Fuel->diesel_price", math.random(1, 4))
