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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"camera"] highlightImage:[UIImage imageNamed:@"camera"]];
}

@end
