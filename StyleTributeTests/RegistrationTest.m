//
//  RegistrationTest.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 18/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <KIFTestCase.h>
#import <KIFUITestActor.h>
#import "KIFUITestActor+EXAdditions.h"
#import "GlobalDefs.h"

static NSString* testEmail = @"test4@gmail.com";

@interface RegistrationTest : KIFTestCase

@end

@implementation RegistrationTest

- (void)setUp {
    [super setUp];
    [KIFUITestActor setDefaultTimeout:60];
    [tester navigateToRegistrationScreen];
}

- (void)tearDown {
    [tester logoutIfPossible];
    [super tearDown];
}

- (void)test1_EmptyField {
    [tester tapViewWithAccessibilityLabel:@"Create new account"];
    [tester waitForViewWithAccessibilityLabel:DefEmptyFields];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    XCTAssert(YES, @"Pass");
}

- (void)test2_CorrectRegistration {
    [tester enterText:@"testLogin" intoViewWithAccessibilityLabel:@"Enter your username"];
    [tester enterText:@"123456" intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester enterText:@"John" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Doe" intoViewWithAccessibilityLabel:@"Last name"];
    [tester enterText:testEmail intoViewWithAccessibilityLabel:@"Email"];
    [tester tapViewWithAccessibilityLabel:@"Country"];
    [tester enterText:@"+71234567890" intoViewWithAccessibilityLabel:@"Phone number"];
    [tester tapViewWithAccessibilityLabel:@"Create new account"];
    [tester waitForViewWithAccessibilityLabel:@"Wardrobe items type"];
    
    XCTAssert(YES, @"Pass");
}

- (void)test3_ExistingUser {
    [tester enterText:@"testLogin" intoViewWithAccessibilityLabel:@"Enter your username"];
    [tester enterText:@"123456" intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester enterText:@"John" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Doe" intoViewWithAccessibilityLabel:@"Last name"];
    [tester enterText:testEmail intoViewWithAccessibilityLabel:@"Email"];
    [tester tapViewWithAccessibilityLabel:@"Country"];
    [tester enterText:@"+71234567890" intoViewWithAccessibilityLabel:@"Phone number"];
    [tester tapViewWithAccessibilityLabel:@"Create new account"];
    [tester waitForViewWithAccessibilityLabel:DefUserAlreadyExists];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    XCTAssert(YES, @"Pass");
}

@end
