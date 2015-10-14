//
//  ImageDownloader.m
//  Lesson36Kr
//
//  Created by neal on 14-8-4.
//  Copyright (c) 2014年 www.lanou3g.com. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

- (instancetype)initWithURLString:(NSString *)urlStr delegate:(id<ImageDownloaderDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.urlString = urlStr;
        self.delegate = delegate;
        
        [self startDownload];
    }
    return self;

}



- (void)startDownload
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        UIImage *image = [UIImage imageWithData:data];
        
        if ([_delegate respondsToSelector:@selector(imageDownloader:finishLoadImage:)]) {
            [_delegate imageDownloader:self finishLoadImage:image];
        }
        
    }];
}


@end
