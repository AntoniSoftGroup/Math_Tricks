// Generated from Android TrickStepManager.java. Do not hand-edit.
// Source SHA-256: 7d58e4ca933a646f4daccd448800d633616fa524f1d21fdccb3d289cf69afc2b
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
    JList<Step*> getStepsForMultiplyBy11(JContext context, int32_t operand, bool usePartitionMethod) {
        if (usePartitionMethod) {
            return getStepsForMultiplyBy11Partition(context, operand);
        } else {
            return getStepsForMultiplyBy11Classic(context, operand);
        }
    }

    JList<Step*> getStepsForMultiplyBy11Partition(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 7; 

        
        
        

        JString mulSign = JString(u" \u00D7 11");
        JString sOperand = JString::valueOf(operand);
        JString line0 = sOperand + mulSign;

        JString split11 = JString(u"(10 + 1)");
        int32_t splitStart = sOperand.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split11;

        int32_t res10 = operand * 10;
        JString sRes10 = JString::valueOf(res10);
        JString sOp1 = sOperand;
        JString q1 = getQuestionMarks(sRes10.length());
        JString q2 = getQuestionMarks(sOp1.length());
        JString line2_q1 = q1 + JString(u" + ") + q2;
        JString line2_q2 = sRes10 + JString(u" + ") + q2;
        JString line2_val = sRes10 + JString(u" + ") + sOp1;

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t plusInLine1 = l1_off + splitStart + split11.indexOf(JString(u"+"));
        int32_t tenInLine1 = l1_off + splitStart + split11.indexOf(JString(u"10"));
        int32_t oneInLine1 = l1_off + splitStart + split11.lastIndexOf(JString(u"1"));
        int32_t op11Idx = line0.indexOf(JString(u"11"));
        int32_t q1InLine2 = l2_off;
        int32_t q2InLine2 = l2_off + q1.length() + 3;

        bool opIsMulti = sOperand.length() > 1;
        bool q1IsMulti = q1.length() > 1;
        bool q2IsMulti = q2.length() > 1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op11Idx, plusInLine1, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, q1InLine2, arrowColor, false, opIsMulti, q1IsMulti, step1_arrow1_curve, sOperand + JString(u" \u00D7 10"), hintColor, false, false, sOperand.length(), sRes10.length()));
        
        arrows1.add(makeArrow(tenInLine1, q1InLine2, arrowColor, false, true, q1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 2, sRes10.length()));

        steps.add(makeStep(
                context.getString(10079),
                sOperand + JString(u" \u00D7 10 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2_q1,
                sRes10,
                arrows1
        ));

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2InLine2, arrowColor, false, opIsMulti, q2IsMulti, step2_arrow1_curve, sOperand + JString(u" \u00D7 1"), hintColor, false, false, sOperand.length(), sOp1.length()));
        
        arrows2.add(makeArrow(oneInLine1, q2InLine2, arrowColor, false, false, q2IsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sOp1.length()));

        steps.add(makeStep(
                context.getString(10080),
                sOperand + JString(u" \u00D7 1 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2_q2,
                sOp1,
                arrows2
        ));

        int32_t finalRes = operand * 11;
        JString sFinalRes = JString::valueOf(finalRes);
        int32_t l3_off = l2_off + line2_val.length() + 1;
        bool finalIsMulti = sFinalRes.length() > 1;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sRes10.length() > 1), finalIsMulti, step3_arrow1_curve, sRes10 + JString(u" + ") + sOp1, hintColor, false, false, sRes10.length(), sFinalRes.length()));
        arrows3.add(makeArrow(q2InLine2, l3_off, arrowColor, false, (sOp1.length() > 1), finalIsMulti, step3_arrow2_curve, nullptr, 0, false, false, sOp1.length(), sFinalRes.length()));

        steps.add(makeStep(
                context.getString(10081),
                sRes10 + JString(u" + ") + sOp1 + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2_val + JString(u"\n") + getQuestionMarks(sFinalRes.length()),
                sFinalRes,
                arrows3
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);

        Step* lastStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2_val + JString(u"\n") + sFinalRes,
                JString(u""),
                arrowsFinal
        );
        lastStep->isFinal = true;
        steps.add(lastStep);

        return steps;
    }

    JList<Step*> getStepsForMultiplyBy11Classic(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        float step1_arrow1_curve = 0.0f;
        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = 0.6f;
        float step4_arrow1_curve = -2.0f;

        JString mulSign = JString(u" \u00D7 11");
        JString sOperand = JString::valueOf(operand);
        JString line0 = sOperand + mulSign;

        if (operand < 10) {
            JString q1 = getQuestionMarks(sOperand.length());
            JString q2 = getQuestionMarks(sOperand.length());
            JString fullQRow = q1 + q2;

            JString eq1 = line0 + JString(u"\n") + fullQRow;
            JList<Arrow*> arrows1 = {};
            int32_t firstOneIdx = sOperand.length() + 3;
            arrows1.add(makeArrow(0, line0.length() + 1, arrowColor, false, false, true, step1_arrow1_curve, sOperand + JString(u"\u00D71"), hintColor, false, false, sOperand.length(), sOperand.length()));
            arrows1.add(makeArrow(firstOneIdx, line0.length() + 1, arrowColor, false, false, true, 0, nullptr, 0, false, false, 1, sOperand.length()));

            steps.add(makeStep(
                    context.getString(10082),
                    sOperand + JString(u" \u00D7 1 = ?"),
                    eq1,
                    sOperand,
                    arrows1
            ));

            JString eq2 = line0 + JString(u"\n") + sOperand + q2;
            JList<Arrow*> arrows2 = cloneAndDim(arrows1);
            int32_t secondOneIdx = firstOneIdx + 1;
            arrows2.add(makeArrow(0, line0.length() + 2, arrowColor, false, false, true, step1_arrow1_curve, sOperand + JString(u"\u00D71"), hintColor, false, false, sOperand.length(), sOperand.length()));
            arrows2.add(makeArrow(secondOneIdx, line0.length() + 2, arrowColor, false, false, true, 0, nullptr, 0, false, false, 1, sOperand.length()));

            steps.add(makeStep(
                    context.getString(10083),
                    sOperand + JString(u" \u00D7 1 = ?"),
                    eq2,
                    sOperand,
                    arrows2
            ));

            JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
            Step* finalStep = makeStep(
                    context.getString(10073, operand * 11),
                    nullptr,
                    line0 + JString(u"\n") + sOperand + sOperand,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);

            return steps;
        }

        if (operand < 100) {
            int32_t d1 = operand / 10;
            int32_t d2 = operand % 10;
            int32_t sum = d1 + d2;
            JString sD1 = JString::valueOf(d1);
            JString sD2 = JString::valueOf(d2);
            JString sSum = JString::valueOf(sum);

            if (sum > 9) {
                int32_t carry = sum / 10;
                int32_t lastDigitOfSum = sum % 10;
                JString sResD1 = JString::valueOf(d1 + carry);
                JString line1_sumOnly = JString(u"  ") + sSum + JString(u"  ");
                JString line1_sumQuestion = JString(u"  ") + getQuestionMarks(sSum.length()) + JString(u"  ");
                int32_t l1_off = line0.length() + 1;
                bool resD1IsTwoDigits = sResD1.length() > 1;

                JString qResD1 = getQuestionMarks(sResD1.length());
                JString qLastDigitOfSum = getQuestionMarks(1);
                JString qD2 = getQuestionMarks(sD2.length());
                JString fullQRow = qResD1 + JString(u" ") + qLastDigitOfSum + JString(u" ") + qD2;

                JString eq1 = line0 + JString(u"\n") + line1_sumQuestion + JString(u"\n") + fullQRow;
                JList<Arrow*> arrows1 = {};
                int32_t gapPos = line0.length() + 3;
                JString op1 = d1 + JString(u"+") + d2;

                arrows1.add(makeArrow(0, gapPos, arrowColor, false, false, true, step1_arrow1_curve, op1, hintColor, false, false, 1, sSum.length()));
                arrows1.add(makeArrow(1, gapPos, arrowColor, false, false, true, 0, nullptr, 0, false, false, 1, sSum.length()));

                steps.add(makeStep(
                        context.getString(10174),
                        sD1 + JString(u" + ") + sD2 + JString(u" = ?"),
                        eq1,
                        sSum,
                        arrows1
                ));

                int32_t l2_off = l1_off + line1_sumOnly.length() + 1;
                JString eq2 = line0 + JString(u"\n") + line1_sumOnly + JString(u"\n") + (resD1IsTwoDigits ? JString(u"??") : JString(u"?")) + JString(u" ") + qLastDigitOfSum + JString(u" ") + qD2;

                JList<Arrow*> arrows2 = cloneAndDim(arrows1);
                JString op2 = d1 + JString(u"+") + carry;
                arrows2.add(makeArrow(0, l2_off, arrowColor, false, false, resD1IsTwoDigits, step2_arrow2_curve, op2, hintColor, false, false, 1, sResD1.length()));

                int32_t carryPosInL1 = line1_sumOnly.indexOf(JString::valueOf(carry));
                arrows2.add(makeArrow(l1_off + carryPosInL1, l2_off, arrowColor, false, false, resD1IsTwoDigits, 0, nullptr, 0, false, false, JString::valueOf(carry).length(), sResD1.length()));

                steps.add(makeStep(
                        context.getString(10013),
                        sD1 + JString(u" + ") + carry + JString(u" = ?"),
                        eq2,
                        sResD1,
                        arrows2
                ));

                JString eq3 = line0 + JString(u"\n") + line1_sumOnly + JString(u"\n") + sResD1 + JString(u" ") + qLastDigitOfSum + JString(u" ") + qD2;
                JList<Arrow*> arrows3 = cloneAndDim(arrows2);
                int32_t unitsPosInL1 = 2 + (sSum.length() - 1);
                arrows3.add(makeArrow(l1_off + unitsPosInL1, l2_off + sResD1.length() + 1, arrowColor, false, false, true, step2_arrow1_curve, JString::valueOf(lastDigitOfSum), hintColor, false, false, 1, 1));

                steps.add(makeStep(
                        context.getString(10033),
                        JString::valueOf(lastDigitOfSum),
                        eq3,
                        JString::valueOf(lastDigitOfSum),
                        arrows3
                ));

                JString sPartialRow3 = sResD1 + JString(u" ") + lastDigitOfSum;
                JString eq4 = line0 + JString(u"\n") + line1_sumOnly + JString(u"\n") + sPartialRow3 + JString(u" ") + qD2;
                JList<Arrow*> arrows4 = cloneAndDim(arrows3);
                arrows4.add(makeArrow(1, l2_off + sPartialRow3.length() + 1, arrowColor, false, false, true, step4_arrow1_curve, sD2, hintColor, false, false, 1, sD2.length()));

                steps.add(makeStep(
                        context.getString(10032),
                        JString::valueOf(sD2),
                        eq4,
                        sD2,
                        arrows4
                ));

                JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
                Step* finalStep = makeStep(
                        context.getString(10073, operand * 11),
                        nullptr,
                        line0 + JString(u"\n") + line1_sumOnly + JString(u"\n") + sResD1 + JString(u" ") + lastDigitOfSum + JString(u" ") + sD2,
                        JString(u""),
                        arrowsFinal
                );
                finalStep->isFinal = true;
                steps.add(finalStep);

            } else {
                JString q1 = getQuestionMarks(sD1.length());
                JString q2 = getQuestionMarks(sSum.length());
                JString q3 = getQuestionMarks(sD2.length());
                JString fullQRow = q1 + JString(u" ") + q2 + JString(u" ") + q3;

                JString eq1 = line0 + JString(u"\n") + fullQRow;
                JList<Arrow*> arrows1 = {};
                arrows1.add(makeArrow(0, line0.length() + 1, arrowColor, false, false, true, step1_arrow1_curve, sD1, hintColor, false, false, 1, sD1.length()));

                steps.add(makeStep(
                        context.getString(10031),
                        sD1,
                        eq1,
                        sD1,
                        arrows1
                ));

                JString eq2 = line0 + JString(u"\n") + sD1 + JString(u" ") + q2 + JString(u" ") + q3;
                JList<Arrow*> arrows2 = cloneAndDim(arrows1);
                JString op2 = d1 + JString(u"+") + d2;
                int32_t q2PosInL1 = line0.length() + sD1.length() + 2;
                arrows2.add(makeArrow(0, q2PosInL1, arrowColor, false, false, true, step1_arrow1_curve, op2, hintColor, false, false, 1, sSum.length()));
                arrows2.add(makeArrow(1, q2PosInL1, arrowColor, false, false, true, 0, nullptr, 0, false, false, 1, sSum.length()));

                steps.add(makeStep(
                        context.getString(10174),
                        sD1 + JString(u" + ") + sD2 + JString(u" = ?"),
                        eq2,
                        sSum,
                        arrows2
                ));

                JString eq3 = line0 + JString(u"\n") + sD1 + JString(u" ") + sSum + JString(u" ") + q3;
                JList<Arrow*> arrows3 = cloneAndDim(arrows2);
                int32_t q3PosInL1 = line0.length() + sD1.length() + sSum.length() + 3;
                arrows3.add(makeArrow(1, q3PosInL1, arrowColor, false, false, true, step1_arrow1_curve, sD2, hintColor, false, false, 1, sD2.length()));

                steps.add(makeStep(
                        context.getString(10032),
                        sD2,
                        eq3,
                        sD2,
                        arrows3
                ));

                JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
                Step* finalStep = makeStep(
                        context.getString(10073, operand * 11),
                        nullptr,
                        line0 + JString(u"\n") + sD1 + JString(u" ") + sSum + JString(u" ") + sD2,
                        JString(u""),
                        arrowsFinal
                );
                finalStep->isFinal = true;
                steps.add(finalStep);
            }
            return steps;
        }

        return getStepsForMultiplyBy11Partition(context, operand);
    }

    JList<Step*> getStepsForMultiplyEndingIn1(JContext context, int32_t op1, int32_t op2) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t d1 = op1 / 10;
        int32_t d2 = op2 / 10;
        int32_t prod = d1 * d2;
        int32_t sum = d1 + d2;

        JString sOp1 = JString::valueOf(op1);
        JString sOp2 = JString::valueOf(op2);
        JString mulSign = JString(u" \u00D7 ");
        JString line0 = sOp1 + mulSign + sOp2;

        int32_t d1Idx = 0;
        int32_t d2Idx = sOp1.length() + mulSign.length();
        int32_t op1UnitsIdx = sOp1.length() - 1;
        int32_t op2UnitsIdx = line0.length() - 1;

        JString sD1 = JString::valueOf(d1);
        JString sD2 = JString::valueOf(d2);
        JString sProd = JString::valueOf(prod);
        JString sSum = JString::valueOf(sum);

        bool prodIsTwoDigits = (sProd.length() > 1);
        bool sumIsTwoDigits = (sSum.length() > 1);

        int32_t l1_off = line0.length() + 1;

        if (sum > 9) {
            int32_t carry = sum / 10;
            int32_t lastDigitOfSum = sum % 10;
            int32_t resProd = prod + carry;

            JString sResProd = JString::valueOf(resProd);
            JString sLastDigitOfSum = JString::valueOf(lastDigitOfSum);
            bool resProdIsTwoDigits = (sResProd.length() > 1);

            JString qResProd = getQuestionMarks(sResProd.length());
            JString qSum = getQuestionMarks(sSum.length());
            JString qOne = getQuestionMarks(1);

            JString eq1 = line0 + JString(u"\n") + qResProd + JString(u" ") + qSum + JString(u" ") + qOne;
            JList<Arrow*> arrows1 = {};
            arrows1.add(makeArrow(d1Idx, l1_off, arrowColor, false, false, resProdIsTwoDigits, 0, sD1 + JString(u"\u00D7") + sD2, hintColor, false, false, sD1.length(), sResProd.length()));
            arrows1.add(makeArrow(d2Idx, l1_off, arrowColor, false, false, resProdIsTwoDigits, 0, nullptr, 0, false, false, sD2.length(), sResProd.length()));

            steps.add(makeStep(
                    context.getString(10096),
                    sD1 + JString(u" \u00D7 ") + sD2 + JString(u" = ?"),
                    eq1,
                    sProd,
                    arrows1
            ));

            JString q2 = getQuestionMarks(sSum.length());
            int32_t q2PosInL1 = l1_off + sResProd.length() + 1;
            JString eq2 = line0 + JString(u"\n") + sProd + JString(u" ") + q2 + JString(u" ") + qOne;

            JList<Arrow*> arrows2 = cloneAndDim(arrows1);
            arrows2.add(makeArrow(d1Idx, q2PosInL1, arrowColor, false, false, sumIsTwoDigits, 0, sD1 + JString(u"+") + sD2, hintColor, false, false, sD1.length(), sSum.length()));
            arrows2.add(makeArrow(d2Idx, q2PosInL1, arrowColor, false, false, sumIsTwoDigits, 0, nullptr, 0, false, false, sD2.length(), sSum.length()));

            steps.add(makeStep(
                    context.getString(10097),
                    sD1 + JString(u" + ") + sD2 + JString(u" = ?"),
                    eq2,
                    sSum,
                    arrows2
            ));

            int32_t q3PosInL1 = l1_off + sResProd.length() + 1 + sSum.length() + 1;
            JString eq3 = line0 + JString(u"\n") + sProd + JString(u" ") + sSum + JString(u" ") + qOne;

            JList<Arrow*> arrows3 = cloneAndDim(arrows2);
            arrows3.add(makeArrow(op1UnitsIdx, q3PosInL1, arrowColor, false, false, true, 0, JString(u"1\u00D71"), hintColor, false, false, 1, 1));
            arrows3.add(makeArrow(op2UnitsIdx, q3PosInL1, arrowColor, false, false, true, 0, nullptr, 0, false, false, 1, 1));

            steps.add(makeStep(
                    context.getString(10098),
                    JString(u"1 \u00D7 1 = ?"),
                    eq3,
                    JString(u"1"),
                    arrows3
            ));

            JString line1 = sProd + JString(u" ") + sSum + JString(u" 1");
            int32_t l2_off = l1_off + line1.length() + 1;

            JString qLastDigitOfSum = getQuestionMarks(1);
            JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + qResProd + JString(u" ") + qLastDigitOfSum + JString(u" ") + qOne;

            JList<Arrow*> arrows4 = cloneAndDim(arrows3);
            arrows4.add(makeArrow(l1_off, l2_off, arrowColor, false, prodIsTwoDigits, resProdIsTwoDigits, 0, sProd + JString(u"+") + carry, hintColor, false, false, sProd.length(), sResProd.length()));
            int32_t carryPosInL1 = l1_off + sProd.length() + 1;
            arrows4.add(makeArrow(carryPosInL1, l2_off, arrowColor, false, false, resProdIsTwoDigits, 0, nullptr, 0, false, false, JString::valueOf(carry).length(), sResProd.length()));

            steps.add(makeStep(
                    context.getString(10014),
                    sProd + JString(u" + ") + carry + JString(u" = ?"),
                    eq4,
                    sResProd,
                    arrows4
            ));

            int32_t unitsPosInL1 = l1_off + sProd.length() + 1 + (sSum.length() - 1);
            int32_t q5PosInL2 = l2_off + sResProd.length() + 1;
            JString eq5 = line0 + JString(u"\n") + line1 + JString(u"\n") + sResProd + JString(u" ") + qLastDigitOfSum + JString(u" ") + qOne;

            JList<Arrow*> arrows5 = cloneAndDim(arrows4);
            arrows5.add(makeArrow(unitsPosInL1, q5PosInL2, arrowColor, false, false, true, 0, sLastDigitOfSum, hintColor, false, false, 1, 1));

            steps.add(makeStep(
                    context.getString(10033),
                    sLastDigitOfSum,
                    eq5,
                    sLastDigitOfSum,
                    arrows5
            ));

            int32_t onePosInL1 = l1_off + line1.length() - 1;
            JString sPartialRow = sResProd + JString(u" ") + sLastDigitOfSum;
            int32_t q6PosInL2 = l2_off + sPartialRow.length() + 1;
            JString eq6 = line0 + JString(u"\n") + line1 + JString(u"\n") + sPartialRow + JString(u" ") + qOne;

            JList<Arrow*> arrows6 = cloneAndDim(arrows5);
            arrows6.add(makeArrow(onePosInL1, q6PosInL2, arrowColor, false, false, true, 0, JString(u"1"), hintColor, false, false, 1, 1));

            steps.add(makeStep(
                    context.getString(10032),
                    JString(u"1"),
                    eq6,
                    JString(u"1"),
                    arrows6
            ));

            JList<Arrow*> arrowsFinal = cloneArrows(arrows6, false);
            Step* finalStep = makeStep(
                    context.getString(10073, op1 * op2),
                    nullptr,
                    line0 + JString(u"\n") + line1 + JString(u"\n") + sResProd + JString(u" ") + sLastDigitOfSum + JString(u" 1"),
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);

        } else {
            JString qProd = getQuestionMarks(sProd.length());
            JString qSum = getQuestionMarks(sSum.length());
            JString qOne = getQuestionMarks(1);
            JString fullQRow = qProd + JString(u" ") + qSum + JString(u" ") + qOne;

            JString eq1 = line0 + JString(u"\n") + fullQRow;
            JList<Arrow*> arrows1 = {};
            arrows1.add(makeArrow(d1Idx, l1_off, arrowColor, false, false, prodIsTwoDigits, 0, sD1 + JString(u"\u00D7") + sD2, hintColor, false, false, sD1.length(), sProd.length()));
            arrows1.add(makeArrow(d2Idx, l1_off, arrowColor, false, false, prodIsTwoDigits, 0, nullptr, 0, false, false, sD2.length(), sProd.length()));

            steps.add(makeStep(
                    context.getString(10096),
                    sD1 + JString(u" \u00D7 ") + sD2 + JString(u" = ?"),
                    eq1,
                    sProd,
                    arrows1
            ));

            JString eq2 = line0 + JString(u"\n") + sProd + JString(u" ") + qSum + JString(u" ") + qOne;
            int32_t targetPos2 = l1_off + sProd.length() + 1;
            JList<Arrow*> arrows2 = cloneAndDim(arrows1);
            arrows2.add(makeArrow(d1Idx, targetPos2, arrowColor, false, false, sumIsTwoDigits, 0, sD1 + JString(u"+") + sD2, hintColor, false, false, sD1.length(), sSum.length()));
            arrows2.add(makeArrow(d2Idx, targetPos2, arrowColor, false, false, sumIsTwoDigits, 0, nullptr, 0, false, false, sD2.length(), sSum.length()));

            steps.add(makeStep(
                    context.getString(10097),
                    sD1 + JString(u" + ") + sD2 + JString(u" = ?"),
                    eq2,
                    sSum,
                    arrows2
            ));

            JString eq3 = line0 + JString(u"\n") + sProd + JString(u" ") + sSum + JString(u" ") + qOne;
            int32_t targetPos3 = l1_off + sProd.length() + 1 + sSum.length() + 1;
            JList<Arrow*> arrows3 = cloneAndDim(arrows2);
            arrows3.add(makeArrow(op1UnitsIdx, targetPos3, arrowColor, false, false, true, 0, JString(u"1\u00D71"), hintColor, false, false, 1, 1));
            arrows3.add(makeArrow(op2UnitsIdx, targetPos3, arrowColor, false, false, true, 0, nullptr, 0, false, false, 1, 1));

            steps.add(makeStep(
                    context.getString(10098),
                    JString(u"1 \u00D7 1 = ?"),
                    eq3,
                    JString(u"1"),
                    arrows3
            ));

            JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
            Step* finalStep = makeStep(
                    context.getString(10073, op1 * op2),
                    nullptr,
                    line0 + JString(u"\n") + sProd + JString(u" ") + sSum + JString(u" 1"),
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
        }

        return steps;
    }

    JList<Step*> getStepsForMultiplyBy2(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 2");
        JString split2 = JString(u"(1 + 1)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split2;

        int32_t step1Res = operand;
        int32_t step2Res = operand;
        int32_t finalRes = operand * 2;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op2Idx = line0.lastIndexOf(JString(u"2"));
        int32_t plusInLine1 = l1_off + splitStart + split2.indexOf(JString(u"+"));
        int32_t firstOneInLine1 = l1_off + splitStart + split2.indexOf(JString(u"1"));
        int32_t secondOneInLine1 = l1_off + splitStart + split2.lastIndexOf(JString(u"1"));

        int32_t q1InLine2 = l2_off;
        int32_t q2InLine2 = l2_off + sStep1.length() + 3;

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool s2IsMulti = sStep2.length() > 1;

        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" + ") + q2;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op2Idx, plusInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0));
        arrows1.add(makeArrow(0, q1InLine2, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00D71"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(firstOneInLine1, q1InLine2, arrowColor, false, false, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" + ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(0, q2InLine2, arrowColor, false, opIsMulti, s2IsMulti, step2_arrow1_curve, sOp + JString(u"\u00D71"), hintColor, false, false, sOp.length(), sStep2.length()));
        arrows2.add(makeArrow(secondOneInLine1, q2InLine2, arrowColor, false, false, s2IsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        JString line2 = sStep1 + JString(u" + ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"+") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows3.add(makeArrow(q2InLine2, l3_off, arrowColor, false, s2IsMulti, (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10010),
                sStep1 + JString(u" + ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForMultiplyBy3(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 3");
        JString split3 = JString(u"(2 + 1)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split3;

        int32_t step1Res = operand * 2;
        int32_t step2Res = operand;
        int32_t finalRes = operand * 3;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op3Idx = line0.lastIndexOf(JString(u"3"));
        int32_t plusInLine1 = l1_off + splitStart + split3.indexOf(JString(u"+"));
        int32_t twoPosInLine1 = l1_off + splitStart + split3.indexOf(JString(u"2"));
        int32_t onePosInLine1 = l1_off + splitStart + split3.indexOf(JString(u"1"));

        int32_t q1InLine2 = l2_off;
        int32_t q2InLine2 = l2_off + sStep1.length() + 3;

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool s2IsMulti = sStep2.length() > 1;

        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" + ") + q2;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op3Idx, plusInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(0, q1InLine2, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00D72"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(twoPosInLine1, q1InLine2, arrowColor, false, false, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10091),
                sOp + JString(u" \u00D7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" + ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(0, q2InLine2, arrowColor, false, opIsMulti, s2IsMulti, step2_arrow1_curve, sOp + JString(u"\u00D71"), hintColor, false, false, sOp.length(), sStep2.length()));
        arrows2.add(makeArrow(onePosInLine1, q2InLine2, arrowColor, false, false, s2IsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        JString line2 = sStep1 + JString(u" + ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"+") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows3.add(makeArrow(q2InLine2, l3_off, arrowColor, false, s2IsMulti, (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10010),
                sStep1 + JString(u" + ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForMultiplyBy4(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;    
        float step2_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 4");
        JString split4 = JString(u"(2 \u00D7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split4;

        int32_t step1Res = operand * 2;
        int32_t finalRes = operand * 4;

        JString sStep1 = JString::valueOf(step1Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op4Idx = line0.lastIndexOf(JString(u"4"));
        int32_t mulInLine1 = l1_off + splitStart + split4.indexOf(JString(u"\u00D7"));
        int32_t firstTwoInLine1 = l1_off + splitStart + split4.indexOf(JString(u"2"));
        int32_t secondTwoInLine1 = l1_off + splitStart + split4.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op4Idx, mulInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00D72"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(firstTwoInLine1, l2_off, arrowColor, false, false, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10091),
                sOp + JString(u" \u00D7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarks(sFinal.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, finalIsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00D72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(secondTwoInLine1, l3_off, arrowColor, false, false, finalIsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10102),
                sStep1 + JString(u" \u00D7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForMultiplyBy5(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;    
        float step2_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 5");
        JString split5 = JString(u"(10 \u00F7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split5;

        int32_t step1Res = operand * 10;
        int32_t finalRes = operand * 5;

        JString sStep1 = JString::valueOf(step1Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op5Idx = line0.lastIndexOf(JString(u"5"));
        int32_t divInLine1 = l1_off + splitStart + split5.indexOf(JString(u"\u00F7"));
        int32_t tenInLine1 = l1_off + splitStart + split5.indexOf(JString(u"10"));
        int32_t twoInLine1 = l1_off + splitStart + split5.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op5Idx, divInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00D710"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(tenInLine1, l2_off, arrowColor, false, true, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10088),
                sOp + JString(u" \u00D7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarks(sFinal.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, finalIsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00F72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(twoInLine1, l3_off, arrowColor, false, false, finalIsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" \u00F7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy6(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;  
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;    
        float step2_arrow2_curve = -1.3f; 

        float step3_arrow1_curve = 3.8f;  
        float step3_arrow2_curve = 0.0f;    

        float step4_arrow1_curve = 0.0f;    
        float step4_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 6");
        JString split6 = JString(u"(10\u00F72+1)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split6;

        int32_t step1Res = operand * 10;
        int32_t step2Res = operand * 5;
        int32_t step3Res = operand;
        int32_t finalRes = operand * 6;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op6Idx     = line0.lastIndexOf(JString(u"6"));
        int32_t tenInLine1 = l1_off + splitStart + split6.indexOf(JString(u"10"));
        int32_t twoInLine1 = l1_off + splitStart + split6.indexOf(JString(u"2"));
        int32_t oneInLine1 = l1_off + splitStart + split6.lastIndexOf(JString(u"1"));

        
        int32_t topDimmedArrowTarget = twoInLine1;

        bool opIsMulti    = sOp.length() > 1;
        bool s1IsMulti    = sStep1.length() > 1;
        bool s2IsMulti    = sStep2.length() > 1;
        bool s3IsMulti    = sStep3.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(op6Idx, topDimmedArrowTarget, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00D710"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(tenInLine1, l2_off, arrowColor, false, true, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10088),
                sOp + JString(u" \u00D7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, s2IsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00F72"), hintColor, false, false, sStep1.length(), sStep2.length()));
        
        arrows2.add(makeArrow(twoInLine1, l3_off, arrowColor, false, false, s2IsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" \u00F7 2 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString partialLine3 = sStep2 + JString(u" + ");
        int32_t q3_off = l3_off + partialLine3.length();
        JString q3 = getQuestionMarks(sStep3.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + partialLine3 + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(0, q3_off, arrowColor, false, opIsMulti, s3IsMulti, step3_arrow1_curve, sOp + JString(u" \u00D7 1"), hintColor, false, false, sOp.length(), sStep3.length()));
        
        arrows3.add(makeArrow(oneInLine1, q3_off, arrowColor, false, false, s3IsMulti, step3_arrow2_curve, nullptr, 0, false, false, 1, sStep3.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq3,
                sStep3,
                arrows3
        ));

        
        JString line3 = sStep2 + JString(u" + ") + sStep3;
        int32_t l4_off = l3_off + line3.length() + 1; 
        JString q4 = getQuestionMarks(sFinal.length());
        JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + q4;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        
        arrows4.add(makeArrow(l3_off, l4_off, arrowColor, false, s2IsMulti, finalIsMulti, step4_arrow1_curve, sStep2 + JString(u"+") + sStep3, hintColor, false, false, sStep2.length(), sFinal.length()));
        
        arrows4.add(makeArrow(q3_off, l4_off, arrowColor, false, s3IsMulti, finalIsMulti, step4_arrow2_curve, nullptr, 0, false, false, sStep3.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10012),
                sStep2 + JString(u" + ") + sStep3 + JString(u" = ?"),
                eq4,
                sFinal,
                arrows4
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy7(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;  
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;    
        float step2_arrow2_curve = -1.3f; 

        float step3_arrow1_curve = 3.8f;  
        float step3_arrow2_curve = 0.0f;    

        float step4_arrow1_curve = 0.0f;    
        float step4_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 7");
        JString split7 = JString(u"(10\u00F72+2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split7;

        int32_t step1Res = operand * 10;
        int32_t step2Res = operand * 5;
        int32_t step3Res = operand * 2;
        int32_t finalRes = operand * 7;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op7Idx           = line0.lastIndexOf(JString(u"7"));
        int32_t tenInLine1       = l1_off + splitStart + split7.indexOf(JString(u"10"));
        int32_t twoInLine1       = l1_off + splitStart + split7.indexOf(JString(u"2"));
        int32_t secondTwoInLine1 = l1_off + splitStart + split7.lastIndexOf(JString(u"2"));

        
        int32_t topDimmedArrowTarget = twoInLine1;

        bool opIsMulti    = sOp.length() > 1;
        bool s1IsMulti    = sStep1.length() > 1;
        bool s2IsMulti    = sStep2.length() > 1;
        bool s3IsMulti    = sStep3.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(op7Idx, topDimmedArrowTarget, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00D710"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(tenInLine1, l2_off, arrowColor, false, true, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10088),
                sOp + JString(u" \u00D7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, s2IsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00F72"), hintColor, false, false, sStep1.length(), sStep2.length()));
        
        arrows2.add(makeArrow(twoInLine1, l3_off, arrowColor, false, false, s2IsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" \u00F7 2 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString partialLine3 = sStep2 + JString(u" + ");
        int32_t q3_off = l3_off + partialLine3.length();
        JString q3 = getQuestionMarks(sStep3.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + partialLine3 + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(0, q3_off, arrowColor, false, opIsMulti, s3IsMulti, step3_arrow1_curve, sOp + JString(u" \u00D7 2"), hintColor, false, false, sOp.length(), sStep3.length()));
        
        arrows3.add(makeArrow(secondTwoInLine1, q3_off, arrowColor, false, false, s3IsMulti, step3_arrow2_curve, nullptr, 0, false, false, 1, sStep3.length()));

        steps.add(makeStep(
                context.getString(10091),
                sOp + JString(u" \u00D7 2 = ?"),
                eq3,
                sStep3,
                arrows3
        ));

        
        JString line3 = sStep2 + JString(u" + ") + sStep3;
        int32_t l4_off = l3_off + line3.length() + 1; 
        JString q4 = getQuestionMarks(sFinal.length());
        JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + q4;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        
        arrows4.add(makeArrow(l3_off, l4_off, arrowColor, false, s2IsMulti, finalIsMulti, step4_arrow1_curve, sStep2 + JString(u"+") + sStep3, hintColor, false, false, sStep2.length(), sFinal.length()));
        
        arrows4.add(makeArrow(q3_off, l4_off, arrowColor, false, s3IsMulti, finalIsMulti, step4_arrow2_curve, nullptr, 0, false, false, sStep3.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10012),
                sStep2 + JString(u" + ") + sStep3 + JString(u" = ?"),
                eq4,
                sFinal,
                arrows4
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForMultiplyBy8(JContext context, int32_t operand) {
        return getStepsForMultiplyBy8(context, operand, false);
    }

    JList<Step*> getStepsForMultiplyBy8(JContext context, int32_t operand, bool usePartitionMethod) {
        if (usePartitionMethod) {
            return getStepsForMultiplyBy8Partition(context, operand);
        } else {
            return getStepsForMultiplyBy8Classic(context, operand);
        }
    }

    JList<Step*> getStepsForMultiplyBy8Classic(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f; 
        float step1_arrow2_curve = 0.0f; 

        float step2_arrow1_curve = 0.0f; 
        float step2_arrow2_curve = -1.0f; 

        float step3_arrow1_curve = 0.0f; 
        float step3_arrow2_curve = -1.5f; 

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 8");
        JString split8 = JString(u"(2\u00D72\u00D72)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split8;

        int32_t step1Res = operand * 2;
        int32_t step2Res = step1Res * 2;
        int32_t finalRes = operand * 8;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op8Idx        = line0.lastIndexOf(JString(u"8"));
        int32_t firstTwoPos   = l1_off + splitStart + split8.indexOf(JString(u"2"));
        int32_t secondTwoPos  = l1_off + splitStart + split8.indexOf(JString(u"2"), split8.indexOf(JString(u"2")) + 1);
        int32_t thirdTwoPos   = l1_off + splitStart + split8.lastIndexOf(JString(u"2"));

        
        int32_t topDimmedArrowTarget = secondTwoPos;

        bool opIsMulti = sOp.length() > 1;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(op8Idx, topDimmedArrowTarget, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, opIsMulti, (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D72"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(firstTwoPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10091),
                sOp + JString(u" \u00D7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D72"), hintColor, false, false, sStep1.length(), sStep2.length()));
        
        arrows2.add(makeArrow(secondTwoPos, l3_off, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10102),
                sStep1 + JString(u" \u00D7 2 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line3 = sStep2;
        int32_t l4_off = l3_off + line3.length() + 1; 
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l3_off, l4_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep2 + JString(u"\u00D72"), hintColor, false, false, sStep2.length(), sFinal.length()));
        
        arrows3.add(makeArrow(thirdTwoPos, l4_off, arrowColor, false, false, (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10102),
                sStep2 + JString(u" \u00D7 2 = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForMultiplyBy8Partition(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 7; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 8");
        JString split8 = JString(u"(10 - 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split8;

        int32_t step1Res = operand * 10;
        int32_t step2Res = operand * 2;
        int32_t finalRes = operand * 8;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op8Idx       = line0.lastIndexOf(JString(u"8"));
        int32_t tenPos       = l1_off + splitStart + split8.indexOf(JString(u"10"));
        int32_t twoPos       = l1_off + splitStart + split8.indexOf(JString(u"2"));
        int32_t minusInLine1 = l1_off + splitStart + split8.indexOf(JString(u"-"));

        
        int32_t topDimmedArrowTarget = minusInLine1;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" - ") + q2;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(op8Idx, topDimmedArrowTarget, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D710"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(tenPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10088),
                sOp + JString(u" \u00D7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" - ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D72"), hintColor, false, false, sOp.length(), sStep2.length()));
        
        arrows2.add(makeArrow(twoPos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10091),
                sOp + JString(u" \u00D7 2 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line2 = sStep1 + JString(u" - ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"-") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows3.add(makeArrow(l2_off + sStep1.length() + 3, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10173),
                sStep1 + JString(u" - ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    
    JList<Step*> getStepsForMultiplyBy9(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 7; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 9");
        JString split9 = JString(u"(10 - 1)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split9;

        int32_t step1Res = operand * 10;
        int32_t step2Res = operand * 1;
        int32_t finalRes = operand * 9;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op9Idx       = line0.lastIndexOf(JString(u"9"));
        int32_t tenPos       = l1_off + splitStart + split9.indexOf(JString(u"10"));
        int32_t onePos       = l1_off + splitStart + split9.lastIndexOf(JString(u"1"));
        int32_t minusInLine1 = l1_off + splitStart + split9.indexOf(JString(u"-"));

        
        int32_t topDimmedArrowTarget = minusInLine1;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" - ") + q2;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(op9Idx, topDimmedArrowTarget, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D710"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(tenPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10088),
                sOp + JString(u" \u00D7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" - ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D71"), hintColor, false, false, sOp.length(), sStep2.length()));
        
        arrows2.add(makeArrow(onePos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line2 = sStep1 + JString(u" - ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"-") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows3.add(makeArrow(l2_off + sStep1.length() + 3, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10173),
                sStep1 + JString(u" - ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    
    JList<Step*> getStepsForMultiplyBy99(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 1.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 99");
        JString split99 = JString(u"(100 - 1)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split99;

        int32_t step1Res = operand * 100;
        int32_t step2Res = operand * 1;
        int32_t finalRes = operand * 99;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op99Idx      = line0.lastIndexOf(JString(u"99"));
        int32_t hundredPos   = l1_off + splitStart + split99.indexOf(JString(u"100"));
        int32_t onePos       = l1_off + splitStart + split99.lastIndexOf(JString(u"1"));
        int32_t minusInLine  = l1_off + splitStart + split99.indexOf(JString(u"-"));

        
        int32_t topDimmedArrowStart  = op99Idx;
        int32_t topDimmedArrowTarget = minusInLine;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" - ") + q2;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D7100"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(hundredPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 3, sStep1.length()));

        steps.add(makeStep(
                context.getString(10089),
                sOp + JString(u" \u00D7 100 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" - ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D71"), hintColor, false, false, sOp.length(), sStep2.length()));
        
        arrows2.add(makeArrow(onePos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line2 = sStep1 + JString(u" - ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"-") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows3.add(makeArrow(l2_off + sStep1.length() + 3, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10173),
                sStep1 + JString(u" - ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    
    JList<Step*> getStepsForMultiplyBy20(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;    
        float step2_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 20");
        JString split20 = JString(u"(2 \u00D7 10)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split20;

        int32_t step1Res = operand * 2;
        int32_t finalRes = operand * 20;

        JString sStep1 = JString::valueOf(step1Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op20Idx     = line0.lastIndexOf(JString(u"20"));
        int32_t twoPos      = l1_off + splitStart + split20.indexOf(JString(u"2"));
        int32_t tenPos      = l1_off + splitStart + split20.indexOf(JString(u"10"));
        int32_t mulInLine1  = l1_off + splitStart + split20.indexOf(JString(u"\u00D7"));

        
        int32_t topDimmedArrowStart  = op20Idx;
        int32_t topDimmedArrowTarget = mulInLine1;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D72"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(twoPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10091),
                sOp + JString(u" \u00D7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q2 = getQuestionMarks(sFinal.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D710"), hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows2.add(makeArrow(tenPos, l3_off, arrowColor, false, true, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 2, sFinal.length()));

        steps.add(makeStep(
                context.getString(10099),
                sStep1 + JString(u" \u00D7 10 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy25(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;    
        float step2_arrow2_curve = -1.0f;    

        
        int32_t splitStartOffset = 8; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 25");
        JString split25 = JString(u"(100 \u00F7 4)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split25;

        double step1Val = (double) operand / 4.0;
        int32_t finalRes = operand * 25;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op25Idx     = line0.lastIndexOf(JString(u"25"));
        int32_t hundredPos  = l1_off + splitStart + split25.indexOf(JString(u"100"));
        int32_t fourPos     = l1_off + splitStart + split25.indexOf(JString(u"4"));
        int32_t divInLine1  = l1_off + splitStart + split25.indexOf(JString(u"\u00F7"));

        
        int32_t topDimmedArrowStart  = op25Idx;
        int32_t topDimmedArrowTarget = divInLine1;

        
        
        

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F74"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(fourPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10053),
                sOp + JString(u" \u00F7 4 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        
        Step* firstStep = steps.get(0);
        firstStep->frozenArrows = cloneArrows(arrows1, false);
        for (Arrow* arrow : firstStep->frozenArrows) {
            if (arrow->endOffset == l2_off) {
                arrow->tokenLength = q1.length();
            }
        }
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D7100"), hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows2.add(makeArrow(hundredPos, l3_off, arrowColor, false, true, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 3, sFinal.length()));

        steps.add(makeStep(
                context.getString(10100),
                sStep1 + JString(u" \u00D7 100 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy50(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;    
        float step2_arrow2_curve = -1.0f;    

        
        int32_t splitStartOffset = 8; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 50");
        JString split50 = JString(u"(100 \u00F7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split50;

        double step1Val = (double) operand / 2.0;
        int32_t finalRes = operand * 50;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op50Idx     = line0.lastIndexOf(JString(u"50"));
        int32_t hundredPos  = l1_off + splitStart + split50.indexOf(JString(u"100"));
        int32_t twoPos      = l1_off + splitStart + split50.indexOf(JString(u"2"));
        int32_t divInLine1  = l1_off + splitStart + split50.indexOf(JString(u"\u00F7"));

        
        int32_t topDimmedArrowStart  = op50Idx;
        int32_t topDimmedArrowTarget = divInLine1;

        
        
        

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F72"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(twoPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10052),
                sOp + JString(u" \u00F7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D7100"), hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows2.add(makeArrow(hundredPos, l3_off, arrowColor, false, true, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 3, sFinal.length()));

        steps.add(makeStep(
                context.getString(10100),
                sStep1 + JString(u" \u00D7 100 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy75(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 1.3f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.0f;  
        float step2_arrow2_curve = -1.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = -3.5f; 

        
        int32_t splitStartOffset = 6; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 75");
        JString split75 = JString(u"(100\u00F74\u00D73)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split75;

        double step1Val = (double) operand / 4.0;
        double step2Val = step1Val * 3.0;
        int32_t finalRes = operand * 75;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sStep2 = (step2Val == (int64_t) step2Val) ? JString::valueOf((int64_t) step2Val) : JString::valueOf(step2Val);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op75Idx     = line0.lastIndexOf(JString(u"75"));
        int32_t hundredPos  = l1_off + splitStart + split75.indexOf(JString(u"100"));
        int32_t fourPos     = l1_off + splitStart + split75.indexOf(JString(u"4"));
        int32_t threePos    = l1_off + splitStart + split75.indexOf(JString(u"3"));
        int32_t divInLine1  = l1_off + splitStart + split75.indexOf(JString(u"\u00F7"));

        
        int32_t topDimmedArrowStart  = op75Idx;
        int32_t topDimmedArrowTarget = fourPos;

        
        
        

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F74"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(fourPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10053),
                sOp + JString(u" \u00F7 4 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q2 = getQuestionMarksForAnswer(sStep2);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D73"), hintColor, false, false, sStep1.length(), sStep2.length()));
        
        arrows2.add(makeArrow(threePos, l3_off, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10103),
                sStep1 + JString(u" \u00D7 3 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line3 = sStep2;
        int32_t l4_off = l3_off + line3.length() + 1; 
        JString q3 = getQuestionMarksForAnswer(sFinal);
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l3_off, l4_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep2 + JString(u"\u00D7100"), hintColor, false, false, sStep2.length(), sFinal.length()));
        
        arrows3.add(makeArrow(hundredPos, l4_off, arrowColor, false, true, (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, 3, sFinal.length()));

        steps.add(makeStep(
                context.getString(10105),
                sStep2 + JString(u" \u00D7 100 = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyTwoDigitNumbersSameTens(JContext context, int32_t operand1, int32_t operand2) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step0_arrow2_curve = 0.0f;  
        float step0_arrow3_curve = 0.0f;  
        float step0_arrow4_curve = 0.0f;  

        float step1_arrow_curve  = 0.0f;    
        float step2_arrow_curve  = 0.0f;    

        
        int32_t splitStartOffset = -7; 

        
        
        

        int32_t tens = operand1 / 10;
        int32_t u1   = operand1 % 10;
        int32_t u2   = operand2 % 10;

        JString sOp1 = JString::valueOf(operand1);
        JString sOp2 = JString::valueOf(operand2);
        JString line0 = sOp1 + JString(u" \u00D7 ") + sOp2; 
        JString splitStr = tens + JString(u" \u00D7 ") + (tens + 1) + JString(u" _ ") + u1 + JString(u" \u00D7 ") + u2; 
        int32_t splitStart = line0.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + splitStr;

        int32_t step1Res = tens * (tens + 1);
        int32_t step2ResInt = u1 * u2;
        int32_t finalRes = operand1 * operand2;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = step2ResInt < 10 ? (JString(u"0") + step2ResInt) : JString::valueOf(step2ResInt);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        
        int32_t op1TensPos  = 0;                   
        int32_t op1UnitsPos = 1;                   
        int32_t op2UnitsPos = sOp1.length() + 4;  

        
        int32_t splitStartInFull = l1_off + splitStart;

        
        int32_t expr1TensPos     = splitStartInFull + splitStr.indexOf(JString::valueOf(tens));                   
        int32_t expr1MulPos      = splitStartInFull + splitStr.indexOf(JString(u"\u00D7"));                              
        int32_t expr1NextTensPos = splitStartInFull + splitStr.indexOf(JString::valueOf(tens + 1));             

        
        int32_t secondExprStartInSplit = splitStr.indexOf(JString(u"_")) + 1;
        int32_t u1InSecondExpr = splitStr.indexOf(JString::valueOf(u1), secondExprStartInSplit);
        int32_t expr2U1Pos = splitStartInFull + u1InSecondExpr;                                             
        int32_t expr2MulPos = splitStartInFull + splitStr.indexOf(JString(u"\u00D7"), secondExprStartInSplit);         
        int32_t u2InSecondExpr = splitStr.indexOf(JString::valueOf(u2), u1InSecondExpr + 1);
        if (u2InSecondExpr == -1) u2InSecondExpr = splitStr.lastIndexOf(JString::valueOf(u2));
        int32_t expr2U2Pos = splitStartInFull + u2InSecondExpr;                                             

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString q2 = getQuestionMarksForAnswer(sStep2);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + getSpaces(q2.length());

        JList<Arrow*> arrows1 = {};
        
        
        arrows1.add(makeArrow(op1TensPos, expr1TensPos, arrowColor, true, false, false, 0.0f, nullptr, 0));
        
        arrows1.add(makeArrow(op1TensPos, expr1NextTensPos, arrowColor, true, false, false, step0_arrow2_curve, tens + JString(u"+1"), hintColor, true, true));
        
        arrows1.add(makeArrow(op1UnitsPos, expr2U1Pos, arrowColor, true, false, false, step0_arrow3_curve, nullptr, 0));
        
        arrows1.add(makeArrow(op2UnitsPos, expr2U2Pos, arrowColor, true, true, false, step0_arrow4_curve, nullptr, 0));

        
        Arrow* step1Arrow = makeArrow(expr1MulPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow_curve, JString(u"\u00D7"), 0xFF1976D2, false, false, 1, sStep1.length());
        arrows1.add(step1Arrow);

        steps.add(makeStep(
                context.getString(10140),
                tens + JString(u" \u00D7 (") + tens + JString(u" + 1) = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        int32_t step2ResPosInL2 = l2_off + sStep1.length();

        if (step2ResInt < 10) {
            
            JString eq2A = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"?") + getSpaces(1);
            JList<Arrow*> arrows2A = cloneAndDim(arrows1);
            arrows2A.add(makeArrow(expr2MulPos, step2ResPosInL2, arrowColor, false, false, false, 0.0f, sStep2, hintColor, false, false, 1, 1));

            steps.add(makeStep(
                    context.getString(10138, u1, u2, step2ResInt),
                    u1 + JString(u" \u00D7 ") + u2 + JString(u" = ?"),
                    eq2A,
                    JString(u"0"),
                    arrows2A
            ));

            
            JString eq2B = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"0?");
            JList<Arrow*> arrows2B = cloneAndDim(arrows2A);
            arrows2B.add(makeArrow(expr2MulPos, step2ResPosInL2 + 1, arrowColor, false, false, false, 0.0f, sStep2, hintColor, false, false, 1, 1));

            steps.add(makeStep(
                    context.getString(10139, u1, u2, step2ResInt),
                    u1 + JString(u" \u00D7 ") + u2 + JString(u" = ?"),
                    eq2B,
                    JString::valueOf(step2ResInt),
                    arrows2B
            ));

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows2B, false);
            for (Arrow* a : arrowsFinal) {
                if (a->endOffset == step2ResPosInL2 && sStep2.equals(a->label)) {
                    a->label = nullptr; 
                }
            }
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1 + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
        } else {
            
            JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + q2;
            JList<Arrow*> arrows2 = cloneAndDim(arrows1);
            Arrow* step2Arrow = makeArrow(expr2MulPos, step2ResPosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow_curve, JString(u"\u00D7"), 0xFF1976D2, false, false, 1, sStep2.length());
            arrows2.add(step2Arrow);

            steps.add(makeStep(
                    context.getString(10141),
                    u1 + JString(u" \u00D7 ") + u2 + JString(u" = ?"),
                    eq2,
                    sStep2,
                    arrows2
            ));

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1 + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
        }

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyNumbersBetween11And19(JContext context, int32_t operand1, int32_t operand2) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        int32_t larger = JMath::max(operand1, operand2);
        int32_t smaller = JMath::min(operand1, operand2);

        int32_t u1 = operand1 % 10;
        int32_t u2 = operand2 % 10;
        int32_t rightDigitOfOther = smaller % 10;

        JString sOp1 = JString::valueOf(operand1);
        JString sOp2 = JString::valueOf(operand2);
        JString line0 = sOp1 + JString(u" \u00D7 ") + sOp2;

        int32_t step1Res = larger + rightDigitOfOther;
        int32_t step2Res = step1Res * 10;
        int32_t step3Res = u1 * u2;
        int32_t finalRes = operand1 * operand2;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;

        int32_t largerPos;
        int32_t rightDigitOfOtherPos;

        if (operand1 >= operand2) {
            largerPos = 0;
            rightDigitOfOtherPos = line0.length() - 1;
        } else {
            largerPos = line0.length() - sOp2.length();
            rightDigitOfOtherPos = sOp1.length() - 1;
        }

        int32_t u1Pos = sOp1.length() - 1;
        int32_t u2Pos = line0.length() - 1;

        JString qStep2 = getQuestionMarksForAnswer(sStep2);
        JString qStep3 = getQuestionMarksForAnswer(sStep3);
        JString fullRow = qStep2 + JString(u" + ") + qStep3;

        
        JString eq1 = line0 + JString(u"\n") + fullRow;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(largerPos, l1_off, arrowColor, false, (larger > 9), true, 0.0f, larger + JString(u"+") + rightDigitOfOther, hintColor, false, false, JString::valueOf(larger).length(), sStep1.length()));
        arrows1.add(makeArrow(rightDigitOfOtherPos, l1_off, arrowColor, false, false, true, 0.0f, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10076),
                larger + JString(u" + ") + rightDigitOfOther + JString(u" = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString eq2 = line0 + JString(u"\n") + sStep1 + JString(u"? + ") + qStep3;
        int32_t zeroPos = l1_off + sStep1.length();

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(zeroPos, zeroPos, 0, false, false, false, 0.0f, JString(u"0"), hintColor, true, false, 1));

        steps.add(makeStep(
                context.getString(10077),
                sStep1 + JString(u" \u00D7 10 = ?"),
                eq2,
                JString(u"0"),
                arrows2
        ));

        
        JString eq3 = line0 + JString(u"\n") + sStep2 + JString(u" + ") + qStep3;
        int32_t qStep3Pos = l1_off + sStep2.length() + 3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(u1Pos, qStep3Pos, arrowColor, false, false, true, 0.0f, u1 + JString(u"\u00D7") + u2, hintColor, false, false, 1, sStep3.length()));
        arrows3.add(makeArrow(u2Pos, qStep3Pos, arrowColor, false, false, true, 0.0f, nullptr, 0, false, false, 1, sStep3.length()));

        steps.add(makeStep(
                context.getString(10078),
                u1 + JString(u" \u00D7 ") + u2 + JString(u" = ?"),
                eq3,
                sStep3,
                arrows3
        ));

        
        JString line1_step4 = sStep2 + JString(u" + ") + sStep3;
        int32_t l2_off = l1_off + line1_step4.length() + 1;
        JString q4 = getQuestionMarksForAnswer(sFinal);
        JString eq4 = line0 + JString(u"\n") + line1_step4 + JString(u"\n") + q4;

        int32_t step2PosInL1 = l1_off;
        int32_t step3PosInL1 = l1_off + sStep2.length() + 3;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        
        
        arrows4.add(makeArrow(step2PosInL1, l2_off, arrowColor, false, (sStep2.length() > 1), (finalRes > 9), 0.0f, sStep2 + JString(u"+") + sStep3, hintColor, false, false, sStep2.length(), sFinal.length()));
        arrows4.add(makeArrow(step3PosInL1, l2_off, arrowColor, false, (sStep3.length() > 1), (finalRes > 9), 0.0f, nullptr, 0, false, false, sStep3.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10012),
                sStep2 + JString(u" + ") + sStep3 + JString(u" = ?"),
                eq4,
                sFinal,
                arrows4
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1_step4 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy12(JContext context, int32_t operand) {
        return getStepsForMultiplyBy10PlusDigit(context, operand, 12, 2, 10091);
    }

    
    JList<Step*> getStepsForMultiplyBy13(JContext context, int32_t operand) {
        return getStepsForMultiplyBy10PlusDigit(context, operand, 13, 3, 10093);
    }

    
    JList<Step*> getStepsForMultiplyBy14(JContext context, int32_t operand) {
        return getStepsForMultiplyBy10PlusDigit(context, operand, 14, 4, 10094);
    }

    
    JList<Step*> getStepsForMultiplyBy15(JContext context, int32_t operand) {
        JString customStep2Hint = JString::valueOf(operand) + JString(u" \u00D7 5 = ") + (operand * 10) + JString(u" \u00F7 2 = ?");
        return getStepsForMultiplyBy10PlusDigit(context, operand, 15, 5, 10095, customStep2Hint);
    }

    
    JList<Step*> getStepsForMultiplyBy16(JContext context, int32_t operand) {
        return getStepsForMultiplyBy16(context, operand, false);
    }

    JList<Step*> getStepsForMultiplyBy16(JContext context, int32_t operand, bool use10Plus5Plus1Method) {
        if (use10Plus5Plus1Method) {
            return getStepsForMultiplyBy16Sum(context, operand);
        }
        return getStepsForMultiplyBy16Sub(context, operand);
    }

    
    JList<Step*> getStepsForMultiplyBy16Sub(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 8; 

        
        bool topDimmedArrowStartGap = true; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 16");
        JString split16 = JString(u"(20 - 4)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split16;

        int32_t step1Res = operand * 20;
        int32_t step2Res = operand * 4;
        int32_t finalRes = operand * 16;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op16Idx      = line0.lastIndexOf(JString(u"16"));
        int32_t twentyPos    = l1_off + splitStart + split16.indexOf(JString(u"20"));
        int32_t fourPos      = l1_off + splitStart + split16.indexOf(JString(u"4"));
        int32_t minusInLine  = l1_off + splitStart + split16.indexOf(JString(u"-"));

        
        int32_t topDimmedArrowStart  = op16Idx;
        int32_t topDimmedArrowTarget = minusInLine;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" - ") + q2;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, topDimmedArrowStartGap, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D720"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(twentyPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10092),
                sOp + JString(u" \u00D7 20 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" - ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D74"), hintColor, false, false, sOp.length(), sStep2.length()));
        
        arrows2.add(makeArrow(fourPos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10094),
                sOp + JString(u" \u00D7 4 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line2 = sStep1 + JString(u" - ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"-") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows3.add(makeArrow(l2_off + sStep1.length() + 3, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10173),
                sStep1 + JString(u" - ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    
    JList<Step*> getStepsForMultiplyBy16Sum(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 2.0f;  
        float step3_arrow2_curve = 0.0f;    

        float step4_arrow1_curve = 0.0f;    
        float step4_arrow2_curve = 0.0f;    
        float step4_arrow3_curve = 0.0f;    

        
        int32_t splitStartOffset = 9; 

        
        bool topDimmedArrowStartGap = true; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 16");
        JString split16 = JString(u"(10 + 5 + 1)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split16;

        int32_t step1Res = operand * 10;
        int32_t step2Res = operand * 5;
        int32_t step3Res = operand * 1;
        int32_t finalRes = operand * 16;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t op16Idx       = line0.lastIndexOf(JString(u"16"));
        int32_t tenPos        = l1_off + splitStart + split16.indexOf(JString(u"10"));
        int32_t fivePos       = l1_off + splitStart + split16.indexOf(JString(u"5"));
        int32_t onePos        = l1_off + splitStart + split16.lastIndexOf(JString(u"1"));

        
        int32_t topDimmedArrowStart  = op16Idx;
        int32_t topDimmedArrowTarget = fivePos;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString q3 = getQuestionMarks(sStep3.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" + ") + q2 + JString(u" + ") + q3;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, topDimmedArrowStartGap, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D710"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(tenPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10088),
                sOp + JString(u" \u00D7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" + ") + q2 + JString(u" + ") + q3;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D75"), hintColor, false, false, sOp.length(), sStep2.length()));
        
        arrows2.add(makeArrow(fivePos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        JString step2Hint = sOp + JString(u" \u00D7 5 = ") + sStep1 + JString(u" \u00F7 2 = ?");

        steps.add(makeStep(
                context.getString(10095),
                step2Hint,
                eq2,
                sStep2,
                arrows2
        ));

        
        int32_t q3PosInL2 = q2PosInL2 + sStep2.length() + 3;
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" + ") + sStep2 + JString(u" + ") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(0, q3PosInL2, arrowColor, false, (sOp.length() > 1), (sStep3.length() > 1), step3_arrow1_curve, sOp + JString(u"\u00D71"), hintColor, false, false, sOp.length(), sStep3.length()));
        
        arrows3.add(makeArrow(onePos, q3PosInL2, arrowColor, false, false, (sStep3.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, 1, sStep3.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq3,
                sStep3,
                arrows3
        ));

        
        JString line2 = sStep1 + JString(u" + ") + sStep2 + JString(u" + ") + sStep3;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q4 = getQuestionMarks(sFinal.length());
        JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q4;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        
        arrows4.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step4_arrow1_curve, sStep1 + JString(u"+") + sStep2 + JString(u"+") + sStep3, hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows4.add(makeArrow(q2PosInL2, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step4_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));
        
        arrows4.add(makeArrow(q3PosInL2, l3_off, arrowColor, false, (sStep3.length() > 1), (sFinal.length() > 1), step4_arrow3_curve, nullptr, 0, false, false, sStep3.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10011),
                sStep1 + JString(u" + ") + sStep2 + JString(u" + ") + sStep3 + JString(u" = ?"),
                eq4,
                sFinal,
                arrows4
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy17(JContext context, int32_t operand) {
        return getStepsForMultiplyBy20MinusDigit(context, operand, 17, 3, 10093);
    }

    
    JList<Step*> getStepsForMultiplyBy18(JContext context, int32_t operand) {
        return getStepsForMultiplyBy20MinusDigit(context, operand, 18, 2, 10091);
    }

    
    JList<Step*> getStepsForMultiplyBy19(JContext context, int32_t operand) {
        return getStepsForMultiplyBy20MinusDigit(context, operand, 19, 1, 10087);
    }

    
    JList<Step*> getStepsForMultiplyBy20MinusDigit(JContext context, int32_t operand, int32_t multiplier, int32_t digit, int32_t digitStepTitleRes) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 8; 

        
        bool topDimmedArrowStartGap = true; 

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 ") + multiplier;
        JString splitStr = JString(u"(20 - ") + digit + JString(u")");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + splitStr;

        int32_t step1Res = operand * 20;
        int32_t step2Res = operand * digit;
        int32_t finalRes = operand * multiplier;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t opMultIdx    = line0.lastIndexOf(JString::valueOf(multiplier));
        int32_t twentyPos    = l1_off + splitStart + splitStr.indexOf(JString(u"20"));
        int32_t digitPos     = l1_off + splitStart + splitStr.lastIndexOf(JString::valueOf(digit));
        int32_t minusInLine  = l1_off + splitStart + splitStr.indexOf(JString(u"-"));

        
        int32_t topDimmedArrowStart  = opMultIdx;
        int32_t topDimmedArrowTarget = minusInLine;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" - ") + q2;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, topDimmedArrowStartGap, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D720"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(twentyPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10092),
                sOp + JString(u" \u00D7 20 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" - ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D7") + digit, hintColor, false, false, sOp.length(), sStep2.length()));
        
        arrows2.add(makeArrow(digitPos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(digitStepTitleRes),
                sOp + JString(u" \u00D7 ") + digit + JString(u" = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line2 = sStep1 + JString(u" - ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"-") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows3.add(makeArrow(l2_off + sStep1.length() + 3, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10173),
                sStep1 + JString(u" - ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    
    JList<Step*> getStepsForMultiplyBy10PlusDigit(JContext context, int32_t operand, int32_t multiplier, int32_t digit, int32_t digitStepTitleRes) {
        return getStepsForMultiplyBy10PlusDigit(context, operand, multiplier, digit, digitStepTitleRes, nullptr);
    }

    JList<Step*> getStepsForMultiplyBy10PlusDigit(JContext context, int32_t operand, int32_t multiplier, int32_t digit, int32_t digitStepTitleRes, JString customStep2Hint) {
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step1_arrow1_curve = 0.0f;    
        float step1_arrow2_curve = 0.0f;    

        float step2_arrow1_curve = 0.6f;  
        float step2_arrow2_curve = 0.0f;    

        float step3_arrow1_curve = 0.0f;    
        float step3_arrow2_curve = 0.0f;    

        
        int32_t splitStartOffset = 8; 

        
        
        bool topDimmedArrowStartGap = true;

        
        
        

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 ") + multiplier;
        JString splitStr = JString(u"(10 + ") + digit + JString(u")");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + splitStr;

        int32_t step1Res = operand * 10;
        int32_t step2Res = operand * digit;
        int32_t finalRes = operand * multiplier;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        
        int32_t l1_off = line0.length() + 1;          
        int32_t l2_off = l1_off + line1.length() + 1;  

        
        int32_t opMultIdx    = line0.lastIndexOf(JString::valueOf(multiplier));
        int32_t tenPos       = l1_off + splitStart + splitStr.indexOf(JString(u"10"));
        int32_t digitPos     = l1_off + splitStart + splitStr.indexOf(JString::valueOf(digit));
        int32_t plusInLine   = l1_off + splitStart + splitStr.indexOf(JString(u"+"));

        
        int32_t topDimmedArrowStart  = opMultIdx;
        int32_t topDimmedArrowTarget = plusInLine;

        
        
        

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" + ") + q2;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, topDimmedArrowStartGap, false, 0.0f, nullptr, 0, false, false, 2, 1));
        
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D710"), hintColor, false, false, sOp.length(), sStep1.length()));
        
        arrows1.add(makeArrow(tenPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10088),
                sOp + JString(u" \u00D7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" + ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D7") + digit, hintColor, false, false, sOp.length(), sStep2.length()));
        
        arrows2.add(makeArrow(digitPos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        JString step2Hint = (customStep2Hint != nullptr) ? customStep2Hint : (sOp + JString(u" \u00D7 ") + digit + JString(u" = ?"));

        steps.add(makeStep(
                context.getString(digitStepTitleRes),
                step2Hint,
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line2 = sStep1 + JString(u" + ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1; 
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"+") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        
        arrows3.add(makeArrow(l2_off + sStep1.length() + 3, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10010),
                sStep1 + JString(u" + ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForAdditionColumn(JContext context, int32_t op1, int32_t op2) {
        JList<Step*> steps = {};
        JString sOp1 = JString::valueOf(op1);
        JString sOp2 = JString::valueOf(op2);
        int32_t maxLen = JMath::max(sOp1.length(), sOp2.length());
        JString padOp1 = JString::format(JString(u"%") + maxLen + JString(u"s"), sOp1);
        JString padOp2 = JString::format(JString(u"%") + maxLen + JString(u"s"), sOp2);
        JArray<char16_t> carries = JArray<char16_t>(maxLen + 1);
        JArray<char16_t> resultDigits = JArray<char16_t>(maxLen + 1);
        JArrays::fill(carries, u' ');
        
        
        JArrays::fill(resultDigits, u' ');

        int32_t arrowColor = 0xFF888888;
        int32_t lineStart = 2 * (maxLen + 3);
        int32_t lineEnd = lineStart + 2 + maxLen;
        Arrow* separator = makeArrow(lineStart, lineEnd, arrowColor, false, false, false, 0.0f, nullptr, 0, false, false, true, 0, 0);

        int32_t carry = 0;
        for (int32_t col = maxLen - 1; col >= 0; col--) {
            bool isFirstColumn = col == maxLen - 1;
            bool isLastColumn = col == 0;
            bool hasIncomingCarry = carry > 0;
            char16_t c1 = padOp1.charAt(col);
            char16_t c2 = padOp2.charAt(col);
            int32_t d1 = c1 == u' ' ? 0 : JCharacter::getNumericValue(c1);
            int32_t d2 = c2 == u' ' ? 0 : JCharacter::getNumericValue(c2);
            int32_t sum = d1 + d2 + carry;
            int32_t units = sum % 10;
            int32_t nextCarry = sum / 10;

            JString hint;
            JString desc;
            JString columnName = isFirstColumn
                    ? context.getString(10026)
                    : context.getString(10027);

            if (c1 == u' ' || c2 == u' ') {
                int32_t digit = (c1 == u' ') ? d2 : d1;
                if (carry == 0) {
                    desc = context.getString(10024);
                    hint = digit + JString(u" = ?");
                } else {
                    desc = context.getString(10019, columnName);
                    hint = digit + JString(u" + ") + carry + JString(u" = ?");
                }
            } else {
                hint = carry == 0 ? d1 + JString(u" + ") + d2 + JString(u" = ?") : d1 + JString(u" + ") + d2 + JString(u" + ") + carry + JString(u" = ?");
                desc = nextCarry == 0 || isLastColumn
                        ? (hasIncomingCarry
                            ? context.getString(10021, columnName)
                            : context.getString(10020, columnName))
                        : (hasIncomingCarry
                            ? context.getString(10022, columnName)
                            : context.getString(10023, columnName));
            }

            JList<Arrow*> unitsArrows = {};
            unitsArrows.add(separator);

            resultDigits[col + 1] = u'?';
            Step* unitsStep = makeStep(
                    desc,
                    hint,
                    buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+")),
                    JString::valueOf(units),
                    unitsArrows
            );
            unitsStep->pulseIndex = getResultQuestionMarkIndex(unitsStep->equation, col + 1);
            steps.add(unitsStep);

            resultDigits[col + 1] = JCharacter::forDigit(units, 10);
            if (nextCarry == 0) {
                
                
                carry = 0;
            } else {
                
                
                if (isLastColumn) {
                    carry = nextCarry;
                    continue;
                }
                
                carries[col] = u'?';
                JList<Arrow*> carryArrows = {};
                carryArrows.add(separator);
                Step* carryStep = makeStep(
                        context.getString(10028),
                        JString::valueOf(nextCarry),
                        buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+")),
                        JString::valueOf(nextCarry),
                        carryArrows
                );
                carryStep->pulseIndex = getCarryQuestionMarkIndex(carryStep->equation, col);
                steps.add(carryStep);
                carries[col] = JCharacter::forDigit(nextCarry, 10);
                carry = nextCarry;
            }
        }

        if (carry > 0) {
            resultDigits[0] = u'?';
            JList<Arrow*> finalCarryArrows = {};
            finalCarryArrows.add(separator);
            Step* finalCarry = makeStep(
                    context.getString(10029),
                    context.getString(10025),
                    buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+")), JString::valueOf(carry), finalCarryArrows);
            finalCarry->pulseIndex = getResultQuestionMarkIndex(finalCarry->equation, 0);
            steps.add(finalCarry);
            resultDigits[0] = JCharacter::forDigit(carry, 10);
        }

        JList<Arrow*> finalArrows = {};
        finalArrows.add(separator);
        Step* finalStep = makeStep(context.getString(10073, op1 + op2), nullptr,
                buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+")), JString(u""), finalArrows);
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    
    JList<Step*> getStepsForToughMultiplication(JContext context, int32_t op1, int32_t op2) {
        if (op1 < 1 || op2 < 1) {
            throw JavaArgumentError(JString(u"Tough multiplication requires positive operands"));
        }

        int64_t first = JMath::min(op1, op2);
        int64_t second = JMath::max(op1, op2);
        int64_t product = (int64_t) op1 * (int64_t) op2;
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        JList<Step*> steps = {};
        JList<JString> rows = {};
        JList<Arrow*> activeArrows = {};
        rows.add(first + JString(u" × ") + second);
        bool divideFirst = getToughMultiplicationFactor(first) != 0;
        if (!divideFirst && getToughMultiplicationFactor(second) == 0) {
            divideFirst = true;
        }

        bool canLoop = (first > 2);
        if (!divideFirst && (first % 5 != 0 || second % 2 != 0)) {
            canLoop = false;
        }

        while (canLoop) {
            int64_t dividedValue = divideFirst ? first : second;
            int32_t factor = getToughMultiplicationFactor(dividedValue);
            if (factor == 0) break;

            int64_t nextFirst = divideFirst ? first / factor : first * factor;
            int64_t nextSecond = divideFirst ? second * factor : second / factor;

            if (!divideFirst && nextFirst > nextSecond) {
                break;
            }

            JString currentFirst = JString::valueOf(first);
            JString currentSecond = JString::valueOf(second);
            JString nextFirstValue = JString::valueOf(nextFirst);
            JString nextSecondValue = JString::valueOf(nextSecond);
            
            JString targetRow1 = getQuestionMarksForAnswer(nextFirstValue) + JString(u" × ")
                    + getQuestionMarksForAnswer(nextSecondValue);
            JString equation1 = buildToughMultiplicationEquation(rows, targetRow1);
            int32_t previousRowOffset = getToughMultiplicationLastRowOffset(rows);
            int32_t targetRowOffset = equation1.length() - targetRow1.length();
            int32_t currentSecondOffset = previousRowOffset + currentFirst.length() + 3;
            int32_t nextSecondOffset = targetRowOffset + nextFirstValue.length() + 3;

            JList<Arrow*> arrows1 = cloneAndDim(activeArrows);
            arrows1.add(makeArrow(previousRowOffset, targetRowOffset, arrowColor, false,
                    currentFirst.length() > 1, nextFirstValue.length() > 1, 0.0f,
                    (divideFirst ? JString(u"÷") : JString(u"×")) + factor, hintColor, false, false,
                    currentFirst.length(), nextFirstValue.length()));

            JString description1 = divideFirst
                    ? context.getString(10065, currentFirst, factor)
                    : context.getString(10118, currentFirst, factor);
            JString hintExpr1 = currentFirst + (divideFirst ? JString(u" ÷ ") : JString(u" × ")) + factor + JString(u" = ?");
            steps.add(makeStep(description1, hintExpr1, equation1, nextFirstValue, arrows1));

            
            JString targetRow2 = nextFirstValue + JString(u" × ")
                    + getQuestionMarksForAnswer(nextSecondValue);
            JString equation2 = buildToughMultiplicationEquation(rows, targetRow2);

            JList<Arrow*> arrows2 = cloneAndDim(arrows1);
            arrows2.add(makeArrow(currentSecondOffset, nextSecondOffset, arrowColor, false,
                    currentSecond.length() > 1, nextSecondValue.length() > 1, 0.0f,
                    (divideFirst ? JString(u"×") : JString(u"÷")) + factor, hintColor, false, false,
                    currentSecond.length(), nextSecondValue.length()));

            JString description2 = divideFirst
                    ? context.getString(10118, currentSecond, factor)
                    : context.getString(10065, currentSecond, factor);
            JString hintExpr2 = currentSecond + (divideFirst ? JString(u" × ") : JString(u" ÷ ")) + factor + JString(u" = ?");
            steps.add(makeStep(description2, hintExpr2, equation2, nextSecondValue, arrows2));

            rows.add(nextFirst + JString(u" × ") + nextSecond);
            activeArrows = arrows2;
            first = nextFirst;
            second = nextSecond;

            if (!divideFirst && (first % 10 == 0 || first >= second)) {
                break;
            }
        }

        JString lastFirst = JString::valueOf(first);
        JString lastSecond = JString::valueOf(second);
        JString productValue = JString::valueOf(product);
        JString productQuestion = getQuestionMarksForAnswer(productValue);
        JString productEquation = buildToughMultiplicationEquation(rows, productQuestion);
        int32_t lastRowOffset = getToughMultiplicationLastRowOffset(rows);
        int32_t productOffset = productEquation.length() - productQuestion.length();
        int32_t lastSecondOffset = lastRowOffset + lastFirst.length() + 3;

        JList<Arrow*> productArrows = cloneAndDim(activeArrows);
        productArrows.add(makeArrow(lastRowOffset, productOffset, arrowColor, false,
                lastFirst.length() > 1, productValue.length() > 1, 0.0f,
                JString(u"×"), hintColor, false, false, lastFirst.length(), productValue.length()));
        productArrows.add(makeArrow(lastSecondOffset, productOffset, arrowColor, false,
                lastSecond.length() > 1, productValue.length() > 1, 0.0f,
                nullptr, 0, false, false, lastSecond.length(), productValue.length()));
        steps.add(makeStep(context.getString(10118, lastFirst, second),
                lastFirst + JString(u" × ") + lastSecond + JString(u" = ?"),
                productEquation, productValue, productArrows));

        Step* finalStep = makeStep(context.getString(10073, product), nullptr,
                buildToughMultiplicationEquation(rows, productValue), JString(u""),
                cloneArrows(productArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    bool isToughMultiplicationSuitable(int32_t op1, int32_t op2) {
        if (op1 < 1 || op2 < 1) return false;
        int64_t first = JMath::min(op1, op2);
        int64_t second = JMath::max(op1, op2);
        if (first <= 2) return false;

        bool divideFirst = getToughMultiplicationFactor(first) != 0;
        if (!divideFirst && (first % 5 != 0 || second % 2 != 0)) {
            return false;
        }

        int32_t iterations = 0;
        int64_t curFirst = first;
        int64_t curSecond = second;

        while (true) {
            int64_t dividedValue = divideFirst ? curFirst : curSecond;
            int32_t factor = getToughMultiplicationFactor(dividedValue);
            if (factor == 0) break;

            int64_t nextFirst = divideFirst ? curFirst / factor : curFirst * factor;
            int64_t nextSecond = divideFirst ? curSecond * factor : curSecond / factor;

            if (!divideFirst && nextFirst > nextSecond) {
                break;
            }

            curFirst = nextFirst;
            curSecond = nextSecond;
            iterations++;

            if (!divideFirst && (curFirst % 10 == 0 || curFirst >= curSecond)) {
                break;
            }
        }

        if (iterations == 0) return false;
        if ((curFirst == first && curSecond == second) || (curFirst == second && curSecond == first)) {
            return false;
        }
        return true;
    }

    int32_t getToughMultiplicationFactor(int64_t value) {
        if (value > 10 && value % 10 == 0) return 10;
        if (value > 11 && value % 11 == 0) return 11;
        if (value > 3 && value % 3 == 0) return 3;
        if (value > 2 && value % 2 == 0) return 2;
        return 0;
    }

    JString buildToughMultiplicationEquation(JList<JString> rows, JString lastRow) {
        JStringBuilder equation = JStringBuilder();
        for (JString row : rows) {
            if (equation.length() > 0) equation.append(u'\n');
            equation.append(row);
        }
        return equation.append(u'\n').append(lastRow).toString();
    }

    int32_t getToughMultiplicationLastRowOffset(JList<JString> rows) {
        int32_t offset = 0;
        for (int32_t i = 0; i < rows.size() - 1; i++) {
            offset += rows.get(i).length() + 1;
        }
        return offset;
    }

    
    JList<Step*> getStepsForMultiplicationTable(JContext context, int32_t op1, int32_t op2) {
        if (op1 < 0 || op2 < 0) {
            throw JavaArgumentError(JString(u"Step-by-step multiplication requires non-negative operands"));
        }

        JList<Step*> steps = {};
        JString sOp1 = JString::valueOf(op1);
        JString sOp2 = JString::valueOf(op2);
        int64_t finalValue = (int64_t) op1 * (int64_t) op2;
        JString sFinal = JString::valueOf(finalValue);

        
        
        
        int32_t width = JMath::max(sOp1.length() + sOp2.length(), sFinal.length());
        JString padOp1 = getSpaces(width - sOp1.length()) + sOp1;
        JString padOp2 = getSpaces(width - sOp2.length()) + sOp2;
        int32_t op1Start = width - sOp1.length();
        int32_t op2Start = width - sOp2.length();

        JList<JArray<char16_t>> partialRows = {};
        for (int32_t i = 0; i < sOp2.length(); i++) {
            JArray<char16_t> row = JArray<char16_t>(width);
            JArrays::fill(row, u' ');
            partialRows.add(row);
        }

        JArray<char16_t> multiplicationCarries = JArray<char16_t>(width);
        JArrays::fill(multiplicationCarries, u' ');

        
        for (int32_t multiplierIndex = sOp2.length() - 1, rowIndex = 0;
             multiplierIndex >= 0;
             multiplierIndex--, rowIndex++) {

            JArray<char16_t> row = partialRows.get(rowIndex);
            int32_t shift = rowIndex;
            int32_t multiplierDigit = sOp2.charAt(multiplierIndex) - u'0';

            
            for (int32_t z = 0; z < shift; z++) {
                row[width - 1 - z] = u'0';
            }

            JArrays::fill(multiplicationCarries, u' ');
            int32_t carry = 0;

            for (int32_t multiplicandIndex = sOp1.length() - 1; multiplicandIndex >= 0; multiplicandIndex--) {
                int32_t multiplicandDigit = sOp1.charAt(multiplicandIndex) - u'0';
                int32_t value = multiplicandDigit * multiplierDigit + carry;
                int32_t units = value % 10;
                int32_t nextCarry = value / 10;

                int32_t processedFromRight = sOp1.length() - 1 - multiplicandIndex;
                int32_t targetCol = width - 1 - shift - processedFromRight;
                row[targetCol] = u'?';

                JString hint = multiplicandDigit + JString(u" × ") + multiplierDigit
                        + (carry > 0 ? JString(u" + ") + carry : JString(u"")) + JString(u" = ?");
                JString description;
                if (processedFromRight == 0) {
                    if (rowIndex == 0) {
                        description = context.getString(10112);
                    } else {
                        description = context.getString(10111, shift);
                    }
                } else {
                    description = carry > 0
                            ? context.getString(10110)
                            : context.getString(10109);
                }

                JString equation = buildMultiplicationGrid(
                        padOp1, padOp2, multiplicationCarries, partialRows, nullptr, nullptr, false);
                Step* digitStep = makeStep(
                        description,
                        hint,
                        equation,
                        JString::valueOf(units),
                        buildMultiplicationSeparators(width, partialRows.size(), false)
                );
                digitStep->pulseIndex = equation.indexOf(u'?');
                highlightMultiplicationOperands(digitStep, width, op1Start, multiplicandIndex,
                        op2Start, multiplierIndex);
                steps.add(digitStep);
                row[targetCol] = JCharacter::forDigit(units, 10);

                if (nextCarry > 0) {
                    if (multiplicandIndex > 0) {
                        int32_t carryCol = op1Start + multiplicandIndex - 1;
                        multiplicationCarries[carryCol] = u'?';
                        JString carryEquation = buildMultiplicationGrid(
                                padOp1, padOp2, multiplicationCarries, partialRows, nullptr, nullptr, false);
                        Step* carryStep = makeStep(
                                context.getString(10113),
                                context.getString(10025),
                                carryEquation,
                                JString::valueOf(nextCarry),
                                buildMultiplicationSeparators(width, partialRows.size(), false)
                        );
                        carryStep->pulseIndex = carryEquation.indexOf(u'?');
                        highlightMultiplicationOperands(carryStep, width, op1Start, multiplicandIndex,
                                op2Start, multiplierIndex);
                        steps.add(carryStep);
                        multiplicationCarries[carryCol] = JCharacter::forDigit(nextCarry, 10);
                    } else {
                        
                        
                        int32_t carryTargetCol = targetCol - 1;
                        if (carryTargetCol >= 0) {
                            row[carryTargetCol] = u'?';
                            JString carryEquation = buildMultiplicationGrid(
                                    padOp1, padOp2, multiplicationCarries, partialRows, nullptr, nullptr, false);
                            Step* carryStep = makeStep(
                                    context.getString(10115),
                                    context.getString(10025),
                                    carryEquation,
                                    JString::valueOf(nextCarry),
                                    buildMultiplicationSeparators(width, partialRows.size(), false)
                            );
                            carryStep->pulseIndex = carryEquation.indexOf(u'?');
                            steps.add(carryStep);
                            row[carryTargetCol] = JCharacter::forDigit(nextCarry, 10);
                        }
                    }
                }

                carry = nextCarry;
            }
        }

        
        if (sOp2.length() == 1) {
            JArrays::fill(multiplicationCarries, u' ');
            trimLeadingZeros(partialRows.get(0));
            JString finalGrid = buildMultiplicationGrid(
                    padOp1, padOp2, multiplicationCarries, partialRows, nullptr, nullptr, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalValue),
                    nullptr,
                    finalGrid,
                    JString(u""),
                    buildMultiplicationSeparators(width, partialRows.size(), false)
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
            return steps;
        }

        
        
        JArray<char16_t> sumCarries = JArray<char16_t>(width);
        JArray<char16_t> resultDigits = JArray<char16_t>(width);
        JArrays::fill(sumCarries, u' ');
        JArrays::fill(resultDigits, u' ');
        JArrays::fill(multiplicationCarries, u' ');

        int32_t answerStart = width - sFinal.length();
        int32_t carry = 0;
        for (int32_t col = width - 1; col >= answerStart; col--) {
            int32_t columnTotal = carry;
            JList<int32_t> visibleDigits = {};
            for (JArray<char16_t> partial : partialRows) {
                char16_t c = partial[col];
                if (JCharacter::isDigit(c)) {
                    int32_t digit = c - u'0';
                    columnTotal += digit;
                    visibleDigits.add(digit);
                }
            }

            int32_t units = columnTotal % 10;
            int32_t nextCarry = columnTotal / 10;
            resultDigits[col] = u'?';

            JString hint = buildColumnSumHint(visibleDigits, carry);
            JString equation = buildMultiplicationGrid(
                    padOp1, padOp2, multiplicationCarries, partialRows, sumCarries, resultDigits, true);
            Step* sumStep = makeStep(
                    carry > 0
                            ? context.getString(10107)
                            : context.getString(10108),
                    hint,
                    equation,
                    JString::valueOf(units),
                    buildMultiplicationSeparators(width, partialRows.size(), true)
            );
            sumStep->pulseIndex = equation.indexOf(u'?');
            steps.add(sumStep);
            resultDigits[col] = JCharacter::forDigit(units, 10);

            if (nextCarry > 0 && col > answerStart) {
                sumCarries[col - 1] = u'?';
                JString carryEquation = buildMultiplicationGrid(
                        padOp1, padOp2, multiplicationCarries, partialRows, sumCarries, resultDigits, true);
                Step* carryStep = makeStep(
                        context.getString(10114),
                        context.getString(10025),
                        carryEquation,
                        JString::valueOf(nextCarry),
                        buildMultiplicationSeparators(width, partialRows.size(), true)
                );
                carryStep->pulseIndex = carryEquation.indexOf(u'?');
                steps.add(carryStep);
                sumCarries[col - 1] = JCharacter::forDigit(nextCarry, 10);
            }
            carry = nextCarry;
        }

        JString finalGrid = buildMultiplicationGrid(
                padOp1, padOp2, multiplicationCarries, partialRows, sumCarries, resultDigits, true);
        Step* finalStep = makeStep(
                context.getString(10073, finalValue),
                nullptr,
                finalGrid,
                JString(u""),
                buildMultiplicationSeparators(width, partialRows.size(), true)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JString buildMultiplicationGrid(JString padOp1, JString padOp2,
                                                  JArray<char16_t> multiplicationCarries, JList<JArray<char16_t>> partialRows,
                                                  JArray<char16_t> sumCarries, JArray<char16_t> resultDigits, bool showSum) {
        JStringBuilder grid = JStringBuilder();
        grid.append(JString(u"  ")).append(JString(multiplicationCarries)).append(u'\n');
        grid.append(JString(u"  ")).append(padOp1).append(u'\n');
        grid.append(JString(u"× ")).append(padOp2);

        for (JArray<char16_t> row : partialRows) {
            grid.append(u'\n').append(JString(u"  ")).append(JString(row));
        }

        if (showSum) {
            grid.append(u'\n').append(JString(u"  ")).append(JString(sumCarries));
            grid.append(u'\n').append(JString(u"  ")).append(JString(resultDigits));
        }
        return grid.toString();
    }

    JList<Arrow*> buildMultiplicationSeparators(int32_t width, int32_t partialCount,
                                                             bool showSum) {
        JList<Arrow*> arrows = {};
        int32_t arrowColor = 0xFF888888;
        int32_t lineLength = width + 2;
        int32_t rowLength = lineLength + 1; 

        
        int32_t firstStart = 2 * rowLength;
        arrows.add(makeArrow(firstStart, firstStart + lineLength, arrowColor,
                false, false, false, 0.0f, nullptr, 0, false, false, true, 0, 0));

        if (showSum) {
            
            
            int32_t sumCarryRow = 3 + partialCount;
            int32_t secondStart = sumCarryRow * rowLength;
            arrows.add(makeArrow(secondStart, secondStart + lineLength, arrowColor,
                    false, false, false, 0.0f, nullptr, 0, false, false, true, 0, 0));
        }
        return arrows;
    }

    void highlightMultiplicationOperands(Step* step, int32_t width,
                                                        int32_t op1Start, int32_t op1DigitIndex, int32_t op2Start, int32_t op2DigitIndex) {
        int32_t rowLength = width + 3;
        int32_t topDigit = rowLength + 2 + op1Start + op1DigitIndex;
        int32_t bottomDigit = 2 * rowLength + 2 + op2Start + op2DigitIndex;
        step->highlightedRanges.add(JArray<int32_t> {topDigit, topDigit + 1});
        step->highlightedRanges.add(JArray<int32_t> {bottomDigit, bottomDigit + 1});
    }

    void trimLeadingZeros(JArray<char16_t> row) {
        int32_t lastDigit = -1;
        for (int32_t i = 0; i < row.length; i++) {
            if (JCharacter::isDigit(row[i])) lastDigit = i;
        }
        if (lastDigit < 0) return;
        for (int32_t i = 0; i < lastDigit; i++) {
            if (row[i] == u'0') row[i] = u' ';
            else if (row[i] != u' ') break;
        }
    }

    JString buildColumnSumHint(JList<int32_t> digits, int32_t carry) {
        JStringBuilder hint = JStringBuilder();
        for (int32_t digit : digits) {
            if (hint.length() > 0) hint.append(JString(u" + "));
            hint.append(digit);
        }
        if (carry > 0) {
            if (hint.length() > 0) hint.append(JString(u" + "));
            hint.append(carry);
        }
        if (hint.length() == 0) hint.append(u'0');
        hint.append(JString(u" = ?"));
        return hint.toString();
    }

    
    JList<Step*> getStepsForAddingRounding(JContext context, int32_t op1, int32_t op2) {
        if (op1 < 0 || op2 < 0) {
            return getStepsForSingleOperation(context, op1, op2, JString(u"+"), op1 + op2);
        }

        RoundingPlan* plan1 = chooseNearestFriendlyRound(op1, JInteger::MAX_VALUE);
        RoundingPlan* plan2 = chooseNearestFriendlyRound(op2, JInteger::MAX_VALUE);

        
        bool roundFirst;
        RoundingPlan* plan;
        
        if (plan1 == nullptr && plan2 == nullptr) {
            return getStepsForSingleOperation(context, op1, op2, JString(u"+"), op1 + op2);
        }
        
        bool boring1 = isBoringPlan(plan1);
        bool boring2 = isBoringPlan(plan2);

        if (plan1 != nullptr && plan2 != nullptr) {
            if (boring1 && !boring2) {
                roundFirst = false;
                plan = plan2;
            } else if (!boring1 && boring2) {
                roundFirst = true;
                plan = plan1;
            } else {
                
                if (JMath::abs(plan1->delta) < JMath::abs(plan2->delta)) {
                    roundFirst = true;
                    plan = plan1;
                } else {
                    roundFirst = false;
                    plan = plan2;
                }
            }
        } else if (plan1 != nullptr) {
            roundFirst = true;
            plan = plan1;
        } else {
            roundFirst = false;
            plan = plan2;
        }

        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t opLabelColor = 0xFF1976D2;

        
        float step1_curve = 0.0f;
        float base_curve = 2.0f;
        float step2_arrow_source_curve = base_curve * (roundFirst ? -1.0f : 1.0f);
        float step2_arrow_main_curve = 0.0f;
        float step3_arrow_main_curve = 0.0f;
        float step3_arrow_source_curve = -base_curve * (roundFirst ? -1.0f : 1.0f);

        JString sOp1 = JString::valueOf(op1);
        JString sOp2 = JString::valueOf(op2);
        JString line0 = sOp1 + JString(u" + ") + sOp2;

        int32_t roundedSource = roundFirst ? 0 : sOp1.length() + 3;
        JString sOriginal = JString::valueOf(plan->original);
        JString sRounded = JString::valueOf(plan->rounded);
        int32_t correction = JMath::abs(plan->delta);
        JString sCorrection = JString::valueOf(correction);
        JString roundingSign = plan->delta > 0 ? JString(u"+") : JString(u"−");
        JString roundingSignAscii = plan->delta > 0 ? JString(u"+") : JString(u"-");

        
        JString qRounded = getQuestionMarks(sRounded.length());
        int32_t l1Off = line0.length() + 1;
        JString eq1 = line0 + JString(u"\n") + qRounded;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(
                roundedSource, l1Off, arrowColor,
                false, sOriginal.length() > 1, sRounded.length() > 1,
                step1_curve, roundingSignAscii + sCorrection, hintColor,
                false, false, sOriginal.length(), sRounded.length()));

        JString step1Desc = plan->delta > 0
                ? (context != nullptr ? context.getString(10137) : JString(u"Round the number up"))
                : (context != nullptr ? context.getString(10136) : JString(u"Round the number down"));
        Step* step1 = makeStep(
                step1Desc,
                sOriginal + JString(u" ") + roundingSign + JString(u" ") + sCorrection + JString(u" = ?"),
                eq1,
                sRounded,
                arrows1
        );
        step1->pulseIndex = l1Off;
        steps.add(step1);

        
        int32_t firstForEasySum = roundFirst ? plan->rounded : op1;
        int32_t secondForEasySum = roundFirst ? op2 : plan->rounded;
        int32_t intermediate = firstForEasySum + secondForEasySum;
        JString sIntermediate = JString::valueOf(intermediate);
        JString qIntermediate = getQuestionMarks(sIntermediate.length());
        int32_t l2Off = l1Off + sRounded.length() + 1;
        JString eq2 = line0 + JString(u"\n") + sRounded + JString(u"\n") + qIntermediate;

        int32_t otherSource = roundFirst ? sOp1.length() + 3 : 0;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(
                otherSource, l2Off, arrowColor,
                false, (roundFirst ? sOp2.length() : sOp1.length()) > 1, sIntermediate.length() > 1,
                step2_arrow_source_curve, nullptr, 0,
                false, false, roundFirst ? sOp2.length() : sOp1.length(), sIntermediate.length()));
        arrows2.add(makeArrow(
                l1Off, l2Off, arrowColor,
                false, sRounded.length() > 1, sIntermediate.length() > 1,
                step2_arrow_main_curve, JString(u"+"), opLabelColor,
                false, false, sRounded.length(), sIntermediate.length()));

        Step* step2 = makeStep(
                context != nullptr ? context.getString(10009) : JString(u"Add the numbers"),
                firstForEasySum + JString(u" + ") + secondForEasySum + JString(u" = ?"),
                eq2,
                sIntermediate,
                arrows2
        );
        step2->pulseIndex = l2Off;
        steps.add(step2);

        
        JString compensationSign = plan->delta > 0 ? JString(u"−") : JString(u"+");
        JString compensationSignAscii = plan->delta > 0 ? JString(u"-") : JString(u"+");
        int32_t answer = op1 + op2;
        JString sAnswer = JString::valueOf(answer);
        JString qAnswer = getQuestionMarks(sAnswer.length());
        int32_t l3Off = l2Off + sIntermediate.length() + 1;
        JString eq3 = line0 + JString(u"\n") + sRounded + JString(u"\n") + sIntermediate + JString(u"\n") + qAnswer;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(
                roundedSource, l3Off, arrowColor,
                false, sOriginal.length() > 1, sAnswer.length() > 1,
                step3_arrow_source_curve, nullptr, 0,
                false, false, sOriginal.length(), sAnswer.length()));
        arrows3.add(makeArrow(
                l2Off, l3Off, arrowColor,
                false, sIntermediate.length() > 1, sAnswer.length() > 1,
                step3_arrow_main_curve, compensationSignAscii + sCorrection, hintColor,
                false, false, sIntermediate.length(), sAnswer.length()));

        Step* step3 = makeStep(
                context != nullptr ? context.getString(10030) : JString(u"Perform compensation"),
                sIntermediate + JString(u" ") + compensationSign + JString(u" ") + sCorrection + JString(u" = ?"),
                eq3,
                sAnswer,
                arrows3
        );
        step3->pulseIndex = l3Off;
        steps.add(step3);

        JList<Arrow*> finalArrows = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context != nullptr ? context.getString(10073, answer) : (JString(u"Done ") + answer),
                nullptr,
                line0 + JString(u"\n") + sRounded + JString(u"\n") + sIntermediate + JString(u"\n") + sAnswer,
                JString(u""),
                finalArrows
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    
    JList<Step*> getStepsForSubtractingRounding(JContext context, int32_t op1, int32_t op2) {
        if (op1 < 0 || op2 < 0 || op2 > op1) {
            return getStepsForSingleOperation(context, op1, op2, JString(u"−"), op1 - op2);
        }

        RoundingPlan* plan2 = chooseNearestFriendlyRound(op2, op1);
        RoundingPlan* plan1 = chooseNearestFriendlyRound(op1, JInteger::MAX_VALUE);

        bool roundFirst;
        RoundingPlan* plan;

        if (plan2 != nullptr && JMath::abs(plan2->delta) <= 50) {
            roundFirst = false;
            plan = plan2;
        } else if (plan1 != nullptr && JMath::abs(plan1->delta) <= 50) {
            roundFirst = true;
            plan = plan1;
        } else {
            return getStepsForSingleOperation(context, op1, op2, JString(u"−"), op1 - op2);
        }

        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t opLabelColor = 0xFF1976D2;

        
        float step1_curve = 0.0f;
        float base_curve = 2.0f;
        float step2_arrow_source_curve = base_curve * (roundFirst ? -1.0f : 1.0f);
        float step2_arrow_main_curve = 0.0f;
        float step3_arrow_main_curve = 0.0f;
        float step3_arrow_source_curve = -base_curve * (roundFirst ? -1.0f : 1.0f);

        JString sOp1 = JString::valueOf(op1);
        JString sOp2 = JString::valueOf(op2);
        JString line0 = sOp1 + JString(u" − ") + sOp2;
        int32_t subtrahendSource = sOp1.length() + 3;
        int32_t roundedSource = roundFirst ? 0 : subtrahendSource;

        JString sOriginal = JString::valueOf(plan->original);
        JString sRounded = JString::valueOf(plan->rounded);
        int32_t correction = JMath::abs(plan->delta);
        JString sCorrection = JString::valueOf(correction);
        JString roundingSign = plan->delta > 0 ? JString(u"+") : JString(u"−");
        JString roundingSignAscii = plan->delta > 0 ? JString(u"+") : JString(u"-");

        
        JString qRounded = getQuestionMarks(sRounded.length());
        int32_t l1Off = line0.length() + 1;
        JString eq1 = line0 + JString(u"\n") + qRounded;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(
                roundedSource, l1Off, arrowColor,
                false, sOriginal.length() > 1, sRounded.length() > 1,
                step1_curve, roundingSignAscii + sCorrection, hintColor,
                false, false, sOriginal.length(), sRounded.length()));

        JString step1Desc = plan->delta > 0
                ? (context != nullptr ? context.getString(10137) : JString(u"Round the number up"))
                : (context != nullptr ? context.getString(10136) : JString(u"Round the number down"));
        Step* step1 = makeStep(
                step1Desc,
                sOriginal + JString(u" ") + roundingSign + JString(u" ") + sCorrection + JString(u" = ?"),
                eq1,
                sRounded,
                arrows1
        );
        step1->pulseIndex = l1Off;
        steps.add(step1);

        
        int32_t firstForEasySum = roundFirst ? plan->rounded : op1;
        int32_t secondForEasySum = roundFirst ? op2 : plan->rounded;
        int32_t intermediate = firstForEasySum - secondForEasySum;
        JString sIntermediate = JString::valueOf(intermediate);
        JString qIntermediate = getQuestionMarks(sIntermediate.length());
        int32_t l2Off = l1Off + sRounded.length() + 1;
        JString eq2 = line0 + JString(u"\n") + sRounded + JString(u"\n") + qIntermediate;

        int32_t otherSource = roundFirst ? subtrahendSource : 0;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(
                otherSource, l2Off, arrowColor,
                false, (roundFirst ? sOp2.length() : sOp1.length()) > 1, sIntermediate.length() > 1,
                step2_arrow_source_curve, JString(u"−"), opLabelColor,
                false, false, roundFirst ? sOp2.length() : sOp1.length(), sIntermediate.length()));
        arrows2.add(makeArrow(
                l1Off, l2Off, arrowColor,
                false, sRounded.length() > 1, sIntermediate.length() > 1,
                step2_arrow_main_curve, nullptr, 0,
                false, false, sRounded.length(), sIntermediate.length()));

        Step* step2 = makeStep(
                context != nullptr ? context.getString(10172) : JString(u"Subtract the numbers"),
                firstForEasySum + JString(u" − ") + secondForEasySum + JString(u" = ?"),
                eq2,
                sIntermediate,
                arrows2
        );
        step2->pulseIndex = l2Off;
        steps.add(step2);

        
        
        
        JString compensationSign;
        JString compensationSignAscii;
        if (roundFirst) {
            compensationSign = plan->delta > 0 ? JString(u"−") : JString(u"+");
            compensationSignAscii = plan->delta > 0 ? JString(u"-") : JString(u"+");
        } else {
            compensationSign = plan->delta > 0 ? JString(u"+") : JString(u"−");
            compensationSignAscii = plan->delta > 0 ? JString(u"+") : JString(u"-");
        }

        int32_t answer = op1 - op2;
        JString sAnswer = JString::valueOf(answer);
        JString qAnswer = getQuestionMarks(sAnswer.length());
        int32_t l3Off = l2Off + sIntermediate.length() + 1;
        JString eq3 = line0 + JString(u"\n") + sRounded + JString(u"\n") + sIntermediate + JString(u"\n") + qAnswer;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(
                roundedSource, l3Off, arrowColor,
                false, sOriginal.length() > 1, sAnswer.length() > 1,
                step3_arrow_source_curve, nullptr, 0,
                false, false, sOriginal.length(), sAnswer.length()));
        arrows3.add(makeArrow(
                l2Off, l3Off, arrowColor,
                false, sIntermediate.length() > 1, sAnswer.length() > 1,
                step3_arrow_main_curve, compensationSignAscii + sCorrection, hintColor,
                false, false, sIntermediate.length(), sAnswer.length()));

        Step* step3 = makeStep(
                context != nullptr ? context.getString(10030) : JString(u"Perform compensation"),
                sIntermediate + JString(u" ") + compensationSign + JString(u" ") + sCorrection + JString(u" = ?"),
                eq3,
                sAnswer,
                arrows3
        );
        step3->pulseIndex = l3Off;
        steps.add(step3);

        JList<Arrow*> finalArrows = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context != nullptr ? context.getString(10073, answer) : (JString(u"Done ") + answer),
                nullptr,
                line0 + JString(u"\n") + sRounded + JString(u"\n") + sIntermediate + JString(u"\n") + sAnswer,
                JString(u""),
                finalArrows
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    
    JList<Step*> getStepsForSubtractingFrom1000(JContext context, int32_t base, int32_t op1) {
        int32_t digitCount = JString::valueOf(base).length() - 1;
        if (op1 <= 0 || op1 >= base) {
            return getStepsForSingleOperation(context, base, op1, JString(u"−"), base - op1);
        }

        JList<Step*> steps = {};

        
        
        
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        
        
        float curve3_arrow1 = 1.3f;   
        float curve3_arrow2 = 0.0f;     
        float curve3_arrow3 = -1.3f;  

        
        float curve4_arrow1 = 1.6f;   
        float curve4_arrow2 = 0.5f;     
        float curve4_arrow3 = -0.5f;     
        float curve4_arrow4 = -1.6f;  

        
        float curve2_arrow1 = 0.6f;   
        float curve2_arrow2 = -0.6f;  

        JString digits = JString::format( JString(u"%0") + digitCount + JString(u"d"), op1);
        int32_t answer = base - op1;
        JString sAnswer = JString::valueOf(answer);
        JString prefix = base + JString(u" − ");
        JString line0 = prefix + digits;
        int32_t numberStart = prefix.length();

        int32_t rightmostNonZero = -1;
        for (int32_t i = digits.length() - 1; i >= 0; i--) {
            if (digits.charAt(i) != u'0') {
                rightmostNonZero = i;
                break;
            }
        }

        JString qRow = getQuestionMarks(sAnswer.length());
        JStringBuilder currentAnswer = JStringBuilder(qRow);
        JList<Arrow*> previousArrows = {};
        int32_t offsetInDigits = digitCount - sAnswer.length();

        for (int32_t i = 0; i < sAnswer.length(); i++) {
            int32_t digitIdx = offsetInDigits + i;
            int32_t sourceDigit = digits.charAt(digitIdx) - u'0';
            int32_t resultDigit = sAnswer.charAt(i) - u'0';

            JString description;
            JString hint;
            JString arrowLabel;

            if (digitIdx < rightmostNonZero) {
                description = context != nullptr ? context.getString(10171) : JString(u"Subtract the current digit from 9");
                hint = JString(u"9 − ") + sourceDigit + JString(u" = ?");
                arrowLabel = JString(u"9-") + sourceDigit;
            } else if (digitIdx == rightmostNonZero) {
                description = context != nullptr ? context.getString(10170) : JString(u"Subtract the last digit from 10");
                hint = JString(u"10 − ") + sourceDigit + JString(u" = ?");
                arrowLabel = JString(u"10-") + sourceDigit;
            } else {
                description = context != nullptr ? context.getString(10185) : JString(u"Zero is carried to the answer");
                hint = JString(u"0 = ?");
                arrowLabel = JString(u"0");
            }

            JString equation = line0 + JString(u"\n") + currentAnswer.toString();
            int32_t target = line0.length() + 1 + i;

            JList<Arrow*> arrows = cloneAndDim(previousArrows);
            float curve;
            if (sAnswer.length() == 4) {
                if (i == 0) curve = curve4_arrow1;
                else if (i == 1) curve = curve4_arrow2;
                else if (i == 2) curve = curve4_arrow3;
                else curve = curve4_arrow4;
            } else if (sAnswer.length() == 3) {
                if (i == 0) curve = curve3_arrow1;
                else if (i == 1) curve = curve3_arrow2;
                else curve = curve3_arrow3;
            } else if (sAnswer.length() == 2) {
                if (i == 0) curve = curve2_arrow1;
                else curve = curve2_arrow2;
            } else {
                curve = 0.0f;
            }
            arrows.add(makeArrow(
                    numberStart + digitIdx, target, arrowColor,
                    false, false, false,
                    curve, arrowLabel, hintColor,
                    false, false, 1, 1));

            Step* step = makeStep(description, hint, equation, JString::valueOf(resultDigit), arrows);
            step->pulseIndex = target;
            steps.add(step);

            currentAnswer.setCharAt(i, JCharacter::forDigit(resultDigit, 10));
            previousArrows = arrows;
        }

        Step* finalStep = makeStep(
                context != nullptr ? context.getString(10073, answer) : (JString(u"Done ") + answer),
                nullptr,
                line0 + JString(u"\n") + sAnswer,
                JString(u""),
                cloneArrows(previousArrows, false)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    
    RoundingPlan* chooseNearestFriendlyRound(int32_t value, int32_t maxRounded) {
        if (value < 10) return nullptr;
        return findBestPlan(value, maxRounded, false);
    }

    RoundingPlan* findBestPlan(int32_t value, int32_t maxRounded, bool forceNextLevel) {
        int32_t unit;
        int32_t length = JString::valueOf(value).length();
        if (length == 2) unit = 10;
        else if (length == 3 || length == 4) unit = 100;
        else unit = 1000;

        if (forceNextLevel || value % unit == 0) {
            unit *= 10;
        }

        int64_t lower = (value / (int64_t) unit) * unit;
        int64_t upper = lower + unit;
        int64_t bestTarget = -1;
        int64_t bestDiff = JLong::MAX_VALUE;

        for (int64_t target : JArray<int64_t> {lower, upper}) {
            if (target <= 0 || target > JInteger::MAX_VALUE || target > maxRounded || target == value) continue;
            int64_t diff = JMath::abs(target - value);
            if (diff < bestDiff || (diff == bestDiff && target > lower)) {
                bestDiff = diff;
                bestTarget = target;
            }
        }

        if (bestTarget == -1) {
            
            
            if (!forceNextLevel && unit > 10) return nullptr; 
            return nullptr;
        }

        RoundingPlan* plan = makePlan(value, (int32_t) bestTarget, unit);
        
        
        if (!forceNextLevel && isBoringPlan(plan)) {
            RoundingPlan* nextLevelPlan = findBestPlan(value, maxRounded, true);
            if (nextLevelPlan != nullptr) return nextLevelPlan;
        }

        return plan;
    }

    bool isBoringPlan(RoundingPlan* p) {
        if (p == nullptr) return false;
        int32_t d = JMath::abs(p->delta);
        return d == 10 || d == 100 || d == 1000;
    }

    
    JList<Step*> getStepsForDivision(JContext context, int32_t dividend, int32_t divisor) {
        if (dividend < 0 || divisor <= 0) {
            throw JavaArgumentError(JString(u"Step-by-step division requires dividend >= 0 and divisor > 0"));
        }
        if (dividend % divisor != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division currently requires an integer result"));
        }

        JList<Step*> steps = {};
        JString sDividend = JString::valueOf(dividend);
        JString sDivisor = JString::valueOf(divisor);
        int32_t dividendWidth = sDividend.length();

        
        
        int32_t firstEnd = 0;
        int32_t firstPartial = 0;
        bool found = false;
        for (int32_t i = 0; i < dividendWidth; i++) {
            firstPartial = firstPartial * 10 + (sDividend.charAt(i) - u'0');
            if (firstPartial >= divisor) {
                firstEnd = i;
                found = true;
                break;
            }
        }
        if (!found) {
            firstEnd = dividendWidth - 1;
            firstPartial = dividend;
        }

        JString sQuotient = JString::valueOf(dividend / divisor);
        JArray<char16_t> quotientDigits = JArray<char16_t>(sQuotient.length());
        JArrays::fill(quotientDigits, u' ');
        JList<JString> workRows = {};

        int32_t currentPartial = firstPartial;
        int32_t quotientIndex = 0;

        for (int32_t sourceIndex = firstEnd; sourceIndex < dividendWidth; sourceIndex++, quotientIndex++) {
            int32_t quotientDigit = currentPartial / divisor;

            
            quotientDigits[quotientIndex] = u'?';
            JString quotientEquation = buildDivisionGrid(
                    sDividend, sDivisor, quotientDigits, workRows);
            Step* quotientStep = makeStep(
                    context.getString(quotientIndex == 0
                            ? 10068
                            : 10070, divisor, currentPartial),
                    currentPartial + JString(u" ÷ ") + divisor + JString(u" = ?"),
                    quotientEquation,
                    JString::valueOf(quotientDigit),
                    {}
            );
            quotientStep->pulseIndex = quotientEquation.indexOf(u'?');
            highlightDivisionHeader(quotientStep, sDividend, sDivisor, quotientIndex, quotientDigits.length);
            
            
            int32_t partialRowStart = workRows.isEmpty() ? 0 : quotientEquation.lastIndexOf(u'\n') + 1;
            int32_t partialEnd = partialRowStart + 2 + sourceIndex + 1;
            quotientStep->highlightedRanges.add(JArray<int32_t> {
                    partialEnd - JString::valueOf(currentPartial).length(), partialEnd
            });
            steps.add(quotientStep);
            quotientDigits[quotientIndex] = JCharacter::forDigit(quotientDigit, 10);

            
            
            if (sourceIndex + 1 == dividendWidth) {
                break;
            }

            
            
            int32_t product = quotientDigit * divisor;
            JString sProduct = JString::valueOf(product);
            JString productQuestions = getQuestionMarks(sProduct.length());
            workRows.add(buildDivisionWorkRow(dividendWidth, sourceIndex, productQuestions, true));
            int32_t productRowIndex = workRows.size() - 1;

            JString productEquation = buildDivisionGrid(
                    sDividend, sDivisor, quotientDigits, workRows);
            Step* productStep = makeStep(
                    context.getString(10069, divisor, quotientDigit),
                    divisor + JString(u" × ") + quotientDigit + JString(u" = ?"),
                    productEquation,
                    sProduct,
                    {}
            );
            productStep->pulseIndex = productEquation.indexOf(u'?');
            highlightDivisionHeader(productStep, sDividend, sDivisor, quotientIndex, quotientDigits.length);
            steps.add(productStep);
            workRows.set(productRowIndex,
                    buildDivisionWorkRow(dividendWidth, sourceIndex, sProduct, true));

            
            int32_t subtractionWidth = JMath::max(JString::valueOf(currentPartial).length(), sProduct.length());
            workRows.add(buildDivisionSeparatorRow(dividendWidth, sourceIndex, subtractionWidth));

            int32_t remainder = currentPartial - product;
            JString sRemainder = JString::valueOf(remainder);
            workRows.add(buildDivisionWorkRow(dividendWidth, sourceIndex,
                    getQuestionMarks(sRemainder.length()), false));
            int32_t remainderRowIndex = workRows.size() - 1;

            JString remainderEquation = buildDivisionGrid(
                    sDividend, sDivisor, quotientDigits, workRows);
            Step* remainderStep = makeStep(
                    context.getString(10072, product, currentPartial),
                    currentPartial + JString(u" − ") + product + JString(u" = ?"),
                    remainderEquation,
                    sRemainder,
                    {}
            );
            remainderStep->pulseIndex = remainderEquation.indexOf(u'?');
            remainderStep->highlightedRanges.add(JArray<int32_t> {
                    partialEnd - JString::valueOf(currentPartial).length(), partialEnd
            });
            remainderStep->highlightedRanges.add(JArray<int32_t> {
                    productStep->pulseIndex, productStep->pulseIndex + sProduct.length()
            });
            remainderStep->highlightedRanges.add(JArray<int32_t> {
                    remainderStep->pulseIndex, remainderStep->pulseIndex + sRemainder.length()
            });
            steps.add(remainderStep);
            workRows.set(remainderRowIndex,
                    buildDivisionWorkRow(dividendWidth, sourceIndex, sRemainder, false));

            
            int32_t nextDigit = sDividend.charAt(sourceIndex + 1) - u'0';
            int32_t nextPartial = remainder * 10 + nextDigit;
            JString baseBringDownRow = workRows.get(remainderRowIndex);
            
            if (remainder == 0) {
                baseBringDownRow = setDivisionRowDigit(baseBringDownRow, sourceIndex, u' ');
            }
            JString bringDownRow = setDivisionRowDigit(
                    baseBringDownRow, sourceIndex + 1, u'?');
            workRows.set(remainderRowIndex, bringDownRow);

            JString bringEquation = buildDivisionGrid(
                    sDividend, sDivisor, quotientDigits, workRows);
            JString bringDescription = remainder == 0
                    ? context.getString(10066, nextDigit)
                    : context.getString(10067,
                            nextDigit, remainder);
            Step* bringStep = makeStep(
                    bringDescription,
                    context.getString(10071, nextPartial),
                    bringEquation,
                    JString::valueOf(nextDigit),
                    {}
            );
            bringStep->pulseIndex = bringEquation.indexOf(u'?');
            
            int32_t sourceDigitOffset = 2 + sourceIndex + 1;
            bringStep->highlightedRanges.add(JArray<int32_t> {sourceDigitOffset, sourceDigitOffset + 1});
            bringStep->highlightedRanges.add(JArray<int32_t> {
                    bringStep->pulseIndex - (remainder == 0 ? 0 : sRemainder.length()),
                    bringStep->pulseIndex + 1
            });
            steps.add(bringStep);

            workRows.set(remainderRowIndex,
                    setDivisionRowDigit(workRows.get(remainderRowIndex),
                            sourceIndex + 1, JCharacter::forDigit(nextDigit, 10)));
            currentPartial = nextPartial;
        }

        
        
        JString lastPartial = JString::valueOf(currentPartial);
        workRows.add(buildDivisionWorkRow(dividendWidth, dividendWidth - 1, lastPartial, true));
        workRows.add(buildDivisionSeparatorRow(dividendWidth, dividendWidth - 1, lastPartial.length()));
        workRows.add(buildDivisionWorkRow(dividendWidth, dividendWidth - 1, JString(u"0"), false));

        JString finalGrid = buildDivisionGrid(sDividend, sDivisor, quotientDigits, workRows);
        Step* finalStep = makeStep(
                context.getString(10073, dividend / divisor),
                nullptr,
                finalGrid,
                JString(u""),
                {}
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    
    JString buildDivisionGrid(JString dividend, JString divisor,
                                            JArray<char16_t> quotientDigits, JList<JString> workRows) {
        int32_t leftWidth = dividend.length() + 2;
        int32_t rightWidth = JMath::max(divisor.length(), quotientDigits.length);
        JStringBuilder grid = JStringBuilder();

        grid.append(JString(u"  ")).append(dividend).append(JString(u" | ")).append(divisor).append(u'\n');
        grid.append(getSpaces(leftWidth)).append(JString(u" | ")).append(repeatChar(u'-', rightWidth)).append(u'\n');
        grid.append(getSpaces(leftWidth)).append(JString(u" | ")).append(JString(quotientDigits));

        for (JString row : workRows) {
            grid.append(u'\n').append(row);
        }
        return grid.toString();
    }

    
    JString buildDivisionWorkRow(int32_t dividendWidth, int32_t endColumn,
                                               JString value, bool subtractionRow) {
        JArray<char16_t> cells = JArray<char16_t>(dividendWidth);
        JArrays::fill(cells, u' ');
        int32_t start = endColumn - value.length() + 1;
        if (start < 0) start = 0;
        for (int32_t i = 0; i < value.length() && start + i < cells.length; i++) {
            cells[start + i] = value.charAt(i);
        }
        return (subtractionRow ? JString(u"− ") : JString(u"  ")) + JString(cells);
    }

    
    JString buildDivisionSeparatorRow(int32_t dividendWidth, int32_t endColumn, int32_t length) {
        JArray<char16_t> cells = JArray<char16_t>(dividendWidth);
        JArrays::fill(cells, u' ');
        int32_t start = JMath::max(0, endColumn - length + 1);
        for (int32_t i = start; i <= endColumn && i < cells.length; i++) {
            cells[i] = u'─';
        }
        return JString(u"  ") + JString(cells);
    }

    
    JString setDivisionRowDigit(JString row, int32_t dividendColumn, char16_t digit) {
        JArray<char16_t> chars = row.toCharArray();
        int32_t offset = 2 + dividendColumn;
        if (offset >= 0 && offset < chars.length) chars[offset] = digit;
        return JString(chars);
    }

    JString repeatChar(char16_t c, int32_t count) {
        JStringBuilder sb = JStringBuilder();
        for (int32_t i = 0; i < count; i++) sb.append(c);
        return sb.toString();
    }

    
    void highlightDivisionHeader(Step* step, JString dividend, JString divisor,
                                                int32_t quotientIndex, int32_t quotientLength) {
        int32_t line0Length = 2 + dividend.length() + 3 + divisor.length();
        int32_t leftWidth = dividend.length() + 2;
        int32_t dividerStart = 2 + dividend.length() + 3;
        step->highlightedRanges.add(JArray<int32_t> {dividerStart, dividerStart + divisor.length()});

        int32_t line1Length = leftWidth + 3 + JMath::max(divisor.length(), quotientLength);
        int32_t line2Start = line0Length + 1 + line1Length + 1;
        int32_t quotientStart = line2Start + leftWidth + 3;
        if (quotientIndex >= 0 && quotientIndex < quotientLength) {
            step->highlightedRanges.add(JArray<int32_t> {
                    quotientStart + quotientIndex, quotientStart + quotientIndex + 1
            });
        }
    }

    JList<Step*> getStepsForMultiplyBy02(JContext context, int32_t op1) {
        return getStepsForFractionMultiplication(context, op1, 5, JString(u"0.2"),
                10085);
    }

    JList<Step*> getStepsForMultiplyBy025(JContext context, int32_t op1) {
        return getStepsForFractionMultiplication(context, op1, 4, JString(u"0.25"),
                10084);
    }

    JList<Step*> getStepsForDividingBy02(JContext context, int32_t op1) {
        return getStepsForFractionDivision(context, op1, 5, JString(u"0.2"),
                10048);
    }

    JList<Step*> getStepsForDividingBy025(JContext context, int32_t op1) {
        return getStepsForFractionDivision(context, op1, 4, JString(u"0.25"),
                10047);
    }

    JList<Step*> getStepsForFractionDivision(JContext context, int32_t operand,
                                                            int32_t multiplier, JString divisor,
                                                            int32_t introResId) {
        if (operand < 0) {
            throw JavaArgumentError(JString(u"Fraction division requires a nonnegative number"));
        }

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        bool isBy02 = multiplier == 5;
        JString sOp = JString::valueOf(operand);
        JString firstFactor = isBy02 ? JString(u"10") : JString(u"2");
        JString split = isBy02 ? JString(u"(10 \u00F7 2)") : JString(u"(2 \u00D7 2)");
        JString line0 = sOp + JString(u" \u00F7 ") + divisor;
        JString line1 = sOp + JString(u" \u00D7 ") + split;

        int32_t step1Result = operand * (isBy02 ? 10 : 2);
        int32_t finalResult = operand * multiplier;
        JString sStep1 = JString::valueOf(step1Result);
        JString sFinal = JString::valueOf(finalResult);

        int32_t line1Offset = line0.length() + 1;
        int32_t result1Offset = line1Offset + line1.length() + 1;
        int32_t initialDivisionOffset = line0.indexOf(JString(u"\u00F7"));
        int32_t multiplicationOffset = line1Offset + line1.indexOf(JString(u"\u00D7"));
        int32_t firstFactorOffset = line1Offset + line1.indexOf(firstFactor, sOp.length() + 3);
        int32_t secondFactorOffset = line1Offset + line1.lastIndexOf(JString(u"2"));

        JString question1 = getQuestionMarksForAnswer(sStep1);
        JString equation1 = line0 + JString(u"\n") + line1 + JString(u"\n") + question1;
        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(initialDivisionOffset, multiplicationOffset, arrowColor, true,
                false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(line1Offset, result1Offset, arrowColor, false, sOp.length() > 1,
                sStep1.length() > 1, 0.0f, sOp + (isBy02 ? JString(u"\u00D710") : JString(u"\u00D72")), hintColor,
                false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(firstFactorOffset, result1Offset, arrowColor, false,
                firstFactor.length() > 1, sStep1.length() > 1, 0.0f, nullptr, 0,
                false, false, firstFactor.length(), sStep1.length()));

        JString firstDescription = html(context.getString(introResId, operand) + JString(u"<br>")
                + context.getString(isBy02 ? 10088 : 10091));
        JList<Step*> steps = {};
        steps.add(makeStep(firstDescription, sOp + (isBy02 ? JString(u" \u00D7 10 = ?") : JString(u" \u00D7 2 = ?")),
                equation1, sStep1, arrows1));

        int32_t result2Offset = result1Offset + sStep1.length() + 1;
        JString question2 = getQuestionMarksForAnswer(sFinal);
        JString equation2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"\n") + question2;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(result1Offset, result2Offset, arrowColor, false, sStep1.length() > 1,
                sFinal.length() > 1, 0.0f, sStep1 + (isBy02 ? JString(u"\u00F72") : JString(u"\u00D72")), hintColor,
                false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(secondFactorOffset, result2Offset, arrowColor, false, false,
                sFinal.length() > 1, 0.0f, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(context.getString(isBy02 ? 10058
                        : 10102),
                sStep1 + (isBy02 ? JString(u" \u00F7 2 = ?") : JString(u" \u00D7 2 = ?")), equation2, sFinal, arrows2));

        Step* finalStep = makeStep(context.getString(10073, finalResult), nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"\n") + sFinal,
                JString(u""), cloneArrows(arrows2, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForFractionMultiplication(JContext context, int32_t operand,
                                                                  int32_t divisor, JString multiplier,
                                                                  int32_t introResId) {
        if (operand < 0 || operand % divisor != 0) {
            throw JavaArgumentError(JString(u"Fraction multiplication requires a nonnegative multiple of the divisor"));
        }

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        JString sOp = JString::valueOf(operand);
        JString divisorText = JString::valueOf(divisor);
        JString split = divisor == 4 ? JString(u"(2 \u00D7 2)") : JString(u"(10 \u00F7 2)");
        int32_t splitStart = sOp.length() + 6;
        JString line0Body = sOp + JString(u" \u00D7 ") + multiplier;
        JString line1Body = sOp + JString(u" \u00F7 ") + divisorText;
        JString line0 = line0Body;
        JString line1 = line1Body;
        JString splitLine = getSpaces(splitStart) + split;

        int32_t step1Result = divisor == 4 ? operand / 2 : operand / 10;
        int32_t finalResult = operand / divisor;
        JString sStep1 = JString::valueOf(step1Result);
        JString sFinal = JString::valueOf(finalResult);

        int32_t line1Offset = line0.length() + 1;
        int32_t splitOffset = line1Offset + line1.length() + 1;
        int32_t result1Offset = splitOffset + splitLine.length() + 1;

        int32_t multiplicationOffset = line0.indexOf(JString(u"\u00D7"));
        int32_t divisionOffset = line1Offset + line1.indexOf(JString(u"\u00F7"));
        int32_t divisorValueOffset = line1Offset + line1.lastIndexOf(divisorText);
        int32_t splitOperatorOffset = splitOffset + splitStart + split.indexOf(divisor == 4 ? JString(u"\u00D7") : JString(u"\u00F7"));
        int32_t firstFactorOffset = splitOffset + splitStart + split.indexOf(divisor == 4 ? JString(u"2") : JString(u"10"));
        int32_t secondFactorOffset = splitOffset + splitStart + split.lastIndexOf(JString(u"2"));

        JString question1 = getQuestionMarksForAnswer(sStep1);
        JString equation1 = line0 + JString(u"\n") + line1 + JString(u"\n") + splitLine + JString(u"\n") + question1;
        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(multiplicationOffset, divisionOffset, arrowColor, true, false,
                false, 0.0f, nullptr, 0, false, false, 1, 1));
        if (divisor == 4 || divisor == 5) {
            arrows1.add(makeArrow(divisorValueOffset, splitOperatorOffset, arrowColor, true,
                    false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        } else {
            arrows1.add(makeArrow(line1Offset, splitOperatorOffset, arrowColor, true,
                    sOp.length() > 1, false, 0.0f, nullptr, 0, false, false, sOp.length(), 1));
        }
        arrows1.add(makeArrow(line1Offset, result1Offset, arrowColor, false, sOp.length() > 1,
                sStep1.length() > 1, 0.0f, sOp + (divisor == 4 ? JString(u"\u00F72") : JString(u"\u00F710")), hintColor,
                false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(firstFactorOffset, result1Offset, arrowColor, false, divisor == 5,
                sStep1.length() > 1, 0.0f, nullptr, 0, false, false, divisor == 4 ? 1 : 2, sStep1.length()));

        JString firstDescription = html(context.getString(introResId, operand) + JString(u"<br>")
                + context.getString(divisor == 4 ? 10052 : 10050));
        JList<Step*> steps = {};
        steps.add(makeStep(firstDescription, sOp + (divisor == 4 ? JString(u" \u00F7 2 = ?") : JString(u" \u00F7 10 = ?")),
                equation1, sStep1, arrows1));

        int32_t result2Offset = result1Offset + sStep1.length() + 1;
        JString question2 = getQuestionMarksForAnswer(sFinal);
        JString equation2 = line0 + JString(u"\n") + line1 + JString(u"\n") + splitLine + JString(u"\n") + sStep1 + JString(u"\n") + question2;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(result1Offset, result2Offset, arrowColor, false, sStep1.length() > 1,
                sFinal.length() > 1, 0.0f, sStep1 + (divisor == 4 ? JString(u"\u00F72") : JString(u"\u00D72")), hintColor,
                false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(secondFactorOffset, result2Offset, arrowColor, false, false,
                sFinal.length() > 1, 0.0f, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(context.getString(divisor == 4 ? 10058
                        : 10102),
                sStep1 + (divisor == 4 ? JString(u" \u00F7 2 = ?") : JString(u" \u00D7 2 = ?")), equation2, sFinal, arrows2));

        Step* finalStep = makeStep(context.getString(10073, finalResult), nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + splitLine + JString(u"\n") + sStep1 + JString(u"\n") + sFinal,
                JString(u""), cloneArrows(arrows2, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForMultiplyBy05(JContext context, int32_t op1) {
        return getStepsForBy05(context, op1, true);
    }

    JList<Step*> getStepsForDividingBy05(JContext context, int32_t op1) {
        return getStepsForBy05(context, op1, false);
    }

    JList<Step*> getStepsForBy05(JContext context, int32_t op1, bool isMultiplyBy05) {
        if (op1 < 0 || (isMultiplyBy05 && op1 % 2 != 0)) {
            throw JavaArgumentError(JString(u"Step-by-step halving requires a nonnegative even number"));
        }

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        float divisorArrowCurve = -1.6f;

        JString operand = JString::valueOf(op1);
        JList<int32_t> parts = {};
        int32_t place = 1;
        for (int32_t i = 1; i < operand.length(); i++) place *= 10;
        for (int32_t i = 0; i < operand.length(); i++, place /= 10) {
            int32_t part = (operand.charAt(i) - u'0') * place;
            if (part != 0) parts.add(part);
        }
        if (parts.isEmpty()) parts.add(0);

        int32_t partCount = parts.size();
        JArray<JString> partTexts = JArray<JString>(partCount);
        JArray<JString> halfTexts = JArray<JString>(partCount);
        JArray<int32_t> partColumns = JArray<int32_t>(partCount);
        JArray<int32_t> halfColumns = JArray<int32_t>(partCount);
        int32_t splitStart = 1;
        JStringBuilder split = JStringBuilder(JString(u"("));
        JStringBuilder halfQuestions = JStringBuilder(getSpaces(splitStart + 1));
        JStringBuilder sum = JStringBuilder();
        JList<int32_t> plusIndicesInSplit = {};
        for (int32_t i = 0; i < partCount; i++) {
            if (i > 0) {
                plusIndicesInSplit.add(split.length());
                split.append(JString(u"+"));
                halfQuestions.append(JString(u"+"));
                sum.append(JString(u" + "));
            }
            partTexts[i] = JString::valueOf(parts.get(i));
            halfTexts[i] = JString::valueOf(isMultiplyBy05 ? parts.get(i) / 2 : parts.get(i) * 2);
            partColumns[i] = splitStart + split.length();
            split.append(partTexts[i]);

            
            int32_t spare = partTexts[i].length() - halfTexts[i].length();
            halfQuestions.append(getSpaces(spare / 2));
            halfColumns[i] = halfQuestions.length();
            halfQuestions.append(getQuestionMarks(halfTexts[i].length()));
            halfQuestions.append(getSpaces(spare - spare / 2));
            sum.append(halfTexts[i]);
        }
        split.append(u')');

        int32_t divisorColumn = splitStart + split.length() + JMath::max(4, split.length() / 2);
        int32_t operandColumn = divisorColumn - operand.length() - 3;
        int32_t rowWidth = JMath::max(divisorColumn + 4, splitStart + split.length() + 2);

        JString line0 = getSpaces(operandColumn) + operand + (isMultiplyBy05 ? JString(u" \u00D7 0.5") : JString(u" \u00F7 0.5"))
                + getSpaces(JMath::max(0, rowWidth - operandColumn - operand.length() - 6));
        JString line1 = getSpaces(operandColumn) + operand + (isMultiplyBy05 ? JString(u" \u00F7 2") : JString(u" \u00D7 2"))
                + getSpaces(JMath::max(0, rowWidth - operandColumn - operand.length() - 4));
        JString splitRow = getSpaces(splitStart) + split
                + getSpaces(JMath::max(0, rowWidth - splitStart - split.length()));
        JArray<char16_t> halfRow = (halfQuestions.toString()
                + getSpaces(JMath::max(0, rowWidth - halfQuestions.length()))).toCharArray();

        int32_t line1Offset = line0.length() + 1;
        int32_t splitRowOffset = line1Offset + line1.length() + 1;
        int32_t halfRowOffset = splitRowOffset + splitRow.length() + 1;
        int32_t divisorOffsetInLine1 = line1Offset + divisorColumn;

        JList<Step*> steps = {};
        JList<Arrow*> completedArrows = {};

        int32_t initialSignOffset = line0.indexOf(isMultiplyBy05 ? JString(u"\u00D7") : JString(u"\u00F7"));
        int32_t transformedSignOffset = line1Offset + line1.indexOf(isMultiplyBy05 ? JString(u"\u00F7") : JString(u"\u00D7"));
        completedArrows.add(makeArrow(initialSignOffset, transformedSignOffset,
                arrowColor, true, false, false, 0.0f, nullptr, 0,
                false, false, 1, 1));

        
        int32_t line1OperandOffset = line1Offset + operandColumn;
        int32_t targetOffset;
        int32_t targetTokenLength;
        bool targetGap;
        if (partCount % 2 == 0) {
            
            int32_t centralPlusIndex = (partCount - 1) / 2;
            targetOffset = splitRowOffset + splitStart + plusIndicesInSplit.get(centralPlusIndex);
            targetTokenLength = 1;
            targetGap = false;
        } else {
            
            int32_t centralTermIndex = partCount / 2;
            targetOffset = splitRowOffset + partColumns[centralTermIndex];
            targetTokenLength = partTexts[centralTermIndex].length();
            targetGap = targetTokenLength > 1;
        }

        completedArrows.add(makeArrow(line1OperandOffset, targetOffset,
                arrowColor, true, operand.length() > 1, targetGap, 0.0f, nullptr, 0,
                false, false, operand.length(), targetTokenLength));

        JString baseEquation = line0 + JString(u"\n") + line1 + JString(u"\n") + splitRow;

        for (int32_t i = 0; i < partCount; i++) {
            int32_t partOffset = splitRowOffset + partColumns[i];
            int32_t halfOffset = halfRowOffset + halfColumns[i];
            JList<Arrow*> arrows = cloneAndDim(completedArrows);
            arrows.add(makeArrow(partOffset, halfOffset, arrowColor, false,
                    partTexts[i].length() > 1, halfTexts[i].length() > 1, 0.0f,
                    partTexts[i] + (isMultiplyBy05 ? JString(u"÷2") : JString(u"×2")), hintColor, false, false,
                    partTexts[i].length(), halfTexts[i].length()));
            arrows.add(makeArrow(divisorOffsetInLine1, halfOffset, arrowColor, false,
                    false, halfTexts[i].length() > 1, divisorArrowCurve, nullptr, 0,
                    false, false, 1, halfTexts[i].length()));

            JString desc;
            if (i == 0) {
                JString intro = context.getString(isMultiplyBy05
                        ? 10086
                        : 10049, op1);
                JString action = partCount > 1
                        ? context.getString(isMultiplyBy05
                                ? 10060
                                : 10117, op1, parts.get(i))
                        : context.getString(isMultiplyBy05
                                ? 10059
                                : 10116, parts.get(i));
                desc = html(intro + JString(u"<br>") + action);
            } else {
                desc = context.getString(isMultiplyBy05
                        ? 10059
                        : 10116, parts.get(i));
            }

            Step* step = makeStep(
                    desc,
                    partTexts[i] + (isMultiplyBy05 ? JString(u" ÷ 2 = ?") : JString(u" × 2 = ?")),
                    baseEquation + JString(u"\n") + JString(halfRow),
                    halfTexts[i],
                    arrows
            );
            step->pulseIndex = halfOffset;
            steps.add(step);
            halfTexts[i].getChars(0, halfTexts[i].length(), halfRow, halfColumns[i]);
            completedArrows = arrows;
        }

        JString finishedEquation = baseEquation + JString(u"\n") + JString(halfRow);
        JString answer = JString::valueOf(isMultiplyBy05 ? op1 / 2 : op1 * 2);
        if (partCount > 1) {
            int32_t answerColumn = splitStart + (split.length() - answer.length()) / 2;
            int32_t answerOffset = finishedEquation.length() + 1 + answerColumn;
            JString answerPadding = getSpaces(JMath::max(0, rowWidth - answerColumn - answer.length()));
            JList<Arrow*> sumArrows = cloneAndDim(completedArrows);
            for (int32_t i = 0; i < partCount; i++) {
                sumArrows.add(makeArrow(halfRowOffset + halfColumns[i], answerOffset,
                        arrowColor, false, halfTexts[i].length() > 1, answer.length() > 1,
                        0.0f, i == 0 ? sum.toString() : nullptr, hintColor, false, false,
                        halfTexts[i].length(), answer.length()));
            }
            Step* sumStep = makeStep(
                    context.getString(10009),
                    sum + JString(u" = ?"),
                    finishedEquation + JString(u"\n") + getSpaces(answerColumn)
                            + getQuestionMarks(answer.length()) + answerPadding,
                    answer,
                    sumArrows
            );
            sumStep->pulseIndex = answerOffset;
            steps.add(sumStep);
            finishedEquation += JString(u"\n") + getSpaces(answerColumn) + answer + answerPadding;
            completedArrows = sumArrows;
        }

        Step* finalStep = makeStep(context.getString(10073,
                isMultiplyBy05 ? op1 / 2 : op1 * 2),
                nullptr, finishedEquation, JString(u""), cloneArrows(completedArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy125(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        
        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = -1.0f;

        
        int32_t splitStartOffset = 9;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 125");
        JString split125 = JString(u"(1000 \u00F7 8)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split125;

        double step1Val = (double) operand / 8.0;
        int32_t finalRes = operand * 125;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op125Idx     = line0.lastIndexOf(JString(u"125"));
        int32_t thousandPos  = l1_off + splitStart + split125.indexOf(JString(u"1000"));
        int32_t eightPos     = l1_off + splitStart + split125.indexOf(JString(u"8"));
        int32_t divInLine1   = l1_off + splitStart + split125.indexOf(JString(u"\u00F7"));

        int32_t topDimmedArrowStart  = op125Idx;
        int32_t topDimmedArrowTarget = divInLine1;

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 3, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F78"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(eightPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10057),
                sOp + JString(u" \u00F7 8 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D71000"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(thousandPos, l3_off, arrowColor, false, true, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 4, sFinal.length()));

        steps.add(makeStep(
                context.getString(10101),
                sStep1 + JString(u" \u00D7 1000 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy250(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        
        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = -1.0f;

        
        int32_t splitStartOffset = 9;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 250");
        JString split250 = JString(u"(1000 \u00F7 4)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split250;

        double step1Val = (double) operand / 4.0;
        int32_t finalRes = operand * 250;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op250Idx     = line0.lastIndexOf(JString(u"250"));
        int32_t thousandPos  = l1_off + splitStart + split250.indexOf(JString(u"1000"));
        int32_t fourPos      = l1_off + splitStart + split250.indexOf(JString(u"4"));
        int32_t divInLine1   = l1_off + splitStart + split250.indexOf(JString(u"\u00F7"));

        int32_t topDimmedArrowStart  = op250Idx;
        int32_t topDimmedArrowTarget = divInLine1;

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 3, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F74"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(fourPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10053),
                sOp + JString(u" \u00F7 4 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D71000"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(thousandPos, l3_off, arrowColor, false, true, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 4, sFinal.length()));

        steps.add(makeStep(
                context.getString(10101),
                sStep1 + JString(u" \u00D7 1000 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy500(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        
        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = -1.0f;

        
        int32_t splitStartOffset = 9;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 500");
        JString split500 = JString(u"(1000 \u00F7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split500;

        double step1Val = (double) operand / 2.0;
        int32_t finalRes = operand * 500;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op500Idx     = line0.lastIndexOf(JString(u"500"));
        int32_t thousandPos  = l1_off + splitStart + split500.indexOf(JString(u"1000"));
        int32_t twoPos       = l1_off + splitStart + split500.indexOf(JString(u"2"));
        int32_t divInLine1   = l1_off + splitStart + split500.indexOf(JString(u"\u00F7"));

        int32_t topDimmedArrowStart  = op500Idx;
        int32_t topDimmedArrowTarget = divInLine1;

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 3, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F72"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(twoPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10052),
                sOp + JString(u" \u00F7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D71000"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(thousandPos, l3_off, arrowColor, false, true, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 4, sFinal.length()));

        steps.add(makeStep(
                context.getString(10101),
                sStep1 + JString(u" \u00D7 1000 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy750(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        
        float step1_arrow1_curve = 1.3f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = -1.0f;

        float step3_arrow1_curve = 0.0f;
        float step3_arrow2_curve = -3.5f;

        
        int32_t splitStartOffset = 7;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 750");
        JString split750 = JString(u"(1000\u00F74\u00D73)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split750;

        double step1Val = (double) operand / 4.0;
        double step2Val = step1Val * 3.0;
        int32_t finalRes = operand * 750;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sStep2 = (step2Val == (int64_t) step2Val) ? JString::valueOf((int64_t) step2Val) : JString::valueOf(step2Val);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op750Idx     = line0.lastIndexOf(JString(u"750"));
        int32_t thousandPos  = l1_off + splitStart + split750.indexOf(JString(u"1000"));
        int32_t fourPos      = l1_off + splitStart + split750.indexOf(JString(u"4"));
        int32_t threePos     = l1_off + splitStart + split750.indexOf(JString(u"3"));

        int32_t topDimmedArrowStart  = op750Idx;
        int32_t topDimmedArrowTarget = fourPos;

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 3, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F74"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(fourPos, l2_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10053),
                sOp + JString(u" \u00F7 4 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sStep2);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D73"), hintColor, false, false, sStep1.length(), sStep2.length()));
        arrows2.add(makeArrow(threePos, l3_off, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10103),
                sStep1 + JString(u" \u00D7 3 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line3 = sStep2;
        int32_t l4_off = l3_off + line3.length() + 1;
        JString q3 = getQuestionMarksForAnswer(sFinal);
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l3_off, l4_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep2 + JString(u"\u00D71000"), hintColor, false, false, sStep2.length(), sFinal.length()));
        arrows3.add(makeArrow(thousandPos, l4_off, arrowColor, false, true, (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, 4, sFinal.length()));

        steps.add(makeStep(
                context.getString(10106),
                sStep2 + JString(u" \u00D7 1000 = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    
    JList<Step*> getStepsForMultiplyBy999(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        
        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 1.6f;
        float step2_arrow2_curve = 0.0f;

        float step3_arrow1_curve = 0.0f;
        float step3_arrow2_curve = 0.0f;

        
        int32_t splitStartOffset = 7;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00D7 999");
        JString split999 = JString(u"(1000 - 1)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split999;

        int32_t step1Res = operand * 1000;
        int32_t step2Res = operand * 1;
        int32_t finalRes = operand * 999;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op999Idx     = line0.lastIndexOf(JString(u"999"));
        int32_t thousandPos  = l1_off + splitStart + split999.indexOf(JString(u"1000"));
        int32_t onePos       = l1_off + splitStart + split999.lastIndexOf(JString(u"1"));
        int32_t minusInLine  = l1_off + splitStart + split999.indexOf(JString(u"-"));

        int32_t topDimmedArrowStart  = op999Idx;
        int32_t topDimmedArrowTarget = minusInLine;

        
        JString q1 = getQuestionMarks(sStep1.length());
        JString q2 = getQuestionMarks(sStep2.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1 + JString(u" - ") + q2;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 3, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00D71000"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(thousandPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 4, sStep1.length()));

        steps.add(makeStep(
                context.getString(10090),
                sOp + JString(u" \u00D7 1000 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        
        int32_t q2PosInL2 = l2_off + sStep1.length() + 3;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u" - ") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(0, q2PosInL2, arrowColor, false, (sOp.length() > 1), (sStep2.length() > 1), step2_arrow1_curve, sOp + JString(u"\u00D71"), hintColor, false, false, sOp.length(), sStep2.length()));
        arrows2.add(makeArrow(onePos, q2PosInL2, arrowColor, false, false, (sStep2.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sStep2.length()));

        steps.add(makeStep(
                context.getString(10087),
                sOp + JString(u" \u00D7 1 = ?"),
                eq2,
                sStep2,
                arrows2
        ));

        
        JString line2 = sStep1 + JString(u" - ") + sStep2;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q3 = getQuestionMarks(sFinal.length());
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step3_arrow1_curve, sStep1 + JString(u"-") + sStep2, hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows3.add(makeArrow(l2_off + sStep1.length() + 3, l3_off, arrowColor, false, (sStep2.length() > 1), (sFinal.length() > 1), step3_arrow2_curve, nullptr, 0, false, false, sStep2.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10173),
                sStep1 + JString(u" - ") + sStep2 + JString(u" = ?"),
                eq3,
                sFinal,
                arrows3
        ));

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForDividingBy2(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 2 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step halving requires a nonnegative even number"));
        }

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        float divisorArrowCurve = -1.6f;

        JString operand = JString::valueOf(op1);
        JList<int32_t> parts = {};
        int32_t place = 1;
        for (int32_t i = 1; i < operand.length(); i++) place *= 10;
        for (int32_t i = 0; i < operand.length(); i++, place /= 10) {
            int32_t part = (operand.charAt(i) - u'0') * place;
            if (part != 0) parts.add(part);
        }
        if (parts.isEmpty()) parts.add(0);

        int32_t partCount = parts.size();
        JArray<JString> partTexts = JArray<JString>(partCount);
        JArray<JString> halfTexts = JArray<JString>(partCount);
        JArray<int32_t> partColumns = JArray<int32_t>(partCount);
        JArray<int32_t> halfColumns = JArray<int32_t>(partCount);
        int32_t splitStart = 1;
        JStringBuilder split = JStringBuilder(JString(u"("));
        JStringBuilder halfQuestions = JStringBuilder(getSpaces(splitStart + 1));
        JStringBuilder sum = JStringBuilder();
        JList<int32_t> plusIndicesInSplit = {};
        for (int32_t i = 0; i < partCount; i++) {
            if (i > 0) {
                plusIndicesInSplit.add(split.length());
                split.append(JString(u"+"));
                halfQuestions.append(JString(u"+"));
                sum.append(JString(u" + "));
            }
            partTexts[i] = JString::valueOf(parts.get(i));
            halfTexts[i] = JString::valueOf(parts.get(i) / 2);
            partColumns[i] = splitStart + split.length();
            split.append(partTexts[i]);

            
            int32_t spare = partTexts[i].length() - halfTexts[i].length();
            halfQuestions.append(getSpaces(spare / 2));
            halfColumns[i] = halfQuestions.length();
            halfQuestions.append(getQuestionMarks(halfTexts[i].length()));
            halfQuestions.append(getSpaces(spare - spare / 2));
            sum.append(halfTexts[i]);
        }
        split.append(u')');

        
        
        int32_t divisorColumn = splitStart + split.length() + JMath::max(4, split.length() / 2);
        int32_t operandColumn = divisorColumn - operand.length() - 3;
        int32_t rowWidth = divisorColumn + 2;
        JString header = getSpaces(operandColumn) + operand + JString(u" ÷ 2 ");
        JString splitRow = getSpaces(splitStart) + split
                + getSpaces(JMath::max(0, rowWidth - splitStart - split.length()));
        JArray<char16_t> halfRow = (halfQuestions.toString()
                + getSpaces(JMath::max(0, rowWidth - halfQuestions.length()))).toCharArray();
        int32_t splitRowOffset = header.length() + 1;
        int32_t halfRowOffset = splitRowOffset + splitRow.length() + 1;
        int32_t divisorOffset = header.lastIndexOf(u'2');

        JList<Step*> steps = {};
        JList<Arrow*> completedArrows = {};

        int32_t targetOffset;
        int32_t targetTokenLength;
        bool targetGap;
        if (partCount % 2 == 0) {
            
            int32_t centralPlusIndex = (partCount - 1) / 2;
            targetOffset = splitRowOffset + splitStart + plusIndicesInSplit.get(centralPlusIndex);
            targetTokenLength = 1;
            targetGap = false;
        } else {
            
            int32_t centralTermIndex = partCount / 2;
            targetOffset = splitRowOffset + partColumns[centralTermIndex];
            targetTokenLength = partTexts[centralTermIndex].length();
            targetGap = targetTokenLength > 1;
        }

        completedArrows.add(makeArrow(operandColumn, targetOffset,
                arrowColor, true, operand.length() > 1, targetGap, 0.0f, nullptr, 0,
                false, false, operand.length(), targetTokenLength));

        for (int32_t i = 0; i < partCount; i++) {
            int32_t partOffset = splitRowOffset + partColumns[i];
            int32_t halfOffset = halfRowOffset + halfColumns[i];
            JList<Arrow*> arrows = cloneAndDim(completedArrows);
            
            
            arrows.add(makeArrow(partOffset, halfOffset, arrowColor, false,
                    partTexts[i].length() > 1, halfTexts[i].length() > 1, 0.0f,
                    partTexts[i] + JString(u"÷2"), hintColor, false, false,
                    partTexts[i].length(), halfTexts[i].length()));
            arrows.add(makeArrow(divisorOffset, halfOffset, arrowColor, false,
                    false, halfTexts[i].length() > 1, divisorArrowCurve, nullptr, 0,
                    false, false, 1, halfTexts[i].length()));

            Step* step = makeStep(
                    i == 0 && partCount > 1
                            ? html(context.getString(10060, op1, parts.get(i)))
                            : context.getString(10059, parts.get(i)),
                    partTexts[i] + JString(u" ÷ 2 = ?"),
                    header + JString(u"\n") + splitRow + JString(u"\n") + JString(halfRow),
                    halfTexts[i],
                    arrows
            );
            step->pulseIndex = halfOffset;
            steps.add(step);
            halfTexts[i].getChars(0, halfTexts[i].length(), halfRow, halfColumns[i]);
            completedArrows = arrows;
        }

        JString finishedEquation = header + JString(u"\n") + splitRow + JString(u"\n") + JString(halfRow);
        JString answer = JString::valueOf(op1 / 2);
        if (partCount > 1) {
            int32_t answerColumn = splitStart + (split.length() - answer.length()) / 2;
            int32_t answerOffset = finishedEquation.length() + 1 + answerColumn;
            JString answerPadding = getSpaces(JMath::max(0, rowWidth - answerColumn - answer.length()));
            JList<Arrow*> sumArrows = cloneAndDim(completedArrows);
            for (int32_t i = 0; i < partCount; i++) {
                sumArrows.add(makeArrow(halfRowOffset + halfColumns[i], answerOffset,
                        arrowColor, false, halfTexts[i].length() > 1, answer.length() > 1,
                        0.0f, i == 0 ? sum.toString() : nullptr, hintColor, false, false,
                        halfTexts[i].length(), answer.length()));
            }
            Step* sumStep = makeStep(
                    context.getString(10009),
                    sum + JString(u" = ?"),
                    finishedEquation + JString(u"\n") + getSpaces(answerColumn)
                            + getQuestionMarks(answer.length()) + answerPadding,
                    answer,
                    sumArrows
            );
            sumStep->pulseIndex = answerOffset;
            steps.add(sumStep);
            finishedEquation += JString(u"\n") + getSpaces(answerColumn) + answer + answerPadding;
            completedArrows = sumArrows;
        }

        Step* finalStep = makeStep(context.getString(10073, op1 / 2),
                nullptr, finishedEquation, JString(u""), cloneArrows(completedArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForDividingBy6(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 6 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division by 6 requires a nonnegative multiple of 6"));
        }

        int32_t afterDividingBy2 = op1 / 2;
        int32_t afterDividingBy3 = op1 / 3;
        bool divideBy3First = countTrailingZeros(afterDividingBy3) > countTrailingZeros(afterDividingBy2);
        int32_t firstDivisor = divideBy3First ? 3 : 2;
        int32_t secondDivisor = divideBy3First ? 2 : 3;
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;
        int32_t splitStartOffset = 6;

        JString sOp = JString::valueOf(op1);
        JString firstDivisorText = JString::valueOf(firstDivisor);
        JString secondDivisorText = JString::valueOf(secondDivisor);
        JString line0 = sOp + JString(u" \u00F7 6");
        JString split6 = JString(u"(") + firstDivisorText + JString(u" \u00D7 ") + secondDivisorText + JString(u")");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split6;

        int32_t step1Result = op1 / firstDivisor;
        int32_t finalResult = step1Result / secondDivisor;
        JString sStep1 = JString::valueOf(step1Result);
        JString sFinal = JString::valueOf(finalResult);

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;

        int32_t op6Idx = line0.lastIndexOf(JString(u"6"));
        int32_t mulInLine1 = l1Off + splitStart + split6.indexOf(JString(u"\u00D7"));
        int32_t firstDivisorInLine1 = l1Off + splitStart + split6.indexOf(firstDivisorText);
        int32_t secondDivisorInLine1 = l1Off + splitStart + split6.lastIndexOf(secondDivisorText);

        bool opIsMulti = sOp.length() > 1;
        bool step1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op6Idx, mulInLine1, arrowColor, true,
                false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(0, l2Off, arrowColor, false,
                opIsMulti, step1IsMulti, 0.0f, sOp + JString(u"\u00F7") + firstDivisorText,
                hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(firstDivisorInLine1, l2Off, arrowColor, false,
                false, step1IsMulti, 0.0f, nullptr, 0, false, false,
                firstDivisorText.length(), sStep1.length()));

        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;
        JList<Step*> steps = {};
        steps.add(makeStep(
                html(context.getString(10055, op1)
                        + JString(u"<br>") + context.getString(10054, op1, firstDivisor)),
                sOp + JString(u" \u00F7 ") + firstDivisorText + JString(u" = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3Off = l2Off + line2.length() + 1;
        JString q2 = getQuestionMarks(sFinal.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2Off, l3Off, arrowColor, false,
                step1IsMulti, finalIsMulti, 0.0f, sStep1 + JString(u"\u00F7") + secondDivisorText,
                hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(secondDivisorInLine1, l3Off, arrowColor, false,
                false, finalIsMulti, 0.0f, nullptr, 0, false, false,
                secondDivisorText.length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(10056, secondDivisor),
                sStep1 + JString(u" \u00F7 ") + secondDivisorText + JString(u" = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        Step* finalStep = makeStep(context.getString(10073, finalResult), nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""), cloneArrows(arrows2, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    int32_t countTrailingZeros(int32_t value) {
        if (value == 0) return 1;
        int32_t count = 0;
        while (value % 10 == 0) {
            count++;
            value /= 10;
        }
        return count;
    }

    JList<Step*> getStepsForDividingBy7(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 7 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division by 7 requires a nonnegative multiple of 7"));
        }
        return getStepsForDividingWithSmartParts(context, op1, 7,
                10064, 10063);
    }

    JList<Step*> getStepsForDividingWithSmartParts(JContext context, int32_t op1, int32_t divisor,
                                                                  int32_t partsDescriptionRes, int32_t partDescriptionRes) {
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        float divisorArrowCurve = -1.6f;

        JString operand = JString::valueOf(op1);
        int32_t quotient = op1 / divisor;
        JString quotientText = JString::valueOf(quotient);
        JList<int32_t> parts = {};
        int32_t place = 1;
        for (int32_t i = 1; i < quotientText.length(); i++) place *= 10;
        for (int32_t i = 0; i < quotientText.length(); i++, place /= 10) {
            int32_t quotientPart = (quotientText.charAt(i) - u'0') * place;
            if (quotientPart != 0) parts.add(quotientPart * divisor);
        }
        if (parts.isEmpty()) parts.add(0);

        int32_t partCount = parts.size();
        JArray<JString> partTexts = JArray<JString>(partCount);
        JArray<JString> resultTexts = JArray<JString>(partCount);
        JArray<int32_t> partColumns = JArray<int32_t>(partCount);
        JArray<int32_t> resultColumns = JArray<int32_t>(partCount);
        int32_t splitStart = 1;
        JStringBuilder split = JStringBuilder(JString(u"("));
        JStringBuilder resultQuestions = JStringBuilder(getSpaces(splitStart + 1));
        JStringBuilder sum = JStringBuilder();
        JList<int32_t> plusIndicesInSplit = {};
        for (int32_t i = 0; i < partCount; i++) {
            if (i > 0) {
                plusIndicesInSplit.add(split.length());
                split.append(JString(u"+"));
                resultQuestions.append(JString(u" + "));
                sum.append(JString(u" + "));
            }
            partTexts[i] = JString::valueOf(parts.get(i));
            resultTexts[i] = JString::valueOf(parts.get(i) / divisor);
            partColumns[i] = splitStart + split.length();
            split.append(partTexts[i]);

            resultColumns[i] = resultQuestions.length();
            resultQuestions.append(getQuestionMarks(resultTexts[i].length()));
            sum.append(resultTexts[i]);
        }
        split.append(u')');

        int32_t divisorColumn = splitStart + split.length() + JMath::max(4, split.length() / 2);
        int32_t operandColumn = divisorColumn - operand.length() - JString::valueOf(divisor).length() - 2;
        int32_t rowWidth = divisorColumn + JString::valueOf(divisor).length() + 1;
        JString header = getSpaces(operandColumn) + operand + JString(u" ÷ ") + divisor + JString(u" ");
        JString splitRow = getSpaces(splitStart) + split
                + getSpaces(JMath::max(0, rowWidth - splitStart - split.length()));
        JArray<char16_t> resultRow = (resultQuestions.toString()
                + getSpaces(JMath::max(0, rowWidth - resultQuestions.length()))).toCharArray();
        int32_t splitRowOffset = header.length() + 1;
        int32_t resultRowOffset = splitRowOffset + splitRow.length() + 1;
        int32_t divisorOffset = header.lastIndexOf(JString::valueOf(divisor));

        JList<Step*> steps = {};
        JList<Arrow*> completedArrows = {};

        int32_t targetOffset;
        int32_t targetTokenLength;
        bool targetGap;
        if (partCount % 2 == 0) {
            int32_t centralPlusIndex = (partCount - 1) / 2;
            targetOffset = splitRowOffset + splitStart + plusIndicesInSplit.get(centralPlusIndex);
            targetTokenLength = 1;
            targetGap = false;
        } else {
            int32_t centralTermIndex = partCount / 2;
            targetOffset = splitRowOffset + partColumns[centralTermIndex];
            targetTokenLength = partTexts[centralTermIndex].length();
            targetGap = targetTokenLength > 1;
        }

        completedArrows.add(makeArrow(operandColumn, targetOffset,
                arrowColor, true, operand.length() > 1, targetGap, 0.0f, nullptr, 0,
                false, false, operand.length(), targetTokenLength));

        for (int32_t i = 0; i < partCount; i++) {
            int32_t partOffset = splitRowOffset + partColumns[i];
            int32_t resultOffset = resultRowOffset + resultColumns[i];
            JList<Arrow*> arrows = cloneAndDim(completedArrows);
            arrows.add(makeArrow(partOffset, resultOffset, arrowColor, false,
                    partTexts[i].length() > 1, resultTexts[i].length() > 1, 0.0f,
                    partTexts[i] + JString(u"÷") + divisor, hintColor, false, false,
                    partTexts[i].length(), resultTexts[i].length()));
            arrows.add(makeArrow(divisorOffset, resultOffset, arrowColor, false,
                    JString::valueOf(divisor).length() > 1, resultTexts[i].length() > 1,
                    divisorArrowCurve, nullptr, 0, false, false,
                    JString::valueOf(divisor).length(), resultTexts[i].length()));

            Step* step = makeStep(
                    i == 0 && partCount > 1
                            ? html(context.getString(partsDescriptionRes, op1, parts.get(i)))
                            : context.getString(partDescriptionRes, parts.get(i)),
                    partTexts[i] + JString(u" ÷ ") + divisor + JString(u" = ?"),
                    header + JString(u"\n") + splitRow + JString(u"\n") + JString(resultRow),
                    resultTexts[i],
                    arrows
            );
            step->pulseIndex = resultOffset;
            steps.add(step);
            resultTexts[i].getChars(0, resultTexts[i].length(), resultRow, resultColumns[i]);
            completedArrows = arrows;
        }

        JString finishedEquation = header + JString(u"\n") + splitRow + JString(u"\n") + JString(resultRow);
        JString answer = JString::valueOf(quotient);
        if (partCount > 1) {
            int32_t answerColumn = splitStart + (split.length() - answer.length()) / 2;
            int32_t answerOffset = finishedEquation.length() + 1 + answerColumn;
            JString answerPadding = getSpaces(JMath::max(0, rowWidth - answerColumn - answer.length()));
            JList<Arrow*> sumArrows = cloneAndDim(completedArrows);
            for (int32_t i = 0; i < partCount; i++) {
                sumArrows.add(makeArrow(resultRowOffset + resultColumns[i], answerOffset,
                        arrowColor, false, resultTexts[i].length() > 1, answer.length() > 1,
                        0.0f, i == 0 ? sum.toString() : nullptr, hintColor, false, false,
                        resultTexts[i].length(), answer.length()));
            }
            Step* sumStep = makeStep(
                    context.getString(10009),
                    sum + JString(u" = ?"),
                    finishedEquation + JString(u"\n") + getSpaces(answerColumn)
                            + getQuestionMarks(answer.length()) + answerPadding,
                    answer,
                    sumArrows
            );
            sumStep->pulseIndex = answerOffset;
            steps.add(sumStep);
            finishedEquation += JString(u"\n") + getSpaces(answerColumn) + answer + answerPadding;
            completedArrows = sumArrows;
        }

        Step* finalStep = makeStep(context.getString(10073, quotient),
                nullptr, finishedEquation, JString(u""), cloneArrows(completedArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForDividingBy8(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 8 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division by 8 requires a nonnegative multiple of 8"));
        }
        return getStepsForFactorizedDivision(context, op1, 8, JArray<int32_t> {2, 2, 2},
                JArray<bool> {true, true, true}, JString(u"(2×2×2)"), 1);
    }

    JList<Step*> getStepsForDividingBy9(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 9 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division by 9 requires a nonnegative multiple of 9"));
        }
        return getStepsForFactorizedDivision(context, op1, 9, JArray<int32_t> {3, 3},
                JArray<bool> {true, true}, JString(u"(3 × 3)"), -1);
    }

    JList<Step*> getStepsForDividingBy15(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 15 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division by 15 requires a nonnegative multiple of 15"));
        }
        return getStepsForFactorizedDivision(context, op1, 15, JArray<int32_t> {10, 3, 2},
                JArray<bool> {true, true, false}, JString(u"(10×3÷2)"), -1);
    }

    JList<Step*> getStepsForDividingBy40(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 40 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division by 40 requires a nonnegative multiple of 40"));
        }
        bool divideBy4First = countTrailingZeros(op1 / 4) > countTrailingZeros(op1 / 10);
        int32_t firstDivisor = divideBy4First ? 4 : 10;
        int32_t secondDivisor = divideBy4First ? 10 : 4;
        return getStepsForFactorizedDivision(context, op1, 40, JArray<int32_t> {firstDivisor, secondDivisor},
                JArray<bool> {true, true}, JString(u"(") + firstDivisor + JString(u" × ") + secondDivisor + JString(u")"), -1);
    }

    JList<Step*> getStepsForFactorizedDivision(JContext context, int32_t op1, int32_t divisor,
                                                              JArray<int32_t> factors, JArray<bool> divideFactors,
                                                              JString factorExpression, int32_t topArrowFactorIndex) {
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t splitStartOffset = 6;

        JString sOp = JString::valueOf(op1);
        JString line0 = sOp + JString(u" ÷ ") + divisor;
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + factorExpression;
        int32_t line1Offset = line0.length() + 1;
        int32_t firstResultOffset = line1Offset + line1.length() + 1;
        int32_t headerDivisorOffset = line0.lastIndexOf(JString::valueOf(divisor));

        JArray<int32_t> factorOffsets = JArray<int32_t>(factors.length);
        int32_t searchFrom = 0;
        for (int32_t i = 0; i < factors.length; i++) {
            JString factorText = JString::valueOf(factors[i]);
            int32_t factorIndex = factorExpression.indexOf(factorText, searchFrom);
            factorOffsets[i] = line1Offset + splitStart + factorIndex;
            searchFrom = factorIndex + factorText.length();
        }
        int32_t topArrowTarget = topArrowFactorIndex >= 0
                ? factorOffsets[topArrowFactorIndex]
                : line1Offset + splitStart + factorExpression.indexOf(JString(u"×"));
        int32_t topArrowTargetLength = topArrowFactorIndex >= 0
                ? JString::valueOf(factors[topArrowFactorIndex]).length()
                : 1;

        JArray<JString> values = JArray<JString>(factors.length + 1);
        values[0] = sOp;
        double value = op1;
        for (int32_t i = 0; i < factors.length; i++) {
            value = divideFactors[i] ? value / factors[i] : value * factors[i];
            values[i + 1] = formatStepValue(value);
        }

        JList<Step*> steps = {};
        JList<Arrow*> completedArrows = {};
        completedArrows.add(makeArrow(headerDivisorOffset, topArrowTarget, arrowColor, true,
                JString::valueOf(divisor).length() > 1, false, 0.0f, nullptr, 0, false, false,
                JString::valueOf(divisor).length(), topArrowTargetLength));

        int32_t sourceOffset = 0;
        for (int32_t i = 0; i < factors.length; i++) {
            int32_t resultOffset = i == 0 ? firstResultOffset : sourceOffset + values[i].length() + 1;
            JList<Arrow*> arrows = cloneAndDim(completedArrows);
            JString operation = divideFactors[i] ? JString(u"÷") : JString(u"×");
            JString sourceText = values[i];
            JString resultText = values[i + 1];
            JString factorText = JString::valueOf(factors[i]);
            arrows.add(makeArrow(sourceOffset, resultOffset, arrowColor, false,
                    sourceText.length() > 1, resultText.length() > 1, 0.0f,
                    sourceText + operation + factorText, hintColor, false, false,
                    sourceText.length(), resultText.length()));
            arrows.add(makeArrow(factorOffsets[i], resultOffset, arrowColor, false,
                    factorText.length() > 1, resultText.length() > 1, 0.0f,
                    nullptr, 0, false, false, factorText.length(), resultText.length()));

            JStringBuilder equation = JStringBuilder(line0).append(JString(u"\n")).append(line1);
            for (int32_t previous = 1; previous <= i; previous++) {
                equation.append(JString(u"\n")).append(values[previous]);
            }
            equation.append(JString(u"\n")).append(getQuestionMarksForAnswer(resultText));

            JString description;
            if (i == 0) {
                int32_t actionRes = divideFactors[i] ? 10065 : 10118;
                description = html(context.getString(10074,
                        op1, divisor, factorExpression) + JString(u"<br>")
                        + context.getString(actionRes, sourceText, factors[i]));
            } else {
                int32_t actionRes = divideFactors[i] ? 10065 : 10118;
                description = context.getString(actionRes, sourceText, factors[i]);
            }
            Step* step = makeStep(description, sourceText + JString(u" ") + operation + JString(u" ") + factorText + JString(u" = ?"),
                    equation.toString(), resultText, arrows);
            step->pulseIndex = resultOffset;
            steps.add(step);
            completedArrows = arrows;
            sourceOffset = resultOffset;
        }

        JStringBuilder finalEquation = JStringBuilder(line0).append(JString(u"\n")).append(line1);
        for (int32_t i = 1; i < values.length; i++) finalEquation.append(JString(u"\n")).append(values[i]);
        Step* finalStep = makeStep(context.getString(10073, op1 / divisor), nullptr,
                finalEquation.toString(), JString(u""), cloneArrows(completedArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JString formatStepValue(double value) {
        return value == JMath::rint(value) ? JString::valueOf((int64_t) value) : JString::valueOf(value);
    }

    JList<Step*> getStepsForDividingBy3(JContext context, int32_t op1) {
        if (op1 < 0 || op1 % 3 != 0) {
            throw JavaArgumentError(JString(u"Step-by-step division by 3 requires a nonnegative multiple of 3"));
        }

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        float divisorArrowCurve = -1.6f;

        JString operand = JString::valueOf(op1);
        int32_t quotient = op1 / 3;
        JString quotientText = JString::valueOf(quotient);
        JList<int32_t> parts = {};
        int32_t place = 1;
        for (int32_t i = 1; i < quotientText.length(); i++) place *= 10;
        for (int32_t i = 0; i < quotientText.length(); i++, place /= 10) {
            int32_t quotientPart = (quotientText.charAt(i) - u'0') * place;
            if (quotientPart != 0) parts.add(quotientPart * 3);
        }
        if (parts.isEmpty()) parts.add(0);

        int32_t partCount = parts.size();
        JArray<JString> partTexts = JArray<JString>(partCount);
        JArray<JString> resultTexts = JArray<JString>(partCount);
        JArray<int32_t> partColumns = JArray<int32_t>(partCount);
        JArray<int32_t> resultColumns = JArray<int32_t>(partCount);
        int32_t splitStart = 1;
        JStringBuilder split = JStringBuilder(JString(u"("));
        JStringBuilder resultQuestions = JStringBuilder(getSpaces(splitStart + 1));
        JStringBuilder sum = JStringBuilder();
        JList<int32_t> plusIndicesInSplit = {};
        for (int32_t i = 0; i < partCount; i++) {
            if (i > 0) {
                plusIndicesInSplit.add(split.length());
                split.append(JString(u"+"));
                resultQuestions.append(JString(u" + "));
                sum.append(JString(u" + "));
            }
            partTexts[i] = JString::valueOf(parts.get(i));
            resultTexts[i] = JString::valueOf(parts.get(i) / 3);
            partColumns[i] = splitStart + split.length();
            split.append(partTexts[i]);

            resultColumns[i] = resultQuestions.length();
            resultQuestions.append(getQuestionMarks(resultTexts[i].length()));
            sum.append(resultTexts[i]);
        }
        split.append(u')');

        int32_t divisorColumn = splitStart + split.length() + JMath::max(4, split.length() / 2);
        int32_t operandColumn = divisorColumn - operand.length() - 3;
        int32_t rowWidth = divisorColumn + 2;
        JString header = getSpaces(operandColumn) + operand + JString(u" ÷ 3 ");
        JString splitRow = getSpaces(splitStart) + split
                + getSpaces(JMath::max(0, rowWidth - splitStart - split.length()));
        JArray<char16_t> resultRow = (resultQuestions.toString()
                + getSpaces(JMath::max(0, rowWidth - resultQuestions.length()))).toCharArray();
        int32_t splitRowOffset = header.length() + 1;
        int32_t resultRowOffset = splitRowOffset + splitRow.length() + 1;
        int32_t divisorOffset = header.lastIndexOf(u'3');

        JList<Step*> steps = {};
        JList<Arrow*> completedArrows = {};

        int32_t targetOffset;
        int32_t targetTokenLength;
        bool targetGap;
        if (partCount % 2 == 0) {
            int32_t centralPlusIndex = (partCount - 1) / 2;
            targetOffset = splitRowOffset + splitStart + plusIndicesInSplit.get(centralPlusIndex);
            targetTokenLength = 1;
            targetGap = false;
        } else {
            int32_t centralTermIndex = partCount / 2;
            targetOffset = splitRowOffset + partColumns[centralTermIndex];
            targetTokenLength = partTexts[centralTermIndex].length();
            targetGap = targetTokenLength > 1;
        }

        completedArrows.add(makeArrow(operandColumn, targetOffset,
                arrowColor, true, operand.length() > 1, targetGap, 0.0f, nullptr, 0,
                false, false, operand.length(), targetTokenLength));

        for (int32_t i = 0; i < partCount; i++) {
            int32_t partOffset = splitRowOffset + partColumns[i];
            int32_t resultOffset = resultRowOffset + resultColumns[i];
            JList<Arrow*> arrows = cloneAndDim(completedArrows);
            arrows.add(makeArrow(partOffset, resultOffset, arrowColor, false,
                    partTexts[i].length() > 1, resultTexts[i].length() > 1, 0.0f,
                    partTexts[i] + JString(u"÷3"), hintColor, false, false,
                    partTexts[i].length(), resultTexts[i].length()));
            arrows.add(makeArrow(divisorOffset, resultOffset, arrowColor, false,
                    false, resultTexts[i].length() > 1, divisorArrowCurve, nullptr, 0,
                    false, false, 1, resultTexts[i].length()));

            Step* step = makeStep(
                    i == 0 && partCount > 1
                            ? html(context.getString(10062, op1, parts.get(i)))
                            : context.getString(10061, parts.get(i)),
                    partTexts[i] + JString(u" ÷ 3 = ?"),
                    header + JString(u"\n") + splitRow + JString(u"\n") + JString(resultRow),
                    resultTexts[i],
                    arrows
            );
            step->pulseIndex = resultOffset;
            steps.add(step);
            resultTexts[i].getChars(0, resultTexts[i].length(), resultRow, resultColumns[i]);
            completedArrows = arrows;
        }

        JString finishedEquation = header + JString(u"\n") + splitRow + JString(u"\n") + JString(resultRow);
        JString answer = JString::valueOf(quotient);
        if (partCount > 1) {
            int32_t answerColumn = splitStart + (split.length() - answer.length()) / 2;
            int32_t answerOffset = finishedEquation.length() + 1 + answerColumn;
            JString answerPadding = getSpaces(JMath::max(0, rowWidth - answerColumn - answer.length()));
            JList<Arrow*> sumArrows = cloneAndDim(completedArrows);
            for (int32_t i = 0; i < partCount; i++) {
                sumArrows.add(makeArrow(resultRowOffset + resultColumns[i], answerOffset,
                        arrowColor, false, resultTexts[i].length() > 1, answer.length() > 1,
                        0.0f, i == 0 ? sum.toString() : nullptr, hintColor, false, false,
                        resultTexts[i].length(), answer.length()));
            }
            Step* sumStep = makeStep(
                    context.getString(10009),
                    sum + JString(u" = ?"),
                    finishedEquation + JString(u"\n") + getSpaces(answerColumn)
                            + getQuestionMarks(answer.length()) + answerPadding,
                    answer,
                    sumArrows
            );
            sumStep->pulseIndex = answerOffset;
            steps.add(sumStep);
            finishedEquation += JString(u"\n") + getSpaces(answerColumn) + answer + answerPadding;
            completedArrows = sumArrows;
        }

        Step* finalStep = makeStep(context.getString(10073, quotient),
                nullptr, finishedEquation, JString(u""), cloneArrows(completedArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForDividingBy4(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = 0.0f;

        int32_t splitStartOffset = 6;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00F7 4");
        JString split4 = JString(u"(2 \u00D7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split4;

        int32_t step1Res = operand / 2;
        int32_t finalRes = operand / 4;

        JString sStep1 = JString::valueOf(step1Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op4Idx = line0.lastIndexOf(JString(u"4"));
        int32_t mulInLine1 = l1_off + splitStart + split4.indexOf(JString(u"\u00D7"));
        int32_t firstTwoInLine1 = l1_off + splitStart + split4.indexOf(JString(u"2"));
        int32_t secondTwoInLine1 = l1_off + splitStart + split4.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op4Idx, mulInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00F72"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(firstTwoInLine1, l2_off, arrowColor, false, false, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10052),
                sOp + JString(u" \u00F7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarks(sFinal.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, finalIsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00F72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(secondTwoInLine1, l3_off, arrowColor, false, false, finalIsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" \u00F7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForDividingBy5(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = 0.0f;

        int32_t splitStartOffset = 6;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00F7 5");
        JString split5 = JString(u"(10 \u00F7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split5;

        double step1Val = (double) operand / 10.0;
        int32_t finalRes = operand / 5;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op5Idx = line0.lastIndexOf(JString(u"5"));
        int32_t divInLine1 = l1_off + splitStart + split5.indexOf(JString(u"\u00F7"));
        int32_t tenInLine1 = l1_off + splitStart + split5.indexOf(JString(u"10"));
        int32_t twoInLine1 = l1_off + splitStart + split5.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op5Idx, divInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00F710"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(tenInLine1, l2_off, arrowColor, false, true, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10050),
                sOp + JString(u" \u00F7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, finalIsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00D72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(twoInLine1, l3_off, arrowColor, false, false, finalIsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10102),
                sStep1 + JString(u" \u00D7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForDividingBy20(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = 0.0f;

        int32_t splitStartOffset = 6;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00F7 20");
        JString split20 = JString(u"(10 \u00D7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split20;

        int32_t step1Res = operand / 10;
        int32_t finalRes = operand / 20;

        JString sStep1 = JString::valueOf(step1Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op20Idx    = line0.lastIndexOf(JString(u"20"));
        int32_t tenPos     = l1_off + splitStart + split20.indexOf(JString(u"10"));
        int32_t twoPos     = l1_off + splitStart + split20.lastIndexOf(JString(u"2"));
        int32_t mulInLine1 = l1_off + splitStart + split20.indexOf(JString(u"\u00D7"));

        int32_t topDimmedArrowStart  = op20Idx;
        int32_t topDimmedArrowTarget = mulInLine1;

        JString q1 = getQuestionMarks(sStep1.length());
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F710"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(tenPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10050),
                sOp + JString(u" \u00F7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarks(sFinal.length());
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00F72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(twoPos, l3_off, arrowColor, false, false, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" \u00F7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForDividingBy25(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = -1.0f;

        int32_t splitStartOffset = 8;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00F7 25");
        JString split25 = JString(u"(100 \u00F7 4)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split25;

        double step1Val = (double) operand / 100.0;
        int32_t finalRes = operand / 25;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op25Idx     = line0.lastIndexOf(JString(u"25"));
        int32_t hundredPos  = l1_off + splitStart + split25.indexOf(JString(u"100"));
        int32_t fourPos     = l1_off + splitStart + split25.indexOf(JString(u"4"));
        int32_t divInLine1  = l1_off + splitStart + split25.indexOf(JString(u"\u00F7"));

        int32_t topDimmedArrowStart  = op25Idx;
        int32_t topDimmedArrowTarget = divInLine1;

        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F7100"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(hundredPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 3, sStep1.length()));

        steps.add(makeStep(
                context.getString(10051),
                sOp + JString(u" \u00F7 100 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D74"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(fourPos, l3_off, arrowColor, false, false, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10104),
                sStep1 + JString(u" \u00D7 4 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForDividingBy50(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = 0.0f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = -1.0f;

        int32_t splitStartOffset = 8;

        JString sOp = JString::valueOf(operand);
        JString line0 = sOp + JString(u" \u00F7 50");
        JString split50 = JString(u"(100 \u00F7 2)");
        int32_t splitStart = sOp.length() + splitStartOffset;
        JString line1 = getSpaces(splitStart) + split50;

        double step1Val = (double) operand / 100.0;
        int32_t finalRes = operand / 50;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op50Idx     = line0.lastIndexOf(JString(u"50"));
        int32_t hundredPos  = l1_off + splitStart + split50.indexOf(JString(u"100"));
        int32_t twoPos      = l1_off + splitStart + split50.indexOf(JString(u"2"));
        int32_t divInLine1  = l1_off + splitStart + split50.indexOf(JString(u"\u00F7"));

        int32_t topDimmedArrowStart  = op50Idx;
        int32_t topDimmedArrowTarget = divInLine1;

        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(topDimmedArrowStart, topDimmedArrowTarget, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, 2, 1));
        arrows1.add(makeArrow(0, l2_off, arrowColor, false, (sOp.length() > 1), (sStep1.length() > 1), step1_arrow1_curve, sOp + JString(u"\u00F7100"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(hundredPos, l2_off, arrowColor, false, true, (sStep1.length() > 1), step1_arrow2_curve, nullptr, 0, false, false, 3, sStep1.length()));

        steps.add(makeStep(
                context.getString(10051),
                sOp + JString(u" \u00F7 100 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, (sStep1.length() > 1), (sFinal.length() > 1), step2_arrow1_curve, sStep1 + JString(u"\u00D72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(twoPos, l3_off, arrowColor, false, false, (sFinal.length() > 1), step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10102),
                sStep1 + JString(u" \u00D7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn5(JContext context, int32_t operand) {
        int32_t operand1 = operand;
        int32_t operand2 = operand;
        JList<Step*> steps = {};

        
        
        

        
        int32_t arrowColor = 0xFF888888; 
        int32_t hintColor  = 0xFF66BB00; 

        
        float step0_arrow2_curve = 0.0f;  
        float step0_arrow3_curve = 0.0f;  
        float step0_arrow4_curve = 0.0f;  

        float step1_arrow_curve  = 0.0f;    
        float step2_arrow_curve  = 0.0f;    

        
        int32_t splitStartOffset = -7; 

        
        
        

        int32_t tens = operand1 / 10;
        int32_t u1   = operand1 % 10;
        int32_t u2   = operand2 % 10;

        JString sOp1 = JString::valueOf(operand1);
        JString sOp2 = JString::valueOf(operand2);
        JString sSquare = JString(u"\u00B2") + sOp1 + JString(u"\u00B2"); 
        JString line0 = sSquare;
        JString line1 = sOp1 + JString(u" \u00D7 ") + sOp2; 
        JString splitStr = tens + JString(u" \u00D7 ") + (tens + 1) + JString(u" _ ") + u1 + JString(u" \u00D7 ") + u2; 
        int32_t splitStart = JMath::max(0, line1.length() + splitStartOffset);
        JString line2 = getSpaces(splitStart) + splitStr;

        int32_t step1Res = tens * (tens + 1);
        int32_t step2ResInt = u1 * u2;
        int32_t finalRes = operand1 * operand2;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = step2ResInt < 10 ? (JString(u"0") + step2ResInt) : JString::valueOf(step2ResInt);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;
        int32_t l3_off = l2_off + line2.length() + 1;

        
        int32_t op1NumberPosInL0 = 1;

        
        int32_t mulInLine1  = l1_off + line1.indexOf(JString(u"\u00D7"));
        int32_t op1TensPos  = l1_off + 0;                              
        int32_t op1UnitsPos = l1_off + sOp1.length() - 1;              
        int32_t op2UnitsPos = l1_off + line1.length() - 1;             

        
        int32_t splitStartInFull = l2_off + splitStart;

        
        int32_t expr1TensPos     = splitStartInFull + splitStr.indexOf(JString::valueOf(tens));                   
        int32_t expr1MulPos      = splitStartInFull + splitStr.indexOf(JString(u"\u00D7"));                              
        int32_t expr1NextTensPos = splitStartInFull + splitStr.indexOf(JString::valueOf(tens + 1));             

        
        int32_t secondExprStartInSplit = splitStr.indexOf(JString(u"_")) + 1;
        int32_t u1InSecondExpr = splitStr.indexOf(JString::valueOf(u1), secondExprStartInSplit);
        int32_t expr2U1Pos = splitStartInFull + u1InSecondExpr;                                             
        int32_t expr2MulPos = splitStartInFull + splitStr.indexOf(JString(u"\u00D7"), secondExprStartInSplit);         
        int32_t u2InSecondExpr = splitStr.indexOf(JString::valueOf(u2), u1InSecondExpr + 1);
        if (u2InSecondExpr == -1) u2InSecondExpr = splitStr.lastIndexOf(JString::valueOf(u2));
        int32_t expr2U2Pos = splitStartInFull + u2InSecondExpr;                                             

        
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString q2 = getQuestionMarksForAnswer(sStep2);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q1 + getSpaces(q2.length());

        int32_t tensLen = sOp1.length() - 1;
        int32_t nextTensLen = JString::valueOf(tens + 1).length();

        JList<Arrow*> arrows1 = {};
        
        
        arrows1.add(makeArrow(op1NumberPosInL0, mulInLine1, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, sOp1.length(), 1));
        
        arrows1.add(makeArrow(op1TensPos, expr1TensPos, arrowColor, true, true, true, 0.0f, nullptr, 0, false, false, tensLen, tensLen));
        
        arrows1.add(makeArrow(op1TensPos, expr1NextTensPos, arrowColor, true, true, true, step0_arrow2_curve, tens + JString(u"+1"), hintColor, true, true, tensLen, nextTensLen));
        
        arrows1.add(makeArrow(op1UnitsPos, expr2U1Pos, arrowColor, true, false, false, step0_arrow3_curve, nullptr, 0));
        
        arrows1.add(makeArrow(op2UnitsPos, expr2U2Pos, arrowColor, true, true, false, step0_arrow4_curve, nullptr, 0));

        
        Arrow* step1Arrow = makeArrow(expr1MulPos, l3_off, arrowColor, false, false, (sStep1.length() > 1), step1_arrow_curve, JString(u"\u00D7"), 0xFF1976D2, false, false, 1, sStep1.length());
        arrows1.add(step1Arrow);

        Step* step1 = makeStep(
                context.getString(10165),
                tens + JString(u" \u00D7 (") + tens + JString(u" + 1) = ?"),
                eq1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        int32_t step2ResPosInL3 = l3_off + sStep1.length();

        
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sStep1 + q2;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        Arrow* step2Arrow = makeArrow(expr2MulPos, step2ResPosInL3, arrowColor, false, false, (sStep2.length() > 1), step2_arrow_curve, JString(u"\u00D7"), 0xFF1976D2, false, false, 1, sStep2.length());
        arrows2.add(step2Arrow);

        Step* step2 = makeStep(
                context.getString(10166),
                u1 + JString(u" \u00D7 ") + u2 + JString(u" = ?"),
                eq2,
                sStep2,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn5(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareEndingIn5(context, operand1);
    }


    JList<Step*> getStepsForSquareBetween10And19(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForSquareEndingIn0(context, operand);
        }

        int32_t operand1 = operand;
        int32_t operand2 = operand;
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        int32_t larger = operand;
        int32_t u1 = operand % 10;
        int32_t u2 = operand % 10;
        int32_t rightDigitOfOther = u2;

        JString sOp1 = JString::valueOf(operand1);
        JString sOp2 = JString::valueOf(operand2);
        JString sSquare = JString(u"\u00B2") + sOp1 + JString(u"\u00B2"); 
        JString line0 = sSquare;
        JString line1 = sOp1 + JString(u" \u00D7 ") + sOp2;

        int32_t step1Res = larger + rightDigitOfOther;
        int32_t step2Res = step1Res * 10;
        int32_t step3Res = u1 * u2;
        int32_t finalRes = operand * operand;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        
        int32_t op1NumberPosInL0 = 1;

        
        int32_t mulInLine1 = l1_off + line1.indexOf(JString(u"\u00D7"));
        int32_t largerPos = l1_off + 0;
        int32_t rightDigitOfOtherPos = l1_off + line1.length() - 1;
        int32_t u1Pos = l1_off + sOp1.length() - 1;
        int32_t u2Pos = l1_off + line1.length() - 1;

        JString qStep2 = getQuestionMarksForAnswer(sStep2);
        JString qStep3 = getQuestionMarksForAnswer(sStep3);
        JString fullRow = qStep2 + JString(u" + ") + qStep3;

        
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + fullRow;

        JList<Arrow*> arrows1 = {};
        
        
        arrows1.add(makeArrow(op1NumberPosInL0, mulInLine1, arrowColor, true, true, false, 0.0f, nullptr, 0, false, false, sOp1.length(), 1));
        
        arrows1.add(makeArrow(largerPos, l2_off, arrowColor, false, (larger > 9), true, 0.0f, larger + JString(u"+") + rightDigitOfOther, hintColor, false, false, JString::valueOf(larger).length(), sStep1.length()));
        
        arrows1.add(makeArrow(rightDigitOfOtherPos, l2_off, arrowColor, false, false, true, 0.0f, nullptr, 0, false, false, 1, sStep1.length()));

        Step* step1 = makeStep(
                context.getString(10147),
                larger + JString(u" + ") + rightDigitOfOther + JString(u" = ?"),
                eq1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"? + ") + qStep3;
        int32_t zeroPos = l2_off + sStep1.length();

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        
        arrows2.add(makeArrow(zeroPos, zeroPos, 0, false, false, false, 0.0f, JString(u"0"), hintColor, true, false, 1, 1));

        Step* step2 = makeStep(
                context.getString(10077),
                sStep1 + JString(u" \u00D7 10 = ?"),
                eq2,
                JString(u"0"),
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep2 + JString(u" + ") + qStep3;
        int32_t qStep3Pos = l2_off + sStep2.length() + 3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(u1Pos, qStep3Pos, arrowColor, false, false, (sStep3.length() > 1), 0.0f, u1 + JString(u"\u00D7") + u2, hintColor, false, false, 1, sStep3.length()));
        arrows3.add(makeArrow(u2Pos, qStep3Pos, arrowColor, false, false, (sStep3.length() > 1), 0.0f, nullptr, 0, false, false, 1, sStep3.length()));

        Step* step3 = makeStep(
                context.getString(10078),
                u1 + JString(u" \u00D7 ") + u2 + JString(u" = ?"),
                eq3,
                sStep3,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        
        JString line2_step4 = sStep2 + JString(u" + ") + sStep3;
        int32_t l3_off = l2_off + line2_step4.length() + 1;
        JString q4 = getQuestionMarksForAnswer(sFinal);
        JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2_step4 + JString(u"\n") + q4;

        int32_t step2PosInL2 = l2_off;
        int32_t step3PosInL2 = l2_off + sStep2.length() + 3;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(step2PosInL2, l3_off, arrowColor, false, (sStep2.length() > 1), (finalRes > 9), 0.0f, sStep2 + JString(u"+") + sStep3, hintColor, false, false, sStep2.length(), sFinal.length()));
        arrows4.add(makeArrow(step3PosInL2, l3_off, arrowColor, false, (sStep3.length() > 1), (finalRes > 9), 0.0f, nullptr, 0, false, false, sStep3.length(), sFinal.length()));

        Step* step4 = makeStep(
                context.getString(10012),
                sStep2 + JString(u" + ") + sStep3 + JString(u" = ?"),
                eq4,
                sFinal,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2_step4 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareBetween10And19(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween10And19(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween40And49(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForSquareEndingIn0(context, operand);
        }

        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        JString sOp1 = JString::valueOf(operand);
        JString sSquare = JString(u"\u00B2") + sOp1 + JString(u"\u00B2"); 
        JString line0 = sSquare;

        int32_t diff = 50 - operand;
        JString sDiff = JString::valueOf(diff);
        JString qDiff = getQuestionMarksForAnswer(sDiff);

        int32_t step1Res = diff;
        int32_t step2Res = 25 - diff;
        int32_t step3Res = diff * diff;
        int32_t finalRes = operand * operand;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = step3Res < 10 ? (JString(u"0") + step3Res) : JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        JString line1_step1 = JString(u"25-") + qDiff + JString(u" _ ") + qDiff + JString(u"\u00B2");
        JString line1_filled = JString(u"25-") + sDiff + JString(u" _ ") + sDiff + JString(u"\u00B2");

        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1_filled.length() + 1;

        
        int32_t op1NumberPosInL0 = 1;

        
        int32_t qDiff1PosInLine1 = line1_step1.indexOf(qDiff);
        int32_t qDiff2PosInLine1 = line1_step1.lastIndexOf(qDiff);
        int32_t expr1TargetPos = l1_off + qDiff1PosInLine1;
        int32_t expr2TargetPos = l1_off + qDiff2PosInLine1;

        
        int32_t minusPosInL1 = l1_off + line1_filled.indexOf(JString(u"-"));
        int32_t diff2PowInLine1 = line1_filled.indexOf(JString(u" _ ")) + 3;
        int32_t diff2PowPosInL1 = l1_off + diff2PowInLine1;
        int32_t diff2PowLen = sDiff.length(); 

        
        JString eq1 = line0 + JString(u"\n") + line1_step1;

        JList<Arrow*> arrows1 = {};
        Arrow* arrow1 = makeArrow(op1NumberPosInL0, expr1TargetPos, arrowColor, false, (sOp1.length() > 1), (qDiff.length() > 1), 0.0f, JString(u"50-") + operand, hintColor, true, true, sOp1.length(), qDiff.length());
        arrow1->centerBetweenArrows = true;
        arrows1.add(arrow1);
        Arrow* arrow2 = makeArrow(op1NumberPosInL0, expr2TargetPos, arrowColor, false, (sOp1.length() > 1), (qDiff.length() > 1), 0.0f, nullptr, 0, false, false, sOp1.length(), qDiff.length());
        arrows1.add(arrow2);

        Step* step1 = makeStep(
                context.getString(10149),
                JString(u"50 - ") + operand + JString(u" = ?"),
                eq1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + line1_filled + JString(u"\n????");

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        Arrow* step2Arrow = makeArrow(minusPosInL1, l2_off, arrowColor, false, false, true, 0.0f, JString(u"-"), hintColor, false, false, 1, sStep2.length());
        arrows2.add(step2Arrow);

        Step* step2 = makeStep(
                context.getString(10150),
                JString(u"25 - ") + sStep1 + JString(u" = ?"),
                eq2,
                sStep2,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        int32_t step3ResPosInL2 = l2_off + sStep2.length();

        if (step3Res < 10) {
            
            JString eq3A = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3A = cloneAndDim(arrows2);
            arrows3A.add(makeArrow(diff2PowPosInL1, step3ResPosInL2, arrowColor, false, (sDiff.length() > 1), false, 0.0f, JString(u"0"), hintColor, false, false, diff2PowLen, 1));

            Step* step3A = makeStep(
                    context.getString(10148, diff, step3Res),
                    diff + JString(u" \u00D7 ") + diff + JString(u" = ?"),
                    eq3A,
                    JString(u"0"),
                    arrows3A
            );
            step3A->transparentOffsets.add(0);
            steps.add(step3A);

            
            JString eq3B = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"0?");
            JList<Arrow*> arrows3B = cloneAndDim(arrows3A);
            arrows3B.add(makeArrow(diff2PowPosInL1, step3ResPosInL2 + 1, arrowColor, false, (sDiff.length() > 1), false, 0.0f, JString(u"\u00D7"), hintColor, false, false, diff2PowLen, 1));

            Step* step3B = makeStep(
                    context.getString(10119),
                    diff + JString(u" \u00D7 ") + diff + JString(u" = ?"),
                    eq3B,
                    JString::valueOf(step3Res),
                    arrows3B
            );
            step3B->transparentOffsets.add(0);
            steps.add(step3B);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3B, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        } else {
            
            JString eq3 = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3 = cloneAndDim(arrows2);
            Arrow* step3Arrow = makeArrow(diff2PowPosInL1, step3ResPosInL2, arrowColor, false, (sDiff.length() > 1), true, 0.0f, JString(u"\u00D7"), hintColor, false, false, diff2PowLen, sStep3.length());
            arrows3.add(step3Arrow);

            Step* step3 = makeStep(
                    context.getString(10119),
                    diff + JString(u" \u00D7 ") + diff + JString(u" = ?"),
                    eq3,
                    sStep3,
                    arrows3
            );
            step3->transparentOffsets.add(0);
            steps.add(step3);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        }

        return steps;
    }

    JList<Step*> getStepsForSquareBetween40And49(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween40And49(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween50And59(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForSquareEndingIn0(context, operand);
        }

        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        JString sOp1 = JString::valueOf(operand);
        JString sSquare = JString(u"\u00B2") + sOp1 + JString(u"\u00B2"); 
        JString line0 = sSquare;

        int32_t u = operand % 10;
        JString sU = JString::valueOf(u);
        JString qU = getQuestionMarksForAnswer(sU);

        int32_t step1Res = u;
        int32_t step2Res = 25 + u;
        int32_t step3Res = u * u;
        int32_t finalRes = operand * operand;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = step3Res < 10 ? (JString(u"0") + step3Res) : JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        JString line1_step1 = JString(u"25+") + qU + JString(u" _ ") + qU + JString(u"\u00B2");
        JString line1_filled = JString(u"25+") + sU + JString(u" _ ") + sU + JString(u"\u00B2");

        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1_filled.length() + 1;

        
        
        
        int32_t uPosInL0 = sOp1.length();

        
        int32_t qU1PosInLine1 = line1_step1.indexOf(qU);
        int32_t qU2PosInLine1 = line1_step1.lastIndexOf(qU);
        int32_t expr1TargetPos = l1_off + qU1PosInLine1;
        int32_t expr2TargetPos = l1_off + qU2PosInLine1;

        
        int32_t plusPosInL1 = l1_off + line1_filled.indexOf(JString(u"+"));
        int32_t u2PowInLine1 = line1_filled.indexOf(JString(u" _ ")) + 3;
        int32_t u2PowPosInL1 = l1_off + u2PowInLine1;
        int32_t u2PowLen = sU.length(); 

        
        JString eq1 = line0 + JString(u"\n") + line1_step1;

        JList<Arrow*> arrows1 = {};
        Arrow* arrow1 = makeArrow(uPosInL0, expr1TargetPos, arrowColor, false, false, (qU.length() > 1), 0.0f, sU, hintColor, true, true, 1, qU.length());
        arrow1->centerBetweenArrows = true;
        arrows1.add(arrow1);
        Arrow* arrow2 = makeArrow(uPosInL0, expr2TargetPos, arrowColor, false, false, (qU.length() > 1), 0.0f, nullptr, 0, false, false, 1, qU.length());
        arrows1.add(arrow2);

        Step* step1 = makeStep(
                context.getString(10075),
                sU + JString(u" = ?"),
                eq1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + line1_filled + JString(u"\n????");

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        Arrow* step2Arrow = makeArrow(plusPosInL1, l2_off, arrowColor, false, false, true, 0.0f, JString(u"+"), hintColor, false, false, 1, sStep2.length());
        arrows2.add(step2Arrow);

        Step* step2 = makeStep(
                context.getString(10151),
                JString(u"25 + ") + sStep1 + JString(u" = ?"),
                eq2,
                sStep2,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        int32_t step3ResPosInL2 = l2_off + sStep2.length();

        if (step3Res < 10) {
            
            JString eq3A = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3A = cloneAndDim(arrows2);
            arrows3A.add(makeArrow(u2PowPosInL1, step3ResPosInL2, arrowColor, false, (sU.length() > 1), false, 0.0f, JString(u"0"), hintColor, false, false, u2PowLen, 1));

            Step* step3A = makeStep(
                    context.getString(10148, u, step3Res),
                    u + JString(u" \u00D7 ") + u + JString(u" = ?"),
                    eq3A,
                    JString(u"0"),
                    arrows3A
            );
            step3A->transparentOffsets.add(0);
            steps.add(step3A);

            
            JString eq3B = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"0?");
            JList<Arrow*> arrows3B = cloneAndDim(arrows3A);
            arrows3B.add(makeArrow(u2PowPosInL1, step3ResPosInL2 + 1, arrowColor, false, (sU.length() > 1), false, 0.0f, JString(u"\u00D7"), hintColor, false, false, u2PowLen, 1));

            Step* step3B = makeStep(
                    context.getString(10119),
                    u + JString(u" \u00D7 ") + u + JString(u" = ?"),
                    eq3B,
                    JString::valueOf(step3Res),
                    arrows3B
            );
            step3B->transparentOffsets.add(0);
            steps.add(step3B);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3B, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        } else {
            
            JString eq3 = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3 = cloneAndDim(arrows2);
            Arrow* step3Arrow = makeArrow(u2PowPosInL1, step3ResPosInL2, arrowColor, false, (sU.length() > 1), true, 0.0f, JString(u"\u00D7"), hintColor, false, false, u2PowLen, sStep3.length());
            arrows3.add(step3Arrow);

            Step* step3 = makeStep(
                    context.getString(10119),
                    u + JString(u" \u00D7 ") + u + JString(u" = ?"),
                    eq3,
                    sStep3,
                    arrows3
            );
            step3->transparentOffsets.add(0);
            steps.add(step3);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        }

        return steps;
    }

    JList<Step*> getStepsForSquareBetween50And59(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween50And59(context, operand1);
    }

    JList<Step*> getStepsForSquareEndingIn0(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;

        JString sOp1 = JString::valueOf(operand);
        JString sSquare = JString(u"\u00B2") + sOp1 + JString(u"\u00B2"); 
        JString line0 = sSquare;

        int32_t prefix = operand / 10;
        JString sPrefix = JString::valueOf(prefix);
        int32_t step1Res = prefix * prefix;
        JString sStep1 = JString::valueOf(step1Res);
        int32_t finalRes = operand * operand;
        JString sFinal = JString::valueOf(finalRes);

        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;

        
        
        
        
        int32_t prefixPosInL0 = 1;
        int32_t zeroPosInL0 = sOp1.length();

        
        JString eq1 = line0 + JString(u"\n") + getQuestionMarksForAnswer(sStep1);

        JList<Arrow*> arrows1 = {};
        Arrow* arrow1 = makeArrow(prefixPosInL0, l1_off, arrowColor, false, sPrefix.length() > 1, true, 0.0f, nullptr, 0, false, false, sPrefix.length(), sStep1.length());
        arrows1.add(arrow1);

        Step* step1 = makeStep(
                context.getString(prefix > 9
                        ? 10160
                        : 10159),
                prefix + JString(u"\u00B2 = ?"),
                eq1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + sStep1 + JString(u"??");

        int32_t zeroTargetPosInL1 = l1_off + sStep1.length();

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        Arrow* arrow2 = makeArrow(zeroPosInL0, zeroTargetPosInL1, arrowColor, false, false, true, 0.0f, nullptr, 0, false, false, 1, 2);
        arrows2.add(arrow2);

        Step* step2 = makeStep(
                context.getString(10161),
                JString(u"00 = ?"),
                eq2,
                JString(u"00"),
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        for (Arrow* a : arrowsFinal) {
            a->label = nullptr;
        }
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                line0 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn00(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;

        JString sOp1 = JString::valueOf(operand);
        JString line0 = JString(u"\u00B2") + sOp1 + JString(u"\u00B2");
        int32_t prefix = operand / 100;
        JString sPrefix = JString::valueOf(prefix);
        JString sStep1 = JString::valueOf(prefix * prefix);
        JString sFinal = JString::valueOf(operand * operand);

        int32_t l1Off = line0.length() + 1;
        int32_t prefixPosInL0 = 1;
        int32_t zeroPairPosInL0 = sOp1.length() - 1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(prefixPosInL0, l1Off, arrowColor, false,
                sPrefix.length() > 1, sStep1.length() > 1, 0.0f, nullptr, 0,
                false, false, sPrefix.length(), sStep1.length()));

        Step* step1 = makeStep(
                context.getString(10156),
                prefix + JString(u"\u00B2 = ?"),
                line0 + JString(u"\n") + getQuestionMarksForAnswer(sStep1),
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        int32_t zeroTargetPosInL1 = l1Off + sStep1.length();
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(zeroPairPosInL0, zeroTargetPosInL1, arrowColor, false,
                true, true, 0.0f, nullptr, 0, false, false, 2, 4));

        Step* step2 = makeStep(
                context.getString(10157),
                JString(u"0000 = ?"),
                line0 + JString(u"\n") + sStep1 + JString(u"????"),
                JString(u"0000"),
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        for (Arrow* arrow : arrowsFinal) {
            arrow->label = nullptr;
        }
        Step* finalStep = makeStep(
                context.getString(10073, operand * operand),
                nullptr,
                line0 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareBetween90And99(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForSquareEndingIn0(context, operand);
        }

        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        JString sOp1 = JString::valueOf(operand);
        JString sSquare = JString(u"\u00B2") + sOp1 + JString(u"\u00B2"); 
        JString line0 = sSquare;

        int32_t diff = 100 - operand;
        JString sDiff = JString::valueOf(diff);
        JString qDiff = getQuestionMarksForAnswer(sDiff);

        int32_t step1Res = diff;
        int32_t step2Res = operand - diff;
        int32_t step3Res = diff * diff;
        int32_t finalRes = operand * operand;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = step3Res < 10 ? (JString(u"0") + step3Res) : JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        JString line1_step1 = sOp1 + JString(u"-") + qDiff + JString(u" _ ") + qDiff + JString(u"\u00B2");
        JString line1_filled = sOp1 + JString(u"-") + sDiff + JString(u" _ ") + sDiff + JString(u"\u00B2");

        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1_filled.length() + 1;

        
        int32_t op1NumberPosInL0 = 1;

        
        int32_t qDiff1PosInLine1 = line1_step1.indexOf(qDiff);
        int32_t qDiff2PosInLine1 = line1_step1.lastIndexOf(qDiff);
        int32_t expr1TargetPos = l1_off + qDiff1PosInLine1;
        int32_t expr2TargetPos = l1_off + qDiff2PosInLine1;

        
        int32_t minusPosInL1 = l1_off + line1_filled.indexOf(JString(u"-"));
        int32_t diff2PowInLine1 = line1_filled.indexOf(JString(u" _ ")) + 3;
        int32_t diff2PowPosInL1 = l1_off + diff2PowInLine1;
        int32_t diff2PowLen = sDiff.length(); 

        
        JString eq1 = line0 + JString(u"\n") + line1_step1;

        JList<Arrow*> arrows1 = {};
        Arrow* arrow1 = makeArrow(op1NumberPosInL0, expr1TargetPos, arrowColor, false, (sOp1.length() > 1), (qDiff.length() > 1), 0.0f, JString(u"100-") + operand, hintColor, true, true, sOp1.length(), qDiff.length());
        arrow1->centerBetweenArrows = true;
        arrows1.add(arrow1);
        Arrow* arrow2 = makeArrow(op1NumberPosInL0, expr2TargetPos, arrowColor, false, (sOp1.length() > 1), (qDiff.length() > 1), 0.0f, nullptr, 0, false, false, sOp1.length(), qDiff.length());
        arrows1.add(arrow2);

        Step* step1 = makeStep(
                context.getString(10152),
                JString(u"100 - ") + operand + JString(u" = ?"),
                eq1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + line1_filled + JString(u"\n????");

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        Arrow* step2Arrow = makeArrow(minusPosInL1, l2_off, arrowColor, false, false, true, 0.0f, JString(u"-"), hintColor, false, false, 1, sStep2.length());
        arrows2.add(step2Arrow);

        Step* step2 = makeStep(
                context.getString(10153),
                operand + JString(u" - ") + sStep1 + JString(u" = ?"),
                eq2,
                sStep2,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        int32_t step3ResPosInL2 = l2_off + sStep2.length();

        if (step3Res < 10) {
            
            JString eq3A = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3A = cloneAndDim(arrows2);
            arrows3A.add(makeArrow(diff2PowPosInL1, step3ResPosInL2, arrowColor, false, (sDiff.length() > 1), false, 0.0f, JString(u"0"), hintColor, false, false, diff2PowLen, 1));

            Step* step3A = makeStep(
                    context.getString(10148, diff, step3Res),
                    diff + JString(u" \u00D7 ") + diff + JString(u" = ?"),
                    eq3A,
                    JString(u"0"),
                    arrows3A
            );
            step3A->transparentOffsets.add(0);
            steps.add(step3A);

            
            JString eq3B = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"0?");
            JList<Arrow*> arrows3B = cloneAndDim(arrows3A);
            arrows3B.add(makeArrow(diff2PowPosInL1, step3ResPosInL2 + 1, arrowColor, false, (sDiff.length() > 1), false, 0.0f, JString(u"\u00D7"), hintColor, false, false, diff2PowLen, 1));

            Step* step3B = makeStep(
                    context.getString(10119),
                    diff + JString(u" \u00D7 ") + diff + JString(u" = ?"),
                    eq3B,
                    JString::valueOf(step3Res),
                    arrows3B
            );
            step3B->transparentOffsets.add(0);
            steps.add(step3B);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3B, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        } else {
            
            JString eq3 = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3 = cloneAndDim(arrows2);
            Arrow* step3Arrow = makeArrow(diff2PowPosInL1, step3ResPosInL2, arrowColor, false, (sDiff.length() > 1), true, 0.0f, JString(u"\u00D7"), hintColor, false, false, diff2PowLen, sStep3.length());
            arrows3.add(step3Arrow);

            Step* step3 = makeStep(
                    context.getString(10119),
                    diff + JString(u" \u00D7 ") + diff + JString(u" = ?"),
                    eq3,
                    sStep3,
                    arrows3
            );
            step3->transparentOffsets.add(0);
            steps.add(step3);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        }

        return steps;
    }

    JList<Step*> getStepsForSquareBetween90And99(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween90And99(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween100And109(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForSquareEndingIn0(context, operand);
        }

        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        JString sOp1 = JString::valueOf(operand);
        JString sSquare = JString(u"\u00B2") + sOp1 + JString(u"\u00B2"); 
        JString line0 = sSquare;

        int32_t u = operand % 10;
        JString sU = JString::valueOf(u);
        JString qU = getQuestionMarksForAnswer(sU);

        int32_t step1Res = u;
        int32_t step2Res = operand + u;
        int32_t step3Res = u * u;
        int32_t finalRes = operand * operand;

        JString sStep1 = JString::valueOf(step1Res);
        JString sStep2 = JString::valueOf(step2Res);
        JString sStep3 = step3Res < 10 ? (JString(u"0") + step3Res) : JString::valueOf(step3Res);
        JString sFinal = JString::valueOf(finalRes);

        JString line1_step1 = sOp1 + JString(u"+") + qU + JString(u" _ ") + qU + JString(u"\u00B2");
        JString line1_filled = sOp1 + JString(u"+") + sU + JString(u" _ ") + sU + JString(u"\u00B2");

        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1_filled.length() + 1;

        
        
        
        int32_t uPosInL0 = sOp1.length();

        
        int32_t qU1PosInLine1 = line1_step1.indexOf(qU);
        int32_t qU2PosInLine1 = line1_step1.lastIndexOf(qU);
        int32_t expr1TargetPos = l1_off + qU1PosInLine1;
        int32_t expr2TargetPos = l1_off + qU2PosInLine1;

        
        int32_t plusPosInL1 = l1_off + line1_filled.indexOf(JString(u"+"));
        int32_t u2PowInLine1 = line1_filled.indexOf(JString(u" _ ")) + 3;
        int32_t u2PowPosInL1 = l1_off + u2PowInLine1;
        int32_t u2PowLen = sU.length(); 

        
        JString eq1 = line0 + JString(u"\n") + line1_step1;

        JList<Arrow*> arrows1 = {};
        Arrow* arrow1 = makeArrow(uPosInL0, expr1TargetPos, arrowColor, false, false, (qU.length() > 1), 0.0f, sU, hintColor, true, true, 1, qU.length());
        arrow1->centerBetweenArrows = true;
        arrows1.add(arrow1);
        Arrow* arrow2 = makeArrow(uPosInL0, expr2TargetPos, arrowColor, false, false, (qU.length() > 1), 0.0f, nullptr, 0, false, false, 1, qU.length());
        arrows1.add(arrow2);

        Step* step1 = makeStep(
                context.getString(10075),
                sU + JString(u" = ?"),
                eq1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString qLine2 = getQuestionMarks(sFinal.length());
        JString eq2 = line0 + JString(u"\n") + line1_filled + JString(u"\n") + qLine2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        Arrow* step2Arrow = makeArrow(plusPosInL1, l2_off, arrowColor, false, false, true, 0.0f, JString(u"+"), hintColor, false, false, 1, sStep2.length());
        arrows2.add(step2Arrow);

        Step* step2 = makeStep(
                context.getString(10146),
                operand + JString(u" + ") + sStep1 + JString(u" = ?"),
                eq2,
                sStep2,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        int32_t step3ResPosInL2 = l2_off + sStep2.length();

        if (step3Res < 10) {
            
            JString eq3A = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3A = cloneAndDim(arrows2);
            arrows3A.add(makeArrow(u2PowPosInL1, step3ResPosInL2, arrowColor, false, (sU.length() > 1), false, 0.0f, JString(u"0"), hintColor, false, false, u2PowLen, 1));

            Step* step3A = makeStep(
                    context.getString(10148, u, step3Res),
                    u + JString(u" \u00D7 ") + u + JString(u" = ?"),
                    eq3A,
                    JString(u"0"),
                    arrows3A
            );
            step3A->transparentOffsets.add(0);
            steps.add(step3A);

            
            JString eq3B = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"0?");
            JList<Arrow*> arrows3B = cloneAndDim(arrows3A);
            arrows3B.add(makeArrow(u2PowPosInL1, step3ResPosInL2 + 1, arrowColor, false, (sU.length() > 1), false, 0.0f, JString(u"\u00D7"), hintColor, false, false, u2PowLen, 1));

            Step* step3B = makeStep(
                    context.getString(10119),
                    u + JString(u" \u00D7 ") + u + JString(u" = ?"),
                    eq3B,
                    JString::valueOf(step3Res),
                    arrows3B
            );
            step3B->transparentOffsets.add(0);
            steps.add(step3B);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3B, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        } else {
            
            JString eq3 = line0 + JString(u"\n") + line1_filled + JString(u"\n") + sStep2 + JString(u"??");
            JList<Arrow*> arrows3 = cloneAndDim(arrows2);
            Arrow* step3Arrow = makeArrow(u2PowPosInL1, step3ResPosInL2, arrowColor, false, (sU.length() > 1), true, 0.0f, JString(u"\u00D7"), hintColor, false, false, u2PowLen, sStep3.length());
            arrows3.add(step3Arrow);

            Step* step3 = makeStep(
                    context.getString(10119),
                    u + JString(u" \u00D7 ") + u + JString(u" = ?"),
                    eq3,
                    sStep3,
                    arrows3
            );
            step3->transparentOffsets.add(0);
            steps.add(step3);

            
            JList<Arrow*> arrowsFinal = cloneArrows(arrows3, false);
            Step* finalStep = makeStep(
                    context.getString(10073, finalRes),
                    nullptr,
                    line0 + JString(u"\n") + line1_filled + JString(u"\n") + sFinal,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->transparentOffsets.add(0);
            finalStep->isFinal = true;
            steps.add(finalStep);
        }

        return steps;
    }

    JList<Step*> getStepsForSquareBetween100And109(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween100And109(context, operand1);
    }

    JList<Step*> getStepsForSquareEndingIn25(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t prefix = operand / 100;
        int32_t prefixSquare = prefix * prefix;
        int32_t product = prefixSquare * 10 + prefix * 5;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sSquare = JString::valueOf(prefixSquare);
        JString sHalf = (prefix % 2 == 0) ? JString::valueOf(prefix / 2) : (prefix / 2) + JString(u".5");
        JString sSum = (prefix % 2 == 0) ? JString::valueOf(prefixSquare + prefix / 2) : (prefixSquare + prefix / 2) + JString(u".5");
        JString sProduct = JString::valueOf(product);
        JString sFinalResult = JString::valueOf(finalResult);

        
        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = JString(u"(") + sPrefix + JString(u"\u00B2+") + sPrefix + JString(u"\u00F72)\u00D710 _ 25\u00B2");
        JString line2 = sSquare + JString(u"+") + sHalf;
        JString line3 = sSum;

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;
        int32_t l4Off = l3Off + line3.length() + 1;

        int32_t prefixPosInL0 = 1;
        int32_t prefixLenInL0 = prefix > 0 ? sPrefix.length() : 0;
        int32_t twentyFivePosInL0 = 1 + prefixLenInL0;

        int32_t firstPrefixInL1 = l1Off + 1;
        int32_t firstTermLenInL1 = sPrefix.length() + 1; 
        int32_t secondPrefixInL1 = l1Off + line1.indexOf(sPrefix, line1.indexOf(u'+'));
        int32_t twoInL1 = l1Off + line1.indexOf(JString(u"2"), line1.indexOf(JString(u"\u00F7")));
        int32_t tenInL1 = l1Off + line1.indexOf(JString(u"10"));
        int32_t twentyFiveInL1 = l1Off + line1.indexOf(JString(u"25"), line1.indexOf(u'_'));

        int32_t firstTermInL2 = l2Off;
        int32_t plusInL2 = l2Off + line2.indexOf(u'+');

        int32_t sumInL3 = l3Off;

        JString qSquare = getQuestionMarksForAnswer(sSquare);
        JString qHalf = getQuestionMarksForAnswer(sHalf);
        JString qSum = getQuestionMarksForAnswer(sSum);
        JString qProduct = getQuestionMarksForAnswer(sProduct);
        JString qSuffix = JString(u"???");

        int32_t originalNumberPos = 1;
        int32_t mulInL1 = l1Off + line1.indexOf(JString(u"\u00D7"));

        
        JString line2Step1 = qSquare + JString(u"+") + qHalf;
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2Step1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(originalNumberPos, mulInL1, arrowColor, true,
                true, false, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));

        arrows1.add(makeArrow(firstPrefixInL1, firstTermInL2, arrowColor, false,
                true, qSquare.length() > 1, 0.0f, sPrefix + JString(u"\u00B2"), hintColor,
                false, false, firstTermLenInL1, qSquare.length()));

        Step* step1 = makeStep(
                context.getString(10119),
                sPrefix + JString(u" \u00D7 ") + sPrefix + JString(u" = ?"),
                eq1,
                sSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString line2Step2 = sSquare + JString(u"+") + qHalf;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2Step2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        int32_t secondTermInL2 = l2Off + line2Step2.indexOf(qHalf);
        arrows2.add(makeArrow(secondPrefixInL1, secondTermInL2, arrowColor, false,
                true, qHalf.length() > 1, 0.0f, JString(u"\u00F7"), hintColor,
                false, false, sPrefix.length(), qHalf.length()));
        arrows2.add(makeArrow(twoInL1, secondTermInL2, arrowColor, false,
                true, qHalf.length() > 1, 0.0f, nullptr, 0,
                false, false, 1, qHalf.length()));

        Step* step2 = makeStep(
                context.getString(10121, sPrefix, 2),
                sPrefix + JString(u" \u00F7 2 = ?"),
                eq2,
                sHalf,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        
        JString line3Step3 = qSum;
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3Step3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        int32_t secondTermInL2Filled = l2Off + line2.indexOf(u'+') + 1;
        arrows3.add(makeArrow(firstTermInL2, sumInL3, arrowColor, false,
                true, qSum.length() > 1, 0.0f, JString(u"+"), hintColor,
                false, false, sSquare.length(), qSum.length()));
        arrows3.add(makeArrow(secondTermInL2Filled, sumInL3, arrowColor, false,
                true, qSum.length() > 1, 0.0f, nullptr, 0,
                false, false, sHalf.length(), qSum.length()));

        Step* step3 = makeStep(
                context.getString(10120, sSquare, sHalf),
                sSquare + JString(u" + ") + sHalf + JString(u" = ?"),
                eq3,
                sSum,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        
        JString line4Step4 = qProduct;
        JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4Step4;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(sumInL3, l4Off, arrowColor, false,
                true, qProduct.length() > 1, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, sSum.length(), qProduct.length()));
        arrows4.add(makeArrow(tenInL1, l4Off, arrowColor, false,
                true, qProduct.length() > 1, -3.0f, nullptr, 0,
                false, false, 2, qProduct.length()));

        Step* step4 = makeStep(
                context.getString(10123, sSum, 10),
                sSum + JString(u" \u00D7 10 = ?"),
                eq4,
                sProduct,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        
        JString line4Step5 = sProduct + qSuffix;
        JString eq5 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4Step5;

        JList<Arrow*> arrows5 = cloneAndDim(arrows4);
        arrows5.add(makeArrow(twentyFiveInL1, l4Off + sProduct.length(), arrowColor, false,
                true, true, -2.0f, JString(u"625"), hintColor, true, false,
                2, qSuffix.length()));

        Step* step5 = makeStep(
                context.getString(10164),
                JString(u"625"),
                eq5,
                JString(u"625"),
                arrows5
        );
        step5->transparentOffsets.add(0);
        steps.add(step5);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows5, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn25(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareEndingIn25(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween20And29(JContext context, int32_t operand) {
        return getStepsForSquareBetweenTensAndNines(context, operand, 20);
    }

    JList<Step*> getStepsForPower2(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForSquareEndingIn0(context, operand);
        }
        return getStepsForSquareBetweenTensAndNines(context, operand, operand / 10 * 10, 1);
    }

    JList<Step*> getStepsForPower2(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower2(context, operand1);
    }

    JList<Step*> getStepsForPowerOfTwo(JContext context, int32_t exponent) {
        int32_t minExponent = 1;
        int32_t maxExponent = 30;
        exponent = JMath::max(minExponent, JMath::min(maxExponent, exponent));

        JArray<int32_t> anchors = {5, 10, 15, 20};
        int32_t anchorExponent;
        if (exponent <= 5) {
            anchorExponent = 1;
        } else {
            anchorExponent = anchors[0];
            for (int32_t candidate : anchors) {
                if (JMath::abs(candidate - exponent) < JMath::abs(anchorExponent - exponent)) {
                    anchorExponent = candidate;
                }
            }
            if (exponent == anchorExponent) {
                anchorExponent -= 5;
            }
        }

        int32_t anchorValue = 1 << anchorExponent;
        int32_t finalValue = 1 << exponent;
        bool multiply = exponent > anchorExponent;
        JString operationSymbol = multiply ? JString(u"\u00D7") : JString(u"\u00F7");
        JString operation = operationSymbol + JString(u"2");
        JString operationVerb = multiply
                ? context.getString(10129)
                : context.getString(10128);

        JString sTargetExponent = getSuperscriptNumber(exponent);
        JString sAnchorExponent = getSuperscriptNumber(anchorExponent);
        JString sAnchorValue = JString::valueOf(anchorValue);
        JString line0 = JString(u"2") + sTargetExponent + JString(u" = ?");
        JString anchorLine = JString(u"2") + sAnchorExponent + JString(u" = ") + sAnchorValue;
        JString equationPrefix = line0 + JString(u"\n") + anchorLine;

        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        if (exponent == anchorExponent) {
            JString qFinal = getQuestionMarksForAnswer(sAnchorValue);
            JString targetLine = JString(u"2") + sTargetExponent + JString(u" = ") + qFinal;
            Step* step1 = makeStep(
                    context.getString(10127,
                            JString(u"2") + sAnchorExponent + JString(u" = ") + sAnchorValue),
                    JString(u"2") + sTargetExponent + JString(u" = ?"),
                    line0 + JString(u"\n") + targetLine,
                    sAnchorValue,
                    {}
            );
            steps.add(step1);

            Step* finalStep = makeStep(
                    context.getString(10073, finalValue),
                    nullptr,
                    line0 + JString(u"\n") + anchorLine,
                    JString(u""),
                    {}
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
            return steps;
        }

        JString equation = equationPrefix;
        int32_t currentExponent = anchorExponent;
        int32_t currentValue = anchorValue;
        int32_t currentValueOffset = equationPrefix.length() - sAnchorValue.length();
        JList<Arrow*> previousArrows = {};

        while (currentExponent != exponent) {
            int32_t nextExponent = currentExponent + (multiply ? 1 : -1);
            int32_t nextValue = multiply ? currentValue * 2 : currentValue / 2;
            JString sCurrentValue = JString::valueOf(currentValue);
            JString sNextValue = JString::valueOf(nextValue);
            JString nextPrefix = JString(u"2") + getSuperscriptNumber(nextExponent) + JString(u" = ");
            JString qNextValue = getQuestionMarksForAnswer(sNextValue);
            int32_t nextValueOffset = equation.length() + 1 + nextPrefix.length();
            JString nextEquation = equation + JString(u"\n") + nextPrefix + qNextValue;

            JList<Arrow*> arrows = cloneAndDim(previousArrows);
            arrows.add(makeArrow(currentValueOffset, nextValueOffset, arrowColor, false,
                    sCurrentValue.length() > 1, sNextValue.length() > 1, 0.0f, operation,
                    hintColor, true, false, sCurrentValue.length(), qNextValue.length()));

            bool isFirstStep = currentExponent == anchorExponent;
            JString description = isFirstStep
                    ? context.getString(10126,
                    JString(u"2") + sAnchorExponent + JString(u" = ") + sAnchorValue, operationVerb)
                    : context.getString(10130, operationVerb);
            Step* step = makeStep(
                    description,
                    sCurrentValue + JString(u" ") + operationSymbol + JString(u" 2 = ?"),
                    nextEquation,
                    sNextValue,
                    arrows
            );
            steps.add(step);

            equation = equation.substring(0, equation.length()) + JString(u"\n") + nextPrefix + sNextValue;
            currentValueOffset = equation.length() - sNextValue.length();
            currentExponent = nextExponent;
            currentValue = nextValue;
            previousArrows = arrows;
        }

        Step* finalStep = makeStep(
                context.getString(10073, finalValue),
                nullptr,
                equation,
                JString(u""),
                cloneArrows(previousArrows, false)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JString getSuperscriptNumber(int32_t value) {
        JString digits = JString::valueOf(value);
        JStringBuilder result = JStringBuilder(digits.length());
        for (int32_t i = 0; i < digits.length(); i++) {
            char16_t digit = digits.charAt(i);
            result.append(JString(u"\u2070\u00B9\u00B2\u00B3\u2074\u2075\u2076\u2077\u2078\u2079").charAt(digit - u'0'));
        }
        return result.toString();
    }

    JList<Step*> getStepsForPower3(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForCubeEndingIn0(context, operand);
        }

        int32_t lowerBase = operand / 10 * 10;
        int32_t upperBase = lowerBase + 10;
        int32_t lowerDistance = operand - lowerBase;
        int32_t upperDistance = upperBase - operand;
        int32_t base = lowerDistance <= upperDistance ? lowerBase : upperBase;
        int32_t delta = JMath::abs(operand - base);

        if (delta <= 2) {
            return getStepsForCubeThroughSquareDirect(context, operand);
        }
        return getStepsForCubeByExpansion(context, operand, base, delta, operand > base);
    }

    JList<Step*> getStepsForPower3(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower3(context, operand1);
    }

    JList<Step*> getStepsForPower3Between100And999(JContext context, int32_t operand) {
        if (operand % 10 == 0) {
            return getStepsForCubeEndingIn0(context, operand);
        }

        int32_t lowerBase = operand / 50 * 50;
        int32_t upperBase = lowerBase + 50;
        int32_t lowerDistance = operand - lowerBase;
        int32_t upperDistance = upperBase - operand;
        int32_t lowerScore = getCubeBaseScore(lowerBase, lowerDistance);
        int32_t upperScore = getCubeBaseScore(upperBase, upperDistance);
        int32_t base = lowerScore <= upperScore ? lowerBase : upperBase;
        int32_t delta = JMath::abs(operand - base);

        if (delta <= 2) {
            return getStepsForCubeThroughSquareDirect(context, operand);
        }
        return getStepsForCubeByExpansion(context, operand, base, delta, operand > base);
    }

    JList<Step*> getStepsForPower3Between100And999(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower3Between100And999(context, operand1);
    }

    int32_t getCubeBaseScore(int32_t base, int32_t distance) {
        return distance + (base % 100 == 0 ? 0 : 10);
    }

    JString getCubeCalculationExpression(int32_t value) {
        int32_t zeroCount = 0;
        int32_t prefix = value;
        while (prefix % 10 == 0) {
            prefix /= 10;
            zeroCount++;
        }
        if (zeroCount == 0) {
            JString sValue = JString::valueOf(value);
            return sValue + JString(u" \u00D7 ") + sValue + JString(u" \u00D7 ") + sValue;
        }

        int32_t multiplier = 1;
        for (int32_t i = 0; i < zeroCount * 3; i++) {
            multiplier *= 10;
        }
        return prefix + JString(u"\u00B3 \u00D7 ") + multiplier;
    }

    JList<Step*> getStepsForPower4(JContext context, int32_t operand) {
        return getStepsForFactoredPower(context, operand, 4, 2, 2);
    }

    JList<Step*> getStepsForPower4(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower4(context, operand1);
    }

    JList<Step*> getStepsForPower6(JContext context, int32_t operand) {
        return getStepsForFactoredPower(context, operand, 6, 2, 3);
    }

    JList<Step*> getStepsForPower6(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower6(context, operand1);
    }

    JList<Step*> getStepsForPower9(JContext context, int32_t operand) {
        return getStepsForFactoredPower(context, operand, 9, 3, 3);
    }

    JList<Step*> getStepsForPower9(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower9(context, operand1);
    }

    JList<Step*> getStepsForFactoredPower(JContext context, int32_t operand, int32_t totalPow, int32_t innerPow, int32_t outerPow) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        JString sOperand = JString::valueOf(operand);
        char16_t totalPowChar;
        if (totalPow == 4) totalPowChar = u'\u2074';
        else if (totalPow == 6) totalPowChar = u'\u2076';
        else totalPowChar = u'\u2079';

        char16_t innerPowChar = (innerPow == 2) ? u'\u00B2' : u'\u00B3';
        char16_t outerPowChar = (outerPow == 2) ? u'\u00B2' : u'\u00B3';

        JBigInteger bOperand = JBigInteger::valueOf(operand);
        JBigInteger bStep1 = bOperand.pow(innerPow);
        JBigInteger bFinal = bOperand.pow(totalPow);

        JString sStep1 = bStep1.toString();
        JString sFinal = bFinal.toString();
        JString qStep1 = getQuestionMarksForAnswer(sStep1);
        JString qFinal = getQuestionMarksForAnswer(sFinal);

        JString line0 = JString(u"") + totalPowChar + sOperand + totalPowChar;
        JString line1 = JString(u"(") + sOperand + innerPowChar + JString(u")") + outerPowChar;
        JString line2_step1 = qStep1 + outerPowChar;
        JString line2_filled = sStep1 + outerPowChar;
        JString line3_step2 = qFinal;
        JString line3_final = sFinal;

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2_filled.length() + 1;

        Arrow* arrow0 = makeArrow(1, l1Off, arrowColor, false, true, true, 0.0f, nullptr, 0, false, false, sOperand.length() + 1, line1.length());
        JString labelStep1 = sOperand + innerPowChar;
        Arrow* arrow1 = makeArrow(l1Off + 1, l2Off, arrowColor, false, true, qStep1.length() > 1, 0.0f, labelStep1, hintColor, false, false, sOperand.length() + 1, qStep1.length());

        JList<Arrow*> arrows1 = {};
        arrows1.add(arrow0);
        arrows1.add(arrow1);

        JString eqStep1 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2_step1;
        Step* step1 = makeStep(
                context.getString(10124, operand, JString(u"") + totalPowChar, JString(u"") + innerPowChar, JString(u"") + outerPowChar),
                sOperand + innerPowChar + JString(u" = ?"),
                eqStep1,
                sStep1,
                arrows1
        );
        step1->transparentOffsets.add(0);
        step1->pulseIndex = eqStep1.indexOf(u'?');
        steps.add(step1);

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        JString labelStep2 = sStep1 + outerPowChar;
        Arrow* arrow2 = makeArrow(l2Off, l3Off, arrowColor, false, true, qFinal.length() > 1, 0.0f, labelStep2, hintColor, false, false, line2_filled.length(), qFinal.length());
        arrows2.add(arrow2);

        JString eqStep2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2_filled + JString(u"\n") + line3_step2;
        Step* step2 = makeStep(
                context.getString(10125, JString::valueOf(outerPow), sStep1, JString(u"") + outerPowChar),
                sStep1 + outerPowChar + JString(u" = ?"),
                eqStep2,
                sFinal,
                arrows2
        );
        step2->transparentOffsets.add(0);
        step2->pulseIndex = eqStep2.indexOf(u'?');
        steps.add(step2);

        JString eqFinal = line0 + JString(u"\n") + line1 + JString(u"\n") + line2_filled + JString(u"\n") + line3_final;
        Step* finalStep = makeStep(
                context.getString(10073, bFinal),
                nullptr,
                eqFinal,
                JString(u""),
                cloneArrows(arrows2, false)
        );
        finalStep->isFinal = true;
        finalStep->transparentOffsets.add(0);
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForRoot4(JContext context, int64_t operand) {
        return getStepsForFactoredRoot(context, operand, 4, 2, 2);
    }

    JList<Step*> getStepsForRoot4(JContext context, int32_t operand) {
        return getStepsForRoot4(context, (int64_t) operand);
    }

    JList<Step*> getStepsForRoot4(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForRoot4(context, (int64_t) operand1);
    }

    JList<Step*> getStepsForRoot6(JContext context, int64_t operand) {
        return getStepsForFactoredRoot(context, operand, 6, 3, 2);
    }

    JList<Step*> getStepsForRoot6(JContext context, int32_t operand) {
        return getStepsForRoot6(context, (int64_t) operand);
    }

    JList<Step*> getStepsForRoot6(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForRoot6(context, (int64_t) operand1);
    }

    JList<Step*> getStepsForRoot9(JContext context, int64_t operand) {
        return getStepsForFactoredRoot(context, operand, 9, 3, 3);
    }

    JList<Step*> getStepsForRoot9(JContext context, int32_t operand) {
        return getStepsForRoot9(context, (int64_t) operand);
    }

    JList<Step*> getStepsForRoot9(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForRoot9(context, (int64_t) operand1);
    }

    JList<Step*> getStepsForSquareRoot(JContext context, int64_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t root = (int32_t) JMath::round(JMath::sqrt(operand));
        if (root < 2) root = 2;
        if (root > 99) root = 99;
        operand = (int64_t) root * root;

        JString sOperand = JString::valueOf(operand);
        char16_t sqrtChar = u'\u221A';

        if (root < 10) {
            JString line0 = JString(u"") + sqrtChar + sOperand;
            JString line1_step = JString(u"?");
            JString line1_final = JString::valueOf(root);

            int32_t l0_off = 0;
            int32_t l1_off = line0.length() + 1;

            Arrow* arrow = makeArrow(l0_off + 1, l1_off, arrowColor, false, false, false, 0.0f, root + JString(u"²=") + operand, hintColor, false, false, sOperand.length(), 1);
            JList<Arrow*> arrows1 = {};
            arrows1.add(arrow);

            JString eq1 = line0 + JString(u"\n") + line1_step;
            Step* step1 = makeStep(
                    context.getString(10142, operand, root),
                    JString(u"? \u00D7 ? = ") + operand,
                    eq1,
                    JString::valueOf(root),
                    arrows1
            );
            step1->pulseIndex = eq1.indexOf(u'?');
            steps.add(step1);

            JList<Arrow*> arrowsFinal = cloneArrows(arrows1, false);
            Step* finalStep = makeStep(
                    context.getString(10073, root),
                    nullptr,
                    line0 + JString(u"\n") + line1_final,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
            return steps;
        }

        
        int32_t tens = root / 10;
        int32_t units = root % 10;

        int64_t lead = operand / 100;
        int64_t last2 = operand % 100;
        JString sLead = JString::valueOf(lead);
        JString sLast2 = JString::format( JString(u"%02d"), last2);

        JString line0 = JString(u"") + sqrtChar + sOperand;
        JString line1 = JString(u"") + sqrtChar + JString(u"(") + sLead + JString(u"|") + sLast2 + JString(u")");

        JString sStep1 = JString::valueOf(tens);
        JString sStep2 = JString::valueOf(units);
        JString sFinal = JString::valueOf(root);

        
        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t leadStart = l1_off + 2; 
        int32_t leadLen = sLead.length();
        int32_t pipePos = leadStart + leadLen;
        int32_t last2Start = pipePos + 1; 
        int32_t lastDigitPos = last2Start + 1; 

        int32_t tensPosInL2 = l2_off;
        int32_t unitsPosInL2 = l2_off + 1;

        
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n?_");
        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(l0_off + 1, l1_off + 2, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, sOperand.length(), leadLen + 3));
        
        JString labelTens = tens + JString(u"² ≤ ") + lead;
        arrows1.add(makeArrow(leadStart, tensPosInL2, arrowColor, false, false, false, 0.0f, labelTens, hintColor, false, false, leadLen, 1));

        Step* step1 = makeStep(
                context.getString(10143, sLead, sLast2, tens, tens * tens),
                JString(u"?² ≤ ") + sLead + JString(u" → ") + tens,
                eq1,
                sStep1,
                arrows1
        );
        step1->highlightedRanges.add(JArray<int32_t> {leadStart, leadStart + leadLen});
        step1->pulseIndex = eq1.indexOf(u'?');
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"?");
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);

        int32_t lastDigit = (int32_t) (operand % 10);
        JString step2Description;
        JString step2Hint;
        JString labelUnits;

        if (units == 0 || units == 5) {
            step2Description = context.getString(10145, lastDigit, units, units * units);
            step2Hint = units + JString(u"² = ") + (units * units) + JString(u" → ") + units;
            labelUnits = units + JString(u"² = ") + (units * units);
        } else {
            int32_t c1 = JMath::min(units, 10 - units);
            int32_t c2 = 10 - c1;
            int32_t mid = tens * 10 + 5;
            int32_t midSq = mid * mid;
            JString compSign = (operand > midSq) ? JString(u">") : JString(u"<");
            step2Description = context.getString(10144,
                    lastDigit, c1, c2, c1 * c1, c2 * c2, operand, mid, midSq, compSign, units);
            step2Hint = operand + JString(u" ") + compSign + JString(u" ") + mid + JString(u"²(") + midSq + JString(u") → ") + units;
            labelUnits = mid + JString(u"² = ") + midSq;
        }

        arrows2.add(makeArrow(lastDigitPos, unitsPosInL2, arrowColor, false, false, false, 0.0f, labelUnits, hintColor, false, false, 1, 1));

        Step* step2 = makeStep(
                step2Description,
                step2Hint,
                eq2,
                sStep2,
                arrows2
        );
        step2->highlightedRanges.add(JArray<int32_t> {lastDigitPos, lastDigitPos + 1});
        step2->pulseIndex = eq2.indexOf(u'?');
        steps.add(step2);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, root),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareRoot(JContext context, int32_t operand) {
        return getStepsForSquareRoot(context, (int64_t) operand);
    }

    JList<Step*> getStepsForSquareRoot(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareRoot(context, (int64_t) operand1);
    }

    JList<Step*> getStepsForCubeRoot(JContext context, int64_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t root = (int32_t) JMath::round(JMath::cbrt(operand));
        if (root < 1) root = 1;
        if (root > 99) root = 99;
        operand = (int64_t) root * root * root;

        JString sOperand = JString::valueOf(operand);
        char16_t cbrtPrefix = u'\u00B3';
        char16_t sqrtChar = u'\u221A';

        if (root < 10) {
            JString line0 = JString(u"") + cbrtPrefix + sqrtChar + sOperand;
            JString line1_step = JString(u"?");
            JString line1_final = JString::valueOf(root);

            int32_t l0_off = 0;
            int32_t l1_off = line0.length() + 1;

            Arrow* arrow = makeArrow(l0_off + 2, l1_off, arrowColor, false, false, false, 0.0f, root + JString(u"³=") + operand, hintColor, false, false, sOperand.length(), 1);
            JList<Arrow*> arrows1 = {};
            arrows1.add(arrow);

            JString eq1 = line0 + JString(u"\n") + line1_step;
            Step* step1 = makeStep(
                    context.getString(10015, operand, root),
                    JString(u"? \u00D7 ? \u00D7 ? = ") + operand,
                    eq1,
                    JString::valueOf(root),
                    arrows1
            );
            step1->pulseIndex = eq1.indexOf(u'?');
            steps.add(step1);

            JList<Arrow*> arrowsFinal = cloneArrows(arrows1, false);
            Step* finalStep = makeStep(
                    context.getString(10073, root),
                    nullptr,
                    line0 + JString(u"\n") + line1_final,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
            return steps;
        }

        
        int32_t tens = root / 10;
        int32_t units = root % 10;

        int64_t lead = operand / 1000;
        int64_t last3 = operand % 1000;
        JString sLead = JString::valueOf(lead);
        JString sLast3 = JString::format( JString(u"%03d"), last3);

        JString line0 = JString(u"") + cbrtPrefix + sqrtChar + sOperand;
        JString line1 = JString(u"") + cbrtPrefix + sqrtChar + JString(u"(") + sLead + JString(u"|") + sLast3 + JString(u")");

        JString sStep1 = JString::valueOf(tens);
        JString sStep2 = JString::valueOf(units);
        JString sFinal = JString::valueOf(root);

        
        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t leadStart = l1_off + 3; 
        int32_t leadLen = sLead.length();
        int32_t pipePos = leadStart + leadLen;
        int32_t last3Start = pipePos + 1; 
        int32_t lastDigitPos = last3Start + 2; 

        int32_t tensPosInL2 = l2_off;
        int32_t unitsPosInL2 = l2_off + 1;

        
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n?_");
        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(l0_off + 2, l1_off + 3, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, sOperand.length(), leadLen + 4));
        
        JString labelTens = tens + JString(u"³ ≤ ") + lead;
        arrows1.add(makeArrow(leadStart, tensPosInL2, arrowColor, false, false, false, 0.0f, labelTens, hintColor, false, false, leadLen, 1));

        Step* step1 = makeStep(
                context.getString(10016, sLead, sLast3, tens, tens * tens * tens),
                JString(u"?³ ≤ ") + sLead + JString(u" → ") + tens,
                eq1,
                sStep1,
                arrows1
        );
        step1->highlightedRanges.add(JArray<int32_t> {leadStart, leadStart + leadLen});
        step1->pulseIndex = eq1.indexOf(u'?');
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"?");
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);

        int32_t lastDigit = (int32_t) (operand % 10);
        JString step2Description;
        JString step2Hint;
        JString labelUnits;

        if (units == lastDigit) {
            step2Description = context.getString(10018, lastDigit, units, units * units * units);
            step2Hint = lastDigit + JString(u"³ = ") + (units * units * units) + JString(u" → ") + units;
            labelUnits = units + JString(u"³ = ") + (units * units * units);
        } else {
            step2Description = context.getString(10017, lastDigit, units, units * units * units);
            step2Hint = JString(u"10 - ") + lastDigit + JString(u" = ") + units + JString(u" (") + units + JString(u"³=") + (units * units * units) + JString(u") → ") + units;
            labelUnits = JString(u"10 - ") + lastDigit + JString(u" = ") + units;
        }

        arrows2.add(makeArrow(lastDigitPos, unitsPosInL2, arrowColor, false, false, false, 0.0f, labelUnits, hintColor, false, false, 1, 1));

        Step* step2 = makeStep(
                step2Description,
                step2Hint,
                eq2,
                sStep2,
                arrows2
        );
        step2->highlightedRanges.add(JArray<int32_t> {lastDigitPos, lastDigitPos + 1});
        step2->pulseIndex = eq2.indexOf(u'?');
        steps.add(step2);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, root),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForCubeRoot(JContext context, int32_t operand) {
        return getStepsForCubeRoot(context, (int64_t) operand);
    }

    JList<Step*> getStepsForCubeRoot(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForCubeRoot(context, (int64_t) operand1);
    }

    JList<Step*> getStepsForRoot5(JContext context, int64_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t root = (int32_t) JMath::round(JMath::pow(operand, 0.2));
        if (root < 1) root = 1;
        if (root > 73) root = 73;
        operand = (int64_t) JMath::round(JMath::pow(root, 5));

        JString sOperand = JString::valueOf(operand);
        char16_t rootChar = u'\u2075';
        char16_t sqrtChar = u'\u221A';

        if (root < 10) {
            JString line0 = JString(u"") + rootChar + sqrtChar + sOperand;
            JString line1_step = JString(u"?");
            JString line1_final = JString::valueOf(root);

            int32_t l0_off = 0;
            int32_t l1_off = line0.length() + 1;

            Arrow* arrow = makeArrow(l0_off + 2, l1_off, arrowColor, false, false, false, 0.0f, root + JString(u"⁵=") + operand, hintColor, false, false, sOperand.length(), 1);
            JList<Arrow*> arrows1 = {};
            arrows1.add(arrow);

            JString eq1 = line0 + JString(u"\n") + line1_step;
            Step* step1 = makeStep(
                    context.getString(10131, operand, root),
                    JString(u"?⁵ = ") + operand,
                    eq1,
                    JString::valueOf(root),
                    arrows1
            );
            step1->pulseIndex = eq1.indexOf(u'?');
            steps.add(step1);

            JList<Arrow*> arrowsFinal = cloneArrows(arrows1, false);
            Step* finalStep = makeStep(
                    context.getString(10073, root),
                    nullptr,
                    line0 + JString(u"\n") + line1_final,
                    JString(u""),
                    arrowsFinal
            );
            finalStep->isFinal = true;
            steps.add(finalStep);
            return steps;
        }

        
        int32_t tens = root / 10;
        int32_t units = root % 10;

        int64_t lead = operand / 100000;
        int64_t last5 = operand % 100000;
        JString sLead = JString::valueOf(lead);
        JString sLast5 = JString::format( JString(u"%05d"), last5);

        JString line0 = JString(u"") + rootChar + sqrtChar + sOperand;
        JString line1 = JString(u"") + rootChar + sqrtChar + JString(u"(") + sLead + JString(u"|") + sLast5 + JString(u")");

        JString sStep1 = JString::valueOf(tens);
        JString sStep2 = JString::valueOf(units);
        JString sFinal = JString::valueOf(root);

        
        int32_t l0_off = 0;
        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t leadStart = l1_off + 3; 
        int32_t leadLen = sLead.length();
        int32_t pipePos = leadStart + leadLen;
        int32_t last5Start = pipePos + 1; 
        int32_t lastDigitPos = last5Start + 4; 

        int32_t tensPosInL2 = l2_off;
        int32_t unitsPosInL2 = l2_off + 1;

        int64_t tensPower5 = (int64_t) JMath::round(JMath::pow(tens, 5));

        
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n?_");
        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(l0_off + 2, l1_off + 3, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, sOperand.length(), leadLen + 6));
        
        JString labelTens = tens + JString(u"⁵ ≤ ") + lead;
        arrows1.add(makeArrow(leadStart, tensPosInL2, arrowColor, false, false, false, 0.0f, labelTens, hintColor, false, false, leadLen, 1));

        Step* step1 = makeStep(
                context.getString(10132, sLead, sLast5, tens, tensPower5),
                JString(u"?⁵ ≤ ") + sLead + JString(u" → ") + tens,
                eq1,
                sStep1,
                arrows1
        );
        step1->highlightedRanges.add(JArray<int32_t> {leadStart, leadStart + leadLen});
        step1->pulseIndex = eq1.indexOf(u'?');
        steps.add(step1);

        
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"?");
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);

        int64_t unitsPower5 = (int64_t) JMath::round(JMath::pow(units, 5));
        JString step2Description = context.getString(10133, units, unitsPower5);
        JString step2Hint = units + JString(u"⁵ = ") + unitsPower5 + JString(u" → ") + units;
        JString labelUnits = units + JString(u"⁵=") + unitsPower5;

        arrows2.add(makeArrow(lastDigitPos, unitsPosInL2, arrowColor, false, false, false, 0.0f, labelUnits, hintColor, false, false, 1, 1));

        Step* step2 = makeStep(
                step2Description,
                step2Hint,
                eq2,
                sStep2,
                arrows2
        );
        step2->highlightedRanges.add(JArray<int32_t> {lastDigitPos, lastDigitPos + 1});
        step2->pulseIndex = eq2.indexOf(u'?');
        steps.add(step2);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, root),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForRoot5(JContext context, int32_t operand) {
        return getStepsForRoot5(context, (int64_t) operand);
    }

    JList<Step*> getStepsForRoot5(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForRoot5(context, (int64_t) operand1);
    }

    JList<Step*> getStepsForFactoredRoot(JContext context, int64_t operand, int32_t totalRoot, int32_t outerRoot, int32_t innerRoot) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        
        if (totalRoot == 4 && operand >= 2 && operand < 16) {
            operand = (int64_t) JMath::round(JMath::pow(operand, 4));
        } else if (totalRoot == 6 && operand >= 2 && operand < 64) {
            operand = (int64_t) JMath::round(JMath::pow(operand, 6));
        } else if (totalRoot == 9 && operand >= 2 && operand < 512) {
            operand = (int64_t) JMath::round(JMath::pow(operand, 9));
        }

        char16_t totalChar = (totalRoot == 4) ? u'\u2074' : (totalRoot == 6 ? u'\u2076' : u'\u2079');
        char16_t outerChar = (outerRoot == 2) ? u'\u00B2' : u'\u00B3';
        char16_t innerChar = (innerRoot == 2) ? u'\u00B2' : u'\u00B3';
        char16_t sqrtChar = u'\u221A';

        int64_t innerRes = JMath::round(JMath::pow(operand, 1.0 / innerRoot));
        int64_t finalRes = JMath::round(JMath::pow(innerRes, 1.0 / outerRoot));

        JString sOperand = JString::valueOf(operand);
        JString sStep1 = JString::valueOf(innerRes);
        JString sFinal = JString::valueOf(finalRes);

        JString qStep1 = getQuestionMarksForAnswer(sStep1);
        JString qFinal = getQuestionMarksForAnswer(sFinal);

        
        
        JString line0 = JString(u"") + totalChar + sqrtChar + sOperand;
        JString line1 = JString(u"") + outerChar + sqrtChar + JString(u"(") + innerChar + sqrtChar + sOperand + JString(u")");
        JString line2_step1 = JString(u"") + outerChar + sqrtChar + qStep1;
        JString line2_filled = JString(u"") + outerChar + sqrtChar + sStep1;
        JString line3_step2 = qFinal;
        JString line3_final = sFinal;

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2_filled.length() + 1;

        
        Arrow* arrowOuter = makeArrow(l1Off + 0, 0, arrowColor, false, false, false, 0.0f, JString(u"\u00D7"), hintColor, false, true, 1, 1);
        arrowOuter->centerBetweenArrows = true;
        Arrow* arrowInner = makeArrow(l1Off + 3, 0, arrowColor, false, false, false, 0.0f, nullptr, 0, false, false, 1, 1);

        JString labelStep1 = JString(u"") + innerChar + sqrtChar + sOperand;
        Arrow* arrowStep1 = makeArrow(l1Off + 3, l2Off + 2, arrowColor, false, true, qStep1.length() > 1, 0.0f, labelStep1, hintColor, false, false, 2 + sOperand.length(), qStep1.length());

        JList<Arrow*> arrows1 = {};
        arrows1.add(arrowOuter);
        arrows1.add(arrowInner);
        arrows1.add(arrowStep1);

        JString eqStep1 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2_step1;
        Step* step1 = makeStep(
                context.getString(10134, JString(u"") + totalChar, sOperand, JString(u"") + outerChar, JString(u"") + innerChar, totalRoot, outerRoot, innerRoot),
                JString(u"") + innerChar + sqrtChar + sOperand + JString(u" = ?"),
                eqStep1,
                sStep1,
                arrows1
        );
        step1->pulseIndex = eqStep1.indexOf(u'?');
        steps.add(step1);

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        JString labelStep2 = JString(u"") + outerChar + sqrtChar + sStep1;
        Arrow* arrowStep2 = makeArrow(l2Off, l3Off, arrowColor, false, true, qFinal.length() > 1, 0.0f, labelStep2, hintColor, false, false, line2_filled.length(), qFinal.length());
        arrows2.add(arrowStep2);

        JString eqStep2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2_filled + JString(u"\n") + line3_step2;
        Step* step2 = makeStep(
                context.getString(10135, outerRoot, JString(u"") + outerChar + sqrtChar, sStep1),
                JString(u"") + outerChar + sqrtChar + sStep1 + JString(u" = ?"),
                eqStep2,
                sFinal,
                arrows2
        );
        step2->pulseIndex = eqStep2.indexOf(u'?');
        steps.add(step2);

        JString eqFinal = line0 + JString(u"\n") + line1 + JString(u"\n") + line2_filled + JString(u"\n") + line3_final;
        Step* finalStep = makeStep(
                context.getString(10073, finalRes),
                nullptr,
                eqFinal,
                JString(u""),
                cloneArrows(arrows2, false)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForCubeEndingIn0Legacy(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t prefix = operand / 10;
        int32_t prefixSquare = prefix * prefix;
        int32_t prefixCube = prefixSquare * prefix;
        int32_t finalResult = prefixCube * 1000;

        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sPrefixSquare = JString::valueOf(prefixSquare);
        JString sPrefixCube = JString::valueOf(prefixCube);
        JString sFinalResult = JString::valueOf(finalResult);

        JString line0 = JString(u"\u00B3") + sOperand + JString(u"\u00B3");
        JString line1 = sPrefix + JString(u"\u00B2 \u00D7 ") + sPrefix + JString(u" \u00D7 1000");
        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t firstPrefixInLine1 = l1Off;
        int32_t secondPrefixInLine1 = l1Off + line1.indexOf(sPrefix, line1.indexOf(JString(u"\u00D7")) + 1);

        JString qPrefixSquare = getQuestionMarksForAnswer(sPrefixSquare);
        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(1, firstPrefixInLine1, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sOperand.length(), sPrefix.length()));
        arrows1.add(makeArrow(firstPrefixInLine1, l2Off, arrowColor, false,
                true, sPrefixSquare.length() > 1, 0.0f, sPrefix + JString(u"\u00D7") + sPrefix, hintColor,
                false, false, sPrefix.length(), qPrefixSquare.length()));
        arrows1.add(makeArrow(secondPrefixInLine1, l2Off, arrowColor, false,
                false, sPrefixSquare.length() > 1, 0.0f, nullptr, 0,
                false, false, sPrefix.length(), qPrefixSquare.length()));

        Step* step1 = makeStep(
                context.getString(10046, operand, prefix, 1000, 3),
                sPrefix + JString(u" \u00D7 ") + sPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + qPrefixSquare,
                sPrefixSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JString line2 = sPrefixSquare;
        int32_t l3Off = l2Off + line2.length() + 1;
        JString qPrefixCube = getQuestionMarksForAnswer(sPrefixCube);
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2Off, l3Off, arrowColor, false,
                sPrefixSquare.length() > 1, sPrefixCube.length() > 1, 0.0f,
                JString(u"\u00D7") + sPrefix, hintColor, false, false,
                sPrefixSquare.length(), qPrefixCube.length()));
        arrows2.add(makeArrow(secondPrefixInLine1, l3Off, arrowColor, false,
                false, sPrefixCube.length() > 1, 0.0f, nullptr, 0,
                false, false, sPrefix.length(), qPrefixCube.length()));

        Step* step2 = makeStep(
                context.getString(10037, prefix),
                sPrefixSquare + JString(u" \u00D7 ") + sPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + qPrefixCube,
                sPrefixCube,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JString line3 = sPrefixCube;
        int32_t l4Off = l3Off + line3.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);
        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l3Off, l4Off, arrowColor, false,
                sPrefixCube.length() > 1, sFinalResult.length() > 1, 0.0f,
                JString(u"\u00D71000"), hintColor, false, false,
                sPrefixCube.length(), qFinalResult.length()));

        Step* step3 = makeStep(
                context.getString(10036),
                sPrefixCube + JString(u" \u00D7 1000 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + sFinalResult,
                JString(u""),
                cloneArrows(arrows3, false)
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForCubeEndingIn0(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t zeroCount = 0;
        int32_t prefix = operand;
        while (prefix % 10 == 0) {
            prefix /= 10;
            zeroCount++;
        }
        int32_t appendedZeroCount = zeroCount * 3;
        int32_t multiplier = 1;
        for (int32_t i = 0; i < appendedZeroCount; i++) {
            multiplier *= 10;
        }
        int32_t prefixCube = prefix * prefix * prefix;
        int32_t finalResult = prefixCube * multiplier;
        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sPrefixCube = JString::valueOf(prefixCube);
        JString sMultiplier = JString::valueOf(multiplier);
        JString sFinalResult = JString::valueOf(finalResult);

        JString line0 = JString(u"\u00B3") + sOperand + JString(u"\u00B3");
        JString line1 = sPrefix + JString(u"\u00B3 \u00D7 ") + sMultiplier;
        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t multiplierInLine1 = l1Off + line1.indexOf(sMultiplier);
        JString qPrefixCube = getQuestionMarksForAnswer(sPrefixCube);

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(1, l1Off, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sOperand.length(), sPrefix.length()));
        arrows1.add(makeArrow(l1Off, l2Off, arrowColor, false,
                true, sPrefixCube.length() > 1, 0.0f, sPrefix + JString(u"\u00B3"),
                hintColor, false, false, sPrefix.length(), qPrefixCube.length()));

        Step* step1 = makeStep(
                context.getString(10046, operand, prefix, multiplier, appendedZeroCount),
                sPrefix + JString(u" \u00D7 ") + sPrefix + JString(u" \u00D7 ") + sPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + qPrefixCube,
                sPrefixCube,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JString line2 = sPrefixCube;
        int32_t l3Off = l2Off + line2.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2Off, l3Off, arrowColor, false,
                sPrefixCube.length() > 1, sFinalResult.length() > 1, 0.0f, JString(u"\u00D7") + sMultiplier,
                hintColor, false, false, sPrefixCube.length(), qFinalResult.length()));
        arrows2.add(makeArrow(multiplierInLine1, l3Off, arrowColor, false,
                false, sFinalResult.length() > 1, -1.2f, nullptr, 0,
                false, false, sMultiplier.length(), qFinalResult.length()));

        Step* step2 = makeStep(
                context.getString(10034, multiplier, appendedZeroCount),
                sPrefixCube + JString(u" \u00D7 ") + sMultiplier + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinalResult,
                JString(u""),
                cloneArrows(arrows2, false)
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForCubeThroughSquare(JContext context, int32_t operand, int32_t base,
                                                            int32_t delta, bool isAddition) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        JString sign = isAddition ? JString(u"+") : JString(u"-");

        int32_t square = operand * operand;
        int32_t baseProduct = square * base;
        int32_t deltaProduct = square * delta;
        int32_t finalResult = square * operand;

        JString sOperand = JString::valueOf(operand);
        JString sBase = JString::valueOf(base);
        JString sDelta = JString::valueOf(delta);
        JString sSquare = JString::valueOf(square);
        JString sBaseProduct = JString::valueOf(baseProduct);
        JString sDeltaProduct = JString::valueOf(deltaProduct);
        JString sFinalResult = JString::valueOf(finalResult);

        JString line0 = JString(u"\u00B3") + sOperand + JString(u"\u00B3");
        JString line1 = sOperand + JString(u"\u00B2 \u00D7 ") + sOperand;
        JString line2 = sOperand + JString(u"\u00B2 \u00D7 (") + sBase + JString(u" ") + sign + JString(u" ") + sDelta + JString(u")");
        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;
        int32_t firstOperandInLine1 = l1Off;
        int32_t baseInLine2 = l2Off + line2.indexOf(sBase, line2.indexOf(JString(u"(")) + 1);
        int32_t deltaInLine2 = l2Off + line2.lastIndexOf(sDelta);

        JString qSquare = getQuestionMarksForAnswer(sSquare);
        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(1, firstOperandInLine1, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sOperand.length(), sOperand.length()));
        arrows1.add(makeArrow(firstOperandInLine1, l3Off, arrowColor, false,
                true, sSquare.length() > 1, 0.0f, sOperand + JString(u"\u00D7") + sOperand, hintColor,
                false, false, sOperand.length(), qSquare.length()));

        Step* step1 = makeStep(
                context.getString(10044, operand, base, sign, delta),
                sOperand + JString(u" \u00D7 ") + sOperand + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + qSquare,
                sSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JString line3 = sSquare;
        JString qBaseProduct = getQuestionMarksForAnswer(sBaseProduct);
        JString line4ForBase = qBaseProduct + JString(u" ") + sign + JString(u" ") + sSquare + JString(u"\u00D7") + sDelta;
        int32_t l4Off = l3Off + line3.length() + 1;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l3Off, l4Off, arrowColor, false,
                sSquare.length() > 1, sBaseProduct.length() > 1, 0.0f,
                JString(u"\u00D7") + sBase, hintColor, false, false,
                sSquare.length(), qBaseProduct.length()));
        arrows2.add(makeArrow(baseInLine2, l4Off, arrowColor, false,
                false, sBaseProduct.length() > 1, 0.0f, nullptr, 0,
                false, false, sBase.length(), qBaseProduct.length()));

        Step* step2 = makeStep(
                context.getString(10039, operand, base),
                sSquare + JString(u" \u00D7 ") + sBase + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4ForBase,
                sBaseProduct,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JString qDeltaProduct = getQuestionMarksForAnswer(sDeltaProduct);
        JString line4ForDelta = sBaseProduct + JString(u" ") + sign + JString(u" ") + qDeltaProduct;
        int32_t deltaTarget = l4Off + sBaseProduct.length() + 3;
        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l3Off, deltaTarget, arrowColor, false,
                sSquare.length() > 1, sDeltaProduct.length() > 1, 0.0f,
                JString(u"\u00D7") + sDelta, hintColor, false, false,
                sSquare.length(), qDeltaProduct.length()));
        arrows3.add(makeArrow(deltaInLine2, deltaTarget, arrowColor, false,
                false, sDeltaProduct.length() > 1, 0.0f, nullptr, 0,
                false, false, sDelta.length(), qDeltaProduct.length()));

        Step* step3 = makeStep(
                context.getString(10040, operand, delta),
                sSquare + JString(u" \u00D7 ") + sDelta + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4ForDelta,
                sDeltaProduct,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        JString line4 = sBaseProduct + JString(u" ") + sign + JString(u" ") + sDeltaProduct;
        int32_t l5Off = l4Off + line4.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);
        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(l4Off, l5Off, arrowColor, false,
                sBaseProduct.length() > 1, sFinalResult.length() > 1, 0.0f,
                sBaseProduct + sign + sDeltaProduct, hintColor, false, false,
                sBaseProduct.length(), qFinalResult.length()));
        arrows4.add(makeArrow(deltaTarget, l5Off, arrowColor, false,
                sDeltaProduct.length() > 1, sFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sDeltaProduct.length(), qFinalResult.length()));

        Step* step4 = makeStep(
                context.getString(10036),
                line4 + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + sFinalResult,
                JString(u""),
                cloneArrows(arrows4, false)
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForCubeThroughSquareDirect(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t square = operand * operand;
        int32_t finalResult = square * operand;
        JString sOperand = JString::valueOf(operand);
        JString sSquare = JString::valueOf(square);
        JString sFinalResult = JString::valueOf(finalResult);

        JString line0 = JString(u"\u00B3") + sOperand + JString(u"\u00B3");
        JString line1 = JString(u"(") + sOperand + JString(u"\u00B2 \u00D7 ") + sOperand + JString(u")");
        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t squareInLine1 = l1Off + 1;
        int32_t multiplicationInLine1 = l1Off + line1.indexOf(JString(u"\u00D7"));
        int32_t operandInLine1 = l1Off + line1.lastIndexOf(sOperand);

        JString qSquare = getQuestionMarksForAnswer(sSquare);
        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(1, multiplicationInLine1, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));
        arrows1.add(makeArrow(squareInLine1, l2Off, arrowColor, false,
                true, sSquare.length() > 1, 0.0f, sOperand + JString(u"\u00B2"), hintColor,
                false, false, sOperand.length(), qSquare.length()));

        Step* step1 = makeStep(
                context.getString(10045),
                sOperand + JString(u" \u00D7 ") + sOperand + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + qSquare,
                sSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JString line2 = sSquare;
        int32_t l3Off = l2Off + line2.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2Off, l3Off, arrowColor, false,
                sSquare.length() > 1, sFinalResult.length() > 1, 0.0f,
                JString(u"\u00D7") + sOperand, hintColor, false, false,
                sSquare.length(), qFinalResult.length()));
        arrows2.add(makeArrow(operandInLine1, l3Off, arrowColor, false,
                false, sFinalResult.length() > 1, -1.2f, nullptr, 0,
                false, false, sOperand.length(), qFinalResult.length()));

        Step* step2 = makeStep(
                context.getString(10041, operand),
                sSquare + JString(u" \u00D7 ") + sOperand + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinalResult,
                JString(u""),
                cloneArrows(arrows2, false)
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForCubeByExpansion(JContext context, int32_t operand, int32_t base,
                                                          int32_t delta, bool isAddition) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        JString sign = isAddition ? JString(u"+") : JString(u"-");

        int32_t baseCube = base * base * base;
        int32_t middleTerm = 3 * base * delta * operand;
        int32_t deltaCube = delta * delta * delta;
        int32_t finalResult = operand * operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sBase = JString::valueOf(base);
        JString sDelta = JString::valueOf(delta);
        JString sBaseCube = JString::valueOf(baseCube);
        JString sMiddleTerm = JString::valueOf(middleTerm);
        JString sDeltaCube = JString::valueOf(deltaCube);
        JString sFinalResult = JString::valueOf(finalResult);

        JString line0 = JString(u"\u00B3") + sOperand + JString(u"\u00B3");
        JString line1 = JString(u"(") + sBase + JString(u" ") + sign + JString(u" ") + sDelta + JString(u")\u00B3");
        JString line2 = sBase + JString(u"\u00B3 ") + sign + JString(u" 3\u00D7") + sBase + JString(u"\u00D7") + sDelta + JString(u"\u00D7") + sOperand
                + JString(u" ") + sign + JString(u" ") + sDelta + JString(u"\u00B3");
        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;
        int32_t baseInLine1 = l1Off + line1.indexOf(sBase);
        int32_t deltaInLine1 = l1Off + line1.lastIndexOf(sDelta);
        int32_t firstBaseInLine2 = l2Off;
        int32_t middleBaseInLine2 = l2Off + line2.indexOf(sBase, sBase.length() + 1);
        int32_t middleDeltaInLine2 = l2Off + line2.indexOf(sDelta, middleBaseInLine2 - l2Off + sBase.length());
        int32_t operandInLine2 = l2Off + line2.lastIndexOf(sOperand);
        int32_t lastDeltaInLine2 = l2Off + line2.lastIndexOf(sDelta);

        bool multiplyOperandByDeltaFirst = operand % 10 == 5;
        int32_t firstFactor;
        int32_t secondFactor;
        JString firstExpression;
        JString secondExpression;
        int32_t firstSource1;
        int32_t firstSource2;
        int32_t firstSource1Length;
        int32_t firstSource2Length;
        int32_t secondSource1;
        int32_t secondSource2;
        int32_t secondSource1Length;
        int32_t secondSource2Length;

        if (multiplyOperandByDeltaFirst) {
            firstFactor = operand * delta;
            secondFactor = 3 * base;
            firstExpression = sOperand + JString(u"\u00D7") + sDelta;
            secondExpression = JString(u"3\u00D7") + sBase;
            firstSource1 = operandInLine2;
            firstSource2 = middleDeltaInLine2;
            firstSource1Length = sOperand.length();
            firstSource2Length = sDelta.length();
            secondSource1 = l2Off + line2.indexOf(JString(u"3\u00D7"));
            secondSource2 = middleBaseInLine2;
            secondSource1Length = 1;
            secondSource2Length = sBase.length();
        } else {
            firstFactor = 3 * delta;
            secondFactor = base * operand;
            firstExpression = JString(u"3\u00D7") + sDelta;
            secondExpression = sBase + JString(u"\u00D7") + sOperand;
            firstSource1 = l2Off + line2.indexOf(JString(u"3\u00D7"));
            firstSource2 = middleDeltaInLine2;
            firstSource1Length = 1;
            firstSource2Length = sDelta.length();
            secondSource1 = middleBaseInLine2;
            secondSource2 = operandInLine2;
            secondSource1Length = sBase.length();
            secondSource2Length = sOperand.length();
        }

        JString sFirstFactor = JString::valueOf(firstFactor);
        JString sSecondFactor = JString::valueOf(secondFactor);
        JString qFirstFactor = getQuestionMarksForAnswer(sFirstFactor);
        JString qSecondFactor = getQuestionMarksForAnswer(sSecondFactor);
        JString line3ForFirstFactor = qFirstFactor + JString(u" \u00D7 ") + qSecondFactor;
        int32_t firstFactorTarget = l3Off;
        int32_t secondFactorTarget = l3Off + qFirstFactor.length() + 3;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(1, l1Off + line1.indexOf(sign), arrowColor, true,
                true, false, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));
        arrows1.add(makeArrow(baseInLine1, firstBaseInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows1.add(makeArrow(baseInLine1, middleBaseInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows1.add(makeArrow(deltaInLine1, middleDeltaInLine2, arrowColor, true,
                false, false, 0.0f, nullptr, 0, false, false, sDelta.length(), sDelta.length()));
        arrows1.add(makeArrow(deltaInLine1, lastDeltaInLine2, arrowColor, true,
                false, true, 0.0f, nullptr, 0, false, false, sDelta.length(), sDelta.length()));
        arrows1.add(makeArrow(baseInLine1, operandInLine2, arrowColor, true,
                true, true, 0.0f, sign, hintColor, false, false,
                sBase.length(), sOperand.length()));
        arrows1.add(makeArrow(deltaInLine1, operandInLine2, arrowColor, true,
                false, true, 0.0f, nullptr, 0, false, false,
                sDelta.length(), sOperand.length()));
        arrows1.add(makeArrow(firstSource1, firstFactorTarget, arrowColor, false,
                true, sFirstFactor.length() > 1, 0.0f, firstExpression, hintColor,
                false, false, firstSource1Length, qFirstFactor.length()));
        arrows1.add(makeArrow(firstSource2, firstFactorTarget, arrowColor, false,
                false, sFirstFactor.length() > 1, 0.0f, nullptr, 0,
                false, false, firstSource2Length, qFirstFactor.length()));

        Step* step1 = makeStep(
                context.getString(10038, operand, base, sign, delta, firstExpression),
                firstExpression + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3ForFirstFactor,
                sFirstFactor,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JString line3ForSecondFactor = sFirstFactor + JString(u" \u00D7 ") + qSecondFactor;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(secondSource1, secondFactorTarget, arrowColor, false,
                true, sSecondFactor.length() > 1, 0.0f, secondExpression,
                hintColor, false, false, secondSource1Length, qSecondFactor.length()));
        arrows2.add(makeArrow(secondSource2, secondFactorTarget, arrowColor, false,
                false, sSecondFactor.length() > 1, 0.0f, nullptr, 0,
                false, false, secondSource2Length, qSecondFactor.length()));

        Step* step2 = makeStep(
                context.getString(10043, secondExpression),
                secondExpression + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3ForSecondFactor,
                sSecondFactor,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JString line3 = sFirstFactor + JString(u" \u00D7 ") + sSecondFactor;
        int32_t l4Off = l3Off + line3.length() + 1;
        JString qBaseCube = getQuestionMarksForAnswer(sBaseCube);
        JString qMiddleTerm = getQuestionMarksForAnswer(sMiddleTerm);
        JString qDeltaCube = getQuestionMarksForAnswer(sDeltaCube);
        JString line4ForBase = qBaseCube + JString(u" ") + sign + JString(u" ") + qMiddleTerm + JString(u" ") + sign + JString(u" ") + qDeltaCube;
        int32_t baseTarget = l4Off;
        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(firstBaseInLine2, baseTarget, arrowColor, false,
                true, sBaseCube.length() > 1, 0.0f, sBase + JString(u"\u00B3"), hintColor,
                false, false, sBase.length(), qBaseCube.length()));

        Step* step3 = makeStep(
                context.getString(10035, base),
                getCubeCalculationExpression(base) + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4ForBase,
                sBaseCube,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        JString line4ForMiddle = sBaseCube + JString(u" ") + sign + JString(u" ") + qMiddleTerm
                + JString(u" ") + sign + JString(u" ") + qDeltaCube;
        int32_t middleTarget = l4Off + sBaseCube.length() + 3;
        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(l3Off, middleTarget, arrowColor, false,
                sFirstFactor.length() > 1, sMiddleTerm.length() > 1, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, sFirstFactor.length(), qMiddleTerm.length()));
        arrows4.add(makeArrow(l3Off + sFirstFactor.length() + 3, middleTarget, arrowColor, false,
                false, sMiddleTerm.length() > 1, 0.0f, nullptr, 0,
                false, false, sSecondFactor.length(), qMiddleTerm.length()));

        Step* step4 = makeStep(
                context.getString(10042),
                sFirstFactor + JString(u" \u00D7 ") + sSecondFactor + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4ForMiddle,
                sMiddleTerm,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        JString line4ForDelta = sBaseCube + JString(u" ") + sign + JString(u" ") + sMiddleTerm + JString(u" ") + sign + JString(u" ") + qDeltaCube;
        int32_t deltaTarget = l4Off + sBaseCube.length() + 3 + sMiddleTerm.length() + 3;
        JList<Arrow*> arrows5 = cloneAndDim(arrows4);
        arrows5.add(makeArrow(lastDeltaInLine2, deltaTarget, arrowColor, false,
                false, sDeltaCube.length() > 1, 0.0f, sDelta + JString(u"\u00B3"), hintColor,
                false, false, sDelta.length(), qDeltaCube.length()));

        Step* step5 = makeStep(
                context.getString(10037, delta),
                sDelta + JString(u" \u00D7 ") + sDelta + JString(u" \u00D7 ") + sDelta + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4ForDelta,
                sDeltaCube,
                arrows5
        );
        step5->transparentOffsets.add(0);
        steps.add(step5);

        JString line4 = sBaseCube + JString(u" ") + sign + JString(u" ") + sMiddleTerm + JString(u" ") + sign + JString(u" ") + sDeltaCube;
        int32_t l5Off = l4Off + line4.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);
        JList<Arrow*> arrows6 = cloneAndDim(arrows5);
        arrows6.add(makeArrow(l4Off, l5Off, arrowColor, false,
                sBaseCube.length() > 1, sFinalResult.length() > 1, 0.0f,
                sBaseCube + sign + sMiddleTerm + sign + sDeltaCube, hintColor,
                false, false, sBaseCube.length(), qFinalResult.length()));
        arrows6.add(makeArrow(middleTarget, l5Off, arrowColor, false,
                sMiddleTerm.length() > 1, sFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sMiddleTerm.length(), qFinalResult.length()));
        arrows6.add(makeArrow(deltaTarget, l5Off, arrowColor, false,
                sDeltaCube.length() > 1, sFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sDeltaCube.length(), qFinalResult.length()));

        Step* step6 = makeStep(
                context.getString(10036),
                line4 + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows6
        );
        step6->transparentOffsets.add(0);
        steps.add(step6);

        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + sFinalResult,
                JString(u""),
                cloneArrows(arrows6, false)
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForPower2Between100And999(JContext context, int32_t operand) {
        if (operand % 100 == 0) {
            return getStepsForSquareEndingIn00(context, operand);
        }
        if (operand % 10 == 0) {
            return getStepsForSquareByHundredsAndTens(context, operand);
        }
        return getStepsForSquareAroundConvenientBase(context, operand, 2.2f, true, 2);
    }

    JList<Step*> getStepsForPower2Between100And999(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower2Between100And999(context, operand1);
    }

    JList<Step*> getStepsForPower2Between1000And9999(JContext context, int32_t operand) {
        if (operand % 100 == 0) {
            return getStepsForSquareEndingIn00(context, operand);
        }
        if (operand % 10 == 0) {
            return getStepsForSquareByThousandsHundredsAndTens(context, operand);
        }
        return getStepsForSquareAroundConvenientBase(context, operand, 2.5f, true, 3);
    }

    JList<Step*> getStepsForPower2Between1000And9999(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForPower2Between1000And9999(context, operand1);
    }

    JList<Step*> getStepsForSquareAroundConvenientBaseLegacy(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        
        
        int32_t lowerBase = operand / 50 * 50;
        int32_t upperBase = lowerBase + 50;
        int32_t lowerDistance = operand - lowerBase;
        int32_t upperDistance = upperBase - operand;
        int32_t base;
        if (lowerDistance < upperDistance) {
            base = lowerBase;
        } else if (upperDistance < lowerDistance) {
            base = upperBase;
        } else {
            base = lowerBase % 100 == 0 ? lowerBase : upperBase;
        }

        int32_t delta = JMath::abs(operand - base);
        bool isAddition = operand >= base;
        int32_t baseSquare = base * base;
        int32_t product = base * delta;
        int32_t doubleProduct = 2 * product;
        int32_t deltaSquare = delta * delta;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sBase = JString::valueOf(base);
        JString sDelta = JString::valueOf(delta);
        JString sBaseSquare = JString::valueOf(baseSquare);
        JString sProduct = JString::valueOf(product);
        JString sDoubleProduct = JString::valueOf(doubleProduct);
        JString sDeltaSquare = JString::valueOf(deltaSquare);
        JString sFinalResult = JString::valueOf(finalResult);
        JString sign = isAddition ? JString(u"+") : JString(u"-");

        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = JString(u"(") + sBase + JString(u" ") + sign + JString(u" ") + sDelta + JString(u")\u00B2");
        JString line2 = sBase + JString(u"\u00B2 ") + sign + JString(u" 2\u00D7") + sBase + JString(u"\u00D7") + sDelta + JString(u" + ") + sDelta + JString(u"\u00B2");

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;

        int32_t baseInLine1 = l1Off + line1.indexOf(sBase);
        int32_t deltaInLine1 = l1Off + line1.lastIndexOf(sDelta);
        int32_t firstBaseInLine2 = l2Off;
        int32_t middleBaseInLine2 = l2Off + line2.indexOf(sBase, sBase.length() + 1);
        int32_t middleDeltaInLine2 = l2Off + line2.indexOf(sDelta, middleBaseInLine2 - l2Off + sBase.length());
        int32_t lastDeltaInLine2 = l2Off + line2.lastIndexOf(sDelta);

        Step* intro = makeStep(
                context.getString(10154, operand, base, sign, delta),
                nullptr,
                line0 + JString(u"\n") + line1
        );
        intro->isIntro = true;
        intro->transparentOffsets.add(0);
        steps.add(intro);

        JString qBaseSquare = getQuestionMarksForAnswer(sBaseSquare);
        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(baseInLine1, firstBaseInLine2, arrowColor, false,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows1.add(makeArrow(firstBaseInLine2, l3Off, arrowColor, false,
                true, qBaseSquare.length() > 1, 0.0f, sBase + JString(u"\u00B2"), hintColor,
                false, false, sBase.length(), qBaseSquare.length()));

        Step* step1 = makeStep(
                context.getString(10119),
                sBase + JString(u" \u00D7 ") + sBase + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + qBaseSquare,
                sBaseSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        int32_t l4Off = l3Off + sBaseSquare.length() + 1;
        JString qProduct = getQuestionMarksForAnswer(sProduct);
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(baseInLine1, middleBaseInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows2.add(makeArrow(deltaInLine1, middleDeltaInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sDelta.length(), sDelta.length()));
        arrows2.add(makeArrow(middleBaseInLine2, l4Off, arrowColor, false,
                true, qProduct.length() > 1, 0.0f, sBase + JString(u"\u00D7") + sDelta, hintColor,
                false, false, sBase.length(), qProduct.length()));
        arrows2.add(makeArrow(middleDeltaInLine2, l4Off, arrowColor, false,
                false, qProduct.length() > 1, 0.0f, nullptr, 0, false, false,
                sDelta.length(), qProduct.length()));

        Step* step2 = makeStep(
                context.getString(10118, sBase, delta),
                sBase + JString(u" \u00D7 ") + sDelta + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sBaseSquare + JString(u"\n") + qProduct,
                sProduct,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        int32_t l5Off = l4Off + sProduct.length() + 1;
        JString qDoubleProduct = getQuestionMarksForAnswer(sDoubleProduct);
        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l4Off, l5Off, arrowColor, false,
                sProduct.length() > 1, qDoubleProduct.length() > 1, 0.0f, JString(u"\u00D72"), hintColor,
                false, false, sProduct.length(), qDoubleProduct.length()));
        arrows3.add(makeArrow(l2Off + line2.indexOf(JString(u"2\u00D7")), l5Off, arrowColor, false,
                false, qDoubleProduct.length() > 1, 1.1f, nullptr, 0, false, false,
                1, qDoubleProduct.length()));

        Step* step3 = makeStep(
                context.getString(10102),
                sProduct + JString(u" \u00D7 2 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sBaseSquare + JString(u"\n") + sProduct + JString(u"\n") + qDoubleProduct,
                sDoubleProduct,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        int32_t l6Off = l5Off + sDoubleProduct.length() + 1;
        JString qDeltaSquare = getQuestionMarksForAnswer(sDeltaSquare);
        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(lastDeltaInLine2, l6Off, arrowColor, false,
                false, qDeltaSquare.length() > 1, 0.0f, sDelta + JString(u"\u00B2"), hintColor,
                false, false, sDelta.length(), qDeltaSquare.length()));

        Step* step4 = makeStep(
                context.getString(10119),
                sDelta + JString(u" \u00D7 ") + sDelta + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sBaseSquare + JString(u"\n") + sProduct + JString(u"\n") + sDoubleProduct + JString(u"\n") + qDeltaSquare,
                sDeltaSquare,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        JString results = sBaseSquare + JString(u" ") + sign + JString(u" ") + sDoubleProduct + JString(u" + ") + sDeltaSquare;
        int32_t l7Off = l6Off + sDeltaSquare.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);
        JList<Arrow*> arrows5 = cloneAndDim(arrows4);
        arrows5.add(makeArrow(l3Off, l7Off, arrowColor, false,
                sBaseSquare.length() > 1, qFinalResult.length() > 1, 0.0f,
                results, hintColor, false, false, sBaseSquare.length(), qFinalResult.length()));
        arrows5.add(makeArrow(l5Off, l7Off, arrowColor, false,
                sDoubleProduct.length() > 1, qFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sDoubleProduct.length(), qFinalResult.length()));
        arrows5.add(makeArrow(l6Off, l7Off, arrowColor, false,
                sDeltaSquare.length() > 1, qFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sDeltaSquare.length(), qFinalResult.length()));

        Step* step5 = makeStep(
                context.getString(10155),
                results + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sBaseSquare + JString(u"\n") + sProduct + JString(u"\n") + sDoubleProduct + JString(u"\n") + sDeltaSquare + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows5
        );
        step5->transparentOffsets.add(0);
        steps.add(step5);

        JList<Arrow*> arrowsFinal = cloneArrows(arrows5, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sBaseSquare + JString(u"\n") + sProduct + JString(u"\n") + sDoubleProduct + JString(u"\n") + sDeltaSquare + JString(u"\n") + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareAroundConvenientBase(JContext context, int32_t operand) {
        return getStepsForSquareAroundConvenientBase(context, operand, 1.1f, false, 0);
    }

    JList<Step*> getStepsForSquareAroundConvenientBase(JContext context, int32_t operand,
                                                                     float thirdStepArrowCurve,
                                                                     bool arrowsStartFromNumberCenter,
                                                                     int32_t firstStepResultIndent) {
        int32_t lowerBase = operand / 50 * 50;
        int32_t upperBase = lowerBase + 50;
        int32_t lowerDistance = operand - lowerBase;
        int32_t upperDistance = upperBase - operand;
        int32_t base;
        if (lowerDistance < upperDistance) {
            base = lowerBase;
        } else if (upperDistance < lowerDistance) {
            base = upperBase;
        } else {
            base = lowerBase % 100 == 0 ? lowerBase : upperBase;
        }

        int32_t delta = JMath::abs(operand - base);
        bool isAddition = operand >= base;
        return getStepsForSquareFromParts(
                context,
                operand,
                base,
                delta,
                isAddition,
                context.getString(10154, operand, base,
                        isAddition ? JString(u"+") : JString(u"-"), delta),
                thirdStepArrowCurve,
                arrowsStartFromNumberCenter,
                firstStepResultIndent
        );
    }

    JList<Step*> getStepsForSquareByHundredsAndTens(JContext context, int32_t operand) {
        int32_t hundreds = operand / 100 * 100;
        int32_t tens = operand % 100;
        return getStepsForSquareFromParts(
                context,
                operand,
                hundreds,
                tens,
                true,
                context.getString(10168, operand, hundreds, tens),
                2.2f,
                true,
                2
        );
    }

    JList<Step*> getStepsForSquareByThousandsHundredsAndTens(JContext context, int32_t operand) {
        int32_t thousandsAndHundreds = operand / 100 * 100;
        int32_t tens = operand % 100;
        return getStepsForSquareFromParts(
                context,
                operand,
                thousandsAndHundreds,
                tens,
                true,
                context.getString(10169,
                        operand, thousandsAndHundreds, tens),
                2.5f,
                true,
                3
        );
    }

    JList<Step*> getStepsForSquareFromParts(JContext context, int32_t operand, int32_t base,
                                                          int32_t delta, bool isAddition,
                                                          JString decompositionDescription,
                                                          float thirdStepArrowCurve,
                                                          bool arrowsStartFromNumberCenter,
                                                          int32_t firstStepResultIndent) {
        JString sign = isAddition ? JString(u"+") : JString(u"-");

        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t product = base * delta;
        int32_t baseSquare = base * base;
        int32_t doubleProduct = 2 * product;
        int32_t deltaSquare = delta * delta;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sBase = JString::valueOf(base);
        JString sDelta = JString::valueOf(delta);
        JString sProduct = JString::valueOf(product);
        JString sBaseSquare = JString::valueOf(baseSquare);
        JString sDoubleProduct = JString::valueOf(doubleProduct);
        JString sDeltaSquare = JString::valueOf(deltaSquare);
        JString sFinalResult = JString::valueOf(finalResult);

        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = JString(u"(") + sBase + JString(u" ") + sign + JString(u" ") + sDelta + JString(u")\u00B2");
        JString line2 = sBase + JString(u"\u00B2 ") + sign + JString(u" 2\u00D7") + sBase + JString(u"\u00D7") + sDelta + JString(u" + ") + sDelta + JString(u"\u00B2");

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;

        int32_t originalNumberPos = 1;
        int32_t signInLine1 = l1Off + line1.indexOf(sign);
        int32_t baseInLine1 = l1Off + line1.indexOf(sBase);
        int32_t deltaInLine1 = l1Off + line1.lastIndexOf(sDelta);

        int32_t firstBaseInLine2 = l2Off;
        int32_t middleBaseInLine2 = l2Off + line2.indexOf(sBase, sBase.length() + 1);
        int32_t middleDeltaInLine2 = l2Off + line2.indexOf(sDelta, middleBaseInLine2 - l2Off + sBase.length());
        int32_t lastDeltaInLine2 = l2Off + line2.lastIndexOf(sDelta);

        JString qProduct = getQuestionMarksForAnswer(sProduct);
        JString productIndent = getSpaces(firstStepResultIndent);
        int32_t productTarget = l3Off + firstStepResultIndent;
        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(originalNumberPos, signInLine1, arrowColor, true,
                true, false, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));
        arrows1.add(makeArrow(baseInLine1, firstBaseInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows1.add(makeArrow(baseInLine1, middleBaseInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows1.add(makeArrow(deltaInLine1, middleDeltaInLine2, arrowColor, true,
                false, false, 0.0f, nullptr, 0, false, false, sDelta.length(), sDelta.length()));
        arrows1.add(makeArrow(deltaInLine1, lastDeltaInLine2, arrowColor, true,
                false, true, 0.0f, nullptr, 0, false, false, sDelta.length(), sDelta.length()));
        arrows1.add(makeArrow(middleBaseInLine2, productTarget, arrowColor, false,
                true, sProduct.length() > 1, 0.0f, sBase + JString(u"\u00D7") + sDelta, hintColor,
                false, false, sBase.length(), sProduct.length()));
        arrows1.add(makeArrow(middleDeltaInLine2, productTarget, arrowColor, false,
                false, sProduct.length() > 1, 0.0f, nullptr, 0, false, false,
                sDelta.length(), sProduct.length()));

        Step* step1 = makeStep(
                decompositionDescription
                        + JString(u"\n\n") + context.getString(10118, sBase, delta),
                JString(u"(a ") + sign + JString(u" b)\u00B2 = a\u00B2 ") + sign + JString(u" 2ab + b\u00B2"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + productIndent + qProduct,
                sProduct,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JString line3 = productIndent + sProduct;
        int32_t l4Off = l3Off + line3.length() + 1;
        JString qBaseSquare = getQuestionMarksForAnswer(sBaseSquare);
        JString qDoubleProduct = getQuestionMarksForAnswer(sDoubleProduct);
        JString qDeltaSquare = getQuestionMarksForAnswer(sDeltaSquare);
        JString resultsWithQuestions = qBaseSquare + JString(u" ") + sign + JString(u" ") + qDoubleProduct + JString(u" + ") + qDeltaSquare;
        int32_t baseSquareTarget = l4Off;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(firstBaseInLine2, baseSquareTarget, arrowColor, false,
                true, true, 0.0f, sBase + JString(u"\u00B2"), hintColor, false, false,
                arrowsStartFromNumberCenter ? sBase.length() : sBase.length() + 1,
                qBaseSquare.length()));

        Step* step2 = makeStep(
                context.getString(10119),
                sBase + JString(u" \u00D7 ") + sBase + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + resultsWithQuestions,
                sBaseSquare,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JString resultsAfterBaseSquare = sBaseSquare + JString(u" ") + sign + JString(u" ") + qDoubleProduct + JString(u" + ") + qDeltaSquare;
        int32_t doubleProductTargetAfterBaseSquare = l4Off + sBaseSquare.length() + 3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        Arrow* doubleProductStepArrow = makeArrow(productTarget, doubleProductTargetAfterBaseSquare, arrowColor, false,
                sProduct.length() > 1, true, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, sProduct.length(), qDoubleProduct.length());
        doubleProductStepArrow->centerBetweenArrows = true;
        arrows3.add(doubleProductStepArrow);
        arrows3.add(makeArrow(l2Off + line2.indexOf(JString(u"2\u00D7")), doubleProductTargetAfterBaseSquare, arrowColor, false,
                false, true, thirdStepArrowCurve, nullptr, 0, false, false, 1, qDoubleProduct.length()));

        Step* step3 = makeStep(
                context.getString(10102),
                sProduct + JString(u" \u00D7 2 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + resultsAfterBaseSquare,
                sDoubleProduct,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        JString resultsAfterDoubleProduct = sBaseSquare + JString(u" ") + sign + JString(u" ") + sDoubleProduct + JString(u" + ") + qDeltaSquare;
        int32_t deltaSquareTargetAfterDoubleProduct = l4Off + sBaseSquare.length() + 3 + sDoubleProduct.length() + 3;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(lastDeltaInLine2, deltaSquareTargetAfterDoubleProduct, arrowColor, false,
                false, false, 0.0f, sDelta + JString(u"\u00B2"), hintColor, false, false,
                arrowsStartFromNumberCenter ? sDelta.length() : sDelta.length() + 1,
                qDeltaSquare.length()));

        Step* step4 = makeStep(
                context.getString(10119),
                sDelta + JString(u" \u00D7 ") + sDelta + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + resultsAfterDoubleProduct,
                sDeltaSquare,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        JString results = sBaseSquare + JString(u" ") + sign + JString(u" ") + sDoubleProduct + JString(u" + ") + sDeltaSquare;
        int32_t l5Off = l4Off + results.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);

        JList<Arrow*> arrows5 = cloneAndDim(arrows4);
        arrows5.add(makeArrow(l4Off, l5Off, arrowColor, false,
                sBaseSquare.length() > 1, sFinalResult.length() > 1, 0.0f,
                sBaseSquare + sign + sDoubleProduct + JString(u"+") + sDeltaSquare, hintColor,
                false, false, sBaseSquare.length(), qFinalResult.length()));
        arrows5.add(makeArrow(l4Off + sBaseSquare.length() + 3, l5Off, arrowColor, false,
                sDoubleProduct.length() > 1, sFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sDoubleProduct.length(), qFinalResult.length()));
        arrows5.add(makeArrow(l4Off + sBaseSquare.length() + 3 + sDoubleProduct.length() + 3, l5Off, arrowColor, false,
                sDeltaSquare.length() > 1, sFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sDeltaSquare.length(), qFinalResult.length()));

        Step* step5 = makeStep(
                context.getString(10155),
                results + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + results + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows5
        );
        step5->transparentOffsets.add(0);
        steps.add(step5);

        JList<Arrow*> arrowsFinal = cloneArrows(arrows5, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + results + JString(u"\n") + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareBetweenTensAndNines(JContext context, int32_t operand, int32_t base) {
        return getStepsForSquareBetweenTensAndNines(context, operand, base, 0);
    }

    JList<Step*> getStepsForSquareBetweenTensAndNines(JContext context, int32_t operand, int32_t base,
                                                                    int32_t firstStepResultIndent) {
        if (operand % 10 == 0) {
            return getStepsForSquareEndingIn0(context, operand);
        }

        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t units = operand - base;
        int32_t product = base * units;
        int32_t baseSquare = base * base;
        int32_t doubleProduct = 2 * product;
        int32_t unitsSquare = units * units;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sBase = JString::valueOf(base);
        JString sUnits = JString::valueOf(units);
        JString sProduct = JString::valueOf(product);
        JString sBaseSquare = JString::valueOf(baseSquare);
        JString sDoubleProduct = JString::valueOf(doubleProduct);
        JString sUnitsSquare = JString::valueOf(unitsSquare);
        JString sFinalResult = JString::valueOf(finalResult);

        
        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = JString(u"(") + sBase + JString(u" + ") + sUnits + JString(u")\u00B2");
        JString line2 = sBase + JString(u"\u00B2 + 2\u00D7") + sBase + JString(u"\u00D7") + sUnits + JString(u" + ") + sUnits + JString(u"\u00B2");

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;

        int32_t originalNumberPos = 1;
        int32_t plusInLine1 = l1Off + line1.indexOf(u'+');
        int32_t baseInLine1 = l1Off + line1.indexOf(sBase);
        int32_t unitsInLine1 = l1Off + line1.lastIndexOf(sUnits);

        int32_t firstBaseInLine2 = l2Off;
        int32_t middleBaseInLine2 = l2Off + line2.indexOf(sBase, sBase.length() + 1);
        int32_t middleUnitsInLine2 = l2Off + line2.indexOf(sUnits, middleBaseInLine2 - l2Off + 2);
        int32_t lastUnitsInLine2 = l2Off + line2.lastIndexOf(sUnits);

        JString qProduct = getQuestionMarksForAnswer(sProduct);
        JString productIndent = getSpaces(firstStepResultIndent);
        int32_t productTarget = l3Off + firstStepResultIndent;
        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(originalNumberPos, plusInLine1, arrowColor, true,
                true, false, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));
        
        arrows1.add(makeArrow(baseInLine1, firstBaseInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows1.add(makeArrow(baseInLine1, middleBaseInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sBase.length(), sBase.length()));
        arrows1.add(makeArrow(unitsInLine1, middleUnitsInLine2, arrowColor, true,
                false, false, 0.0f, nullptr, 0, false, false, sUnits.length(), sUnits.length()));
        arrows1.add(makeArrow(unitsInLine1, lastUnitsInLine2, arrowColor, true,
                false, true, 0.0f, nullptr, 0, false, false, sUnits.length(), sUnits.length()));
        
        arrows1.add(makeArrow(middleBaseInLine2, productTarget, arrowColor, false,
                true, sProduct.length() > 1, 0.0f, sBase + JString(u"\u00D7") + sUnits, hintColor,
                false, false, sBase.length(), sProduct.length()));
        arrows1.add(makeArrow(middleUnitsInLine2, productTarget, arrowColor, false,
                false, sProduct.length() > 1, 0.0f, nullptr, 0, false, false,
                sUnits.length(), sProduct.length()));

        Step* step1 = makeStep(
                context.getString(10118, sBase, units),
                JString(u"(a + b)\u00B2 = a\u00B2 + 2ab + b\u00B2"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + productIndent + qProduct,
                sProduct,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JString line3 = productIndent + sProduct;
        int32_t l4Off = l3Off + line3.length() + 1;
        JString qBaseSquare = getQuestionMarksForAnswer(sBaseSquare);
        JString qDoubleProduct = getQuestionMarksForAnswer(sDoubleProduct);
        JString qUnitsSquare = getQuestionMarksForAnswer(sUnitsSquare);
        JString resultsWithQuestions = qBaseSquare + JString(u" + ") + qDoubleProduct + JString(u" + ") + qUnitsSquare;
        int32_t baseSquareTarget = l4Off;
        
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(firstBaseInLine2, baseSquareTarget, arrowColor, false,
                true, true, 0.0f, sBase + JString(u"\u00B2"), hintColor, false, false,
                sBase.length(), qBaseSquare.length()));

        Step* step2 = makeStep(
                context.getString(10119),
                sBase + JString(u" \u00D7 ") + sBase + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + resultsWithQuestions,
                sBaseSquare,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JString resultsAfterBaseSquare = sBaseSquare + JString(u" + ") + qDoubleProduct + JString(u" + ") + qUnitsSquare;
        int32_t doubleProductTargetAfterBaseSquare = l4Off + sBaseSquare.length() + 3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        Arrow* doubleProductStepArrow = makeArrow(productTarget, doubleProductTargetAfterBaseSquare, arrowColor, false,
                sProduct.length() > 1, true, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, sProduct.length(), qDoubleProduct.length());
        doubleProductStepArrow->centerBetweenArrows = true;
        arrows3.add(doubleProductStepArrow);
        arrows3.add(makeArrow(l2Off + line2.indexOf(JString(u"2\u00D7")), doubleProductTargetAfterBaseSquare, arrowColor, false,
                false, true, 1.1f, nullptr, 0, false, false, 1, qDoubleProduct.length()));

        Step* step3 = makeStep(
                context.getString(10102),
                sProduct + JString(u" \u00D7 2 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + resultsAfterBaseSquare,
                sDoubleProduct,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        JString resultsAfterDoubleProduct = sBaseSquare + JString(u" + ") + sDoubleProduct + JString(u" + ") + qUnitsSquare;
        int32_t unitsSquareTargetAfterDoubleProduct = l4Off + sBaseSquare.length() + 3 + sDoubleProduct.length() + 3;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(lastUnitsInLine2, unitsSquareTargetAfterDoubleProduct, arrowColor, false,
                false, false, 0.0f, sUnits + JString(u"\u00B2"), hintColor, false, false,
                sUnits.length(), qUnitsSquare.length()));

        Step* step4 = makeStep(
                context.getString(10119),
                sUnits + JString(u" \u00D7 ") + sUnits + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + resultsAfterDoubleProduct,
                sUnitsSquare,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        JString results = sBaseSquare + JString(u" + ") + sDoubleProduct + JString(u" + ") + sUnitsSquare;
        int32_t l5Off = l4Off + results.length() + 1;
        JString qFinalResult = getQuestionMarksForAnswer(sFinalResult);

        JList<Arrow*> arrows5 = cloneAndDim(arrows4);
        arrows5.add(makeArrow(l4Off, l5Off, arrowColor, false,
                sBaseSquare.length() > 1, sFinalResult.length() > 1, 0.0f,
                sBaseSquare + JString(u"+") + sDoubleProduct + JString(u"+") + sUnitsSquare, hintColor,
                false, false, sBaseSquare.length(), qFinalResult.length()));
        arrows5.add(makeArrow(l4Off + sBaseSquare.length() + 3, l5Off, arrowColor, false,
                sDoubleProduct.length() > 1, sFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sDoubleProduct.length(), qFinalResult.length()));
        arrows5.add(makeArrow(l4Off + sBaseSquare.length() + 3 + sDoubleProduct.length() + 3, l5Off, arrowColor, false,
                sUnitsSquare.length() > 1, sFinalResult.length() > 1, 0.0f,
                nullptr, 0, false, false, sUnitsSquare.length(), qFinalResult.length()));

        Step* step5 = makeStep(
                context.getString(10011),
                results + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + results + JString(u"\n") + qFinalResult,
                sFinalResult,
                arrows5
        );
        step5->transparentOffsets.add(0);
        steps.add(step5);

        JList<Arrow*> arrowsFinal = cloneArrows(arrows5, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + results + JString(u"\n") + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareBetween20And29(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween20And29(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween30And39(JContext context, int32_t operand) {
        return getStepsForSquareBetweenTensAndNines(context, operand, 30);
    }

    JList<Step*> getStepsForSquareBetween30And39(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween30And39(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween60And69(JContext context, int32_t operand) {
        return getStepsForSquareBetweenTensAndNines(context, operand, 60);
    }

    JList<Step*> getStepsForSquareBetween60And69(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween60And69(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween70And79(JContext context, int32_t operand) {
        return getStepsForSquareBetweenTensAndNines(context, operand, 70);
    }

    JList<Step*> getStepsForSquareBetween70And79(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween70And79(context, operand1);
    }

    JList<Step*> getStepsForSquareBetween80And89(JContext context, int32_t operand) {
        return getStepsForSquareBetweenTensAndNines(context, operand, 80);
    }

    JList<Step*> getStepsForSquareBetween80And89(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareBetween80And89(context, operand1);
    }

    JList<Step*> getStepsForSquareEndingIn75(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t prefix = operand / 100;
        int32_t firstFactor = prefix * 10 + 5;
        int32_t nextPrefix = prefix + 1;
        int32_t firstTerm = operand - 25;
        int32_t product = firstFactor * nextPrefix;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sFirstTerm = JString::valueOf(firstTerm);
        JString sFirstFactor = JString::valueOf(firstFactor);
        JString sNextPrefix = JString::valueOf(nextPrefix);
        JString sProduct = JString::valueOf(product);
        JString sFinalResult = JString::valueOf(finalResult);

        
        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = JString(u"(") + sFirstTerm + JString(u" + 25)\u00B2");
        JString line2 = sFirstFactor + JString(u" \u00D7 ") + sNextPrefix + JString(u" _ 25\u00B2");

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;

        int32_t originalNumberPos = 1;
        int32_t plusInLine1 = l1Off + line1.indexOf(u'+');
        int32_t firstTermInLine1 = l1Off + 1;
        int32_t prefixInLine1 = firstTermInLine1;
        int32_t fiveInLine1 = firstTermInLine1 + (prefix > 0 ? sPrefix.length() : 0);
        int32_t twentyFiveInLine1 = l1Off + line1.indexOf(JString(u"25"), line1.indexOf(u'+'));

        int32_t firstPrefixInLine2 = l2Off;
        int32_t fiveInLine2 = l2Off + (prefix > 0 ? sPrefix.length() : 0);
        int32_t mulInLine2 = l2Off + line2.indexOf(JString(u"\u00D7"));
        int32_t nextPrefixInLine2 = l2Off + line2.indexOf(sNextPrefix, line2.indexOf(JString(u"\u00D7")));
        int32_t suffixSquareInLine2 = l2Off + line2.indexOf(JString(u"25"), line2.indexOf(u'_'));

        JString qProduct = getQuestionMarksForAnswer(sProduct);
        JString qSuffix = JString(u"???");

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(originalNumberPos, plusInLine1, arrowColor, true,
                true, false, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));

        if (prefix > 0) {
            arrows1.add(makeArrow(prefixInLine1, firstPrefixInLine2, arrowColor, true,
                    true, true, 0.0f, nullptr, 0, false, false, sPrefix.length(), sPrefix.length()));
            arrows1.add(makeArrow(prefixInLine1, nextPrefixInLine2, arrowColor, true,
                    true, true, 0.0f, sPrefix + JString(u"+1"), hintColor, true, true, sPrefix.length(), sNextPrefix.length()));
        }
        arrows1.add(makeArrow(fiveInLine1, fiveInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, 1, 1));
        arrows1.add(makeArrow(twentyFiveInLine1, suffixSquareInLine2, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, 2, 2));

        arrows1.add(makeArrow(mulInLine2, l3Off, arrowColor, false,
                false, qProduct.length() > 1, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, 1, qProduct.length()));

        Step* step1 = makeStep(
                context.getString(10118, sFirstFactor, nextPrefix),
                sFirstFactor + JString(u" \u00D7 ") + sNextPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + qProduct + getSpaces(qSuffix.length()),
                sProduct,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(suffixSquareInLine2, l3Off + sProduct.length(), arrowColor, false,
                true, true, 0.0f, JString(u"625"), hintColor, true, false,
                2, qSuffix.length()));

        Step* step2 = makeStep(
                context.getString(10167),
                JString(u"625"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sProduct + qSuffix,
                JString(u"625"),
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn75(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareEndingIn75(context, operand1);
    }

    JList<Step*> getStepsForSquareEndingIn125(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t prefix = operand / 1000;
        int32_t prefixSquare = prefix * prefix;
        int32_t rem = prefix % 4;
        JString sDiv4;
        if (rem == 0) {
            sDiv4 = JString::valueOf(prefix / 4);
        } else if (rem == 1) {
            sDiv4 = (prefix / 4 == 0 ? JString(u"0.25") : (prefix / 4) + JString(u".25"));
        } else if (rem == 2) {
            sDiv4 = (prefix / 4 == 0 ? JString(u"0.5") : (prefix / 4) + JString(u".5"));
        } else {
            sDiv4 = (prefix / 4 == 0 ? JString(u"0.75") : (prefix / 4) + JString(u".75"));
        }

        int32_t sumInt = prefixSquare + prefix / 4;
        JString sSum;
        if (rem == 0) {
            sSum = JString::valueOf(sumInt);
        } else if (rem == 1) {
            sSum = sumInt + JString(u".25");
        } else if (rem == 2) {
            sSum = sumInt + JString(u".5");
        } else {
            sSum = sumInt + JString(u".75");
        }

        int32_t product = prefixSquare * 100 + prefix * 25;
        int32_t beforeSuffix = product + 1;
        int64_t finalResult = (int64_t) operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sSquare = JString::valueOf(prefixSquare);
        JString sProduct = JString::valueOf(product);
        JString sBeforeSuffix = JString::valueOf(beforeSuffix);
        JString sFinalResult = JString::valueOf(finalResult);

        JString padRight = repeatChar(u'\u00A0', 10);
        JString padRight3 = repeatChar(u'\u00A0', 8);
        
        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = JString(u"(") + sPrefix + JString(u"\u00B2+") + sPrefix + JString(u"\u00F74)\u00D7100+1_5625");
        JString line2 = sSquare + JString(u"+") + sDiv4 + padRight;
        JString line3 = sSum + padRight3;
        JString line4 = getSpaces(4) + sProduct + JString(u"+1");
        JString line5 = getSpaces(4) + sBeforeSuffix;

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;
        int32_t l4Off = l3Off + line3.length() + 1;
        int32_t l5Off = l4Off + line4.length() + 1;

        int32_t originalNumberPos = 1;
        int32_t mulInL1 = l1Off + line1.indexOf(JString(u"\u00D7"));

        int32_t firstPrefixInL1 = l1Off + 1;
        int32_t firstTermLenInL1 = sPrefix.length() + 1; 
        int32_t secondPrefixInL1 = l1Off + line1.indexOf(sPrefix, line1.indexOf(u'+'));
        int32_t fourInL1 = l1Off + line1.indexOf(JString(u"4"), line1.indexOf(JString(u"\u00F7")));
        int32_t hundredInL1 = l1Off + line1.indexOf(JString(u"100"));
        int32_t suffixInL1 = l1Off + line1.indexOf(JString(u"5625"), line1.indexOf(u'_'));

        int32_t firstTermInL2 = l2Off;
        int32_t sumInL3 = l3Off;
        int32_t productInL4 = l4Off + 4;
        int32_t oneInL4 = productInL4 + sProduct.length() + 1;
        int32_t targetInL5 = l5Off + 4;

        JString qSquare = getQuestionMarksForAnswer(sSquare);
        JString qDiv4 = getQuestionMarksForAnswer(sDiv4);
        JString qSum = getQuestionMarksForAnswer(sSum);
        JString qProduct = getQuestionMarksForAnswer(sProduct);
        JString qBeforeSuffix = getQuestionMarksForAnswer(sBeforeSuffix);
        JString qSuffix = JString(u"????");

        
        JString line2Step1 = qSquare + JString(u"+") + qDiv4 + padRight;
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2Step1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(originalNumberPos, mulInL1, arrowColor, true,
                true, false, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));

        arrows1.add(makeArrow(firstPrefixInL1, firstTermInL2, arrowColor, false,
                true, qSquare.length() > 1, 0.0f, sPrefix + JString(u"\u00B2"), hintColor,
                false, false, firstTermLenInL1, qSquare.length()));

        Step* step1 = makeStep(
                context.getString(10119),
                sPrefix + JString(u" \u00D7 ") + sPrefix + JString(u" = ?"),
                eq1,
                sSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString line2Step2 = sSquare + JString(u"+") + qDiv4 + padRight;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2Step2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        int32_t secondTermInL2 = l2Off + line2Step2.indexOf(qDiv4);
        arrows2.add(makeArrow(secondPrefixInL1, secondTermInL2, arrowColor, false,
                true, qDiv4.length() > 1, 0.0f, JString(u"\u00F7"), hintColor,
                false, false, sPrefix.length(), qDiv4.length()));
        arrows2.add(makeArrow(fourInL1, secondTermInL2, arrowColor, false,
                true, qDiv4.length() > 1, 0.0f, nullptr, 0,
                false, false, 1, qDiv4.length()));

        Step* step2 = makeStep(
                context.getString(10121, sPrefix, 4),
                sPrefix + JString(u" \u00F7 4 = ?"),
                eq2,
                sDiv4,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        
        JString line3Step3 = qSum + padRight3;
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3Step3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        int32_t secondTermInL2Filled = l2Off + line2.indexOf(u'+') + 1;
        arrows3.add(makeArrow(firstTermInL2, sumInL3, arrowColor, false,
                true, qSum.length() > 1, 0.0f, JString(u"+"), hintColor,
                false, false, sSquare.length(), qSum.length()));
        arrows3.add(makeArrow(secondTermInL2Filled, sumInL3, arrowColor, false,
                true, qSum.length() > 1, 0.0f, nullptr, 0,
                false, false, sDiv4.length(), qSum.length()));

        Step* step3 = makeStep(
                context.getString(10120, sSquare, sDiv4),
                sSquare + JString(u" + ") + sDiv4 + JString(u" = ?"),
                eq3,
                sSum,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        
        JString line4Step4 = getSpaces(4) + qProduct + JString(u"+1");
        JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4Step4;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(sumInL3, productInL4, arrowColor, false,
                true, qProduct.length() > 1, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, sSum.length(), qProduct.length()));
        arrows4.add(makeArrow(hundredInL1, productInL4, arrowColor, false,
                true, qProduct.length() > 1, -2.0f, nullptr, 0,
                false, false, 3, qProduct.length()));

        Step* step4 = makeStep(
                context.getString(10123, sSum, 100),
                sSum + JString(u" \u00D7 100 = ?"),
                eq4,
                sProduct,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        
        JString line5Step5 = getSpaces(4) + qBeforeSuffix;
        JString eq5 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + line5Step5;

        JList<Arrow*> arrows5 = cloneAndDim(arrows4);
        arrows5.add(makeArrow(productInL4, targetInL5, arrowColor, false,
                true, qBeforeSuffix.length() > 1, 0.0f, JString(u"+"), hintColor,
                false, false, sProduct.length(), qBeforeSuffix.length()));
        arrows5.add(makeArrow(oneInL4, targetInL5, arrowColor, false,
                true, qBeforeSuffix.length() > 1, 0.0f, nullptr, 0,
                false, false, 1, qBeforeSuffix.length()));

        Step* step5 = makeStep(
                context.getString(10120, sProduct, JString(u"1")),
                sProduct + JString(u" + 1 = ?"),
                eq5,
                sBeforeSuffix,
                arrows5
        );
        step5->transparentOffsets.add(0);
        steps.add(step5);

        
        JString line5Step6 = getSpaces(4) + sBeforeSuffix + qSuffix;
        JString eq6 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + line5Step6;

        JList<Arrow*> arrows6 = cloneAndDim(arrows5);
        arrows6.add(makeArrow(suffixInL1, targetInL5 + sBeforeSuffix.length(), arrowColor, false,
                true, true, -2.0f, JString(u"5625"), hintColor, true, false,
                4, qSuffix.length()));

        Step* step6 = makeStep(
                context.getString(10162),
                JString(u"5625"),
                eq6,
                JString(u"5625"),
                arrows6
        );
        step6->transparentOffsets.add(0);
        steps.add(step6);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows6, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + getSpaces(4) + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn125(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareEndingIn125(context, operand1);
    }

    JList<Step*> getStepsForSquareEndingIn05(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t prefix = operand / 100;
        int32_t prefixSquare = prefix * prefix;
        int32_t prefixSquareTimesTen = prefixSquare * 10;
        int32_t beforeSuffix = prefixSquareTimesTen + prefix;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sPrefixSquare = JString::valueOf(prefixSquare);
        JString sPrefixSquareTimesTen = JString::valueOf(prefixSquareTimesTen);
        JString sBeforeSuffix = JString::valueOf(beforeSuffix);
        JString sFinalResult = JString::valueOf(finalResult);

        
        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = sPrefix + JString(u"\u00B2\u00D710+") + sPrefix + JString(u"_05\u00B2");

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + sPrefixSquare.length() + 1;
        int32_t l4Off = l3Off + sPrefixSquareTimesTen.length() + 1;

        int32_t prefixInOriginal = 1;
        int32_t suffixInOriginal = prefixInOriginal + sOperand.length() - 2;
        int32_t firstPrefixInFormula = l1Off;
        int32_t secondPrefixInFormula = l1Off + line1.indexOf(JString(u"+")) + 1;
        int32_t tenInFormula = l1Off + line1.indexOf(JString(u"10"));
        int32_t suffixSquareInFormula = l1Off + line1.lastIndexOf(JString(u"05"));

        JString qPrefixSquare = getQuestionMarksForAnswer(sPrefixSquare);
        JString qPrefixSquareTimesTen = getQuestionMarksForAnswer(sPrefixSquareTimesTen);
        JString qBeforeSuffix = getQuestionMarksForAnswer(sBeforeSuffix);
        JString qSuffix = JString(u"???");

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(prefixInOriginal, firstPrefixInFormula, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sPrefix.length(), sPrefix.length() + 1));
        arrows1.add(makeArrow(prefixInOriginal, secondPrefixInFormula, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, sPrefix.length(), sPrefix.length()));
        arrows1.add(makeArrow(suffixInOriginal, suffixSquareInFormula, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, 2, 2));
        arrows1.add(makeArrow(firstPrefixInFormula, l2Off, arrowColor, false,
                true, qPrefixSquare.length() > 1, 0.0f, sPrefix + JString(u"\u00B2"), hintColor,
                false, false, sPrefix.length() + 1, qPrefixSquare.length()));

        Step* step1 = makeStep(
                context.getString(10119),
                sPrefix + JString(u" \u00D7 ") + sPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + qPrefixSquare,
                sPrefixSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2Off, l3Off, arrowColor, false,
                sPrefixSquare.length() > 1, qPrefixSquareTimesTen.length() > 1, 0.0f,
                JString(u"\u00D7"), hintColor, false, false,
                sPrefixSquare.length(), qPrefixSquareTimesTen.length()));
        arrows2.add(makeArrow(tenInFormula, l3Off, arrowColor, false,
                true, qPrefixSquareTimesTen.length() > 1, 2.0f, nullptr, 0, false, false,
                2, qPrefixSquareTimesTen.length()));

        Step* step2 = makeStep(
                context.getString(10099),
                sPrefixSquare + JString(u" \u00D7 10 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + sPrefixSquare + JString(u"\n") + qPrefixSquareTimesTen,
                sPrefixSquareTimesTen,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l3Off, l4Off, arrowColor, false,
                sPrefixSquareTimesTen.length() > 1, qBeforeSuffix.length() > 1, 0.0f,
                JString(u"+"), hintColor, false, false,
                sPrefixSquareTimesTen.length(), qBeforeSuffix.length()));
        arrows3.add(makeArrow(secondPrefixInFormula, l4Off, arrowColor, false,
                true, qBeforeSuffix.length() > 1, -2.5f, nullptr, 0, false, false,
                sPrefix.length(), qBeforeSuffix.length()));

        Step* step3 = makeStep(
                context.getString(10009),
                sPrefixSquareTimesTen + JString(u" + ") + sPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + sPrefixSquare + JString(u"\n") + sPrefixSquareTimesTen + JString(u"\n") + qBeforeSuffix,
                sBeforeSuffix,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(suffixSquareInFormula, l4Off + sBeforeSuffix.length(), arrowColor, false,
                true, true, -2.2f, JString(u"025"), hintColor, true, false,
                3, qSuffix.length()));

        Step* step4 = makeStep(
                context.getString(10158),
                JString(u"025"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + sPrefixSquare + JString(u"\n") + sPrefixSquareTimesTen + JString(u"\n") + sBeforeSuffix + qSuffix,
                JString(u"025"),
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sPrefixSquare + JString(u"\n") + sPrefixSquareTimesTen + JString(u"\n") + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn05(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareEndingIn05(context, operand1);
    }

    JList<Step*> getStepsForSquareEndingIn15(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t prefix = operand / 100;
        int32_t prefixSquare = prefix * prefix;
        int32_t prefixDoubled = prefix * 2;
        int32_t product = prefixSquare * 10 + prefix * 5;
        int32_t beforeSuffix = product - prefixDoubled;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sSquare = JString::valueOf(prefixSquare);
        JString sHalf = (prefix % 2 == 0) ? JString::valueOf(prefix / 2) : (prefix / 2) + JString(u".5");
        JString sSum = (prefix % 2 == 0) ? JString::valueOf(prefixSquare + prefix / 2) : (prefixSquare + prefix / 2) + JString(u".5");
        JString sProduct = JString::valueOf(product);
        JString sPrefixDoubled = JString::valueOf(prefixDoubled);
        JString sBeforeSuffix = JString::valueOf(beforeSuffix);
        JString sFinalResult = JString::valueOf(finalResult);

        JString padRight = repeatChar(u'\u00A0', 10);
        
        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = JString(u"(") + sPrefix + JString(u"\u00B2+") + sPrefix + JString(u"\u00F72)\u00D710-2\u00D7") + sPrefix + JString(u"_15\u00B2");
        JString line2 = sSquare + JString(u"+") + sHalf + padRight;
        JString line3 = sSum;
        JString line4 = getSpaces(4) + sProduct + JString(u"-") + sPrefixDoubled;
        JString line5 = getSpaces(4) + sBeforeSuffix;

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + line2.length() + 1;
        int32_t l4Off = l3Off + line3.length() + 1;
        int32_t l5Off = l4Off + line4.length() + 1;

        int32_t originalNumberPos = 1;
        int32_t mulInL1 = l1Off + line1.indexOf(JString(u"\u00D7"));

        int32_t firstPrefixInL1 = l1Off + 1;
        int32_t firstTermLenInL1 = sPrefix.length() + 1; 
        int32_t secondPrefixInL1 = l1Off + line1.indexOf(sPrefix, line1.indexOf(u'+'));
        int32_t twoInL1 = l1Off + line1.indexOf(JString(u"2"), line1.indexOf(JString(u"\u00F7")));
        int32_t tenInL1 = l1Off + line1.indexOf(JString(u"10"));
        int32_t minusInL1 = l1Off + line1.indexOf(u'-');
        int32_t twoInL1Mul = minusInL1 + 1;
        int32_t thirdPrefixInL1 = minusInL1 + 3;
        int32_t fifteenInL1 = l1Off + line1.indexOf(JString(u"15"), line1.indexOf(u'_'));

        int32_t firstTermInL2 = l2Off;
        int32_t plusInL2 = l2Off + line2.indexOf(u'+');

        int32_t sumInL3 = l3Off;

        int32_t productInL4 = l4Off + 4;
        int32_t targetInL4 = productInL4 + sProduct.length() + 1;
        int32_t targetInL5 = l5Off + 4;

        JString qSquare = getQuestionMarksForAnswer(sSquare);
        JString qHalf = getQuestionMarksForAnswer(sHalf);
        JString qSum = getQuestionMarksForAnswer(sSum);
        JString qProduct = getQuestionMarksForAnswer(sProduct);
        JString qPrefixDoubled = getQuestionMarksForAnswer(sPrefixDoubled);
        JString qBeforeSuffix = getQuestionMarksForAnswer(sBeforeSuffix);
        JString qSuffix = JString(u"???");

        
        JString line2Step1 = qSquare + JString(u"+") + qHalf + padRight;
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2Step1;

        JList<Arrow*> arrows1 = {};
        
        arrows1.add(makeArrow(originalNumberPos, mulInL1, arrowColor, true,
                true, false, 0.0f, nullptr, 0, false, false, sOperand.length(), 1));

        arrows1.add(makeArrow(firstPrefixInL1, firstTermInL2, arrowColor, false,
                true, qSquare.length() > 1, 0.0f, sPrefix + JString(u"\u00B2"), hintColor,
                false, false, firstTermLenInL1, qSquare.length()));

        Step* step1 = makeStep(
                context.getString(10119),
                sPrefix + JString(u" \u00D7 ") + sPrefix + JString(u" = ?"),
                eq1,
                sSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        
        JString line2Step2 = sSquare + JString(u"+") + qHalf + padRight;
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2Step2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        int32_t secondTermInL2 = l2Off + line2Step2.indexOf(qHalf);
        arrows2.add(makeArrow(secondPrefixInL1, secondTermInL2, arrowColor, false,
                true, qHalf.length() > 1, 0.0f, JString(u"\u00F7"), hintColor,
                false, false, sPrefix.length(), qHalf.length()));
        arrows2.add(makeArrow(twoInL1, secondTermInL2, arrowColor, false,
                true, qHalf.length() > 1, 0.0f, nullptr, 0,
                false, false, 1, qHalf.length()));

        Step* step2 = makeStep(
                context.getString(10121, sPrefix, 2),
                sPrefix + JString(u" \u00F7 2 = ?"),
                eq2,
                sHalf,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        
        JString line3Step3 = qSum;
        JString eq3 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3Step3;

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        int32_t secondTermInL2Filled = l2Off + line2.indexOf(u'+') + 1;
        arrows3.add(makeArrow(firstTermInL2, sumInL3, arrowColor, false,
                true, qSum.length() > 1, 0.0f, JString(u"+"), hintColor,
                false, false, sSquare.length(), qSum.length()));
        arrows3.add(makeArrow(secondTermInL2Filled, sumInL3, arrowColor, false,
                true, qSum.length() > 1, 0.0f, nullptr, 0,
                false, false, sHalf.length(), qSum.length()));

        Step* step3 = makeStep(
                context.getString(10120, sSquare, sHalf),
                sSquare + JString(u" + ") + sHalf + JString(u" = ?"),
                eq3,
                sSum,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        
        JString line4Step4 = getSpaces(4) + qProduct;
        JString eq4 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4Step4;

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(sumInL3, productInL4, arrowColor, false,
                true, qProduct.length() > 1, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, sSum.length(), qProduct.length()));
        arrows4.add(makeArrow(tenInL1, productInL4, arrowColor, false,
                true, qProduct.length() > 1, -2.0f, nullptr, 0,
                false, false, 2, qProduct.length()));

        Step* step4 = makeStep(
                context.getString(10123, sSum, 10),
                sSum + JString(u" \u00D7 10 = ?"),
                eq4,
                sProduct,
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        
        JString line4Step5 = getSpaces(4) + sProduct + JString(u"-") + qPrefixDoubled;
        JString eq5 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4Step5;

        JList<Arrow*> arrows5 = cloneAndDim(arrows4);
        arrows5.add(makeArrow(twoInL1Mul, targetInL4, arrowColor, false,
                true, qPrefixDoubled.length() > 1, 0.0f, JString(u"\u00D7"), hintColor,
                false, false, 1, qPrefixDoubled.length()));
        arrows5.add(makeArrow(thirdPrefixInL1, targetInL4, arrowColor, false,
                true, qPrefixDoubled.length() > 1, 0.0f, nullptr, 0,
                false, false, sPrefix.length(), qPrefixDoubled.length()));

        Step* step5 = makeStep(
                context.getString(10123, sPrefix, 2),
                JString(u"2 \u00D7 ") + sPrefix + JString(u" = ?"),
                eq5,
                sPrefixDoubled,
                arrows5
        );
        step5->transparentOffsets.add(0);
        steps.add(step5);

        
        JString line5Step6 = getSpaces(4) + qBeforeSuffix;
        JString eq6 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + line5Step6;

        JList<Arrow*> arrows6 = cloneAndDim(arrows5);
        arrows6.add(makeArrow(productInL4, targetInL5, arrowColor, false,
                true, qBeforeSuffix.length() > 1, 0.0f, JString(u"-"), hintColor,
                false, false, sProduct.length(), qBeforeSuffix.length()));
        arrows6.add(makeArrow(targetInL4, targetInL5, arrowColor, false,
                true, qBeforeSuffix.length() > 1, 0.0f, nullptr, 0,
                false, false, sPrefixDoubled.length(), qBeforeSuffix.length()));

        Step* step6 = makeStep(
                context.getString(10172),
                sProduct + JString(u" - ") + sPrefixDoubled + JString(u" = ?"),
                eq6,
                sBeforeSuffix,
                arrows6
        );
        step6->transparentOffsets.add(0);
        steps.add(step6);

        
        JString line5Step7 = getSpaces(4) + sBeforeSuffix + qSuffix;
        JString eq7 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + line5Step7;

        JList<Arrow*> arrows7 = cloneAndDim(arrows6);
        arrows7.add(makeArrow(fifteenInL1, targetInL5 + sBeforeSuffix.length(), arrowColor, false,
                true, true, -2.0f, JString(u"225"), hintColor, true, false,
                3, qSuffix.length()));

        Step* step7 = makeStep(
                context.getString(10163),
                JString(u"225"),
                eq7,
                JString(u"225"),
                arrows7
        );
        step7->transparentOffsets.add(0);
        steps.add(step7);

        
        JList<Arrow*> arrowsFinal = cloneArrows(arrows7, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + line3 + JString(u"\n") + line4 + JString(u"\n") + getSpaces(4) + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn15(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareEndingIn15(context, operand1);
    }

    JList<Step*> getStepsForSquareEndingIn95(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        int32_t prefix = operand / 100;
        int32_t nextPrefix = prefix + 1;
        int32_t nextPrefixSquare = nextPrefix * nextPrefix;
        int32_t nextPrefixSquareTimesTen = nextPrefixSquare * 10;
        int32_t beforeSuffix = nextPrefixSquareTimesTen - nextPrefix;
        int32_t finalResult = operand * operand;

        JString sOperand = JString::valueOf(operand);
        JString sPrefix = JString::valueOf(prefix);
        JString sNextPrefix = JString::valueOf(nextPrefix);
        JString sNextPrefixSquare = JString::valueOf(nextPrefixSquare);
        JString sNextPrefixSquareTimesTen = JString::valueOf(nextPrefixSquareTimesTen);
        JString sBeforeSuffix = JString::valueOf(beforeSuffix);
        JString sFinalResult = JString::valueOf(finalResult);

        
        JString line0 = JString(u"\u00B2") + sOperand + JString(u"\u00B2");
        JString line1 = sNextPrefix + JString(u"\u00B2\u00D710-") + sNextPrefix + JString(u"_95\u00B2");

        int32_t l1Off = line0.length() + 1;
        int32_t l2Off = l1Off + line1.length() + 1;
        int32_t l3Off = l2Off + sNextPrefixSquare.length() + 1;
        int32_t l4Off = l3Off + sNextPrefixSquareTimesTen.length() + 1;

        int32_t prefixInOriginal = 1;
        int32_t suffixInOriginal = prefixInOriginal + sOperand.length() - 2;
        int32_t firstPrefixInFormula = l1Off;
        int32_t tenInFormula = l1Off + line1.indexOf(JString(u"10"));
        int32_t secondPrefixInFormula = l1Off + line1.indexOf(JString(u"-")) + 1;
        int32_t suffixSquareInFormula = l1Off + line1.lastIndexOf(JString(u"95"));

        JString qNextPrefixSquare = getQuestionMarksForAnswer(sNextPrefixSquare);
        JString qNextPrefixSquareTimesTen = getQuestionMarksForAnswer(sNextPrefixSquareTimesTen);
        JString qBeforeSuffix = getQuestionMarksForAnswer(sBeforeSuffix);
        JString qSuffix = JString(u"???");

        JList<Arrow*> arrows1 = {};
        
        if (prefix > 0) {
            arrows1.add(makeArrow(prefixInOriginal, firstPrefixInFormula, arrowColor, true,
                    true, true, 0.0f, sPrefix + JString(u"+1"), hintColor, true, true, sPrefix.length(), sNextPrefix.length() + 1));
            arrows1.add(makeArrow(prefixInOriginal, secondPrefixInFormula, arrowColor, true,
                    true, true, 0.0f, sPrefix + JString(u"+1"), hintColor, true, true, sPrefix.length(), sNextPrefix.length()));
        } else {
            arrows1.add(makeArrow(prefixInOriginal, firstPrefixInFormula, arrowColor, true,
                    true, true, 0.0f, nullptr, 0, false, false, 1, sNextPrefix.length() + 1));
            arrows1.add(makeArrow(prefixInOriginal, secondPrefixInFormula, arrowColor, true,
                    true, true, 0.0f, nullptr, 0, false, false, 1, sNextPrefix.length()));
        }
        arrows1.add(makeArrow(suffixInOriginal, suffixSquareInFormula, arrowColor, true,
                true, true, 0.0f, nullptr, 0, false, false, 2, 2));

        arrows1.add(makeArrow(firstPrefixInFormula, l2Off, arrowColor, false,
                true, qNextPrefixSquare.length() > 1, 0.0f, sNextPrefix + JString(u"\u00B2"), hintColor,
                false, false, sNextPrefix.length() + 1, qNextPrefixSquare.length()));

        Step* step1 = makeStep(
                context.getString(10119),
                sNextPrefix + JString(u" \u00D7 ") + sNextPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + qNextPrefixSquare,
                sNextPrefixSquare,
                arrows1
        );
        step1->transparentOffsets.add(0);
        steps.add(step1);

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2Off, l3Off, arrowColor, false,
                sNextPrefixSquare.length() > 1, qNextPrefixSquareTimesTen.length() > 1, 0.0f,
                JString(u"\u00D7"), hintColor, false, false,
                sNextPrefixSquare.length(), qNextPrefixSquareTimesTen.length()));
        arrows2.add(makeArrow(tenInFormula, l3Off, arrowColor, false,
                true, qNextPrefixSquareTimesTen.length() > 1, 2.0f, nullptr, 0, false, false,
                2, qNextPrefixSquareTimesTen.length()));

        Step* step2 = makeStep(
                context.getString(10099),
                sNextPrefixSquare + JString(u" \u00D7 10 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + sNextPrefixSquare + JString(u"\n") + qNextPrefixSquareTimesTen,
                sNextPrefixSquareTimesTen,
                arrows2
        );
        step2->transparentOffsets.add(0);
        steps.add(step2);

        JList<Arrow*> arrows3 = cloneAndDim(arrows2);
        arrows3.add(makeArrow(l3Off, l4Off, arrowColor, false,
                sNextPrefixSquareTimesTen.length() > 1, qBeforeSuffix.length() > 1, 0.0f,
                JString(u"-"), hintColor, false, false,
                sNextPrefixSquareTimesTen.length(), qBeforeSuffix.length()));
        arrows3.add(makeArrow(secondPrefixInFormula, l4Off, arrowColor, false,
                true, qBeforeSuffix.length() > 1, -2.5f, nullptr, 0, false, false,
                sNextPrefix.length(), qBeforeSuffix.length()));

        Step* step3 = makeStep(
                context.getString(10172),
                sNextPrefixSquareTimesTen + JString(u" - ") + sNextPrefix + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + sNextPrefixSquare + JString(u"\n") + sNextPrefixSquareTimesTen + JString(u"\n") + qBeforeSuffix,
                sBeforeSuffix,
                arrows3
        );
        step3->transparentOffsets.add(0);
        steps.add(step3);

        JList<Arrow*> arrows4 = cloneAndDim(arrows3);
        arrows4.add(makeArrow(suffixSquareInFormula, l4Off + sBeforeSuffix.length(), arrowColor, false,
                true, true, -2.2f, JString(u"025"), hintColor, true, false,
                3, qSuffix.length()));

        Step* step4 = makeStep(
                context.getString(10158),
                JString(u"025"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + sNextPrefixSquare + JString(u"\n") + sNextPrefixSquareTimesTen + JString(u"\n") + sBeforeSuffix + qSuffix,
                JString(u"025"),
                arrows4
        );
        step4->transparentOffsets.add(0);
        steps.add(step4);

        JList<Arrow*> arrowsFinal = cloneArrows(arrows4, false);
        Step* finalStep = makeStep(
                context.getString(10073, finalResult),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sNextPrefixSquare + JString(u"\n") + sNextPrefixSquareTimesTen + JString(u"\n") + sFinalResult,
                JString(u""),
                arrowsFinal
        );
        finalStep->transparentOffsets.add(0);
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsForSquareEndingIn95(JContext context, int32_t operand1, int32_t operand2) {
        return getStepsForSquareEndingIn95(context, operand1);
    }

    JList<Step*> getStepsForPercentTip1(JContext context, int32_t op1, int32_t op2) {
        if (op1 <= 0) op1 = 15;
        if (op2 <= 0) op2 = 300;
        if (op1 % 5 != 0) {
            return getStepsForPercentSingleOperation(context, op1, op2);
        }
        if (op1 == 10) {
            return getStepsForTenPercentTip(context, op2);
        }

        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t tensCount = op1 / 10;
        int32_t tensPercent = tensCount * 10;
        bool hasTens = tensCount > 0;
        bool hasFive = op1 % 10 == 5;

        JString sPercent = JString::valueOf(op1);
        JString sOperand = JString::valueOf(op2);
        JString sTensCount = JString::valueOf(tensCount);
        JString sTensPercent = tensPercent + JString(u"");
        JString sTen = formatPercentResult((int64_t) op2 * 10);
        JString sTens = formatPercentResult((int64_t) op2 * tensPercent);
        JString sFive = formatPercentResult((int64_t) op2 * 5);
        int64_t finalScaled = (int64_t) op1 * op2;
        JString sFinal = formatPercentResult(finalScaled);
        JString qTens = getQuestionMarks(JMath::max(2, getQuestionMarksForAnswer(sTens).length()));
        JString qFive = getQuestionMarks(JMath::max(2, getQuestionMarksForAnswer(sFive).length()));
        JString firstResult = sTens + getSpaces(JMath::max(0, qTens.length() - sTens.length()));
        JString setupDescription = hasFive && hasTens
                ? context.getString(10179, op1, tensPercent, op2)
                : context.getString(10180, op2);

        JString line0 = sPercent + JString(u"% → ") + sOperand;
        JString split = nullptr;
        if (hasFive) {
            split = hasTens ? JString(u"(10×") + sTensCount + JString(u"+10÷2)") : JString(u"(10÷2)");
        }
        JString tenPart = sTen;
        JString line1 = split == nullptr ? tenPart : split + getSpaces(2) + tenPart;
        JString setup = line0 + JString(u"\n") + line1;
        int32_t tenOffset = line0.length() + 1 + line1.lastIndexOf(sTen);
        int32_t resultsOffset = setup.length() + 2;
        bool isTensMultiplierZeroStep = hasFive && tensCount == 1;

        
        
        JList<Arrow*> introArrows = {};
        if (split != nullptr) {
            int32_t splitOffset = line0.length() + 1;
            JString splitLabel = hasTens && hasFive
                    ? sTensPercent + JString(u"%+5%") : JString(u"10%÷2");
            int32_t splitTarget = hasTens && hasFive ? split.indexOf(u'+') : split.indexOf(u'÷');
            introArrows.add(makeArrow(0, splitOffset + splitTarget,
                    arrowColor, true, sPercent.length() > 1, false, 0.0f, splitLabel, hintColor,
                    true, true, sPercent.length(), 1));
        }
        introArrows.add(makeArrow(line0.lastIndexOf(sOperand), tenOffset, arrowColor, true,
                sOperand.length() > 1, sTen.length() > 1, 0.0f, JString(u"10%"), hintColor,
                true, true, sOperand.length(), sTen.length()));
        if (isTensMultiplierZeroStep) {
            int32_t multiplierOffset = line0.length() + 1 + split.indexOf(u'×') + 1;
            introArrows.add(makeArrow(tenOffset, resultsOffset, arrowColor, true,
                    sTen.length() > 1, sTens.length() > 1, 0.0f, JString(u"×"), hintColor,
                    false, false, sTen.length(), sTens.length()));
            introArrows.add(makeArrow(multiplierOffset, resultsOffset, arrowColor, true,
                    false, sTens.length() > 1, 0.0f, nullptr, 0,
                    false, false, sTensCount.length(), sTens.length()));
        }

        JList<Arrow*> currentArrows = cloneArrows(introArrows, true);
        JString finalEquation = setup;
        if (hasTens && !isTensMultiplierZeroStep) {
            int32_t multiplierOffset = split != nullptr
                    ? line0.length() + 1 + split.indexOf(u'×') + 1 : 0;
            JList<Arrow*> multiplyArrows = cloneAndDim(currentArrows);
            multiplyArrows.add(makeArrow(tenOffset, resultsOffset, arrowColor, false,
                    sTen.length() > 1, sTens.length() > 1, 0.0f, JString(u"×"), hintColor,
                    false, false, sTen.length(), sTens.length()));
            multiplyArrows.add(makeArrow(multiplierOffset, resultsOffset, arrowColor, false,
                    sTensCount.length() > 1, sTens.length() > 1, 0.0f, nullptr, 0,
                    false, false, sTensCount.length(), sTens.length()));
            steps.add(makeStep(
                    setupDescription + JString(u"\n\n")
                            + context.getString(10178, tensPercent, tensCount),
                    sTen + JString(u" × ") + sTensCount + JString(u" = ?"),
                    setup + JString(u"\n\n") + qTens + (hasFive ? JString(u" + ") + qFive : JString(u"")), sTens, multiplyArrows));
            currentArrows = multiplyArrows;
            finalEquation = setup + JString(u"\n\n") + firstResult;
        } else if (!hasFive) {
            JList<Arrow*> multiplyArrows = cloneAndDim(currentArrows);
            multiplyArrows.add(makeArrow(tenOffset, resultsOffset, arrowColor, false,
                    sTen.length() > 1, sTens.length() > 1, 0.0f, JString(u"×"), hintColor,
                    false, false, sTen.length(), sTens.length()));
            multiplyArrows.add(makeArrow(0, resultsOffset, arrowColor, false,
                    false, sTens.length() > 1, 0.0f, nullptr, 0,
                    false, false, sTensCount.length(), sTens.length()));
            steps.add(makeStep(
                    setupDescription + JString(u"\n\n")
                            + context.getString(10178, tensPercent, tensCount),
                    sTen + JString(u" × ") + sTensCount + JString(u" = ?"),
                    setup + JString(u"\n\n") + qTens, sTens, multiplyArrows));
            currentArrows = multiplyArrows;
            finalEquation = setup + JString(u"\n\n") + firstResult;
        }

        if (hasFive) {
            JString firstPart = hasTens ? firstResult + JString(u" + ") : JString(u"");
            int32_t fiveResultOffset = resultsOffset + firstPart.length();
            JList<Arrow*> halfArrows = cloneAndDim(currentArrows);
            halfArrows.add(makeArrow(tenOffset, fiveResultOffset, arrowColor, false,
                    sTen.length() > 1, sFive.length() > 1, 0.0f, JString(u"÷"), hintColor,
                    false, false, sTen.length(), sFive.length()));
            int32_t divisorOffset = line0.length() + 1 + split.lastIndexOf(u'2');
            halfArrows.add(makeArrow(divisorOffset, fiveResultOffset, arrowColor, false,
                    false, sFive.length() > 1, 0.0f, nullptr, 0,
                    false, false, 1, sFive.length()));
            steps.add(makeStep(
                    (tensCount <= 1 ? setupDescription + JString(u"\n\n") : JString(u""))
                            + context.getString(10177),
                    sTen + JString(u" ÷ 2 = ?"), setup + JString(u"\n\n") + firstPart + qFive, sFive, halfArrows));
            currentArrows = halfArrows;
            finalEquation = setup + JString(u"\n\n") + firstPart + sFive;

            if (hasTens) {
                JString sumPrefix = finalEquation + JString(u"\n");
                int32_t totalOffset = sumPrefix.length();
                JList<Arrow*> sumArrows = cloneAndDim(currentArrows);
                sumArrows.add(makeArrow(resultsOffset, totalOffset, arrowColor, false,
                        sTens.length() > 1, sFinal.length() > 1, 0.0f, JString(u"+"), hintColor,
                        false, false, sTens.length(), sFinal.length()));
                sumArrows.add(makeArrow(fiveResultOffset, totalOffset, arrowColor, false,
                        sFive.length() > 1, sFinal.length() > 1, 0.0f, nullptr, 0,
                        false, false, sFive.length(), sFinal.length()));
                steps.add(makeStep(
                        context.getString(10175, tensPercent, op1),
                        sTens + JString(u" + ") + sFive + JString(u" = ?"),
                        sumPrefix + getQuestionMarksForAnswer(sFinal), sFinal, sumArrows));
                currentArrows = sumArrows;
                finalEquation = sumPrefix + sFinal;
            }
        }

        Step* finalStep = makeStep(
                context.getString(10176, op1, op2, sFinal),
                nullptr, finalEquation, JString(u""), cloneArrows(currentArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForTenPercentTip(JContext context, int32_t operand) {
        JList<Step*> steps = {};
        JString expression = JString(u"10% → ") + operand;
        JString result = formatPercentResult((int64_t) operand * 10);
        int32_t resultOffset = expression.length() + 1;
        JList<Arrow*> arrows = {};
        arrows.add(makeArrow(expression.lastIndexOf(JString::valueOf(operand)), resultOffset,
                0xFF888888, false, JString::valueOf(operand).length() > 1,
                result.length() > 1, 0.0f, JString(u"÷"), 0xFF66BB00, false, false,
                JString::valueOf(operand).length(), result.length()));
        arrows.add(makeArrow(0, resultOffset, 0xFF888888, false,
                true, result.length() > 1, 0.0f, nullptr, 0, false, false,
                2, result.length()));

        steps.add(makeStep(
                context.getString(10180, operand),
                operand + JString(u" ÷ 10 = ?"),
                expression + JString(u"\n") + getQuestionMarksForAnswer(result),
                result, arrows));

        Step* finalStep = makeStep(
                context.getString(10176, 10, operand, result),
                nullptr, expression + JString(u"\n") + result, JString(u""), cloneArrows(arrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsFor15PercentTip(JContext context, int32_t operand) {
        return getStepsForPercentTip1(context, 15, operand);
    }

    JList<Step*> getStepsFor15Percent(JContext context, int32_t op1, int32_t op2) {
        int32_t operand = op1 == 15 ? op2 : (op2 == 15 ? op1 : op2);
        return getStepsFor15PercentTip(context, operand > 0 ? operand : 60);
    }

    JList<Step*> getStepsFor4Percent(JContext context, int32_t operand) {
        return getStepsForPercentTwoOperations(context, JString(u"4"), operand, JString(u"(100÷100×4)"),
                100, true, 4, false,
                10051, 10104);
    }

    JList<Step*> getStepsFor2Percent(JContext context, int32_t operand) {
        return getStepsForPercentTwoOperations(context, JString(u"2"), operand, JString(u"(100÷100×2)"),
                100, true, 2, false,
                10051, 10102);
    }

    JList<Step*> getStepsFor05Percent(JContext context, int32_t operand) {
        operand = JMath::max(1, operand);
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;

        float step1Arrow1Curve = -1.5f;
        float step1Arrow2Curve = 0.0f;
        float step2Arrow1Curve = 0.0f;
        float step2Arrow2Curve = 2.0f;

        int32_t splitStartOffset = -12;

        JString sOp = JString::valueOf(operand);
        JString line0 = JString(u"0.5% → ") + sOp;
        JString split05 = JString(u"(100÷100÷2)");

        JString line1;
        int32_t splitStartInLine1;
        if (splitStartOffset < 0) {
            line1 = split05 + getSpaces(-splitStartOffset);
            splitStartInLine1 = 0;
        } else {
            line1 = getSpaces(splitStartOffset) + split05;
            splitStartInLine1 = splitStartOffset;
        }

        double step1Val = (double) operand / 100.0;
        double finalVal = step1Val / 2.0;
        JString sStep1 = formatPercentStepValue(step1Val);
        JString sFinal = formatPercentStepValue(finalVal);

        int32_t line1Offset = line0.length() + 1;
        int32_t line2Offset = line1Offset + line1.length() + 1;

        int32_t percent05Index = line0.indexOf(JString(u"0.5"));
        int32_t operandIndex = line0.lastIndexOf(sOp);
        int32_t hundredInLine1 = line1Offset + splitStartInLine1 + split05.lastIndexOf(JString(u"100"));
        int32_t twoInLine1 = line1Offset + splitStartInLine1 + split05.lastIndexOf(JString(u"2"));

        bool operandIsMulti = sOp.length() > 1;
        bool step1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(percent05Index, hundredInLine1, arrowColor, true, true, true,
                0.0f, nullptr, 0, false, false, 3, 3));
        arrows1.add(makeArrow(operandIndex, line2Offset, arrowColor, false, operandIsMulti,
                step1IsMulti, step1Arrow1Curve, sOp + JString(u"÷100"), hintColor, false, false,
                sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(hundredInLine1, line2Offset, arrowColor, false, true,
                step1IsMulti, step1Arrow2Curve, nullptr, 0, false, false, 3, sStep1.length()));

        steps.add(makeStep(
                context.getString(10051),
                sOp + JString(u" ÷ 100 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + getQuestionMarksForAnswer(sStep1),
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t line3Offset = line2Offset + line2.length() + 1;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(line2Offset, line3Offset, arrowColor, false, step1IsMulti,
                finalIsMulti, step2Arrow1Curve, sStep1 + JString(u"÷2"), hintColor, false, false,
                sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(twoInLine1, line3Offset, arrowColor, false, false, finalIsMulti,
                step2Arrow2Curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" ÷ 2 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + getQuestionMarksForAnswer(sFinal),
                sFinal,
                arrows2
        ));

        Step* finalStep = makeStep(
                finalVal == (int64_t) finalVal
                        ? context.getString(10073, (int32_t) finalVal)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                cloneArrows(arrows2, false)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsFor150Percent(JContext context, int32_t operand) {
        operand = JMath::max(1, operand);
        JString sOperand = JString::valueOf(operand);
        JString half = formatPercentStepValue(operand / 2.0);
        JString result = formatPercentStepValue(operand + operand / 2.0);
        JString line0 = JString(u"150% → ") + sOperand;
        JString split = JString(u"(100×1+100÷2)");
        JString line1 = split + getSpaces(8);
        JString setup = line0 + JString(u"\n") + line1;
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        JList<Step*> steps = {};

        int32_t line1Offset = line0.length() + 1;
        int32_t oneOffset = line1Offset + split.indexOf(JString(u"×1")) + 1;
        int32_t twoOffset = line1Offset + split.lastIndexOf(u'2');
        int32_t operandOffset = line0.lastIndexOf(sOperand);
        int32_t resultsOffset = setup.length() + 2;
        int32_t halfResultOffset = resultsOffset + sOperand.length() + 3;

        JList<Arrow*> introArrows = {};
        introArrows.add(makeArrow(0, line1Offset + split.indexOf(u'+'), arrowColor, true,
                true, false, 0.0f, JString(u"100%+50%"), hintColor, true, true, 3, 1));
        introArrows.add(makeArrow(operandOffset, resultsOffset, arrowColor, true,
                sOperand.length() > 1, sOperand.length() > 1, -1.5f, JString(u"×"), hintColor,
                false, false, sOperand.length(), sOperand.length()));
        introArrows.add(makeArrow(oneOffset, resultsOffset, arrowColor, true,
                false, sOperand.length() > 1, 0.0f, nullptr, 0,
                false, false, 1, sOperand.length()));

        JList<Arrow*> halfArrows = cloneArrows(introArrows, true);
        halfArrows.add(makeArrow(operandOffset, halfResultOffset, arrowColor, false,
                sOperand.length() > 1, half.length() > 1, -1.5f, JString(u"÷"), hintColor,
                false, false, sOperand.length(), half.length()));
        halfArrows.add(makeArrow(twoOffset, halfResultOffset, arrowColor, false, false,
                half.length() > 1, 0.0f, nullptr, 0, false, false, 1, half.length()));
        JString firstPart = sOperand + JString(u" + ");
        JString halfEquation = setup + JString(u"\n\n") + firstPart + getQuestionMarksForAnswer(half);
        steps.add(makeStep(
                context.getString(10121, sOperand, 2),
                sOperand + JString(u" ÷ 2 = ?"),
                halfEquation,
                half,
                halfArrows
        ));

        JString sumPrefix = setup + JString(u"\n\n") + firstPart + half + JString(u"\n");
        int32_t totalOffset = sumPrefix.length();
        JList<Arrow*> sumArrows = cloneAndDim(halfArrows);
        sumArrows.add(makeArrow(resultsOffset, totalOffset, arrowColor, false,
                sOperand.length() > 1, result.length() > 1, 0.0f, JString(u"+"), hintColor,
                false, false, sOperand.length(), result.length()));
        sumArrows.add(makeArrow(halfResultOffset, totalOffset, arrowColor, false,
                half.length() > 1, result.length() > 1, 0.0f, nullptr, 0,
                false, false, half.length(), result.length()));
        steps.add(makeStep(
                context.getString(10120, sOperand, half),
                sOperand + JString(u" + ") + half + JString(u" = ?"),
                sumPrefix + getQuestionMarksForAnswer(result),
                result,
                sumArrows
        ));

        Step* finalStep = makeStep(context.getString(10122,
                JString(u"150"), operand, result), nullptr,
                sumPrefix + result, JString(u""), cloneArrows(sumArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsFor200Percent(JContext context, int32_t operand) {
        operand = JMath::max(1, operand);
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t splitStartOffset = -12;

        JString sOperand = JString::valueOf(operand);
        JString line0 = JString(u"200% → ") + sOperand;
        JString split200 = JString(u"(100×2)");
        JString line1 = splitStartOffset < 0
                ? split200 + getSpaces(-splitStartOffset)
                : getSpaces(splitStartOffset) + split200;
        int32_t splitStartInLine1 = JMath::max(0, splitStartOffset);

        double finalValue = operand * 2.0;
        JString sFinal = formatPercentStepValue(finalValue);

        int32_t line1Offset = line0.length() + 1;
        int32_t line2Offset = line1Offset + line1.length() + 1;
        int32_t percentOffset = line0.indexOf(JString(u"200"));
        int32_t operandOffset = line0.lastIndexOf(sOperand);
        int32_t twoOffset = line1Offset + splitStartInLine1 + split200.lastIndexOf(u'2');

        bool operandIsMulti = sOperand.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;
        JList<Arrow*> arrows = {};
        arrows.add(makeArrow(percentOffset, twoOffset, arrowColor, true, false, false,
                0.0f, nullptr, 0, false, false, 3, 1));
        arrows.add(makeArrow(operandOffset, line2Offset, arrowColor, false, operandIsMulti,
                finalIsMulti, -1.5f, sOperand + JString(u"×2"), hintColor, false, false,
                sOperand.length(), sFinal.length()));
        arrows.add(makeArrow(twoOffset, line2Offset, arrowColor, false, false, finalIsMulti,
                0.0f, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10091),
                sOperand + JString(u" × 2 = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + getQuestionMarksForAnswer(sFinal),
                sFinal,
                arrows
        ));

        Step* finalStep = makeStep(
                finalValue == (int64_t) finalValue
                        ? context.getString(10073, (int32_t) finalValue)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sFinal,
                JString(u""),
                cloneArrows(arrows, false)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsFor250Percent(JContext context, int32_t operand) {
        return getStepsForPercentOperations(context, JString(u"250"), operand, JString(u"(100÷4×10)"),
                JArray<int32_t> {4, 10}, JArray<bool> {true, false},
                JArray<int32_t> {10053, 10099});
    }

    JList<Step*> getStepsFor300Percent(JContext context, int32_t operand) {
        return getStepsForPercentOperations(context, JString(u"300"), operand, JString(u"(100×3)"),
                JArray<int32_t> {3}, JArray<bool> {false},
                JArray<int32_t> {10093});
    }

    JList<Step*> getStepsFor500Percent(JContext context, int32_t operand) {
        return getStepsForPercentOperations(context, JString(u"500"), operand, JString(u"(100÷2×10)"),
                JArray<int32_t> {2, 10}, JArray<bool> {true, false},
                JArray<int32_t> {10052, 10099});
    }

    JList<Step*> getStepsFor75Percent(JContext context, int32_t operand) {
        return getStepsForPercentTwoOperations(context, JString(u"75"), operand, JString(u"(100÷4×3)"),
                4, true, 3, false,
                10053, 10103);
    }

    JList<Step*> getStepsFor750Percent(JContext context, int32_t operand) {
        return getStepsForPercentOperations(context, JString(u"750"), operand, JString(u"(100÷4×3×10)"),
                JArray<int32_t> {4, 3, 10}, JArray<bool> {true, false, false},
                JArray<int32_t> {10053, 10103, 0});
    }

    JList<Step*> getStepsFor40Percent(JContext context, int32_t operand) {
        return getStepsForPercentTwoOperations(context, JString(u"40"), operand, JString(u"(100÷10×4)"),
                10, true, 4, false,
                10050, 10104);
    }

    JList<Step*> getStepsForFixedPercent(JContext context, JString percent, int32_t operand,
                                                       JArray<int32_t> factors, JArray<bool> divisions,
                                                       JArray<int32_t> stepDescriptionRes) {
        operand = JMath::max(1, operand);
        JString sOperand = JString::valueOf(operand);
        JString line0 = percent + JString(u"% → ") + sOperand;
        JStringBuilder operationLineBuilder = JStringBuilder(JString(u"(100"));
        JArray<int32_t> factorOffsets = JArray<int32_t>(factors.length);
        for (int32_t i = 0; i < factors.length; i++) {
            operationLineBuilder.append(divisions[i] ? u'÷' : u'×');
            factorOffsets[i] = operationLineBuilder.length();
            operationLineBuilder.append(factors[i]);
        }
        operationLineBuilder.append(u')');
        JString operationLine = operationLineBuilder.toString();
        int32_t operationLineOffset = line0.length() + 1;
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        JList<Step*> steps = {};
        JList<JString> values = {};
        values.add(sOperand);
        JList<Arrow*> currentArrows = {};
        currentArrows.add(makeArrow(line0.indexOf(percent), operationLineOffset + factorOffsets[0],
                arrowColor, true, false, false, 0.0f, nullptr, 0, false, false,
                percent.length(), JString::valueOf(factors[0]).length()));
        double current = operand;

        for (int32_t i = 0; i < factors.length; i++) {
            JString source = values.get(values.size() - 1);
            current = divisions[i] ? current / factors[i] : current * factors[i];
            JString next = formatPercentStepValue(current);
            JStringBuilder equation = JStringBuilder(line0).append(u'\n').append(operationLine).append(u'\n');
            int32_t sourceOffset;
            if (i == 0) {
                sourceOffset = line0.lastIndexOf(sOperand);
            } else {
                for (int32_t valueIndex = 0; valueIndex < values.size(); valueIndex++) {
                    if (valueIndex == values.size() - 1) sourceOffset = equation.length();
                    equation.append(values.get(valueIndex)).append(u'\n');
                }
                sourceOffset = equation.lastIndexOf(source);
            }
            int32_t resultOffset = equation.length();
            equation.append(getQuestionMarksForAnswer(next));

            JList<Arrow*> arrows = cloneAndDim(currentArrows);
            JString sign = divisions[i] ? JString(u"÷") : JString(u"×");
            arrows.add(makeArrow(sourceOffset, resultOffset, arrowColor, false,
                    source.length() > 1, next.length() > 1, 0.0f, sign + factors[i], hintColor,
                    false, false, source.length(), next.length()));
            arrows.add(makeArrow(operationLineOffset + factorOffsets[i], resultOffset, arrowColor, false,
                    JString::valueOf(factors[i]).length() > 1, next.length() > 1, 1.0f, nullptr, 0,
                    false, false, JString::valueOf(factors[i]).length(), next.length()));

            JString description = i < stepDescriptionRes.length
                    ? context.getString(stepDescriptionRes[i])
                    : (divisions[i]
                            ? context.getString(10121, source, factors[i])
                            : context.getString(10123, source, factors[i]));
            steps.add(makeStep(description, source + JString(u" ") + sign + JString(u" ") + factors[i] + JString(u" = ?"),
                    equation.toString(), next, arrows));
            values.add(next);
            currentArrows = arrows;
        }

        JStringBuilder finalEquation = JStringBuilder(line0).append(u'\n').append(operationLine);
        for (JString value : values) finalEquation.append(u'\n').append(value);
        JString result = values.get(values.size() - 1);
        Step* finalStep = makeStep(context.getString(10122,
                percent, operand, result), nullptr, finalEquation.toString(), JString(u""),
                cloneArrows(currentArrows, false));
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForPercentTwoOperations(JContext context, JString percent,
                                                               int32_t operand, JString split,
                                                               int32_t firstFactor, bool firstIsDivision,
                                                               int32_t secondFactor, bool secondIsDivision,
                                                               int32_t firstDescriptionRes,
                                                               int32_t secondDescriptionRes) {
        operand = JMath::max(1, operand);

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t splitStartOffset = -12;
        JList<Step*> steps = {};

        JString sOperand = JString::valueOf(operand);
        JString line0 = percent + JString(u"% → ") + sOperand;
        JString line1 = splitStartOffset < 0
                ? split + getSpaces(-splitStartOffset)
                : getSpaces(splitStartOffset) + split;
        int32_t splitStartInLine1 = JMath::max(0, splitStartOffset);

        double step1Value = firstIsDivision
                ? (double) operand / firstFactor
                : (double) operand * firstFactor;
        double finalValue = secondIsDivision
                ? step1Value / secondFactor
                : step1Value * secondFactor;
        JString sStep1 = formatPercentStepValue(step1Value);
        JString sFinal = formatPercentStepValue(finalValue);

        int32_t line1Offset = line0.length() + 1;
        int32_t line2Offset = line1Offset + line1.length() + 1;
        int32_t percentOffset = line0.indexOf(percent);
        int32_t operandOffset = line0.lastIndexOf(sOperand);
        int32_t firstFactorOffset = line1Offset + splitStartInLine1
                + split.lastIndexOf(JString::valueOf(firstFactor));
        int32_t secondFactorOffset = line1Offset + splitStartInLine1
                + split.lastIndexOf(JString::valueOf(secondFactor));

        bool operandIsMulti = sOperand.length() > 1;
        bool step1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;
        JString firstSign = firstIsDivision ? JString(u"÷") : JString(u"×");
        JString secondSign = secondIsDivision ? JString(u"÷") : JString(u"×");

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(percentOffset, firstFactorOffset, arrowColor, true, false, false,
                0.0f, nullptr, 0, false, false, percent.length(),
                JString::valueOf(firstFactor).length()));
        arrows1.add(makeArrow(operandOffset, line2Offset, arrowColor, false, operandIsMulti,
                step1IsMulti, -1.5f, sOperand + firstSign + firstFactor, hintColor, false, false,
                sOperand.length(), sStep1.length()));
        arrows1.add(makeArrow(firstFactorOffset, line2Offset, arrowColor, false,
                JString::valueOf(firstFactor).length() > 1, step1IsMulti, 0.0f, nullptr, 0,
                false, false, JString::valueOf(firstFactor).length(), sStep1.length()));

        steps.add(makeStep(
                context.getString(firstDescriptionRes),
                sOperand + JString(u" ") + firstSign + JString(u" ") + firstFactor + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + getQuestionMarksForAnswer(sStep1),
                sStep1,
                arrows1
        ));

        int32_t line3Offset = line2Offset + sStep1.length() + 1;
        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(line2Offset, line3Offset, arrowColor, false, step1IsMulti,
                finalIsMulti, 0.0f, sStep1 + secondSign + secondFactor, hintColor, false, false,
                sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(secondFactorOffset, line3Offset, arrowColor, false,
                JString::valueOf(secondFactor).length() > 1, finalIsMulti, 2.0f, nullptr, 0,
                false, false, JString::valueOf(secondFactor).length(), sFinal.length()));

        steps.add(makeStep(
                context.getString(secondDescriptionRes),
                sStep1 + JString(u" ") + secondSign + JString(u" ") + secondFactor + JString(u" = ?"),
                line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"\n")
                        + getQuestionMarksForAnswer(sFinal),
                sFinal,
                arrows2
        ));

        Step* finalStep = makeStep(
                finalValue == (int64_t) finalValue
                        ? context.getString(10073, (int32_t) finalValue)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sStep1 + JString(u"\n") + sFinal,
                JString(u""),
                cloneArrows(arrows2, false)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForPercentOperations(JContext context, JString percent,
                                                            int32_t operand, JString split,
                                                            JArray<int32_t> factors, JArray<bool> divisions,
                                                            JArray<int32_t> stepDescriptionRes) {
        operand = JMath::max(1, operand);

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t splitStartOffset = -12;
        JString sOperand = JString::valueOf(operand);
        JString line0 = percent + JString(u"% → ") + sOperand;
        JString line1 = splitStartOffset < 0
                ? split + getSpaces(-splitStartOffset)
                : getSpaces(splitStartOffset) + split;
        int32_t splitStartInLine1 = JMath::max(0, splitStartOffset);
        int32_t line1Offset = line0.length() + 1;
        int32_t resultLineOffset = line1Offset + line1.length() + 1;

        JArray<int32_t> factorOffsets = JArray<int32_t>(factors.length);
        int32_t factorIndex = 0;
        for (int32_t i = 0; i < split.length() && factorIndex < factors.length; i++) {
            char16_t c = split.charAt(i);
            if (c == u'÷' || c == u'×') {
                factorOffsets[factorIndex++] = line1Offset + splitStartInLine1 + i + 1;
            }
        }

        JList<JString> values = {};
        double currentValue = operand;
        for (int32_t i = 0; i < factors.length; i++) {
            currentValue = divisions[i] ? currentValue / factors[i] : currentValue * factors[i];
            values.add(formatPercentStepValue(currentValue));
        }

        JList<Arrow*> currentArrows = {};
        currentArrows.add(makeArrow(line0.indexOf(percent), factorOffsets[0], arrowColor, true,
                false, false, 0.0f, nullptr, 0, false, false, percent.length(),
                JString::valueOf(factors[0]).length()));
        JList<Step*> steps = {};

        for (int32_t i = 0; i < factors.length; i++) {
            JString source = i == 0 ? sOperand : values.get(i - 1);
            JString result = values.get(i);
            JString sign = divisions[i] ? JString(u"÷") : JString(u"×");
            JStringBuilder equation = JStringBuilder(line0).append(u'\n').append(line1).append(u'\n');
            int32_t sourceOffset;
            if (i == 0) {
                sourceOffset = line0.lastIndexOf(sOperand);
            } else {
                sourceOffset = -1;
                for (int32_t valueIndex = 0; valueIndex < i; valueIndex++) {
                    if (valueIndex == i - 1) sourceOffset = equation.length();
                    equation.append(values.get(valueIndex)).append(u'\n');
                }
            }
            int32_t resultOffset = equation.length();
            equation.append(getQuestionMarksForAnswer(result));

            JList<Arrow*> arrows = cloneAndDim(currentArrows);
            arrows.add(makeArrow(sourceOffset, resultOffset, arrowColor, false,
                    source.length() > 1, result.length() > 1, i == 0 ? -1.5f : 0.0f,
                    source + sign + factors[i], hintColor, false, false,
                    source.length(), result.length()));
            arrows.add(makeArrow(factorOffsets[i], resultOffset, arrowColor, false,
                    JString::valueOf(factors[i]).length() > 1, result.length() > 1,
                    i == 0 ? 0.0f : 2.0f, nullptr, 0, false, false,
                    JString::valueOf(factors[i]).length(), result.length()));

            JString description = stepDescriptionRes[i] != 0
                    ? context.getString(stepDescriptionRes[i])
                    : (divisions[i]
                            ? context.getString(10121, source, factors[i])
                            : context.getString(10123, source, factors[i]));
            steps.add(makeStep(
                    description,
                    source + JString(u" ") + sign + JString(u" ") + factors[i] + JString(u" = ?"),
                    equation.toString(),
                    result,
                    arrows
            ));
            currentArrows = arrows;
        }

        JStringBuilder finalEquation = JStringBuilder(line0).append(u'\n').append(line1);
        for (JString value : values) finalEquation.append(u'\n').append(value);
        JString finalResult = values.get(values.size() - 1);
        Step* finalStep = makeStep(
                currentValue == (int64_t) currentValue
                        ? context.getString(10073, (int32_t) currentValue)
                        : context.getString(10073, 0).replace(JString(u"0"), finalResult),
                nullptr,
                finalEquation.toString(),
                JString(u""),
                cloneArrows(currentArrows, false)
        );
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JString formatPercentStepValue(double value) {
        return JBigDecimal::valueOf(value).stripTrailingZeros().toPlainString();
    }

    JString formatPercentResult(int64_t hundredths) {
        return JBigDecimal::valueOf(hundredths, 2).stripTrailingZeros()
                .toPlainString();
    }

    JList<Step*> getStepsForPercentTip2(JContext context, int32_t op1, int32_t op2) {
        
        float INTRO_ARROW_1_CURVE = 0.0f; 
        float INTRO_ARROW_2_CURVE = 0.0f; 
        float STEP_1_ARROW_1_CURVE = 1.0f; 
        float STEP_1_ARROW_2_CURVE = 0.0f; 
        float STEP_2_ARROW_1_CURVE = 2.5f; 
        float STEP_2_ARROW_2_CURVE = 0.0f; 
        float STEP_3_ARROW_1_CURVE = 0.0f; 
        float STEP_3_ARROW_2_CURVE = 0.0f; 

        
        int32_t EXPRESSION_INDENT = 0; 
        int32_t SPLIT_INDENT = 10; 
        int32_t HUNDREDS_SPLIT_INDENT = 11; 
        int32_t RESULTS_INDENT = 0; 
        int32_t TOTAL_INDENT = 0; 

        if (op1 <= 0) op1 = 6;
        if (op2 <= 0) op2 = 350;
        int32_t remainder = op2 % 100;
        if (remainder != 0 && remainder != 50) {
            return getStepsForPercentSingleOperation(context, op1, op2);
        }

        JList<Step*> steps = {};
        int32_t arrowColor = 0xFF888888;
        int32_t hintColor = 0xFF66BB00;
        int32_t hundreds = op2 / 100;
        bool hasHalfHundred = remainder == 50;

        JString sPercent = JString::valueOf(op1);
        JString sOperand = JString::valueOf(op2);
        JString sHundreds = JString::valueOf(hundreds);
        JString expressionIndent = getSpaces(EXPRESSION_INDENT);
        JString splitIndent = getSpaces(SPLIT_INDENT);
        JString hundredsSplitIndent = getSpaces(HUNDREDS_SPLIT_INDENT);
        JString resultsIndent = getSpaces(RESULTS_INDENT);
        JString totalIndent = getSpaces(TOTAL_INDENT);
        JString line0 = expressionIndent + sPercent + JString(u"% → ") + sOperand;
        JString decomposition;
        JString hundredsSplit;
        int32_t line2Offset = 0;
        int32_t multiplierOffset;
        JList<Arrow*> introArrows = {};

        if (hasHalfHundred) {
            JString split = JString(u"(") + (hundreds * 100) + JString(u"+50)");
            hundredsSplit = JString(u"(100×") + sHundreds + JString(u"+100÷2)");
            JString line1 = splitIndent + split;
            JString line2 = hundredsSplitIndent + hundredsSplit;
            decomposition = line0 + JString(u"\n") + line1 + JString(u"\n") + line2;

            int32_t line1Offset = line0.length() + 1;
            line2Offset = line1Offset + line1.length() + 1;
            multiplierOffset = line2Offset + hundredsSplitIndent.length() + hundredsSplit.indexOf(JString(u"×")) + 1;
            int32_t splitAnchorOffset = line1Offset + splitIndent.length() + split.indexOf(u'+');

            introArrows.add(makeArrow(line0.lastIndexOf(sOperand), splitAnchorOffset,
                    arrowColor, true, true, false, INTRO_ARROW_1_CURVE, nullptr, 0, false, false,
                    sOperand.length(), 1));

            JString sFirstNum = JString::valueOf(hundreds * 100);
            int32_t num1Offset = line1Offset + splitIndent.length() + split.indexOf(sFirstNum);
            int32_t mulSignOffset = line2Offset + hundredsSplitIndent.length() + hundredsSplit.indexOf(JString(u"×"));
            introArrows.add(makeArrow(num1Offset, mulSignOffset, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false,
                    sFirstNum.length(), 1));

            JString sSecondNum = JString(u"50");
            int32_t num2Offset = line1Offset + splitIndent.length() + split.indexOf(JString(u"+50")) + 1;
            int32_t divSignOffset = line2Offset + hundredsSplitIndent.length() + hundredsSplit.indexOf(JString(u"÷"));
            introArrows.add(makeArrow(num2Offset, divSignOffset, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false,
                    sSecondNum.length(), 1));
        } else {
            hundredsSplit = JString(u"100×") + sHundreds;
            JString line1 = hundredsSplitIndent + hundredsSplit;
            decomposition = line0 + JString(u"\n") + line1;

            int32_t line1Offset = line0.length() + 1;
            int32_t mulSignOffset = line1Offset + hundredsSplitIndent.length() + hundredsSplit.indexOf(JString(u"×"));
            multiplierOffset = mulSignOffset + 1;

            introArrows.add(makeArrow(line0.lastIndexOf(sOperand), mulSignOffset,
                    arrowColor, true, true, false, INTRO_ARROW_1_CURVE, nullptr, 0, false, false,
                    sOperand.length(), 1));
        }

        int32_t percentOffset = expressionIndent.length();
        int32_t resultsOffset = decomposition.length() + 1 + resultsIndent.length();

        JString introDescription = hasHalfHundred
                ? context.getString(10184, op2, hundreds * 100)
                : context.getString(10182, op2, hundreds);

        JString sStep1 = JString::valueOf((int64_t) op1 * hundreds);
        JString sStep2 = op1 % 2 == 0 ? JString::valueOf(op1 / 2) : (op1 / 2) + JString(u",5");
        double finalValue = (double) op1 * op2 / 100.0;
        JString sFinal = finalValue == (int64_t) finalValue
                ? JString::valueOf((int64_t) finalValue) : JString::valueOf(finalValue).replace(u'.', u',');
        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString q2 = getQuestionMarksForAnswer(sStep2);
        JString firstResult = sStep1 + getSpaces(q1.length() - sStep1.length());
        JString firstEquation = decomposition + JString(u"\n") + resultsIndent + q1 + (hasHalfHundred ? JString(u" + ") + q2 : JString(u""));

        JList<Arrow*> arrows1 = cloneArrows(introArrows, true);
        arrows1.add(makeArrow(percentOffset, resultsOffset, arrowColor, false,
                sPercent.length() > 1, sStep1.length() > 1, STEP_1_ARROW_1_CURVE, JString(u"×"), hintColor,
                false, false, sPercent.length(), sStep1.length()));
        arrows1.add(makeArrow(multiplierOffset, resultsOffset, arrowColor, false,
                sHundreds.length() > 1, sStep1.length() > 1, STEP_1_ARROW_2_CURVE, nullptr, 0,
                false, false, sHundreds.length(), sStep1.length()));
        steps.add(makeStep(
                introDescription + JString(u"\n\n")
                        + context.getString(10183, op1, hundreds),
                sPercent + JString(u" × ") + sHundreds + JString(u" = ?"), firstEquation, sStep1, arrows1));

        JList<Arrow*> finalArrows = arrows1;
        JString finalEquation = decomposition + JString(u"\n") + resultsIndent + sFinal;
        if (hasHalfHundred) {
            int32_t secondResultOffset = resultsOffset + firstResult.length() + 3;
            int32_t divisorOffset = line2Offset + hundredsSplitIndent.length() + hundredsSplit.lastIndexOf(JString(u"2"));
            JList<Arrow*> arrows2 = cloneAndDim(arrows1);
            arrows2.add(makeArrow(percentOffset, secondResultOffset, arrowColor, false,
                    sPercent.length() > 1, sStep2.length() > 1, STEP_2_ARROW_1_CURVE, JString(u"÷"), hintColor,
                    false, false, sPercent.length(), sStep2.length()));
            arrows2.add(makeArrow(divisorOffset, secondResultOffset, arrowColor, false,
                    false, sStep2.length() > 1, STEP_2_ARROW_2_CURVE, nullptr, 0,
                    false, false, 1, sStep2.length()));
            steps.add(makeStep(
                    context.getString(10181, op1),
                    sPercent + JString(u" ÷ 2 = ?"),
                    decomposition + JString(u"\n") + resultsIndent + firstResult + JString(u" + ") + q2, sStep2, arrows2));

            JString filledResults = firstResult + JString(u" + ") + sStep2;
            int32_t totalOffset = resultsOffset + filledResults.length() + 1 + totalIndent.length();
            JList<Arrow*> arrows3 = cloneAndDim(arrows2);
            arrows3.add(makeArrow(resultsOffset, totalOffset, arrowColor, false,
                    sStep1.length() > 1, sFinal.length() > 1, STEP_3_ARROW_1_CURVE, JString(u"+"), hintColor,
                    false, false, sStep1.length(), sFinal.length()));
            arrows3.add(makeArrow(secondResultOffset, totalOffset, arrowColor, false,
                    sStep2.length() > 1, sFinal.length() > 1, STEP_3_ARROW_2_CURVE, nullptr, 0,
                    false, false, sStep2.length(), sFinal.length()));
            steps.add(makeStep(
                    context.getString(10010),
                    sStep1 + JString(u" + ") + sStep2 + JString(u" = ?"),
                    decomposition + JString(u"\n") + resultsIndent + filledResults
                            + JString(u"\n") + totalIndent + getQuestionMarksForAnswer(sFinal),
                    sFinal, arrows3));
            finalArrows = arrows3;
            finalEquation = decomposition + JString(u"\n") + resultsIndent + filledResults + JString(u"\n") + totalIndent + sFinal;
        }

        JList<Arrow*> arrowsFinal = cloneArrows(finalArrows, false);
        for (Arrow* a : arrowsFinal) {
            for (Arrow* intro : introArrows) {
                if (a->startOffset == intro->startOffset && a->endOffset == intro->endOffset) {
                    a->isDimmed = true;
                    break;
                }
            }
        }

        Step* finalStep = makeStep(
                finalValue == (int64_t) finalValue
                        ? context.getString(10073, (int32_t) finalValue)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr, finalEquation, JString(u""), arrowsFinal);
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsFor5Percent(JContext context, int32_t op1, int32_t op2) {
        int32_t operand = (op1 == 5) ? op2 : ((op2 == 5) ? op1 : op2);
        if (operand <= 0) operand = 60;
        return getStepsFor5Percent(context, operand);
    }

    JList<Step*> getStepsFor5Percent(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = -1.5f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = 2.0f;

        
        int32_t splitStartOffset = -12; 

        JString sOp = JString::valueOf(operand);
        JString line0 = JString(u"5% → ") + sOp;
        JString split5 = JString(u"(100\u00F710\u00F72)");

        JString line1;
        int32_t splitStartInLine1 = 0;
        if (splitStartOffset < 0) {
            line1 = split5 + getSpaces(-splitStartOffset);
            splitStartInLine1 = 0;
        } else {
            line1 = getSpaces(splitStartOffset) + split5;
            splitStartInLine1 = splitStartOffset;
        }

        double step1Val = (double) operand / 10.0;
        double finalVal = step1Val / 2.0;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val).replace(u'.', u',');
        JString sFinal = (finalVal == (int64_t) finalVal) ? JString::valueOf((int64_t) finalVal) : JString::valueOf(finalVal).replace(u'.', u',');

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op5Idx = line0.indexOf(JString(u"5"));
        int32_t opIdx = line0.lastIndexOf(sOp);
        int32_t tenInLine1 = l1_off + splitStartInLine1 + split5.lastIndexOf(JString(u"10"));
        int32_t twoInLine1 = l1_off + splitStartInLine1 + split5.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op5Idx, tenInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 1, 2));
        arrows1.add(makeArrow(opIdx, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00F710"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(tenInLine1, l2_off, arrowColor, false, true, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10050),
                sOp + JString(u" \u00F7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, finalIsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00F72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(twoInLine1, l3_off, arrowColor, false, false, finalIsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" \u00F7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                (finalVal == (int64_t) finalVal)
                        ? context.getString(10073, (int32_t) finalVal)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }

    JList<Step*> getStepsFor20Percent(JContext context, int32_t op1, int32_t op2) {
        int32_t operand = (op1 == 20) ? op2 : ((op2 == 20) ? op1 : op2);
        if (operand <= 0) operand = 255;
        return getStepsFor20Percent(context, operand);
    }

    JList<Step*> getStepsFor20Percent(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = -1.5f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = 2.0f;

        
        int32_t splitStartOffset = -12; 

        JString sOp = JString::valueOf(operand);
        JString line0 = JString(u"20% → ") + sOp;
        JString split20 = JString(u"(100\u00F710\u00D72)");

        JString line1;
        int32_t splitStartInLine1 = 0;
        if (splitStartOffset < 0) {
            line1 = split20 + getSpaces(-splitStartOffset);
            splitStartInLine1 = 0;
        } else {
            line1 = getSpaces(splitStartOffset) + split20;
            splitStartInLine1 = splitStartOffset;
        }

        double step1Val = (double) operand / 10.0;
        double finalVal = step1Val * 2.0;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val).replace(u'.', u',');
        JString sFinal = (finalVal == (int64_t) finalVal) ? JString::valueOf((int64_t) finalVal) : JString::valueOf(finalVal).replace(u'.', u',');

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op20Idx = line0.indexOf(JString(u"20"));
        int32_t opIdx = line0.lastIndexOf(sOp);
        int32_t tenInLine1 = l1_off + splitStartInLine1 + split20.lastIndexOf(JString(u"10"));
        int32_t twoInLine1 = l1_off + splitStartInLine1 + split20.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op20Idx, tenInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 2, 2));
        arrows1.add(makeArrow(opIdx, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00F710"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(tenInLine1, l2_off, arrowColor, false, true, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 2, sStep1.length()));

        steps.add(makeStep(
                context.getString(10050),
                sOp + JString(u" \u00F7 10 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, finalIsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00D72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(twoInLine1, l3_off, arrowColor, false, false, finalIsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10102),
                sStep1 + JString(u" \u00D7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                (finalVal == (int64_t) finalVal)
                        ? context.getString(10073, (int32_t) finalVal)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    JList<Step*> getStepsFor25Percent(JContext context, int32_t op1, int32_t op2) {
        int32_t operand = (op1 == 25) ? op2 : ((op2 == 25) ? op1 : op2);
        if (operand <= 0) operand = 64;
        return getStepsFor25Percent(context, operand);
    }

    JList<Step*> getStepsFor25Percent(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = -1.5f;
        float step1_arrow2_curve = 0.0f;

        float step2_arrow1_curve = 0.0f;
        float step2_arrow2_curve = 2.0f;

        
        int32_t splitStartOffset = -12; 

        JString sOp = JString::valueOf(operand);
        JString line0 = JString(u"25% → ") + sOp;
        JString split25 = JString(u"(100\u00F72\u00F72)");

        JString line1;
        int32_t splitStartInLine1 = 0;
        if (splitStartOffset < 0) {
            line1 = split25 + getSpaces(-splitStartOffset);
            splitStartInLine1 = 0;
        } else {
            line1 = getSpaces(splitStartOffset) + split25;
            splitStartInLine1 = splitStartOffset;
        }

        double step1Val = (double) operand / 2.0;
        double finalVal = step1Val / 2.0;

        JString sStep1 = (step1Val == (int64_t) step1Val) ? JString::valueOf((int64_t) step1Val) : JString::valueOf(step1Val).replace(u'.', u',');
        JString sFinal = (finalVal == (int64_t) finalVal) ? JString::valueOf((int64_t) finalVal) : JString::valueOf(finalVal).replace(u'.', u',');

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op25Idx = line0.indexOf(JString(u"25"));
        int32_t opIdx = line0.lastIndexOf(sOp);
        int32_t firstTwoInLine1 = l1_off + splitStartInLine1 + split25.indexOf(JString(u"2"));
        int32_t secondTwoInLine1 = l1_off + splitStartInLine1 + split25.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool s1IsMulti = sStep1.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarksForAnswer(sStep1);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op25Idx, firstTwoInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 2, 1));
        arrows1.add(makeArrow(opIdx, l2_off, arrowColor, false, opIsMulti, s1IsMulti, step1_arrow1_curve, sOp + JString(u"\u00F72"), hintColor, false, false, sOp.length(), sStep1.length()));
        arrows1.add(makeArrow(firstTwoInLine1, l2_off, arrowColor, false, false, s1IsMulti, step1_arrow2_curve, nullptr, 0, false, false, 1, sStep1.length()));

        steps.add(makeStep(
                context.getString(10052),
                sOp + JString(u" \u00F7 2 = ?"),
                eq1,
                sStep1,
                arrows1
        ));

        JString line2 = sStep1;
        int32_t l3_off = l2_off + line2.length() + 1;
        JString q2 = getQuestionMarksForAnswer(sFinal);
        JString eq2 = line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + q2;

        JList<Arrow*> arrows2 = cloneAndDim(arrows1);
        arrows2.add(makeArrow(l2_off, l3_off, arrowColor, false, s1IsMulti, finalIsMulti, step2_arrow1_curve, sStep1 + JString(u"\u00F72"), hintColor, false, false, sStep1.length(), sFinal.length()));
        arrows2.add(makeArrow(secondTwoInLine1, l3_off, arrowColor, false, false, finalIsMulti, step2_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10058),
                sStep1 + JString(u" \u00F7 2 = ?"),
                eq2,
                sFinal,
                arrows2
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows2, false);
        Step* finalStep = makeStep(
                (finalVal == (int64_t) finalVal)
                        ? context.getString(10073, (int32_t) finalVal)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + line2 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    JList<Step*> getStepsFor50Percent(JContext context, int32_t op1, int32_t op2) {
        int32_t operand = (op1 == 50) ? op2 : ((op2 == 50) ? op1 : op2);
        if (operand <= 0) operand = 64;
        return getStepsFor50Percent(context, operand);
    }

    JList<Step*> getStepsFor50Percent(JContext context, int32_t operand) {
        JList<Step*> steps = {};

        int32_t arrowColor = 0xFF888888;
        int32_t hintColor  = 0xFF66BB00;

        float step1_arrow1_curve = -0.0f;
        float step1_arrow2_curve = 0.0f;

        
        int32_t splitStartOffset = -8; 

        JString sOp = JString::valueOf(operand);
        JString line0 = JString(u"50% → ") + sOp;
        JString split50 = JString(u"(100\u00F72)");

        JString line1;
        int32_t splitStartInLine1 = 0;
        if (splitStartOffset < 0) {
            line1 = split50 + getSpaces(-splitStartOffset);
            splitStartInLine1 = 0;
        } else {
            line1 = getSpaces(splitStartOffset) + split50;
            splitStartInLine1 = splitStartOffset;
        }

        double finalVal = (double) operand / 2.0;
        JString sFinal = (finalVal == (int64_t) finalVal) ? JString::valueOf((int64_t) finalVal) : JString::valueOf(finalVal).replace(u'.', u',');

        int32_t l1_off = line0.length() + 1;
        int32_t l2_off = l1_off + line1.length() + 1;

        int32_t op50Idx = line0.indexOf(JString(u"50"));
        int32_t opIdx = line0.lastIndexOf(sOp);
        int32_t divisionSignInLine1 = l1_off + splitStartInLine1 + split50.indexOf(JString(u"\u00F7"));
        int32_t twoInLine1 = l1_off + splitStartInLine1 + split50.lastIndexOf(JString(u"2"));

        bool opIsMulti = sOp.length() > 1;
        bool finalIsMulti = sFinal.length() > 1;

        JString q1 = getQuestionMarksForAnswer(sFinal);
        JString eq1 = line0 + JString(u"\n") + line1 + JString(u"\n") + q1;

        JList<Arrow*> arrows1 = {};
        arrows1.add(makeArrow(op50Idx, divisionSignInLine1, arrowColor, true, false, false, 0.0f, nullptr, 0, false, false, 2, 1));
        arrows1.add(makeArrow(opIdx, l2_off, arrowColor, false, opIsMulti, finalIsMulti, step1_arrow1_curve, sOp + JString(u"\u00F72"), hintColor, false, false, sOp.length(), sFinal.length()));
        arrows1.add(makeArrow(twoInLine1, l2_off, arrowColor, false, false, finalIsMulti, step1_arrow2_curve, nullptr, 0, false, false, 1, sFinal.length()));

        steps.add(makeStep(
                context.getString(10052),
                sOp + JString(u" \u00F7 2 = ?"),
                eq1,
                sFinal,
                arrows1
        ));

        JList<Arrow*> arrowsFinal = cloneArrows(arrows1, false);
        Step* finalStep = makeStep(
                (finalVal == (int64_t) finalVal)
                        ? context.getString(10073, (int32_t) finalVal)
                        : context.getString(10073, 0).replace(JString(u"0"), sFinal),
                nullptr,
                line0 + JString(u"\n") + line1 + JString(u"\n") + sFinal,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }


    JList<Step*> getStepsForPercentSingleOperation(JContext context, int32_t op1, int32_t op2) {
        if (op1 <= 0) op1 = 1;
        if (op2 <= 0) op2 = 1;
        JList<Step*> steps = {};
        JString expression = op1 + JString(u"% → ") + op2;
        double rawAnswer = (double) op1 * op2 / 100.0;
        JString sAnswer = (rawAnswer == (int32_t) rawAnswer)
                ? JString::valueOf((int32_t) rawAnswer)
                : JString::valueOf(rawAnswer).replace(u'.', u',');
        int32_t intAnswer = (int32_t) JMath::round(rawAnswer);

        JStringBuilder qMarks = JStringBuilder();
        for (int32_t i = 0; i < sAnswer.length(); i++) {
            char16_t c = sAnswer.charAt(i);
            if (JCharacter::isDigit(c)) {
                qMarks.append(u'?');
            } else {
                qMarks.append(c);
            }
        }

        steps.add(makeStep(context.getString(10000), expression + JString(u" = ?"),
                expression + JString(u"\n") + qMarks, sAnswer, {}));

        Step* finalStep = makeStep(context.getString(10073, intAnswer), nullptr,
                expression + JString(u"\n") + sAnswer, JString(u""), {});
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }


    JList<Step*> getStepsForSingleOperation(JContext context, int32_t op1, double op2,
                                                         JString sign, int32_t answer) {
        JList<Step*> steps = {};
        JString sOp2 = (op2 == (int32_t) op2) ? JString::valueOf((int32_t) op2) : JString::valueOf(op2).replace(u'.', u',');
        JString expression = op1 + sign + sOp2;
        JString equation = expression + JString(u"\n?");
        steps.add(makeStep(context.getString(10000), expression + JString(u" = ?"),
                equation, JString::valueOf(answer), {}));

        Step* finalStep = makeStep(context.getString(10073, answer), nullptr,
                expression + JString(u"\n") + answer, JString(u""), {});
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Step*> getStepsForSingleOperation(JContext context, int32_t op1, int32_t op2,
                                                         JString sign, int32_t answer) {
        JList<Step*> steps = {};
        JString expression = op1 + JString(u" ") + sign + JString(u" ") + op2;
        JString equation = expression + JString(u"\n?");
        steps.add(makeStep(context.getString(10000), expression + JString(u" = ?"),
                equation, JString::valueOf(answer), {}));

        Step* finalStep = makeStep(context.getString(10073, answer), nullptr,
                expression + JString(u"\n") + answer, JString(u""), {});
        finalStep->isFinal = true;
        steps.add(finalStep);
        return steps;
    }

    JList<Arrow*> cloneArrows(JList<Arrow*> source, bool forceDimValue) {
        JList<Arrow*> copy = {};
        for (Arrow* a : source) {
            bool dim = forceDimValue;
            if (a->noHead) dim = false; 
            Arrow* ca = makeArrow(a->startOffset, a->endOffset, a->color, dim, a->startGap, a->targetGap, a->curveAmount, a->label, a->labelColor, a->isSquareBox, a->alwaysShowLabel, a->noHead, a->startTokenLength, a->tokenLength);
            ca->isCarryFlight = a->isCarryFlight;
            ca->centerBetweenArrows = a->centerBetweenArrows;
            ca->drawDashedDivider = a->drawDashedDivider;
            ca->dividerOffset = a->dividerOffset;
            copy.add(ca);
        }
        return copy;
    }

    JList<Arrow*> cloneAndDim(JList<Arrow*> source) {
        return cloneArrows(source, true);
    }

    JString getQuestionMarksForAnswer(JString answer) {
        int32_t count = 0;
        for (int32_t i = 0; i < answer.length(); i++) {
            if (JCharacter::isDigit(answer.charAt(i))) {
                count++;
            }
        }
        return getQuestionMarks(count);
    }

    JString getQuestionMarks(int32_t length) {
        JStringBuilder sb = JStringBuilder();
        for (int32_t i = 0; i < length; i++) sb.append(JString(u"?"));
        return sb.toString();
    }

    JString getSpaces(int32_t count) {
        JStringBuilder sb = JStringBuilder();
        for (int32_t i = 0; i < count; i++) sb.append(u' ');
        return sb.toString();
    }


    JList<Step*> getStepsForColumnAddition(JContext context, int32_t op1, int32_t op2) {
        JList<Step*> steps = {};

        JString sOp1 = JString::valueOf(op1);
        JString sOp2 = JString::valueOf(op2);

        int32_t maxLen = JMath::max(sOp1.length(), sOp2.length());

        
        JString padOp1 = JString::format(JString(u"%") + maxLen + JString(u"s"), sOp1);
        JString padOp2 = JString::format(JString(u"%") + maxLen + JString(u"s"), sOp2);

        int32_t carry = 0;

        
        JArray<char16_t> carries = JArray<char16_t>(maxLen + 1); 
        JArray<char16_t> resultDigits = JArray<char16_t>(maxLen + 1); 

        for (int32_t i = 0; i < carries.length; i++) {
            carries[i] = u' ';
            resultDigits[i] = u'?';
        }

        int32_t arrowColor = 0xFF888888;
        int32_t lineStart = 2 * (maxLen + 3);
        int32_t lineEnd = lineStart + 2 + maxLen;
        Arrow* separator = makeArrow(lineStart, lineEnd, arrowColor, false, false, false, 0.0f, nullptr, 0, false, false, true, 0, 0);

        
        for (int32_t col = maxLen - 1; col >= 0; col--) {
            char16_t c1 = padOp1.charAt(col);
            char16_t c2 = padOp2.charAt(col);

            int32_t d1 = (c1 != u' ') ? JCharacter::getNumericValue(c1) : 0;
            int32_t d2 = (c2 != u' ') ? JCharacter::getNumericValue(c2) : 0;

            int32_t currentSum = d1 + d2 + carry;
            int32_t units = currentSum % 10;
            int32_t nextCarry = currentSum / 10;

            
            JString hintExpr;
            JString commonDesc = nullptr;
            JString columnName = (col == maxLen - 1)
                    ? context.getString(10026)
                    : context.getString(10027);

            if (c1 == u' ' || c2 == u' ') {
                int32_t digit = (c1 == u' ') ? d2 : d1;
                if (carry > 0) {
                    commonDesc = context.getString(10019, columnName);
                    hintExpr = digit + JString(u" + ") + carry + JString(u" = ?");
                } else {
                    commonDesc = context.getString(10024);
                    hintExpr = digit + JString(u" = ?");
                }
            } else {
                if (carry > 0) {
                    hintExpr = d1 + JString(u" + ") + d2 + JString(u" + ") + carry + JString(u" = ?");
                } else {
                    hintExpr = d1 + JString(u" + ") + d2 + JString(u" = ?");
                }
            }

            if (currentSum < 10) {
                
                
                
                resultDigits[col + 1] = u'?'; 

                JString eqState = buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+"));

                JList<Arrow*> arrows = {};
                arrows.add(separator);

                Step* step = makeStep(
                        commonDesc != nullptr ? commonDesc : context.getString(10020, columnName),
                        hintExpr,
                        eqState,
                        JString::valueOf(units),
                        arrows
                );
                
                step->pulseIndex = getResultQuestionMarkIndex(eqState, col + 1);
                steps.add(step);

                
                resultDigits[col + 1] = JCharacter::forDigit(units, 10);
                carry = 0;

            } else {
                
                
                

                
                resultDigits[col + 1] = u'?';
                JString eqStateUnits = buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+"));

                JList<Arrow*> arrowsUnits = {};
                arrowsUnits.add(separator);

                Step* stepUnits = makeStep(
                        commonDesc != nullptr ? commonDesc : context.getString(10022, columnName),
                        hintExpr,
                        eqStateUnits,
                        JString::valueOf(units),
                        arrowsUnits
                );
                stepUnits->pulseIndex = getResultQuestionMarkIndex(eqStateUnits, col + 1);
                steps.add(stepUnits);

                
                resultDigits[col + 1] = JCharacter::forDigit(units, 10);

                
                carries[col] = u'?'; 
                JString eqStateCarry = buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+"));

                JList<Arrow*> arrowsCarry = {};
                arrowsCarry.add(separator);

                Step* stepCarry = makeStep(
                        context.getString(10028),
                        JString::valueOf(nextCarry),
                        eqStateCarry,
                        JString(u"1"),
                        arrowsCarry
                );
                stepCarry->pulseIndex = getCarryQuestionMarkIndex(eqStateCarry, col);
                steps.add(stepCarry);

                
                carries[col] = u'1';
                carry = nextCarry;
            }
        }
        
        if (carry > 0) {
            resultDigits[0] = u'?';
            JString eqStateFinalCarry = buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+"));

            JList<Arrow*> arrowsLastCarry = {};
            arrowsLastCarry.add(separator);

            Step* stepLastCarry = makeStep(
                    context.getString(10029),
                    context.getString(10025),
                    eqStateFinalCarry,
                    JString::valueOf(carry),
                    arrowsLastCarry
            );
            stepLastCarry->pulseIndex = getResultQuestionMarkIndex(eqStateFinalCarry, 0);
            steps.add(stepLastCarry);

            resultDigits[0] = JCharacter::forDigit(carry, 10);
        }
        
        
        
        int32_t finalSum = op1 + op2;
        JString finalGrid = buildEquationGrid(padOp1, padOp2, carries, resultDigits, JString(u"+"));

        JList<Arrow*> arrowsFinal = {};
        arrowsFinal.add(separator);

        Step* finalStep = makeStep(
                context.getString(10073, finalSum),
                nullptr,
                finalGrid,
                JString(u""),
                arrowsFinal
        );
        finalStep->isFinal = true;
        steps.add(finalStep);

        return steps;
    }
    JList<Step*> getStepsForColumnSubtraction(JContext context, int32_t op1, int32_t op2) {
        if (op1 < 0 || op2 < 0 || op1 < op2) {
            throw JavaArgumentError(JString(u"Column subtraction requires op1 >= op2 >= 0"));
        }
        JList<Step*> steps = {};
        JString first = JString::valueOf(op1);
        JString second = getSpaces(first.length() - JString::valueOf(op2).length()) + op2;
        int32_t size = first.length();
        JArray<int32_t> digits = JArray<int32_t>(size);
        JArray<bool> changed = JArray<bool>(size);
        JArray<JString> result = JArray<JString>(size);
        JArrays::fill(result, JString(u""));
        for (int32_t i = 0; i < size; i++) digits[i] = first.charAt(i) - u'0';
        JArray<JString> places = context.getResources().getStringArray(10005);

        for (int32_t col = size - 1; col >= 0; col--) {
            int32_t bottom = second.charAt(col) == u' ' ? 0 : second.charAt(col) - u'0';
            JString place = places[size - 1 - col];
            if (digits[col] < bottom) {
                int32_t donor = col - 1;
                while (donor >= 0 && digits[donor] == 0) donor--;
                
                
                JString reason = context.getString(10004,
                        place, digits[col], bottom);
                if (donor < col - 1) reason += JString(u" ") + context.getString(10001);
                for (int32_t source = donor; source < col; source++) {
                    int32_t before = digits[source];
                    digits[source]--;
                    digits[source + 1] += 10;
                    changed[source] = true;
                    changed[source + 1] = true;
                    JString description = (source == donor ? reason + JString(u"\n") : JString(u""))
                            + context.getString(10003,
                            places[size - 1 - source], places[size - 2 - source],
                            digits[source + 1]);
                    Step* exchange = buildSubtractionStep(description, before + JString(u" − 1 = ?"),
                            JString::valueOf(digits[source]), first, second, digits, changed,
                            result, source, true, false);
                    steps.add(exchange);
                }
            }

            JString description = context.getString(10008, place);
            if (col == size - 1) {
                description = context.getString(10006) + JString(u"\n") + description;
            }
            if (changed[col]) {
                description += JString(u" ") + context.getString(10007, digits[col]);
            }
            int32_t difference = digits[col] - bottom;
            result[col] = JString(u"?");
            steps.add(buildSubtractionStep(description, digits[col] + JString(u" − ") + bottom + JString(u" = ?"),
                    JString::valueOf(difference), first, second, digits, changed,
                    result, col, false, false));
            result[col] = JString::valueOf(difference);
        }

        
        for (int32_t i = 0; i < size - 1 && JString(u"0").equals(result[i]); i++) result[i] = JString(u"");
        steps.add(buildSubtractionStep(context.getString(10073, op1 - op2),
                context.getString(10002, op1 - op2, op2, op1),
                JString(u""), first, second, digits, changed, result, -1, false, true));
        return steps;
    }

    
    Step* buildSubtractionStep(JString description, JString hint, JString answer,
                                             JString first, JString second, JArray<int32_t> digits, JArray<bool> changed, JArray<JString> result,
                                             int32_t activeColumn, bool exchange, bool isFinal) {
        int32_t size = first.length();
        JStringBuilder grid = JStringBuilder();
        for (int32_t row = 0; row < 4; row++) {
            grid.append(row == 2 ? JString(u"− ") : JString(u"  "));
            for (int32_t col = 0; col < size; col++) {
                JString cell;
                if (row == 0) {
                    cell = exchange && col == activeColumn ? JString(u"?")
                            : changed[col] ? JString::valueOf(digits[col]) : JString(u"");
                } else if (row == 1) {
                    cell = first.substring(col, col + 1);
                } else if (row == 2) {
                    cell = second.substring(col, col + 1).trim();
                } else {
                    cell = result[col];
                }
                grid.append(getSpaces(3 - cell.length())).append(cell);
            }
            if (row < 3) grid.append(u'\n');
        }
        int32_t rowLength = 2 + 3 * size + 1;
        JList<Arrow*> arrows = {};
        arrows.add(makeArrow(2 * rowLength, 3 * rowLength - 1, 0xFF888888,
                false, false, false, 0.0f, nullptr, 0, false, false, true, 0, 0));
        Step* step = makeStep(description, hint, grid.toString(), answer, arrows);
        step->isFinal = isFinal;
        step->pulseIndex = step->equation.indexOf(u'?');
        for (int32_t col = 0; col < size; col++) {
            int32_t digitOffset = 4 + 3 * col;
            if (changed[col]) {
                step->crossedOutOffsets.add(rowLength + digitOffset);
                int32_t length = exchange && col == activeColumn ? 1 : JString::valueOf(digits[col]).length();
                step->highlightedRanges.add(JArray<int32_t> {digitOffset + 1 - length, digitOffset + 1});
            }
            if (col == activeColumn && !exchange) {
                if (!changed[col]) {
                    step->highlightedRanges.add(JArray<int32_t> {rowLength + digitOffset, rowLength + digitOffset + 1});
                }
                if (second.charAt(col) != u' ') {
                    step->highlightedRanges.add(JArray<int32_t> {2 * rowLength + digitOffset, 2 * rowLength + digitOffset + 1});
                }
            }
        }
        return step;
    }

    
    JString buildEquationGrid(JString op1, JString op2, JArray<char16_t> carries, JArray<char16_t> resultDigits, JString sign) {
        JStringBuilder sb = JStringBuilder();

        
        sb.append(JString(u" ")).append(JString(carries)).append(JString(u"\n"));

        
        sb.append(JString(u"  ")).append(op1).append(JString(u"\n"));

        
        sb.append(sign).append(JString(u" ")).append(op2).append(JString(u"\n"));

        
        sb.append(JString(u" ")).append(JString(resultDigits));

        return sb.toString();
    }
    int32_t getResultQuestionMarkIndex(JString grid, int32_t col) {
        int32_t lastLineStart = grid.lastIndexOf(u'\n') + 1;
        return lastLineStart + 1 + col;
    }
    int32_t getCarryQuestionMarkIndex(JString grid, int32_t col) {
        return 1 + col;
    }



};
