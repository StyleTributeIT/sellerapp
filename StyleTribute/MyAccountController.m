//
//  MyAccountController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "MyAccountController.h"

@interface MyAccountController ()

@property NSArray* accountSettings;

@end

@implementation MyAccountController

#pragma mark - Init

-(void)viewDidLoad {
    [super viewDidLoad];
    self.accountSettings = @[@"Edit profile", @"Resident address", @"Change/update password", @"My bank details", @"Contact & find us"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accountSettings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.tag = indexPath.row;
    cell.textLabel.text = [self.accountSettings objectAtIndex:indexPath.row];
    
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
            [self performSegueWithIdentifier:@"changePasswordSegue" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"bankDetailsSegue" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"contactUsSegue" sender:self];
            break;
            
        default:
            break;
    }
}

#pragma mark - Unwind handlers

-(IBAction)unwindToMyAccount:(UIStoryboardSegue*)sender {
}

@end
