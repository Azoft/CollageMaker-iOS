//
//  ICMUserSearchViewController.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICMUser;

typedef void (^ICMUserSearchCompletionBlock)(ICMUser *user);

@interface ICMUserSearchViewController : UITableViewController

@property (nonatomic, copy) ICMUserSearchCompletionBlock completion;

@end
