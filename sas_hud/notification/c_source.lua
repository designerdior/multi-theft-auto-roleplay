local displayWidth, displayHeight = guiGetScreenSize();

local notificationData = {};

local notificationFont = dxCreateFont('notification/files/fonts/roboto.ttf', 24, false);

addEventHandler('onClientRender', root,
	function()
		for k, v in pairs(notificationData) do
			if (v.State == 'fadeIn') then
				local alphaProgress = (getTickCount() - v.AlphaTick) / 650;
				local alphaAnimation = interpolateBetween(0, 0, 0, 255, 0, 0, alphaProgress, 'Linear');

				if (alphaAnimation) then
					v.Alpha = alphaAnimation;
				else
					v.Alpha = 255;
				end

				if (alphaProgress > 1) then
					v.Tick = getTickCount();
					v.State = 'openTile';
				end
			elseif (v.State == 'fadeOut') then
				local alphaProgress = (getTickCount() - v.AlphaTick) / 650;
				local alphaAnimation = interpolateBetween(255, 0, 0, 0, 0, 0, alphaProgress, 'Linear');

				if (alphaAnimation) then
					v.Alpha = alphaAnimation;
				else
					v.Alpha = 0;
				end

				if (alphaProgress > 1) then
					notificationData = {};
				end
			elseif (v.State == 'openTile') then
				local tileProgress = (getTickCount() - v.Tick) / 350;
				local tilePosition = interpolateBetween(v.StartX, 0, 0, v.EndX, 0, 0, tileProgress, 'Linear');
				local tileWidth = interpolateBetween(0, 0, 0, v.Width, 0, 0, tileProgress, 'Linear');

				if (tilePosition and tileWidth) then
					v.CurrentX = tilePosition;
					v.CurrentWidth = tileWidth;
				else
					v.CurrentX = v.EndX;
					v.CurrentWidth = v.Width;
				end

				if (tileProgress > 1) then
					v.State = 'fixTile';

					setTimer(function()
						v.Tick = getTickCount();
						v.State = 'closeTile';
					end, string.len(v.Text) * 45 + 5000, 1);
				end
			elseif (v.State == 'closeTile') then
				local tileProgress = (getTickCount() - v.Tick) / 350;
				local tilePosition = interpolateBetween(v.EndX, 0, 0, v.StartX, 0, 0, tileProgress, 'Linear');
				local tileWidth = interpolateBetween(v.Width, 0, 0, 0, 0, 0, tileProgress, 'Linear');

				if (tilePosition and tileWidth) then
					v.CurrentX = tilePosition;
					v.CurrentWidth = tileWidth;
				else
					v.CurrentX = v.StartX;
					v.CurrentWidth = 0;
				end

				if (tileProgress > 1) then
					v.AlphaTick = getTickCount();
					v.State = 'fadeOut';
				end
			elseif (v.State == 'fixTile') then
				v.Alpha = 255;
				v.CurrentX = v.EndX;
				v.CurrentWidth = v.Width;
			end

			roundedRectangle(v.CurrentX, 20, 25+6 + v.CurrentWidth, 25+6, tocolor(0, 0, 0, 150 * v.Alpha / 255), nil, true);
			dxDrawRectangle(v.CurrentX, 20, 25+6, 25+6, tocolor(0, 0, 0, 255 * v.Alpha / 255), true);

			if (v.Alpha == 255) then
				dxDrawText(v.Text, v.CurrentX + 25 + 10+6, 20+6, v.CurrentX + 25 + 10+6 + v.CurrentWidth - 20, 20 + 25, tocolor(255, 255, 255, 255), 0.40, notificationFont, 'center', 'center', true, false, true);
			end

			if (v.Type == 'error') then
				dxDrawImage(v.CurrentX + 2, 20 + 2, 26, 26, "notification/files/e.png",0,0,0,tocolor(255, 255, 255, v.Alpha), true)
			elseif (v.Type == 'warning') then
				dxDrawImage(v.CurrentX + 2, 20 + 2, 26, 26, "notification/files/w.png",0,0,0,tocolor(255, 255, 255, v.Alpha), true)
			elseif (v.Type == 'info') then
			--	dxDrawImageSection(v.CurrentX + 2, 20 + 2, 20, 20, 22 + 5 + 22 + 5, 0, 20, 20, 'notification/files/images/icons.png', 0, 0, 0, tocolor(255, 255, 255, v.Alpha));
				dxDrawImage(v.CurrentX + 2, 20 + 2, 26, 26, "notification/files/i.png",0,0,0,tocolor(255, 255, 255, v.Alpha), true)
			elseif (v.Type == 'success') then
				dxDrawImage(v.CurrentX + 2, 20 + 2, 26, 26, "notification/files/s.png",0,0,0,tocolor(255, 255, 255, v.Alpha), true)
			end
		end
	end
)


addEvent ("addNewNotification",true)
addEventHandler ("addNewNotification",getRootElement(),
	function (text,type)
		addNotification(text,type)
	end
)


function addNotification(text, type)
	if (text and type) then
		if (notificationData ~= nil) then
			table.remove(notificationData, #notificationData);
		end

		table.insert(notificationData,
			{
				StartX = (displayWidth / 2) - (25 / 2),
				EndX = (displayWidth / 2) - ((dxGetTextWidth(text, 0.40, notificationFont) + 20 + 25) / 2),
				Text = text,
				Width = dxGetTextWidth(text, 0.40, notificationFont) + 20,
				Alpha = 0,
				State = 'fadeIn',
				Tick = 0,
				AlphaTick = getTickCount(),
				CurrentX = (displayWidth / 2) - (25 / 2),
				CurrentWidth = 0,
				Type = type or 'info'
			}
		);
		if type == "error" then
			figy = playSound("notification/files/e.mp3")
		elseif type == "info" then
			figy = playSound("notification/files/i.mp3")
		elseif type == "success" then
			figy = playSound("notification/files/s.mp3")
		elseif type == "warning" then
			figy = playSound("notification/files/w.mp3")
		end
		--setSoundVolume(figy, 0.2)
		--playSoundFrontEnd(11);
	end
end

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end

		if (not bgColor) then
			bgColor = borderColor;
		end

		--> Background
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);

		--> Border
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
end
