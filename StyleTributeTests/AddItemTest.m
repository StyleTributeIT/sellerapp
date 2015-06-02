//
//  AddItemTest.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 01/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <KIFTestCase.h>
#import <KIFUITestActor.h>
#import "KIFUITestActor+EXAdditions.h"
#import "GlobalDefs.h"
#import "UIView+Additions.h"

@interface AddItemTest : KIFTestCase

@end

@implementation AddItemTest

- (void)setUp {
    [super setUp];
    [KIFUITestActor setDefaultTimeout:20];
}

- (void)tearDown {
    [super tearDown];
}

-(void)beforeAll {
    [tester navigateToAddItemScreen];
}

-(void)afterAll {
    [tester tapViewWithAccessibilityLabel:@"Cancel"];
    [tester logoutIfPossible];
}

- (void)test1_ChooseCategoryCancelling {
    
    [tester tapViewWithAccessibilityLabel:@"Choose category"];
    [tester waitForAnimationsToFinishWithTimeout:500];
    [tester tapViewWithAccessibilityLabel:@"Cancel"];
    UITextField* chooseCategoryField = (UITextField*)[tester waitForTappableViewWithAccessibilityLabel:@"Choose category"];
    
    XCTAssert(chooseCategoryField.text.length == 0, @"Choose category cancelled");
}

- (void)test2_ChooseCategorySelectValue {
    
    [tester tapViewWithAccessibilityLabel:@"Choose category"];
    [tester waitForAnimationsToFinishWithTimeout:500];
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Choose category table"];
    UITextField* chooseCategoryField = (UITextField*)[tester waitForTappableViewWithAccessibilityLabel:@"Choose category"];
    
    XCTAssert(chooseCategoryField.text.length > 0, @"Choose category value selected");
}

- (void)test3_SelectPhoto {
    [tester waitForViewWithAccessibilityLabel:@"Photos collection"];
    
    [self selectPhoto:0];
    [self selectPhoto:1];
    [self selectPhoto:2];
    
    XCTAssert(YES, @"Choose category value selected");
}

-(void)selectPhoto:(NSUInteger)num {
    [tester longPressViewWithAccessibilityLabel:[NSString stringWithFormat:@"Photo cell %zd", num] duration:0.5];
    [tester waitForTappableViewWithAccessibilityLabel:@"Pick from gallery"];
    [tester tapViewWithAccessibilityLabel:@"Pick from gallery"];
    [tester waitForViewWithAccessibilityLabel:@"Moments"];
    [tester tapViewWithAccessibilityLabel:@"Moments"];
    [tester waitForAnimationsToFinishWithTimeout:100];
    
    NSInteger column = num + 1, row = 1;
    const CGFloat headerHeight = 64.0 + 44;
    const CGSize thumbnailSize = CGSizeMake(75.0, 75.0);
    const CGFloat thumbnailMargin = 5.0;
    CGPoint thumbnailCenter;
    thumbnailCenter.x = thumbnailMargin + (MAX(0, column - 1) * (thumbnailSize.width + thumbnailMargin)) + thumbnailSize.width / 2.0;
    thumbnailCenter.y = headerHeight + thumbnailMargin + (MAX(0, row - 1) * (thumbnailSize.height + thumbnailMargin)) + thumbnailSize.height / 2.0;
    [tester tapScreenAtPoint:thumbnailCenter];
    [tester waitForViewWithAccessibilityLabel:@"Choose category"];
}

-(void)test4_fillAllFields {
    [tester waitForViewWithAccessibilityLabel:@"Description"];
    [tester enterText:@"description" intoViewWithAccessibilityLabel:@"Description"];
    [tester tapViewWithAccessibilityLabel:@"Brand"];
    [tester tapViewWithAccessibilityLabel:@"Size"];
    [tester tapViewWithAccessibilityLabel:@"Condition"];
}

@end
