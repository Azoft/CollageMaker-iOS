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
        self.navigationItem.title = @"Превью";
    }
    return self;
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
        [SVProgressHUD showErrorWithStatus:@"В данный момент отправка невозможна, пожалуйста, проверьте настройки email"];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        [SVProgressHUD showErrorWithStatus:@"Не удалось отправить email"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
