--
-- c_rays.lua
--
local bRaysEnabled = false
local myScreenSource
local bAllValid


local shineDirectionList = {
			-- H   M		x,	y, 		z,			color (RGBA)	 range  brightness
			{  0,  0,	-0.914,	0.378, 0.000,	1.0, 0.7, 0.1, 0.01, -0.2, -20.0},	-- Night
			{  5,  9,	-0.914,	0.378, 0.000,	1.0, 0.7, 0.1, 0.01, -0.2, -20.0},	-- Night

			{  5, 15,	-0.914,	0.378, 0.000,	1.0, 0.8, 0.4, 1.4, -0.2, -2.2},	-- Sun fade in stard
			{  6, 50,	-0.914,	0.378, -0.246,	1.0, 0.8, 0.4, 1.4, -0.3, -2.2},	-- Sun fade in end
			{  7,  0,	-0.891,	0.378, -0.301,	1.0, 0.8, 0.6, 1.2, -0.3, -2.3},	-- Sun
			{ 10,  0,	-0.679,	0.405, -0.613,	1.0, 1.0, 0.95, 1.0, -0.5, -2.4},	-- Sun
			{ 13,  0,	-0.304,	0.491, -0.817,	1.0, 1.0, 0.95, 1.0, -0.3, -2.5},	-- Sun
			{ 16,  0,	 0.170,	0.707, -0.686,	1.0, 1.0, 0.95, 1.0, -0.5, -2.4},	-- Sun
			{ 18,  0,	 0.380,	0.894, -0.239,	1.0, 0.9, 0.8, 1.1, -0.4, -2.3},	-- Sun
			{ 18, 30,	 0.398,	0.911, -0.109,	1.0, 0.8, 0.6, 1.2, -0.3, -2.2},	-- Sun fade out start
			{ 18, 53,	 0.360,	0.933, 0.000,	1.0, 0.8, 0.1, 1.4, -0.2, -2.2},	-- Sun fade out start
			
			{ 19, 00,	 0.360,	0.933, 0.000,	1.0, 0.7, 0.1, 0.01, -0.2, -20.0},	-- Night
			{ 23, 59,	 0.360,	0.933, 0.000,	1.0, 0.7, 0.1, 0.01, -0.2, -20.0},}-- Night


local scx, scy = guiGetScreenSize()	

-----------------------------------------------------------------------------------
-- Settings
-----------------------------------------------------------------------------------
local pos = {}
local Settings = {}
Settings.var = {}
Settings.var.isDepthSupported = false

----------------------------------------------------------------
-- DepthBuffer error handling
----------------------------------------------------------------
function zErrorHandling()
	local info=dxGetStatus()
	local depthStatus=false
	Settings.var.isDepthSupported=false
    for k,v in pairs(info) do
		if string.find(k, "DepthBufferFormat") then
			depthStatus=true
			if tostring(v)=='unknown' then 
			else
				Settings.var.isDepthSupported=true
			end
		end
    end
	if depthStatus==false then 
		Settings.var.isDepthSupported=false
	end
end

function switchRays( bOn )
	if bOn then
		enableRays()
	else
		disableRays()
	end
end
addEvent( "switchRays", true )
addEventHandler( "switchRays", getLocalPlayer(), switchRays )


function enableRays()
		if bRaysEnabled then return end

		if getVersion ().sortable < "1.3.1" then return end

		-- Create things
        myScreenSource = dxCreateScreenSource( scx, scy )

        depthShader = dxCreateShader( "fx/rays.fx" )
		mediumShader = dxCreateShader( "fx/rays2.fx" )
		medium2Shader = dxCreateShader( "fx/rays3.fx" )
		medium3Shader = dxCreateShader( "fx/rays4.fx" )
		blurShader = dxCreateShader( "fx/rays5.fx" )
		
		zErrorHandling()

		-- Check everything is ok
		bAllValid = myScreenSource and depthShader and medium2Shader and medium3Shader and blurShader
		
		bRaysEnabled = true

		addEventHandler( "onClientHUDRender", root, raysRender, true, "high")
	end



function disableRays()
	if not bRaysEnabled then return end

	removeEventHandler( "onClientHUDRender", root, raysRender)

	destroyElement( myScreenSource )
	destroyElement( depthShader )
	destroyElement( mediumShader )
	destroyElement( medium2Shader )
	destroyElement( medium3Shader )
	destroyElement( blurShader )

	bAllValid = false
	RTPool.clear()

	-- Flag effect as stopped
	bRaysEnabled = false
