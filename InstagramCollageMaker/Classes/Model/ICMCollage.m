//
//  ICMCollage.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMCollage.h"

@interface ICMCollage ()

@property (nonatomic, strong) NSArray *relativeFrames;

@end

@implementation ICMCollage

+ (NSArray *)collages {
    static NSArray *_collages = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _collages = [self loadCollages];
    });
    
    return _collages;
}

+ (NSArray *)loadCollages {
    NSArray *collagesDicts = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Collages" ofType:@"plist"]];
    return [self objectsWithDicionaries:collagesDicts];
}

- (UIImage *)previewImage {
    return [UIImage imageNamed:self.previewImageName];
}

- (void)enumerateRelativeFramesUsingBlock:(void (^)(CGRect relativeFrame, NSUInteger index))block {
    [self.relativeFrames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block) {
            block([obj CGRectValue], idx);
        }
    }];
}

- (void)setRelativeFramesStrings:(NSArray *)relativeFramesStrings {
    NSMutableArray *result = [NSMutableArray new];
    [relativeFramesStrings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[NSValue valueWithCGRect:CGRectFromString(obj)]];
    }];
    self.relativeFrames = [result copy];
}

@end
