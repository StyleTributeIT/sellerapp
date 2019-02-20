//
//  ResidentAddressController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ResidentAddressController.h"
#import "Country.h"

@interface ResidentAddressController ()

@property UIPickerView* picker;
@property NSArray* states;
@property NSArray *Country;
@property NSInteger curCountryIndex;
@property NSInteger curStateIndex;

@end

@implementation ResidentAddressController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.curCountryIndex = -1;
    self.curStateIndex = -1;
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    self.picker = [GlobalHelper createPickerForFields:@[self.countryField, self.stateField]];
    self.picker.delegate = self;
    self.picker.dataSource = self;
   
    
    self.Country = [DataCache sharedInstance].countries;
    

    Address* curShippingAddress = [DataCache sharedInstance].shippingAddress;
    if(curShippingAddress) {
        
        self.firstNameField.text = curShippingAddress.firstName;
        self.lastNameField.text = curShippingAddress.lastName;
        self.companyField.text = curShippingAddress.company;
        self.addressField.text = curShippingAddress.address;
        self.cityField.text = curShippingAddress.city;
        self.postalCodeField.text = curShippingAddress.zipCode;
        self.phoneNumberField.text = curShippingAddress.contactNumber;
        
        Country* curCountry = [[[DataCache sharedInstance].countries linq_where:^BOOL(Country* item) {
            return [item.identifier isEqualToString:curShippingAddress.countryId];
        }] firstObject];
        self.curCountryIndex = [[DataCache sharedInstance].countries indexOfObject:curCountry];
        self.countryField.text = curCountry.name;
        
        if(curShippingAddress.state) {
            self.stateField.text = curShippingAddress.state.name;
            [[ApiRequester sharedInstance] getRegionsByCountry:curCountry.identifier success:^(NSArray *regions) {
                self.states = regions;
                curShippingAddress.state = [[regions linq_where:^BOOL(NamedItem* item) {
                    return (item.identifier == curShippingAddress.state.identifier);
                }] firstObject];
                self.curStateIndex = [regions indexOfObject:curShippingAddress.state];
                [self.stateField setEnabled:(regions != nil)];
            } failure:^(NSString *error) {}];
        }
    }
}

#pragma mark - Actions

-(IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromResidentAddress" sender:self];
}

-(IBAction)save:(id)sender {
    bool empty_fields = [self hasEmptyFields];
    if(empty_fields == false) {
        Country* curCountry = [[DataCache sharedInstance].countries objectAtIndex:self.curCountryIndex];
        Address* newAddress = [Address new];
        newAddress.firstName = self.firstNameField.text;
        newAddress.lastName = self.lastNameField.text;
        newAddress.company = self.companyField.text;
        newAddress.address = self.addressField.text;
        newAddress.city = self.cityField.text;
        newAddress.state = self.stateField.text;
        newAddress.zipCode = self.postalCodeField.text;
        newAddress.countryId = curCountry.identifier;
        newAddress.contactNumber = self.phoneNumberField.text;
        newAddress.cusomer_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"cust_id"];
        
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] setShippingAddress:newAddress success:^{
            [DataCache sharedInstance].userProfile.shippingAddress = newAddress;
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [self performSegueWithIdentifier:@"unwindFromResidentAddress" sender:self];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    } else {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
    }
}

#pragma mark - Text fields

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    
    if(self.activeField == self.countryField) {
        [self.picker reloadAllComponents];
        [self.picker selectRow:1 inComponent:0 animated:NO];
    } else if(self.activeField == self.stateField) {
        [self.picker reloadAllComponents];
        [self.picker selectRow:(self.curStateIndex >= 0 ? self.curStateIndex : 0) inComponent:0 animated:NO];
    }
}

#pragma mark - UIPicker

-(NSArray*)getCurrentDatasource {
    if(self.activeField == self.countryField) {
        return [DataCache sharedInstance].countries;
    } else if(self.activeField == self.stateField) {
        return self.states;
    } else {
        return nil;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self getCurrentDatasource].count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [[[self getCurrentDatasource] objectAtIndex:row] name];
}

-(void)inputDone {
    NSInteger index = [self.picker selectedRowInComponent:0];
    
    if(self.activeField == self.countryField) {
        Country* country = [[DataCache sharedInstance].countries objectAtIndex:index];
        if(index != self.curCountryIndex) {
            [self.stateField setEnabled:NO];
            [[ApiRequester sharedInstance] getRegionsByCountry:country.identifier success:^(NSArray *regions) {
                self.states = regions;
                [self.stateField setEnabled:(regions != nil)];
            } failure:^(NSString *error) {}];
        }
        self.curCountryIndex = index;
        self.countryField.text = country.name;
    } else if(self.activeField == self.stateField) {
        self.curStateIndex = index;
        self.stateField.text = [[self.states objectAtIndex:index] name];
    }
    
    [self.activeField resignFirstResponder];
}

#pragma mark -

-(BOOL)hasEmptyFields {
    //    BOOL isStateFilled = (self.stateField.isEnabled ? (self.stateField.text.length > 0) : YES);
    if (self.firstNameField.text.length == 0)
        return true;
    if (self.lastNameField.text.length == 0)
        return true;
    if (self.addressField.text.length == 0)
        return true;
    if (self.cityField.text.length == 0)
        return true;
    if (self.postalCodeField.text.length == 0)
        return true;
    if (self.countryField.text.length == 0)
        return true;
    if (self.phoneNumberField.text.length == 0)
        return true;
    return false;
}

@end
