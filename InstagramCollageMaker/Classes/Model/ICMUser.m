//
//  ICMUser.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMUser.h"
#import "ICMAPIClient.h"
#import "ICMMedia.h"

const CGFloat kICMMaxMediaCount = 100;

@implementation ICMUser

+ (NSURLSessionDataTask *)requestUsersWithUserName:(NSString *)username completion:(ICMRequrestObjectsCompletionBlock)completion {
    return [[ICMAPIClient sharedClient] GET:@"users/search"
                                 parameters:@{@"q" : username ?: @"", @"count" : @(NSIntegerMax)}
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        if (completion) {
                                            completion([self objectsWithDicionaries:responseObject[@"data"]], nil);
                                        }
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        if (completion) {
                                            completion(nil, error);
                                        }
                                    }];
}

- (void)requesTopPhotosWithCompletion:(ICMRequrestObjectsCompletionBlock)completion {
    [self requestPhotoMediaWithLPhotos:[NSMutableArray new] maxID:nil maxMediaCount:kICMMaxMediaCount completion:completion];
}

- (NSURLSessionDataTask *)requestPhotoMediaWithLPhotos:(NSMutableArray *)photos
                                                 maxID:(NSString *)maxID
                                         maxMediaCount:(unsigned)maxMediaCount
                                            completion:(ICMRequrestObjectsCompletionBlock)completion {
    NSDictionary *params;
    if (maxID) {
        params = @{@"max_id" : maxID};
    }
    return [[ICMAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%lu/media/recent/", (unsigned long)self.remoteID]
                                 parameters:params
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        NSString *newMaxID = responseObject[@"pagination"][@"next_max_id"];
                                        
                                        NSArray *media = [ICMMedia objectsWithDicionaries:responseObject[@"data"]];
                                        
                                        [photos addObjectsFromArray:[media filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type = %d",
                                                                                                        ICMMediaTypePhoto]]];
                                        if ([photos count] > maxMediaCount || [newMaxID length] == 0) {
                                            if (completion) {
                                                completion([photos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"likesCount" ascending:NO]]], nil);
                                            }
                                        } else {
                                            [self requestPhotoMediaWithLPhotos:photos
                                                                         maxID:newMaxID
                                                                 maxMediaCount:maxMediaCount
                                                                    completion:completion];
                                        }
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        if (completion) {
                                            completion(nil, error);
                                        }
                                    }];
}

- (NSURLSessionDataTask *)checkUserPermissionsWithCompletion:(ICMRequrestPermissionsCompletionBlock)completion {
    return [[ICMAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%lu/", (unsigned long)self.remoteID]
                                 parameters:nil
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        if (completion) {
                                            completion(YES, nil);
                                        }
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        if (completion) {
                                            completion(NO, error);
                                        }
                                    }];
}

#pragma mark - API KVC setters

- (void)setProfile_picture:(NSString *)picureURLString {
    self.photoURL = [NSURL URLWithString:picureURLString];
}

- (void)setId:(NSUInteger)remoteID {
    self.remoteID = remoteID;
}

@end
