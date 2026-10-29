#!/usr/bin/env python3
"""Native iOS wording, alongside the unchanged Android translations."""
from pathlib import Path
import json
P=Path(__file__).parent
KEYS='another_example|backspace|change_input|change_method|coins|collapse_all|default_input|difficulty|examples|expand_all|finish|level|locked|new_game|player|previous_step|result|result_details|resume_multiplayer|resume_saved|save_exit|saved_progress|select_all|show_answer|skip|sort|speech|speech_both|speech_off|step_example|streak_pending|switch_numpad|system_settings|table_grid|table_list|unlock|versus|winner|graph|leaderboard|operation_error|backup_confirm|archive_description|archive_replace_warning|daily_reminder_message|progress_changed|deferred_service'.split('|')
for source in sorted(P.glob('native_rows_*.txt')):
 for line in source.read_text().splitlines():
  if not line.strip() or line.startswith('#'):continue
  row=line.split('|');locale=row.pop(0)
  assert len(row)==len(KEYS),(locale,len(row),len(KEYS))
  values=dict(zip(KEYS,row))
  values.update({'save_error':values['operation_error'],'read_error':values['operation_error'],'reset_progress_final':values['backup_confirm'],'archive_final_confirm':values['backup_confirm'],'archives':values['saved_progress']+' · iOS','unlock_message':values['unlock']+': %lld\n'+values['coins'],'daily_complete':values.get('daily_complete',''),'stats_examples':values['examples']})
  # These labels use the canonical Android translations in import_localizations.py.
  values.pop('daily_complete')
  insufficient={'ar':'العملات غير كافية.','be':'Недастаткова манет.','bn':'পর্যাপ্ত কয়েন নেই।','de':'Nicht genügend Münzen.','el':'Δεν υπάρχουν αρκετά νομίσματα.','es':'No tienes suficientes monedas.','fa':'سکه کافی نیست.','fr':'Pas assez de pièces.','hu':'Nincs elég érme.','id':'Koin tidak cukup.','it':'Monete insufficienti.','he':'אין מספיק מטבעות.','ja':'コインが足りません。','ka':'მონეტები საკმარისი არ არის.','ko':'코인이 부족합니다.','pl':'Za mało monet.','pt':'Moedas insuficientes.','ro':'Monede insuficiente.','th':'เหรียญไม่เพียงพอ','tr':'Yeterli altın yok.','uk':'Недостатньо монет.','vi':'Không đủ xu.','zh-Hans':'金币不足。','zh-Hant':'金幣不足。'}
  values['not_enough_coins']=insufficient[locale]
  (P/('native.'+locale+'.json')).write_text(json.dumps(values,ensure_ascii=False,indent=2)+'\n')
print('Native iOS translation keys:',len(KEYS))
