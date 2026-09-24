"""Rebuilds assets/fonts/MatriksSymbols-Regular.ttf.

The web build's bundled Roboto lacks the arrows, sub/superscripts and math
symbols that the step prose uses (readableMathProse), so without this font
Flutter web downloads a Noto fallback from fonts.gstatic.com at runtime and
shows empty boxes offline. This keeps only the glyphs Roboto is missing.

Source: DejaVu Sans (Bitstream Vera license; see
assets/fonts/LICENSE-MatriksSymbols.txt). The license requires a modified
font to be renamed, so the family is MatriksSymbols.

Usage: python3 tool/build_symbol_font.py DejaVuSans.ttf Roboto-Regular.ttf
(Roboto-Regular.ttf is build/web/assets/fonts/fallback/Roboto-Regular.ttf
after `flutter build web --no-web-resources-cdn`.) Requires fontTools.
"""
import sys

from fontTools import subset
from fontTools.ttLib import TTFont

RANGES = [
    (0x0302, 0x0302),  # combining circumflex: î, ĵ basis vectors
    (0x2070, 0x209F),  # superscripts and subscripts: A⁻¹, R₂
    (0x2190, 0x21FF),  # arrows: ← → ↔ ⇒ ⇥
    (0x2200, 0x22FF),  # mathematical operators: ∅ ∓ ∣ ≈
    (0x2713, 0x2713),  # ✓
    (0x27F5, 0x27FE),  # long arrows: ⟹
]


def main(source: str, roboto: str) -> None:
    covered = TTFont(roboto).getBestCmap()
    available = TTFont(source).getBestCmap()
    codepoints = [
        cp
        for start, end in RANGES
        for cp in range(start, end + 1)
        if cp in available and cp not in covered
    ]
    options = subset.Options()
    options.name_IDs = ['*']
    options.layout_features = ['*']
    options.notdef_outline = True
    font = TTFont(source)
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=codepoints)
    subsetter.subset(font)
    for record in font['name'].names:
        if record.nameID in (1, 16):
            record.string = 'MatriksSymbols'
        elif record.nameID == 4:
            record.string = 'MatriksSymbols Regular'
        elif record.nameID == 6:
            record.string = 'MatriksSymbols-Regular'
        elif record.nameID == 3:
            record.string = 'MatriksSymbols-Regular;subset of DejaVu Sans'
    font.save('assets/fonts/MatriksSymbols-Regular.ttf')
    print(f'{len(codepoints)} glyphs')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
