#pragma once
#import <Foundation/Foundation.h>
#include <string>
#include <vector>
#include <memory>
#include <algorithm>
#include <cmath>
#include <sstream>
#include <iomanip>
#include <limits>
#include <stdexcept>
#include <type_traits>

// Small value/container adapters for the offline arithmetic port. Offsets are UTF-16,
// matching Java and NSAttributedString. There is no Java VM or downloaded code.
template<class T> struct JArray {
    std::shared_ptr<std::vector<T>> values;
    int32_t length;
    JArray(std::nullptr_t): values(nullptr), length(0) {}
    bool operator==(std::nullptr_t) const {return !values;}
    bool operator!=(std::nullptr_t) const {return bool(values);}
    JArray(): values(std::make_shared<std::vector<T>>()), length(0) {}
    JArray(int64_t size): values(std::make_shared<std::vector<T>>(std::max<int64_t>(0,size))), length(int32_t(std::max<int64_t>(0,size))) {}
    JArray(std::initializer_list<T> init): values(std::make_shared<std::vector<T>>(init)), length(int32_t(init.size())) {}
    typename std::vector<T>::reference operator[](int64_t i) { return values->at(i); }
    typename std::vector<T>::const_reference operator[](int64_t i) const { return values->at(i); }
    auto begin() { return values->begin(); } auto end() { return values->end(); }
};
struct JString {
    std::u16string value;
    bool null = false;
    JString() = default;
    JString(std::nullptr_t): null(true) {}
    JString(const char16_t* s): value(s ? s : u""), null(s == nullptr) {}
    JString(const std::u16string& s): value(s) {}
    JString(const char* s) { NSString* v = [NSString stringWithUTF8String:s]; assign(v); }
    JString(const JArray<char16_t>& a): value(a.values->begin(), a.values->end()) {}
    void assign(NSString* s) { value.resize(s.length); [s getCharacters:reinterpret_cast<unichar*>(value.data()) range:NSMakeRange(0,s.length)]; }
    NSString* ns() const { return [[NSString alloc] initWithCharacters:reinterpret_cast<const unichar*>(value.data()) length:value.size()]; }
    int32_t length() const { return int32_t(value.size()); }
    bool isEmpty() const { return value.empty(); }
    bool equals(const JString& s) const { return value == s.value; }
    bool operator==(std::nullptr_t) const { return null; }
    bool operator!=(std::nullptr_t) const { return !null; }
    char16_t charAt(int64_t i) const { return value.at(i); }
    JString substring(int64_t start) const { return value.substr(start); }
    JString substring(int64_t start, int64_t end) const { return value.substr(start,end-start); }
    int32_t indexOf(const JString& s, int64_t start=0) const { auto i=value.find(s.value,start); return i==value.npos ? -1 : int32_t(i); }
    int32_t indexOf(char16_t c, int64_t start=0) const { return indexOf(JString(std::u16string(1,c)),start); }
    int32_t lastIndexOf(const JString& s, int64_t start=INT64_MAX) const { auto i=value.rfind(s.value,std::min<int64_t>(start,value.size())); return i==value.npos ? -1 : int32_t(i); }
    int32_t lastIndexOf(char16_t c, int64_t start=INT64_MAX) const { return lastIndexOf(JString(std::u16string(1,c)),start); }
    bool contains(const JString& s) const { return indexOf(s)>=0; }
    JString replace(const JString& from, const JString& to) const {
        auto result=value; size_t p=0; if(from.value.empty()) return result;
        while((p=result.find(from.value,p))!=result.npos) { result.replace(p,from.value.size(),to.value); p+=to.value.size(); }
        return result;
    }
    JString replace(char16_t from,char16_t to) const { auto s=value; std::replace(s.begin(),s.end(),from,to); return s; }
    JString trim() const { auto a=value.find_first_not_of(u" \n\r\t"), b=value.find_last_not_of(u" \n\r\t"); return a==value.npos ? JString(u"") : JString(value.substr(a,b-a+1)); }
    JArray<char16_t> toCharArray() const { JArray<char16_t> a(value.size()); std::copy(value.begin(),value.end(),a.values->begin()); return a; }
    void getChars(int64_t start,int64_t end,JArray<char16_t> dest,int64_t offset) const { std::copy(value.begin()+start,value.begin()+end,dest.values->begin()+offset); }
    JString operator+(const JString& b) const { return value+b.value; }
    JString operator+(char16_t c) const { return value+std::u16string(1,c); }
    template<class T, std::enable_if_t<std::is_arithmetic_v<T>,int> = 0> JString operator+(T n) const { return *this+valueOf(n); }
    JString& operator+=(const JString& s) { value+=s.value; return *this; }
    template<class T> JString& operator+=(T n) { *this=*this+n; return *this; }
    static JString valueOf(JString v) { return v; }
    static JString valueOf(char16_t v) { return std::u16string(1,v); }
    static JString valueOf(bool v) { return v ? u"true" : u"false"; }
    template<class T> static JString valueOf(T n) { std::ostringstream s; s<<std::setprecision(15)<<n; return JString(s.str().c_str()); }
    static JString formatted(const JString& format, const std::vector<JString>& args);
    template<class... T> static JString format(const JString& f,T... args) { return formatted(f,{valueOf(args)...}); }
};
template<class T,std::enable_if_t<std::is_arithmetic_v<T>,int> = 0> JString operator+(T n,const JString& s) { return JString::valueOf(n)+s; }

