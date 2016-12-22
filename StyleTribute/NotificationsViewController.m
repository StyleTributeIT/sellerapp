//
//  NotificationsViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/1/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationTableViewCell.h"
#import "ProductNavigationViewController.h"
#import "Photo.h"

@interface NotificationsViewController ()
@property NSMutableArray *prods;
@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    self.prods = [defs objectForKey:@"notifications"];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([DataCache sharedInstance].products != nil) {
        Product* product = [[[DataCache sharedInstance].products linq_where:^BOOL(Product* p) {
            return (p.identifier == [[[self.prods objectAtIndex:indexPath.row] objectForKey:@"pid"] integerValue]);
        }] firstObject];
        if(product != nil) {
            
            UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddItemNavController"];
            for(UIViewController * viewController in navController.viewControllers){
                if ([viewController isKindOfClass:[ProductNavigationViewController class]]){
                    ProductNavigationViewController *vc = (ProductNavigationViewController * ) viewController;
                    vc.curProduct = product;
                    [DataCache setSelectedItem:product];
                    [DataCache sharedInstance].isEditingItem = YES;
                }
            }
            [self presentViewController:navController animated:YES completion:nil] ;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.prods?self.prods.count:0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    if([DataCache sharedInstance].products != nil) {
        Product* product = [[[DataCache sharedInstance].products linq_where:^BOOL(Product* p) {
            return (p.identifier == [[[self.prods objectAtIndex:indexPath.row] objectForKey:@"pid"] integerValue]);
        }] firstObject];
        cell.title.text = product.name;
        cell.message.text = [[self.prods objectAtIndex:indexPath.row] objectForKey:@"alert"];
        if(product != nil) {
            Photo* photo = [product.photos firstObject];
            [cell.photoView sd_setImageWithURL:[NSURL URLWithString:photo.imageUrl] placeholderImage:[UIImage imageNamed:@"stub"]];
        }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
