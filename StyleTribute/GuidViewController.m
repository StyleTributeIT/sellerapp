//
//  GuidViewController.m
//  StyleTribute
//
//  Created by Maxim Vasilkov on 17/11/2016.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "GuidViewController.h"
#import "SwipeView.h"

@interface GuidViewController ()<SwipeViewDataSource, SwipeViewDelegate>
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@end

@implementation GuidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    NSLog(@"Loading guid %ld",index);
    //create new view if no view is available for recycling
    if (view == nil) {
        NSString *xibName = [NSString stringWithFormat:@"Guid%ld",index];
        view = [[[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil] objectAtIndex:0];
        view.frame = self.swipeView.bounds;
    }
    return view;
}

@end
