//
//  ResidentAddressController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "ResidentAddressController.h"

@interface ResidentAddressController ()

@property UIPickerView* picker;
@property NSArray* countries;

@end

@implementation ResidentAddressController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    self.countries = @[@"country 1", @"country 2", @"country 3", @"country 4", @"country 5"];
    self.picker = [GlobalHelper createPickerForFields:@[self.countryField] withTarget:self doneAction:@selector(pickerOk:) cancelAction:@selector(pickerCancel:)];
    self.picker.delegate = self;
    self.picker.dataSource = self;
}

-(IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromResidentAddress" sender:self];
}

-(IBAction)save:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromResidentAddress" sender:self];
}

#pragma mark - UIPicker

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

@end
