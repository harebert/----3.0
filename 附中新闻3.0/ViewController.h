//
//  ViewController.h
//  附中新闻3.0
//
//  Created by 朱 皓斌 on 12-12-7.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownImage.h"
#import "newsDetail.h"
#import "SBJSON.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"
#import "DownJSon.h"
#import "EGORefreshTableHeaderView.h"
#import "sqlite3.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DownloaderDelegate,SBJsonProtocol,DownJSonDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate>{
    NSMutableArray *tableViewDataArray;
    int page;
    int channelID;
    UIView *channelButtonBorder;
    UILabel *channelButtonBorderLabel;
    UIButton *pre_channelButton;
    UILabel *touban_title_label;
    IBOutlet UIButton *showMoreButton;
    UIActivityIndicatorView *loadingViewIndicator;
    int loginTimes;
    ///EgoRefresh
    BOOL isflage;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSDictionary *theFirstNews;
@public
    sqlite3 *db;
    
}
@property (retain, nonatomic) IBOutlet UIImageView *titleImageView;
- (IBAction)showMore:(UIButton *)sender;
@property(retain,nonatomic)IBOutlet UIButton *showMoreButton;
@property (retain, nonatomic) IBOutlet UITableView *listTableView;
@property(retain,nonatomic)NSMutableArray *tableViewDataArray;
@property(assign,nonatomic)int page;
@property(assign,nonatomic)int channelID;
@property(retain,nonatomic)UIView *channelButtonBorder;
@property(retain,nonatomic)UILabel *channelButtonBorderLabel;
//EgoRefresh
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end

