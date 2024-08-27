import sys
from colorsys import rgb_to_hsv, hsv_to_rgb

def adjust_hue(rgb, degrees):
    # RGB를 HSV로 변환
    r, g, b = rgb
    h, s, v = rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)

    # Hue를 degrees만큼 감소 (360을 기준으로 순환)
    h = (h * 360 - degrees) % 360 / 360.0

    # 다시 RGB로 변환
    r, g, b = hsv_to_rgb(h, s, v)
    return int(r * 255), int(g * 255), int(b * 255)

def generate_palette(r, g, b):
    palette = []
    for i in range(36):  # 360도 / 10도 = 36개 색상
        new_color = adjust_hue((r, g, b), i * 10)
        palette.append(new_color)
    return palette

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 util.py <r> <g> <b>")
        sys.exit(1)

    r = int(sys.argv[1])
    g = int(sys.argv[2])
    b = int(sys.argv[3])

    palette = generate_palette(r, g, b)

    with open("/home/sky/.config/aseprite/scripts/log.txt", "a") as f:
        f.write("return {\n")
        for color in palette:
            f.write("  {%d, %d, %d},\n" % color)
        f.write("}\n")

    with open("/home/sky/.config/aseprite/scripts/palette.lua", "w") as f:
        f.write("return {\n")
        for color in palette:
            f.write("  {%d, %d, %d},\n" % color)
        f.write("}\n")
