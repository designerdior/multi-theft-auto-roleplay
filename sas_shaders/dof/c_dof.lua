--
-- c_dof.lua
--
local bDofEnabled = false
local bAllValid

local scx, scy = guiGetScreenSize()	

-----------------------------------------------------------------------------------
-- Settings
-----------------------------------------------------------------------------------
local Settings = {}
Settings.var = {}
Settings.var.blurFactor = 0.0025
Settings.var.blurDiv = 10
Settings.var.depthFactor = 0.002
Settings.var.depthIntensity = 0.3
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

function switchDof( bOn )
	if bOn then
		enableDof()
	else
		disableDof()
	end
end
addEvent( "switchDof", true )
addEventHandler( "switchDof", getLocalPlayer(), switchDof )

function enableDof()

		-- Version check
		if getVersion ().sortable < "1.3.1" then return end

		-- Create things

        dBlurHShader = dxCreateShader( "fx/dBlurH.fx" )

        dBlurVShader = dxCreateShader( "fx/dBlurV.fx" )
		
		zErrorHandling()

		-- Check everything is ok
		bAllValid = dBlurHShader and dBlurVShader
		bDofEnabled = true

		addEventHandler( "onClientHUDRender", root, dofRender, true, "high")
	end

function disableDof()
	if not bDofEnabled then return end

	removeEventHandler( "onClientHUDRender", root, dofRender)

	destroyElement( dBlurHShader )
	destroyElement( dBlurVShader )

	bAllValid = false
	RTPool.clear()

	-- Flag effect as stopped
	bDofEnabled = false


end

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
--addEventHandler( "onClientHUDRender", root,

    function dofRender()
		if not Settings.var then
			return
		end
        if bAllValid then
			-- Reset render target pool
			RTPool.frameStart()

			-- Update screen
			
			local current = exports.rp_screen:getCurrentScreenSource()

			-- Apply all the effects, bouncing from one render target to another
			current = applyGDepthBlurH( current, Settings.var.blurDiv,Settings.var.blurFactor,Settings.var.depthFactor,Settings.var.depthIntensity )
			current = applyGDepthBlurV( current, Settings.var.blurDiv,Settings.var.blurFactor,Settings.var.depthFactor,Settings.var.depthIntensity )

			-- When we're done, turn the render target back to default
			dxSetRenderTarget()
			
			dxDrawImage( 0, 0, scx, scy, current, 0,0,0,tocolor(255,255,255,255))
	
        end
    end
--,true ,"high" )


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function applyGDepthBlurH( Src, blurDiv, blur, depthFactor, depthIntensity )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( dBlurHShader, "TEX0", Src )
	dxSetShaderValue( dBlurHShader, "gblurFactor", blur)
	dxSetShaderValue( dBlurHShader, "gDepthFactor", depthFactor)
	dxSetShaderValue( dBlurHShader, "blurDiv", blurDiv )
	dxSetShaderValue( dBlurHShader, "gDepthIntensity", depthIntensity )
	dxDrawImage( 0, 0, mx, my, dBlurHShader )
	return newRT
end

function applyGDepthBlurV( Src, blurDiv, blur, depthFactor, depthIntensity )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( dBlurVShader, "TEX0", Src )
	dxSetShaderValue( dBlurVShader, "gblurFactor", blur)
	dxSetShaderValue( dBlurVShader, "gDepthFactor", depthFactor)
	dxSetShaderValue( dBlurVShader, "blurDiv", blurDiv )
	dxSetShaderValue( dBlurVShader, "gDepthIntensity", depthIntensity )
	dxDrawImage( 0, 0, mx,my, dBlurVShader )
	return newRT
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