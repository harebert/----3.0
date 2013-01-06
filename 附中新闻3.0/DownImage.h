//
//  DownImage.h
//  sinaWeiboTest
//
//  Created by 朱 皓斌 on 12-8-22.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DownloaderDelegate;
@interface DownImage : NSObject {
    NSInteger imageViewIndex; //需要的视图tag
    
    id <DownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSString *imageUrl;
    UIImage *newDownImage;
}
@property (nonatomic) NSInteger imageViewIndex;
@property (nonatomic, assign) id <DownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString *imageUrl;
- (void)startDownload;
- (void)cancelDownload;
@end
@protocol DownloaderDelegate  //使用代理派发的原因在于，不知道何时下载完成，indexTag：将要显示图片的tag，imageUrl：图片的地址
- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)imageUrl imageName:(NSString *)imageName;
@end
