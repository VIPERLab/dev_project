//
//  FileZip.mm
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "FileZip.h"
#include "ZipArchive.h"
#include "KwDir.h"

namespace KwTools
{
	namespace Filezip
	{
        BOOL Compress(const std::vector<std::string>& vecSrcFiles,const std::string& strDesFile)
        {
            ZipArchive* zip=[[ZipArchive alloc] init];
            BOOL ret=[zip CreateZipFile2:[NSString stringWithUTF8String:strDesFile.c_str()]];
            if (!ret) {
                [zip release];
                return FALSE;
            }
            for (int i=0; i<vecSrcFiles.size(); ++i) {
                NSString* strFilePathName=[NSString stringWithUTF8String:vecSrcFiles[i].c_str()];
                NSString* strFileName=KwTools::Dir::GetFileName(strFilePathName);
                ret=[zip addFileToZip:strFilePathName newname:strFileName];
                if (!ret) {
                    [zip release];
                    return FALSE;
                }
            }
            ret=[zip CloseZipFile2];
            [zip release];
            return ret;
        }
        
        BOOL Compress(NSArray* arraySrcFiles,NSString* strDesFile)
        {
            if (!arraySrcFiles || !strDesFile) {
                return FALSE;
            }
            ZipArchive* zip=[[ZipArchive alloc] init];
            BOOL ret=[zip CreateZipFile2:strDesFile];
            if (!ret) {
                [zip release];
                return FALSE;
            }
            for (id f in arraySrcFiles) {
                 if ([[f class] isSubclassOfClass:[NSString class]]) {
                     ret=[zip addFileToZip:f newname:KwTools::Dir::GetFileName(f)];
                     if (!ret) {
                         [zip release];
                         return FALSE;
                     }
                }
            }
            ret=[zip CloseZipFile2];
            [zip release];
            return ret;
        }
        
		BOOL UnCompress(const std::string& strSrcFile,const std::string& strUnZipDir,std::vector<std::string>& vecDesFiles,BOOL bOverWrite/*=TRUE*/)
        {
            vecDesFiles.clear();
            
            ZipArchive* zip=[[ZipArchive alloc] init];
            BOOL ret=[zip UnzipOpenFile:[NSString stringWithUTF8String:strSrcFile.c_str()]];
            if (!ret) {
                [zip release];
                return FALSE;
            }
            NSMutableArray* array=[[NSMutableArray alloc] init];
            ret=[zip UnzipFileTo:[NSString stringWithUTF8String:strUnZipDir.c_str()] overWrite:bOverWrite filepaths:array];
            [zip release];
            if (ret) {
                for (NSString* f in array) {
                    vecDesFiles.push_back([f UTF8String]);
                }
            }
            [array release];
            return ret;
        }
		
        BOOL UnCompress(NSString* strSrcFile,NSString* strUnZipDir,NSMutableArray* arrayDesFiles/*=NULL*/,BOOL bOverWrite/*=TRUE*/)
        {
            if (arrayDesFiles) {
                [arrayDesFiles removeAllObjects];
            }
            ZipArchive* zip=[[ZipArchive alloc] init];
            BOOL ret=[zip UnzipOpenFile:strSrcFile];
            if (!ret) {
                [zip release];
                return FALSE;
            }
            ret=[zip UnzipFileTo:strUnZipDir overWrite:bOverWrite filepaths:arrayDesFiles];
            [zip release];
            return ret;
        }
	}
}





