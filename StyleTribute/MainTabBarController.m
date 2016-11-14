//
//  MainTabBarController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 20/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "MainTabBarController.h"
#import <CoreGraphics/CoreGraphics.h>

@interface MainTabBarController () <UITabBarControllerDelegate>

@property NSUInteger previousTabIndex;
@property (strong, nonatomic) UIButton *myWardrobeButton;
@property (strong, nonatomic) UIButton *shopButton;
@property (strong, nonatomic) UIButton *addItemButton;
@property (strong, nonatomic) UIButton *myAccountButton;
@property (strong, nonatomic) UIButton *notificationsButton;
@end

@implementation MainTabBarController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self=  [super initWithCoder:aDecoder];
    
    if(self) {
        self.previousTabIndex = 0;
        self.delegate = self;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        
        //Widht of button
        CGFloat itemWidth = screenSize.width/5;
        
        UIImage * backgroundImage = [self resizeBackgroundImage:[UIImage imageNamed:@"TabBar"]];
        
        //Container to hold the all the button and background image for custom tabbar
        UIView * tabbarContainer = [[UIView alloc]initWithFrame:CGRectMake(0, screenSize.height - backgroundImage.size.height  , backgroundImage.size.width , backgroundImage.size.height)];

        //Background imageview add to the contrainer
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:tabbarContainer.bounds];
        bgImageView.contentMode = UIViewContentModeBottom;
        bgImageView.image = backgroundImage;
      //  [self.tabBar setBackgroundImage:backgroundImage];
        [tabbarContainer addSubview:bgImageView];
       // return self;
        //My wardrobe Tab button created
        self.myWardrobeButton = [self getTabbarButtonforFrame:CGRectMake(0, backgroundImage.size.height - (backgroundImage.size.height * 0.5882352941), itemWidth, backgroundImage.size.height * 0.5882352941) icon:[[UIImage imageNamed:@"wardrobe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"Wardrobe" andTopOffset:0];
        [self.myWardrobeButton addTarget:self action:@selector(myWardrobeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        //Shop button
        self.shopButton = [self getTabbarButtonforFrame:CGRectMake(itemWidth, backgroundImage.size.height - (backgroundImage.size.height * 0.5882352941), itemWidth, backgroundImage.size.height * 0.5882352941) icon:[[UIImage imageNamed:@"shop"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"Shop" andTopOffset:0];
        [self.myWardrobeButton addTarget:self action:@selector(shopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        //Add Item Tab Button created
        self.addItemButton = [self getTabbarButtonforFrame:CGRectMake(itemWidth * 2,backgroundImage.size.height - (backgroundImage.size.height * 0.8333333333) , itemWidth, backgroundImage.size.height) icon:[[UIImage imageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"Sell" andTopOffset: -16];
        [self.addItemButton addTarget:self action:@selector(addItemButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        //My Account Butoon Created
        self.myAccountButton = [self getTabbarButtonforFrame:CGRectMake(itemWidth * 3, backgroundImage.size.height - (backgroundImage.size.height * 0.5882352941), itemWidth, backgroundImage.size.height * 0.5882352941) icon:[[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"Profile" andTopOffset:0];
        [self.myAccountButton addTarget:self action:@selector(myAccountButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.notificationsButton = [self getTabbarButtonforFrame:CGRectMake(itemWidth * 4, backgroundImage.size.height - (backgroundImage.size.height * 0.5882352941), itemWidth, backgroundImage.size.height * 0.5882352941) icon:[[UIImage imageNamed:@"notifications"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] title:@"Notification" andTopOffset:0];
        [self.myAccountButton addTarget:self action:@selector(notificationsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        //Added all the button to container
        [tabbarContainer addSubview:self.myWardrobeButton];
        [tabbarContainer addSubview:self.shopButton];
        [tabbarContainer addSubview:self.addItemButton];
        [tabbarContainer addSubview:self.myAccountButton];
        [tabbarContainer addSubview:self.notificationsButton];
        
        //Added container to the view
        [self.view addSubview:tabbarContainer];
        
        //by default My Wardrobe button is selected
        [self myWardrobeButtonPressed];
    
    }
    
    return self;
}

//- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
//    NSLog(@"QWE!!!!!!!!!!!!");
//}

-(void)selectPreviousTab {
    [self setSelectedIndex:self.previousTabIndex];
}



-(void)setSelectedIndex:(NSUInteger)selectedIndex {
    self.previousTabIndex = self.selectedIndex;
    [super setSelectedIndex:selectedIndex];
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    self.previousTabIndex = self.selectedIndex;
    return YES;
}

-(UIImage*)resizeBackgroundImage:(UIImage*)image {
    CGSize xsize = CGSizeMake(self.view.frame.size.width, image.size.height);
    CGFloat edgeWidth = round((xsize.width - image.size.width)/2);
    
    CGImageRef edgeImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, edgeWidth*2, image.size.height*2));
    
    UIGraphicsBeginImageContext(xsize);
    UIImage* img = [UIImage imageWithCGImage:edgeImage];
    [image drawInRect:CGRectMake(edgeWidth, 0, image.size.width, image.size.height)];
    [img drawInRect:CGRectMake(0, 0, edgeWidth, image.size.height)];
    [img drawInRect:CGRectMake(image.size.width + edgeWidth, 0, edgeWidth, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(edgeImage);
    
    return newImage;
}


//Gives the custom designed button for custom tabbar
- (UIButton *) getTabbarButtonforFrame:(CGRect) frame icon:(UIImage *) icon title:(NSString *) title andTopOffset:(CGFloat) topOffset{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateNormal];
    
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                                0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                                - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    [button setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    // increase the content height to avoid clipping
    CGFloat edgeOffset = fabsf(titleSize.height - imageSize.height) / 2.0;
    button.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset + topOffset, 0.0, edgeOffset, 0.0);
    
    return button;
}

-(void) shopButtonPressed
{
    
}

- (void) notificationsButtonPressed
{
    
}

- (void) myWardrobeButtonPressed{
    [self setSelectedIndex:0];
    [self.myWardrobeButton setImage:[UIImage imageNamed:@"wardrobe-pink"] forState: UIControlStateNormal];
    [self.myAccountButton setImage:[UIImage imageNamed:@"profile"] forState: UIControlStateNormal];
    [self.myWardrobeButton setTitleColor: [UIColor colorWithRed:1.0 green:0.0 blue:102.0/256 alpha:1]forState:UIControlStateNormal];
    [self.myAccountButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
}

- (void) addItemButtonPressed{
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemNavController"] animated:YES completion:nil] ;
    [self.myWardrobeButton setImage:[UIImage imageNamed:@"wardrobe"] forState: UIControlStateNormal];
    [self.myAccountButton setImage:[UIImage imageNamed:@"account"] forState: UIControlStateNormal];
    [self.myWardrobeButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [self.myWardrobeButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
}

- (void) myAccountButtonPressed{
    [self setSelectedIndex:2];
    [self.myWardrobeButton setImage:[UIImage imageNamed:@"wardrobe"] forState: UIControlStateNormal];
    [self.myAccountButton setImage:[UIImage imageNamed:@"profile-pink"] forState: UIControlStateNormal];
    [self.myAccountButton setTitleColor: [UIColor colorWithRed:1.0 green:0.0 blue:102.0/256 alpha:1]forState:UIControlStateNormal];
    [self.myWardrobeButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
}


-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
    UIViewController* viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
