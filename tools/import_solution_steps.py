#!/usr/bin/env python3
"""Port Android's pure step construction to C++ using UTF-16/container adapters.
All UI spans remain a UIKit responsibility. Generated methods retain the source
integer division, loops, decompositions, expected answers and arrow offsets.
"""
from pathlib import Path
import re,json,hashlib,xml.etree.ElementTree as ET
P=Path(__file__).resolve().parents[1]
R=P.parents[1]/'android/Math_Tricks/app/src/main'
source=R/'java/example/matharithmetics/game/TrickStepManager.java'
s=source.read_text()
token=r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|/\*.*?\*/|//[^\n]*'
s=re.sub(token,lambda m:'' if m[0].startswith(('/',)) else m[0],s,flags=re.S)
s=s[s.index('    public static List<Step> getStepsForMultiplyBy11('):].rsplit('}',1)[0]
a=s.index('    private static class RoundingPlan');b=s.index('    private static RoundingPlan chooseNearestFriendlyRound',a)
s=s[:a]+s[b:]
# Pointer-valued Java model references use an arena; collections are shared value wrappers.
s=s.replace('TrickStepManager.Step','Step').replace('TrickStepManager.','')
s=s.replace('java.math.BigInteger','JBigInteger').replace('java.math.BigDecimal','JBigDecimal')
s=s.replace('java.util.Arrays','JArrays').replace('Arrays.','JArrays::')
s=s.replace('java.util.Locale.US,','').replace('Locale.US,','')
resourceKeys=sorted(set(re.findall(r'R\.(?:string|array)\.(\w+)',s)))
resourceIDs={k:i+10000 for i,k in enumerate(resourceKeys)}
s=re.sub(r'R\.(?:string|array)\.(\w+)',lambda m:str(resourceIDs[m[1]]),s)
s=re.sub(r'\b(?:public|private|static|final)\s+','',s)
s=re.sub(r'new ArrayList<>\(\)',r'{}',s)
# Restore typed empty list constructions in Step arguments (not template argument inference).
s=re.sub(r'new (Step|Arrow|RoundingPlan)\(',lambda m:{'Step':'makeStep','Arrow':'makeArrow','RoundingPlan':'makePlan'}[m[1]]+'(',s)
s=s.replace('new StringBuilder(', 'JStringBuilder(').replace('new String(', 'JString(')
for java,cpp in [('boolean','bool'),('char','char16_t'),('String','JString'),('int','int32_t'),('long','int64_t')]:
 s=re.sub(r'new '+java+r'\[\]\s*\{',r'JArray<'+cpp+'> {',s)
 s=re.sub(r'new '+java+r'\[([^\]\n]+)\]',r'JArray<'+cpp+r'>(\1)',s)
 s=re.sub(r'\b'+java+r'\[\]',r'JArray<'+cpp+'>',s)
for name in ['Step','Arrow','RoundingPlan']:
 s=re.sub(r'\b'+name+r'\s+(\w+)',name+r'* \1',s)
 s=s.replace('List<'+name+'>','JList<'+name+'*>')
s=s.replace('List<Integer>','JList<int32_t>').replace('List<String>','JList<JString>').replace('List<char[]>','JList<JArray<char16_t>>')
s=re.sub(r'\bList<', 'JList<',s)
s=s.replace('CharSequence','JString').replace('Spanned','JString')
s=re.sub(r'\bContext\b','JContext',s)
s=re.sub(r'\bStringBuilder\b','JStringBuilder',s)
s=re.sub(r'\bString\b','JString',s)
s=re.sub(r'\bint\b','int32_t',s);s=re.sub(r'\blong\b','int64_t',s);s=re.sub(r'\bchar\b','char16_t',s);s=re.sub(r'\bboolean\b','bool',s)
for c in ['Math','Character','Integer','Long','BigInteger','BigDecimal']:
 s=re.sub(r'\b'+c+r'\.', 'J'+c+'::',s)
