//
//  TabbetViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/24/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "TabbetViewController.h"

@interface TabbetViewController ()

@end

@implementation TabbetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
/*    self.viewControllers = [NSArray arrayWithObjects:
                            [self viewControllerWithTabTitle:@"My warbrode" image:[UIImage imageNamed:@"wardrobe"]],
                            [self viewControllerWithTabTitle:@"Shop" image:[UIImage imageNamed:@"shop"]],
                            [self viewControllerWithTabTitle:@"Sell" image:nil],
                            [self viewControllerWithTabTitle:@"Profile 2" image:[UIImage imageNamed:@"profile"]],
                            [self viewControllerWithTabTitle:@"Notifications" image:[UIImage imageNamed:@"notifications"]], nil]; */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"camera"] highlightImage:[UIImage imageNamed:@"camera"]];
}

@end
