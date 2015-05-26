//
//  FBRegistrationController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "FBRegistrationController.h"
#import "GlobalHelper.h"
#import "GlobalDefs.h"
#import "ApiRequester.h"
#import <MRProgress.h>
#import "DataCache.h"
#import "Country.h"
#import <NSArray+LinqExtensions.h>

@interface FBRegistrationController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property NSArray* countries;
@property UIPickerView* picker;

@end

@implementation FBRegistrationController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.picker = [GlobalHelper createPickerForFields:@[self.countryField]];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    [GlobalHelper configureSlideshow:self.slideShow];
    
    if([DataCache sharedInstance].countries == nil) {
        [[ApiRequester sharedInstance] getCountries:^(NSArray *countries) {
            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
            [DataCache sharedInstance].countries = countries;
            [self.picker reloadAllComponents];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerDidOpen:) name:UIKeyboardDidShowNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self centerContent];
    [self.slideShow start];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.slideShow stop];
    [super viewWillDisappear:animated];
}

- (void)pickerDidOpen:(NSNotification*)aNotification {
    if(self.activeField == self.countryField && [DataCache sharedInstance].countries == nil) {
        if([MRProgressOverlayView overlayForView:self.picker] == nil) {
            [MRProgressOverlayView showOverlayAddedTo:self.picker  title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:NO];
        }
    }
}

-(IBAction)createAccount:(id)sender {
    if([self noEmptyFields]) {
        //
    } else {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
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
    return [DataCache sharedInstance].countries.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Country* country = [[DataCache sharedInstance].countries objectAtIndex:row];
    return country.name;
}

- (void)setPickerData:(NSNotification*)aNotification {
    if(self.activeField == self.countryField) {
        [self.picker reloadAllComponents];
        
        Country* curCountry = [[[DataCache sharedInstance].countries linq_where:^BOOL(Country* country) {
            return [country.name isEqualToString:((UITextField*)self.activeField).text];
        }] firstObject];
        
        NSUInteger index = [[DataCache sharedInstance].countries indexOfObject:curCountry];
        if(index == NSNotFound) {
            index = 0;
        }
        [self.picker selectRow:index inComponent:0 animated:NO];
    }
}

@end
