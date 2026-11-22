sx,sy = guiGetScreenSize ()
box = false
local guiInfoGui = {}
local guiInfoGuiState = false
local gui = {}
guiFont = dxCreateFont ("files/myriadproregular.ttf",14.5)
gui.width = 256
gui.height = 64
gui.x = sx/2-gui.width/2
gui.y = sy - gui.height
gui.nameX = gui.x+15
gui.nameY = gui.y+1
gui.nameX2 = gui.x+100
gui.nameY2 = gui.y+37
gui.descX = gui.x+16
gui.descY = gui.y+1
gui.descX2 = gui.x+40
gui.descY2 = gui.y+50

function showAlsoBox(inf, str)
	if box == false then
		if str and type(str) == "string" and string.len(str) > 0 then
			box = true
			showAlsoBoxX (str, inf,"files/select.png")
		end
	end
end

downBox = {}
downBox.path = ""
downBox.show = false
downBox.state = nil
downBox.string = nil
downBox.starTick = nil
downBox.currentY = nil
downBox.time = 1000
downBox.next = nil
downBox.nextPath = ""
downBox.timer = nil
downBox.startY = -60
downBox.stopY = 120

function showAlsoBoxX (str,info,path)
	if str then
		if path == nil then
			path = "img/info.png"
		end
		if fileExists (path) then
			if downBox.show == true then
				downBox.next = str
				downBox.nextPath = path
			else
				downBox.path = path
				downBox.show = true
				downBox.state = "starting"
				downBox.string = str
				downBox.info = info
				downBox.startTick = getTickCount()
				box = true
			end
		end
	end
end

addEventHandler ("onClientRender", getRootElement(),
	function ()
		if downBox.show == true and downBox.string then
			local width = dxGetTextWidth (downBox.string, 1, "default-bold")
			if width then			
				dxDrawImage (gui.x,gui.y,gui.width,gui.height,"files/select.png")
				dxDrawText (downBox.info,gui.nameX,gui.nameY,gui.nameX2,gui.nameY2,tocolor(44,147,222),0.85,guiFont,"left","center")
				dxDrawText (downBox.string,gui.descX,gui.descY,gui.descX2,gui.descY2,tocolor(205,205,205),0.55,guiFont,"left","top")
			end
		end
	end
)