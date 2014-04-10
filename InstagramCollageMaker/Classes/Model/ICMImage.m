//
//  ICMImage.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMImage.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation ICMImage {
    BOOL _loadingInProgress;
    
    id <SDWebImageOperation> _imageLoadingOperation;
}

- (void)postCompleteNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                            object:self];
    });
}

- (void)loadUnderlyingImageAndNotify {
    if (_loadingInProgress) {
        return;
    }
    if (self.underlyingImage) {
        [self postCompleteNotification];
    } else {
        [self performLoadUnderlyingImageAndNotify];
    }
}

- (void)imageWithCompletion:(void (^)(UIImage *image))completion {
    _loadingInProgress = YES;
    
    if (completion && self.underlyingImage) {
        completion(self.underlyingImage);
        return;
    }
    
    _imageLoadingOperation = [[SDWebImageManager sharedManager] downloadWithURL:self.imageURL
                                                                        options:0
                                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                           float progress = (float)receivedSize / (float)expectedSize;
                                                                           NSDictionary* dict = @{@"progress" : @(progress),
                                                                                                  @"photo" : self};
                                                                           [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION
                                                                                                                               object:dict];
                                                                       } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                           if (error) {
                                                                               NSLog(@"%@", error);
                                                                           }
                                                                           _imageLoadingOperation = nil;
                                                                           self.underlyingImage = image;
                                                                           _loadingInProgress = NO;
                                                                           
                                                                           if (completion) {
                                                                               completion(image);
                                                                           }
                                                                       }];
}

- (void)performLoadUnderlyingImageAndNotify {
    _loadingInProgress = YES;
    
    [self imageWithCompletion:^(UIImage *image) {
        [self postCompleteNotification];
    }];
}

- (void)unloadUnderlyingImage {
    [self cancelAnyLoading];
    self.underlyingImage = nil;
}

- (void)cancelAnyLoading {
    _loadingInProgress = NO;
    [_imageLoadingOperation cancel];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
    self.imageURL = [NSURL URLWithString:keyedValues[@"url"]];
    self.size = CGSizeMake([keyedValues[@"width"] floatValue], [keyedValues[@"height"] floatValue]);
}

- (void)dealloc {
    [self unloadUnderlyingImage];
}

@end
