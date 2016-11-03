//
//  ChooseBrandController.m
//  StyleTribute
//
//  Created by selim mustafaev on 11/09/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ChooseBrandController.h"
#import "DataCache.h"
#import "NamedItems.h"
#import "AddBrandTableViewCell.h"
#import <NSArray+LinqExtensions.h>
#import "GlobalHelper.h"

@interface ChooseBrandController ()

@property NSArray* designers;
@property NSArray* sectionNames;
@property NSArray* sections;
@property NSString* searchingString;
@end

@implementation ChooseBrandController

-(void)viewDidLoad {
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    self.designers = [DataCache sharedInstance].designers;
    [self registerCells];
    [self updateSections];
}

- (void) registerCells{
    UINib *nib = [UINib nibWithNibName:@"AddBrandTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"AddCell"];
}

-(void)updateSections {
    self.sectionNames = [[self.designers linq_select:^id(NamedItem* designer) {
        return [designer.name substringToIndex:1];
    }] linq_distinct];
    
    self.sections = [self.sectionNames linq_select:^id(NSString* sectionName) {
        return [self.designers linq_where:^BOOL(NamedItem* designer) {
            return ([designer.name rangeOfString:sectionName].location == 0);
        }];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sectionNames.count == 0)
        return 1;
    return self.sectionNames.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sectionNames.count == 0)
        return @"";
    return [self.sectionNames objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sectionNames.count == 0)
        return 1;
    NSArray* curSection = [self.sections objectAtIndex:section];
    return curSection.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    if (self.sectionNames.count == 0)
    {
        /*AddBrandTableViewCell *cell = (AddBrandTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"AddCell"];
        if (cell == nil)
        cell= [[AddBrandTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"AddCell"];
        cell.titleLabel.text = @"+ Add Brand";
         */
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddCell"];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"+ Add %@?", self.searchingString];
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell setBackgroundColor:[UIColor redColor]];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray* curSection = [self.sections objectAtIndex:indexPath.section];
    NamedItem* designer = [curSection objectAtIndex:indexPath.row];
    cell.textLabel.text = designer.name;
    return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionNames;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.sectionNames indexOfObject:title];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionNames.count == 0)
    {
        return;
    }
    NSArray* curSection = [self.sections objectAtIndex:indexPath.section];
    NamedItem* designer = [curSection objectAtIndex:indexPath.row];
    self.product.designer = designer;
    [self performSegueWithIdentifier:@"unwindToAddItem" sender:self];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchingString = searchString;
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchString];
    self.designers = [[DataCache sharedInstance].designers filteredArrayUsingPredicate:resultPredicate];
    [self updateSections];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.designers = [DataCache sharedInstance].designers;
    [self updateSections];
}

@end
