//
//  AppDelegate.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TestFairy.h>
#import "DataCache.h"
#import "CustomTextField.h"
#import "UIFloatLabelTextField.h"
#import "Product.h"
#import "Photo.h"
#import <Parse/Parse.h>
#import "WelcomeController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@property BOOL isInBackground;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[[Crashlytics class]]];

    // Override point for customization after application launch.
    
    [TestFairy begin:@"8aecdb789c2b51a840eafed3b8acc3d0aa49373c"];
    UIColor* pink = [UIColor colorWithRed:218/256.0 green:0 blue:100.0/255 alpha:1];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Montserrat-Regular" size:11.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBar appearance] setSelectedImageTintColor:pink];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];
    [[CustomTextField appearance] setBackground:[[UIImage imageNamed:@"Edit"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];
    [[CustomTextField appearance] setBorderStyle:UITextBorderStyleNone];
    [[CustomTextField appearance] setFont:[UIFont fontWithName:@"Montserrat-UltraLight" size:14]];
    [[CustomTextField appearance] setTextAlignment:NSTextAlignmentCenter];
    
    [[UIFloatLabelTextField appearance] setBackground:[[UIImage imageNamed:@"Edit"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];
    [[UIFloatLabelTextField appearance] setBorderStyle:UITextBorderStyleNone];
    [[UIFloatLabelTextField appearance] setFont:[UIFont fontWithName:@"Montserrat-UltraLight" size:14]];
    [[UIFloatLabelTextField appearance] setTextAlignment:NSTextAlignmentCenter];
    [[UIFloatLabelTextField appearance] setFloatLabelActiveColor:pink];
    [[UIFloatLabelTextField appearance] setFloatLabelFont:[UIFont fontWithName:@"Montserrat-Light" size:10]];
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                             | UIUserNotificationTypeBadge
                                                                                             | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    self.isInBackground = NO;
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotif) {
        NSDictionary* aps = [remoteNotif objectForKey:@"aps"];
        NSUInteger productId = (NSUInteger)[[aps objectForKey:@"pid"] intValue];
        [DataCache sharedInstance].openProductOnstart = productId;
    }
	
	[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    self.isInBackground = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    UINavigationController* nav = (UINavigationController*)self.window.rootViewController;
    WelcomeController* wc = (WelcomeController*)[nav topViewController];
    
    if([wc isKindOfClass:[WelcomeController class]]) {
        [wc showVertionAlert];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    self.isInBackground = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Push notifications



-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken  {
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [DataCache sharedInstance].deviceToken = newToken;
    
    NSLog(@"My token is: %@", newToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get device token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    NSString* alert = [aps objectForKey:@"alert"];
    NSUInteger productId = (NSUInteger)[[aps objectForKey:@"pid"] intValue];
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prods = [NSMutableArray arrayWithArray:[defs objectForKey:@"notifications"]];
    if (!prods)
        prods = [NSMutableArray new];
    [prods addObject:@{@"alert":alert,@"pid":[aps objectForKey:@"pid"]}];
    [defs setObject:prods forKey:@"notifications"];
    [defs synchronize];
    // get product name from id
    if([DataCache sharedInstance].products != nil) {
        Product* product = [[[DataCache sharedInstance].products linq_where:^BOOL(Product* p) {
            return (p.identifier == productId);
        }] firstObject];
        
        if(product != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [GlobalHelper showMessage:alert withTitle:product.name];
                Photo* photo = [product.photos firstObject];
                [GlobalHelper showToastNotificationWithTitle:product.name subtitle:alert imageUrl:(photo ? photo.imageUrl : nil)];
            });
        }
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

@end
