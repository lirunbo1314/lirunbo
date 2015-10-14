//
//  Activity.h
//  Douban
//
//  Created by y_小易 on 14-8-27.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDownloader.h"

@interface Activity : NSObject<ImageDownloaderDelegate,NSCoding>

@property (nonatomic,retain) NSString * ID;
@property (nonatomic,retain) NSString * title;
@property (nonatomic,retain) NSString * begin_time;
@property (nonatomic,retain) NSString * end_time;
@property (nonatomic,retain) NSString * address;
@property (nonatomic,retain) NSString * category_name;
@property (nonatomic,retain) NSString * imageUrl;//图像网址
@property (nonatomic,retain) NSString * content;
@property (nonatomic,retain) NSString * ownerName;
@property (nonatomic,retain) NSString * wisher_count;
@property (nonatomic,retain) NSString * participant_count;

@property (nonatomic,retain) UIImage  * image;//图像
@property (nonatomic,retain) NSString * imageFilePath;//图像在沙盒中的路径
@property (nonatomic,assign) BOOL       isDownloading;//图像下载状态

@property (nonatomic,assign) BOOL       isFavorite;//是否收藏

//开始下载图像
- (void)loadImage;

@end
