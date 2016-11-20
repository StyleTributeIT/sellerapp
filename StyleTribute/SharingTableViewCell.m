//
//  SharingTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/19/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "SharingTableViewCell.h"

@implementation SharingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)postToFB:(id)sender {
    if (_delegate)
        [_delegate shareFB];
}

- (IBAction)postToTwitter:(id)sender {
    NSString *text = @"How to add Facebook and Twitter sharing to an iOS app";
    NSURL *url = [NSURL URLWithString:@"http://roadfiresoftware.com/2014/02/how-to-add-facebook-and-twitter-sharing-to-an-ios-app/"];
    UIImage *image = [UIImage imageNamed:@"roadfire-icon-square-200"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url]
     applicationActivities:nil];
    if (_delegate)
        [_delegate shareTwitt:controller];
    //[self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)postToWhatsapp:(id)sender {
    NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://send?text=Hello%2C%20World!"];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
}

- (IBAction)copyLink:(id)sender {
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end