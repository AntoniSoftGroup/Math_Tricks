#!/usr/bin/env python3
"""Import result/statistics UI translations and original progress assets from Android."""
from pathlib import Path
import json, plistlib, re, shutil, xml.etree.ElementTree as ET
PROJECT=Path(__file__).resolve().parents[1]
RES=PROJECT.parents[1]/'android/Math_Tricks/app/src/main/res'
OUT=PROJECT/'Math_Tricks/Resources'
def values(folder):
 return {n.get('name'):n for p in sorted(folder.glob('*.xml')) for n in ET.parse(p).getroot().findall('string')}
base=values(RES/'values')
keys=[k for k in base if k.startswith(('results_','statistics_','example_statistics_','theme_picker_','theme_preview_','theme_settings_','theme_font_')) or k in ['change_game_color','change_system_color','font_size_system','option_font_size']]
for target in sorted(OUT.glob('*.lproj')):
 locale=target.stem
 folder={'en':'values','he':'values-iw','zh-Hans':'values-zh-rCN','zh-Hant':'values-zh-rTW'}.get(locale,'values-'+locale)
 translations={**base,**values(RES/folder)}
 rows=[]
 for key in sorted(keys):
  text=''.join(translations[key].itertext()).strip()
  text=re.sub('<[^>]+>','',text.replace('<br>','\n').replace('<br/>','\n')).replace('\\n','\n').replace("\\'", "'").replace('\\"','"')
  text=re.sub(r'%(\d+\$)?[ds]',lambda m:'%'+(m[1] or '')+('lld' if m[0][-1]=='d' else '@'),text)
  rows.append(json.dumps(key,ensure_ascii=False)+' = '+json.dumps(text,ensure_ascii=False)+';')
 (target/'Results.strings').write_text('\n'.join(rows)+'\n')
 plural_keys = ['results_share_clean_intro', 'results_share_tricks_intro']
 plurals = {n.get('name'):n for source in [RES/'values', RES/folder] for xml in sorted(source.glob('*.xml')) for n in ET.parse(xml).getroot().findall('plurals')}
 dictionary = {}
 for key in plural_keys:
  forms = {}
  for item in plurals[key]:
   text = ''.join(item.itertext()).strip().replace('\\n', '\n').replace("\\'", "'").replace('\\"', '"')
   forms[item.get('quantity')] = re.sub(r'%(\d+\$)?[ds]', lambda m: '%'+(m[1] or '')+('lld' if m[0][-1]=='d' else '@'), text)
  dictionary[key] = {'NSStringLocalizedFormatKey':'%#@count@', 'count':{'NSStringFormatSpecTypeKey':'NSStringPluralRuleType', 'NSStringFormatValueTypeKey':'lld', **forms}}
 (target/'Results.stringsdict').write_bytes(plistlib.dumps(dictionary, sort_keys=False))

for name in ['theme_light_progress_bar_black','theme_light_progress_bar_black_light','theme_dark_progress_bar_black','theme_dark_progress_bar_black_dark']:
 shutil.copy2(RES/'drawable-xhdpi'/(name+'.9.png'),OUT/'NinePatch'/(name+'.9.png'))
print('Imported result/statistics resources.')
