local displayWidth, displayHeight = guiGetScreenSize();

local notificationData = {};

local notificationFont = dxCreateFont('kickban/files/fonts/roboto.ttf', 12 * 2, false);

addEventHandler('onClientRender', root,
	function()
		for k, v in pairs(notificationData) do
			if (v.State == 'fadeIn') then
			--	v.Width = 325
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
			local lekeresX, lekeresY = exports.sas_hud:getNode(15, "x"), exports.sas_hud:getNode(15, "y")
			local isShowing = exports.sas_hud:getNode(15, "showing")
			if isShowing or getElementData(localPlayer, "valaszto") then
				roundedRectangle(lekeresX+v.CurrentX-v.StartX+100+45, lekeresY, 40 + v.CurrentWidth, 40, tocolor(0, 0, 0, 150 * v.Alpha / 255));
				dxDrawRectangle(lekeresX+v.CurrentX-v.StartX+100+45, lekeresY, 40, 40, tocolor(0, 0, 0, 255 * v.Alpha / 255));
			--	roundedRectangle(lekeresX+v.CurrentX-v.StartX, lekeresY, 25+6 + v.CurrentWidth, 25+6, tocolor(0, 0, 0, 150 * v.Alpha / 255));
			--	dxDrawRectangle(lekeresX+v.CurrentX-v.StartX, lekeresY, 25+6, 25+6, tocolor(0, 0, 0, 255 * v.Alpha / 255));
				local textcolorRGB = {255,255,255}
				if (v.Type == 'kick') then
					dxDrawImage(lekeresX+v.CurrentX-v.StartX+100+45-1, lekeresY, 40, 40, "kickban/files/kick.png",0,0,0,tocolor(255, 127, 0, v.Alpha))
					textcolorRGB = {255, 127, 0}
				elseif (v.Type == 'ban') then
					dxDrawImage(lekeresX+v.CurrentX-v.StartX+100+45-1, lekeresY, 40, 40, "kickban/files/ban.png",0,0,0,tocolor(255, 80, 80, v.Alpha))
					textcolorRGB = {255, 80, 80}
				end
				if (v.Alpha == 255) then
					dxDrawText(v.Text, lekeresX+v.CurrentX-v.StartX+100+45 + 25 + 10+6+5, lekeresY+20+6-35-6, lekeresX+v.CurrentX-v.StartX+100+45 + 25 + 10+6 + v.CurrentWidth - 20+5, lekeresY+20 + 25-10, tocolor(textcolorRGB[1], textcolorRGB[2], textcolorRGB[3], 255), 0.40, notificationFont, 'center', 'center', true);
					dxDrawText(v.Text2, lekeresX+v.CurrentX-v.StartX+100+45 + 25 + 10+6+5, lekeresY+20+6-6, lekeresX+v.CurrentX-v.StartX+100+45 + 25 + 10+6 + v.CurrentWidth - 20+5, lekeresY+20 + 25-10, tocolor(255, 255, 255, 255), 0.40, notificationFont, 'left', 'center', true);
				end
			end
		end
	end
)


addEvent ("addNewKickban",true)
addEventHandler ("addNewKickban",getRootElement(),
	function (text,type, text2)
		addKickban(text,type, text2)
	end
)

function probakick()
	addKickban("Thomas Makarov kickelte: Farkas Tamás-t", "kick", "Indok: perelve")
end
addCommandHandler("probakick", probakick)

function probakick()
	addKickban("Thomas Makarov bannolta: Farkas Tamás-t", "ban", "Indok: perelve")
end
addCommandHandler("probaban", probakick)


function addKickban(text, type, text2)
	if (text and type and text2) then
		if (notificationData ~= nil) then
			table.remove(notificationData, #notificationData);
		end

		table.insert(notificationData,
			{
				StartX = (displayWidth / 2) - (25 / 2),
				EndX = (displayWidth / 2) - ((dxGetTextWidth(text, 0.40, notificationFont) + 20 + 25) / 2),
				Text = text,
				Text2 = text2,
				Width = dxGetTextWidth(text, 0.40, notificationFont) + 20,
				Alpha = 0,
				State = 'fadeIn',
				Tick = 0,
				AlphaTick = getTickCount(),
				CurrentX = (displayWidth / 2) - (25 / 2),
				CurrentWidth = 0,
				Type = type or 'kick'
			}
		);
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
