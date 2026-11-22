local gMe   = getLocalPlayer();
local gRoot = getRootElement();

local imgTable = { image = {}, alpha = {} };
local drawRec = false;

local screen = { guiGetScreenSize() };
local imgDims = { 
  { screen[1]/2, screen[2]/2, 1024,666 },
  { screen[1]/2, screen[2]/2, 1024,666 },
  { screen[1]/2, screen[2]/2, 1024,666 },
  { screen[1]/2, screen[2]/2, 1024,666 },
};

addEventHandler( 'onClientResourceStart', gRoot,
  function ( res )
    if res == getThisResource() then
      for i = 1, 4 do
        imgTable.image[i] = 'splatters/'..tostring(i)..'.png';
        imgTable.alpha[i] = 0;
      end;
      rectangleAlpha = 0;
    end;
  end
);


  function bloody()
    imgTable.alpha[math.random(1,6)] = 255;
    rectangleAlpha = 150;
    if drawRec == false then
      drawRec = true;
      addEventHandler( 'onClientRender', gRoot, renderRectangle );
    end;
  end
addEventHandler( 'onClientPlayerDamage', gMe, bloody)

addEventHandler( 'onClientRender', gRoot,
  function ()
    for imgKey, imgAdress in ipairs( imgTable.image ) do
      if imgTable.alpha[imgKey] > 0 then
        imgTable.alpha[imgKey] = imgTable.alpha[imgKey] - 0.5;
      end;
      if imgKey == 4 then
        dxDrawImage( imgDims[imgKey][1], imgDims[imgKey][2], imgDims[imgKey][3], imgDims[imgKey][4], imgAdress, 90, 0, 0, tocolor( 225, 0, 0, imgTable.alpha[imgKey] ) );
      else
        dxDrawImage( imgDims[imgKey][1], imgDims[imgKey][2], imgDims[imgKey][3], imgDims[imgKey][4], imgAdress, 0, 0, 0, tocolor( 225, 0, 0, imgTable.alpha[imgKey] ) );
      end;
    end;
  end
);

function renderRectangle()
  if rectangleAlpha > 0 then
    rectangleAlpha = rectangleAlpha - 5;
    dxDrawRectangle( 0, 0, screen[1], screen[2], tocolor( 155, 0, 0, rectangleAlpha ) );
  else
    removeEventHandler( 'onClientRender', gRoot, renderRectangle );
    drawRec = false;
  end;
end;