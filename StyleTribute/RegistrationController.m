//
//  RegistrationController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "RegistrationController.h"
#import "GlobalHelper.h"

@interface RegistrationController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property NSArray* countries;
@property UIPickerView* picker;


@end

@implementation RegistrationController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.countries = @[@"country 1", @"country 2", @"country 3", @"country 4", @"country 5"];
    self.picker = [GlobalHelper createPickerForFields:@[self.countryField]];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)inputDone {
    NSInteger index = [self.picker selectedRowInComponent:0];
    self.countryField.text = [self.countries objectAtIndex:index];
    [self.activeField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self centerContent];
}

-(IBAction)createAccount:(id)sender {
    if([self noEmptyFields]) {
        if([self validateEmail:self.emailField.text]) {
            // login
        } else {
            [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Invalid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Please fill in all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

-(BOOL)noEmptyFields {
    return (self.userNameField.text.length > 0 &&
            self.passwordField.text.length > 0 &&
            self.firstNameField.text.length > 0 &&
            self.lastNameField.text.length > 0 &&
            self.emailField.text.length > 0 &&
            self.countryField.text.length > 0 &&
            self.phoneField.text.length > 0);
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.countries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.countries objectAtIndex:row];
}

- (void)setPickerData:(NSNotification*)aNotification {
    if(self.activeField == self.countryField) {
        [self.picker reloadAllComponents];
        
        NSUInteger index = [self.countries indexOfObject:((UITextField*)self.activeField).text];
        if(index == NSNotFound) {
            index = 0;
        }
        [self.picker selectRow:index inComponent:0 animated:NO];
    }
}

@end
