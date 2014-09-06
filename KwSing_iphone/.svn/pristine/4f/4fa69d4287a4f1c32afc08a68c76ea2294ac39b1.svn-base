//
//  SearchBarView.h
//  KWPlayer
//
//  Created by FelixLee on 11-8-15.
//  Copyright 2011年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SEARCH_BAR_HEIGHT 42

@interface SearchBackgroundView : UIView 

@end

@interface SearchBarView : UISearchBar {
	UIView* _backgroundView;
    UIButton* _btnSearch;
    UIButton* _btnVoiceSrh;
    UIButton* _btnCancel;
    
    //BOOL _bIOS7;
    
    BOOL _eidting;
}

@property (nonatomic, retain) UIView* backgroundView;
@property (nonatomic, retain) UIButton* btnSearch;
@property (nonatomic, retain) UIButton* btnVoiceSrh;
@property (nonatomic, retain) UIButton* btnCancel;
@property (nonatomic, assign) BOOL editing;

- (void) addSearchButtonWithTarget:(id)target action:(SEL)action;
- (void) addSearchCancelButtonWithTarget:(id)target action:(SEL)action;

//- (void) showSearchCancelButton:(BOOL)show;

@end
