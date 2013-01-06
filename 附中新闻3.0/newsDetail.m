//
//  newsDetail.m
//  sflsNews_StoryBoard
//
//  Created by 朱 皓斌 on 12-11-28.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//

#import "newsDetail.h"

@interface newsDetail ()

@end

@implementation newsDetail
@synthesize news,newsContentWebView,newsInfoLabel,newsTitleLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"news:%@",news);
    if ([UIScreen mainScreen].bounds.size.height==568) {
        newsContentWebView.frame=CGRectMake(newsContentWebView.frame.origin.x, newsContentWebView.frame.origin.y, newsContentWebView.frame.size.width, newsContentWebView.frame.size.height+88);
    }
    self.title=[news objectForKey:@"Title"];
    [newsContentWebView loadHTMLString:[news objectForKey:@"content"] baseURL:nil];
    newsTitleLabel.text=[news objectForKey:@"Title"];
    newsInfoLabel.text=[NSString stringWithFormat:@"作者：%@ 点击：%@",[news objectForKey:@"Author"],[news objectForKey:@"Hits"]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [newsContentWebView release];
    [newsTitleLabel release];
    [newsInfoLabel release];
    [super dealloc];
}
@end