s=s.replace('JBigInteger.','JBigInteger::').replace('JBigDecimal.','JBigDecimal::')
s=s.replace('JString.','JString::').replace('null','nullptr')
s=re.sub(r'(\d+(?:\.\d+)?)f\b',r'\1f',s) # corrected below: C++ requires a decimal point
s=re.sub(r'(?<![\w.])(\d+)f\b',r'\1.0f',s)
# Per-method pointer variables prevent ambiguity between identically named numeric/string locals.
headers=list(re.finditer(r'^\s*(?:JList<[^\n]+?>|JString|Step\*|RoundingPlan\*|bool|int64_t|int32_t|void)\s+\w+\([^;{]*\)\s*\{',s,re.M))
for h in reversed(headers):
 start=h.start();depth=1;i=h.end()
 while depth and i<len(s):
  if s[i]=='{':depth+=1
  elif s[i]=='}':depth-=1
  i+=1
 chunk=s[start:i]
 pointers=set(re.findall(r'\b(?:Step|Arrow|RoundingPlan)\*\s*(\w+)',chunk))
 for name in pointers:chunk=re.sub(r'\b'+name+r'\.',name+'->',chunk)
 # Pointer fields after list access.
 pointerLists=set(re.findall(r'JList<(?:Step|Arrow)\*>\s+(\w+)',chunk))
 for name in pointerLists:chunk=re.sub(r'\b'+name+r'\.get\(([^()]*)\)\.',name+r'.get(\1)->',chunk)
 s=s[:start]+chunk+s[i:]
# Wrap every literal so integer + string follows Java concatenation rather than C pointer arithmetic.
s=re.sub(r'"(?:\\.|[^"\\])*"',lambda m:'JString(u'+m[0]+')',s)
s=re.sub(r"'(?:\\.|[^'\\])*'",lambda m:'u'+m[0],s)
s=s.replace('JJArrays','JArrays').replace('fromHtml(', 'html(').replace('int32_t... stepDescriptionRes', 'JArray<int32_t> stepDescriptionRes').replace('new IllegalArgumentException(', 'JavaArgumentError(')
pre='''// Generated from Android TrickStepManager.java. Do not hand-edit.
// Source SHA-256: %s
#include "AndroidStepModels.hpp"
struct AndroidStepPort {
    std::vector<std::unique_ptr<Step>> stepArena;
    std::vector<std::unique_ptr<Arrow>> arrowArena;
    std::vector<std::unique_ptr<RoundingPlan>> planArena;
    Step* makeStep(JString d,JString h,JString e,JString answer=JString(u""),JList<Arrow*> arrows={}) {
        stepArena.push_back(std::make_unique<Step>(d,h,e,answer,arrows)); return stepArena.back().get();
    }
    template<class... T> Arrow* makeArrow(T... args) { arrowArena.push_back(std::make_unique<Arrow>(args...));return arrowArena.back().get(); }
    RoundingPlan* makePlan(int64_t o,int64_t r,int64_t u) {planArena.push_back(std::make_unique<RoundingPlan>(o,r,u));return planArena.back().get();}
    JString html(JString s){return s;}
'''%hashlib.sha256(source.read_bytes()).hexdigest()
keysSource='inline JString MTStepStringKey(int64_t key) { switch(key) {\n'+''.join('case '+str(v)+': return JString(u"'+k+'");\n' for k,v in resourceIDs.items())+'default:return JString(u"");}}\n'
(P/'Math_Tricks/Game/Solutions/AndroidStepResourceKeys.hpp').write_text(keysSource)
(P/'Math_Tricks/Game/Solutions/AndroidStepPort.hpp').write_text(pre+s+'\n};\n')
# Localized descriptions keep Android printf semantics; formatting is handled by the adapter.
keys=set(re.findall(r'R.string.(\w+)',source.read_text()))
base={n.get('name'):n for f in (R/'res/values').glob('*.xml') for n in ET.parse(f).getroot() if n.get('name')}
for locale,folder in [('en','values'),('ru','values-ru')]:
 values={**base,**{n.get('name'):n for f in (R/'res'/folder).glob('*.xml') for n in ET.parse(f).getroot() if n.get('name')}}
 out={k:''.join(values[k].itertext()).strip().replace('\\n','\n').replace("\\'", "'") for k in sorted(keys)}
 for i,n in enumerate(values['subtraction_place_names']): out['subtraction_place_'+str(i)]=''.join(n.itertext())
 dest=P/'Math_Tricks/Resources' /f'{locale}.lproj'/'Steps.strings'
 dest.write_text('\n'.join(json.dumps(k,ensure_ascii=False)+' = '+json.dumps(v,ensure_ascii=False)+';' for k,v in out.items())+'\n')
