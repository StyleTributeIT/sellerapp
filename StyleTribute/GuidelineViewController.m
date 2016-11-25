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

@end

@implementation GuidelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.guidImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"guid%ld",self.index + 1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
