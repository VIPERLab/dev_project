//
//  ToString.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ToString_h
#define KwSing_ToString_h

#include <typeinfo>
#include <string>

namespace KwTools
{
    namespace Convert
    {
        template<typename T>
        std::string ConvertToString(const T& val)
        {
            return typeid(val).name();
        }

        std::string ConvertToString(bool val);

        std::string ConvertToString(const std::string& val);

        std::string ConvertToString(unsigned char val);

        std::string ConvertToString(char val);

        std::string ConvertToString(short val);

        std::string ConvertToString(unsigned short val);

        std::string ConvertToString(unsigned int val);

        std::string ConvertToString(int val);

        std::string ConvertToString(long val);

        std::string ConvertToString(unsigned long val);

        std::string ConvertToString(const unsigned long long& val);

        std::string ConvertToString(const long long& val);

        std::string ConvertToString(const double& val);

        std::string ConvertToString(float val);

        std::string ConvertToString(char* val);

        std::string ConvertToString(const char* val);

        std::string ConvertToString(const NSString* val);

    }//namespace Convert
}//namespace KwTools

#endif
