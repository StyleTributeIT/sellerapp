//
//  XCDFormInputAccessoryView.h
//
//  Created by Cédric Luthi on 2012-11-10
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCDFormInputAccessoryView : UIView

- (id) initWithResponders:(NSArray *)responders; // Objects must be UIResponder instances
-(id) initWithTarget:(id)target  doneAction:(SEL)doneAction;
-(id) initWithTarget:(id)target hideNavButtons:(BOOL)hideNavButtons doneAction:(SEL)doneAction;

@property (nonatomic, strong) NSArray *responders;
@property (nonatomic, assign) BOOL hideNavButtons;
@property (nonatomic, assign) BOOL hasDoneButton; // Defaults to YES on iPhone, NO on iPad

- (void) setHasDoneButton:(BOOL)hasDoneButton animated:(BOOL)animated;

@end
