// Generated from Android Player.java and ResColors.java. Do not hand-edit.
// Regenerate with tools/import_boolean_solutions.py.
// Player source SHA-256: 105a838615787a1ea512ea5805e3145e37e9dcdb6f62838e46e576d6a35a5ce3
#pragma once
struct AndroidBooleanSolutionPort {
    int64_t op1 = 0, op2 = 0, answer = 0;
    int64_t temp1 = 0, temp2 = 0, temp3 = 0, temp4 = 0, temp5 = 0, temp6 = 0, temp7 = 0, temp8 = 0, temp9 = 0;
    float float1 = 0, float2 = 0;
    JString str1, solutionText;
    JString clRed = JString(u"992424");
    JString clGreen = JString(u"2E7D32");
    JString clBlue = JString(u"1565C0");
    JString clCyan = JString(u"00838F");
    JString clBlack = JString(u"ffffff");
    JString clWhite = JString(u"000000");
    JString clYellow = JString(u"797100");
    JString clMangeta = JString(u"924bd7");
    JString clOrange = JString(u"9e6202");
    JString clGreenLight = JString(u"089B00");
    JString clBrown = JString(u"773500");
    JString clViolet = JString(u"6A1B9A");
    JString clGreenYellow = JString(u"aed300");
    JString tagI(JString text) { return JString(u"<i>") + text + JString(u"</i>"); }
    JString tagBr() { return JString(u"<br>"); }
    JString tagStep(int64_t step) { return JString(u"<small><small>") + tagI(JString::valueOf(step)) + JString(u":</small></small>  "); }
    JString tagPower(int64_t value) { return JString(u"<sup><sup><small><small><small>") + value + JString(u"</small></small></small></sup></sup>"); }
    JString tagColor(JString text, JString color) { return JString(u"<font color=#") + color + JString(u">") + text + JString(u"</font>"); }
    JString tagNewExample(int64_t number) { return tagColor(JString(u"<u>-") + number + JString(u"-</u>"), clGreenLight); }
    JString trimFloat(float value) { JString result; result.assign([NSString stringWithFormat:@"%.7g", value]); return result; }
    JString getMultiplicationSign() { return JString(u"×"); }
    JString getDivisionSign() { return JString(u"÷"); }
    int64_t power(int64_t base, int64_t exponent) { int64_t result = base; for(int64_t i = 1; i < exponent; ++i) result *= base; return result; }
void trickAdditionSt()
    {
        solutionText = op1 + JString(u" + ") + op2 + JString(u" = ") + answer;

    }
    void trickSubtractionSt()
    {
        solutionText = op1 + JString(u" - ") + op2 + JString(u" = ") + answer;

    }
    void trickMultiplicationSt()
    {
        solutionText = op1 + JString(u" ") + getMultiplicationSign() + JString(u" ") + op2 + JString(u" = ") + answer;

    }
    void trickDivisionSt()
    {
        solutionText = op1 + JString(u" ") + getDivisionSign() + JString(u" ") + op2 + JString(u" = ") + answer;

    }
    void trickMultiplyBy11TwoDigitSt()
    {
        solutionText = JString(u"");

        if (op1 <= 99)
        {
            temp1 = op1/10;
            temp2 = op1%10;
            temp3 = temp1 + temp2;
            temp4 = op1;

            solutionText += tagNewExample(1);
            solutionText += tagBr();
            solutionText += tagBr();
            solutionText +=	tagColor(temp1 + JString(u""), clRed) + tagColor(temp2+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign()+ JString(u" ") + op2 + JString(u" = ") + answer;
            solutionText +=	tagBr();

            if (temp3 <= 9)
            {
                solutionText += tagBr() + tagStep(1) + tagColor(temp1 + JString(u""), clRed) + JString(u" + ") + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + tagColor(temp3 + JString(u""), clMangeta);
                solutionText += tagBr() + tagStep(2) + tagColor(temp1 + JString(u""), clRed) + JString(u"_") + tagColor(temp3 + JString(u""), clMangeta) + JString(u"_") + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + answer;
            }
            else
            {
                solutionText += tagBr() + tagStep(1) + tagColor(temp1 + JString(u""), clRed) + JString(u" + ") + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + tagColor(temp3 / 10 + JString(u""), clGreen) + tagColor(temp3 % 10 + JString(u""), clMangeta);
                solutionText += tagBr() + tagStep(2) + tagColor(temp1 + JString(u""), clRed) + JString(u" + ") + tagColor(JString(u"1"), clGreen) + JString(u" = ") + tagColor((temp1 + 1) + JString(u""), clYellow); ++temp1;
                solutionText += tagBr() + tagStep(3) + tagColor(temp1 + JString(u""), clYellow) + JString(u"_") + tagColor(temp3 % 10 + JString(u""), clMangeta) + JString(u"_") + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + answer;
            }

            solutionText += tagBr();
            solutionText += tagBr();
            solutionText += tagNewExample(2);
            solutionText += tagBr();
            solutionText += tagBr();

        }

        temp1 = op1 * 10;
        temp2 = op1;

        solutionText += tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"11"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"11"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" + ") + tagColor(JString(u"1"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1 + JString(u""), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trickSquareNumbersEditingIn5St()
    {
        temp1 = op1/10;
        temp2 = op1%10;
        temp3 = temp1 * (temp1 + 1);

        solutionText = tagColor(temp1+JString(u""), clRed) + temp2 + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" (") + tagColor(temp1+JString(u""), clRed) + JString(u" + 1) = ") + tagColor(temp3+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp3+JString(u""), clBlue) + JString(u"_25 = ") + answer;

    }
    void trickMultiplyBy5St()
    {
        temp1 = op1;
        temp2 = op2;
        float1 = (float)temp1/2;

        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"5"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"5"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + (int64_t)(float1*10);

    }
    void trickMultiplyBy9St()
    {
        temp1 = op1;
        temp2 = op1 * 10;
        temp3 = temp2 - op1;

        solutionText = tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"9"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"9"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" - ") + tagColor(JString(u"1"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clRed);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp2 + JString(u""), clMangeta) + JString(u" - ") + tagColor(temp1 + JString(u""), clRed) + JString(u" = ") + temp3;

    }
    void trickMultiplyBy4St()
    {
        temp1 = op1;
        temp2 = temp1 * 2;
        temp3 = temp2 * 2;

        solutionText = tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"4"), clBlue) + JString(u" = ") + tagColor(JString(u"2"), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" = ") + tagColor(temp2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + temp3;

    }
    void trickDividingBy5St()
    {
        temp1 = op1;
        float1 = (float)temp1 / 10;
        temp2 = (int64_t)(float1 * 2);

        solutionText = tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"5"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"5"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + temp2;

    }
    void trickSubtracringFrom1000St()
    {
        if (op1 == 1000)
        {
            temp1 = op2 % 10;
            temp2 = (op2 / 10) % 10;
            temp3 = op2 / 100;

            solutionText = JString(u"1000") + JString(u" - ") + tagColor(temp3 + JString(u""), clRed) + tagColor(temp2 + JString(u""), clBlue) + tagColor(temp1 + JString(u""), clGreen) + JString(u" = ") + answer;
            solutionText += tagBr();
            solutionText += tagBr() + tagStep(1) + JString(u"9") + JString(u" - ") + tagColor(temp3 + JString(u""), clRed) + JString(u" = ") + tagColor((9 - temp3) + JString(u""), clCyan);
            solutionText += tagBr() + tagStep(2) + JString(u"9") + JString(u" - ") + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + tagColor((9 - temp2) + JString(u""), clYellow);
            solutionText += tagBr() + tagStep(3) + JString(u"10") + JString(u" - ") + tagColor(temp1 + JString(u""), clGreen) + JString(u" = ") + tagColor((10 - temp1) + JString(u""), clMangeta);
            solutionText += tagBr() + tagStep(4) + tagColor((9 - temp3) + JString(u""), clCyan) + JString(u"_") + tagColor((9 - temp2) + JString(u""), clYellow) + JString(u"_") + tagColor((10 - temp1) + JString(u""), clMangeta) + JString(u" = ") + answer;
        }
        else
            solutionText += tagBr() + op1 + JString(u" - ") + op2 + JString(u" = ") + answer;

    }
    void trickToughMultiplicationSt()
    {
        temp1 = JMath::min(op1, op2);
        temp2 = JMath::max(op1, op2);
        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + answer;
        int64_t step = 1;
        bool divideFirst = getToughMultiplicationFactor(temp1) != 0;
        if (!divideFirst && getToughMultiplicationFactor(temp2) == 0) {
            divideFirst = true;
        }

        bool canLoop = temp1 > 2;
        if (!divideFirst && (temp1 % 5 != 0 || temp2 % 2 != 0)) {
            canLoop = false;
        }

        while (canLoop) {
            int64_t factor = getToughMultiplicationFactor(divideFirst ? temp1 : temp2);
            if (factor == 0) break;
            int64_t next1 = divideFirst ? temp1 / factor : temp1 * factor;
            int64_t next2 = divideFirst ? temp2 * factor : temp2 / factor;
            if (!divideFirst && next1 > next2) {
                break;
            }
            temp1 = next1;
            temp2 = next2;
            solutionText += tagBr() + tagBr() + tagStep(step++)
                    + tagColor(temp1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ")
                    + tagColor(temp2 + JString(u""), clBlue);
            if (!divideFirst && (temp1 % 10 == 0 || temp1 >= temp2)) {
                break;
            }
        }

        solutionText += tagBr() + tagBr() + tagStep(step)
                + tagColor(temp1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ")
                + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + answer;
    }

    int64_t getToughMultiplicationFactor(int64_t value)
    {
        if (value > 10 && value % 10 == 0) return 10;
        if (value > 11 && value % 11 == 0) return 11;
        if (value > 3 && value % 3 == 0) return 3;
        if (value > 2 && value % 2 == 0) return 2;
        return 0;
    }
    void trickPowerOfTwoSt()
    {
        temp1 = op1;
        temp2 = op2;

        solutionText = temp1 + tagPower(temp2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        for (int64_t i = 1; i < temp2; i++)
            solutionText +=	tagBr() + tagStep(i) + temp1 + tagPower(i) + JString(u" = ") + (int64_t)JMath::pow(temp1, i);

        solutionText +=	tagBr();
        solutionText +=	tagBr()+ tagStep(temp2) + temp1 + tagPower(temp2) + JString(u" = ") + (int64_t)JMath::pow(temp1, temp2);

    }
    void trick_adding_numbers_close_to_hundredsSt()
    {
        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" + ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();


        if (op2/10%10 == 9)
        {
            temp3 = 10 - op2%10;
            temp2 = op2 + temp3;
            temp1 = op1 + temp2;

            solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp2+JString(u""), clGreen) + JString(u" - ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" + ") + tagColor(temp2+JString(u""), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp1 + JString(u""), clMangeta) + JString(u" - ") + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;

        }
        else
        {
            temp3 = op2%10;
            temp2 = op2 - temp3;
            temp1 = op1 + temp2;

            solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp2+JString(u""), clGreen) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" + ") + tagColor(temp2+JString(u""), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp1 + JString(u""), clMangeta) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;

        }

    }
    void trick_subtracting_numbers_close_to_hundredsSt()
    {
        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" - ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();


        if (op2/10%10 == 9)
        {
            temp3 = 10 - op2%10;
            temp2 = op2 + temp3;
            temp1 = op1 - temp2;

            solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp2+JString(u""), clGreen) + JString(u" - ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" - ") + tagColor(temp2+JString(u""), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;

        }
        else
        {
            temp3 = op2%10;
            temp2 = op2 - temp3;
            temp1 = op1 - temp2;

            solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp2+JString(u""), clGreen) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" - ") + tagColor(temp2+JString(u""), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" - ") + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;

        }
    }
    void trick_multiply_numbers_between_11_and_19_textSt()
    {
        temp1 = op1%10;
        temp2 = op2%10;
        temp3 = op1 + temp2;
        temp4 = temp1 * temp2;

        solutionText = JString(u"1") + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"1") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"1") + tagColor(temp1+JString(u""), clRed) + JString(u" + ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp3+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp3+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" 10 = ") + tagColor((temp3*10)+JString(u""), clCyan);
        temp3 *= 10;
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp4+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp3+JString(u""), clCyan) + JString(u" + ") + tagColor(temp4+JString(u""), clMangeta) + JString(u" = ") + answer;

    }
    void trick_square_number_between_11_and_99_textSt()
    {
        temp1 = op1;
        temp2 = 100 - temp1;
        temp3 = temp1 - temp2;
        temp4 = temp2 * temp2;

        solutionText = tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"100") + JString(u" - ") + tagColor(temp1 + JString(u""), clRed) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1 + JString(u""), clRed) + JString(u" - ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp3+JString(u""), clGreen);
        if (temp4 <= 9)
            str1 = JString(u"0");
        else
            str1 = JString(u"");
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2+JString(u""), clBlue) + tagPower(2) + JString(u" = ") + str1 + tagColor(temp4+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp3+JString(u""), clGreen) + JString(u"_") + str1 + tagColor(temp4+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_multiply_two_digit_numbers_having_same_tensSt()
    {
        temp1 = op1%10;
        temp2 = op2%10;
        temp3 = op1/10;
        temp4 = temp3 * (temp3 + 1);
        temp5 = temp1 * temp2;

        solutionText = tagColor(temp3 + JString(u""), clGreen) + tagColor(temp1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp3+JString(u""), clGreen) + tagColor(temp2 + JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp3+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" (") + tagColor(temp3+JString(u""), clGreen) + JString(u" + 1) = ") + tagColor(temp4+JString(u""), clYellow);
        if (temp5 <= 9)
            str1 = JString(u"0");
        else
            str1 = JString(u"");
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + str1 +tagColor(temp5+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp4+JString(u""), clYellow) + JString(u"_") + str1 + tagColor(temp5+JString(u""), clMangeta) + JString(u" = ") + answer;


    }
    void trick_square_number_between_50_and_59St()
    {
        temp1 = op1%10;
        temp2 = 25 + temp1;
        temp3 = temp1 * temp1;

        solutionText = JString(u"5") + tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"25") + JString(u" + ") + tagColor(temp1+JString(u""), clRed) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        if (temp3 <= 9)
            str1 = JString(u"0");
        else
            str1 = JString(u"");
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + str1 + tagColor(temp3+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2+JString(u""), clBlue) + JString(u"_") + str1 + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_square_number_between_40_and_49St()
    {
        temp1 = op1%10;
        temp2 = 50 - op1;
        temp3 = 25 - temp2;
        temp4 = temp2 * temp2;

        solutionText = tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"50") + JString(u" - ") + tagColor(op1 + JString(u""), clRed) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + JString(u"25 - ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp3+JString(u""), clGreen);
        if (temp4 <= 9)
            str1 = JString(u"0");
        else
            str1 = JString(u"");
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2+JString(u""), clBlue) + tagPower(2) + JString(u" = ") + str1 + tagColor(temp4+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp3+JString(u""), clGreen) + JString(u"_") + str1 + tagColor(temp4+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_multiply_two_digit_numbers_editing_in_1St()
    {
        temp1 = op1/10;
        temp2 = op2/10;
        temp3 = temp1 * temp2;
        temp4 = temp1 + temp2;

        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u"1") + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp2+JString(u""), clBlue) + JString(u"1") + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp3+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" + ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp4+JString(u""), clYellow);
        if (temp4 <= 9)
        {
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp3+JString(u""), clGreen) + JString(u"_") + tagColor(temp4+JString(u""), clYellow) + JString(u" = ") + tagColor(temp3+JString(u"")+temp4+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(4) + tagColor(temp3+JString(u"")+temp4+JString(u""), clMangeta) + JString(u"_") + JString(u"1") + JString(u" = ") + answer;
        }
        else
        {
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp3+JString(u""), clGreen) + JString(u" + ") + tagColor((temp4/10)+JString(u""), clYellow) + JString(u" = ") + tagColor((temp3 + 1)+JString(u""), clCyan); ++temp3;
            solutionText +=	tagBr() + tagStep(4) + tagColor(temp3+JString(u""), clCyan) + JString(u"_") + tagColor((temp4%10)+JString(u""), clYellow) + JString(u" = ") + tagColor(temp3+JString(u"")+temp4%10+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(5) + tagColor(temp3+JString(u"")+temp4%10+JString(u""), clMangeta) + JString(u"_") + JString(u"1") + JString(u" = ") + answer;
        }

    }
    void trick_percentSt()
    {
        temp1 = op1 / 10;
        temp2 = op1 % 10;

        temp3 = op2 / 10;
        temp4 = temp3 / 2;

        temp5 = temp3 * temp1;

        if (temp1 == 0)
        {
            solutionText = tagColor(temp2+JString(u""), clBlue) + JString(u"% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + answer;
            solutionText +=	tagBr();
            solutionText +=	tagBr() + tagStep(1) + JString(u"10% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + tagColor(op2+JString(u""), clGreen) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"10 = ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + JString(u" 5% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + tagColor(temp3+JString(u""), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"2 = ") + answer;
        }
        else
        if (temp2 == 0)
        {
            solutionText = tagColor(temp1+JString(u""), clRed) + JString(u"0% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + answer;
            solutionText +=	tagBr();
            solutionText +=	tagBr() + tagStep(1) + JString(u"10% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + tagColor(op2+JString(u""), clGreen) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"10 = ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;
        }
        else
        {
            solutionText = tagColor(temp1+JString(u""), clRed) + tagColor(temp2+JString(u""), clBlue) + JString(u"% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + answer;
            solutionText +=	tagBr();
            solutionText +=	tagBr() + tagStep(1) + JString(u"10% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + tagColor(op2+JString(u""), clGreen) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"10 = ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + JString(u" 5% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + tagColor(temp3+JString(u""), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"2 = ") + tagColor(temp4+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + tagColor(temp5+JString(u""), clCyan);
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp5+JString(u""), clCyan) + JString(u" + ") + tagColor(temp4+JString(u""), clMangeta) + JString(u" = ") + answer;
        }

    }
    void trick_square_number_between_100_and_109St()
    {
        temp1 = op1%10;
        temp2 = op1 + temp1;
        temp3 = temp1 * temp1;


        solutionText = JString(u"10") + tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"10") + tagColor(temp1+JString(u""), clRed) + JString(u" + ") + tagColor(temp1+JString(u""), clRed) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        if (temp3 <= 9)
            str1 = JString(u"0");
        else
            str1 = JString(u"");
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + str1 + tagColor(temp3+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2 + JString(u""), clBlue) + JString(u"_") + str1 + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_square_rootSt()
    {
        solutionText = tagPower(op2) + JString(u"√") + op1 + JString(u" = ") + answer;

    }
    void trick_percent_2St()
    {
        temp1 = op2 / 100;
        temp2 = (op2 / 10)%10;

        temp3 = op1 * temp1;
        temp4 = op1 / 2;

        if (temp2 == 0)
        {
            solutionText = tagColor(op1+JString(u""), clRed) + JString(u"% → ") + tagColor(temp1+JString(u""), clBlue) + JString(u"00") + JString(u" = ") + answer;
            solutionText +=	tagBr();
            solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp1+JString(u""), clBlue) + JString(u" = ") + answer;
        }
        else
        {
            solutionText = tagColor(op1+JString(u""), clRed) + JString(u"% → ") + tagColor(temp1+JString(u""), clBlue) + tagColor(JString(u"50"), clGreen) + JString(u" = ") + answer;
            solutionText +=	tagBr();
            solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp1+JString(u""), clBlue) + JString(u" = ") + tagColor(temp3+JString(u""), clYellow);
            solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"50"), clGreen) + JString(u" = ") + JString(u"100") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
            solutionText +=	tagBr() + tagStep(3) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + tagColor(temp4+JString(u""), clMangeta);
            solutionText +=	tagBr() + tagStep(3) + tagColor(temp3+JString(u""), clYellow) + JString(u" + ") + tagColor(temp4+JString(u""), clMangeta) + JString(u" = ") + answer;
        }

    }
    void trickMultiplyBy15St()
    {
        temp1 = op1 * 10;
        temp2 = temp1 / 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"15"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"15"), clMangeta) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" + (") + tagColor(JString(u"10"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u")");
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + tagColor(temp2+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1 + JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clGreen) + JString(u" = ") + answer;

    }
    void trickMultiplyBy20St()
    {
        temp1 = op1 * 2;
        temp2 = temp1 * 10;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"20"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"20"), clMangeta) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + tagColor(temp1+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + answer;

    }
    void trickDividingBy4St()
    {
        temp1 = op1 / 2;
        temp2 = temp1 / 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"4"), clMangeta) + JString(u" = ") + tagColor(JString(u"2"), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + answer;

    }
    void trickDividingBy20St()
    {
        temp1 = op1 / 10;
        temp2 = temp1 / 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"20"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"20"), clMangeta) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + answer;

    }
    void trickDividingBy50St()
    {
        float1 = (float)op1 / 100;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"50"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"50"), clMangeta) + JString(u" = ") + tagColor(JString(u"100"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + answer;

    }
    void trickDividingBy25St()
    {
        float1 = (float)op1 / 100;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"25"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"25"), clMangeta) + JString(u" = ") + tagColor(JString(u"100"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clCyan) + JString(u" = ") + answer;

    }
    void trick_square_number_between_10_and_19St()
    {
        temp1 = op1%10;
        temp2 = op1 + temp1;
        temp3 = temp1 * temp1;

        solutionText = JString(u"1") + tagColor(temp1 + JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"1") + tagColor(temp1 + JString(u""), clRed) + JString(u" + ") + tagColor(temp1+JString(u""), clRed) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp2 + JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" 10 = ") + tagColor((temp2*10)+JString(u""), clGreen);
        temp2 *= 10;
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(temp1+JString(u""), clRed) + JString(u" = ") + tagColor(temp3+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp2 + JString(u""), clGreen) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trickMultiplyBy99St()
    {
        temp1 = op1;
        temp2 = op1 * 100;
        temp3 = temp2 - op1;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"99"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"99"), clBlue) + JString(u" = ") + tagColor(JString(u"100"), clYellow) + JString(u" - ") + tagColor(JString(u"1"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(temp2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clRed);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp2+JString(u""), clMangeta) + JString(u" - ") + tagColor(temp1 + JString(u""), clRed) + JString(u" = ") + temp3;
        solutionText += tagBr();

        if (op1 <= 100)
        {
            temp1 = op1 - 1;
            temp2 = 100 - op1;

            solutionText +=	tagBr() + tagNewExample(2);
            solutionText += tagBr();
            solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"99") + JString(u" = ") + answer;
            solutionText +=	tagBr();
            solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" - ") + JString(u"1") + JString(u" = ") + tagColor(temp1+JString(u""), clBlue);
            if (temp2 >= 10)
            {
                solutionText +=	tagBr() + tagStep(2) + JString(u"100") + JString(u" - ") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(temp2+JString(u""), clYellow);
                solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clBlue) + JString(u"_") + tagColor(temp2+JString(u""), clYellow) + JString(u" = ") + answer;
            }
            else
            {
                solutionText +=	tagBr() + tagStep(2) + JString(u"100") + JString(u" - ") + tagColor(op1+JString(u""), clRed) + JString(u" = 0") + tagColor(temp2+JString(u""), clYellow);
                solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clBlue) + JString(u"_0") + tagColor(temp2+JString(u""), clYellow) + JString(u" = ") + answer;
            }
        }

    }
    void trickMultiplyBy25St()
    {
        float1 = (float)op1 / 4;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"25"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"25"), clMangeta) + JString(u" = ") + tagColor(JString(u"100"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + answer;

    }
    void trickMultiplyBy50St()
    {
        float1 = (float)op1 / 2;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"50"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"50"), clMangeta) + JString(u" = ") + tagColor(JString(u"100"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + answer;

    }
    void trickDividingBy40St()
    {
        temp1 = op1 / 10;
        temp2 = temp1 / 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"40"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"40"), clMangeta) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + tagColor(temp2+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp2+JString(u""), clOrange) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + answer;

    }
    void trickMultiplyBy05St()
    {
        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"0.5"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"0.5"), clMangeta) + JString(u" = ") + JString(u"1") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + answer;

    }
    void trickDividingBy05St()
    {
        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"0.5"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"0.5"), clMangeta) + JString(u" = ") + JString(u"1") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + answer;

    }
    void trickSquareNumbersEditingIn25St()
    {
        temp1 = op1/100;
        temp2 = temp1 * temp1;
        float1 = (float)temp1 / 2;
        float2 = float1 + (float)temp2;
        temp3 = (int64_t)(float2 * 10);

        solutionText = tagColor(temp1+JString(u""), clRed) + JString(u"25") + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clGreen) + JString(u" + ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(trimFloat(float2)+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(4) + tagColor(trimFloat(float2)+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"10") + JString(u" = ") + tagColor(temp3+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(5) + tagColor(temp3+JString(u""), clMangeta) + JString(u"_625") + JString(u" = ") + answer;

    }
    void trickMultiplyBy02St()
    {
        float1 = (float)op1/10;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"0.2"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"0.2"), clMangeta) + JString(u" = ") + JString(u"1") + JString(u" ") + getDivisionSign() + JString(u" (") + tagColor(JString(u"10"), clCyan) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clBlue) + JString(u")");
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clBlue) + JString(u" = ") + answer;

    }
    void trickDividingBy02St()
    {
        float1 = (float)op1/2;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"0.2"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"0.2"), clMangeta) + JString(u" = ") + JString(u"1") + JString(u" ") + getDivisionSign() + JString(u" (") + tagColor(JString(u"10"), clCyan) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clBlue) + JString(u")");
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clBlue) + JString(u" = ") + tagColor(trimFloat(float1), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clCyan) + JString(u" = ") + answer;

    }
    void trickMultiplyBy025St()
    {
        temp1 = op1 / 2;
        temp2 = temp1 / 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"0.25"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"0.25"), clBlue) + JString(u" = ") + JString(u"1") + JString(u" ") + getDivisionSign() + JString(u" 4 = 1 ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + answer;

    }
    void trickDividingBy025St()
    {
        temp1 = op1 * 2;
        temp2 = temp1 * 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"0.25"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"0.25"), clBlue) + JString(u" = ") + JString(u"1") + JString(u" ") + getDivisionSign() + JString(u" 4 = 1 ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + answer;

    }
    void trick_square_number_between_20_and_29St()
    {
        temp1 = op1%10; 
        temp2 = temp1 * 40; 
        temp3 = temp1 * temp1;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(JString(u"20"), clBlue) + JString(u" + ") + tagColor(temp1+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"20"), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(JString(u"40"), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(JString(u"20"), clBlue) + tagPower(2) + JString(u" = ") + tagColor(JString(u"400"), clMangeta);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"40"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(5) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(6) + tagColor(JString(u"400"), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"2") + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"40") + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + JString(u"400") + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_square_number_between_30_and_39St()
    {
        temp1 = op1%10;
        temp2 = temp1 * 60;
        temp3 = temp1 * temp1;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(JString(u"30"), clBlue) + JString(u" + ") + tagColor(temp1+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"30"), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(JString(u"60"), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(JString(u"30"), clBlue) + tagPower(2) + JString(u" = ") + tagColor(JString(u"900"), clMangeta);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"60"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(5) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(6) + tagColor(JString(u"900"), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"3") + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"60") + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + JString(u"900") + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_square_number_between_60_and_69St()
    {
        temp1 = op1%10;
        temp2 = temp1 * 120;
        temp3 = temp1 * temp1;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(JString(u"60"), clBlue) + JString(u" + ") + tagColor(temp1+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"60"), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(JString(u"120"), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(JString(u"60"), clBlue) + tagPower(2) + JString(u" = ") + tagColor(JString(u"3600"), clMangeta);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"120"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(5) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(6) + tagColor(JString(u"3600"), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"6") + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"120") + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + JString(u"3600") + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_square_number_between_70_and_79St()
    {
        temp1 = op1%10;
        temp2 = temp1 * 140;
        temp3 = temp1 * temp1;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(JString(u"70"), clBlue) + JString(u" + ") + tagColor(temp1+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"70"), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(JString(u"140"), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(JString(u"70"), clBlue) + tagPower(2) + JString(u" = ") + tagColor(JString(u"4900"), clMangeta);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"140"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(5) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(6) + tagColor(JString(u"4900"), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"7") + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"140") + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + JString(u"4900") + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_square_number_between_80_and_89St()
    {
        temp1 = op1%10;
        temp2 = temp1 * 160;
        temp3 = temp1 * temp1;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(JString(u"80"), clBlue) + JString(u" + ") + tagColor(temp1+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"80"), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(JString(u"160"), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(JString(u"80"), clBlue) + tagPower(2) + JString(u" = ") + tagColor(JString(u"6400"), clMangeta);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"160"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(5) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(6) + tagColor(JString(u"6400"), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"8") + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"160") + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clYellow) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + JString(u"6400") + JString(u" + ") + tagColor(temp2+JString(u""), clCyan) + JString(u" + ") + tagColor(temp3+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_50_percentSt()
    {
        solutionText = tagColor(JString(u"50"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"50"), clRed) + JString(u" = 100 ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + answer;

    }
    void trick_25_percentSt()
    {
        solutionText = tagColor(JString(u"25"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"25"), clRed) + JString(u" = 100 ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u" = ") + answer;

    }
    void trick_20_percentSt()
    {
        float1 = (float)op2/10;

        solutionText = tagColor(JString(u"2"), clRed) + JString(u"0% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"10% → ") + tagColor(op2+JString(u""), clGreen) + JString(u" = ") + tagColor(op2+JString(u""), clGreen) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"10 = ") + tagColor(trimFloat(float1)+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"2"), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(trimFloat(float1)+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_15_percentSt()
    {
        temp1 = op2/10;
        temp2 = temp1/2;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"15"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"15"), clRed) + JString(u"% = ") + tagColor(JString(u"10"), clGreen) + JString(u"% + ") + tagColor(JString(u"5"), clYellow) + JString(u"%");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"10"), clGreen) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"10 = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"5"), clYellow) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clGreen) + JString(u"% ") + getDivisionSign() + JString(u" ") + JString(u"2 = ") + tagColor(temp1+JString(u""), clMangeta) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"2 = ") + tagColor(temp2+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp2 + JString(u""), clOrange) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"15% → ") + tagColor(op2+JString(u""), clRed) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"10 = ") + tagColor(temp1+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"2 = ") + tagColor(temp2+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1 + JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_5_percentSt()
    {
        temp1 = op2/10;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"5"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"5"), clRed) + JString(u"% = ") + JString(u"100%") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"20"), clYellow) + JString(u"%");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"20"), clYellow) + JString(u" = ") + tagColor(JString(u"10"), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clOrange) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"5"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clOrange) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + answer;

    }
    void trick_4_percentSt()
    {
        float1 = (float)op2/100;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"4"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"4"), clRed) + JString(u"% = ") + tagColor(JString(u"1"), clGreen) + JString(u"%") + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clMangeta);
        solutionText +=	tagBr() + tagColor(JString(u"1"), clGreen) + JString(u"% = ") + JString(u"100%") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clOrange) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"4"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clOrange) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clMangeta) + JString(u" = ") + answer;

    }
    void trick_2_percentSt()
    {
        float1 = (float)op2/100;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"2"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"2"), clRed) + JString(u"% = ") + tagColor(JString(u"1"), clGreen) + JString(u"%") + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta);
        solutionText +=	tagBr() + tagColor(JString(u"1"), clGreen) + JString(u"% = ") + JString(u"100%") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clOrange) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"2"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clOrange) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + answer;

    }
    void trick_05_percentSt()
    {
        float1 = (float)op2/100;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"0.5"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"0.5"), clRed) + JString(u"% = ") + tagColor(JString(u"1"), clGreen) + JString(u"%") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta);
        solutionText +=	tagBr() + tagColor(JString(u"1"), clGreen) + JString(u"% = ") + JString(u"100%") + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clOrange) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"0.5"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clOrange) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + answer;

    }
    void trick_150_percentSt()
    {
        temp1 = op2/2;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"150"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"150"), clRed) + JString(u"% = ") + tagColor(JString(u"100"), clGreen) + JString(u"% + ") + tagColor(JString(u"50"), clYellow) + JString(u"%");
        solutionText +=	tagBr() + tagColor(JString(u"50"), clYellow) + JString(u"% = ") + tagColor(JString(u"100"), clGreen) + JString(u"% ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"100"), clGreen) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(op2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(JString(u"50"), clYellow) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + tagColor(temp1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(op2 + JString(u""), clMangeta) + JString(u" + ") + tagColor(temp1+JString(u""), clOrange) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"150% → ") + tagColor(op2+JString(u""), clRed) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(temp1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op2 + JString(u""), clRed) + JString(u" + ") + tagColor(temp1+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_200_percentSt()
    {
        solutionText = tagColor(JString(u"200"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"200"), clRed) + JString(u" = 100 ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + answer;

    }
    void trickMultiplyBy3St()
    {
        temp1 = op1 * 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"3"), clBlue) + JString(u" = ") + tagColor(JString(u"2"), clYellow) + JString(u" + ") + tagColor(JString(u"1"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clGreen) + JString(u" = ") + tagColor(op1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1 + JString(u""), clMangeta) + JString(u" + ") + tagColor(op1+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trickMultiplyBy6St()
    {
        float1 = (float)op1/2;
        float2 = float1*10;
        temp1 = (int64_t)float2;

        solutionText =	tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"6"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"6"), clYellow) + JString(u" = ") + JString(u"5 + 1 = ") + tagColor(JString(u"10"), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" + ") + tagColor(JString(u"1"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clBlue) + JString(u" = ") + tagColor(temp1+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(3) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clGreen) + JString(u" = ") + tagColor(op1+JString(u""), clRed);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1 + JString(u""), clCyan) + JString(u" + ") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + answer;

    }
    void trickMultiplyBy7St()
    {
        float1 = (float)op1/2;
        float2 = float1*10;
        temp1 = (int64_t)float2;
        temp2 = op1*2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"7"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"7"), clYellow) + JString(u" = ") + JString(u"5 + 2 = ") + tagColor(JString(u"10"), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" + ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clBlue) + JString(u" = ") + tagColor(temp1+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(3) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clBrown);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clCyan) + JString(u" + ") + tagColor(temp2+JString(u""), clBrown) + JString(u" = ") + answer;

    }
    void trickMultiplyBy8St()
    {
        temp1 = op1*10;
        temp2 = op1*2;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"8"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"8"), clYellow) + JString(u" = ") + tagColor(JString(u"10"), clBlue) + JString(u" - ") + tagColor(JString(u"2"), clOrange);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clBlue) + JString(u" = ") + tagColor(temp1+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" = ") + tagColor(temp2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clGreen) + JString(u" - ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" = ") + answer;
        solutionText += tagBr();

        temp1 = op1*2;
        temp2 = temp1*2;

        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"8"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"8"), clYellow) + JString(u" = ") + tagColor(JString(u"2"), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clBlue) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" = ") + tagColor(temp2+JString(u""), clBrown);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2+JString(u""), clBrown) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + answer;
        solutionText += tagBr();


        float1 = (float)op1/2;
        float2 = float1*10;
        temp1 = (int64_t)float2;
        temp2 = op1*3;

        solutionText +=	tagBr() + tagNewExample(3);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"8"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"8"), clYellow) + JString(u" = ") + JString(u"5 + 3 = ") + tagColor(JString(u"10"), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" + ") + tagColor(JString(u"3"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clBlue) + JString(u" = ") + tagColor(temp1+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(3) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clBrown);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clCyan) + JString(u" + ") + tagColor(temp2+JString(u""), clBrown) + JString(u" = ") + answer;

    }
    void trickMultiplyBy12St()
    {
        temp1 = op1 * 10;
        temp2 = op1 * 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"12"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"12"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" + ") + tagColor(JString(u"2"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trickMultiplyBy13St()
    {
        temp1 = op1 * 10;
        temp2 = op1 * 3;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"13"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"13"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" + ") + tagColor(JString(u"3"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trickMultiplyBy14St()
    {
        temp1 = op1 * 10;
        temp2 = op1 * 4;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"14"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"14"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" + ") + tagColor(JString(u"4"), clGreen);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp2+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trickMultiplyBy16St()
    {
        temp1 = op1 * 10;
        temp2 = op1 * 5;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"16"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"16"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" + ") + tagColor(JString(u"5"), clGreen) + JString(u" + ") + tagColor(JString(u"1"), clMangeta);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"5"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clBrown);
        solutionText +=	tagBr() + tagStep(3) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clMangeta) + JString(u" = ") + tagColor(op1+JString(u""), clRed);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clOrange) + JString(u" + ") + tagColor(temp2 + JString(u""), clBrown) + JString(u" + ") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + answer;

    }
    void trickMultiplyBy17St()
    {
        temp1 = op1 * 10;
        temp2 = op1 * 5;
        temp3 = op1 * 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"17"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"17"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clYellow) + JString(u" + ") + tagColor(JString(u"5"), clGreen) + JString(u" + ") + tagColor(JString(u"2"), clMangeta);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clYellow) + JString(u" = ") + tagColor(temp1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"5"), clGreen) + JString(u" = ") + tagColor(temp2+JString(u""), clBrown);
        solutionText +=	tagBr() + tagStep(3) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + tagColor(temp3+JString(u""), clRed);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp1+JString(u""), clOrange) + JString(u" + ") + tagColor(temp2 + JString(u""), clBrown) + JString(u" + ") + tagColor(temp3+JString(u""), clRed) + JString(u" = ") + answer;

    }
    void trickMultiplyBy18St()
    {
        temp1 = op1*20;
        temp2 = op1*2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"18"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"18"), clYellow) + JString(u" = ") + tagColor(JString(u"20"), clBlue) + JString(u" - ") + tagColor(JString(u"2"), clOrange);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"20"), clBlue) + JString(u" = ") + tagColor(temp1+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clOrange) + JString(u" = ") + tagColor(temp2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clGreen) + JString(u" - ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" = ") + answer;


    }
    void trickMultiplyBy19St()
    {
        temp1 = op1*20;
        temp2 = op1*1;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"19"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"19"), clYellow) + JString(u" = ") + tagColor(JString(u"20"), clBlue) + JString(u" - ") + tagColor(JString(u"1"), clOrange);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"20"), clBlue) + JString(u" = ") + tagColor(temp1+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clOrange) + JString(u" = ") + tagColor(temp2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp1 + JString(u""), clGreen) + JString(u" - ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" = ") + answer;


    }
    void trick_250_percentSt()
    {
        solutionText = tagColor(JString(u"250"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();

        float1 = (float)op2/4;

        solutionText +=	tagBr() + tagColor(JString(u"250"), clRed) + JString(u"% = 100% ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clMangeta);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clMangeta) + JString(u" = ") + answer;

    }
    void trickDividingBy15St()
    {
        temp1 = op1;
        float1 = (float)temp1 / 10;
        float2 = float1 / 3;
        temp2 = (int64_t)(float2 * 2);

        solutionText = tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"15"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"15"), clBlue) + JString(u" = ") + tagColor(JString(u"10"), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clMangeta) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clBrown);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clGreen) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"3"), clMangeta) + JString(u" ") + JString(u" = ") + tagColor(trimFloat(float2)+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float2)+JString(u""), clOrange) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clBrown) + JString(u" = ") + temp2;

    }
    void trickDividingBy6St()
    {
        temp1 = op1;
        float1 = (float)temp1 / 2;

        solutionText = tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"6"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"6"), clBlue) + JString(u" = ") + tagColor(JString(u"3"), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1) + JString(u""), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"3"), clGreen) + JString(u" ") + JString(u" = ") + answer;

    }
    void trick_3_rootSt()
    {
        solutionText = tagPower(op2) + JString(u"√") + op1 + JString(u" = ") + answer;

    }
    void trick_4_rootSt()
    {
        int64_t temp1 = (int64_t) JMath::round(JMath::sqrt(op1));
        solutionText = tagPower(op2) + JString(u"√") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText += tagBr() + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(2+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(2+JString(u""), clOrange);
        solutionText += tagBr();
        solutionText += tagBr() + tagStep(1) + tagPower(2) + JString(u"√") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(temp1+JString(u""), clYellow);
        solutionText += tagBr() + tagStep(2) + tagPower(2) + JString(u"√") + tagColor(temp1+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_6_rootSt()
    {
        int64_t temp1 = (int64_t) JMath::round(JMath::sqrt(op1));
        solutionText = tagPower(op2) + JString(u"√") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText += tagBr() + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(3+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(2+JString(u""), clOrange);
        solutionText += tagBr();
        solutionText += tagBr() + tagStep(1) + tagPower(2) + JString(u"√") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(temp1+JString(u""), clYellow);
        solutionText += tagBr() + tagStep(2) + tagPower(3) + JString(u"√") + tagColor(temp1+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_9_rootSt()
    {
        int64_t temp1 = (int64_t) JMath::round(JMath::cbrt(op1));
        solutionText = tagPower(op2) + JString(u"√") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText += tagBr() + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(3+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(3+JString(u""), clOrange);
        solutionText += tagBr();
        solutionText += tagBr() + tagStep(1) + tagPower(3) + JString(u"√") + tagColor(op1+JString(u""), clRed) + JString(u" = ") + tagColor(temp1+JString(u""), clYellow);
        solutionText += tagBr() + tagStep(2) + tagPower(3) + JString(u"√") + tagColor(temp1+JString(u""), clYellow) + JString(u" = ") + answer;

    }
    void trick_power_2St()
    {
        temp1 = op1/10 * 10;
        temp2 = op1%10;

        temp3 = temp1 * temp1;
        temp4 = 2 * (temp1 * temp2);
        temp5 = temp2 * temp2;

        if (op1 <=10)
        {
            solutionText = tagNewExample(1);
            solutionText += tagBr();
            solutionText +=	tagBr() + op1 + tagPower(op2) + JString(u" = ") + answer;

            return;
        }


        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X + Y)") + tagPower(2) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + JString(u"X") + tagPower(2) + tagColor(JString(u"]"), clMangeta) + JString(u" + ") + tagColor(JString(u"["), clOrange) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Y)") + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + JString(u"Y") + tagPower(2) + tagColor(JString(u"]"), clYellow);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + tagColor(temp1+JString(u""), clBlue) + tagPower(2) + tagColor(JString(u"]"), clMangeta) + JString(u" + ") + tagColor(JString(u"["), clOrange) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1 + JString(u""), clBlue) + getMultiplicationSign() + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + tagColor(temp2+JString(u""), clGreen) + tagPower(2) + tagColor(JString(u"]"), clYellow) + JString(u" =");
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + temp3 + tagColor(JString(u"]"), clMangeta) + JString(u" + ") + tagColor(JString(u"["), clOrange) + temp4 + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + temp5 + tagColor(JString(u"]"), clYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();


        temp1 = (op1/10 + 1) * 10;
        temp2 = 10 - op1%10;

        temp3 = temp1 * temp1;
        temp4 = temp1 * temp2 * 2;
        temp5 = temp2 * temp2;


        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X - Y)") + tagPower(2) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + JString(u"X") + tagPower(2) + tagColor(JString(u"]"), clMangeta) + JString(u" - ") + tagColor(JString(u"["), clOrange) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Y)") + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + JString(u"Y") + tagPower(2) + tagColor(JString(u"]"), clYellow);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" - ") + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + tagColor(temp1+JString(u""), clBlue) + tagPower(2) + tagColor(JString(u"]"), clMangeta) + JString(u" - ") + tagColor(JString(u"["), clOrange) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1 + JString(u""), clBlue) + getMultiplicationSign() + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + tagColor(temp2+JString(u""), clGreen) + tagPower(2) + tagColor(JString(u"]"), clYellow) + JString(u" =");
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + temp3 + tagColor(JString(u"]"), clMangeta) + JString(u" - ") + tagColor(JString(u"["), clOrange) + temp4 + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + temp5 + tagColor(JString(u"]"), clYellow) + JString(u" = ") + answer;


    }
    void trick_power_2_between_100_and_999St()
    {
        temp1 = op1/100 * 100;
        temp2 = (op1/10)%10 * 10;
        temp3 = op1%10;

        temp4 = temp1 * temp1;
        temp5 = temp2 * temp2;
        temp6 = temp3 * temp3;

        temp7 = 2 * (temp1 * temp2);
        temp8 = 2 * (temp1 * temp3);
        temp9 = 2 * (temp2 * temp3);


        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X + Y + Z)") + tagPower(2) + JString(u" = ") + tagBr()
                + tagBr() + JString(u" = ") + tagColor(JString(u"["), clViolet) + JString(u"X") + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + JString(u"Y") + tagPower(2) + tagColor(JString(u"]"), clOrange ) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + JString(u"Z") + tagPower(2) + tagColor(JString(u"]"), clCyan   ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreen) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Y)") + tagColor(JString(u"]"), clGreen) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clBrown ) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clBrown ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreenYellow ) + JString(u"2") + getMultiplicationSign() + JString(u"(Y") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clGreenYellow );
        solutionText +=	tagBr();
        solutionText +=	tagBr() + JString(u"------");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1 + JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + tagColor(temp1+JString(u""), clBlue   ) + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + tagColor(temp2+JString(u""), clMangeta) + tagPower(2) + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + tagColor(temp3+JString(u""), clYellow ) + tagPower(2) + tagColor(JString(u"]"), clCyan  ) + JString(u" + ")

                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreen     ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta) + JString(u")") + tagColor(JString(u"]"), clGreen     ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clBrown      ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clBrown      ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreenYellow) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp2+JString(u""), clMangeta) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + temp4  + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + temp5  + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + temp6  + tagColor(JString(u"]"), clCyan  ) + JString(u" + ")

                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreen     ) + temp7 + tagColor(JString(u"]"), clGreen     ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clBrown      ) + temp8 + tagColor(JString(u"]"), clBrown      ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreenYellow) + temp9 + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();


        temp1 = op1/100 * 100;
        temp2 = ((op1/10)%10 + 1) * 10;
        temp3 = 10 - op1%10;

        temp4 = temp1 * temp1;
        temp5 = temp2 * temp2;
        temp6 = temp3 * temp3;

        temp7 = 2 * (temp1 * temp2);
        temp8 = 2 * (temp1 * temp3);
        temp9 = 2 * (temp2 * temp3);


        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X + Y - Z)") + tagPower(2) + JString(u" = ") + tagBr()
                + tagBr() + JString(u" = ") + tagColor(JString(u"["), clViolet) + JString(u"X") + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + JString(u"Y") + tagPower(2) + tagColor(JString(u"]"), clOrange ) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + JString(u"Z") + tagPower(2) + tagColor(JString(u"]"), clCyan   ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreen) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Y)") + tagColor(JString(u"]"), clGreen) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clBrown ) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clBrown ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreenYellow ) + JString(u"2") + getMultiplicationSign() + JString(u"(Y") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clGreenYellow );
        solutionText +=	tagBr();
        solutionText +=	tagBr() + JString(u"------");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1 + JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" - ") + tagColor(temp3+JString(u""), clYellow) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + tagColor(temp1+JString(u""), clBlue   ) + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + tagColor(temp2+JString(u""), clMangeta) + tagPower(2) + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + tagColor(temp3+JString(u""), clYellow ) + tagPower(2) + tagColor(JString(u"]"), clCyan  ) + JString(u" + ")

                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreen     ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta) + JString(u")") + tagColor(JString(u"]"), clGreen     ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clBrown      ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clBrown      ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreenYellow) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp2+JString(u""), clMangeta) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + temp4  + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + temp5  + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + temp6  + tagColor(JString(u"]"), clCyan  ) + JString(u" + ")

                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreen     ) + temp7 + tagColor(JString(u"]"), clGreen     ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clBrown      ) + temp8 + tagColor(JString(u"]"), clBrown      ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreenYellow) + temp9 + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();


        temp1 = (op1/100 + 1) * 100;
        temp2 = (10 - (op1/10)%10) * 10;
        temp3 = op1%10;

        temp4 = temp1 * temp1;
        temp5 = temp2 * temp2;
        temp6 = temp3 * temp3;

        temp7 = 2 * (temp1 * temp2);
        temp8 = 2 * (temp1 * temp3);
        temp9 = 2 * (temp2 * temp3);


        solutionText +=	tagBr() + tagNewExample(3);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X - Y + Z)") + tagPower(2) + JString(u" = ") + tagBr()
                + tagBr() + JString(u" = ") + tagColor(JString(u"["), clViolet) + JString(u"X") + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + JString(u"Y") + tagPower(2) + tagColor(JString(u"]"), clOrange ) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + JString(u"Z") + tagPower(2) + tagColor(JString(u"]"), clCyan   ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreen) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Y)") + tagColor(JString(u"]"), clGreen) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clBrown ) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clBrown ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreenYellow ) + JString(u"2") + getMultiplicationSign() + JString(u"(Y") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clGreenYellow );
        solutionText +=	tagBr();
        solutionText +=	tagBr() + JString(u"------");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1 + JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" - ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + tagColor(temp1+JString(u""), clBlue   ) + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + tagColor(temp2+JString(u""), clMangeta) + tagPower(2) + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + tagColor(temp3+JString(u""), clYellow ) + tagPower(2) + tagColor(JString(u"]"), clCyan  ) + JString(u" - ")

                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreen      ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta ) + JString(u")") + tagColor(JString(u"]"), clGreen      ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clBrown      ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clBrown      ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreenYellow) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp2+JString(u""), clMangeta) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + temp4  + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + temp5  + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + temp6  + tagColor(JString(u"]"), clCyan  ) + JString(u" - ")

                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreen     ) + temp7 + tagColor(JString(u"]"), clGreen     ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clBrown      ) + temp8 + tagColor(JString(u"]"), clBrown      ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreenYellow) + temp9 + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ") + answer;
        solutionText +=	tagBr();


        temp1 = (op1/100 + 1) * 100;
        temp2 = ((10 - (op1/10)%10) - 1) * 10;
        temp3 = 10 - op1%10;

        temp4 = temp1 * temp1;
        temp5 = temp2 * temp2;
        temp6 = temp3 * temp3;

        temp7 = 2 * (temp1 * temp2);
        temp8 = 2 * (temp1 * temp3);
        temp9 = 2 * (temp2 * temp3);


        solutionText +=	tagBr() + tagNewExample(4);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X - Y - Z)") + tagPower(2) + JString(u" = ") + tagBr()
                + tagBr() + JString(u" = ") + tagColor(JString(u"["), clViolet) + JString(u"X") + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + JString(u"Y") + tagPower(2) + tagColor(JString(u"]"), clOrange ) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + JString(u"Z") + tagPower(2) + tagColor(JString(u"]"), clCyan   ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreen) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Y)") + tagColor(JString(u"]"), clGreen) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clBrown ) + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clBrown ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreenYellow ) + JString(u"2") + getMultiplicationSign() + JString(u"(Y") + getMultiplicationSign() + JString(u"Z)") + tagColor(JString(u"]"), clGreenYellow );
        solutionText +=	tagBr();
        solutionText +=	tagBr() + JString(u"------");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1 + JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" - ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" - ") + tagColor(temp3+JString(u""), clYellow) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + tagColor(temp1+JString(u""), clBlue   ) + tagPower(2) + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + tagColor(temp2+JString(u""), clMangeta) + tagPower(2) + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + tagColor(temp3+JString(u""), clYellow ) + tagPower(2) + tagColor(JString(u"]"), clCyan  ) + JString(u" - ")

                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreen      ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta ) + JString(u")") + tagColor(JString(u"]"), clGreen      ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clBrown      ) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue   ) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clBrown      ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreenYellow) + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp2+JString(u""), clMangeta) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow  ) + JString(u")") + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clViolet ) + temp4  + tagColor(JString(u"]"), clViolet) + JString(u" + ")
                + tagColor(JString(u"["), clOrange ) + temp5  + tagColor(JString(u"]"), clOrange) + JString(u" + ")
                + tagColor(JString(u"["), clCyan   ) + temp6  + tagColor(JString(u"]"), clCyan  ) + JString(u" - ")

                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clGreen     ) + temp7 + tagColor(JString(u"]"), clGreen     ) + JString(u" - ")
                + tagBr() + JString(u" - ") + tagColor(JString(u"["), clBrown      ) + temp8 + tagColor(JString(u"]"), clBrown      ) + JString(u" + ")
                + tagBr() + JString(u" + ") + tagColor(JString(u"["), clGreenYellow) + temp9 + tagColor(JString(u"]"), clGreenYellow) + JString(u" = ") + answer;

    }
    void trick_power_2_between_1000_and_9999St()
    {
        temp1 = op1/1000 * 1000;
        temp2 = (op1/100%10) * 100;
        temp3 = (op1/10)%10 * 10;
        temp4 = op1%10;

        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X + Y + Z + Q)") + tagPower(2) + JString(u" = ") + tagBr()
                + tagBr() + JString(u" = ") + JString(u"X") + tagPower(2) + JString(u" + ") + JString(u"Y") + tagPower(2) + JString(u" + ") + JString(u"Z") + tagPower(2) + JString(u" + ") + JString(u"Q") + tagPower(2) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Y)") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Z)") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(X") + getMultiplicationSign() + JString(u"Q)") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(Y") + getMultiplicationSign() + JString(u"Z)") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(Y") + getMultiplicationSign() + JString(u"Q)") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(Z") + getMultiplicationSign() + JString(u"Q)");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + JString(u"------");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1 + JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow) + JString(u" + ") + tagColor(temp4+JString(u""), clGreen) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(temp1+JString(u""), clBlue   ) + tagPower(2) + JString(u" + ")
                + tagColor(temp2+JString(u""), clMangeta) + tagPower(2) + JString(u" + ")
                + tagColor(temp3+JString(u""), clYellow ) + tagPower(2) + JString(u" + ")
                + tagColor(temp4+JString(u""), clGreen  ) + tagPower(2) + JString(u" + ")

                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue	) + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta) + JString(u") + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue	) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow ) + JString(u") + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp1+JString(u""), clBlue	) + getMultiplicationSign() + tagColor(temp4+JString(u""), clGreen  ) + JString(u") + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp2+JString(u""), clMangeta	) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow ) + JString(u") + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp2+JString(u""), clMangeta	) + getMultiplicationSign() + tagColor(temp4+JString(u""), clGreen  ) + JString(u") + ")
                + tagBr() + JString(u" + ") + JString(u"2") + getMultiplicationSign() + JString(u"(") + tagColor(temp3+JString(u""), clYellow	) + getMultiplicationSign() + tagColor(temp4+JString(u""), clGreen  ) + JString(u") = ");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + power(temp1, 2) + JString(u" + ") + power(temp2, 2) + JString(u" + ") + power(temp3, 2) + JString(u" + ") + power(temp4, 2) + JString(u" + ")
                + tagBr() + JString(u" + ") + 2*temp1*temp2 + JString(u" + ")
                + tagBr() + JString(u" + ") + 2*temp1*temp3 + JString(u" + ")
                + tagBr() + JString(u" + ") + 2*temp1*temp4 + JString(u" + ")
                + tagBr() + JString(u" + ") + 2*temp2*temp3 + JString(u" + ")
                + tagBr() + JString(u" + ") + 2*temp2*temp4 + JString(u" + ")
                + tagBr() + JString(u" + ") + 2*temp3*temp4 + JString(u" = ") + answer;

    }
    void trick_power_3St()
    {
        temp1 = op1/10 * 10;
        temp2 = op1%10;

        temp3 = temp1 * temp1 * temp1;
        temp4 = 3 * temp1 * temp2 * (temp1 + temp2);
        temp5 = temp2 * temp2 * temp2;


        if (op1 <=10)
        {
            solutionText = tagNewExample(1);
            solutionText += tagBr();
            solutionText +=	tagBr() + op1 + tagPower(op2) + JString(u" = ") + answer;

            return;
        }


        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X + Y)") + tagPower(3) + JString(u" = ") + tagBr() + JString(u"= ") + tagColor(JString(u"["), clMangeta) + JString(u"X") + tagPower(3) + tagColor(JString(u"]"), clMangeta) + JString(u" + ") + tagColor(JString(u"["), clOrange) + JString(u"3") + getMultiplicationSign() + JString(u"X") + getMultiplicationSign() + JString(u"Y") + getMultiplicationSign() + JString(u"(X+Y)") + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + JString(u"Y") + tagPower(3) + tagColor(JString(u"]"), clYellow);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + tagPower(3) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagPower(3) + JString(u" =");
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + tagColor(temp1+JString(u""), clBlue) + tagPower(3) + tagColor(JString(u"]"), clMangeta) + JString(u" + ") + tagColor(JString(u"["), clOrange) + JString(u"3") + getMultiplicationSign() + tagColor(temp1 + JString(u""), clBlue) + getMultiplicationSign() + tagColor(temp2+JString(u""), clGreen) + getMultiplicationSign() + JString(u"(") + tagColor(temp1 + JString(u""), clBlue) + JString(u"+") + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + tagColor(temp2+JString(u""), clGreen) + tagPower(3) + tagColor(JString(u"]"), clYellow) + JString(u" =");
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + temp3 + tagColor(JString(u"]"), clMangeta) + JString(u" + ") + tagColor(JString(u"["), clOrange) + temp4 + tagColor(JString(u"]"), clOrange) + JString(u" + ") + tagColor(JString(u"["), clYellow) + temp5 + tagColor(JString(u"]"), clYellow) + JString(u" = ") + answer;

        solutionText +=	tagBr();

        temp1 = (op1/10 + 1) * 10;
        temp2 = 10 - op1%10;

        temp3 = temp1 * temp1 * temp1;
        temp4 = 3 * temp1 * temp2 * (temp1 - temp2);
        temp5 = temp2 * temp2 * temp2;



        solutionText +=	tagBr() + tagNewExample(2);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X - Y)") + tagPower(3) + JString(u" = ") + tagBr() + JString(u"= ") + tagColor(JString(u"["), clMangeta) + JString(u"X") + tagPower(3) + tagColor(JString(u"]"), clMangeta) + JString(u" - ") + tagColor(JString(u"["), clOrange) + JString(u"3") + getMultiplicationSign() + JString(u"X") + getMultiplicationSign() + JString(u"Y") + getMultiplicationSign() + JString(u"(X-Y)") + tagColor(JString(u"]"), clOrange) + JString(u" - ") + tagColor(JString(u"["), clYellow) + JString(u"Y") + tagPower(3) + tagColor(JString(u"]"), clYellow);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + tagPower(3) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" - ") + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagPower(3) + JString(u" =");
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + tagColor(temp1+JString(u""), clBlue) + tagPower(3) + tagColor(JString(u"]"), clMangeta) + JString(u" - ") + tagColor(JString(u"["), clOrange) + JString(u"3") + getMultiplicationSign() + tagColor(temp1 + JString(u""), clBlue) + getMultiplicationSign() + tagColor(temp2+JString(u""), clGreen) + getMultiplicationSign() + JString(u"(") + tagColor(temp1 + JString(u""), clBlue) + JString(u"-") + tagColor(temp2+JString(u""), clGreen) + JString(u")") + tagColor(JString(u"]"), clOrange) + JString(u" - ") + tagColor(JString(u"["), clYellow) + tagColor(temp2+JString(u""), clGreen) + tagPower(3) + tagColor(JString(u"]"), clYellow) + JString(u" = ") + tagBr() + JString(u"= ") + answer;
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + tagColor(JString(u"["), clMangeta) + temp3 + tagColor(JString(u"]"), clMangeta) + JString(u" - ") + tagColor(JString(u"["), clOrange) + temp4 + tagColor(JString(u"]"), clOrange) + JString(u" - ") + tagColor(JString(u"["), clYellow) + temp5 + tagColor(JString(u"]"), clYellow) + JString(u" = ") + answer;


    }
    void trick_power_3_between_100_and_999St()
    {
        temp1 = op1/100 * 100;
        temp2 = (op1/10)%10 * 10;
        temp3 = op1%10;

        temp4 = temp1 * temp1 * temp1;
        temp5 = temp2 * temp2 * temp2;
        temp6 = temp3 * temp3 * temp3;


        solutionText = tagNewExample(1);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op1+JString(u""), clRed) + tagPower(op2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + JString(u"(X + Y + Z)") + tagPower(3) + JString(u" = ") + tagBr()
                + tagBr() + JString(u" = ") + JString(u"X") + tagPower(3) + JString(u" + ") + JString(u"Y") + tagPower(3) + JString(u" + ") + JString(u"Z") + tagPower(3) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + JString(u"X") + tagPower(2) + getMultiplicationSign() + JString(u"Y") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + JString(u"X") + tagPower(2) + getMultiplicationSign() + JString(u"Z") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + JString(u"Y") + tagPower(2) + getMultiplicationSign() + JString(u"X") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + JString(u"Y") + tagPower(2) + getMultiplicationSign() + JString(u"Z") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + JString(u"Z") + tagPower(2) + getMultiplicationSign() + JString(u"X") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + JString(u"Z") + tagPower(2) + getMultiplicationSign() + JString(u"Y") + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"6") + getMultiplicationSign() + JString(u"X") + getMultiplicationSign() + JString(u"Y") + getMultiplicationSign() + JString(u"Z");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + JString(u"------");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1 + JString(u""), clRed) + tagPower(2) + JString(u" = ") + JString(u"(") + tagColor(temp1+JString(u""), clBlue) + JString(u" + ") + tagColor(temp2+JString(u""), clMangeta) + JString(u" + ") + tagColor(temp3+JString(u""), clYellow) + JString(u")") + tagPower(2) + JString(u" =");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(2) + JString(u" = ") + tagColor(temp1+JString(u""), clBlue   ) + tagPower(3) + JString(u" + ")
                + tagColor(temp2+JString(u""), clMangeta) + tagPower(3) + JString(u" + ")
                + tagColor(temp3+JString(u""), clYellow ) + tagPower(3) + JString(u" + ")

                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + tagColor(temp1+JString(u""), clBlue	) + tagPower(2) + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + tagColor(temp1+JString(u""), clBlue	) + tagPower(2) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow	) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta) + tagPower(2) + getMultiplicationSign() + tagColor(temp1+JString(u""), clBlue	) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta) + tagPower(2) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow	) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow	) + tagPower(2) + getMultiplicationSign() + tagColor(temp1+JString(u""), clBlue	) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"3") + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow	) + tagPower(2) + getMultiplicationSign() + tagColor(temp2+JString(u""), clMangeta) + JString(u" + ")
                + tagBr() + JString(u" + ") + JString(u"6") + getMultiplicationSign() + tagColor(temp1 + JString(u""), clBlue) + getMultiplicationSign() + tagColor(temp2 + JString(u""), clMangeta) + getMultiplicationSign() + tagColor(temp3+JString(u""), clYellow) + JString(u" = ");
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(3) + JString(u" = ") + temp4 + JString(u" + ") + temp5 + JString(u" + ") + temp6 + JString(u" + ")
                + tagBr() + JString(u" + ") + 3*temp1*temp1*temp2 + JString(u" + ")
                + tagBr() + JString(u" + ") + 3*temp1*temp1*temp3 + JString(u" + ")
                + tagBr() + JString(u" + ") + 3*temp2*temp2*temp1 + JString(u" + ")
                + tagBr() + JString(u" + ") + 3*temp2*temp2*temp3 + JString(u" + ")
                + tagBr() + JString(u" + ") + 3*temp3*temp3*temp1 + JString(u" + ")
                + tagBr() + JString(u" + ") + 3*temp3*temp3*temp2 + JString(u" + ")
                + tagBr() + JString(u" + ") + 6*temp1*temp2*temp3 + JString(u" = ") + answer;


    }
    
    void trick_power_4St()
    {
        solutionText = tagColor(op1+JString(u""), clRed) + tagColor(tagPower(op2)+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(2+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(2+JString(u""), clOrange);
        solutionText += tagBr();
        solutionText += tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + tagColor(tagPower(op2)+JString(u""), clBlue) + JString(u" = ") + tagColor(op1+JString(u""), clRed) + tagColor(tagPower(2)+JString(u""), clGreen) + JString(u"<sup>") + tagColor(tagPower(2)+JString(u""), clOrange) + JString(u"</sup>");
        solutionText += tagBr() + tagStep(2) + power(op1, 2) + tagColor(tagPower(2)+JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_power_6St()
    {
        solutionText = tagColor(op1+JString(u""), clRed) + tagColor(tagPower(op2)+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(2+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(3+JString(u""), clOrange);
        solutionText += tagBr();
        solutionText += tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + tagColor(tagPower(op2)+JString(u""), clBlue) + JString(u" = ") + tagColor(op1 + JString(u""), clRed) + tagColor(tagPower(2)+JString(u""), clGreen) + JString(u"<sup>") + tagColor(tagPower(3)+JString(u""), clOrange) + JString(u"</sup>");
        solutionText += tagBr() + tagStep(2) + power(op1, 2) + tagColor(tagPower(3) + JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trick_power_9St()
    {
        solutionText = tagColor(op1+JString(u""), clRed) + tagColor(tagPower(op2)+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText +=	tagBr() + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + tagColor(3+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(3+JString(u""), clOrange);
        solutionText += tagBr();
        solutionText += tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + tagColor(tagPower(op2)+JString(u""), clBlue) + JString(u" = ") + tagColor(op1 + JString(u""), clRed) + tagColor(tagPower(3)+JString(u""), clGreen) + JString(u"<sup>") + tagColor(tagPower(3)+JString(u""), clOrange) + JString(u"</sup>");
        solutionText += tagBr() + tagStep(2) + power(op1, 3) + tagColor(tagPower(3) + JString(u""), clOrange) + JString(u" = ") + answer;

    }
    void trickDividingBy3St()
    {
        solutionText = op1 + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"3") + JString(u" = ") + answer;

    }
    void trickDividingBy2St()
    {
        solutionText = op1 + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"2") + JString(u" = ") + answer;

    }
    void trickMultiplyBy2St()
    {
        solutionText = op1 + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"2") + JString(u" = ") + answer;

    }
    void trickDividingBy8St()
    {
        temp1 = op1 / 2;
        temp2 = temp1 / 2;
        temp3 = temp2 / 2;

        solutionText = tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"8"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"8"), clBlue) + JString(u" = ") + tagColor(JString(u"2"), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta);
        solutionText +=	tagBr();
        solutionText += tagBr() + tagStep(1) + tagColor(op1 +JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clOrange);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clOrange) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clYellow) + JString(u" = ") + tagColor(temp2+JString(u""), clCyan);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2 + JString(u""), clCyan) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clMangeta) + JString(u" = ") + answer;

    }
    void trick_5_rootSt()
    {
        solutionText = tagPower(op2) + JString(u"√") + tagColor(op1 + JString(u""), clRed) + JString(u" = ") + answer;
        if(op1 <= 100000)
            return;

        JString s1,s2;

        s1 = op1+JString(u"");
        s2 = s1.substring(s1.length()-5,s1.length()-1);


        temp1 = op1/100000;
        temp2 = op1%100000;
        temp3 = temp2%10;
        temp2 = temp2/10;

        solutionText +=	tagBr();
        solutionText += tagBr() + tagStep(1) + tagColor(op1 + JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"100000") + JString(u" = ") + tagColor(temp1 + JString(u""), clBlue) + JString(u".") + s2 + tagColor(temp3 + JString(u""), clGreen);

        int64_t i = 9;
        int64_t j;

        while (temp1 < power(i, 5))
            i--;

        j = i+1;

        solutionText += tagBr() + tagStep(2) + power(i,5) + JString(u"(") + tagColor(i + JString(u""), clOrange) + tagPower(5) + JString(u")") + JString(u" ≤ ") + tagColor(temp1 + JString(u""), clBlue) + JString(u" < ") + power(j,5) + JString(u"(") + j + tagPower(5) + JString(u")");
        solutionText += tagBr() + tagStep(3) + tagPower(op2) + JString(u"√") + op1+ JString(u" = ") + tagColor(i + JString(u""), clOrange) + tagColor(temp3 + JString(u""), clGreen);


    }
    void trickMultiplyBy125St()
    {
        float1 = (float)op1 / 8;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"125"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"125"), clMangeta) + JString(u" = ") + tagColor(JString(u"1000"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"8"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"8"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1000"), clYellow) + JString(u" = ") + answer;

    }
    void trickSquareNumbersEditingIn75St()
    {
        temp1 = op1/100;
        temp2 = (temp1*10+5)*(temp1+1);

        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u"7") + tagColor(JString(u"5"), clBlue) + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + tagColor(JString(u"5"), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" (") + tagColor(temp1 + JString(u""), clRed) + JString(u" + ") + JString(u"1)") + JString(u" = ") + tagColor(temp2+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp2+JString(u""), clGreen) + JString(u"_625") + JString(u" = ") + answer;
    }
    void trickSquareNumbersEditingIn125St()
    {
        temp1 = op1/1000;

        temp2 = temp1*temp1;

        float1 = (float)temp1/4;
        float2 = temp2 + float1;

        temp3 = (int64_t)(float2*100);

        temp4 = temp3 + 1;

        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u"125") + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + JString(u"(") + tagColor(temp1 + JString(u""), clRed) + tagPower(2) + JString(u" + ") + tagColor(temp1 + JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"4)") + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"100 + 1_") + tagColor(JString(u"5625"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + JString(u"(") + temp2 + JString(u" + ") + trimFloat(float1) + JString(u")") + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"100 + 1_") + tagColor(JString(u"5625"), clGreen);
        solutionText +=	tagBr() + tagStep(3) + temp3 + JString(u" + 1_") + tagColor(JString(u"5625"), clGreen);
        solutionText +=	tagBr() + tagStep(4) + temp4 + JString(u"_") + tagColor(JString(u"5625"), clGreen) + JString(u" = ") + answer;

    }
    void trickMultiplyBy250St()
    {
        float1 = (float)op1 / 4;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"250"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"250"), clMangeta) + JString(u" = ") + tagColor(JString(u"1000"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1000"), clYellow) + JString(u" = ") + answer;

    }
    void trickMultiplyBy500St()
    {
        float1 = (float)op1 / 2;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"500"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"500"), clMangeta) + JString(u" = ") + tagColor(JString(u"1000"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"2"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1000"), clYellow) + JString(u" = ") + answer;

    }
    void trickMultiplyBy750St()
    {
        float1 = (float)op1 / 4;
        float2 = float1 * 3;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"750"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"750"), clMangeta) + JString(u" = ") + JString(u"(") + tagColor(JString(u"1000"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan) + JString(u")") + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange) + JString(u" = ") + tagColor(trimFloat(float2), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float2)+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1000"), clYellow) + JString(u" = ") + answer;


    }
    void trickMultiplyBy999St()
    {
        temp1 = op1;
        temp2 = op1 * 1000;
        temp3 = temp2 - op1;

        solutionText =	tagBr() + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"999"), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"999"), clBlue) + JString(u" = ") + tagColor(JString(u"1000"), clYellow) + JString(u" - ") + tagColor(JString(u"1"), clGreen);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1000"), clYellow) + JString(u" = ") + tagColor(temp2+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"1"), clGreen) + JString(u" = ") + tagColor(temp1+JString(u""), clRed);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp2 + JString(u""), clMangeta) + JString(u" - ") + tagColor(temp1 + JString(u""), clRed) + JString(u" = ") + temp3;

    }
    void trickDividingBy7St()
    {
        solutionText = op1 + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"7") + JString(u" = ") + answer;

    }
    void trickDividingBy9St()
    {
        solutionText = op1 + JString(u" ") + getDivisionSign() + JString(u" ") + JString(u"9") + JString(u" = ") + answer;

    }
    void trick_300_percentSt()
    {
        solutionText = tagColor(JString(u"300"), clRed) + JString(u"% → ") + tagColor(op2 + JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"300"), clRed) + JString(u" = 100 ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clGreen) + JString(u" = ") + answer;

    }
    void trick_500_percentSt()
    {
        solutionText = tagColor(JString(u"500"), clRed) + JString(u"% → ") + tagColor(op2+JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(JString(u"500"), clRed) + JString(u" = 100 ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"5"), clGreen);
        solutionText +=	tagBr() + tagStep(2) + tagColor(op2+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"5"), clGreen) + JString(u" = ") + answer;

    }
    void trickMultiplyBy75St()
    {
        float1 = (float)op1 / 4;
        float2 = float1 * 3;

        solutionText = tagColor(op1 + JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"75"), clMangeta) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"75"), clMangeta) + JString(u" = ") + JString(u"(") + tagColor(JString(u"100"), clYellow) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan) + JString(u")") + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange);
        solutionText += tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op1+JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clCyan) + JString(u" = ") + tagColor(trimFloat(float1)+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1)+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange) + JString(u" = ") + tagColor(trimFloat(float2), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float2)+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"100"), clYellow) + JString(u" = ") + answer;


    }
    void trickSquareNumbersEditingIn05St()
    {
        temp1 = op1/100;
        temp2 = temp1 * temp1;
        temp3 = temp2*10+temp1;

        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u"05") + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp2+JString(u""), clBlue) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"10") + JString(u" + ") + tagColor(temp1 + JString(u""), clRed) + JString(u" = ") + tagColor(temp3+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp3+JString(u""), clGreen) + JString(u"_025") + JString(u" = ") + answer;

    }
    void trickSquareNumbersEditingIn15St()
    {
        temp1 = op1/100;
        temp2 = temp1*temp1;

        float1 = (float)temp1/2;
        float1 = ((float)temp2 + float1) * 10;

        temp3 = (int64_t)float1;

        temp4 = temp1*2;

        temp5 = temp3-temp4;

        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u"15") + tagPower(2) + JString(u" = ") + answer;
        solutionText += tagBr();
        solutionText += tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + tagPower(2) + JString(u" = ") + tagColor(temp2+JString(u""), clBlue);
        solutionText += tagBr() + tagStep(2) + JString(u"(") + tagColor(temp2+JString(u""), clBlue) + JString(u" ") + JString(u"+") + JString(u" ") + tagColor(temp1 + JString(u""), clRed) + JString(u" ") + getDivisionSign() + JString(u" 2) ") + getMultiplicationSign() + JString(u" 10 = ") + tagColor(temp3+JString(u""), clGreen);
        solutionText += tagBr() + tagStep(3) + tagColor(temp1+JString(u""), clRed) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"2") + JString(u" = ") + tagColor(temp4+JString(u""), clMangeta);
        solutionText += tagBr() + tagStep(4) + tagColor(temp3 + JString(u""), clGreen) + JString(u" - ") + tagColor(temp4+JString(u""), clMangeta) + JString(u" = ") + tagColor(temp5+JString(u""), clOrange);
        solutionText += tagBr() + tagStep(5) + tagColor(temp5+JString(u""), clOrange) + JString(u"_225") + JString(u" = ") + answer;

    }
    void trickSquareNumbersEditingIn95St()
    {
        temp1 = op1/100;
        temp2 = temp1+1;
        temp3 = temp2*temp2;
        temp4 = temp3*10-temp2;

        solutionText = tagColor(temp1 + JString(u""), clRed) + JString(u"95") + tagPower(2) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(temp1+JString(u""), clRed) + JString(u" + 1 = ") + tagColor(temp2+JString(u""), clBlue);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp2+JString(u""), clBlue) + tagPower(2) + JString(u" = ") + tagColor(temp3+JString(u""), clGreen);
        solutionText +=	tagBr() + tagStep(3) + tagColor(temp3+JString(u""), clGreen) + JString(u" ") + getMultiplicationSign() + JString(u" ") + JString(u"10") + JString(u" - ") + tagColor(temp2+JString(u""), clBlue) + JString(u" = ") + tagColor(temp4+JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(4) + tagColor(temp4+JString(u""), clMangeta) + JString(u"_025") + JString(u" = ") + answer;

    }
    void trick_75_percentSt()
    {
        temp1 = op2/4;
        temp2 = temp1*3;


        solutionText = tagColor(JString(u"75"), clRed) + JString(u"% → ") + tagColor(op2 + JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"75"), clRed) + JString(u"% = (100 ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u") ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2 + JString(u""), clBlue)+ JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u" = ") + tagColor(temp1 + JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(temp1 + JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange) + JString(u" = ") + answer;

    }
    void trick_750_percentSt()
    {
        float1 = (float)op2/4;
        float2 = float1*3;


        solutionText = tagColor(JString(u"750"), clRed) + JString(u"% → ") + tagColor(op2 + JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"750"), clRed) + JString(u"% = ((100% ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u") ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange)+ JString(u") ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clCyan);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2 + JString(u""), clBlue)+ JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"4"), clGreen) + JString(u" = ") + tagColor(trimFloat(float1) + JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1) + JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"3"), clOrange) + JString(u" = ") + tagColor(trimFloat(float2) + JString(u""), clYellow);
        solutionText +=	tagBr() + tagStep(3) + tagColor(trimFloat(float2) + JString(u""), clYellow) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"10"), clCyan) + JString(u" = ") + answer;

    }
    void trick_40_percentSt()
    {
        float1 = (float)op2/10;
        temp2 = (int64_t)(float1*4);


        solutionText = tagColor(JString(u"40"), clRed) + JString(u"% → ") + tagColor(op2 + JString(u""), clBlue) + JString(u" = ") + answer;
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagColor(JString(u"40"), clRed) + JString(u"% = (100 ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clGreen) + JString(u") ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clOrange);
        solutionText +=	tagBr();
        solutionText +=	tagBr() + tagStep(1) + tagColor(op2 + JString(u""), clBlue)+ JString(u" ") + getDivisionSign() + JString(u" ") + tagColor(JString(u"10"), clGreen) + JString(u" = ") + tagColor(trimFloat(float1) + JString(u""), clMangeta);
        solutionText +=	tagBr() + tagStep(2) + tagColor(trimFloat(float1) + JString(u""), clMangeta) + JString(u" ") + getMultiplicationSign() + JString(u" ") + tagColor(JString(u"4"), clOrange) + JString(u" = ") + answer;

    }
    


    
    void generate(int32_t trick) { switch(trick) {
        case 1: trickAdditionSt(); break;
        case 2: trickSubtractionSt(); break;
        case 3: trickMultiplicationSt(); break;
        case 4: trickDivisionSt(); break;
        case 5: trickMultiplyBy11TwoDigitSt(); break;
        case 6: trickSquareNumbersEditingIn5St(); break;
        case 7: trickMultiplyBy5St(); break;
        case 8: trickMultiplyBy9St(); break;
        case 9: trickMultiplyBy4St(); break;
        case 10: trickDividingBy5St(); break;
        case 11: trickSubtracringFrom1000St(); break;
        case 12: trickToughMultiplicationSt(); break;
        case 13: trickPowerOfTwoSt(); break;
        case 14: trick_adding_numbers_close_to_hundredsSt(); break;
        case 15: trick_subtracting_numbers_close_to_hundredsSt(); break;
        case 16: trick_multiply_numbers_between_11_and_19_textSt(); break;
        case 17: trick_square_number_between_11_and_99_textSt(); break;
        case 18: trick_multiply_two_digit_numbers_having_same_tensSt(); break;
        case 19: trick_square_number_between_50_and_59St(); break;
        case 20: trick_square_number_between_40_and_49St(); break;
        case 21: trick_multiply_two_digit_numbers_editing_in_1St(); break;
        case 22: trick_percentSt(); break;
        case 23: trick_square_number_between_100_and_109St(); break;
        case 24: trick_square_rootSt(); break;
        case 25: trick_percent_2St(); break;
        case 26: trickMultiplyBy15St(); break;
        case 27: trickMultiplyBy20St(); break;
        case 28: trickDividingBy4St(); break;
        case 29: trickDividingBy20St(); break;
        case 30: trickDividingBy50St(); break;
        case 31: trickDividingBy25St(); break;
        case 32: trick_square_number_between_10_and_19St(); break;
        case 33: trickMultiplyBy99St(); break;
        case 34: trickMultiplyBy25St(); break;
        case 35: trickMultiplyBy50St(); break;
        case 36: trickDividingBy40St(); break;
        case 37: trickMultiplyBy05St(); break;
        case 38: trickDividingBy05St(); break;
        case 39: trickSquareNumbersEditingIn25St(); break;
        case 40: trickMultiplyBy02St(); break;
        case 41: trickDividingBy02St(); break;
        case 42: trickMultiplyBy025St(); break;
        case 43: trickDividingBy025St(); break;
        case 44: trick_square_number_between_20_and_29St(); break;
        case 45: trick_square_number_between_30_and_39St(); break;
        case 46: trick_square_number_between_60_and_69St(); break;
        case 47: trick_square_number_between_70_and_79St(); break;
        case 48: trick_square_number_between_80_and_89St(); break;
        case 49: trick_50_percentSt(); break;
        case 50: trick_25_percentSt(); break;
        case 51: trick_20_percentSt(); break;
        case 52: trick_15_percentSt(); break;
        case 53: trick_5_percentSt(); break;
        case 54: trick_4_percentSt(); break;
        case 55: trick_2_percentSt(); break;
        case 56: trick_05_percentSt(); break;
        case 57: trick_150_percentSt(); break;
        case 58: trick_200_percentSt(); break;
        case 59: trickMultiplyBy3St(); break;
        case 60: trickMultiplyBy6St(); break;
        case 61: trickMultiplyBy7St(); break;
        case 62: trickMultiplyBy8St(); break;
        case 63: trickMultiplyBy12St(); break;
        case 64: trickMultiplyBy13St(); break;
        case 65: trickMultiplyBy14St(); break;
        case 66: trickMultiplyBy16St(); break;
        case 67: trickMultiplyBy17St(); break;
        case 68: trickMultiplyBy18St(); break;
        case 69: trickMultiplyBy19St(); break;
        case 70: trick_250_percentSt(); break;
        case 71: trickDividingBy15St(); break;
        case 72: trickDividingBy6St(); break;
        case 73: trick_3_rootSt(); break;
        case 74: trick_4_rootSt(); break;
        case 75: trick_6_rootSt(); break;
        case 76: trick_9_rootSt(); break;
        case 77: trick_power_2St(); break;
        case 78: trick_power_2_between_100_and_999St(); break;
        case 79: trick_power_2_between_1000_and_9999St(); break;
        case 80: trick_power_3St(); break;
        case 81: trick_power_3_between_100_and_999St(); break;
        case 82: trick_power_4St(); break;
        case 83: trick_power_6St(); break;
        case 84: trick_power_9St(); break;
        case 85: trickDividingBy3St(); break;
        case 86: trickDividingBy2St(); break;
        case 87: trickMultiplyBy2St(); break;
        case 88: trickDividingBy8St(); break;
        case 89: trick_5_rootSt(); break;
        case 90: trickMultiplyBy125St(); break;
        case 91: trickSquareNumbersEditingIn75St(); break;
        case 92: trickSquareNumbersEditingIn125St(); break;
        case 93: trickMultiplyBy250St(); break;
        case 94: trickMultiplyBy500St(); break;
        case 95: trickMultiplyBy750St(); break;
        case 96: trickMultiplyBy999St(); break;
        case 97: trickDividingBy7St(); break;
        case 98: trickDividingBy9St(); break;
        case 99: trick_300_percentSt(); break;
        case 100: trick_500_percentSt(); break;
        case 101: trickMultiplyBy75St(); break;
        case 102: trickSquareNumbersEditingIn05St(); break;
        case 103: trickSquareNumbersEditingIn15St(); break;
        case 104: trickSquareNumbersEditingIn95St(); break;
        case 105: trick_75_percentSt(); break;
        case 106: trick_750_percentSt(); break;
        case 107: trick_40_percentSt(); break;
        default: break;
    }}
};
