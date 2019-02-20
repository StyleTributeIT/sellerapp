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
   /* if (self.index > 0)
    {
        self.subtitle.hidden = NO;
    }*/
    self.subtitle.hidden = NO;
    switch (self.index) {
        case 0:
            self.subtitle.text = @"Use photos taken by you. The item should’t be worn in the photo. And we don’t need any fingers anywhere!";
            self.topTitle.text = @"Remember, the better the photo, the quicker it sells!";
            //self.subtitle.hidden = YES;
            break;
        case 1:
            self.subtitle.text = @"Use the frame provided to position your item in the best way and make sure the item is at a right angle.";
            self.topTitle.text = @"Keep to the frame";
            break;
        case 2:
            self.subtitle.text = @"Put the item on a white background and take it out of its box and/ or dust bag.";
            self.topTitle.text = @"Have a white background";
            break;
        case 3:
            self.subtitle.text = @"Make sure the light comes from behind you and onto the item.";
            self.topTitle.text = @"Find a place with good lighting";
            break;
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
