"""Export platform-sized launcher assets from the ImageGen master. Requires Pillow."""
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
master = Image.open(ROOT / 'assets/branding/matriks.png').convert('RGB')

def export(path, size, padding=0):
    canvas = Image.new('RGB', (size, size), '#111e32')
    inner = size - padding * 2
    canvas.paste(master.resize((inner, inner), Image.Resampling.LANCZOS), (padding, padding))
    canvas.save(ROOT / path)

for density, size in [('mdpi',48), ('hdpi',72), ('xhdpi',96), ('xxhdpi',144), ('xxxhdpi',192)]:
    export(f'android/app/src/main/res/mipmap-{density}/ic_launcher.png',size)
for item in json.loads((ROOT/'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json').read_text())['images']:
    size = round(float(item['size'].split('x')[0]) * float(item['scale'][:-1]))
    export('ios/Runner/Assets.xcassets/AppIcon.appiconset/'+item['filename'],size)
for size in [192,512]:
    export(f'web/icons/Icon-{size}.png',size)
    export(f'web/icons/Icon-maskable-{size}.png',size,round(size*.15))
export('web/favicon.png',32)
# In-app logo: shown at 32-48 logical px, so 192 px covers a 4x display
# without shipping the full-size master in the app bundle.
master.resize((192,192),Image.Resampling.LANCZOS).save(ROOT/'assets/branding/matriks_icon.png', optimize=True)
master.resize((256,256),Image.Resampling.LANCZOS).save(ROOT/'windows/runner/resources/app_icon.ico',sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
print('Android, iOS, Windows, web and in-app icons exported.')
