//
//  ICMPreviewViewController.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 10.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMPreviewViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface ICMPreviewViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *previewView;

@end

@implementation ICMPreviewViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                                               target:self
                                                                                               action:@selector(onSendButtonTap:)];
        self.navigationItem.title = NSLocalizedString(@"preview", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.previewView.image = self.collageImage;
}

#pragma mark - Actions

- (void)onSendButtonTap:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setSubject:@"Instagram collage"];
        NSData *imageData = UIImagePNGRepresentation(self.collageImage);
        [mailVC addAttachmentData:imageData mimeType:@"image/png" fileName:@"photoCollage"];
        [self presentViewController:mailVC animated:YES completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"at the moment, not sent, please check your email settings", nil)];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"failed to send email", nil)];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