template<class T> struct JList {
    std::shared_ptr<std::vector<T>> values=std::make_shared<std::vector<T>>();
    JList() = default;
    JList(std::nullptr_t): values(nullptr) {}
    bool operator==(std::nullptr_t) const { return !values; }
    bool operator!=(std::nullptr_t) const { return bool(values); }
    void add(T v) { values->push_back(v); }
    T& get(int64_t i) { return values->at(i); }
    const T& get(int64_t i) const { return values->at(i); }
    void set(int64_t i,T v) { values->at(i)=v; }
    int32_t size() const { return int32_t(values->size()); }
    bool isEmpty() const { return values->empty(); }
    auto begin() { return values->begin(); } auto end() { return values->end(); }
};
struct JStringBuilder {
    JString value;
    JStringBuilder()=default;
    JStringBuilder(int32_t capacity) { value.value.reserve(std::max(0,capacity)); }
    operator JString() const {return value;}
    JString operator+(JString s) const {return value+s;}
    JStringBuilder(JString s):value(s){}
    template<class T> JStringBuilder& append(T s) { value+=s; return *this; }
    JString toString() const { return value; }
    int32_t length() const { return value.length(); }
    int32_t indexOf(JString s,int64_t start=0) const { return value.indexOf(s,start); }
    int32_t lastIndexOf(JString s,int64_t start=INT64_MAX) const { return value.lastIndexOf(s,start); }
    char16_t charAt(int64_t i) const { return value.charAt(i); }
    void setCharAt(int64_t i,char16_t c) { value.value.at(i)=c; }
    JStringBuilder& replace(int64_t a,int64_t b,JString s) { value.value.replace(a,b-a,s.value);return *this; }
    JStringBuilder& insert(int64_t a,JString s) { value.value.insert(a,s.value);return *this; }
};
struct JMath {
    template<class A,class B> static auto max(A a,B b) { using T=std::common_type_t<A,B>;return std::max<T>(a,b); }
    template<class A,class B> static auto min(A a,B b) { using T=std::common_type_t<A,B>;return std::min<T>(a,b); }
    template<class T> static auto abs(T n) { return std::abs(n); }
    static double sqrt(double n){return std::sqrt(n);} static double cbrt(double n){return std::cbrt(n);}
    static double pow(double a,double b){return std::pow(a,b);} static double rint(double n){return std::rint(n);}
    static int64_t round(double n){return std::llround(n);}
};
struct JCharacter { static bool isDigit(char16_t c){return c>=u'0'&&c<=u'9';} static int32_t getNumericValue(char16_t c){return c-u'0';} static char16_t forDigit(int64_t n,int64_t){return u'0'+n;} };
struct JArrays { template<class T> static void fill(JArray<T> a,T v){std::fill(a.values->begin(),a.values->end(),v);} };
struct JInteger { static constexpr int64_t MAX_VALUE=INT32_MAX; static int64_t parseInt(JString s){return std::stoll(std::string(s.ns().UTF8String));} };
struct JLong { static constexpr int64_t MAX_VALUE=INT64_MAX; };
struct JBigInteger {
    JString value;
    static JBigInteger valueOf(int64_t n){return {JString::valueOf(n)};}
    JBigInteger pow(int64_t n) const {
        std::string base(value.ns().UTF8String), total="1";
        for(int64_t k=0;k<n;k++) {
            std::vector<int> digits(total.size()+base.size(),0);
            for(int i=int(total.size())-1;i>=0;i--) for(int j=int(base.size())-1;j>=0;j--) digits[i+j+1]+=(total[i]-'0')*(base[j]-'0');
            for(int i=int(digits.size())-1;i>0;i--){digits[i-1]+=digits[i]/10;digits[i]%=10;}
            total.clear();bool zero=true;for(int d:digits){if(d||!zero){total+=char('0'+d);zero=false;}}if(total.empty())total="0";
        }
        return {JString(total.c_str())};
    }
    JString toString() const {return value;}
};
struct JBigDecimal {
    double value;
    static JBigDecimal valueOf(double n){return {n};} static JBigDecimal valueOf(int64_t n,int scale){return {double(n)/std::pow(10,scale)};}
    JBigDecimal stripTrailingZeros() const{return *this;} JString toPlainString() const{return JString::valueOf(value);}
};
JString MTStepStringKey(int64_t);
struct JavaArgumentError: std::invalid_argument { JavaArgumentError(JString text):std::invalid_argument(text.ns().UTF8String){} };
struct JContext {
    bool operator==(std::nullptr_t) const { return false; }
    bool operator!=(std::nullptr_t) const { return true; }
    template<class... T> JString getString(int64_t key,T... args) { return getString(MTStepStringKey(key),args...); }
    template<class... T> JString getString(JString key,T... args) {
        JString f; f.assign(NSLocalizedStringFromTable(key.ns(),@"Steps",nil));
        return JString::formatted(f,{JString::valueOf(args)...});
    }
    JContext getResources(){return *this;}
    JArray<JString> getStringArray(int64_t key);
};