end

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
--addEventHandler( "onClientHUDRender", root,
    function raysRender()
		if not Settings.var then
			return
		end
        if bAllValid then
			-- Reset render target pool
			RTPool.frameStart()
			
			updateShineDirection()

			-- Update screen
			dxUpdateScreenSource( myScreenSource, true)
			local current2 = myScreenSource
			--local current2 = current

			-- Apply all the effects, bouncing from one render target to another
			local current = depth( current2 )
			local current3 = current
			current = medium( current3 )
			current = medium2( current3, current )
			current = medium3( current3, current )
			current = blur( current, current2, current3)

			-- When we're done, turn the render target back to default
			dxSetRenderTarget()
			
			dxDrawImage( 0, 0, scx, scy, current, 0,0,0,tocolor(255,255,255,255))
	
        end
    end
--,true ,"high" )


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function depth( Src )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxDrawImage( 0, 0, mx, my, depthShader )
	dxSetShaderValue( depthShader, "value", Settings.var.alpha)
	dxSetShaderValue( depthShader, "sunColor", Settings.var.red, Settings.var.green, Settings.var.blue )
	return newRT
end

function medium( Src )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( mediumShader, "TEX0", Src )
	dxSetShaderValue( mediumShader, "sunPos", pos[1]/2, pos[2], -pos[3] )
	--outputChatBox(pos[1]/2 .. "   " .. pos[2] .. "   " .. -pos[3]/2)
	dxSetShaderValue( mediumShader, "value", Settings.var.alpha)
	dxSetShaderValue( mediumShader, "range", Settings.var.range)
	dxDrawImage( 0, 0, mx, my, mediumShader )
	return newRT
end

function medium2( Src, Src2 )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( medium2Shader, "TEX0", Src )
	dxSetShaderValue( medium2Shader, "TEX1", Src2 )
	dxSetShaderValue( medium2Shader, "sunPos", pos[1]/2, pos[2], -pos[3] )
	--outputChatBox(pos[1]/2 .. "   " .. pos[2] .. "   " .. -pos[3]/2)
	dxSetShaderValue( medium2Shader, "value", Settings.var.alpha)
	dxSetShaderValue( medium2Shader, "range", Settings.var.range)
	dxDrawImage( 0, 0, mx, my, medium2Shader )
	return newRT
end

function medium3( Src, Src2 )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( medium3Shader, "TEX0", Src )
	dxSetShaderValue( medium3Shader, "TEX1", Src2 )
	dxSetShaderValue( medium3Shader, "sunPos", pos[1]/2, pos[2], -pos[3] )
	--outputChatBox(pos[1]/2 .. "   " .. pos[2] .. "   " .. -pos[3]/2)
	dxSetShaderValue( medium3Shader, "value", Settings.var.alpha)
	dxSetShaderValue( medium3Shader, "range", Settings.var.range)
	dxDrawImage( 0, 0, mx, my, medium3Shader )
	return newRT
end

function blur( Src, current2, current3 )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( blurShader, "TEX0", current2)
	dxSetShaderValue( blurShader, "TEX1", Src )
	dxSetShaderValue( blurShader, "TEX2", current3)
	dxSetShaderValue( blurShader, "sunPos", pos[1]/2, pos[2], -pos[3] )
	dxSetShaderValue( blurShader, "value", Settings.var.alpha)
	dxSetShaderValue( blurShader, "range", Settings.var.range)
	dxSetShaderValue( blurShader, "bright", Settings.var.bright)
	dxDrawImage( 0, 0, mx, my, blurShader )
	return newRT
end


