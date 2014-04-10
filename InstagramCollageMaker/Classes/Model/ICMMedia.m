//
//  ICMMedia.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMMedia.h"
#import "ICMImage.h"

@implementation ICMMedia

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
    NSArray *mediaTypes = @[@"image", @"video"];
    
    self.type = [mediaTypes indexOfObject:keyedValues[@"type"]];
    
    NSDictionary *imagesDict = keyedValues[@"images"];
    self.thumbnailImage = [ICMImage objectWithDictionary:imagesDict[@"thumbnail"]];
    self.lowResolutionImage = [ICMImage objectWithDictionary:imagesDict[@"low_resolution"]];
    self.standartResolutionImage = [ICMImage objectWithDictionary:imagesDict[@"standard_resolution"]];
    self.remoteID = keyedValues[@"id"];
    self.likesCount = [keyedValues[@"likes"][@"count"] integerValue];
}

@end
