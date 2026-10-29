#!/usr/bin/env python3
"""Copy the stage-8 Android UI strings; full localization remains a separate stage."""
from pathlib import Path
import json,re,xml.etree.ElementTree as ET
P=Path(__file__).resolve().parents[1]
RES=P.parents[1]/'android/Math_Tricks/app/src/main/res'
KEYS=['activity_main_b_one_player','activity_main_b_two_players','change_system_color','levels_stat_errors','levels_stat_average','levels_stat_total','levels_stat_time_not_measured','font_size_apply','font_size_reset','font_size_current','font_size_system','font_size_preview','font_size_menu_preview','font_size_solution_preview','font_size_tricks_preview','option_language','activity_game_tv_level','activity_game_tv_examples','activity_game_tv_score','activity_game_time_tv_score','alert_dialog_timer_end_tv_time_max','alert_dialog_timer_end_tv_score_max','reset_score','option_theme','activity_main_b_Start','activity_main_b_Teamwise','activity_main_b_Training','activity_main_b_by_heart','example_statistics_title','activity_main_b_Rate','activity_main_b_support','activity_main_b_buy_pro', 'activity_main_b_buy_pro_short','activate_day_streak','play_day_streak','day_streak_text','day_streak_today','all_time_solved','enable_notifications','math_riddles','age_window','age_screen','privacy_policy','streak_shield_progress','streak_shield_rules','streak_shield_title','streak_shield_ready']
KEYS += ['activity_main_tv_days_streak', 'graph_no_data', 'graph_daily_target', 'player_alert_dialog_tv_steps_name', 'alert_dialog_player_tv_win', 'alert_dialog_player_tv_lose', 'alert_dialog_player_score', 'alert_dialog_player_score_total']
EXTRA={
'en':{'settings':'Settings','graph':'Graph','leaderboard':'Leaderboard','onboarding_error':'Could not save your choice. Please try again.','unavailable':'This section is not available yet.','link_error':'Could not open the link.','mail_error':'No email app is available.','backspace':'Delete digit','ok':'OK'},
'ru':{'settings':'Настройки','graph':'График','leaderboard':'Таблица лидеров','onboarding_error':'Не удалось сохранить выбор. Попробуйте ещё раз.','unavailable':'Этот раздел пока недоступен.','link_error':'Не удалось открыть ссылку.','mail_error':'Нет доступного почтового приложения.','backspace':'Удалить цифру','ok':'OK'}}
for locale,folder in [('en','values'),('ru','values-ru')]:
 values={}
 for f in sorted((RES/folder).glob('*.xml')):
  for n in ET.parse(f).getroot().findall('string'):
   if n.get('name') in KEYS:values[n.get('name')]=''.join(n.itertext())
 if locale=='en': fallback=values.copy()
 else: values={**fallback,**values}
 values.update(EXTRA[locale])
 lines=[]
 for key,value in values.items():
  value=re.sub('<[^>]+>','',value).replace('%1$d','%lld').replace('%s','%@').replace('\\n','\n').replace("\\'", "'")
  lines.append(json.dumps(key,ensure_ascii=False)+' = '+json.dumps(value,ensure_ascii=False)+';')
 target=P/'Math_Tricks/Resources'/f'{locale}.lproj'/'Main.strings'
 target.parent.mkdir(parents=True,exist_ok=True);target.write_text('\n'.join(lines)+'\n')
