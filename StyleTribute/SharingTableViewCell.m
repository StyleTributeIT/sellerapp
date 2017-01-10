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
    self.product = [DataCache getSelectedItem];
    // Initialization code
}

- (IBAction)postToFB:(id)sender {
    if (_delegate)
        [_delegate shareFB];
}

- (IBAction)postToTwitter:(id)sender {
    NSString *text = [NSString stringWithFormat:@"%@ %@", self.product.share_text, self.product.url];//@"How to add Facebook and Twitter sharing to an iOS app";
    NSURL *url = [NSURL URLWithString:self.product.url];//@"http://roadfiresoftware.com/2014/02/how-to-add-facebook-and-twitter-sharing-to-an-ios-app/"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url]
     applicationActivities:nil];
    if (_delegate)
        [_delegate shareTwitt:controller];
    //[self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)postToWhatsapp:(id)sender {
    NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://send"];
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
