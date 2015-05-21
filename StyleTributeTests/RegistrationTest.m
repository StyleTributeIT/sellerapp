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

@interface RegistrationTest : KIFTestCase

@end

@implementation RegistrationTest

- (void)setUp {
    [super setUp];
    [tester navigateToRegistrationScreen];
}

- (void)tearDown {
    [tester logoutIfPossible];
    [super tearDown];
}

- (void)testEmptyField {
    [tester tapViewWithAccessibilityLabel:@"Create new account"];
    [tester waitForViewWithAccessibilityLabel:DefEmptyFields];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    XCTAssert(YES, @"Pass");
}

- (void)testCorrectRegistration {
    [tester enterText:@"testLogin" intoViewWithAccessibilityLabel:@"Enter your username"];
    [tester enterText:@"123456" intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester enterText:@"John" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Doe" intoViewWithAccessibilityLabel:@"Last name"];
    [tester enterText:@"test@gmail.com" intoViewWithAccessibilityLabel:@"Email"];
    [tester tapViewWithAccessibilityLabel:@"Country"];
    [tester enterText:@"+71234567890" intoViewWithAccessibilityLabel:@"Phone number"];
    [tester tapViewWithAccessibilityLabel:@"Create new account"];
    [tester waitForViewWithAccessibilityLabel:@"Wardrobe items type"];
    
    XCTAssert(YES, @"Pass");
}

@end
