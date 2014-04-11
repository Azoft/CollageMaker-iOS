//
//  ICMUser.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMRemoteObject.h"

typedef void (^ICMRequrestObjectsCompletionBlock)(NSArray *objects, NSError *error);
typedef void (^ICMRequrestPermissionsCompletionBlock)(BOOL result, NSError *error);

@interface ICMUser : ICMRemoteObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic) NSUInteger remoteID;

+ (NSURLSessionDataTask *)requestUsersWithUserName:(NSString *)username completion:(ICMRequrestObjectsCompletionBlock)completion;
- (void)requesTopPhotosWithCompletion:(ICMRequrestObjectsCompletionBlock)completion;
- (NSURLSessionDataTask *)checkUserPermissionsWithCompletion:(ICMRequrestPermissionsCompletionBlock)completion;

@end
