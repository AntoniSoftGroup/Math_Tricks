#!/usr/bin/env python3
"""Import the app's required Android translations, excluding the alarm module.
Native-only wording is versioned under tools/localization. This script never
modifies Android or legacy and never imports store/ad/server identifiers.
"""
from pathlib import Path
import json,re,xml.etree.ElementTree as ET,ast
P=Path(__file__).resolve().parents[1];RES=P.parents[1]/'android/Math_Tricks/app/src/main/res';OUT=P/'Math_Tricks/Resources';SOURCE=P/'tools/localization'
EXCLUDED=re.compile(r'alarm|challenge|ringing|ringtone|simon|wake|shake|notification_channel|auto_silence',re.I)
def resources(folder):return {n.get('name'):n for f in sorted(folder.glob('*.xml')) for n in ET.parse(f).getroot() if n.get('name') and n.tag in ('string','string-array')}
base=resources(RES/'values')
def raw(key,values):
 n=values[key];v=''.join(n.itertext()).strip()
 if v.startswith('@string/'):return raw(v.split('/',1)[1],values)
 return v.replace('\\u0025','%').replace('\\n','\n').replace('\\u0020',' ').replace("\\'", "'").replace('\\"','"')
def clean(v):return re.sub('<[^>]+>','',v.replace('<br>','\n').replace('<br/>','\n'))
def norm(v):return re.sub(r'[^\w]+',' ',clean(v).lower()).strip()
def fmt(v):
 return re.sub(r'%(\d+\$)?[ds]',lambda m:'%'+(m[1] or '')+('lld' if m[0][-1]=='d' else '@'),v)
def write(table,locale,values):
 path=OUT/(locale+'.lproj')/(table+'.strings');path.parent.mkdir(parents=True,exist_ok=True)
 path.write_text('\n'.join(json.dumps(k,ensure_ascii=False)+' = '+json.dumps(v,ensure_ascii=False)+';' for k,v in sorted(values.items()))+'\n')
interface=json.loads((SOURCE/'interface.en.json').read_text());russian=json.loads((SOURCE/'interface.ru.json').read_text())
byValue={}
for key,node in base.items():
 if node.tag=='string' and not EXCLUDED.search(key):byValue.setdefault(norm(raw(key,base)),[]).append(key)
mapping={k:byValue.get(norm(v),[None])[0] for k,v in interface.items()}
overrides={
'statistics_attempts':'statistics_attempts_card',
'statistics_tricks_slow':'statistics_tricks_slow',
'statistics_tricks_errors':'statistics_tricks_errors',
'statistics_page_size':'statistics_page_size_title',
'statistics_clear':'statistics_clear',
'graph_linear':'graph_mode_linear',
'graph_smooth':'graph_mode_cubic',
'graph_series_days':'graph_series_days',

'seconds':'activity_game_time_tv_sec','cancel':'cloud_cancel','levels':'activity_rule_level_select','selected_play':'activity_main_b_one_player','selected_multiplayer':'activity_main_b_two_players',
'resume':'solution_continue_game_only','exit_game':'theme_preview_pause','record':'alert_dialog_timer_end_tv_score_max','reset_record':'reset_score','reset_record_confirm':'reset_score_confirm',
'solve_separately':'solve_step_separately','share_solution':'solution_share_scheme','multiplayer_length':'player_alert_dialog_tv_steps_name',
'input_0':'example_statistics_keyboard','input_1':'example_statistics_choices','input_2':'example_statistics_boolean','stats_repeat':'example_statistics_repeat',
'independent':'example_statistics_clean','average':'example_statistics_average','statistics_empty':'example_statistics_empty','result_details':'statistics_title',
'stats_trick_repeat':'statistics_tricks_recommendations','font_size':'option_font_size','numpad':'option_numpad','wrong_signal':'option_wrong_answer_signal',
'system_font':'font_size_reset','reset_progress':'progress_reset_title','daily_goal':'daily_goal_title','select_tricks':'select_tricks',
'notification_system_settings':'b_option_notification','streak_ended':'streak_shield_ended',
'archive_export':'file_backup_save','archive_import':'file_backup_restore','archive_invalid':'file_backup_restore_error','notification_denied':'permission_warning','no_selection':'select_tricks','daily_complete':'graph_target_complete','reset_progress_confirm':'progress_reset_local_confirm','finish':'activity_main_b_Exit','stats_examples':'example_statistics_all',
'apply_theme':'theme_picker_apply','theme_title':'option_theme','theme_color':'theme_picker_color','theme_intensity':'theme_picker_intensity',
'preview_single':'activity_main_b_one_player','theme_1':'alert_dialog_theme_b_light','theme_2':'alert_dialog_theme_b_dark','theme_3':'theme_light_aurora_name','theme_4':'theme_dark_aurora_name','theme_5':'theme_timely_name','theme_6':'theme_neon_name',
}
for k,v in overrides.items():
 if v in base:mapping[k]=v
