//
//  AddWardrobeItemController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalDefs.h"
#import "GlobalHelper.h"
#import "AddWardrobeItemController.h"
#import "ChooseCategoryController.h"
#import "TutorialController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface AddWardrobeItemController ()

@property UIPickerView* picker;
@property UIToolbar* pickerToolbar;
@property UIActionSheet* photoActionsSheet;

@property NSArray* categories;
@property NSArray* conditionTypes;
@property NSArray* sizes;

@property UIImageView* selectedImage;
@property BOOL isTutorialPresented;

@end

@implementation AddWardrobeItemController

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isTutorialPresented = NO;
    
    self.picker = [GlobalHelper createPickerForFields:@[self.conditionField, self.sizeField]];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.conditionTypes = @[@"condition 1", @"condition 2", @"condition 3", @"condition 4", @"condition 5", @"condition 6", @"condition 7"];
    self.sizes = @[@"size 1", @"size 2", @"size 3", @"size 4", @"size 5"];

    self.messageLabel.text = @""; //@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    [self.messageLabel sizeToFit];
    
    self.photoActionsSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take new picture", @"Pick from gallery", nil];
    self.photoActionsSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.isTutorialPresented) {
        [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
        self.isTutorialPresented = NO;
    }
}

- (void)setPickerData:(NSNotification*)aNotification {
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

-(void)inputDone {
    NSInteger index = [self.picker selectedRowInComponent:0];
    if(self.activeField == self.conditionField) {
        self.conditionField.text = [self.conditionTypes objectAtIndex:index];
    } else if(self.activeField == self.sizeField) {
        self.sizeField.text = [self.sizes objectAtIndex:index];
    }
    
    [self.activeField resignFirstResponder];
}

#pragma mark - Action sheet

-(IBAction)displayPhotosActionSheet:(UIGestureRecognizer *)gestureRecognizer {
    self.selectedImage = (UIImageView*)gestureRecognizer.view;
    [self.photoActionsSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: { // take new picture
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            if([defs objectForKey:@"displayTutorial"] == nil) {
                [self performSegueWithIdentifier:@"tutorialSegue" sender:self];
                [defs setBool:NO forKey:@"displayTutorial"];
                self.isTutorialPresented = YES;
            } else {
                [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
            }
            break;
        }
        case 1: // pick from gallery
            [self presentCameraController: UIImagePickerControllerSourceTypePhotoLibrary];
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
    } else if([sender.sourceViewController isKindOfClass:[TutorialController class]]) {
    }
    
    NSLog(@"unwindToAddItem");
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    [self setPickerData:nil];
}

#pragma mark - Camera

-(void)presentCameraController:(UIImagePickerControllerSourceType)type {
    if([UIImagePickerController isSourceTypeAvailable:type]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = type;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        if(type == UIImagePickerControllerSourceTypeCamera) {
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            CGRect cameraViewRect = [[UIScreen mainScreen] bounds];
            if(screenSize.height/screenSize.width > 1.5) {
                cameraViewRect = CGRectMake(0, 40, screenSize.width, screenSize.width*4.0/3.0);
            }
            
            UIImage* outline = [UIImage imageNamed:@"SquareOutlineDemo"];
            UIImageView* overlay = [[UIImageView alloc] initWithFrame:CGRectMake((cameraViewRect.size.width - outline.size.width)/2, (cameraViewRect.size.height - outline.size.height)/2 + cameraViewRect.origin.y, outline.size.width, outline.size.height)];
            overlay.image = outline;
            picker.cameraOverlayView = overlay;
        }
        
        [self presentViewController:picker animated:YES completion:^{
        }];
    } else {
        NSLog(@"camera or photo library are not available on this device");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.selectedImage.image = chosenImage;
//    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.9);
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
