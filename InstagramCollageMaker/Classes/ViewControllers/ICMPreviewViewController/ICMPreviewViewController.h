//
//  ICMPreviewViewController.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 10.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMBaseViewController.h"

#import <MessageUI/MFMailComposeViewController.h>

@interface ICMPreviewViewController : ICMBaseViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIImage *collageImage;

@end