print('Ported step builder methods:',len(headers),'localized descriptions:',len(keys))

# One explicit route per catalog ID. Family names are the original Android methods.
catalog=json.loads((P/'Math_Tricks/Resources/TrickCatalog.json').read_text())['tricks']
special={
 'trick_addition':('AdditionColumn','op1, op2'),
 'trick_subtraction':('ColumnSubtraction','op1, op2'),
 'trick_multiplication':('MultiplicationTable','op1, op2'),
 'trick_division':('Division','op1, op2'),
 'trick_multiply_by_11_2digit':('MultiplyBy11','op1, variant != 0 || op1 > 99'),
 'trick_subtracting_from_1000':('SubtractingFrom1000','op1, op2'),
 'trick_tough_multiplication':('ToughMultiplication','op1, op2'),
 'trick_power_of_two':('PowerOfTwo','op2'),
 'trick_adding_numbers_close_to_hundreds':('AddingRounding','op1, op2'),
 'trick_subtracting_numbers_close_to_hundreds':('SubtractingRounding','op1, op2'),
 'trick_multiply_numbers_between_11_and_19':('MultiplyNumbersBetween11And19','op1, op2'),
 'trick_multiply_two_digit_numbers_having_same_tens':('MultiplyTwoDigitNumbersSameTens','op1, op2'),
 'trick_multiply_two_digit_numbers_editing_in_1':('MultiplyEndingIn1','op1, op2'),
 'trick_percent':('PercentTip1','op1, op2'), 'trick_percent_2':('PercentTip2','op1, op2'),
 'trick_square_root':('SquareRoot','int64_t(op1)'),
 'trick_3_root':('CubeRoot','int64_t(op1)'),
 'trick_4_root':('Root4','int64_t(op1)'), 'trick_5_root':('Root5','int64_t(op1)'),
 'trick_6_root':('Root6','int64_t(op1)'), 'trick_9_root':('Root9','int64_t(op1)'),
}
lines=[]
for t in catalog:
 k=t['key'];method,args=special.get(k,('', 'op1'))
 if not method:
  if k.startswith('trick_multiply_by_'):method='MultiplyBy'+k.removeprefix('trick_multiply_by_')
  elif k.startswith('trick_dividing_by_'):method='DividingBy'+k.removeprefix('trick_dividing_by_')
  elif k.startswith('trick_square_numbers_editing_in_'):method='SquareEndingIn'+k.removeprefix('trick_square_numbers_editing_in_')
  elif k.startswith('trick_square_number_between_'):
   suffix=k.removeprefix('trick_square_number_between_').replace('_and_','And')
   if suffix=='11And99':suffix='90And99'
   method='SquareBetween'+suffix
  elif k.startswith('trick_power_'):method='Power'+k.removeprefix('trick_power_').replace('_between_','Between').replace('_and_','And')
  elif k.endswith('_percent'):method=k.removeprefix('trick_').removesuffix('_percent')+'Percent';args='op2'
 if k=='trick_15_percent':method='15PercentTip'
 if k=='trick_multiply_by_8' or k=='trick_multiply_by_16':args='op1, variant != 0'
 assert re.search(r'getStepsFor'+method+r'\(',s), (k,method)
 lines.append('case '+str(t['id'])+': return port.getStepsFor'+method+'(context, '+args+');')
(P/'Math_Tricks/Game/Solutions/AndroidStepDispatch.hpp').write_text('inline JList<Step*> MTDispatchSteps(AndroidStepPort& port,int32_t trick,int32_t op1,int32_t op2,int32_t variant) { JContext context; switch(trick) {\n'+'\n'.join(lines)+'\ndefault:return {};}}\n')
