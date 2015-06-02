//
//  KIFUITestActor+EXAdditions.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 18/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "KIFUITestActor+EXAdditions.h"
#import "GlobalDefs.h"
#import "TestDefs.h"

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

-(void)navigateToMainScreen {
    [tester waitForAnimationsToFinishWithTimeout:500];
    if([[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"Already have account"] != nil) {
        [tester tapViewWithAccessibilityLabel:@"Already have account"];
        [tester waitForTappableViewWithAccessibilityLabel:@"Enter your email"];
        [tester enterText:correctLogin intoViewWithAccessibilityLabel:@"Enter your email"];
        [tester enterText:correctPassword intoViewWithAccessibilityLabel:@"Enter your password"];
        [tester tapViewWithAccessibilityLabel:@"Sign in"];
        [tester waitForAnimationsToFinish];
        [tester waitForViewWithAccessibilityLabel:@"Add item"];
    }
}

-(void)navigateToAddItemScreen {
    [self navigateToMainScreen];
    [tester tapViewWithAccessibilityLabel:@"Add item"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Choose category"];
}

@end
