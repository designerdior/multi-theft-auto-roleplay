function setCraftingAnim(type)
	if(type) then
		exports.sas_global:applyAnimation(source, "shop", "shp_serve_loop", -1, true, true, true)
	else
		exports.sas_global:removeAnimation(source)
	end
end
addEvent("setCraftingAnim", true)
addEventHandler("setCraftingAnim", getRootElement(), setCraftingAnim)
