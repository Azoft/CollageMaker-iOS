//
//  ICMCollageElementView.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 11.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMCollageElementView.h"

@interface ICMCollageElementView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ICMCollageElementView

@dynamic image;

- (id)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onScrollViewTap:)]];
        [self addSubview:_scrollView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor colorWithWhite:0. alpha:0.5];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:25.];
        _textLabel.text = @"+";
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.autoresizingMask = _scrollView.autoresizingMask;
        [self addSubview:_textLabel];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_scrollView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setMaxMinZoomScalesForCurrentBounds];
}

#pragma mark - Actions

- (void)onScrollViewTap:(id)sender {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - helpers

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.textLabel.hidden = image != nil;
    
    CGRect frame = self.imageView.frame;
    frame.size = image.size;
    self.imageView.frame = frame;
    
    self.scrollView.contentSize = image.size;
    
    [self setMaxMinZoomScalesForCurrentBounds];
}

- (UIImage *)image {
    return self.imageView.image;
}

#pragma mark - UIScrollViewStaff

- (void)setMaxMinZoomScalesForCurrentBounds {
	self.scrollView.maximumZoomScale = 1;
	self.scrollView.minimumZoomScale = 1;
	self.scrollView.zoomScale = 1;
    
	self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
	
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    const CGFloat iPhoneMaxScale = 3.;
    const CGFloat iPadMaxScale = 4.;
    
    CGFloat maxScale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? iPadMaxScale : iPhoneMaxScale;
    
	if (xScale >= 1 && yScale >= 1) {
		minScale = 1.0;
	}
	
	self.scrollView.maximumZoomScale = maxScale;
	self.scrollView.minimumZoomScale = minScale;
    
    self.scrollView.zoomScale = [self initialZoomScaleWithMinScale];
    
    if (self.scrollView.zoomScale != minScale) {
        self.scrollView.contentOffset = CGPointMake((imageSize.width * self.scrollView.zoomScale - boundsSize.width) / 2.,
                                                    (imageSize.height * self.scrollView.zoomScale - boundsSize.height) / 2.);
        self.scrollView.scrollEnabled = NO;
    }
}

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.scrollView.minimumZoomScale;
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    CGFloat boundsAR = boundsSize.width / boundsSize.height;
    CGFloat imageAR = imageSize.width / imageSize.height;
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    
    const CGFloat minARDifference = 0.17;
    
    if (ABS(boundsAR - imageAR) < minARDifference) {
        zoomScale = MAX(xScale, yScale);
        zoomScale = MIN(MAX(self.scrollView.minimumZoomScale, zoomScale), self.scrollView.maximumZoomScale);
    }
    return zoomScale;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

@end
