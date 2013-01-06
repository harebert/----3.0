//
//  DownJSon.m
//  sflsNews_StoryBoard
//
//  Created by 朱 皓斌 on 12-11-30.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//

#import "DownJSon.h"

@implementation DownJSon

@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize channelID,page,JSonURl;
@synthesize imageViewIndex;
- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?channelID=%@&indexpage=%@",JSonURl,channelID,page]]] delegate:self];
    
    self.imageConnection = conn;
}

-(void)startDownloadWithURL:(NSString *)JSonURl_2 channelID:(NSString *)channelID_2 Page:(NSString *)page_2{
    forPendding=NO;
    JSonURl=JSonURl_2;
    channelID=channelID_2;
    page=page_2;
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?channelID=%@&indexpage=%@",JSonURl,channelID,page]]] delegate:self];
    NSLog(@"download is start with startdownloadwithurl");
    self.imageConnection = conn;

}

-(void)startAppendWithURL:(NSString *)JSonURl_2 channelID:(NSString *)channelID_2 Page:(NSString *)page_2;{
        forPendding=YES;
        JSonURl=JSonURl_2;
        channelID=channelID_2;
        page=page_2;
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?channelID=%@&indexpage=%@",JSonURl,channelID,page]]] delegate:self];
        NSLog(@"download is start with startappendwithurl:%@",[NSString stringWithFormat:@"%@?channelID=%@&indexpage=%@",JSonURl,channelID,page]);
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
    NSLog(@"connection didReceiveData:");
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
    //UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    //newDownImage=image;
    
    //self.activeDownload = nil;
    //self.imageConnection = nil;
    //[delegate appImageDidLoad:imageViewIndex urlImage:urlpath imageName:[array lastObject]];
    if (forPendding) {
        NSString *stringforappend=[[NSString alloc]initWithData:activeDownload encoding:NSUTF8StringEncoding];
        [delegate appJSonDidLoadForAppend:stringforappend];
        NSLog(@"here is finish download and return the string");
    }
    else{
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        //NSString *Doc = [NSString stringWithFormat:@"%@/%@",documentDir,@"ImageFile"];
        // NSArray *array=[imageUrl componentsSeparatedByString:@"/"];
        NSString *path=[NSString stringWithFormat:@"%@/%@.html",documentDir,channelID];
        [activeDownload writeToFile:path atomically:YES];
        NSString *urlpath = [NSString stringWithFormat:@"%@",path];
        [delegate appJSonDidLoad:imageViewIndex urlJSon:urlpath JsonFileName:[NSString stringWithFormat:@"%@.html",channelID]];//将视图tag和地址派发给实现类
         NSLog(@"here is finish download and return the fileaddress");

    }
        }
@end

