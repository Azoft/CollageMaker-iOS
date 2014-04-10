//
//  UIView+ImageRender.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 09.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "UIView+ImageRender.h"

@implementation UIView (ImageRender)

- (UIImage *)renderImage {
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:c];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
