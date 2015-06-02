//
//  LoginTest.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 18/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <KIFTestCase.h>
#import <KIFUITestActor.h>
#import "KIFUITestActor+EXAdditions.h"
#import "GlobalDefs.h"
#import "TestDefs.h"

@interface LoginTest : KIFTestCase

@end

@implementation LoginTest

- (void)setUp {
    [super setUp];
    [KIFUITestActor setDefaultTimeout:60];
    [tester navigateToLoginScreen];
}

- (void)tearDown {
    [tester logoutIfPossible];
    [super tearDown];
}

- (void)testLogInToMainScreen {
    [tester enterText:correctLogin intoViewWithAccessibilityLabel:@"Enter your email"];
    [tester enterText:correctPassword intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester waitForViewWithAccessibilityLabel:@"Wardrobe items type"];
    
    XCTAssert(YES, @"Pass");
}

- (void)testIncorrectLogin {
    [tester enterText:@"testLogin" intoViewWithAccessibilityLabel:@"Enter your email"];
    [tester enterText:correctPassword intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester waitForViewWithAccessibilityLabel:DefInvalidEmail];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    XCTAssert(YES, @"Pass");
}

- (void)testIncorrectPassword {
    [tester enterText:correctLogin intoViewWithAccessibilityLabel:@"Enter your email"];
    [tester enterText:@"testPassword" intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester waitForViewWithAccessibilityLabel:DefInvalidLoginPassword];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    XCTAssert(YES, @"Pass");
}

- (void)testEmptyLogin {
    [tester enterText:@"" intoViewWithAccessibilityLabel:@"Enter your email"];
    [tester enterText:correctPassword intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester waitForViewWithAccessibilityLabel:DefEmptyFields];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    XCTAssert(YES, @"Pass");
}

- (void)testEmptyPassword {
    [tester enterText:correctLogin intoViewWithAccessibilityLabel:@"Enter your email"];
    [tester enterText:@"" intoViewWithAccessibilityLabel:@"Enter your password"];
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester waitForViewWithAccessibilityLabel:DefEmptyFields];
    [tester tapViewWithAccessibilityLabel:@"OK"];
    
    XCTAssert(YES, @"Pass");
}

@end
