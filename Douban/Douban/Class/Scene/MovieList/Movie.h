//
//  Movie.h
//  Douban
//
//  Created by y_小易 on 14-8-27.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImageDownloader.h"

@interface Movie : NSObject<ImageDownloaderDelegate,NSCoding>

@property (nonatomic,retain) NSString * rating;//评分
@property (nonatomic,retain) NSString * release_date;//上映时间
@property (nonatomic,retain) NSString * movieName;//电影名
@property (nonatomic,retain) NSString * movieId;//电影编号
@property (nonatomic,retain) NSString * pic_url;//图像网址
@property (nonatomic,retain) NSString * genres;//分类
@property (nonatomic,retain) NSString * country;//国家
@property (nonatomic,retain) NSString * runtime;//电影时长
@property (nonatomic,retain) NSString * rating_count;//评论人数
@property (nonatomic,retain) NSString * plot_simple;//电影情节
@property (nonatomic,retain) NSString * actors;//制作人

@property (nonatomic,retain) UIImage  * image;//图像
@property (nonatomic,retain) NSString * imageFilePath;//图像在沙盒中的路径
@property (nonatomic,assign) BOOL       isDownloading;//图像是否正在下载

@property (nonatomic,assign) BOOL       isFavorite;//是否收藏


- (void)loadImage;


@end
