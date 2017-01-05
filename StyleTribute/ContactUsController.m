//
//  ContactUsController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ContactUsController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MapKit/MapKit.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

// TODO: set real data
static NSString* stPhoneNumber = @"+6591593853";
static NSString* stMessage = @"Hello!";

@interface ContactUsController () <MFMailComposeViewControllerDelegate, ABNewPersonViewControllerDelegate>

@property (strong, nonatomic) MKPlacemark *placemark;

@end

@implementation ContactUsController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if([self isExistsContactWithPhoneNumber:stPhoneNumber]) {
        [self.whatsappButton setTitle:@"Whatsapp us" forState:UIControlStateNormal];
    }
    
    [self addPinToMap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
}

#pragma mark - Call phone

- (IBAction)callUs:(id)sender {
    NSURL *url = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:stPhoneNumber]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Send mail

-(IBAction)emailUs:(id)sender {
    [self sendMailTo:@"info@styletribute.com" subject:@"Hello!" body:@"Hello!"];
}

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
    @try {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://app"]]) {
            /*
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
            }];*/
             //NSString *escapedString = [stMessage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send"]];//?text=%@&abid=%d", escapedString, contactId]];
            [[UIApplication sharedApplication] openURL: whatsappURL];
        } else {
            //NSLog(@"whatsapp not installed");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Whatsapp not installed. Please install Whatsapp" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } @catch (NSException *exception) {
        NSLog(@"whatsapp sharing exception");
    } @finally {
        NSLog(@"whatsapp sharing problem");
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
    if(_placemark) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f", _placemark.location.coordinate.latitude, _placemark.location.coordinate.longitude]];
        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            CLLocationCoordinate2D rdOfficeLocation = _placemark.location.coordinate; //DEL CLLocationCoordinate2DMake(stLat, stLon);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:rdOfficeLocation addressDictionary:nil];
            MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
            item.name = @"StyleTribute";
            [item openInMapsWithLaunchOptions:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)addPinToMap {
    NSString *location = @"102F Pasir Panjang Rd, Singapore 118530";
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         _placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_placemark.coordinate, 5000, 5000);
                         
                         [self.mapView setRegion:region animated:YES];
                         [self.mapView addAnnotation:_placemark];
                     }
                 }
     ];
}

@end
