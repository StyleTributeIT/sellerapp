//
//  KIFUITestActor+EXAdditions.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 18/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "KIFUITestActor.h"

@interface KIFUITestActor (EXAdditions)

-(void)navigateToLoginScreen;
-(void)navigateToRegistrationScreen;
-(void)logoutIfPossible;
-(void)navigateToMainScreen;
-(void)navigateToAddItemScreen;

@end
