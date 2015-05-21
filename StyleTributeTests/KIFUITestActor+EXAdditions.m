//
//  KIFUITestActor+EXAdditions.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 18/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "KIFUITestActor+EXAdditions.h"
#import "GlobalDefs.h"

@implementation KIFUITestActor (EXAdditions)

-(void)navigateToLoginScreen {
    [tester tapViewWithAccessibilityLabel:@"Already have account"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Enter your email"];
}

-(void)navigateToRegistrationScreen {
    [tester tapViewWithAccessibilityLabel:@"Sign up"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Enter your username"];
}

-(void)logoutIfPossible {
    if([[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"My account"] != nil) {
        [tester tapViewWithAccessibilityLabel:@"My account"];
        [tester waitForTappableViewWithAccessibilityLabel:@"Logout"];
        [tester tapViewWithAccessibilityLabel:@"Logout"];
    } else {
        [tester tapViewWithAccessibilityLabel:@"Back"];
    }
}

@end
