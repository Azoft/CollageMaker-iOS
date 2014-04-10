//
//  ICMAPIClient.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "AFHTTPSessionManager.h"

static NSString * const kICMAPIBaseURLString = @"https://api.instagram.com/v1/";

@interface ICMAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
