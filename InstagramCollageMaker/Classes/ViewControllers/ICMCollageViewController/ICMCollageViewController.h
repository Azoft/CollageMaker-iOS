//
//  ICMCollageViewController.h
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "ICMBaseViewController.h"

@class ICMCollage;

@interface ICMCollageViewController : ICMBaseViewController <MWPhotoBrowserDelegate>

@property (nonatomic, strong) ICMCollage *collage;
@property (nonatomic, strong) NSArray *mediaPhotos;

@end
