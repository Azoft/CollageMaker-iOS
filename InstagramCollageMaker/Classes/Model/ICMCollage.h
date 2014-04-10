//
//  ICMCollage.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICMRemoteObject.h"

@interface ICMCollage : ICMRemoteObject

@property (nonatomic, readonly) NSArray *relativeFrames;
@property (nonatomic, copy) NSString *previewImageName;
@property (nonatomic) CGFloat ratio;

- (UIImage *)previewImage;
- (void)enumerateRelativeFramesUsingBlock:(void (^)(CGRect relativeFrame, NSUInteger index))block;

+ (NSArray *)collages;

@end
