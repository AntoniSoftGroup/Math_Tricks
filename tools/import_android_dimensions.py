#!/usr/bin/env python3
"""Copy the dimensions used by UIKit from the read-only Android resource sets."""
from pathlib import Path
import json,re,xml.etree.ElementTree as ET
P=Path(__file__).resolve().parents[1]
RES=P.parents[1]/'android/Math_Tricks/app/src/main/res'
KEYS={'player_b','player_tv_expression','player_tv_level','player_tv_trick_name','alert_dialog_theme_b_width','ll_head','a_main_ll_b_margins','a_main_ll_b_margins_land','a_main_b_rate','b_setttings_padding_bottom','theme_activity_main_b_rate','theme_activity_game_tv_expression','theme_activity_game_tv_score','theme_activity_game_tv_expressions_count','theme_activity_game_tv_trick_name','theme_activity_game_tv_level','theme_activity_game_b_text','theme_activity_game_b_hint','theme_activity_levels_b_levels_text','theme_activity_tricks_tv_trick','theme_activity_tricks_tv_group','theme_alert_dialog_l_padding','theme_alert_dialog_b_text','theme_alert_dialog_b_width','aurora_corner_radius','aurora_button_padding','aurora_button_inset','aurora_border_width'}
KEYS.update({'ll_bg_level_size','theme_alert_dialog_timer_end_tv_score','theme_alert_dialog_level_complete_tv_score'})
density={'ldpi':.75,'mdpi':1,'hdpi':1.5,'xhdpi':2,'xxhdpi':3,'xxxhdpi':4}
sets=[]
for folder in sorted(RES.glob('values*')):
 q=folder.name.split('-')[1:]
 if any(not (v in density or v=='land' or re.fullmatch(r'sw\d+dp',v)) for v in q):continue
 values={}
 for source in sorted(folder.glob('dimens*.xml')):
  for node in ET.parse(source).getroot():
   if node.get('name') in KEYS and node.text:
    match=re.fullmatch(r'\s*([\d.]+)(?:dp|sp)\s*',node.text)
    if match:values[node.get('name')]=float(match[1])
 if values:sets.append({'qualifier':folder.name,'smallestWidth':next((int(v[2:-2]) for v in q if v.startswith('sw')),0),'landscape':'land' in q,'density':next((density[v] for v in q if v in density),1),'values':values})
(P/'Math_Tricks/Resources/AndroidDimensions.json').write_text(json.dumps(sets,indent=2)+'\n')
print('Imported',len(sets),'dimension sets.')
