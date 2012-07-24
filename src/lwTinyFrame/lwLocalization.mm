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
            NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
            if ( [language isEqualToString:@"en"] ){
                _currLan = lw::EN;
            }else if ( [language isEqualToString:@"zh-Hans"] ){
                _currLan = lw::CNS;
            }else if ( [language isEqualToString:@"zh-Hant"] ){
                _currLan = lw::CNT;
            }else if ( [language isEqualToString:@"ja"] ){
                _currLan = lw::JP;
            }else if ( [language isEqualToString:@"fr"] ){
                _currLan = lw::FR;
            }else if ( [language isEqualToString:@"de"] ){
                _currLan = lw::DE;
            }else{
                _currLan = lw::UNKNOWN;
            }
        }
        return _currLan;
    }
    
} //namespace lw