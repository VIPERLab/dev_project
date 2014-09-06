//
//  ToString.cpp
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "ToString.h"

namespace KwTools
{
    namespace Convert
    {

        std::string ConvertToString(bool val)
        {
            return val ? "true" : "false";
        }

        std::string ConvertToString(const std::string& val)
        {
            return val;
        }

        std::string ConvertToString(unsigned char val)
        {
            char pData[4];
            sprintf(pData, "%c", val);
            return pData;
        }

        std::string ConvertToString(char val)
        {
            char pData[8];
            sprintf(pData, "%c", val);
            return pData;
        }

        std::string ConvertToString(short val)
        {
            char pData[8];
            sprintf(pData, "%d", val);
            return pData;
        }

        std::string ConvertToString(unsigned short val)
        {
            char pData[8];
            sprintf(pData, "%u", val);
            return pData;
        }

        std::string ConvertToString(unsigned int val)
        {
            char pData[12];
            sprintf(pData, "%u", val);
            return pData;
        }

        std::string ConvertToString(int val)
        {
            char pData[12];
            sprintf(pData, "%d", val);
            return pData;
        }

        std::string ConvertToString(long val)
        {
            char pData[12];
            sprintf(pData, "%ld", val);
            return pData;
        }

        std::string ConvertToString(unsigned long val)
        {
            char pData[12];
            sprintf(pData, "%lu", val);
            return pData;
        }

        std::string ConvertToString(const unsigned long long& val)
        {
            char pData[21];
            sprintf(pData, "%llu", val);
            return pData;
        }

        std::string ConvertToString(const long long& val)
        {
            char pData[21];
            sprintf(pData, "%lld", val);
            return pData;
        }

        std::string ConvertToString(const double& val)
        {
            char pData[24];
            
            long long intValue = static_cast<long long>(val);
            
            if(ABS(val - intValue) < DBL_EPSILON)
                return ConvertToString(intValue);
            
            double absVal = ABS(val);
            if(absVal > 1000000000 || absVal < 0.005)
                sprintf(pData, "%e", val);
            else
                sprintf(pData, "%.4f", val);
            return pData;
        }

        std::string ConvertToString(float val)
        {
            char pData[16];
            
            long long intValue = static_cast<long long>(val);
            
            if(ABS(val - intValue) < FLT_EPSILON)
                return ConvertToString(intValue);
            
            float absVal = ABS(val);
            if(absVal > 1000000000 || absVal < 0.005)
                sprintf(pData, "%e", val);
            else
                sprintf(pData, "%.4f", val);
            return pData;
        }

        std::string ConvertToString(char* val)
        {
            return val;
        }

        std::string ConvertToString(const char* val)
        {
            return val;
        }

        std::string ConvertToString(const NSString* val)
        {
            return [val UTF8String];
        }
        
    }//namespace Convert
}//namespace KwTools