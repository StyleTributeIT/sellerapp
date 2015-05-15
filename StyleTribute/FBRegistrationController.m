//
//  FBRegistrationController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "FBRegistrationController.h"
#import "GlobalHelper.h"

@interface FBRegistrationController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property NSArray* countries;
@property UIPickerView* picker;

@end

@implementation FBRegistrationController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.countries = @[@"country 1", @"country 2", @"country 3", @"country 4", @"country 5"];
    self.picker = [GlobalHelper createPickerForFields:@[self.countryField] withTarget:self doneAction:@selector(pickerOk:) cancelAction:@selector(pickerCancel:)];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self centerContent];
}

-(IBAction)createAccount:(id)sender {
    if([self noEmptyFields]) {
        //
    } else {
        [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Please fill in all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

-(BOOL)noEmptyFields {
    return (self.userNameField.text.length > 0 &&
            self.firstNameField.text.length > 0 &&
            self.lastNameField.text.length > 0 &&
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

-(void)pickerOk:(id)sender {
    NSInteger index = [self.picker selectedRowInComponent:0];
    self.countryField.text = [self.countries objectAtIndex:index];
    [self.activeField resignFirstResponder];
}

-(void)pickerCancel:(id)sender {
    [self.activeField resignFirstResponder];
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
