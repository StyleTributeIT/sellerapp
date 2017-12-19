//
//  ChooseBrandController.m
//  StyleTribute
//
//  Created by selim mustafaev on 11/09/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ChooseBrandController.h"
#import "NamedItems.h"
#import "AddBrandTableViewCell.h"


@interface ChooseBrandController ()

@property NSArray* designers;
@property NSArray* sectionNames;
@property NSArray* sections;
@property NSString* searchingString;
@end

@implementation ChooseBrandController

-(void)viewDidLoad {
//<<<<<<< HEAD
   // [GlobalHelper addLogoToNavBar:self.navigationItem];
    //self.navigationItem.title = self.title;
//=======
  //  [GlobalHelper addLogoToNavBar:self.navigationItem];
  //  self.navigationItem.title = @"Brand";
///>>>>>>> 9685cf5817e3affcfd051352f63acdb4b6e85ccc
    self.designers = [DataCache sharedInstance].designers;
    [self registerCells];
    [self updateSections];
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
    [aButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.product = [DataCache getSelectedItem];
}

- (void) registerCells{
    UINib *nib = [UINib nibWithNibName:@"AddBrandTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"AddCell"];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15];
        [cell setBackgroundColor:[UIColor colorWithRed:255/255.f green:0 blue:102/255.f alpha:1.0f]];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray* curSection = [self.sections objectAtIndex:indexPath.section];
    if (curSection)
    {
        if (curSection.count > indexPath.row)
        {
            NamedItem* designer = [curSection objectAtIndex:indexPath.row];
            if (designer.name)
            {
                cell.textLabel.text = designer.name;
            }
        }
    }
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
        NamedItem *item = [NamedItem new];
        item.name = self.searchingString;
        self.product.other_designer = item;
        [self performSegueWithIdentifier:@"showItemEdited" sender:self];
        return;
    }
    NSArray* curSection = [self.sections objectAtIndex:indexPath.section];
    NamedItem* designer = [curSection objectAtIndex:indexPath.row];
    self.product.designer = designer;
    [DataCache setSelectedItem:self.product];
    [self performSegueWithIdentifier:@"showItemEdited" sender:self];
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
