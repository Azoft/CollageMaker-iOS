//
//  ICMRemoteObject.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICMRemoteObject : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (instancetype)objectWithDictionary:(NSDictionary *)dict;
+ (NSArray *)objectsWithDicionaries:(NSArray *)JSONObjects;

@end
