//
//  ContactUsController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "ContactUsController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MapKit/MapKit.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

// TODO: set real data
static NSString* stPhoneNumber = @"123456789";
static NSString* stMessage = @"Hello world!";
static const CGFloat stLat = 47.23135, stLon = 39.72328;

@interface ContactUsController () <MFMailComposeViewControllerDelegate, ABNewPersonViewControllerDelegate>

@end

@implementation ContactUsController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if([self isExistsContactWithPhoneNumber:stPhoneNumber]) {
        [self.whatsappButton setTitle:@"Whatsapp us" forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
}

-(IBAction)emailUs:(id)sender {
    [self sendMailTo:@"support@example.com" subject:@"Hello!" body:@"Hello!"];
}

#pragma mark - Send mail

-(void)sendMailTo:(NSString*)toStr subject:(NSString*)subject body:(NSString*)body
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:@[toStr]];
        [controller setSubject:subject];
        [controller setMessageBody:body isHTML:NO];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [GlobalHelper showMessage:@"Setup you email account first" withTitle:@""];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        //
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Send whatsapp message

-(IBAction)whatsappUs:(id)sender {
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://app"]]) {
        [self requestAccessToAddressBookWithAllow:^{
            ABRecordID contactId = [self getContactIDByPhoneNumber:stPhoneNumber];
            if(contactId != kABRecordInvalidID) {
                NSString *escapedString = [stMessage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@&abid=%d", escapedString, contactId]];
                [[UIApplication sharedApplication] openURL: whatsappURL];
            } else {
                [self createContactWithName:@"StyleTribute" andPhoneNumber:stPhoneNumber];
            }
        } deny:^{
            NSLog(@"You should allow access to contacts for StyleTribute in setting");
        }];
    } else {
        NSLog(@"whatsapp not installed");
    }
}

-(void)requestAccessToAddressBookWithAllow:(void(^)())allow deny:(void(^)())deny {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if(granted) {
                allow();
            }
            
            CFRelease(addressBookRef);
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        allow();
    } else {
        deny();
    }
}

-(BOOL)isExistsContactWithPhoneNumber:(NSString*)number {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        ABRecordID contactId = [self getContactIDByPhoneNumber:number];
        return (contactId != kABRecordInvalidID);
    }
    
    return NO;
}

-(ABRecordID)getContactIDByPhoneNumber:(NSString*)number {
    ABRecordID personId = kABRecordInvalidID;
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for(int i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            if([phoneNumber isEqualToString:number]) {
                personId = ABRecordGetRecordID(person);
            }
        }
        CFRelease(phoneNumbers);
    }
    
    CFRelease(allPeople);
    CFRelease(addressBook);
    
    return personId;
}

-(void)createContactWithName:(NSString*)name andPhoneNumber:(NSString*)number {
    ABRecordRef person = ABPersonCreate();
    CFErrorRef  error = NULL;
    
    ABMutableMultiValueRef phoneNumberMultiValue  = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(number), kABPersonPhoneMobileLabel, NULL);
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(name), nil);
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, &error);
    
    ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];
    view.newPersonViewDelegate = self;
    view.displayedPerson = person;
    UINavigationController *newNavigationController = [[UINavigationController alloc] initWithRootViewController:view];
    [self presentViewController:newNavigationController animated:YES completion:^{
        CFRelease(person);
        CFRelease(phoneNumberMultiValue);
    }];
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    [newPersonView dismissViewControllerAnimated:YES completion:^{
        if(person != nil) {
            ABRecordID recordId = ABRecordGetRecordID(person);
            if(recordId != kABRecordInvalidID) {
                NSString *escapedString = [stMessage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@&abid=%d", escapedString, recordId]];
                [[UIApplication sharedApplication] openURL: whatsappURL];
            }
        } else {
            NSLog(@"contact creation cancelled");
        }
    }];
}

#pragma mark - Map

- (IBAction)mapTapped:(UITapGestureRecognizer *)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f", stLat, stLon]];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        CLLocationCoordinate2D rdOfficeLocation = CLLocationCoordinate2DMake(stLat, stLon);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:rdOfficeLocation addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = @"StyleTribute";
        [item openInMapsWithLaunchOptions:nil];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
