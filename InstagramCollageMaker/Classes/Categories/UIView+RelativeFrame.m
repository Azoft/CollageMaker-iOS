//
//  UIView+RelativeFrame.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 09.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "UIView+RelativeFrame.h"

#import <objc/runtime.h>

@implementation UIView (RelativeFrame)

const void *kICMRelativeFramePropertyKey = "ICMRelativeFrame";

- (void)setRelativeFrame:(CGRect)relativeFrame {
    objc_setAssociatedObject(self, kICMRelativeFramePropertyKey, [NSValue valueWithCGRect:relativeFrame], OBJC_ASSOCIATION_RETAIN);
    [self refreshFrame];
}

- (CGRect)relativeFrame {
    return [objc_getAssociatedObject(self, kICMRelativeFramePropertyKey) CGRectValue];
}

- (void)refreshFrame {
    if (self.superview || !CGRectEqualToRect(self.relativeFrame, CGRectZero)) {
        CGRect frame = self.relativeFrame;
        frame.origin.x *= self.superview.frame.size.width;
        frame.size.width *= self.superview.frame.size.width;
        frame.origin.y *= self.superview.frame.size.height;
        frame.size.height *= self.superview.frame.size.height;
        self.frame = frame;
    }
}

@end
