//
//  GuidViewController.m
//  StyleTribute
//
//  Created by Maxim Vasilkov on 17/11/2016.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "GuidViewController.h"
#import "GuidelineViewController.h"
#import "SwipeView.h"

@interface GuidViewController ()<UIPageViewControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (strong, nonatomic) IBOutlet UIView *pagesContainer;
@property (strong, nonatomic) IBOutlet UIButton *getStartedBtn;
@property (assign, nonatomic) NSInteger nextIndex;
@property (strong, nonatomic) IBOutlet UIButton *greenBtn;
@end

NSInteger num_screens = 4;
UIPageControl *thisControl = nil;

@implementation GuidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
   // self.swipeView.currentPage = 0;
    [aButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:[[self pagesContainer] bounds]];
    
    GuidelineViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self pagesContainer] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    [UIPageControl appearance].tintColor = [UIColor blackColor];
    for (UIView *v in self.pageController.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)v).delegate = self;
        }
    }
    
    NSArray *subviews = self.pageController.view.subviews;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    if (thisControl)
        thisControl.hidden = YES;

}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.hideSkipButton)
        self.navigationItem.rightBarButtonItem = nil;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)skip:(id)sender {
    
    if (self.delegate)
        [_delegate showCamera];
    [self.navigationController popViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"unwindToCamera" sender:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (IBAction)getStartedClicked:(id)sender {
    
    [self changePage:(UIPageViewControllerNavigationDirectionForward)];
    self.getStartedBtn.hidden = YES;
    thisControl.currentPage = 1;
    if (thisControl)
        thisControl.hidden = NO;
}

- (IBAction)gotItClicked:(id)sender {
    if (!self.hideSkipButton)
    {
        if (self.delegate)
            [_delegate showCamera];
        [self.navigationController popViewControllerAnimated:NO];
     ///   [self performSegueWithIdentifier:@"unwindToCamera" sender:self];
    }
    else
        [self back:nil];
}

- (void)changePage:(UIPageViewControllerNavigationDirection)direction {
    
    NSUInteger pageIndex = ((GuidelineViewController *) [self.pageController.viewControllers objectAtIndex:0]).index;
    
    if (direction == UIPageViewControllerNavigationDirectionForward) {
        pageIndex++;
    }
    else {
        pageIndex--;
    }
    
    GuidelineViewController *viewController = [self viewControllerAtIndex:pageIndex];
    
    if (viewController == nil) {
        return;
    }
    
    [self.pageController setViewControllers:@[viewController]
                                  direction:direction
                                   animated:YES
                                 completion:nil];
}

#pragma mark PageController data source

- (GuidelineViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    GuidelineViewController *childViewController = [[GuidelineViewController alloc] initWithNibName:@"GuidelineViewController" bundle:nil];
    childViewController.index = index;
    if (index == num_screens - 1)
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTutorial)];
        
        [childViewController.view addGestureRecognizer:tapGesture];
    }
    
    return childViewController;
}

-(void)closeTutorial
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{

}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed)
    {
        return;
    }
    NSUInteger currentIndex = [[self.pageController.viewControllers lastObject] index];
    if (currentIndex == 0) {
        self.getStartedBtn.hidden = NO;
    } else {
        self.getStartedBtn.hidden = YES;
    }
    /*if (currentIndex == 2)
    {
        self.greenBtn.hidden = NO;
    } else {
        self.greenBtn.hidden = YES;
    }*/
    if (currentIndex == num_screens - 1)
    {
        self.greenBtn.hidden = NO;
    } else {
        self.greenBtn.hidden = YES;
    }
    if (currentIndex == 0)
    {
        if (thisControl)
            thisControl.hidden = YES;
    } else {
        if (thisControl)
            thisControl.hidden = NO;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(GuidelineViewController *)viewController index];
    
    if (index == 0) {
        
        return nil;
    }
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(GuidelineViewController *)viewController index];
    
    index++;
    
    if (index == num_screens) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return num_screens;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
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
    return num_screens;
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
