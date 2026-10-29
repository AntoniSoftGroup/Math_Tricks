#import <Foundation/Foundation.h>
#include "AndroidStepCompatibility.hpp"
#include "AndroidStepResourceKeys.hpp"
#include "AndroidStepPort.hpp"

JString JString::formatted(const JString& format,const std::vector<JString>& args) {
    NSString* source=format.ns();
    NSRegularExpression* re=[NSRegularExpression regularExpressionWithPattern:@"%%|%(?:(\\d+)\\$)?(-?0?\\d*)(?:\\.\\d+)?[dsf]" options:0 error:nil];
    NSMutableString* out=[NSMutableString string];__block NSUInteger previous=0;__block NSUInteger sequential=0;
    [re enumerateMatchesInString:source options:0 range:NSMakeRange(0,source.length) usingBlock:^(NSTextCheckingResult* match,NSMatchingFlags,BOOL*) {
        [out appendString:[source substringWithRange:NSMakeRange(previous,match.range.location-previous)]];
        NSString* raw=[source substringWithRange:match.range];
        if([raw isEqualToString:@"%%"]) [out appendString:@"%"];
        else {
            auto indexRange=[match rangeAtIndex:1];
            NSUInteger index=indexRange.location==NSNotFound ? sequential++ : [[source substringWithRange:indexRange] integerValue]-1;
            NSString* value=index<args.size() ? args[index].ns() : raw;
            auto widthRange=[match rangeAtIndex:2];NSString* widthText=[source substringWithRange:widthRange];
            NSInteger width=widthText.integerValue;NSUInteger total=std::abs(width);
            if(total>value.length && total<1000) {
                NSString* pad=[@"" stringByPaddingToLength:total-value.length withString:[widthText hasPrefix:@"0"] ? @"0" : @" " startingAtIndex:0];
                value=width<0 ? [value stringByAppendingString:pad] : [pad stringByAppendingString:value];
            }
            [out appendString:value];
        }
        previous=NSMaxRange(match.range);
    }];
    [out appendString:[source substringFromIndex:previous]];JString result;result.assign(out);return result;
}
JArray<JString> JContext::getStringArray(int64_t) {
    // The sole string array used by the step builders names decimal places.
    JArray<JString> result(10);
    for(int i=0;i<10;i++) result[i]=getString(JString(u"subtraction_place_")+JString::valueOf(i));
    return result;
}

#include "AndroidStepBridge.h"
#include "AndroidStepDispatch.hpp"
static NSArray* MTArrows(JList<Arrow*> arrows) {
    NSMutableArray* output=[NSMutableArray array];
    if(arrows==nullptr) return output;
    for(Arrow* a:arrows) [output addObject:@{
        @"startOffset":@(a->startOffset),@"endOffset":@(a->endOffset),@"color":@(uint32_t(a->color)),
        @"labelColor":@(uint32_t(a->labelColor)),@"isDimmed":@(a->isDimmed),@"startGap":@(a->startGap),
        @"targetGap":@(a->targetGap),@"curveAmount":@(a->curveAmount),@"label":a->label.ns(),
        @"isSquareBox":@(a->isSquareBox),@"alwaysShowLabel":@(a->alwaysShowLabel),@"noHead":@(a->noHead),
        @"startTokenLength":@(a->startTokenLength),@"tokenLength":@(a->tokenLength),
        @"isCarryFlight":@(a->isCarryFlight),@"centerBetweenArrows":@(a->centerBetweenArrows),
        @"drawDashedDivider":@(a->drawDashedDivider),@"dividerOffset":@(a->dividerOffset)}];
    return output;
}
char* MTCreateSolutionSteps(int32_t trick,int64_t operand1,int64_t operand2,int32_t variant) {
    @autoreleasepool {
        try {
            if(operand1<0 || operand1>INT32_MAX || operand2<0 || operand2>INT32_MAX) return nullptr;
            AndroidStepPort port;
            auto steps=MTDispatchSteps(port,trick,int32_t(operand1),int32_t(operand2),variant);
            NSMutableArray* output=[NSMutableArray array];
            for(Step* step:steps) {
                NSMutableArray* crossed=[NSMutableArray array];for(auto n:step->crossedOutOffsets) [crossed addObject:@(n)];
                NSMutableArray* transparent=[NSMutableArray array];for(auto n:step->transparentOffsets) [transparent addObject:@(n)];
                NSMutableArray* ranges=[NSMutableArray array];for(auto range:step->highlightedRanges) {NSMutableArray* r=[NSMutableArray array];for(auto n:range) [r addObject:@(n)];[ranges addObject:r];}
                [output addObject:@{@"description":step->description.ns(),@"hintExpr":step->hintExpr.ns(),@"equation":step->equation.ns(),
                    @"expectedAnswer":step->expectedAnswer.ns(),@"isFinal":@(step->isFinal),@"isIntro":@(step->isIntro),
                    @"pulseIndex":@(step->pulseIndex),@"arrows":MTArrows(step->arrows),@"frozenArrows":MTArrows(step->frozenArrows),
                    @"crossedOutOffsets":crossed,@"transparentOffsets":transparent,@"highlightedRanges":ranges}];
            }
            NSData* bytes=[NSJSONSerialization dataWithJSONObject:output options:0 error:nil];
            if(!bytes) return nullptr;
            char* result=(char*)malloc(bytes.length+1);if(!result) return nullptr;
            memcpy(result,bytes.bytes,bytes.length);result[bytes.length]=0;return result;
        } catch(const std::exception& error) { NSLog(@"Step construction failed: %s",error.what());return nullptr; }
    }
}
void MTFreeSolutionSteps(char* bytes) {free(bytes);}

#include "AndroidBooleanSolutionPort.hpp"
char* MTCreateBooleanSolution(int32_t trick, int64_t operand1, int64_t operand2, int64_t answer) {
    @autoreleasepool {
        try {
            if(operand1 < 0 || operand1 > INT32_MAX || operand2 < 0 || operand2 > INT32_MAX || answer < 0) return nullptr;
            AndroidBooleanSolutionPort port;
            port.op1 = operand1; port.op2 = operand2; port.answer = answer;
            port.generate(trick);
            if(port.solutionText.isEmpty()) return nullptr;
            return strdup(port.solutionText.ns().UTF8String);
        } catch(const std::exception& error) {
            NSLog(@"Boolean explanation failed: %s", error.what());
            return nullptr;
        }
    }
}
void MTFreeBooleanSolution(char* html) { free(html); }
