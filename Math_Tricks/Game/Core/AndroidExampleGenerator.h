#ifndef MT_ANDROID_EXAMPLE_GENERATOR_H
#define MT_ANDROID_EXAMPLE_GENERATOR_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
// Stable C ABI used by the Swift domain model. This header has no UIKit dependency.
enum { MTAddition = 0, MTSubtraction = 1, MTMultiplication = 2, MTDivision = 3,
       MTPower = 4, MTRoot = 5, MTPercent = 6 };
typedef struct {
    int64_t operand1, operand2, answer;
    double displayedOperand1, displayedOperand2;
    int32_t operation, valid;
} MTGeneratedExample;
MTGeneratedExample MTGenerateExample(int32_t trickID, int32_t level, uint64_t seed);
#ifdef __cplusplus
}
#endif
#endif
