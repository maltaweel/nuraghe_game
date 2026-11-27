"""Draw the app icons (a stylised nuraghe) with Pillow. Output: icons/icon_{144,180,192,512}.png and icons/android_*.png"""
import os
from PIL import Image, ImageDraw
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons")
os.makedirs(OUT, exist_ok=True)

def icon(size, bg=True):
    S = 512
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if bg:
        d.rounded_rectangle([0, 0, S - 1, S - 1], radius=96, fill=(236, 226, 204, 255))
        d.rectangle([0, 380, S, S], fill=(150, 160, 95, 255))
        d.rounded_rectangle([0, 0, S - 1, S - 1], radius=96, outline=(236, 226, 204, 255), width=1)
    courses, base_w, top_w, y0, y1 = 9, 300, 190, 410, 110
    ch = (y0 - y1) / courses
    for i in range(courses):
        f = i / courses
        w = base_w + (top_w - base_w) * f
        yb, yt = y0 - i * ch, y0 - (i + 1) * ch
        x0 = S / 2 - w / 2
        tone = 205 - (i % 2) * 18
        d.rectangle([x0, yt, x0 + w, yb], fill=(tone, tone - 12, tone - 40, 255), outline=(110, 98, 80, 255), width=4)
        n = 5 if i % 2 else 4
        for k in range(1, n):
            x = x0 + w * (k + (0.5 if i % 2 else 0)) / n
            if x < x0 + w - 6:
                d.line([x, yt, x, yb], fill=(110, 98, 80, 255), width=4)
    d.rectangle([S / 2 - 26, y0 - 70, S / 2 + 26, y0], fill=(60, 50, 40, 255))
    if bg:
        mask = Image.new("L", (S, S), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=96, fill=255)
        im.putalpha(mask)
    return im.resize((size, size), Image.LANCZOS)

for s in (144, 180, 192, 512):
    icon(s).save(os.path.join(OUT, f"icon_{s}.png"))
icon(432, bg=False).save(os.path.join(OUT, "android_foreground.png"))
Image.new("RGBA", (432, 432), (236, 226, 204, 255)).save(os.path.join(OUT, "android_background.png"))
icon(192).save(os.path.join(OUT, "android_main.png"))
