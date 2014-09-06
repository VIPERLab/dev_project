//
//  DesRequestUrlBuilder.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-7-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "Encrypt.h"
#include <math.h>
#include "base64.h"
#include "des1.h"
#include "KuwoConstants.h"
#include "StringUtility.h"
#include "ToString.h"
#include "Encoding.h"

const int XOR_KEY1_LEN = 13;
#define KT_ECRP_KEY1 "KoOtOiTvINGwd"

const int XOR_KEY2_LEN = 23;
#define KT_ECRP_KEY2 "_Y8g2E6n0E1i7L5t2IoOoNk"

const int MOVE_POS1 = 133;
const int MOVE_POS2 = 71;

namespace KwTools
{
	namespace Encrypt
	{
        std::string CreateDesUrl(const std::string& strParams)
        {
            std::string strEncrypted;
            if (strParams.empty()
                ||encode_msg(strEncrypted
                             , KWSING_ENCRYPT_KEY
                             , KwTools::StringUtility::Format("%s&user=%s&prod=%s&source=%s",strParams.c_str(),DEVICE_ID,KWSING_CLIENT_VERSION_STRING,KWSING_INSTALL_SOURCE).c_str()
                             )<=0
                )
            {
                return "";
            }
            return KWSING_SERVER_URL+Encoding::UrlEncode(strEncrypted);
        }
        
		void XOR( char *data, int datalen, const char *key, int keylen)
		{
			for (int i=0; i<datalen; i++)
				*(data+i) ^= *(key+i%keylen);
		}
        
		void MOVE( char *data, int datalen, int pos )
		{
			if (pos == 0 || datalen ==0 || pos%datalen == 0)
				return;
            
			int realpos = abs(pos);
			while (realpos > datalen)
				realpos -= datalen;
            
			char* tmp = new char[realpos];
			char* ptr;
			if (pos > 0)
			{
				memcpy( tmp, data+datalen-realpos, realpos );
				ptr = data+datalen-1;
				for (; ptr>data+realpos-1; ptr--)
					*ptr = *(ptr-realpos);
				memcpy( data, tmp, realpos );
			}
			else
			{
				memcpy( tmp, data, realpos );
				ptr = data;
				for (; ptr<data+datalen-realpos; ptr++)
					*ptr = *(ptr+realpos);
				memcpy( data + datalen - realpos, tmp, realpos );
			}
			delete []tmp;
		}
        
		void Encrypt(char* memptr, int memlen)
		{
            char key1[XOR_KEY1_LEN];
            memcpy(key1,KT_ECRP_KEY1,XOR_KEY1_LEN);
            MOVE( memptr, memlen,MOVE_POS1);
            XOR( memptr, memlen, key1, XOR_KEY1_LEN );
            char key2[XOR_KEY2_LEN];
            memcpy(key2,KT_ECRP_KEY2,XOR_KEY2_LEN);
            MOVE( memptr, memlen,-MOVE_POS2);
            XOR( memptr, memlen, key2, XOR_KEY2_LEN );
		}
        
		void Decrypt(char* memptr, int memlen)
		{
            char key2[XOR_KEY2_LEN];
            memcpy(key2,KT_ECRP_KEY2,XOR_KEY2_LEN);
            XOR( memptr, memlen, key2, XOR_KEY2_LEN );
            MOVE( memptr, memlen,MOVE_POS2);
            
            char key1[XOR_KEY1_LEN];
            memcpy(key1,KT_ECRP_KEY1,XOR_KEY1_LEN);
            XOR( memptr, memlen, key1, XOR_KEY1_LEN );
            MOVE( memptr, memlen,-MOVE_POS1);
		}
        
        std::string EasyEncrypt(char* memptr, int memlen)
        {
            char* temp=new char[memlen];
            memcpy(temp,memptr,memlen);
            XOR(temp, memlen, KWSING_ENCRYPT_KEY, strlen(KWSING_ENCRYPT_KEY));
            int dstLen=Base64::Base64EncodeLength(memlen);
            char* dst=new char[dstLen+1];
            memset(dst,0,dstLen+1);
            dstLen=Base64::Base64Encode(temp, memlen, dst, dstLen);
            return std::string(dst,dstLen);
        }

#define EASY_ENCRYPT_NUM_KEY1 0x653cb8df
#define EASY_ENCRYPT_NUM_KEY2 0x3a7c866d
        std::string EasyEncryptNum(int num,int key1,int key2)
        {
            int n1=num^EASY_ENCRYPT_NUM_KEY1^key1;
            int n2=num^EASY_ENCRYPT_NUM_KEY2^key1;
            int n3=key1^n1^n2;
            int n4=n3^key2;
            char src[16];
            *(int*)src=n1;
            *(int*)&src[4]=n2;
            *(int*)&src[8]=n3;
            *(int*)&src[12]=n4;
            int nDesLen=Base64::Base64EncodeLength(16);
            char* pDes=new char[nDesLen+1];
            Base64::Base64Encode(src, 16, pDes, nDesLen);
            return std::string(pDes,nDesLen);
        }
        
        int EasyDecryptNum(const std::string& str)
        {
            if (str.empty()) {
                return 0;
            }
            int nDesLen=Base64::Base64DecodeLength(str.size())+1;
            char* pDes=new char[nDesLen];
            memset(pDes, 0, nDesLen);
            if (Base64::Base64Decode(str.c_str(), str.size(), pDes, nDesLen)!=16) {
                return 0;
            }
            int n1=*(int*)pDes;
            int n2=*(int*)&pDes[4];
            int n3=*(int*)&pDes[8];
            //int n4=*(int*)&pDes[12];
            int key1=n3^n1^n2;
            //int key2=n4^n3;
            int num1=n1^EASY_ENCRYPT_NUM_KEY1^key1;
            int num2=n2^EASY_ENCRYPT_NUM_KEY2^key1;
            if (num1!=num2) {
                return 0;
            }
            return num1;
        }
    }
}