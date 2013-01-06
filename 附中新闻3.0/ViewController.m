//
//  ViewController.m
//  sflsNews_StoryBoard
//
//  Created by 朱 皓斌 on 12-11-20.
//  Copyright (c) 2012年 朱 皓斌. All rights reserved.
//

#import "ViewController.h"
#import "JSON.h"
#import <QuartzCore/QuartzCore.h>
@interface ViewController ()

@end

@implementation ViewController
@synthesize tableViewDataArray,listTableView,titleImageView,showMoreButton,page,channelID,channelButtonBorder,channelButtonBorderLabel;
#pragma protocol
-(void)appJSonDidLoad:(NSInteger)indexTag urlJSon:(NSString *)JsonUrl JsonFileName:(NSString *)fileName{
    //NSLog(@"abced");
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *jsonString=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",documentDir,fileName] encoding:NSUTF8StringEncoding error:nil];
    // NSLog(@"%@",jsonString);
    SBJSON *parser = [[SBJSON alloc] init];
    parser.delegate=self;
    [parser objectWithString:jsonString error:nil];
}
-(void)appJSonDidLoadForAppend:(NSString *)JsonString{
    NSLog(@"here is adding string:%@",JsonString);
    SBJSON *parser = [[SBJSON alloc] init];
    parser.delegate=self;
    [parser objectWithString:JsonString error:nil];
    
}
-(void)parsedJson:(id)arrayOrDic{
    NSLog(@"!!here is protocol array: and page is %i",page);
    
    if (page<2) {
        
        
        NSMutableArray *newarray=[arrayOrDic objectForKey:@"news"];
        self.tableViewDataArray=[[NSMutableArray alloc]initWithArray:newarray];
        DownImage *titleImage=[[DownImage alloc]init];
        //↓头版头条↓
        NSArray *touban_news=[arrayOrDic objectForKey:@"touban_news"];
        theFirstNews=[[touban_news objectAtIndex:0]retain];
        titleImage.imageUrl=[theFirstNews objectForKey:@"DefaultPicUrl"];
        
        NSString *imageName=[[titleImage.imageUrl componentsSeparatedByString:@"/"] lastObject];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDir =[NSString stringWithFormat:@"%@/%@",[documentPaths objectAtIndex:0],imageName] ;
        //添加相应触摸事件
        UITapGestureRecognizer *titleImageViewTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTitleImageView)];
        [titleImageView addGestureRecognizer:titleImageViewTap];
        //添加完毕
        if ([[NSFileManager defaultManager]fileExistsAtPath:documentDir]) {
            titleImageView.image=[UIImage imageWithContentsOfFile:documentDir];
        //如果有现成图片则调用，否则下载
        }
        else{
        
        //NSLog(@"url:%@",titleImage.imageUrl);
        titleImage.imageViewIndex=100000;
        titleImage.delegate=self;
        [titleImage startDownload];
        }
        touban_title_label.text=[theFirstNews objectForKey:@"Title"];
        [listTableView reloadData];
        
    }
    else{
        NSLog(@"add obj");
        NSArray *newarray=[arrayOrDic objectForKey:@"news"];
        [self.tableViewDataArray addObjectsFromArray:newarray];
        [listTableView reloadData];
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:.3];
        
        [loadingViewIndicator stopAnimating];
    }
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
}
#pragma program
- (void)viewDidLoad
{
    //sleep(3);
    if ([UIScreen mainScreen].bounds.size.height==568) {
        NSLog(@"this is iphone5");
        self.listTableView.frame=CGRectMake(listTableView.frame.origin.x, listTableView.frame.origin.y, listTableView.frame.size.width, listTableView.frame.size.height+88);
    }
    
    //评分系统
    NSString *rateFilePath;
    char *errorMsg;
    rateFilePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"rate.sqlite"];
    NSLog(@"%@",rateFilePath);
    sqlite3_open( [rateFilePath UTF8String],&db);
    NSString * isFirst=@"select * from rateDB";
    sqlite3_stmt *isFirststatement;
    sqlite3_prepare_v2(db, [isFirst UTF8String], -1, &isFirststatement, nil);
    if (sqlite3_step(isFirststatement)==SQLITE_ROW) {
        int times;
        times= sqlite3_column_int(isFirststatement, 1);
        loginTimes=times;
        if (times==5) {
            NSLog(@"5 times");
            UIAlertView *rateAlertView=[[UIAlertView alloc]initWithTitle:@"请对APP评分" message:@"您已经使用本APP一段时间了，感谢您的支持的同时，如果支持此APP的发展，请拨冗前往进行评分" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去评分", nil];
            rateAlertView.tag=2;
            [rateAlertView show];
            NSString *addTimes=[NSString stringWithFormat: @"update rateDB set loginTimes=loginTimes+1 where rateId=1"];
            sqlite3_exec(db, [addTimes UTF8String], NULL, NULL, &errorMsg);
        }else{
            NSString *addTimes=[NSString stringWithFormat: @"update rateDB set loginTimes=loginTimes+1 where rateId=1"];
            sqlite3_exec(db, [addTimes UTF8String], NULL, NULL, &errorMsg);
        }
        //NSString *insertRecord=[NSString stringWithFormat: @"INSERT OR REPLACE INTO 'rateDB' ('rateId','loginTimes') VALUES(1,1)"];
        //sqlite3_exec(db, [insertRecord UTF8String], NULL, NULL, &errorMsg);
    }
    else{
        
        if (sqlite3_open([rateFilePath UTF8String], &db)!=SQLITE_OK) {//打开数据库失败
            NSLog(@"database error");
        }
        
        
        else{//打开数据库成功
            
            NSString *creatSQL=@"CREATE TABLE IF NOT EXISTS 'rateDB'('rateID' INTEGER primary key,'loginTimes' INTEGER DEFAULT 1)";
            if (sqlite3_exec(db,[creatSQL UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
            {
                //打开表、创建表失败
            }
            else
            {//打开表成功，写入数据库；
                NSString *insertRecord=[NSString stringWithFormat: @"INSERT OR REPLACE INTO 'rateDB' ('rateId','loginTimes') VALUES(1,1)"];
                sqlite3_exec(db, [insertRecord UTF8String], NULL, NULL, &errorMsg);
            }
        }
    }
    //评分系统
    
    //EgoRefresh
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.bounds.size.height, self.listTableView.frame.size.width, self.view.bounds.size.height)];
        view1.delegate = self;
        [self.listTableView addSubview:view1];
        _refreshHeaderView = view1;
        //[view1 release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
     
    //EgoRefresh
    
    
    page=1;
    channelID=1000;
    //navigationControllerBanner
    self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:0.47 green:0 blue:0 alpha:1];
    self.title=@"附中新闻";
    
    
    [listTableView setDelegate:self];
    [listTableView setDataSource:self];
    //listTableView.frame=CGRectMake(listTableView.frame.origin.x, 100, listTableView.frame.size.width, listTableView.frame.size.height);
    
    //栏目按钮
    UIView *channelButtonBack=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    channelButtonBack.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"channelButtonBack.png"]];
    channelButtonBack.layer.opacity=0.9;
    channelButtonBack.layer.shadowColor=[UIColor grayColor].CGColor;
    channelButtonBack.layer.shadowRadius=10;
    channelButtonBack.layer.shadowOpacity=1;
    //移动的边框
    channelButtonBorder=[[UIView alloc]initWithFrame:CGRectMake(5, 2.5, 50, 25)];
    channelButtonBorder.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ButtonBak.png"]];
    channelButtonBorder.layer.borderColor=[UIColor redColor].CGColor;
    channelButtonBorder.layer.borderWidth=0;
    channelButtonBorder.layer.cornerRadius=3;
    channelButtonBorder.layer.shadowColor=[UIColor grayColor].CGColor;
    channelButtonBorder.layer.shadowOpacity=1;
    channelButtonBorder.layer.opacity=1;
    channelButtonBorderLabel=[[UILabel alloc]initWithFrame:channelButtonBorder.frame];
    //channelButtonBorderLabel.text=@"学校概况";
    channelButtonBorderLabel.font=[UIFont systemFontOfSize:10];
    channelButtonBorderLabel.backgroundColor=[UIColor clearColor];
    //channelButtonBorderLabel.textColor=[UIColor whiteColor];
    [channelButtonBorder addSubview:channelButtonBorderLabel];
    [channelButtonBack addSubview:channelButtonBorder];
    //添加channel按钮
    int i=1;
    NSArray *channel=[[NSArray alloc]initWithObjects:@"首页",@"校务",@"德育",@"学生",@"教科",@"外事", nil];
    NSArray *channelID_array=[[NSArray alloc]initWithObjects:@"1000",@"1002",@"1003",@"1004",@"1006",@"1007", nil];
    for (i=0; i<=5; i++) {
        
        UIButton *channelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        channelButton.frame=CGRectMake(5+i+i*50, 2.5, 50, 25);
        [channelButton setTitle:[channel objectAtIndex:i]  forState:UIControlStateNormal];
        channelButton.tag=[[channelID_array objectAtIndex:i]intValue];
        //NSLog(@"viewdidload:%@,%i",[channel objectAtIndex:i],[[channelID_array objectAtIndex:i]intValue]);
        //channelButton.tintColor=[UIColor redColor];
        //channelButton.backgroundColor=[UIColor redColor];
        [channelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
        channelButton.titleLabel.font=[UIFont systemFontOfSize:16];
        [channelButton addTarget:self action:@selector(changeChannel:) forControlEvents:UIControlEventTouchUpInside];
        [channelButtonBack addSubview:channelButton];
        if (i==0) {
            pre_channelButton=channelButton;
            [channelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    
    [self.view addSubview:channelButtonBack];
    
    touban_title_label=[[UILabel alloc]init];
    touban_title_label.backgroundColor=[UIColor blackColor];
    touban_title_label.frame=CGRectMake(0, 210, 320, 30);
    touban_title_label.layer.opacity=0.8;
    
    touban_title_label.textColor=[UIColor whiteColor];
    [touban_title_label setTextAlignment:NSTextAlignmentCenter];
    [titleImageView addSubview:touban_title_label];
    
    //↑头版头条↑
    loadingViewIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingViewIndicator.frame=CGRectMake(100, 5, 20, 20);
    [showMoreButton addSubview:loadingViewIndicator];
    //[loadingViewIndicator startAnimating];
    [loadingViewIndicator stopAnimating];
    //添加转动菊花论
    
    [super viewDidLoad];
    //json Parser
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    if ([[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/1000.html",documentDir]]) {
        //NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://app.sfls.cn/sflsnews/newslist.asp?indexpage=1"] encoding:NSUTF8StringEncoding error:nil];
        NSString *jsonString=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/1000.html",documentDir] encoding:NSUTF8StringEncoding error:nil];
        // NSLog(@"%@",jsonString);
        SBJSON *parser = [[SBJSON alloc] init];
        parser.delegate=self;
        [parser objectWithString:jsonString error:nil];
        //为了让现有的json得到更新，重复以下代码：
        DownJSon *newDownJSon=[[DownJSon alloc]init];
        [newDownJSon startDownloadWithURL:@"http://app.sfls.cn/sflsnews/newslist.asp" channelID:@"1000" Page:@"1"];
        newDownJSon.delegate=self;
        
    }
    else{
        DownJSon *newDownJSon=[[DownJSon alloc]init];
        [newDownJSon startDownloadWithURL:@"http://app.sfls.cn/sflsnews/newslist.asp" channelID:@"1000" Page:@"1"];
        newDownJSon.delegate=self;
        NSLog(@"no json please download");
    }
    
   	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [listTableView release];
    [titleImageView release];
    [showMoreButton release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"%i",[self.tableViewDataArray count]);
    return [self.tableViewDataArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //float bi=5;
    if (loginTimes%5==0 && indexPath.row==0) {//广告：下载视频app
        // NSLog(@"logintime is %d now is the 5th time",loginTimes);
        static NSString *CellIdentifier1 = @"ADV";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        UIImageView *newImageView=(UIImageView *)[cell viewWithTag:6];
        newImageView.layer.borderWidth=2;
        newImageView.layer.cornerRadius=5;
        [newImageView.layer setMasksToBounds:YES];
        newImageView.layer.borderColor=[UIColor grayColor].CGColor;
        newImageView.layer.shadowColor=[UIColor blackColor].CGColor;
        newImageView.layer.shadowOffset=CGSizeMake(5, 5);
        newImageView.layer.shadowOpacity=.7;
        newImageView.image=[UIImage imageNamed:@"sflsTV.png"];
        return cell;
        
    }else{
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary *singleNews=[self.tableViewDataArray objectAtIndex:[indexPath row]];
        UILabel *titleLabel=(UILabel *)[cell viewWithTag:1];
        titleLabel.text=[singleNews objectForKey:@"Title"];
        
        UILabel *infoLabel=(UILabel *)[cell viewWithTag:3];
        NSString *infoString=[singleNews objectForKey:@"summary_content"];
        infoLabel.text=infoString;//服务器把<>去掉，再形成一个简介。
        
        //NSArray *tempArray=[[[singleNews objectForKey:@"DefaultPicUrl"] componentsSeparatedByString:@"/"] lastObject];
        UIImageView *newImageView=(UIImageView *)[cell viewWithTag:2];
        //修饰newImageView
        
        newImageView.layer.borderWidth=2;
        newImageView.layer.cornerRadius=5;
        [newImageView.layer setMasksToBounds:YES];
        newImageView.layer.borderColor=[UIColor grayColor].CGColor;
        newImageView.layer.shadowColor=[UIColor blackColor].CGColor;
        newImageView.layer.shadowOffset=CGSizeMake(5, 5);
        newImageView.layer.shadowOpacity=.7;
        
        
        NSString *imageName=[[[singleNews objectForKey:@"DefaultPicUrl"] componentsSeparatedByString:@"/"] lastObject];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDir =[NSString stringWithFormat:@"%@/%@",[documentPaths objectAtIndex:0],imageName] ;
        //NSLog(@"dir:%@&img:%@",documentDir,imageName);
        if ([[NSFileManager defaultManager]fileExistsAtPath:documentDir]) {
            newImageView.image=[UIImage imageWithContentsOfFile:documentDir];
        }
        else{
            
            DownImage *newDownImage=[[DownImage alloc]init];
            newDownImage.delegate=self;
            newDownImage.imageUrl=[singleNews objectForKey:@"DefaultPicUrl"];
            newDownImage.imageViewIndex=[indexPath row];
            //newDownImage.imageViewIndex=21;
            [newDownImage startDownload];
            
            NSLog(@"%@",[singleNews objectForKey:@"Title"]);
            // Configure the cell...
        }
        return cell;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //广告：下载视频app
    if (loginTimes%5==0 && indexPath.row==0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/id521419228?ls=1&mt=8"]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)imageUrl imageName:(NSString *)imageName{
    NSLog(@"the tag is%i",indexTag);
    if (indexTag!=100000) {//是标题图片
        NSIndexPath *newPath=[NSIndexPath indexPathForRow:indexTag inSection:0];
        UITableViewCell *newCell=[self.listTableView cellForRowAtIndexPath:newPath];
        UIImageView *newiMageView=(UIImageView *)[newCell viewWithTag:2];
        //UIActivityIndicatorView *newActView=(UIActivityIndicatorView *)[newiMageView.subviews objectAtIndex:0];
        //newActView.hidden=YES;
        //[newActView stopAnimating];
        newiMageView.image=[UIImage imageWithContentsOfFile:imageUrl];
        newiMageView.layer.opacity=0;
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:1.0];
        newiMageView.layer.opacity=1;
        [UIView commitAnimations];
        
        NSLog(@"%@ is ok path=%@ indextagg= %i",newPath,imageUrl,indexTag);
    }
    else
    {
        if (indexTag==100000) {
            titleImageView.image=[UIImage imageWithContentsOfFile:imageUrl];
        }
    }
}
- (IBAction)showMore:(UIButton *)sender {
    page++;
    
    //NSString *urlString=[NSString stringWithFormat:@"http://app.sfls.cn/sflsnews/newslist.asp?indexpage=%i&channelID=%i",page,channelID];
    DownJSon *newDownJson=[[DownJSon alloc]init];
    newDownJson.delegate=self;
    NSString *channelID_string=[NSString stringWithFormat:@"%i",channelID];
    NSString *page_string=[NSString stringWithFormat:@"%i",page];
    [newDownJson startAppendWithURL:@"http://app.sfls.cn/sflsnews/newslist.asp" channelID:channelID_string Page:page_string];
    [loadingViewIndicator startAnimating];
    //NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    //SBJSON *parser = [[SBJSON alloc] init];
    //NSLog(@"%@",jsonString);
    
    //[parser objectWithString:jsonString error:nil];
    //NSLog(@"%@",thisError);
    //NSArray *newarray=[results objectForKey:@"news"];
    //[self.tableViewDataArray addObjectsFromArray:newarray];
    //[listTableView reloadData];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    newsDetail *desNewsDetail=[segue destinationViewController];
    NSLog(@"%i",[self.listTableView indexPathForCell:sender].row);
    
    desNewsDetail.news=[self.tableViewDataArray objectAtIndex:[self.listTableView indexPathForCell:sender ].row];
    [listTableView deselectRowAtIndexPath:[self.listTableView indexPathForCell:sender ] animated:YES];
    
}
-(void)changeChannel:(UIButton *)sender{
    page=1;
    [pre_channelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pre_channelButton=sender;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    channelButtonBorder.frame=sender.frame;
    [UIView commitAnimations];
    //NSLog(@"%i",sender.tag);
    channelID=sender.tag;
    NSString *channelID_string=[[NSString stringWithFormat:@"%i",channelID]retain];
    //DownJSon *newDownJSon=[[DownJSon alloc]init];
    //newDownJSon.delegate=self;
    //[newDownJSon startDownloadWithURL:@"http://app.sfls.cn/sflsnews/newslist.asp" channelID:[NSString stringWithFormat:@"%i",sender.tag] Page:@"1"];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/%i.html",documentDir,sender.tag]]) {
        NSString *jsonString=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%i.html",documentDir,sender.tag] encoding:NSUTF8StringEncoding error:nil];
        SBJSON *parser = [[SBJSON alloc] init];
        parser.delegate=self;
        [parser objectWithString:jsonString error:nil];
        //为了让现有的json得到更新，重复以下代码：
        DownJSon *newDownJSon=[[DownJSon alloc]init];
        [newDownJSon startDownloadWithURL:@"http://app.sfls.cn/sflsnews/newslist.asp" channelID:channelID_string Page:@"1"];
        newDownJSon.delegate=self;
        
    }
    else{
        DownJSon *newDownJSon=[[DownJSon alloc]init];
        newDownJSon.delegate=self;
        [newDownJSon startDownloadWithURL:@"http://app.sfls.cn/sflsnews/newslist.asp" channelID:channelID_string Page:@"1"];
        
        //NSLog(@"no json please download and channel is %i",channelID);
    }
    /*
     NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
     SBJSON *parser = [[SBJSON alloc] init];
     //NSLog(@"%@",jsonString);
     NSError *thisError;
     NSDictionary *results = [parser objectWithString:jsonString error:&thisError];
     //NSLog(@"%@",results);
     //NSLog(@"%@",thisError);
     NSMutableArray *newarray=[results objectForKey:@"news"];
     self.tableViewDataArray=newarray;
     [listTableView reloadData];
     */
    
    
}
#pragma EgoRefresh
- (void)reloadTableViewDataSource{
    NSLog(@"==开始加载数据");
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    NSLog(@"===加载完数据");
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.listTableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    //为了让现有的json得到更新，重复以下代码：
    NSLog(@"%i",channelID);
    NSString *channelID_string=[[NSString stringWithFormat:@"%i",channelID]retain];
    DownJSon *newDownJSon=[[DownJSon alloc]init];
    [newDownJSon startDownloadWithURL:@"http://app.sfls.cn/sflsnews/newslist.asp" channelID:channelID_string Page:@"1"];
    newDownJSon.delegate=self;
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:15];//如果15秒之后不能reload,直接关闭
    //[self reloadTableViewDataSource];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

- (void)viewDidUnload {
    [showMoreButton release];
    showMoreButton = nil;
    [super viewDidUnload];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/sandman/id503536636?mt=8&uo=4"]];
    }
}

#pragma tapTitleImageView
-(void)tapTitleImageView{
    NSLog(@"tapped titleimageview %@",theFirstNews);
    UIStoryboard *newStoryBoard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    newsDetail *titleNewsDetail=[newStoryBoard instantiateViewControllerWithIdentifier:@"theNewsDetailView"];
    titleNewsDetail.news=theFirstNews;
    [self.navigationController pushViewController:titleNewsDetail animated:YES];
}
@end


