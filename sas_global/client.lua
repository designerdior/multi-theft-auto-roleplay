addEvent("sendMessageToAdmins", true)
addEventHandler("sendMessageToAdmins", localPlayer, function(msg)
  if getElementData(localPlayer, "adminlevel") > 0 then
    outputChatBox(msg, 255, 255, 255, true)
  end
end)