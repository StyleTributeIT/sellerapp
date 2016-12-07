//
//  GuidelineViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/25/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "GuidelineViewController.h"

@interface GuidelineViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *guidImage;
@property (strong, nonatomic) IBOutlet UILabel *subtitle;
@property (strong, nonatomic) IBOutlet UILabel *topTitle;

@end

@implementation GuidelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.guidImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"guid%ld",self.index + 1]];
    if (self.index > 0)
    {
        self.subtitle.hidden = NO;
    }
    switch (self.index) {
        case 0:
            self.topTitle.text = @"Here are some tips to help you take the best photo of your item!";
            self.subtitle.hidden = YES;
            break;
        case 1:
            self.subtitle.text = @"Follow the guidelines given on the camera.";
            self.topTitle.text = @"Keep to the guidelines";
            break;
        case 2:
            self.subtitle.text = @"How you light your product will make a big difference in your final output.";
            self.topTitle.text = @"Find a place with good lightning";
            break;
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
