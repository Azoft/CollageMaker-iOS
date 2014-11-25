//
//  ICMViewController.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 07.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMMenuViewCotrnoller.h"
#import "ICMUser.h"
#import "ICMUserSearchViewController.h"
#import "ICMCollageViewController.h"
#import "ICMCollage.h"
#import "UIImage+CollagePreview.h"

#import <QuartzCore/CALayer.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ICMMenuViewCotrnoller ()

@property (nonatomic, weak) IBOutlet UIButton *giveCollageButton;
@property (nonatomic, weak) IBOutlet UIButton *nameButton;
@property (nonatomic, weak) IBOutlet iCarousel *collagePreviewCarousel;

@property (nonatomic, strong) ICMUser *selectedUser;
@property (nonatomic, strong) ICMCollage *selectedCollage;

@property (nonatomic, strong) NSArray *collages;
@property (nonatomic, strong) NSMutableDictionary *previewImages;

@end

@implementation ICMMenuViewCotrnoller

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _collages = [ICMCollage collages];
        _selectedCollage = [_collages firstObject];
        _previewImages = [NSMutableDictionary dictionaryWithCapacity:[_collages count]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameButton.layer.cornerRadius = self.giveCollageButton.layer.cornerRadius = 5.;
    
    self.collagePreviewCarousel.type = iCarouselTypeCoverFlow2;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"presentUserSearchNC"]) {
        ICMUserSearchViewController *vc = (ICMUserSearchViewController *)[segue.destinationViewController topViewController];
        __weak __typeof(self) this = self;
        vc.completion = ^ (ICMUser *user) {
            this.selectedUser = user;
        };
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.previewImages removeAllObjects];
}

#pragma mark - helpers

- (void)setSelectedUser:(ICMUser *)selectedUser {
    [self.nameButton setTitle:selectedUser.username forState:UIControlStateNormal];
    _selectedUser = selectedUser;
    [self refreshGiveCollageButton];
}

- (void)setSelectedCollage:(ICMCollage *)selectedCollage {
    _selectedCollage = selectedCollage;
    [self refreshGiveCollageButton];
}

- (void)refreshGiveCollageButton {
    self.giveCollageButton.enabled = self.selectedUser && self.selectedCollage;
}

#pragma mark - Actions

- (IBAction)onGiveCollageButtonTap:(UIButton *)sender {
    __weak __typeof(self) this = self;

    [SVProgressHUD showWithStatus:@"Загрузка списка фотографий" maskType:SVProgressHUDMaskTypeGradient];
    
    [self.selectedUser requesTopPhotosWithCompletion:^(NSArray *mediaObjects, NSError *error) {
        if ([mediaObjects count] == 0 || error) {
            [SVProgressHUD showErrorWithStatus:error ? [error localizedDescription] : @"У выбранного пользователя список фотографий пуст"];
        } else {
            [SVProgressHUD dismiss];
            
            ICMCollageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ICMCollageViewController"];
            vc.collage = this.selectedCollage;
            vc.mediaPhotos = mediaObjects;
            [this.navigationController pushViewController:vc animated:YES];
        }
    }];
}

#pragma mark iCarousel staff

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.collages count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UIImageView *result = (UIImageView *)view;
    
    if (!result) {
        result = [[UIImageView alloc] initWithFrame:CGRectMake(0.,
                                                               0.,
                                                               self.collagePreviewCarousel.frame.size.height,
                                                               self.collagePreviewCarousel.frame.size.height)];
    }
    
    if (!self.previewImages[@(index)]) {
        self.previewImages[@(index)] = [UIImage renderPreviewImageWithCollage:self.collages[index] ofSize:result.frame.size];
    }
    result.image = self.previewImages[@(index)];
    
    return result;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    const CGFloat carouselSpacingCoef = 1.1;
    return option == iCarouselOptionSpacing ? value * carouselSpacingCoef : value;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    self.selectedCollage = self.collages[index];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    self.selectedCollage = self.collages[carousel.currentItemIndex];
}

@end
