//
//  ICMUser.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMRemoteObject.h"

@interface ICMUser : ICMRemoteObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic) NSUInteger id;

+ (NSURLSessionDataTask *)requestUsersWithUserName:(NSString *)username completion:(void (^)(NSArray *users, NSError *error))completion;
- (void)requesTopPhotosWithCompletion:(void (^)(NSArray *mediaObjects, NSError *error))completion;
- (NSURLSessionDataTask *)checkUserPermissionsWithCompletion:(void (^)(BOOL userIsAviable, NSError *error))completion;

@end