# A one-label mapping must never introduce an unconsumed Android format placeholder.
for k,v in list(mapping.items()):
 if v and re.search(r'%(?!%)(?:\d+\$)?[ds]',raw(v,base)) and not re.search(r'%(?!%)(?:\d+\$)?(?:lld|@)',interface[k]):mapping[k]=None
catalog=json.loads((OUT/'TrickCatalog.json').read_text());catalogKeys={t[k] for t in catalog['tricks'] for k in ['nameKey','ruleKey','formulaKey']}|{g['nameKey'] for g in catalog['groups']}
stepSource=(P.parents[1]/'android/Math_Tricks/app/src/main/java/example/matharithmetics/game/TrickStepManager.java').read_text();stepKeys=set(re.findall(r'R.string.(\w+)',stepSource))
mainAST=ast.parse((P/'tools/import_main_strings.py').read_text());mainKeys=[]
for node in mainAST.body:
 if isinstance(node,ast.Assign) and any(isinstance(n,ast.Name) and n.id=='KEYS' for n in node.targets):mainKeys=ast.literal_eval(node.value)
mainKeys += ['activity_main_tv_days_streak', 'graph_no_data', 'graph_daily_target', 'player_alert_dialog_tv_steps_name', 'alert_dialog_player_tv_win', 'alert_dialog_player_tv_lose', 'alert_dialog_player_score', 'alert_dialog_player_score_total']
extraMain=json.loads((SOURCE/'main.en.json').read_text());extraRU=json.loads((SOURCE/'main.ru.json').read_text())
folders=[('en','values')]+[(p.name.removeprefix('values-').replace('zh-rCN','zh-Hans').replace('zh-rTW','zh-Hant').replace('iw','he'),p.name) for p in sorted(RES.glob('values-*')) if (p/'strings_tricks.xml').exists()]
report={'locales':{},'interfaceMappings':{k:v for k,v in mapping.items() if v},'nativeOnlyKeys':sorted(k for k,v in mapping.items() if not v)}
for locale,folder in folders:
 translated=resources(RES/folder);values={**base,**translated}
 write('Catalog',locale,{k:raw(k,values) for k in catalogKeys})
 steps={k:raw(k,values) for k in stepKeys}
 for i,n in enumerate(values['subtraction_place_names']):steps['subtraction_place_'+str(i)]=''.join(n.itertext())
 write('Steps',locale,steps)
 customFile=SOURCE/('native.'+locale+'.json');custom=json.loads(customFile.read_text()) if customFile.exists() else {}
 ui={};fallback=[]
 for key,value in interface.items():
  resource=mapping.get(key)
  if locale=='en':ui[key]=value
  elif locale=='ru':ui[key]=russian.get(key,value)
  elif key in custom:ui[key]=custom[key]
  elif resource:ui[key]=fmt(clean(raw(resource,values))).strip().rstrip(':').rstrip()
  else:ui[key]=value;fallback.append(key)
 write('Interface',locale,ui)
 main={k:fmt(clean(raw(k,values))) for k in mainKeys}
 for key,value in extraMain.items():
  if locale=='ru':main[key]=extraRU.get(key,value)
  elif key=='settings':main[key]=raw('activity_main_b_Settings',values)
  elif key in custom:main[key]=custom[key]
  elif key in ('onboarding_error','link_error','mail_error'):main[key]=custom.get('operation_error',value)
  elif key=='unavailable':main[key]=custom.get('deferred_service',value)
  else:main[key]=value
 write('Main',locale,main)
 write('MainRich',locale,{k:fmt(raw(k,values)) for k in ['all_time_solved','day_streak_text','day_streak_today']})
 report['locales'][locale]={'androidFolder':folder,'catalogTranslated':sum(k in translated for k in catalogKeys),'catalogFallback':sum(k not in translated for k in catalogKeys),'nativeFallback':fallback}
(P/'docs/LOCALIZATION_REPORT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('Imported',len(folders),'locales;',len(interface),'interface keys;',len(catalogKeys),'catalog keys;',len(stepKeys),'step descriptions.')

# Keep the shared cloud/file labels when regenerating Interface.strings.
import runpy
runpy.run_path(str(P/"tools/import_cloud_localizations.py"),run_name="__main__")
