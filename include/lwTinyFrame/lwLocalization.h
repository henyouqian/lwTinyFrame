#ifndef __LW_LOCALIZATION_H__
#define __LW_LOCALIZATION_H__

namespace lw {
    void getLocalStr(const char* str, std::string& oStr);
    
    enum Language{
        EN,
        CNS,
        CNT,
        JP,
        FR,
        DE,
        UNKNOWN,
        NOT_INIT,
    };
    Language getLanguage();
}

#endif //__LW_LOCALIZATION_H__