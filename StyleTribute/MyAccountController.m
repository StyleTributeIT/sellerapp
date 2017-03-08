//
//  MyAccountController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "MyAccountController.h"
#import "MyAccountCell.h"
#import <ZDCChat/ZDCChat.h>

@interface MyAccountController ()

@property NSArray* accountSettings;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation MyAccountController

#pragma mark - Init

-(void)viewDidLoad {
    [super viewDidLoad];
    self.accountSettings = @[@"EDIT PROFILE", @"RESIDENT ADDRESS", /* @"CHANGE MY PASSWORD", */ @"MY BANK DETAILS", @"CONTACT & FIND US"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    self.versionLabel.text = versionBuildString;
    
    UIColor* pink = [UIColor colorWithRed:1 green:0 blue:102.0/255 alpha:1];
    UIBarButtonItem *supportBtn =[[UIBarButtonItem alloc]initWithTitle:@"Support" style:UIBarButtonItemStyleDone target:self action:@selector(popToSupport)];
    supportBtn.title = @"Support";
    [supportBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Montserrat-Light" size:14], NSFontAttributeName,
                                        pink, NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = supportBtn;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.widthConstraint.constant = [[UIScreen mainScreen] bounds].size.width;
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    self.userNameLabel.text = [NSString stringWithFormat:@"Hi %@!", [DataCache sharedInstance].userProfile.firstName];
}


- (void) popToSupport{
    [ZDCChat initializeWithAccountKey:@"4dkfRL5ABzKB60Xu4VEW7jV65zynqc3T"];
    
    // start a chat in a new modal
    [ZDCChat startChatIn:self.navigationController withConfig:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.email = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.phone = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.department = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.message = ZDCPreChatDataOptionalEditable;
    }];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accountSettings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.tag = indexPath.row;
    cell.title.text = [self.accountSettings objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"editProfileSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"residentAddressSegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"bankDetailsSegue" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"contactUsSegue" sender:self];
            break;
            
        default:
            break;
    }
}

#pragma mark - Unwind handlers

-(IBAction)unwindToMyAccount:(UIStoryboardSegue*)sender {
}

#pragma mark - Actions

-(IBAction)logout:(id)sender {
    [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    [[ApiRequester sharedInstance] logoutWithSuccess:^() {
        [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        [self performSegueWithIdentifier:@"logoutSegue" sender:self];
    } failure:^(NSString *error) {
        [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        [GlobalHelper showMessage:error withTitle:@"Login error"];
    }];
}

@end
