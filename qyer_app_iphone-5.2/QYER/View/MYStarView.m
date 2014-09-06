//
//  MYStarView.m
//
//  自定义的显示星星的view
//  Created by chenguanglin on 14-7-24.
//
//

#import "MYStarView.h"

@interface MYStarView()

@property (nonatomic, strong) NSMutableArray *stars;

@end

@implementation MYStarView



- (void)setStarCount:(float)starCount
{
    _starCount = starCount;
    
    CGFloat starW = 15;
    CGFloat starH = 15;
    CGFloat starY = 0;
    
    CGFloat margin = 5;
    _stars = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        CGFloat starX = i * (starW + margin);
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake(starX, starY, starW, starH)];
        star.backgroundColor = [UIColor clearColor];
        star.image = [UIImage imageNamed:@"star2_微锦囊"];
        [self addSubview:star];
        [_stars addObject:star];
    }
    
    int j = 0;
    for (j = 0; j < starCount; j++) {
        UIImageView *star = self.stars[j];
        star.image = [UIImage imageNamed:@"star1_微锦囊"];
    }
    
    if (j > starCount) {
        UIImageView *star = self.stars[j - 1];
        star.image = [UIImage imageNamed:@"star3_微锦囊"];
    }

}

@end
