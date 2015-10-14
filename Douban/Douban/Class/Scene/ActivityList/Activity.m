//
//  Activity.m
//  Douban
//
//  Created by y_小易 on 14-8-27.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import "Activity.h"

@implementation Activity
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCleanCachedNotification object:nil];
    
    self.title = nil;
    self.begin_time = nil;
    self.end_time = nil;
    self.address = nil;
    self.category_name = nil;
    self.imageUrl = nil;
    self.content = nil;
    self.ownerName = nil;
    self.wisher_count = nil;
    self.participant_count = nil;
    self.image = nil;
    self.imageFilePath = nil;
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

//属性中没有对应的key
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //字典中是id，属性中是ID
    if ([key isEqualToString:@"id"]) {
        
        self.ID = value;
    }
    
    //字典中owner的值是字典，字典中的name是需要的值
    //如果key是owner，从字典中取出name给ownerName赋值。
    if ([key isEqualToString:@"owner"]) {
        
        NSDictionary * ownerDic = (NSDictionary *)value;
        self.ownerName = ownerDic[@"name"];
    }
    
}

//属性中有对应的key
- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    //wisher_count对应的值可能是 NSString 或 NSNumber
    if ([key isEqualToString:@"wisher_count"]) {
        self.wisher_count = [NSString stringWithFormat:@"%@",value];
    }

    //participant_count对应的值可能是 NSString 或 NSNumber
    if ([key isEqualToString:@"participant_count"]) {
        self.participant_count = [NSString stringWithFormat:@"%@",value];
    }
    
    //字典中的image对应的网址，model对象中imageUrl存网址
    if ([key isEqualToString:@"image"]) {
        
        //图像网址
        self.imageUrl = value;
        
        //图像沙盒中路径
        self.imageFilePath = [[FileHandle shareInstance] imageFilePathWithURL:self.imageUrl];
        
        //从沙盒中创建图像
        self.image = [UIImage imageWithContentsOfFile:self.imageFilePath];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.begin_time forKey:@"begin_time"];
    [aCoder encodeObject:self.end_time forKey:@"end_time"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.category_name forKey:@"category_name"];
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.wisher_count forKey:@"wisher_count"];
    [aCoder encodeObject:self.participant_count forKey:@"participant_count"];
    [aCoder encodeObject:self.imageFilePath forKey:@"imageFilePath"];
    [aCoder encodeBool:self.isDownloading forKey:@"isDownloading"];
    [aCoder encodeBool:self.isFavorite forKey:@"isFavorite"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.begin_time = [aDecoder decodeObjectForKey:@"begin_time"];
        self.end_time = [aDecoder decodeObjectForKey:@"end_time"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.category_name = [aDecoder decodeObjectForKey:@"category_name"];
        self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.wisher_count = [aDecoder decodeObjectForKey:@"wisher_count"];
        self.participant_count = [aDecoder decodeObjectForKey:@"participant_count"];
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
   
    //图像下载工具下载图像
    ImageDownloader *loader = [[ImageDownloader alloc] initWithURLString:self.imageUrl delegate:self];
    
    self.isDownloading = YES;
    
    [loader autorelease];
        
    
 }


//代理方法
- (void)imageDownloader:(ImageDownloader *)downloader finishLoadImage:(UIImage *)image
{
    
    self.isDownloading = NO;
    self.image = image;
    
    //图片下载后，保存到沙盒文件中
    [[FileHandle shareInstance] saveDownloadImage:self.image filePath:self.imageFilePath];
}


@end
