//
//  AuthorityInfoManager.mm
//  KwSing
//
//  Created by 永杰 单 on 12-9-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AuthorityInfoManager.h"
#include "KwTools.h"
#include "HttpRequest.h"
#include "MessageManager.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "KuwoLog.h"
#include "KuwoConstants.h"
#include <string>
#include "KwUMengElement.h"
#include "UMengLog.h"

void CAuthorityInfoManager::GetAuthorityInfo(){
    
    KwConfig::GetConfigureInstance()->SetConfigBoolValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, true);
  
    KS_BLOCK_DECLARE{
        std::string strParam="type=ipdomain";
        
        std::string strEncryptParam=KwTools::Encrypt::CreateDesUrl(strParam);
        //NSLog(@"%s", strEncryptParam.c_str());
        
        std::string strData;
        
        bool b_ret = CHttpRequest::QuickSyncGet(strEncryptParam, strData);
//        NSLog(@"%s", strData.c_str());
                
        KS_BLOCK_DECLARE{
            if (!b_ret || strData.empty()) {
                KwConfig::GetConfigureInstance()->SetConfigBoolValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, true);
            }
            
            std::vector<std::string> vecDatas;
            KwTools::StringUtility::Tokenize(strData,"\r\n",vecDatas);
            
            if (vecDatas.empty()) {
                KwConfig::GetConfigureInstance()->SetConfigBoolValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, true);
            }
            
            for (int i = 0; i < vecDatas.size(); ++i) {
                std::vector<std::string> vecKeyValue;
                KwTools::StringUtility::Tokenize(vecDatas[i],"=",vecKeyValue);
                if (2 == vecKeyValue.size()) {
                    if ("RESULT" == vecKeyValue[0]) {
                        if(0 == vecKeyValue[1].compare("0")){
                            KwConfig::GetConfigureInstance()->SetConfigBoolValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, false);
                        }else {
                            KwConfig::GetConfigureInstance()->SetConfigBoolValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, true);
                        }
                    } else if("IP" == vecKeyValue[0]) {
                        KwConfig::GetConfigureInstance()->SetConfigStringValue(AUTHORITY_GROUP, AUTHORITY_IP, vecKeyValue[1]);
                    } else if("DOMAIN" == vecKeyValue[0]) {
                        KwConfig::GetConfigureInstance()->SetConfigStringValue(AUTHORITY_GROUP, AUTHORITY_DOMAIN, vecKeyValue[1]);
                    }
                }
            }
            
            if (b_ret) {
                std::string str_network = CHttpRequest::GetNetWorkProviderName();
                std::string str_uid = "";
                str_uid = [KwConfig::GetConfigureInstance()->GetUserUUID() UTF8String];
                std::string str_ip;
                std::string str_area;
                int n_authorized(0);
                KwConfig::GetConfigureInstance()->GetConfigStringValue(AUTHORITY_GROUP, AUTHORITY_IP, str_ip);
                KwConfig::GetConfigureInstance()->GetConfigStringValue(AUTHORITY_GROUP, AUTHORITY_DOMAIN, str_area);
                KwConfig::GetConfigureInstance()->GetConfigIntValue(AUTHORITY_GROUP, AUTHORITY_AUTHORIZED, n_authorized);
                
                RTLog_Authorization(AR_SUCCESS, str_network.c_str(), str_uid.c_str(), str_ip.c_str(), str_area.c_str(), n_authorized);
                UMengLog(KS_AUTHORIZATION, "0");
            }else {
                RTLog_Authorization(AR_FAIL, NULL, NULL, NULL, NULL, 1);
                UMengLog(KS_AUTHORIZATION, "1");
            }
        
        }
        KS_BLOCK_SYNRUN();
    }
    KS_BLOCK_RUN_THREAD();
}