function updateShineDirection ()

	-- Get game time
	local h, m, s = getTimeHMS ()
	local fhoursNow = h + m / 60 + s / 3600

	-- Find which two lines in the shineDirectionList to blend between
	for idx,v in ipairs( shineDirectionList ) do
		local fhoursTo = v[1] + v[2] / 60
		if fhoursNow <= fhoursTo then

			-- Work out blend from line
			local vFrom = shineDirectionList[ math.max( idx-1, 1 ) ]
			local fhoursFrom = vFrom[1] + vFrom[2] / 60

			-- Calc blend factor
			local f = math.unlerp( fhoursFrom, fhoursNow, fhoursTo )

			-- Calc final direction, sharpness and brightness
			pos[1] = math.lerp( vFrom[3], f, v[3] )
			pos[2] = math.lerp( vFrom[4], f, v[4] )
			pos[3] = math.lerp( vFrom[5], f, v[5] )
			Settings.var.red  = math.lerp( vFrom[6], f, v[6] )
			Settings.var.green = math.lerp( vFrom[7], f, v[7] )
			Settings.var.blue = math.lerp( vFrom[8], f, v[8] )
			Settings.var.alpha = math.lerp( vFrom[9], f, v[9] )
			Settings.var.range = math.lerp( vFrom[10], f, v[10] )
			Settings.var.bright = math.lerp( vFrom[11], f, v[11] )

			local camMat = getRealCameraMatrix()
			local camMatInv = matrix.invert( camMat )

			local velDir = Vector3D:new(pos[1],pos[2],pos[3])
			velDir:Normalize()
			local velDirForCam = matTransformNormal ( camMatInv, {velDir.x,velDir.y,velDir.z} )
			
			pos = velDirForCam

			break
		end
	end
end

function getRealCameraMatrix()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local fwd = Vector3D:new(lx - px, ly - py, lz - pz)
	local up = Vector3D:new(0, 0, 1)
	fwd:Normalize()
	local dot = fwd:Dot(up)				-- Dot product of primary and secondary axis
	up = up:AddV( fwd:Mul(-dot) )		-- Adjust secondary axis
	up:Normalize()
	local right = fwd:CrossV(up)		-- Calculate last axis

	return matrix{ {right.x, right.y, right.z, 0}, {fwd.x, fwd.y, fwd.z, 0}, {up.x, up.y, up.z, 0}, {px, py, pz, 1} }
end

function matTransformNormal( mat, vec )
	local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1]
	local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2]
	local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3]
	return {offX, offY, offZ}
end

Vector3D = {
	new = function(self, _x, _y, _z)
		local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
		return setmetatable(newVector, { __index = Vector3D })
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Module()
		if mod < 0.00001 then
			self.x, self.y, self.z = 0,0,1
		else
			self.x = self.x / mod
			self.y = self.y / mod
			self.z = self.z / mod
		end
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Module = function(self)
		return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	end,

	AddV = function(self, V)
		return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	CrossV = function(self, V)
		return Vector3D:new(self.y * V.z - self.z * V.y,
		                    self.z * V.x - self.x * V.z,
							self.x * V.y - self.y * V.x)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,
}

local timeHMS = {0,0,0}
local minuteStartTickCount
local minuteEndTickCount

function getTimeHMS()
	return unpack(timeHMS)
end

addEventHandler( "onClientRender", root,
	function ()
		if rays == false then return end
		local h, m = getTime ()
		local s = 0
		if m ~= timeHMS[2] then
			minuteStartTickCount = getTickCount ()
			local gameSpeed = math.clamp( 0.01, getGameSpeed(), 10 )
			minuteEndTickCount = minuteStartTickCount + 1000 / gameSpeed
		end
		if minuteStartTickCount then
			local minFraction = math.unlerpclamped( minuteStartTickCount, getTickCount(), minuteEndTickCount )
			s = math.min ( 59, math.floor ( minFraction * 60 ) )
		end
		timeHMS = {h, m, s}
		--outputChatBox( string.format("%02d:%02d:%02d",h,m,s) )
	end
)

function math.lerp(from,alpha,to)
    return from + (to-from) * alpha
end

function math.unlerp(from,pos,to)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end

function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.unlerpclamped(from,pos,to)
	return math.clamp(0,math.unlerp(from,pos,to),1)
end


-----------------------------------------------------------------------------------
-- Pool of render targets
-----------------------------------------------------------------------------------
RTPool = {}
RTPool.list = {}

function RTPool.frameStart()
	for rt,info in pairs(RTPool.list) do
		info.bInUse = false
	end
end

function RTPool.GetUnused( mx, my )
	-- Find unused existing
	for rt,info in pairs(RTPool.list) do
		if not info.bInUse and info.mx == mx and info.my == my then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
	local rt = dxCreateRenderTarget( mx, my )
	if rt then
		--outputDebugString( "creating new RT " .. tostring(mx) .. " x " .. tostring(mx) )
		RTPool.list[rt] = { bInUse = true, mx = mx, my = my }
	end
	return rt
end
