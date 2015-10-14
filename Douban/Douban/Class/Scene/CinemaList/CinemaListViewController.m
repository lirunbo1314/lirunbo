//
//  CinemaListViewController.m
//  Douban
//
//  Created by y_小易 on 14-9-24.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import "CinemaListViewController.h"
#import "CinemaListCell.h"

#import "DoubanAPIUrl.h"
#import "MBProgressHUD.h"
#import "Cinema.h"

@interface CinemaListViewController ()

@property (nonatomic,retain) NSMutableArray * cinemaArray;
@property (nonatomic,retain) MBProgressHUD * hud;

//发起网络请求
- (void)p_sendRequest;
- (void)p_setupProgressHud;

@end

@implementation CinemaListViewController

- (void)dealloc
{
    self.cinemaArray = nil;
    self.hud = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"影院";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.cinemaArray = [NSMutableArray arrayWithCapacity:40];
    
    [self p_setupProgressHud];
    
    //发起网络请求获取数据
    [self p_sendRequest];

}

- (void)p_setupProgressHud
{
    self.hud = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    _hud.frame = self.view.bounds;
    _hud.minSize = CGSizeMake(100, 100);
    _hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:_hud];
    
    [_hud show:YES];
}

#pragma mark --网络请求、数据处理--

//发起网络请求
- (void)p_sendRequest
{
    
    //拼接网址
    
    NSString * urlString = CinemaListAPI;
        
    NSURL * url = [NSURL URLWithString:urlString];
    
    __block CinemaListViewController * listVC = self;
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        [_hud hide:YES];
        
        if (data == nil) {
            
            return;
        }
        
        //解析数据
        NSDictionary * sourceDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //数据处理
        NSDictionary * resultDic = sourceDic[@"result"];
        NSArray * sourceArray = resultDic[@"data"];
        
        for (NSDictionary * cinemaDic in sourceArray) {
            
            Cinema * c = [[Cinema alloc] init];
            [c setValuesForKeysWithDictionary:cinemaDic];
            [listVC.cinemaArray addObject:c];
            [c release];
        }
        
        //刷新数据
        [listVC.tableView reloadData];
        
        
    }];


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_cinemaArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cinema * cinema = _cinemaArray[indexPath.row];
    return [CinemaListCell cellHeight:cinema];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cinemaListCell";
    
    CinemaListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (nil == cell) {
        cell = [[[CinemaListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    Cinema * cinema = _cinemaArray[indexPath.row];
    
    cell.cinema = cinema;
    
    
    
    return cell;
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
