//
//  UIView+RelativeFrame.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 09.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RelativeFrame)

@property (nonatomic) CGRect relativeFrame;

- (void)refreshFrame;

@end
