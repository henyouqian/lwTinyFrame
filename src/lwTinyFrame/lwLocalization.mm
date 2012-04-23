#include "stdafx.h"
#include "lwLocalization.h"
#include "lwSprite.h"

namespace {
    lw::Language _currLan = lw::NOT_INIT;
}


namespace lw{
    void getLocalStr(const char* str, std::string& oStr){
        NSString* inStr = [[NSString alloc] initWithUTF8String:str];
        NSString* outStr = NSLocalizedString(inStr,nil);
        oStr = [outStr UTF8String];
        [inStr release];
    }
    
    Language getLanguage(){
        if ( _currLan == lw::NOT_INIT ){
            std::string str;
            getLocalStr("__LANGUAGE__", str);
            if ( str.compare("EN") == 0 ){
                _currLan = lw::EN;
            }else if ( str.compare("CNS") == 0 ){
                _currLan = lw::CNS;
            }else if ( str.compare("CNT") == 0 ){
                _currLan = lw::CNT;
            }else if ( str.compare("JP") == 0 ){
                _currLan = lw::JP;
            }else{
                _currLan = lw::UNKNOWN;
            }
        }
        return _currLan;
    }
    
} //namespace lw