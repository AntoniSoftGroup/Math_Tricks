#!/usr/bin/env python3
"""Import the actual Android catalog and its translations without modifying the source."""
from pathlib import Path
import json,re,xml.etree.ElementTree as ET
P=Path(__file__).resolve().parents[1]
RES=P.parents[1]/'android/Math_Tricks/app/src/main/res'
def resources(folder):
 return {n.get('name'):n for f in sorted(folder.glob('*.xml')) for n in ET.parse(f).getroot() if n.get('name')}
base=resources(RES/'values')
def resolve(v,values=base):
 if v.startswith(('@integer/','@string/')):
  return resolve(''.join(values[v.split('/',1)[1]].itertext()).strip(),values)
 return v.replace('\\u0025','%').replace('\\n','\n').replace("\\'", "'").replace('\\"','"')
def array(k):return [resolve((i.text or '').strip()) for i in base[k]]
ids=list(map(int,array('tricks_id')))
opened=set(map(int,array('tricks_id_opened')))
refs=lambda k:[(i.text or '').split('/',1)[1] for i in base[k]]
tricks=[]
for i,ident in enumerate(ids):
 tricks.append(dict(id=ident,key=refs('tricks_id')[i].removesuffix('_id'),groupID=int(array('tricks_group')[i]),order=array('tricks_order')[i],nameKey=refs('tricks_text')[i],ruleKey=refs('tricks_rule_text')[i],formulaKey=refs('tricks_rule')[i],initiallyUnlocked=ident in opened))
groups=[dict(id=int(ident),nameKey=refs('groups_name')[i],iconName=refs('group_image')[i]) for i,ident in enumerate(array('groups_id'))]
catalog=dict(tricks=tricks,groups=groups,unlockPrice=int(resolve('@string/trick_money')),levelCount=int(resolve('@integer/activity_levels_levels_count_all_all')))
(P/'Math_Tricks/Resources/TrickCatalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n')
keys=set(t[k] for t in tricks for k in ['nameKey','ruleKey','formulaKey'])|{g['nameKey'] for g in groups}
# Keep Android HTML and its coloured worked examples; rendering belongs to UIKit.
for locale,folder in [('en','values'),('ru','values-ru')]:
 values={**base,**resources(RES/folder)}
 out={k:resolve('@string/'+k,values) for k in sorted(keys)}
 dest=P/'Math_Tricks/Resources'/f'{locale}.lproj'/'Catalog.strings'
 dest.write_text('\n'.join(json.dumps(k,ensure_ascii=False)+' = '+json.dumps(v,ensure_ascii=False)+';' for k,v in out.items())+'\n')
print(f'Imported {len(tricks)} tricks, {len(groups)} groups; {len(opened)} initially unlocked.')
