//
//  newsDetail.h
//  sflsNews_StoryBoard
//
//  Created by 朱 皓斌 on 12-11-28.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newsDetail : UIViewController{
    NSDictionary *news;
}
@property (retain, nonatomic) IBOutlet UILabel *newsInfoLabel;

@property (retain, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (retain, nonatomic) IBOutlet UIWebView *newsContentWebView;
@property(retain,nonatomic)NSDictionary *news;
@end
