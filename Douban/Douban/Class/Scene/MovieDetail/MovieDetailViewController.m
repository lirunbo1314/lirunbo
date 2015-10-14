//
//  MovieDetailViewController.m
//  Douban
//
//  Created by y_小易 on 14-8-27.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "MovieDetailView.h"
#import "Movie.h"
#import "LoginViewController.h"
#import "DoubanAPIUrl.h"
#import "DatabaseHandle.h"
#import "MBProgressHUD.h"


@interface MovieDetailViewController ()

@property (nonatomic,retain) MovieDetailView * detailView;
@property (nonatomic,retain) MBProgressHUD * hud;

//设置数据
- (void)p_setupData;
//发起网络请求
- (void)p_sendReuqest;
//用户登录
- (void)p_userLogin;
//收藏电影
- (void)p_favoriteMovie;
//设置收藏按钮
- (void)p_setupFavoriteButtonItem;
//设置loading
- (void)p_setupProgressHud;



@end

@implementation MovieDetailViewController

- (void)dealloc
{
    self.detailView = nil;
    self.movie = nil;
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
    self.detailView = [[[MovieDetailView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view = _detailView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = _movie.movieName;
    
    //返回按钮
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btn_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(didClickBackButtonItemAction:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem release];
    
    [self p_setupFavoriteButtonItem];

    
    //如果活动未收藏，显示收藏按钮
    BOOL isFavorite = [[DatabaseHandle shareInstance] isFavoriteMovieWithID:_movie.movieId];

    
    if (isFavorite == YES) {
        //如果已经收藏过
        [self.detailView setupSubviews];
        [self p_setupData];

    }else{

        //发起请求
        [self p_sendReuqest];
        [self p_setupProgressHud];
    }


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


#pragma mark --网络请求、数据处理--
//发起网络请求
- (void)p_sendReuqest
{
    //拼接网址，需要使用 电影列表页面中得到的电影编号，根据电影编号获取某个电影的详情
    NSString * urlString = [NSString stringWithFormat:@"%@?movieId=%@",MovieDetailAPI,_movie.movieId];
    NSURL * url = [NSURL URLWithString:urlString];
    
    __block MovieDetailViewController * detailVC = self;
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       
        [_hud hide:YES];
        
        if (data == nil) {
            
            return;
        }
        
        //设置收藏按钮
        [detailVC p_setupFavoriteButtonItem];
        
        NSDictionary * movieDetailDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        //电影列表页面已经获取到了部分数据，直接继续添加详情页面需要的数据即可，不需要创建一个新的movie对象
        
        //获取数据
        
        movieDetailDic = movieDetailDic[@"result"];
        
        detailVC.movie.rating = movieDetailDic[@"rating"];
        
        //评论人数
        detailVC.movie.rating_count = movieDetailDic[@"rating_count"];

        //时长
        detailVC.movie.runtime = movieDetailDic[@"runtime"];
        
        //类型
        detailVC.movie.genres = movieDetailDic[@"genres"];
        
        //国家
        detailVC.movie.country = movieDetailDic[@"country"];

        //简介
        detailVC.movie.plot_simple = movieDetailDic[@"plot_simple"];
        
        //上映时间
        detailVC.movie.release_date = movieDetailDic[@"release_date"];
        
        //制作人
        detailVC.movie.actors = movieDetailDic[@"actors"];
        
        
        //布局页面
        [detailVC.detailView setupSubviews];
        
        //设置显示数据
        [self p_setupData];
        
       
        
    }];

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
        
        [self p_favoriteMovie];
    }

}

//用户登录
- (void)p_userLogin
{
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    UINavigationController * loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    //定义登录成功后回调的block
    
    __block MovieDetailViewController * detailVC = self;
    
    loginVC.successBlock = ^(id userInfo){
        
        NSLog(@"登陆成功");
        
        [detailVC p_favoriteMovie];
        
    };
    
    [self presentViewController:loginNC animated:YES completion:nil];
    
    [loginNC release];
    [loginVC release];
    
}

//收藏活动
- (void)p_favoriteMovie
{
    
    BOOL isFavorite = [[DatabaseHandle shareInstance] isFavoriteMovieWithID:_movie.movieId];
    
    if (YES == isFavorite) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该电影已经被收藏过" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    //操作数据库，收藏活动
    _movie.isFavorite = YES;
    [[DatabaseHandle shareInstance] insertNewMovie:_movie];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"收藏成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
    [self performSelector:@selector(p_removeAlertView:) withObject:alertView afterDelay:0.3];
}

- (void)p_removeAlertView:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
}

#pragma mark -----显示数据-----
- (void)p_setupData
{
    //电影图像
    if (_movie.image == nil) {
        //没有图像，下载图像
        _detailView.movieImageView.image = [UIImage imageNamed:@"picholder"];
        [_movie loadImage];
        
        [_movie addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        
    }else{
        
        _detailView.movieImageView.image = _movie.image;
    }
    
    //评分
    _detailView.ratingLabel.text = [NSString stringWithFormat:@"评分：%@",_movie.rating];
    
    //评论人数
    _detailView.ratingCountLabel.text = [NSString stringWithFormat:@"(%@评论)",_movie.rating_count];
    
    //上映日期
    _detailView.pubLabel.text = _movie.release_date;

    //时长
    _detailView.runtimeLabel.text = _movie.runtime;

    //分类
    _detailView.genresLabel.text = _movie.genres;

    //国家
    _detailView.countryLabel.text = _movie.country;
    
    //制作人
    _detailView.actorsLabel.text = _movie.actors;
    
    //简介
    _detailView.summaryLabel.text = _movie.plot_simple;
    
    [_detailView adjustSubviewsWithContent];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    UIImage *image = [change objectForKey:NSKeyValueChangeNewKey];
    
    _detailView.movieImageView.image = image;
    
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
