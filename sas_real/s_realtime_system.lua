function updateTime()
	local offset = tonumber(get("offset"))
	local realtime = getRealTime()
	hour = realtime.hour + offset
	hour = hour + 1
	if hour >= 24 then
		hour = hour - 24
	elseif hour < 0 then
		hour = hour + 24
	end

	minute = realtime.minute

	setTime(hour, minute)

	nextupdate = (60-realtime.second) * 1000
	setMinuteDuration( nextupdate )
	setTimer( setMinuteDuration, nextupdate + 5, 1, 60000 )
end

addEventHandler("onResourceStart", getResourceRootElement(), updateTime )

setTimer( updateTime, 1800000, 0 )