//
//  ICMImage.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMImage.h"
#import <SDWebImage/SDWebImageManager.h>

@interface ICMImage ()

@property (nonatomic, strong) id <SDWebImageOperation> imageLoadingOperation;
@property (nonatomic) BOOL loadingInProgress;

@end

@implementation ICMImage

- (void)postCompleteNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                            object:self];
    });
}

- (void)loadUnderlyingImageAndNotify {
    if (self.loadingInProgress) {
        return;
    }
    if (self.underlyingImage) {
        [self postCompleteNotification];
    } else {
        [self performLoadUnderlyingImageAndNotify];
    }
}

- (void)imageWithCompletion:(ICMImageRequestCompletionBlock)completion {
    self.loadingInProgress = YES;
    
    if (completion && self.underlyingImage) {
        completion(self.underlyingImage);
        return;
    }
    
    __weak __typeof(self) this = self;
    
    self.imageLoadingOperation = [[SDWebImageManager sharedManager] downloadWithURL:self.imageURL
                                                                        options:0
                                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                           float progress = (float)receivedSize / (float)expectedSize;
                                                                           NSDictionary* dict = @{@"progress" : @(progress),
                                                                                                  @"photo" : this};
                                                                           [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION
                                                                                                                               object:dict];
                                                                       } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                           if (error) {
                                                                               NSLog(@"%@", error);
                                                                           }
                                                                           this.imageLoadingOperation = nil;
                                                                           this.underlyingImage = image;
                                                                           this.loadingInProgress = NO;
                                                                           
                                                                           if (completion) {
                                                                               completion(image);
                                                                           }
                                                                       }];
}

- (void)performLoadUnderlyingImageAndNotify {
    self.loadingInProgress = YES;
    
    [self imageWithCompletion:^(UIImage *image) {
        [self postCompleteNotification];
    }];
}

- (void)unloadUnderlyingImage {
    [self cancelAnyLoading];
    self.underlyingImage = nil;
}

- (void)cancelAnyLoading {
    self.loadingInProgress = NO;
    [self.imageLoadingOperation cancel];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
    self.imageURL = [NSURL URLWithString:keyedValues[@"url"]];
    self.size = CGSizeMake([keyedValues[@"width"] floatValue], [keyedValues[@"height"] floatValue]);
}

- (void)dealloc {
    [self unloadUnderlyingImage];
}

@end
