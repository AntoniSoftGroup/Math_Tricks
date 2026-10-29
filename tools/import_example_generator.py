#!/usr/bin/env python3
"""Reproduce the 107 arithmetic generators from Android Player.java as portable C++.
The generator preserves Java control flow and casts. UIKit/text/sound methods are
removed; wide intermediate operands avoid signed overflow. The C ABI is int64_t.
No Android lifecycle, services, alarms or UI are included.
"""
from pathlib import Path
import re,json,hashlib
P=Path(__file__).resolve().parents[1]
source=P.parents[1]/'android/Math_Tricks/app/src/main/java/example/matharithmetics/player/Player.java'
original=source.read_text()
s=re.sub(r'/\*.*?\*/|//[^\n]*','',original,flags=re.S)
a=s.index('void trickAddition()');b=s.index('int power(',a)
body=s[a:b]
catalog=json.loads((P/'Math_Tricks/Resources/TrickCatalog.json').read_text())
mapping={}
for key,method in re.findall(r'if\s*\(tempID == context.getResources\(\).getInteger\(R.integer.(\w+)\)\)\s*(\w+)\(\);',s[:a]):
 mapping[key.removesuffix('_id')]=method
methods=re.findall(r'void (\w+)\(\)',body)
assert len(methods)==107
assert all(mapping[t['key']] in methods for t in catalog['tricks'])
body=re.sub(r'\bvoid (\w+)\(',r'void \1(',body)
body=re.sub(r'\bint\[\] (\w+) =',r'int64_t \1[] =',body)
body=body.replace('transferableFactors.length','(sizeof(transferableFactors) / sizeof(transferableFactors[0]))')
body=re.sub(r'\bint\b','int64_t',body)
body=body.replace('Math.random()','randomUnit()').replace('Math.abs','std::abs').replace('Math.max','std::max<int64_t>').replace('Math.pow','std::pow')
body=re.sub(r'\s+trick\w*St\(\);','',body)
body=body.replace('context.getString(R.string.sign_plus)','MTAddition').replace('context.getString(R.string.sign_minus)','MTSubtraction').replace('context.getString(R.string.sign_square_root)','MTRoot')
body=body.replace('getMultiplicationSign()','MTMultiplication').replace('getDivisionSign()','MTDivision')
body=body.replace('int64_t', 'Wide').replace('std::abs', 'absolute').replace('std::max<int64_t>', 'std::max<Wide>')
body=body.replace('sign = "^"','sign = MTPower').replace('sign = "% → "','sign = MTPercent')
assert 'context.' not in body and 'Math.' not in body and 'St();' not in body
header='''// Generated from the read-only Android Player.java by tools/import_example_generator.py.
// Formula source SHA-256: %s
#include "AndroidExampleGenerator.h"
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <limits>

namespace {
using Wide = __int128_t;
struct Generator {
    uint64_t state;
    Wide level, op1 = 0, op2 = 0, answer = 0;
    bool arithmeticValid = true;
    static Wide absolute(Wide value) { return value < 0 ? -value : value; }
    int32_t sign = MTAddition;
    double first = std::numeric_limits<double>::quiet_NaN();
    double second = std::numeric_limits<double>::quiet_NaN();
    double randomUnit() {
        uint64_t z = (state += 0x9e3779b97f4a7c15ULL);
        z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
        z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
        z ^= z >> 31;
        return (z >> 11) * 0x1.0p-53;
    }
    Wide power(Wide a, Wide b) {
        Wide result = 1;
        for (Wide i = 0; i < b; ++i) {
            Wide product;
            if (__builtin_mul_overflow(result, a, &product)) { arithmeticValid = false; return 0; }
            result = product;
        }
        return result;
    }
    void setTextSimple() {}
    void setTextPower() { sign = MTPower; }
    void setTextRoot() { sign = MTRoot; }
    void setTextPercent() { sign = MTPercent; }
    void setTextFloat(float value) { second = std::round(double(value) * 100) / 100; }
    void setTextFloatop1(float value) { first = value; sign = MTPercent; }
'''%hashlib.sha256(source.read_bytes()).hexdigest()
cases='\n'.join('        case %d: g.%s(); break;'%(t['id'],mapping[t['key']]) for t in catalog['tricks'])
footer='''
};
}
MTGeneratedExample MTGenerateExample(int32_t trickID, int32_t level, uint64_t seed) {
    if (level < 1) return MTGeneratedExample{};
    Generator g{seed, level};
    switch (trickID) {
%s
        default: return MTGeneratedExample{0, 0, 0, 0, 0, 0, 0};
    }
    constexpr Wide maximumOperand = 9007199254740991LL;
    if (!g.arithmeticValid || g.op1 < 0 || g.op1 > maximumOperand ||
        g.op2 < 0 || g.op2 > maximumOperand || g.answer < 0 || g.answer > 1000000000000000LL)
        return MTGeneratedExample{};
    return MTGeneratedExample{int64_t(g.op1), int64_t(g.op2), int64_t(g.answer), std::isnan(g.first) ? double(g.op1) : g.first,
        std::isnan(g.second) ? double(g.op2) : g.second, g.sign, 1};
}
'''%cases
(P/'Math_Tricks/Game/Core/AndroidExampleGenerator.cpp').write_text(header+body+footer)
print('Imported 107 arithmetic generators.')
