//
//  UIImage+CollagePreview.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 10.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICMCollage;

@interface UIImage (CollagePreview)

+ (UIImage *)renderPreviewImageWithCollage:(ICMCollage *)collage ofSize:(CGSize)size;

@end
