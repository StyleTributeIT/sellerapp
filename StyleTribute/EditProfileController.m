//
//  EditProfileController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "EditProfileController.h"
#import "Country.h"

@interface EditProfileController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property UIPickerView* picker;
@property Country* curCountry;

@end

@implementation EditProfileController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    self.picker = [GlobalHelper createPickerForFields:@[self.countryField]];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    UserProfile* profile = [DataCache sharedInstance].userProfile;
    self.emailField.text = profile.email;
    self.firstNameField.text = profile.firstName;
    self.lastNameField.text = profile.lastName;
    
    if([DataCache sharedInstance].countries == nil) {
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getCountries:^(NSArray *countries) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [DataCache sharedInstance].countries = countries;
            [self updateCurCountry];
            [self.picker reloadAllComponents];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        }];
    } else {
        [self updateCurCountry];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - Actions

-(IBAction)cancel:(id)sender {
    //[self performSegueWithIdentifier:@"unwindFromEditProfile" sender:self];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)save:(id)sender {
    if([self noEmptyFields]) {
        if([self validateEmail:self.emailField.text]) {
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] setAccountWithUserName:nil
                                                        firstName:self.firstNameField.text
                                                         lastName:self.lastNameField.text
                                                          country:self.curCountry.identifier
                                                            phone:[DataCache sharedInstance].userProfile.phone
                                                          success:^{
                                                              [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                                              UserProfile* curProfile = [DataCache sharedInstance].userProfile;
                                                              curProfile.firstName = self.firstNameField.text;
                                                              curProfile.lastName = self.lastNameField.text;
                                                              curProfile.country = self.curCountry.identifier;
                                                              [self performSegueWithIdentifier:@"unwindFromEditProfile" sender:self];
                                                          } failure:^(NSString *error) {
                                                              [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                                              [GlobalHelper showMessage:error withTitle:@"Update profile error"];
                                                          }];
        } else {
            [GlobalHelper showMessage:DefInvalidEmail withTitle:@"error"];
        }
    } else {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
    }
}

#pragma mark - Utils

-(BOOL)noEmptyFields {
    return (self.firstNameField.text.length > 0 &&
            self.lastNameField.text.length > 0 &&
            self.emailField.text.length > 0 /* &&
                                             self.countryField.text.length > 0*/);
}

-(void)updateCurCountry {
    self.curCountry = [[[DataCache sharedInstance].countries linq_where:^BOOL(Country* country) {
        return [country.identifier isEqualToString:[DataCache sharedInstance].userProfile.country];
    }] firstObject];
    self.countryField.text = self.curCountry.name;
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [DataCache sharedInstance].countries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Country* country = [[DataCache sharedInstance].countries objectAtIndex:row];
    return country.name;
}

- (void)setPickerData:(NSNotification*)aNotification {
    if(self.activeField == self.countryField) {
        [self.picker reloadAllComponents];
        
        NSUInteger index = [[DataCache sharedInstance].countries indexOfObject:self.curCountry];
        if(index == NSNotFound) {
            index = 0;
        }
        [self.picker selectRow:index inComponent:0 animated:NO];
    }
}

-(void)inputDone {
    NSInteger index = [self.picker selectedRowInComponent:0];
    Country* country = [[DataCache sharedInstance].countries objectAtIndex:index];
    self.curCountry = country;
    self.countryField.text = country.name;
    [self.activeField resignFirstResponder];
}

@end
