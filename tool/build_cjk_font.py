"""Rebuilds assets/fonts/MatriksCJK-Regular.ttf and MatriksCJK-Bold.ttf.

Without a bundled CJK font, Flutter web downloads Noto Sans SC from
fonts.gstatic.com at runtime to draw the Chinese interface, and shows empty
boxes offline. This keeps only the CJK characters the app's own text uses:
every character from U+2E80 up in lib/l10n/app_zh.arb and in the Dart
sources (the language menu's 简体中文). Text a learner types, such as a
search, can still need the runtime fallback.

Source: Noto Sans SC, the variable font from github.com/google/fonts
(ofl/notosanssc), SIL Open Font License 1.1; see
assets/fonts/LICENSE-MatriksCJK.txt. The subset is renamed MatriksCJK so it
is not presented as the original font.

Usage: python3 tool/build_cjk_font.py "NotoSansSC[wght].ttf"
Requires fontTools. Run it again whenever Chinese strings change.
"""
import pathlib
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = pathlib.Path(__file__).resolve().parent.parent
WEIGHTS = {'Regular': 400, 'Bold': 700}


def used_codepoints() -> set[int]:
    sources = [ROOT / 'lib/l10n/app_zh.arb']
    sources += [
        p for p in (ROOT / 'lib').rglob('*.dart') if 'generated' not in p.parts
    ]
    return {
        ord(ch)
        for path in sources
        for ch in path.read_text(encoding='utf-8')
        if ord(ch) >= 0x2E80
    }


def main(source: str) -> None:
    wanted = used_codepoints()
    available = TTFont(source).getBestCmap()
    codepoints = sorted(cp for cp in wanted if cp in available)
    for style, weight in WEIGHTS.items():
        font = instancer.instantiateVariableFont(
            TTFont(source), {'wght': weight}
        )
        options = subset.Options()
        options.name_IDs = ['*']
        options.layout_features = ['*']
        options.notdef_outline = True
        subsetter = subset.Subsetter(options=options)
        subsetter.populate(unicodes=codepoints)
        subsetter.subset(font)
        for record in font['name'].names:
            if record.nameID in (1, 16):
                record.string = 'MatriksCJK'
            elif record.nameID in (2, 17):
                record.string = style
            elif record.nameID == 4:
                record.string = f'MatriksCJK {style}'
            elif record.nameID == 6:
                record.string = f'MatriksCJK-{style}'
            elif record.nameID == 3:
                record.string = f'MatriksCJK-{style};subset of Noto Sans SC'
        font['OS/2'].usWeightClass = weight
        out = ROOT / f'assets/fonts/MatriksCJK-{style}.ttf'
        font.save(out)
        print(f'{out.name}: {len(codepoints)} glyphs, {out.stat().st_size} bytes')
    missing = sorted(cp for cp in wanted if cp not in available)
    if missing:
        print('not in the source font:', ''.join(map(chr, missing)))


if __name__ == '__main__':
    main(sys.argv[1])
