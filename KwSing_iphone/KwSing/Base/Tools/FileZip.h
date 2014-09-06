//
//  FileZip.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <string>
#import <vector>

namespace KwTools
{
	namespace Filezip
	{
		BOOL Compress(const std::vector<std::string>& vecSrcFiles,const std::string& strDesFile);
        BOOL Compress(NSArray* arraySrcFiles,NSString* strDesFile);

		BOOL UnCompress(const std::string& strSrcFile,const std::string& strUnZipDir,std::vector<std::string>& vecDesFiles,BOOL bOverWrite=TRUE);
        BOOL UnCompress(NSString* strSrcFile,NSString* strUnZipDir,NSMutableArray* arrayDesFiles=NULL,BOOL bOverWrite=TRUE);
	}
}