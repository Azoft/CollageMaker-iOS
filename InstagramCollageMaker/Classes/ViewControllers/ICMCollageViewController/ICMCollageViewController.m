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

#import <QuartzCore/CALayer.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ICMCollageViewController ()

@end

@implementation ICMCollageViewController {
    UIView *_collageView;
    __weak UIButton *_currentCollageElementButton;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                                               target:self
                                                                                               action:@selector(onSendButtonTap:)];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.title = @"Выберите фотографии";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _collageView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.width)];
    _collageView.backgroundColor = [UIColor whiteColor];
    _collageView.layer.cornerRadius = 5.;
    [self.view addSubview:_collageView];
    
    if (self.collage) {
        [self buildCollageView];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    const CGFloat kCollageViewPaddings = 5.;
    
    CGRect frame = _collageView.frame;
    
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
    
    _collageView.frame = frame;
    
    _collageView.center = CGPointMake(self.view.frame.size.width / 2., self.view.frame.size.height / 2.);
    
    [_collageView.subviews makeObjectsPerformSelector:@selector(refreshFrame)];
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
    [_collageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    __weak __typeof(self) this = self;
    [self.collage enumerateRelativeFramesUsingBlock:^(CGRect relativeFrame, NSUInteger index) {
        [this createCollageElementViewWithRelativeFrame:relativeFrame];
    }];
}

- (void)createCollageElementViewWithRelativeFrame:(CGRect)relativeFrame {
    UIButton *result = [UIButton buttonWithType:UIButtonTypeCustom];
    result.backgroundColor = [UIColor colorWithWhite:0. alpha:0.3];
    result.imageView.contentMode = UIViewContentModeScaleAspectFill;
    result.relativeFrame = relativeFrame;
    [result setTitle:@"+" forState:UIControlStateNormal];
    [result setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [result setTitleColor:[UIColor colorWithWhite:1. alpha:0.5] forState:UIControlStateHighlighted];
    result.titleLabel.font = [UIFont boldSystemFontOfSize:25.];
    [result addTarget:self action:@selector(onCollageElementTap:) forControlEvents:UIControlEventTouchUpInside];
    [_collageView addSubview:result];
}

- (void)onPhotoSelected:(ICMImage *)photoImage {
    if (!photoImage.underlyingImage) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    }
    [photoImage imageWithCompletion:^(UIImage *image) {
        [_currentCollageElementButton setImage:image forState:UIControlStateNormal];
        [SVProgressHUD dismiss];
        [_currentCollageElementButton setTitle:nil forState:UIControlStateNormal];
        
        NSArray *images = [[_collageView.subviews valueForKey:@"currentImage"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass:[UIImage class]];
        }]];
        self.navigationItem.rightBarButtonItem.enabled = [self.collage.relativeFrames count] == [images count];
    }];
}

#pragma mark - Actions

- (void)onSendButtonTap:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setSubject:@"Instagram collage"];
        NSData *imageData = UIImagePNGRepresentation([_collageView renderImage]);
        [mailVC addAttachmentData:imageData mimeType:@"image/png" fileName:@"photoCollage"];
        [self presentViewController:mailVC animated:YES completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"В данный момент отправка невозможна"];
    }
}

- (void)onCollageElementTap:(UIButton *)sender {
    _currentCollageElementButton = sender;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = YES;
    browser.displayActionButton = NO;
    browser.displaySelectionButtons = YES;
    browser.startOnGrid = YES;
    [browser setCurrentPhotoIndex:0];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - 

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        [SVProgressHUD showErrorWithStatus:@"Не удалось отправить email"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
