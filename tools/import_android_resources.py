#!/usr/bin/env python3
"""Reproduce iOS assets from read-only Android sources; no third-party packages."""
from pathlib import Path
import hashlib
import json
import shutil
import xml.etree.ElementTree as ET

PROJECT = Path(__file__).resolve().parents[1]
ROOT = PROJECT.parents[1]
RES = ROOT / 'android/Math_Tricks/app/src/main/res'
APP = PROJECT / 'Math_Tricks'
A = '{http://schemas.android.com/apk/res/android}'
S = '{http://www.w3.org/2000/svg}'
ET.register_namespace('', S[1:-1])
EXCLUDED = ('alarm', 'challenge', 'ringtone', 'add_shortcut', 'vol_', 'volume_')
COLORS = {'@android:color/white': '#ffffff', '@android:color/transparent': '#00000000', '@android:color/darker_gray': '#aaaaaa'}
for p in sorted((RES / 'values').glob('*.xml')):
    for item in ET.parse(p).getroot().findall('color'):
        COLORS['@color/' + item.attrib['name']] = item.text.strip()


def color(value):
    while value.startswith('@'):
        value = COLORS[value]
    value = value.lstrip('#')
    if len(value) == 8:  # Android AARRGGBB -> SVG RGB + opacity
        return '#' + value[2:], int(value[:2], 16) / 255
    if len(value) in (3, 6):
        return '#' + value, 1
    raise ValueError(value)


def vector(source):
    root = ET.parse(source).getroot()
    attrs = {k.removeprefix(A): v for k, v in root.attrib.items()}
    svg = ET.Element(S + 'svg', width=attrs['width'].removesuffix('dp'), height=attrs['height'].removesuffix('dp'),
                     viewBox=f"0 0 {attrs['viewportWidth']} {attrs['viewportHeight']}")
    defs = ET.SubElement(svg, S + 'defs')
    counter = 0

    def uid():
        nonlocal counter
        counter += 1
        return f'r{counter}'

    def paint(node, key, value, alpha=1):
        rgb, opacity = color(value)
        node.set(key, rgb)
        if opacity * float(alpha) != 1:
            node.set(key + '-opacity', str(opacity * float(alpha)))

    def children(android, target):
        current = target
        for child in android:
            a = {k.removeprefix(A): v for k, v in child.attrib.items()}
            if child.tag == 'group':
                px, py = a.get('pivotX', '0'), a.get('pivotY', '0')
                transform = (f"translate({a.get('translateX', '0')} {a.get('translateY', '0')}) "
                             f"translate({px} {py}) rotate({a.get('rotation', '0')}) "
                             f"scale({a.get('scaleX', '1')} {a.get('scaleY', '1')}) translate({-float(px)} {-float(py)})")
                children(child, ET.SubElement(current, S + 'g', transform=transform))
            elif child.tag == 'clip-path':
                name = uid()
                clip = ET.SubElement(defs, S + 'clipPath', id=name)
                ET.SubElement(clip, S + 'path', d=a['pathData'], **{'clip-rule': 'evenodd' if a.get('fillType') == 'evenOdd' else 'nonzero'})
                current = ET.SubElement(current, S + 'g', **{'clip-path': f'url(#{name})'})
            elif child.tag == 'path':
                if any(k.startswith('trimPath') for k in a):
                    raise ValueError(f'Unsupported trimmed path: {source}')
                path = ET.SubElement(current, S + 'path', d=a['pathData'])
                paint(path, 'fill', a.get('fillColor', '#00000000'), a.get('fillAlpha', 1))
                path.set('fill-rule', 'evenodd' if a.get('fillType') == 'evenOdd' else 'nonzero')
                if 'strokeColor' in a:
                    paint(path, 'stroke', a['strokeColor'], a.get('strokeAlpha', 1))
                    for key, svgkey in [('strokeWidth', 'stroke-width'), ('strokeLineCap', 'stroke-linecap'), ('strokeLineJoin', 'stroke-linejoin'), ('strokeMiterLimit', 'stroke-miterlimit')]:
                        if key in a:
                            path.set(svgkey, a[key])
                for attr in child:
                    if attr.attrib['name'] != 'android:fillColor':
                        raise ValueError(f'Unsupported paint: {source}')
                    gradient = next(iter(attr))
                    g = {k.removeprefix(A): v for k, v in gradient.attrib.items()}
                    if g.get('type', 'linear') != 'linear':
                        raise ValueError(f'Unsupported gradient: {source}')
                    name = uid()
                    linear = ET.SubElement(defs, S + 'linearGradient', id=name, gradientUnits='userSpaceOnUse',
                                           x1=g['startX'], y1=g['startY'], x2=g['endX'], y2=g['endY'])
                    for stop in gradient:
                        stopattrs = {k.removeprefix(A): v for k, v in stop.attrib.items()}
                        rgb, opacity = color(stopattrs['color'])
                        ET.SubElement(linear, S + 'stop', offset=stopattrs['offset'], **{'stop-color': rgb, 'stop-opacity': str(opacity)})
                    path.set('fill', f'url(#{name})')
                    path.set('fill-opacity', a.get('fillAlpha', '1'))
            else:
                raise ValueError(f'Unsupported tag: {child.tag}')
    canvas = ET.SubElement(svg, S + 'g', opacity=attrs.get('alpha', '1'))
    children(root, canvas)
    return ET.tostring(svg, encoding='unicode') + '\n'


def main():
    manifest = []
    def record(source, target):
        manifest.append({'source': str(source.relative_to(ROOT)), 'target': str(target.relative_to(PROJECT)),
                         'sha256': hashlib.sha256(source.read_bytes()).hexdigest()})
    catalog = APP / 'Resources/AndroidIcons.xcassets'
    catalog.mkdir(parents=True, exist_ok=True)
    (catalog / 'Contents.json').write_text(json.dumps({'info': {'author': 'xcode', 'version': 1}}, indent=2) + '\n')
    for source in sorted((RES / 'drawable').glob('*.xml')):
        if any(part in source.stem for part in EXCLUDED) or ET.parse(source).getroot().tag != 'vector':
            continue
        svg = vector(source)
        folder = catalog / (source.stem + '.imageset')
        folder.mkdir(exist_ok=True)
        output = folder / (source.stem + '.svg')
        output.write_text(svg)
        info = {'images': [{'filename': output.name, 'idiom': 'universal'}], 'info': {'author': 'xcode', 'version': 1},
                'properties': {'preserves-vector-representation': True, 'template-rendering-intent': 'original'}}
        (folder / 'Contents.json').write_text(json.dumps(info, indent=2) + '\n')
        record(source, output)
    for source in sorted((RES / 'raw').iterdir()):
        if source.suffix not in ('.mp3', '.wav'):
            continue
        target = APP / 'Resources/Sounds' / source.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        record(source, target)
    for source in [RES / 'font/roboto_mono.ttf', RES / 'drawable-mdpi/theme_dark_border_expression_dark.9.png',
                   *sorted((RES / 'drawable-xhdpi').glob('bg_th_*_b_main_*.9.png')),
                   *sorted((RES / 'drawable-xhdpi').glob('bg_th_*_elv_item_off.9.png')),
                   *sorted((RES / 'drawable-xhdpi').glob('theme_*_group_indicator_*.9.png'))]:
        target = APP / ('Resources/Fonts' if source.suffix == '.ttf' else 'Resources/NinePatch') / source.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        record(source, target)
    (PROJECT / 'docs/ANDROID_RESOURCES.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print(f'Imported {len(manifest)} Android resources')

if __name__ == '__main__':
    main()
