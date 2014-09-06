//
//  QYBookmark.m
//  QyGuide
//
//  Created by lide on 12-11-2.
//
//

#import "QYBookmark.h"

@implementation QYBookmark

@synthesize bookmarkNumber = _bookmarkNumber;
@synthesize bookmarkTitle = _bookmarkTitle;
@synthesize bookmarkFile = _bookmarkFile;
@synthesize guideName = _guideName;
@synthesize guideId = _guideId;
@synthesize whetherAddBookmark = _whetherAddBookmark;
@synthesize readingNow = _readingNow;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:_bookmarkNumber forKey:@"bookmarkNumber"];
    [aCoder encodeObject:_bookmarkTitle forKey:@"bookmarkTitle"];
    [aCoder encodeObject:_bookmarkFile forKey:@"bookmarkFile"];
    [aCoder encodeObject:_guideName forKey:@"guideName"];
    [aCoder encodeObject:_guideId forKey:@"guideId"];
    [aCoder encodeObject:_whetherAddBookmark forKey:@"whetherAddBookmark"];
    [aCoder encodeObject:_readingNow forKey:@"readingNow"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self != nil)
    {
        self.bookmarkNumber = [aDecoder decodeObjectForKey:@"bookmarkNumber"];
        self.bookmarkTitle = [aDecoder decodeObjectForKey:@"bookmarkTitle"];
        self.bookmarkFile = [aDecoder decodeObjectForKey:@"bookmarkFile"];
        self.guideName = [aDecoder decodeObjectForKey:@"guideName"];
        self.guideId = [aDecoder decodeObjectForKey:@"guideId"];
        self.whetherAddBookmark = [aDecoder decodeObjectForKey:@"whetherAddBookmark"];
        self.readingNow = [aDecoder decodeObjectForKey:@"readingNow"];
    }
    return self;
}

- (id)copyWithZone: (NSZone*)zone{
    
    QYBookmark *gd = [[[self class] allocWithZone:zone] init];
    
    gd.bookmarkNumber = _bookmarkNumber;
    gd.bookmarkTitle = _bookmarkTitle;
    gd.bookmarkFile = _bookmarkFile;
    gd.guideName = _guideName;
    gd.guideId = _guideId;
    gd.whetherAddBookmark = _whetherAddBookmark;
    gd.readingNow = _readingNow;
    
    return gd;
}


- (id)init
{
    self = [super init];
    if(self != nil)
    {
    
    }
    return self;
}

- (void)dealloc
{
    QY_SAFE_RELEASE(_bookmarkNumber);
    QY_SAFE_RELEASE(_bookmarkTitle);
    QY_SAFE_RELEASE(_bookmarkFile);
    QY_SAFE_RELEASE(_guideName);
    QY_SAFE_RELEASE(_guideId);
    QY_SAFE_RELEASE(_whetherAddBookmark);
    QY_SAFE_RELEASE(_readingNow);
    
    [super dealloc];
}

@end
