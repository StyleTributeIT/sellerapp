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
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    self.prods = [NSMutableArray arrayWithArray:[defs objectForKey:@"notifications"]];
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
    NSMutableDictionary *d = [[self.prods objectAtIndex:indexPath.row] mutableCopy];
    [d setValue:@1 forKey:@"seen"];
    [self.prods replaceObjectAtIndex:indexPath.row withObject:d];
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:self.prods forKey:@"notifications"];
    [defs synchronize];
    
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
    [self.tableView reloadData];
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
        if ([[self.prods objectAtIndex:indexPath.row] valueForKey:@"date"] != nil)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            NSDate *notificationDate = [[NSDate alloc] init];
            notificationDate = [dateFormatter dateFromString:[[self.prods objectAtIndex:indexPath.row] valueForKey:@"date"]];
            NSDate *currentDate = [NSDate date];
            cell.dateLabel.hidden = NO;
            cell.dateLabel.text = [self remaningTime:notificationDate endDate:currentDate];
            
        } else
        {
            cell.dateLabel.hidden = YES;
        }
        if ([[self.prods objectAtIndex:indexPath.row] valueForKey:@"seen"] != nil)
        {
            BOOL seen = [[[self.prods objectAtIndex:indexPath.row] valueForKey:@"seen"] boolValue];
            if (!seen)
                [cell setBackgroundColor:[UIColor colorWithRed:246/255.f green:244/255.f blue:244/255.f alpha:1.f]];
            else
                [cell setBackgroundColor:[UIColor whiteColor]];
        }
        cell.title.text = product.name;
        cell.message.text = [[self.prods objectAtIndex:indexPath.row] objectForKey:@"alert"];
        if(product != nil) {
            Photo* photo = [product.photos firstObject];
            [cell.photoView sd_setImageWithURL:[NSURL URLWithString:photo.imageUrl] placeholderImage:[UIImage imageNamed:@"stub"]];
        }
    }
    return cell;
}

-(NSString*)remaningTime:(NSDate*)startDate endDate:(NSDate*)endDate
{
    NSDateComponents *components;
    NSInteger days;
    NSInteger hour;
    NSInteger minutes;
    NSString *durationString;
    
    components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate: startDate toDate: endDate options: 0];
    
    days = [components day];
    hour = [components hour];
    minutes = [components minute];
    
    if(days>0)
    {
        if(days>1)
        {
            if (days < 3)
                durationString=[NSString stringWithFormat:@"%ld days ago",(long)days];
            else
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat: @"dd MMMM yyyy"];
                durationString = [formatter stringFromDate:startDate];
            }
        }
        else
            durationString=[NSString stringWithFormat:@"%ld day ago",(long)days];
        return durationString;
    }
    if(hour>0 && hour < 24)
    {
        if(hour>1)
            durationString=[NSString stringWithFormat:@"%ld hours ago",(long)hour];
        else
            durationString=[NSString stringWithFormat:@"%ld hour ago",(long)hour];
        return durationString;
    }
    if(minutes>0)
    {
        if(minutes>1)
            durationString = [NSString stringWithFormat:@"%ld minutes ago",(long)minutes];
        else
            durationString = @"Just Now";//[NSString stringWithFormat:@"%ld minute ago",(long)minutes];
        
        return durationString;
    }
    return @""; 
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
