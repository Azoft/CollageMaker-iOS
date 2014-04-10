//
//  ICMRemoteObject.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMRemoteObject.h"

@interface NSString (unsignedLongLongValue)

- (unsigned long long)unsignedLongLongValue;

@end

@implementation NSString (unsignedLongLongValue)

- (unsigned long long)unsignedLongLongValue {
    return strtoull([self UTF8String], NULL, 0);
}

@end

@implementation ICMRemoteObject

+ (NSArray *)objectsWithDicionaries:(NSArray *)JSONObjects {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[JSONObjects count]];
    [JSONObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[self objectWithDictionary:obj]];
    }];
    return [result copy];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dict {
    return [[[self class] alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //ignore unnecessary attributes
}

@end
