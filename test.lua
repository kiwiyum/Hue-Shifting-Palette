local spr = app.activeSprite
if not spr then
return app.alert("There is no active sprite")
end
local sel = spr.selection
if sel.isEmpty then
return app.alert("Select an area to make a pallete from")
end
local new_pal
local shade_pal = {}
function populatePalette()
for _i= #new_pal-1, 0, -1 do
local c = new_pal:getColor(_i)
if c.alpha ~= 0 then
table.insert(shade_pal, c)
end
end
end
function getPalette()
local act_pal = spr.palettes[1]
local pal = Palette()
app.command.NewSpriteFromSelection()
app.command.ColorQuantization {
ui = false,
withAlpha = true,
maxColors = 256,
useRange = false,
algorithm = 0 -- 0 default, 1 RGB table, 2 octree
}
local new_spr = app.activeSprite
new_pal = new_spr.palettes[1]
populatePalette()
new_spr:close()
end
-- add to sprite palette
function addShade()
local act_pal = spr.palettes[1]
local ncolors = #act_pal
act_pal:resize(ncolors + #shade_pal)
for _i= #shade_pal, 1, -1 do
act_pal:setColor(ncolors +_i -1, shade_pal[_i])
end
end
-- Dialog Windows
--Main -- Sketch View
function showMain()
local dlgMain
dlgMain = Dialog{
title="Grade",
onclose=function()
ColorShadingWindowBounds = dlgMain.bounds
end
}
--Main Dialog
dlgMain
:shades{id='sha', colors= shade_pal,
onclick=function(ev) app.fgColor=ev.color end}
:newrow()
:button{text="Add to Palette",
onclick=function()
addShade() end}
dlgMain:show{ wait=false, bounds=ColorShadingWindowBounds }
end
do
getPalette()
showMain()
end