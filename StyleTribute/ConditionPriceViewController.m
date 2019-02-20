//
//  ConditionPriceViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/9/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ConditionPriceViewController.h"
#import "PriceConditionTableViewCell.h"
#import "ConditionTableViewController.h"
#import "NewItemTableViewController.h"
#import "ProductNavigationViewController.h"
#import "DataCache.h"
#import "Product.h"

@interface ConditionPriceViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBtn;

@end

@implementation ConditionPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
   /* if (self.isEditing)
    {
        
    }*/
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
    [aButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = backButton;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated
{
    Product *product = [DataCache getSelectedItem];
    ;
}

-(void)viewWillAppear:(BOOL)animated
{
   // if (![DataCache sharedInstance].isEditingItem)
  //      [DataCache sharedInstance].isEditingItem = YES;
    [self.tableView reloadData];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender {
    NSArray *vc = self.navigationController.viewControllers;
    UINavigationController * navController;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        if ([controller isKindOfClass:[ProductNavigationViewController class]])
        {
            navController = (ProductNavigationViewController*)controller;
        } else
        if ([controller isKindOfClass:[NewItemTableViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
         //   [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
    }
    [self.navigationController.navigationController popToRootViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // if ([DataCache sharedInstance].isEditingItem)
  //  {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"segueEditCondition" sender:nil];
        }
        if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"segueEditPrice" sender:nil];
        }
  //  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PriceConditionTableViewCell *cell = (PriceConditionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Product *product = [DataCache getSelectedItem];
    if (indexPath.row == 0)
    {
        cell.title.text = @"Set condition";
        cell.subtitle.text = product.condition.name;
        if (product.condition != nil)
            [cell.statusImage setImage:[UIImage imageNamed:@"checked"]];
    } else {
        cell.title.text = @"Set price";
        cell.subtitle.text = [NSString stringWithFormat:@"S$%.2f",product.price];
        if (product.price != 0.0f)
            [cell.statusImage setImage:[UIImage imageNamed:@"checked"]];
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueEditCondition"])
    {
        ((ConditionTableViewController*)segue.destinationViewController).isEditingItem = self.isEditing;
        [((ConditionTableViewController*)segue.destinationViewController) setEditingCondition];
    }
}


@end
