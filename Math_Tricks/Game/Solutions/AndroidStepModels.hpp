#pragma once
#include "AndroidStepCompatibility.hpp"
struct Arrow {
    int32_t startOffset=0,endOffset=0,color=0,labelColor=0,tokenLength=0,startTokenLength=0,dividerOffset=-1;
    bool isDimmed=false,startGap=false,targetGap=false,isSquareBox=false,alwaysShowLabel=false,noHead=false,isCarryFlight=false,centerBetweenArrows=false,drawDashedDivider=false;
    float curveAmount=0;
    JString label=nullptr;
    Arrow(int64_t s,int64_t e,int64_t c,bool dim,bool sg,bool tg,float curve,JString l,int64_t lc,bool sq,bool always,bool nh,int64_t sl,int64_t tl):
        startOffset(int32_t(s)),endOffset(int32_t(e)),color(int32_t(c)),labelColor(int32_t(lc)),tokenLength(int32_t(tl)),startTokenLength(int32_t(sl)),isDimmed(dim),startGap(sg),targetGap(tg),isSquareBox(sq),alwaysShowLabel(always),noHead(nh),curveAmount(curve),label(l){}
    Arrow(int64_t s,int64_t e,int64_t c,bool dim,bool sg,bool tg,float curve,JString l,int64_t lc,bool sq=false,bool always=false,int64_t sl=0,int64_t tl=0):Arrow(s,e,c,dim,sg,tg,curve,l,lc,sq,always,false,sl,tl){}
    Arrow(int64_t s,int64_t e,int64_t c,bool dim=false,bool tg=false):Arrow(s,e,c,dim,false,tg,0,nullptr,0){}
    Arrow(int64_t s,int64_t e,int64_t c,bool dim,bool tg,float curve):Arrow(s,e,c,dim,false,tg,curve,nullptr,0){}
    Arrow(int64_t s,int64_t e,int64_t c,bool dim,bool tg,float curve,JString l,int64_t lc):Arrow(s,e,c,dim,false,tg,curve,l,lc){}
    Arrow(int64_t s,int64_t e,int64_t c,bool dim,bool sg,bool tg,float curve):Arrow(s,e,c,dim,sg,tg,curve,nullptr,0){}
};
struct Step {
    JString description,hintExpr,equation,expectedAnswer;
    bool isFinal=false,isIntro=false;
    int32_t pulseIndex=0;
    JList<Arrow*> arrows,frozenArrows=nullptr;
    JList<int32_t> crossedOutOffsets,transparentOffsets;
    JList<JArray<int32_t>> highlightedRanges;
    Step(JString d,JString h,JString e,JString answer=JString(u""),JList<Arrow*> a={}):description(d),hintExpr(h),equation(e),expectedAnswer(answer),arrows(a){}
};
struct RoundingPlan {
    int32_t original,rounded,delta,unit;
    RoundingPlan(int64_t o,int64_t r,int64_t u):original(int32_t(o)),rounded(int32_t(r)),delta(int32_t(r-o)),unit(int32_t(u)){}
};
inline std::ostream& operator<<(std::ostream& out,const JBigInteger& n){return out<<n.value.ns().UTF8String;}
