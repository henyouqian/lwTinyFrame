#include "stdafx.h"
#include "lwLocalization.h"


namespace lw{
    
    void getLocalStr(const char* str, std::string& oStr){
        NSString* inStr = [[NSString alloc] initWithUTF8String:str];
        NSString* outStr = NSLocalizedString(inStr,nil);
        oStr = [outStr UTF8String];
        [inStr release];
    }
    
} //namespace lw