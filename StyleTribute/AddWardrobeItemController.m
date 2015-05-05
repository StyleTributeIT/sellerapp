//
//  AddWardrobeItemController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "AddWardrobeItemController.h"
#import "ChooseCategoryController.h"

@interface AddWardrobeItemController ()

@property UIPickerView* picker;
@property UIToolbar* pickerToolbar;
@property UIActionSheet* photoActionsSheet;

@property NSArray* categories;
@property NSArray* conditionTypes;
@property NSArray* sizes;

@end

@implementation AddWardrobeItemController

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];

    self.picker = [[UIPickerView alloc] init];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.pickerToolbar.barTintColor = [UIColor grayColor];
    self.pickerToolbar.translucent = NO;
    UIBarButtonItem *barDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(pickerOk:)];
    UIBarButtonItem *barCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(pickerCancel:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.pickerToolbar.items = @[barCancel, flexibleSpace, barDone];
    
//    self.categoryField.inputView = self.picker;
//    self.categoryField.inputAccessoryView = self.pickerToolbar;
    self.conditionField.inputView = self.picker;
    self.conditionField.inputAccessoryView = self.pickerToolbar;
    self.sizeField.inputView = self.picker;
    self.sizeField.inputAccessoryView = self.pickerToolbar;
    
    self.conditionTypes = @[@"condition 1", @"condition 2", @"condition 3", @"condition 4", @"condition 5", @"condition 6", @"condition 7"];
    self.sizes = @[@"size 1", @"size 2", @"size 3", @"size 4", @"size 5"];

    self.messageLabel.text = @""; //@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    [self.messageLabel sizeToFit];
    
    self.photoActionsSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take new picture", @"Pick from gallery", nil];
    self.photoActionsSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    if(self.activeField == self.conditionField || self.activeField == self.sizeField) {
        [self.picker reloadAllComponents];
        
        NSUInteger index = [[self getCurrentDatasource] indexOfObject:((UITextField*)self.activeField).text];
        if(index == NSNotFound) {
            index = 0;
        }
        [self.picker selectRow:index inComponent:0 animated:NO];
    }
}

#pragma mark - UIPickerView

-(NSArray*)getCurrentDatasource {
    if(self.activeField == self.conditionField) {
        return self.conditionTypes;
    } else if(self.activeField == self.sizeField) {
        return self.sizes;
    }
    
    return nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self getCurrentDatasource].count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self getCurrentDatasource] objectAtIndex:row];
}

-(void)pickerOk:(id)sender {
    NSInteger index = [self.picker selectedRowInComponent:0];
    if(self.activeField == self.conditionField) {
        self.conditionField.text = [self.conditionTypes objectAtIndex:index];
    } else if(self.activeField == self.sizeField) {
        self.sizeField.text = [self.sizes objectAtIndex:index];
    }
    
    [self.activeField resignFirstResponder];
}

-(void)pickerCancel:(id)sender {
    [self.activeField resignFirstResponder];
}

#pragma mark - Action sheet

-(IBAction)displayPhotosActionSheet:(UIGestureRecognizer *)gestureRecognizer {
//    UIView* tappedView = gestureRecognizer.view;
    
    [self.photoActionsSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: // take new picture
            NSLog(@"button 0");
            break;
        case 1: // pick from gallery
            NSLog(@"button 1");
            break;
            
        default:
            break;
    }
}

#pragma mark - Segues unwind handlers

-(IBAction)unwindToAddItem:(UIStoryboardSegue*)sender {
    if([sender.sourceViewController isKindOfClass:[ChooseCategoryController class]]) {
        ChooseCategoryController* ccController = sender.sourceViewController;
        self.categoryField.text = ccController.selectedCategory;
    }
    
    NSLog(@"unwindToWardrobeItems");
}

-(IBAction)cancelUnwindToAddItem:(UIStoryboardSegue*)sender {
    //    UIViewController *sourceViewController = sender.sourceViewController;
    NSLog(@"cancelUnwindToWardrobeItems");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == self.categoryField) {
        [self performSegueWithIdentifier:@"chooseCategorySegue" sender:self];
        return NO;
    }
    
    return YES;
}

@end
