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
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    text = [text stringByAddingPercentEncodingWithAllowedCharacters:set];

    
    NSString *str = [NSString stringWithFormat:@"twitter://post?message=%@", text];
    NSURL *twitterURL = [NSURL URLWithString:str];
    if ([[UIApplication sharedApplication] canOpenURL: twitterURL]) {
        [[UIApplication sharedApplication] openURL: twitterURL];
    }

    
   /* UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url]
     applicationActivities:nil];
    if (_delegate)
        [_delegate shareTwitt:controller];*/
    //[self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)postToWhatsapp:(id)sender {
    NSString *text = [NSString stringWithFormat:@"%@ %@", self.product.share_text, self.product.url];//@"How to add Facebook and Twitter sharing to an iOS app";
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    text = [text stringByAddingPercentEncodingWithAllowedCharacters:set];
  //  NSURL *url = [NSURL URLWithString:self.product.url];//@"http://roadfiresoftware.com/2014/02/how-to-add-facebook-and-twitter-sharing-to-an-ios-app/"];
    
    NSString *str = [NSString stringWithFormat:@"whatsapp://send?text=%@", text];
    NSURL *whatsappURL = [NSURL URLWithString:str];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
}

- (IBAction)copyLink:(id)sender {
    NSString *text = [NSString stringWithFormat:@"%@ %@", self.product.share_text, self.product.url];//@"How to add Facebook and Twitter sharing to an iOS app";
  //  NSURL *url = [NSURL URLWithString:self.product.url];//@"http://roadfiresoftware.com/2014/02/how-to-add-facebook-and-twitter-sharing-to-an-ios-app/"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text]
     applicationActivities:nil];
    if (_delegate)
        [_delegate shareUIActivity:controller];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
