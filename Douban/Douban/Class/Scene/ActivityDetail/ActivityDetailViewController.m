//
//  ActivityDetailViewController.m
//  Douban
//
//  Created by y_小易 on 14-8-27.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "ActivityDetailView.h"
#import "Activity.h"
#import "Defined.h"
#import "LoginViewController.h"
#import "DatabaseHandle.h"
#import "MBProgressHUD.h"

@interface ActivityDetailViewController ()

@property (nonatomic,retain) ActivityDetailView * detailView;
@property (nonatomic,retain) MBProgressHUD * hud;

//设置数据xxxxxxxxxxxxxx
- (void)p_setupData;
//设置收藏按钮
- (void)p_setupFavoriteButtonItem;
//用户登录
- (void)p_userLogin;
//用户收藏活动
- (void)p_favoriteActivity;
//设置loading
- (void)p_setupProgressHud;
//移除alertView
- (void)p_removeAlertView:(UIAlertView *)alertView;

@end

@implementation ActivityDetailViewController

- (void)dealloc
{
    self.detailView = nil;
    self.activity = nil;
    self.hud = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.detailView = [[[ActivityDetailView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view = _detailView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = _activity.title;
    
    //返回按钮
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btn_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(didClickBackButtonItemAction:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem release];
    
    //设置收藏按钮
    [self p_setupFavoriteButtonItem];
    
    
    //设置显示数据
    [self p_setupData];
    

}

- (void)p_setupFavoriteButtonItem
{
    //收藏按钮
    UIBarButtonItem * favoriteButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btn_nav_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(didClickFavoriteButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = favoriteButtonItem;
    [favoriteButtonItem release];
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

#pragma mark -----控制方法-----
//返回
- (void)didClickBackButtonItemAction:(UIBarButtonItem *)buttonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}


//收藏
- (void)didClickFavoriteButtonItemAction:(UIBarButtonItem *)buttonItem
{
    //收藏之前先判断用户是否登录
    BOOL isLogin = [[FileHandle shareInstance] loginState];
    
    if (NO == isLogin) {
        //用户没有登录，显示登录页面进行登录
        [self p_userLogin];
        
    }else {
        //用户已近登录，直接收藏
        [self p_favoriteActivity];
    }
}

//用户登录
- (void)p_userLogin
{
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    UINavigationController * loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    __block ActivityDetailViewController * detailVC = self;
    
    //定义登录成功后回调的block
    loginVC.successBlock = ^(id userInfo){
        
        NSLog(@"登陆成功");
        [detailVC p_favoriteActivity];
    };
    
    [self presentViewController:loginNC animated:YES completion:nil];
    
    [loginNC release];
    [loginVC release];

}

//收藏活动
- (void)p_favoriteActivity
{
    
    BOOL isFavorite = [[DatabaseHandle shareInstance] isFavoriteActivityWithID:_activity.ID];
    
    if (YES == isFavorite) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该活动已经被收藏过" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
        
        return;
    }

    
    //操作数据库，收藏活动
    _activity.isFavorite = YES;
    [[DatabaseHandle shareInstance] insertNewActivity:_activity];
    
    //显示alertView提示用户
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"收藏成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
    //0.3秒后alertView消失
    [self performSelector:@selector(p_removeAlertView:) withObject:alertView afterDelay:0.3];
    
}


- (void)p_removeAlertView:(UIAlertView *)alertView
{
    //alertView消失
    [alertView dismissWithClickedButtonIndex:0 animated:YES];

}


#pragma mark -----显示数据-----
- (void)p_setupData
{
    
    //根据活动内容调整滚动视图的contentSize
    [_detailView adjustSubviewsWithContent:_activity.content];
    
    //活动图片
    
    if (_activity.image == nil) {
        //没有图像，下载图像
        _detailView.activityImageView.image = [UIImage imageNamed:@"picholder"];
        [_activity loadImage];
        
       [_activity addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    }else{
        _detailView.activityImageView.image = _activity.image;
    }

    
    //标题
    _detailView.titleLabel.text = _activity.title;
    
    //时间
    NSString * startTime = [_activity.begin_time substringWithRange:NSMakeRange(5, 11)];
    NSString * endTime = [_activity.end_time substringWithRange:NSMakeRange(5, 11)];
    _detailView.timeLabel.text = [NSString stringWithFormat:@"%@ -- %@",startTime,endTime];
    
    //主办方
    _detailView.ownerLabel.text = _activity.ownerName;

    //类型
    _detailView.categoryLabel.text = [NSString stringWithFormat:@"类型：%@",_activity.category_name];
    
    //地址
    _detailView.addressLabel.text = _activity.address;
    [_detailView.addressLabel sizeToFit];//label适应文本高度
    
    //内容
    _detailView.contextLabel.text = _activity.content;

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    UIImage *image = [change objectForKey:NSKeyValueChangeNewKey];
    
    _detailView.activityImageView.image = image;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
