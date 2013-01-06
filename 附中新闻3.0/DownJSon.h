//
//  DownJSon.h
//  sflsNews_StoryBoard
//
//  Created by 朱 皓斌 on 12-11-30.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DownJSonDelegate;
@interface DownJSon : NSObject{
    NSInteger imageViewIndex; //需要的视图tag
    
    id <DownJSonDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSString *channelID;
    NSString *page;
    NSString *JSonURl;
    //NSString *stringForPending;
    BOOL forPendding;
    
    UIImage *newDownImage;
}
@property (nonatomic) NSInteger imageViewIndex;
@property (nonatomic, assign) id <DownJSonDelegate> delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString *channelID;
@property (nonatomic, retain) NSString *page;
@property (nonatomic, retain) NSString *JSonURl;
- (void)startDownload;
- (void)startDownloadWithURL:(NSString *)JSonURl_2 channelID:(NSString *)channelID_2 Page:(NSString *)page_2;
- (void)startAppendWithURL:(NSString *)JSonURl_2 channelID:(NSString *)channelID_2 Page:(NSString *)page_2;
- (void)cancelDownload;
@end
@protocol DownJSonDelegate
//下载了Json保存为文件
- (void)appJSonDidLoad:(NSInteger)indexTag urlJSon:(NSString *)JsonUrl JsonFileName:(NSString *)fileName;
//下载了Json后返回string
- (void)appJSonDidLoadForAppend:(NSString *)JsonString;
@end

