//
//  ICMImage.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMRemoteObject.h"

#import <MWPhotoBrowser/MWPhotoProtocol.h>

@interface ICMImage : ICMRemoteObject <MWPhoto>

@property (nonatomic, strong) UIImage *underlyingImage;

@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSURL *imageURL;

- (void)imageWithCompletion:(void (^)(UIImage *image))completion;

@end
