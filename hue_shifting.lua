local spr = app.activeSprite
if not spr then
    return app.alert("There is no active sprite")
end

local shade_pal = {}
local dlgMain

-- HSB 값을 기준으로 그레이드 색상 생성
function generateShades(base_color, hue_gap, paletteSize)
    local h, s, b = base_color.hue, base_color.hslSaturation*100, base_color.lightness*100
--     app.alert(string.format("Hue: %d\nSaturation: %d\nBrightness: %d", h*100, s*100, heu_gap))
--     app.alert(string.format("Hue: %d\nSaturation: %d\nBrightness: %d", h, s*100, b*100))

    -- Hue, Saturation, Brightness 값 설정
    -- Hue value Init
    local hue_values = {}

--     local hue_values = {h + 4*hue_gap, h + 3*hue_gap, h + 2*hue_gap, h + hue_gap, h, h - hue_gap, h - 2*hue_gap, h - 3*hue_gap, h - 4*hue_gap}
--     local sat_values = {0, s - 3 * (s - 0) / 4, s - 2 * (s - 0) / 4, s - (s - 0) / 4, s, s + (83 - s) / 4, s + 2 * (83 - s) / 4, s + 3 * (83 - s) / 4, 83}
--     local bri_values = {100, b + 3 * (100 - b) / 4, b + 2 * (100 - b) / 4, b + (100 - b) / 4, b, b - (b - 20) / 4, b - 2 * (b - 20) / 4, b - 3 * (b - 20) / 4, 20}


    local half = math.floor(paletteSize / 2)

    -- Hue
    local hue_values = {}
    local init = h + hue_gap * half
    for i = 0, paletteSize - 1 do
        hue_values[i + 1] = init - i * hue_gap
    end

--     print("Hue Values:", table.concat(hue_values, ", "))

    -- Saturation
    local sat_values = {}
    for i = 0, half do
        sat_values[i + 1] = i * s / half
    end

    for i = 1, half do
        sat_values[#sat_values + 1] = s + i * (83 - s) / half
    end

--     print("Saturation Values:", table.concat(sat_values, ", "))

    -- Brightness
    local bri_values = {}
    for i = half, 1, -1 do
        bri_values[#bri_values + 1] = b + i * (100 - b) / half
    end

    for i = 0, half do
        bri_values[#bri_values + 1] = b - i * (b - 20) / half
    end

--     print("Brightness Values:", table.concat(bri_values, ", "))


    shade_pal = {}

    for i = 1, #hue_values do
        local new_hue = hue_values[i] % 360  -- Hue는 0-360 범위
        local new_sat = math.min(sat_values[i], 100)/100 -- Saturation은 0-100 범위
        local new_bri = math.min(bri_values[i], 100)/100 -- Brightness는 0-100 범위

        local new_color = Color{h = new_hue, s = new_sat, l = new_bri}
        table.insert(shade_pal, new_color)
    end
end

-- 현재 전경색을 기반으로 그레이드 생성
function updateShades()
    local fgColor = app.fgColor
    local hue_gap = tonumber(dlgMain.data.hueGap) or 0
    local palette_size = tonumber(dlgMain.data.paletteSize) or 9
    generateShades(fgColor, hue_gap, palette_size)
    dlgMain:modify{id = 'sha', colors = shade_pal}
end

-- 스프라이트 팔레트에 그레이드 색상 추가
function addShade()
    local act_pal = spr.palettes[1]
    local ncolors = #act_pal
    act_pal:resize(ncolors + #shade_pal)
    for i = 1, #shade_pal do
        act_pal:setColor(ncolors + i - 1, shade_pal[i])
    end
end

-- 메인 대화 상자 표시
function showMain()
    dlgMain = Dialog{
        title = "Hue Shifting",
        onclose = function()
            ColorShadingWindowBounds = dlgMain.bounds
            app.events:off(onFGColorChange)
        end
    }
    -- 메인 대화 상자 구성
    dlgMain
    :label{text = "Palette Size"}
    :slider{
        id = 'paletteSize',
        min = 5, max = 19, value = 9,
        onchange = function()
            local sliderValue = dlgMain.data.paletteSize
            -- 홀수로 강제 변환
            if sliderValue % 2 == 0 then
                sliderValue = sliderValue + 1
                dlgMain:modify{id='paletteSize', value=sliderValue}
            end
            updateShades()
        end
    }
    :newrow()
    :label{text = "Hue Adjustment"}
    :slider{
        id = 'hueGap',
        min = 0, max = 30, value = 10, -- Hue 범위는 -180도에서 180도
        onchange = function()
            updateShades()
        end
    }
    :newrow()
    :shades{
        id = 'sha',
        colors = shade_pal,
        onclick = function(ev) app.fgColor = ev.color end
    }
    :newrow()
    :button{
        text = "Add to Palette",
        onclick = function()
            addShade()
        end
    }
    dlgMain:show{wait = false, bounds = Rectangle(100, 100, 150, 105)}
end

-- 전경색 변경 이벤트 핸들러
function onFGColorChange()
    updateShades()
end

-- 스크립트 실행 시작
do
    showMain()
    updateShades()  -- 초기 그레이드 설정
    app.events:on('fgcolorchange', onFGColorChange)  -- 전경색 변경 이벤트 등록
end
