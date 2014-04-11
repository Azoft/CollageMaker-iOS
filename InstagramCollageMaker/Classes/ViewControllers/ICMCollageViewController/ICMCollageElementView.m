//
//  ICMCollageElementView.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 11.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMCollageElementView.h"

@implementation ICMCollageElementView {
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UILabel *_textLabel;
}

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
    _imageView.image = image;
    _textLabel.hidden = image != nil;
    
    CGRect frame = _imageView.frame;
    frame.size = image.size;
    _imageView.frame = frame;
    
    _scrollView.contentSize = image.size;
    
    [self setMaxMinZoomScalesForCurrentBounds];
}

- (UIImage *)image {
    return _imageView.image;
}

#pragma mark - UIScrollViewStaff

- (void)setMaxMinZoomScalesForCurrentBounds {
	_scrollView.maximumZoomScale = 1;
	_scrollView.minimumZoomScale = 1;
	_scrollView.zoomScale = 1;
    
	_imageView.frame = CGRectMake(0, 0, _imageView.image.size.width, _imageView.image.size.height);
	
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxScale = 4;
    }
    
	if (xScale >= 1 && yScale >= 1) {
		minScale = 1.0;
	}
	
	_scrollView.maximumZoomScale = maxScale;
	_scrollView.minimumZoomScale = minScale;
    
    _scrollView.zoomScale = [self initialZoomScaleWithMinScale];
    
    if (_scrollView.zoomScale != minScale) {
        _scrollView.contentOffset = CGPointMake((imageSize.width * _scrollView.zoomScale - boundsSize.width) / 2.0,
                                                (imageSize.height * _scrollView.zoomScale - boundsSize.height) / 2.0);
        _scrollView.scrollEnabled = NO;
    }
}

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = _scrollView.minimumZoomScale;
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    CGFloat boundsAR = boundsSize.width / boundsSize.height;
    CGFloat imageAR = imageSize.width / imageSize.height;
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    
    if (ABS(boundsAR - imageAR) < 0.17) {
        zoomScale = MAX(xScale, yScale);
        zoomScale = MIN(MAX(_scrollView.minimumZoomScale, zoomScale), _scrollView.maximumZoomScale);
    }
    return zoomScale;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = _scrollView.bounds.size;
    CGRect contentsFrame = _imageView.frame;
    
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
    
    _imageView.frame = contentsFrame;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

@end
