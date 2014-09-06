//
//  DesRequestUrlBuilder.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-7-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_DesRequestUrlBuilder_h
#define KwSing_DesRequestUrlBuilder_h

#include <string>

namespace KwTools {
    namespace Encrypt {

        //k歌专用des加密，user= prod= &source= 这几项会自动加上，外面不用加
        std::string CreateDesUrl(const std::string& strParams);

        //移x位异或a移位y异或b
        void Encrypt(char* memptr, int memlen);
        
        void Decrypt(char* memptr, int memlen);
        
        //异或-base64
        std::string EasyEncrypt(const char* memptr, int memlen);
        
        std::string EasyEncryptNum(int num,int key,int key2);
        int EasyDecryptNum(const std::string& str);
        
        void XOR( char *data, int datalen, const char *key, int keylen);
    }
}
#endif
