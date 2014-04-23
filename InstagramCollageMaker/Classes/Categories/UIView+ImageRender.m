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
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end
