//
//  ICMAPIClient.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMAPIClient.h"

static NSString * const kICMAPIClientID = @"09eb51d4d3ab42518831408de280cbaf";

@implementation ICMAPIClient

+ (instancetype)sharedClient {
    static ICMAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ICMAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kICMAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *params = parameters ? [parameters mutableCopy] : [NSMutableDictionary new];
    params[@"client_id"] = kICMAPIClientID;
    return [super GET:URLString parameters:[params copy] success:success failure:failure];
}

@end
