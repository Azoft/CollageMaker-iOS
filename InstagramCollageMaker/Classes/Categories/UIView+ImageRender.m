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
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width * scale, self.frame.size.height * scale));
//    CGContextRef c = UIGraphicsGetCurrentContext();
//    [self.layer renderInContext:c];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];//image;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end
