// Generated from the read-only Android Player.java by tools/import_example_generator.py.
// Formula source SHA-256: 105a838615787a1ea512ea5805e3145e37e9dcdb6f62838e46e576d6a35a5ce3
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
void trickAddition()
    {
        if (level <= 5)
        {
            op1 = (Wide) (randomUnit() * level * 10) + (level * 5);
            op2 = (Wide) (randomUnit() * level * 10) + (level * 5);
        }
        else
        {
            op1 = (Wide) (randomUnit() * (level-4) * 50) + ((level-5) * 50);
            op2 = (Wide) (randomUnit() * (level-4) * 50) + ((level-5) * 50);
        }

        answer = op1+op2;
        sign = MTAddition;
        setTextSimple();
    }
    void trickSubtraction()
    {
        if (level <= 5)
        {
            op1 = (Wide) (randomUnit() * level * 14) + (level * 8);
            op2 = (Wide) (randomUnit() * level * 7) + (level * 4);
        }
        else
        {
            op1 = (Wide) (randomUnit() * (level-4) * 50) + ((level-5) * 50);
            op2 = (Wide) (randomUnit() * (level-4) * 25) + ((level-5) * 25);
        }


        if (op1 < op2)
        {
            Wide temp = op1;
            op1 = op2;
            op2 = temp;
        }
        answer = op1-op2;
        sign = MTSubtraction;
        setTextSimple();
    }
    void trickMultiplication()
    {
        op1 = level;
        op2 = (Wide)(randomUnit() * 9) + 1;
        answer = op1*op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickDivision()
    {
        op1=(Wide)(randomUnit()*(level+2)) + level + 2;
        op2=(Wide)(randomUnit()*(level+2)) + level + 2;
        answer=op1*op2;
        Wide temp=op1;
        op1=answer;
        answer=temp;
        sign = MTDivision;
        setTextSimple();
    }
    void trickMultiplyBy11TwoDigit()
    {
            

        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 11;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();

    }
    void trickSquareNumbersEditingIn5()
    {
        op1 = ((Wide)(randomUnit()* 9) + level);
        op1 = absolute(op1);
        op1 *= 10;
        op1 += 5;
        op2 = op1;
        answer = op1 * op2;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();

    }
    void trickMultiplyBy5()
    {
        op1 = (Wide)(randomUnit() * 20) + level * 10;
        op2 = 5;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy9()
    {
        op1 = (Wide)(randomUnit() * 10) + level * 5;
        op2 = 9;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy4()
    {
        op1 = ((Wide)(randomUnit() * 10)) + level * 5;
        op2 = 4;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickDividingBy5()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 5;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trickSubtracringFrom1000()
    {
        op1 = 1000;
        op2 = (Wide)(randomUnit() * level * 25) + (level - 1 ) * 25;

        if (op2%10 == 0)
            op2++;

        if (op2 > 1000)
            op1 = 10000;

        if (op2 > 10000)
            op1 = 100000;

        if (op2 > 100000)
            op1 = 1000000;


        answer = op1 - op2;
        sign = MTSubtraction;
        setTextSimple();
    }
    void trickToughMultiplication()
    {
        Wide transferableFactors[] = {4, 6, 8, 9, 10, 12, 18, 20, 22, 24, 27, 30, 33, 36};
        op1 = transferableFactors[(Wide) (randomUnit() * (sizeof(transferableFactors) / sizeof(transferableFactors[0])))];
        op2 = op1 + (Wide)(randomUnit() * 5) + std::max<Wide>(5, level * 5);
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickPowerOfTwo()
    {
        op1 = 2;
        if (level <= 20)
            op2 = 1 + (Wide)(randomUnit() * 8) + level;
        else
            op2 = 1 + (Wide)(randomUnit() * 8) + 20;
        op2 = absolute(op2);

        answer = (Wide)std::pow((double)op1, (double)op2);
        sign = MTPower;
        setTextPower();
    }
    void trick_adding_numbers_close_to_hundreds()
    {
        Wide temp;

        op1 = (Wide)(randomUnit() * level * 50) + (level * 15);
        op2 = (Wide)(randomUnit() * level * 30) + (level * 40);


        if (op2 > op1)
        {
            temp = op1;
            op1 = op2;
            op2 = temp;
        }

        temp = op2;

        if (op2 >= 100)
            op2 = ((temp/100) * 100) + 90 + (Wide)(randomUnit() * 19);
        else
        if (op2 >= 1000)
            op2 = ((temp/1000) * 1000) + ((temp/100) * 100) + 90 + (Wide)(randomUnit() * 19);
        else
            op2 = 90 + (Wide)(randomUnit() * 19);

        answer = op1 + op2;
        sign = MTAddition;
        setTextSimple();
    }
    void trick_subtracting_numbers_close_to_hundreds()
    {
        Wide temp;
        op1 = (Wide)(randomUnit() * level * 60) + (level * 15);
        op2 = (Wide)(randomUnit() * level * 25) + (level * 15);

        if (op2 > op1)
        {
            temp = op1;
            op1 = op2;
            op2 = temp;
        }

        temp = op2;

        op1 +=109;

        if (op2 >= 100)
            op2 = ((temp/100) * 100) + (9 * 10) + (Wide)(randomUnit() * 19);
        else
        if (op2 >= 1000)
            op2 = ((temp/1000) * 1000) + ((temp/100) * 100) + 90 + (Wide)(randomUnit() * 19);
        else
            op2 = 90 + (Wide)(randomUnit() * 19);

        answer = op1 - op2;
        sign = MTSubtraction;
        setTextSimple();
    }
    void trick_multiply_numbers_between_11_and_19_text()
    {
        if (level <= 15)
        {
            op1 = (Wide)(randomUnit() * 4) + 11 + (level / 3);
            op2 = (Wide)(randomUnit() * 4) + 11 + (level / 3);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 9) + 11;
            op2 = (Wide)(randomUnit() * 9) + 11;
        }
        
        Wide temp;
        if (op1 < op2)
        {
            temp = op2;
            op2 = op1;
            op1 = temp;
        }

        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trick_square_number_between_11_and_99_text()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 9);
        }

        op1=99-op1;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_multiply_two_digit_numbers_having_same_tens()
    {
        if (level <= 15)
            op1 = (Wide)(randomUnit() * 29) + 11 + (level * 4);
        else
            op1 = (Wide)(randomUnit() * 29) + 11 + (15 * 4);

        if ((op1 % 10) == 0)
            op1++;

        op2 = ((op1 / 10) * 10) + (10 -(op1 % 10));
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trick_square_number_between_50_and_59()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=50;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_square_number_between_40_and_49()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 9);
        }

        op1=49-op1;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_multiply_two_digit_numbers_editing_in_1()
    {
        if (level <= 15)
        {
            op1 = 1 + ((Wide)(randomUnit() * 4) + (level / 3));
            op2 = 1 + ((Wide)(randomUnit() * 4) + (level / 3));
        }
        else
        {
            op1 = 1 + ((Wide)(randomUnit() * 4) + (15 / 3));
            op2 = 1 + ((Wide)(randomUnit() * 4) + (15 / 3));
        }

        op1 = op1 * 10 + 1;
        op2 = op2 * 10 + 1;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trick_percent()
    {
        op1 = 1 + ((Wide)(randomUnit() * 3) + (level / 2));
        op1 *= 5;
        op2 = 4 + (Wide)(randomUnit() * 3) + (level / 2);

        if (op2 % 2 == 0)
            op2 *= 10;
        else
            op2*= 20;

        answer = (op1 * op2) / 100;

        sign = MTPercent;
        setTextPercent();
    }
    void trick_square_number_between_100_and_109()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=100;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_square_root()
    {
        op1 = (Wide)(randomUnit() * 8) + level;
        op1++;
        answer = op1;
        op2 = 2;
        op1 = power(op1, op2);
        sign = MTRoot;
        setTextRoot();
    }
    void trick_percent_2()
    {
        op1 = 1 + ((Wide)(randomUnit() * 7) + (level / 2));
        op2 = 1 + (Wide)(randomUnit() * 3) + (level / 2);
        op2 = op2 * 100;
        if ((op1 % 2) == 0)
            if ((Wide)(randomUnit() * 2) == 1)
                op2 += 50;
        answer = (op1 * op2) / 100;

        sign = MTPercent;
        setTextPercent();
    }
    void trickMultiplyBy15()
    {
        op1 = (Wide)(randomUnit() * 15) + (level - 1) * 4 + 1;
        op2 = 15;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy20()
    {
        op1 = (Wide)(randomUnit() * 15 * level) + level * 15;
        op2 = 20;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickDividingBy4()
    {
        op1 = ((Wide)(randomUnit() * 10)) + (level-1) * 10;
        op1++;
        op2 = 4;
        answer = op1;
        op1 = op1 * op2;
        sign = MTDivision;
        setTextSimple();
    }
    void trickDividingBy20()
    {
        op1 = ((Wide)(randomUnit() * 10)) + (level-1) * 10;
        op1++;
        op2 = 20;
        answer = op1;
        op1 = op1 * op2;
        sign = MTDivision;
        setTextSimple();
    }
    void trickDividingBy50()
    {
        op1 = ((Wide)(randomUnit() * 10)) + (level-1) * 10;
        op1++;
        op2 = 50;
        answer = op1;
        op1 = op1 * op2;
        sign = MTDivision;
        setTextSimple();
    }
    void trickDividingBy25()
    {
        op1 = ((Wide)(randomUnit() * 10)) + (level-1) * 5;
        op1++;
        op2 = 25;
        answer = op1;
        op1 = op1 * op2;
        sign = MTDivision;
        setTextSimple();
    }
    void trick_square_number_between_10_and_19()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=10;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trickMultiplyBy99()
    {
        op1 = (Wide)(randomUnit() * 10) + (level - 1) * 5 + 1;
        op2 = 99;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy25()
    {
        op1 = (Wide)(randomUnit() * 10) + (level - 1) * 5 + 1;
        op1 *= 2;
        op2 = 25;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy50()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        
        op2 = 50;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickDividingBy40()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op1++;
        op2 = 40;
        answer = op1;
        op1 = op1 * op2;
        sign = MTDivision;
        setTextSimple();
    }
    void trickMultiplyBy05()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 20 + 1;
        op1 *= 2;
        op2 = 0;
        answer = op1 / 2;
        sign = MTMultiplication;
        setTextFloat((float) 0.5);
    }
    void trickDividingBy05()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op1 *= 2;
        op2 = 0;
        answer = op1;
        op1 = op1 / 2;
        sign = MTDivision;
        setTextFloat((float) 0.5);
    }
    void trickSquareNumbersEditingIn25()
    {
        if (level < 300)
            op1 = ((Wide)(randomUnit()* 10) + level);
        else
            op1 = ((Wide)(randomUnit()* 10) + 300);


        op1 = absolute(op1);
        op1 *= 100;
        op1 += 25;
        op2 = op1;
        answer = op1 * op2;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();

    }
    void trickMultiplyBy02()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 20 + 1;
        op1 *= 5;
        op2 = 0;
        answer = op1 / 5;
        sign = MTMultiplication;
        setTextFloat((float) 0.2);
    }
    void trickDividingBy02()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 0;
        answer = op1 * 5;
        sign = MTDivision;
        setTextFloat((float) 0.2);
    }
    void trickMultiplyBy025()
    {
        op1 = ((Wide)(randomUnit() * 10)) + (level-1) * 10;
        op1++;
        op2 = 4;
        answer = op1;
        op1 = op1 * op2;
        sign = MTMultiplication;
        setTextFloat((float)0.25);
    }
    void trickDividingBy025()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 4;
        answer = op1 * op2;
        sign = MTDivision;
        setTextFloat((float) 0.25);
    }
    void trick_square_number_between_20_and_29()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=20;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_square_number_between_30_and_39()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=30;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_square_number_between_60_and_69()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=60;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_square_number_between_70_and_79()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=70;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_square_number_between_80_and_89()
    {
        if (level <= 3)
        {
            op1 = (Wide)(randomUnit() * 6);
        }
        else
        {
            op1 = (Wide)(randomUnit() * 10);
        }

        op1+=80;
        answer = op1 * op1;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();
    }
    void trick_50_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        op2 = answer * 2;
        op1 = 50;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_25_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        op2 = answer * 4;
        op1 = 25;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_20_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        op2 = answer * 5;
        op1 = 20;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_15_percent()
    {
        answer = (Wide)(randomUnit() * 15) + (level - 1) * 10;
        answer++;
        answer*=20;
        op2 = answer;
        answer = (answer/10) + (answer/20);
        op1 = 15;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_5_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        answer*=20;
        op2 = answer;
        answer /= 20;
        op1 = 5;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_4_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        answer*=25;
        op2 = answer;
        answer /= 25;
        op1 = 4;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_2_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        answer*=50;
        op2 = answer;
        answer /= 50;
        op1 = 2;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_05_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        answer*=200;
        op2 = answer;
        answer /= 200;
        op1 = 2;
        sign = MTPercent;
        setTextFloatop1((float) 0.5);

    }
    void trick_150_percent()
    {
        answer = (Wide)(randomUnit() * 15) + (level - 1) * 10;
        answer++;
        answer*=2;
        op2 = answer;
        answer += answer/2;
        op1 = 150;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_200_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        op2 = answer;
        answer*=2;
        op1 = 200;
        sign = MTPercent;
        setTextPercent();

    }
    void trickMultiplyBy3()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 3;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy6()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 6;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy7()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 7;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy8()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 8;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy12()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 12;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy13()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 13;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy14()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 14;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy16()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 16;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy17()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 17;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();

    }
    void trickMultiplyBy18()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 18;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();

    }
    void trickMultiplyBy19()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 19;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();

    }
    void trick_250_percent()
    {
        op2 = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        op2++;
        op2*=2;
        op1 = 250;

        answer = op2 * 10 / 4;

        sign = MTPercent;
        setTextPercent();

    }
    void trickDividingBy15()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 15;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trickDividingBy6()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 6;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trick_3_root()
    {
        if (level < 99)
            op1 = (Wide)(randomUnit() * 8) + level;
        else
            op1 = (Wide)(randomUnit() * 8) + 99;

        op1++;
        answer = op1;
        op2 = 3;
        op1 = power(op1, op2);
        sign = MTRoot;
        setTextRoot();
    }
    void trick_4_root()
    {
        if (level < 99)
            op1 = (Wide)(randomUnit() * 8) + level;
        else
            op1 = (Wide)(randomUnit() * 8) + 99;

        op1++;
        answer = op1;
        op2 = 4;
        op1 = power(op1, op2);
        sign = MTRoot;
        setTextRoot();
    }
    void trick_6_root()
    {
        if (level < 99)
            op1 = (Wide)(randomUnit() * 8) + (level/4);
        else
            op1 = (Wide)(randomUnit() * 8) + (99/4);

        op1++;
        answer = op1;
        op2 = 6;
        op1 = power(op1, op2);
        sign = MTRoot;
        setTextRoot();
    }
    void trick_9_root()
    {
        op1 = (Wide)(randomUnit() * 10);
        op1++;
        answer = op1;
        op2 = 9;
        op1 = power(op1, op2);
        sign = MTRoot;
        setTextRoot();
    }
    void trick_power_2()
    {
        if (level < 10)
            op1 = (Wide) (randomUnit() * 10) + ((level - 1) * 10);
        else
            op1 = (Wide) (randomUnit() * 99);

        op1 += 1;
        op2 = 2;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    void trick_power_2_between_100_and_999()
    {
        if (level <= 45)
            op1 = (Wide) (randomUnit() * 20) + ((level - 1) * 20);
        else
            op1 = (Wide) (randomUnit() * 900);

        op1 += 100;
        op2 = 2;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    void trick_power_2_between_1000_and_9999()
    {
        if (level <= 90)
            op1 = (Wide) (randomUnit() * 100) + ((level - 1) * 100);
        else
            op1 = (Wide) (randomUnit() * 9000);

        op1 += 1000;
        op2 = 2;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    void trick_power_3()
    {
        op1 = (Wide) (randomUnit() * 90) + 10;
        op2 = 3;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    void trick_power_3_between_100_and_999()
    {
        if (level <= 45)
            op1 = (Wide) (randomUnit() * 20) + ((level - 1) * 20);
        else
            op1 = (Wide) (randomUnit() * 900);

        op1 += 100;
        op2 = 3;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    
    void trick_power_4()
    {
        if (level < 10)
            op1 = (Wide) (randomUnit() * 10) + ((level - 1) * 10);
        else
            op1 = (Wide) (randomUnit() * 90);

        op1 += 1;
        op2 = 4;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    void trick_power_6()
    {
        if (level < 4)
            op1 = (Wide) (randomUnit() * 10) + ((level - 1) * 10);
        else
            op1 = (Wide) (randomUnit() * 30);

        op1 += 1;
        op2 = 6;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    void trick_power_9()
    {
        op1 = (Wide) (randomUnit() * 9);

        op1 += 1;
        op2 = 9;

        answer = power(op1, op2);
        sign = MTPower;
        setTextPower();
    }
    void trickDividingBy3()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 3;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trickDividingBy2()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 2;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trickMultiplyBy2()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 2;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickDividingBy8()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 8;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trick_5_root()
    {
        op1 = (Wide)(randomUnit() * 8) + ((level-1)*8);

        if (op1 > 72)
            op1 = (Wide)(randomUnit() * 73);

        op1++;
        answer = op1;
        op2 = 5;
        op1 = power(op1, op2);
        sign = MTRoot;
        setTextRoot();
    }
    void trickMultiplyBy125()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 125;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickSquareNumbersEditingIn75()
    {
        op1 = ((Wide)(randomUnit()* 10) + ((level-1)*3));

        op1++;

        op1 = absolute(op1);
        op1 *= 100;
        op1 += 75;
        op2 = op1;
        answer = op1 * op2;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();

    }
    void trickSquareNumbersEditingIn125()
    {
        op1 = ((Wide)(randomUnit()* 10) + ((level-1)*3));

        if (op1 > 30)
            op1 = ((Wide)(randomUnit()* 31));

        op1++;

        op1 = absolute(op1);
        op1 *= 1000;
        op1 += 125;
        op2 = op1;
        answer = op1 * op2;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();

    }
    void trickMultiplyBy250()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 250;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy500()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 500;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy750()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 750;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickMultiplyBy999()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 999;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickDividingBy7()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 7;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trickDividingBy9()
    {
        op1 = ((Wide)(randomUnit() * 20)) + (level-1) * 20 + 1;
        op2 = 9;
        answer = op1*op2;
        Wide tempNumber = op1;
        op1 = answer;
        answer = tempNumber;
        sign = MTDivision;
        setTextSimple();
    }
    void trick_300_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        op2 = answer;
        answer*=3;
        op1 = 300;
        sign = MTPercent;
        setTextPercent();

    }
    void trick_500_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        op2 = answer;
        answer*=5;
        op1 = 500;
        sign = MTPercent;
        setTextPercent();

    }
    void trickMultiplyBy75()
    {
        op1 = (Wide)(randomUnit() * 20) + (level - 1) * 10 + 1;
        op2 = 75;
        answer = op1 * op2;
        sign = MTMultiplication;
        setTextSimple();
    }
    void trickSquareNumbersEditingIn05()
    {
        if (level < 300)
            op1 = ((Wide)(randomUnit()* 10) + level);
        else
            op1 = ((Wide)(randomUnit()* 10) + 300);


        op1 = absolute(op1);
        op1 *= 100;
        op1 += 5;
        op2 = op1;
        answer = op1 * op2;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();

    }
    void trickSquareNumbersEditingIn15()
    {
        if (level < 300)
            op1 = ((Wide)(randomUnit()* 10) + level);
        else
            op1 = ((Wide)(randomUnit()* 10) + 300);


        op1 = absolute(op1);
        op1 *= 100;
        op1 += 15;
        op2 = op1;
        answer = op1 * op2;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();

    }
    void trickSquareNumbersEditingIn95()
    {
        if (level < 300)
            op1 = ((Wide)(randomUnit()* 10) + level);
        else
            op1 = ((Wide)(randomUnit()* 10) + 300);


        op1 = absolute(op1);
        op1 *= 100;
        op1 += 95;
        op2 = op1;
        answer = op1 * op2;
        op2 = 2;
        sign = MTMultiplication;
        setTextPower();

    }
    void trick_75_percent()
    {
        op2 = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        op2++;
        op2*=4;
        op1 = 75;

        answer = (op2 / 4) * 3;

        sign = MTPercent;
        setTextPercent();

    }
    void trick_750_percent()
    {
        op2 = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        op2++;
        op2*=2;
        op1 = 750;

        answer = (Wide)(((float)op2 / 4) * 3 * 10);

        sign = MTPercent;
        setTextPercent();

    }
    void trick_40_percent()
    {
        answer = (Wide)(randomUnit() * 20) + (level - 1) * 10;
        answer++;
        answer *= 2;

        op2 = (answer * 10) / 4;
        op1 = 40;
        sign = MTPercent;
        setTextPercent();

    }


    
};
}
MTGeneratedExample MTGenerateExample(int32_t trickID, int32_t level, uint64_t seed) {
    if (level < 1) return MTGeneratedExample{};
    Generator g{seed, level};
    switch (trickID) {
        case 1: g.trickAddition(); break;
        case 2: g.trickSubtraction(); break;
        case 3: g.trickMultiplication(); break;
        case 4: g.trickDivision(); break;
        case 5: g.trickMultiplyBy11TwoDigit(); break;
        case 6: g.trickSquareNumbersEditingIn5(); break;
        case 7: g.trickMultiplyBy5(); break;
        case 8: g.trickMultiplyBy9(); break;
        case 9: g.trickMultiplyBy4(); break;
        case 10: g.trickDividingBy5(); break;
        case 11: g.trickSubtracringFrom1000(); break;
        case 12: g.trickToughMultiplication(); break;
        case 13: g.trickPowerOfTwo(); break;
        case 14: g.trick_adding_numbers_close_to_hundreds(); break;
        case 15: g.trick_subtracting_numbers_close_to_hundreds(); break;
        case 16: g.trick_multiply_numbers_between_11_and_19_text(); break;
        case 17: g.trick_square_number_between_11_and_99_text(); break;
        case 18: g.trick_multiply_two_digit_numbers_having_same_tens(); break;
        case 19: g.trick_square_number_between_50_and_59(); break;
        case 20: g.trick_square_number_between_40_and_49(); break;
        case 21: g.trick_multiply_two_digit_numbers_editing_in_1(); break;
        case 22: g.trick_percent(); break;
        case 23: g.trick_square_number_between_100_and_109(); break;
        case 24: g.trick_square_root(); break;
        case 25: g.trick_percent_2(); break;
        case 26: g.trickMultiplyBy15(); break;
        case 27: g.trickMultiplyBy20(); break;
        case 28: g.trickDividingBy4(); break;
        case 29: g.trickDividingBy20(); break;
        case 30: g.trickDividingBy50(); break;
        case 31: g.trickDividingBy25(); break;
        case 32: g.trick_square_number_between_10_and_19(); break;
        case 33: g.trickMultiplyBy99(); break;
        case 34: g.trickMultiplyBy25(); break;
        case 35: g.trickMultiplyBy50(); break;
        case 36: g.trickDividingBy40(); break;
        case 37: g.trickMultiplyBy05(); break;
        case 38: g.trickDividingBy05(); break;
        case 39: g.trickSquareNumbersEditingIn25(); break;
        case 40: g.trickMultiplyBy02(); break;
        case 41: g.trickDividingBy02(); break;
        case 42: g.trickMultiplyBy025(); break;
        case 43: g.trickDividingBy025(); break;
        case 44: g.trick_square_number_between_20_and_29(); break;
        case 45: g.trick_square_number_between_30_and_39(); break;
        case 46: g.trick_square_number_between_60_and_69(); break;
        case 47: g.trick_square_number_between_70_and_79(); break;
        case 48: g.trick_square_number_between_80_and_89(); break;
        case 49: g.trick_50_percent(); break;
        case 50: g.trick_25_percent(); break;
        case 51: g.trick_20_percent(); break;
        case 52: g.trick_15_percent(); break;
        case 53: g.trick_5_percent(); break;
        case 54: g.trick_4_percent(); break;
        case 55: g.trick_2_percent(); break;
        case 56: g.trick_05_percent(); break;
        case 57: g.trick_150_percent(); break;
        case 58: g.trick_200_percent(); break;
        case 59: g.trickMultiplyBy3(); break;
        case 60: g.trickMultiplyBy6(); break;
        case 61: g.trickMultiplyBy7(); break;
        case 62: g.trickMultiplyBy8(); break;
        case 63: g.trickMultiplyBy12(); break;
        case 64: g.trickMultiplyBy13(); break;
        case 65: g.trickMultiplyBy14(); break;
        case 66: g.trickMultiplyBy16(); break;
        case 67: g.trickMultiplyBy17(); break;
        case 68: g.trickMultiplyBy18(); break;
        case 69: g.trickMultiplyBy19(); break;
        case 70: g.trick_250_percent(); break;
        case 71: g.trickDividingBy15(); break;
        case 72: g.trickDividingBy6(); break;
        case 73: g.trick_3_root(); break;
        case 74: g.trick_4_root(); break;
        case 75: g.trick_6_root(); break;
        case 76: g.trick_9_root(); break;
        case 77: g.trick_power_2(); break;
        case 78: g.trick_power_2_between_100_and_999(); break;
        case 79: g.trick_power_2_between_1000_and_9999(); break;
        case 80: g.trick_power_3(); break;
        case 81: g.trick_power_3_between_100_and_999(); break;
        case 82: g.trick_power_4(); break;
        case 83: g.trick_power_6(); break;
        case 84: g.trick_power_9(); break;
        case 85: g.trickDividingBy3(); break;
        case 86: g.trickDividingBy2(); break;
        case 87: g.trickMultiplyBy2(); break;
        case 88: g.trickDividingBy8(); break;
        case 89: g.trick_5_root(); break;
        case 90: g.trickMultiplyBy125(); break;
        case 91: g.trickSquareNumbersEditingIn75(); break;
        case 92: g.trickSquareNumbersEditingIn125(); break;
        case 93: g.trickMultiplyBy250(); break;
        case 94: g.trickMultiplyBy500(); break;
        case 95: g.trickMultiplyBy750(); break;
        case 96: g.trickMultiplyBy999(); break;
        case 97: g.trickDividingBy7(); break;
        case 98: g.trickDividingBy9(); break;
        case 99: g.trick_300_percent(); break;
        case 100: g.trick_500_percent(); break;
        case 101: g.trickMultiplyBy75(); break;
        case 102: g.trickSquareNumbersEditingIn05(); break;
        case 103: g.trickSquareNumbersEditingIn15(); break;
        case 104: g.trickSquareNumbersEditingIn95(); break;
        case 105: g.trick_75_percent(); break;
        case 106: g.trick_750_percent(); break;
        case 107: g.trick_40_percent(); break;
        default: return MTGeneratedExample{0, 0, 0, 0, 0, 0, 0};
    }
    constexpr Wide maximumOperand = 9007199254740991LL;
    if (!g.arithmeticValid || g.op1 < 0 || g.op1 > maximumOperand ||
        g.op2 < 0 || g.op2 > maximumOperand || g.answer < 0 || g.answer > 1000000000000000LL)
        return MTGeneratedExample{};
    return MTGeneratedExample{int64_t(g.op1), int64_t(g.op2), int64_t(g.answer), std::isnan(g.first) ? double(g.op1) : g.first,
        std::isnan(g.second) ? double(g.op2) : g.second, g.sign, 1};
}
