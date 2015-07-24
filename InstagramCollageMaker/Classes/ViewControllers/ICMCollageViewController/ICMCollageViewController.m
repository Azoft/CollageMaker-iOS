//
//  ICMCollageViewController.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMCollageViewController.h"
#import "ICMCollage.h"
#import "UIView+RelativeFrame.h"
#import "ICMImage.h"
#import "ICMMedia.h"
#import "UIView+ImageRender.h"
#import "ICMPreviewViewController.h"
#import "ICMCollageElementView.h"

#import <QuartzCore/CALayer.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ICMPhotoBrowser : MWPhotoBrowser

@end

@implementation ICMPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:NSLocalizedString(@"choose a picture",nil)];
}

@end

@interface ICMCollageViewController ()

@property (nonatomic, strong) UIView *collageView;
@property (nonatomic, weak) ICMCollageElementView *currentCollageElementView;

@end

@implementation ICMCollageViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collageView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.width)];
    self.collageView.backgroundColor = [UIColor whiteColor];
    self.collageView.layer.cornerRadius = 5.;
    [self.view addSubview:self.collageView];
    
    if (self.collage) {
        [self buildCollageView];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    const CGFloat kCollageViewPaddings = 5.;
    
    CGRect frame = self.collageView.frame;
    
    BOOL needUseWidth = YES;
    
    if (self.collage.ratio >= 1.) {
        if (self.view.frame.size.width < self.view.frame.size.height &&
            self.view.frame.size.height >= self.view.frame.size.width / self.collage.ratio) {
            needUseWidth = YES;
        } else {
            needUseWidth = NO;
        }
    } else {
        if (self.view.frame.size.height < self.view.frame.size.width &&
            self.view.frame.size.width >= self.view.frame.size.height / self.collage.ratio) {
            needUseWidth = YES;
        } else {
            needUseWidth = NO;
        }
    }
    
    
    if (needUseWidth) {
        frame.size.width = self.view.frame.size.width - kCollageViewPaddings * 2.;
        frame.size.height = frame.size.width / self.collage.ratio;
    } else {
        frame.size.height = self.view.frame.size.height - kCollageViewPaddings * 2.;
        frame.size.width = frame.size.height * self.collage.ratio;
    }
    
    self.collageView.frame = frame;
    
    self.collageView.center = CGPointMake(self.view.frame.size.width / 2., self.view.frame.size.height / 2.);
    
    [self.collageView.subviews makeObjectsPerformSelector:@selector(refreshFrame)];
}

#pragma mark - helpers

- (void)setCollage:(ICMCollage *)collage {
    if (_collage != collage) {
        _collage = collage;
        if ([self isViewLoaded]) {
            [self buildCollageView];
        }
    }
}

- (void)buildCollageView {
    [self.collageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    __weak __typeof(self) this = self;
    [self.collage enumerateRelativeFramesUsingBlock:^(CGRect relativeFrame, NSUInteger index) {
        [this createCollageElementViewWithRelativeFrame:relativeFrame];
    }];
}

- (void)createCollageElementViewWithRelativeFrame:(CGRect)relativeFrame {
    ICMCollageElementView *result = [ICMCollageElementView new];
    result.relativeFrame = relativeFrame;
    [result addTarget:self action:@selector(onCollageElementTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.collageView addSubview:result];
}

- (void)onPhotoSelected:(ICMImage *)photoImage {
    if (!photoImage.underlyingImage) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    }
    [photoImage imageWithCompletion:^(UIImage *image) {
        if (image) {
            self.currentCollageElementView.image = image;
            [SVProgressHUD dismiss];
            
            NSArray *images = [[self.collageView.subviews valueForKey:@"image"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject isKindOfClass:[UIImage class]];
            }]];
            self.navigationItem.rightBarButtonItem.enabled = [self.collage.relativeFrames count] == [images count];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"error loading image" , nil)];
        }
    }];
}

#pragma mark - Actions

- (IBAction)onDoneButtonTap:(id)sender {
    ICMPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ICMPreviewViewController"];
    vc.collageImage = [self.collageView renderImage];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onCollageElementTap:(id)sender {
    self.currentCollageElementView = sender;
    
    MWPhotoBrowser *browser = [[ICMPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = YES;
    browser.displayActionButton = NO;
    browser.displaySelectionButtons = YES;
    browser.startOnGrid = YES;
    [browser setCurrentPhotoIndex:0];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.mediaPhotos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [self.mediaPhotos[index] standartResolutionImage];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return [self.mediaPhotos[index] thumbnailImage];
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return NO;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [self.navigationController popViewControllerAnimated:YES];
    
    [self onPhotoSelected:[self.mediaPhotos[index] standartResolutionImage]];
}

@end
