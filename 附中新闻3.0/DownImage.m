//
//  DownImage.m
//  sinaWeiboTest
//
//  Created by 朱 皓斌 on 12-8-22.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//
#import "DownImage.h"
@implementation DownImage
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize imageUrl;
@synthesize imageViewIndex;
#pragma mark
- (void)dealloc
{
    [activeDownload release];
    [imageConnection cancel];
    [imageConnection release];
    [super dealloc];
}
- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] delegate:self];
    
    self.imageConnection = conn;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}
#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.activeDownload = nil;
    self.imageConnection = nil;
}
//下载完成后将图片写入黑盒子，
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    newDownImage=image;
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    //NSString *Doc = [NSString stringWithFormat:@"%@/%@",documentDir,@"ImageFile"];
    NSArray *array=[imageUrl componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    [activeDownload writeToFile:path atomically:YES];
    NSString *urlpath = [NSString stringWithFormat:@"%@",path];
    self.activeDownload = nil;
    self.imageConnection = nil;
    [delegate appImageDidLoad:imageViewIndex urlImage:urlpath imageName:[array lastObject]]; //将视图tag和地址派发给实现类
    [image release];
}
@end