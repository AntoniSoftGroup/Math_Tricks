#!/usr/bin/env python3
"""Import Android Player's operand-dependent, coloured True/False explanations."""
from pathlib import Path
import hashlib
import json
import re

PROJECT = Path(__file__).resolve().parents[1]
ANDROID = PROJECT.parents[1] / 'android/Math_Tricks/app/src/main/java/example/matharithmetics'
source = ANDROID / 'player/Player.java'
text = source.read_text()
text = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|/\*.*?\*/|//[^\n]*',
              lambda match: '' if match[0].startswith('/') else match[0], text, flags=re.S)
methods = {}
for match in re.finditer(r'\b(?:public\s+)?(?:void|int|String|float)\s+(\w+)\([^;{}]*\)\s*\{', text):
    depth, end = 1, match.end()
    while depth:
        if text[end] == '{': depth += 1
        elif text[end] == '}': depth -= 1
        end += 1
    methods[match[1]] = text[match.start():end]
routes = {}
for key, name in re.findall(r'if\s*\(tempID\s*==\s*context.getResources\(\).getInteger\(R.integer.(\w+)\)\)\s*(\w+)\(\);', text):
    calls = re.findall(r'\b(\w+St)\(\);', methods.get(name, ''))
    if calls: routes[key] = calls[-1]
catalog = json.loads((PROJECT / 'Math_Tricks/Resources/TrickCatalog.json').read_text())['tricks']
assert all(trick['key'] + '_id' in routes for trick in catalog)
body = text[text.index('void trickAdditionSt()'):text.index('public static int INCORRECT_ANSWER_BLOCK')]
body = body.replace('context.getString(R.string.sign_square_root)', '"√"')
body = re.sub(r'\bpublic\s+', '', body)
body = re.sub(r'\bboolean\b', 'bool', body)
# Keep Java's left-to-right concatenation when a result also increments its operand.
for variable in ['temp1', 'temp3']:
    body = re.sub(r'([^;]*solutionText[^;]*\+\+' + variable + r'[^;]*);',
                  lambda match: match[1].replace('++' + variable, variable + ' + 1') + '; ++' + variable + ';', body)
body = re.sub(r'\bint\b', 'int64_t', body)
body = re.sub(r'\bString\b', 'JString', body)
body = body.replace('Math.', 'JMath::')
body = re.sub(r'"(?:\\.|[^"\\])*"', lambda match: 'JString(u' + match[0] + ')', body)
colors = dict(re.findall(r'(cl\w+)\s*=\s*"([0-9a-fA-F]{6})"', (ANDROID / 'other/ResColors.java').read_text()))
header = '''// Generated from Android Player.java and ResColors.java. Do not hand-edit.
// Regenerate with tools/import_boolean_solutions.py.
// Player source SHA-256: %s
#pragma once
struct AndroidBooleanSolutionPort {
    int64_t op1 = 0, op2 = 0, answer = 0;
    int64_t temp1 = 0, temp2 = 0, temp3 = 0, temp4 = 0, temp5 = 0, temp6 = 0, temp7 = 0, temp8 = 0, temp9 = 0;
    float float1 = 0, float2 = 0;
    JString str1, solutionText;
''' % hashlib.sha256(source.read_bytes()).hexdigest()
header += ''.join('    JString %s = JString(u"%s");\n' % pair for pair in colors.items())
header += '''    JString tagI(JString text) { return JString(u"<i>") + text + JString(u"</i>"); }
    JString tagBr() { return JString(u"<br>"); }
    JString tagStep(int64_t step) { return JString(u"<small><small>") + tagI(JString::valueOf(step)) + JString(u":</small></small>  "); }
    JString tagPower(int64_t value) { return JString(u"<sup><sup><small><small><small>") + value + JString(u"</small></small></small></sup></sup>"); }
    JString tagColor(JString text, JString color) { return JString(u"<font color=#") + color + JString(u">") + text + JString(u"</font>"); }
    JString tagNewExample(int64_t number) { return tagColor(JString(u"<u>-") + number + JString(u"-</u>"), clGreenLight); }
    JString trimFloat(float value) { JString result; result.assign([NSString stringWithFormat:@"%.7g", value]); return result; }
    JString getMultiplicationSign() { return JString(u"×"); }
    JString getDivisionSign() { return JString(u"÷"); }
    int64_t power(int64_t base, int64_t exponent) { int64_t result = base; for(int64_t i = 1; i < exponent; ++i) result *= base; return result; }
'''
header += body
header += '\n    void generate(int32_t trick) { switch(trick) {\n'
for trick in catalog:
    header += '        case %d: %s(); break;\n' % (trick['id'], routes[trick['key'] + '_id'])
header += '        default: break;\n    }}\n};\n'
(PROJECT / 'Math_Tricks/Game/Solutions/AndroidBooleanSolutionPort.hpp').write_text(header)
print('Imported Android boolean explanations:', len(catalog))
