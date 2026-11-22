function tiredAnimOn(player, state)
    if state then
      setPedAnimation(player, "fat", "idle_tired", -1, true, false, true)
    elseif not state then
      setPedAnimation(player)
    end
end
addEvent("tiredAnimOn", true)
addEventHandler("tiredAnimOn", root, tiredAnimOn)
