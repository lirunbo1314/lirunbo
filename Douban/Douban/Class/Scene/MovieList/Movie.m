//
//  Movie.m
//  Douban
//
//  Created by y_小易 on 14-8-27.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCleanCachedNotification object:nil];

    self.rating = nil;
    self.release_date = nil;
    self.movieName = nil;
    self.movieId = nil;
    self.pic_url = nil;
    self.genres = nil;
    self.country = nil;
    self.runtime = nil;
    self.rating_count = nil;
    self.plot_simple = nil;
    self.actors = nil;
    self.imageFilePath = nil;
    self.image = nil;
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCleanImageCachedNotification:) name:kCleanCachedNotification object:nil];
        
    }
    
    return self;
}


- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    if ([key isEqualToString:@"pic_url"]) {
    
        
        //图像在沙盒中的路径
        self.imageFilePath = [[FileHandle shareInstance] imageFilePathWithURL:self.pic_url];
        
        //从沙盒中读取图片
        self.image = [UIImage imageWithContentsOfFile:self.imageFilePath];
        
    }

}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:self.movieId forKey:@"movieId"];
    [aCoder encodeObject:self.movieName forKey:@"movieName"];
    [aCoder encodeObject:self.rating forKey:@"rating"];
    [aCoder encodeObject:self.release_date forKey:@"release_date"];
    [aCoder encodeObject:self.genres forKey:@"genres"];
    [aCoder encodeObject:self.pic_url forKey:@"pic_url"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.rating_count forKey:@"rating_count"];
    [aCoder encodeObject:self.runtime forKey:@"runtime"];
    [aCoder encodeObject:self.plot_simple forKey:@"plot_simple"];
    [aCoder encodeObject:self.actors forKey:@"actors"];
    [aCoder encodeObject:self.imageFilePath forKey:@"imageFilePath"];
    [aCoder encodeBool:self.isDownloading forKey:@"isDownloading"];
    [aCoder encodeBool:self.isFavorite forKey:@"isFavorite"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        self.movieId = [aDecoder decodeObjectForKey:@"movieId"];
        self.movieName = [aDecoder decodeObjectForKey:@"movieName"];
        self.rating = [aDecoder decodeObjectForKey:@"rating"];
        self.release_date = [aDecoder decodeObjectForKey:@"release_date"];
        self.genres = [aDecoder decodeObjectForKey:@"genres"];
        self.rating_count = [aDecoder decodeObjectForKey:@"rating_count"];
        self.pic_url = [aDecoder decodeObjectForKey:@"pic_url"];
        self.country = [aDecoder decodeObjectForKey:@"country"];
        self.runtime = [aDecoder decodeObjectForKey:@"runtime"];
        self.plot_simple = [aDecoder decodeObjectForKey:@"plot_simple"];
        self.actors = [aDecoder decodeObjectForKey:@"actors"];
        self.imageFilePath = [aDecoder decodeObjectForKey:@"imageFilePath"];
        self.isDownloading = [aDecoder decodeBoolForKey:@"isDownloading"];
        self.isFavorite = [aDecoder decodeBoolForKey:@"isFavorite"];
    }
    
    return self;
}

- (void)handleCleanImageCachedNotification:(NSNotification *)notification
{
    //清除缓存时，将image置为空
    self.image = nil;
}

//下载图像
- (void)loadImage
{
    
    //创建图像下载工具下载图像
    ImageDownloader *loader = [[ImageDownloader alloc] initWithURLString:self.pic_url delegate:self];
    
    self.isDownloading = YES;
    
    [loader autorelease];
    
}

//代理方法
- (void)imageDownloader:(ImageDownloader *)downloader finishLoadImage:(UIImage *)image
{
    
    self.isDownloading = NO;
    self.image = image;
    
    //保存图片到沙盒文件中
    [[FileHandle shareInstance] saveDownloadImage:self.image filePath:self.imageFilePath];
}

@end
