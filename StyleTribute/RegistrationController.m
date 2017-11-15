//
//  RegistrationController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "RegistrationController.h"
#import "Country.h"

@interface RegistrationController () <UIPickerViewDelegate>

@property UIPickerView* picker;

@end

@implementation RegistrationController

//-(id)initWithCoder:(NSCoder *)aDecoder {
//    return [super initWithCoder:aDecoder];
//}

-(void)viewDidLoad {
    [super viewDidLoad];
//    self.picker = [GlobalHelper createPickerForFields:@[self.countryField]];
//    self.picker.delegate = self;
//    self.picker.dataSource = self;
    
//    if([DataCache sharedInstance].countries == nil) {
//        [[ApiRequester sharedInstance] getCountries:^(NSArray *countries) {
//            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
//            [DataCache sharedInstance].countries = countries;
//            [self.picker reloadAllComponents];
//        } failure:^(NSString *error) {
//            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
//        }];
//    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerDidOpen:) name:UIKeyboardDidShowNotification object:nil];
}

//-(void)inputDone {
//    NSInteger index = [self.picker selectedRowInComponent:0];
//    Country* country = [[DataCache sharedInstance].countries objectAtIndex:index];
//    self.countryField.text = country.name;
//    [self.activeField resignFirstResponder];
//}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.slideShow start];
}

//- (void)pickerDidOpen:(NSNotification*)aNotification {
//    if(self.activeField == self.countryField && [DataCache sharedInstance].countries == nil) {
//        if([MRProgressOverlayView overlayForView:self.picker] == nil) {
//            [MRProgressOverlayView showOverlayAddedTo:self.picker  title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:NO];
//        }
//    }
//}

-(void)viewWillDisappear:(BOOL)animated {
    [self.slideShow stop];
    [super viewWillDisappear:animated];
}

-(IBAction)createAccount:(id)sender {
    if([self noEmptyFields]) {
        if([self validateEmail:self.emailField.text]) {
            
            [self.activeField resignFirstResponder];
            NSInteger index = [self.picker selectedRowInComponent:0];
            Country* country = [[DataCache sharedInstance].countries objectAtIndex:index];
            
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] registerWithEmail:self.emailField.text
                                                    password:self.passwordField.text
                                                   firstName:self.firstNameField.text
                                                    lastName:self.lastNameField.text
                                                    userName:nil
                                                     country:country.identifier
                                                       phone:self.phoneField.text
                                                     success:^(UserProfile *profile) {
                                                         
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [DataCache sharedInstance].userProfile = profile;
                [self performSegueWithIdentifier:@"showMainScreenSegue" sender:self];
            } failure:^(NSString *error) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                
                if([error isEqualToString:@"exists"]) {
                    [GlobalHelper showMessage:DefUserAlreadyExists withTitle:@"Registration error"];
                } else {
                    [GlobalHelper showMessage:error withTitle:@"Registration error"];
                }
            }];
        } else {
            [GlobalHelper showMessage:DefInvalidEmail withTitle:@"error"];
        }
    } else {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
    }
}

-(BOOL)noEmptyFields {
    return (self.passwordField.text.length > 0 &&
            self.firstNameField.text.length > 0 &&
            self.lastNameField.text.length > 0 &&
            self.emailField.text.length > 0);
}

#pragma mark - UIPickerView

//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
//    return 1;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
//    return [DataCache sharedInstance].countries.count;
//}
//
//- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    Country* country = [[DataCache sharedInstance].countries objectAtIndex:row];
//    return country.name;
//}
//
//- (void)setPickerData:(NSNotification*)aNotification {
//    if(self.activeField == self.countryField) {
//        [self.picker reloadAllComponents];
//        
//        Country* curCountry = [[[DataCache sharedInstance].countries linq_where:^BOOL(Country* country) {
//            return [country.name isEqualToString:((UITextField*)self.activeField).text];
//        }] firstObject];
//        
//        NSUInteger index = [[DataCache sharedInstance].countries indexOfObject:curCountry];
//        if(index == NSNotFound) {
//            index = 0;
//        }
//        [self.picker selectRow:index inComponent:0 animated:NO];
//    }
//}

@end
