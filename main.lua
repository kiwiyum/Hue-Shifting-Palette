local sprite = app.activeSprite
if not sprite then
  return app.alert("There is no active sprite")
end

-- 사용자로부터 색상 입력 받기
local dlg = Dialog("Hue Palette Generator")
dlg:color{ id="baseColor", label="Base Color", color=Color{ r=255, g=0, b=0 } }
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()

local data = dlg.data
if not data.ok then return end

local baseColor = data.baseColor

-- Python 실행 파일과 스크립트의 절대 경로 설정
local python_path = '/usr/bin/python3'  -- Python의 절대 경로
local script_path = '/home/sky/_projects/Hue-Shifting-Palette/util.py'  -- Python 스크립트의 절대 경로

-- 실행할 명령어 문자열 생성
local command = string.format('%s %s %d %d %d', python_path, script_path, baseColor.red, baseColor.green, baseColor.blue)

-- 명령어 실행
local result = os.execute(command)

function showMain()
local dlgMain
dlgMain = Dialog{
title="Grade",
onclose=function()
ColorShadingWindowBounds = dlgMain.bounds
end
}

function addShade()
local act_pal = spr.palettes[1]
local ncolors = #act_pal
act_pal:resize(ncolors + #shade_pal)
for _i= #shade_pal, 1, -1 do
act_pal:setColor(ncolors +_i -1, shade_pal[_i])
end
end

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

local palette = dofile("palette.lua")

app.transaction(
  function()
    math.randomseed(os.time())
    local pal = sprite.palettes[1]
    local pal = Palette()
    for i, color in ipairs(palette) do
      pal:setColor(i, Color{ r=color[1],
                             g=color[2],
                             b=color[3] })
    end
  end)

app.refresh()
