//
//  WelcomeController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KASlideShow.h>

@interface WelcomeController : UIViewController

@property IBOutlet KASlideShow* slideShow;
@property IBOutlet UIButton* signInButton;
@property IBOutlet UIButton* signUpButton;
@property IBOutlet UIButton* signUpFBButton;

-(IBAction)fbLogin:(id)sender;
-(void)showVertionAlert;

@end
