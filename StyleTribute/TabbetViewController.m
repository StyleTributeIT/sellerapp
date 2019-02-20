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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self._layoued_out = NO;

    [self addCenterButtonWithImage:[UIImage imageNamed:@"camera"] highlightImage:[UIImage imageNamed:@"camera"]];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self._layoued_out)
    {
        
        self._layoued_out = YES;

        [self adjustPositionSellButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
