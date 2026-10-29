#ifndef MT_ANDROID_STEP_BRIDGE_H
#define MT_ANDROID_STEP_BRIDGE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
// Returns UTF-8 JSON owned by the caller. A null result is a calculation failure.
char* MTCreateSolutionSteps(int32_t trick, int64_t operand1, int64_t operand2, int32_t variant);
void MTFreeSolutionSteps(char* json);
// Returns the original Android HTML explanation for the supplied operands.
char* MTCreateBooleanSolution(int32_t trick, int64_t operand1, int64_t operand2, int64_t answer);
void MTFreeBooleanSolution(char* html);
#ifdef __cplusplus
}
#endif
#endif
