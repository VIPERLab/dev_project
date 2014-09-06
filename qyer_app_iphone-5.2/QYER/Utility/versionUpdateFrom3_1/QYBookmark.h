//
//  QYBookmark.h
//  QyGuide
//
//  Created by lide on 12-11-2.
//
//

#import <Foundation/Foundation.h>

@interface QYBookmark : NSObject <NSCoding>
{
    NSNumber    *_bookmarkNumber;
    NSString    *_bookmarkTitle;
    NSString    *_bookmarkFile;
    NSString    *_guideName;
    NSNumber    *_guideId;
    NSNumber    *_whetherAddBookmark;
    NSNumber    *_readingNow;
}

@property (retain, nonatomic) NSNumber *bookmarkNumber;
@property (retain, nonatomic) NSString *bookmarkTitle;
@property (retain, nonatomic) NSString *bookmarkFile;
@property (retain, nonatomic) NSString *guideName;
@property (retain, nonatomic) NSNumber *guideId;
@property (retain, nonatomic) NSNumber *whetherAddBookmark;
@property (retain, nonatomic) NSNumber *readingNow;

@end
