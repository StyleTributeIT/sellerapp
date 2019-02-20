//
//  ShopViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/1/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ShopViewController.h"

@interface ShopViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSString *shop_url;

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shop_url = @"https://styletribute.com/app.html";
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    self.navigationController.navigationBarHidden = true;
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"frontend" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"gpr291avhnpjhk4vhra4jaei67" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@".styletribute.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"temptest.styletribute.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    // set expiration to one month from now or any NSDate of your choosing
    // this makes the cookie sessionless and it will persist across web sessions and app launches
    /// if you want the cookie to be destroyed when your app exits, don't set this
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.shop_url]];
    self.webView.delegate = self;
    [request setValue:@"st-mobile-app" forHTTPHeaderField:@"1.0.1"];
    [self.webView loadRequest:request];
}
//
//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    
//    NSString *string = [[request URL] absoluteString];
//    if ([string isEqualToString:self.shop_url])
//        return YES;
//    
//    UIAlertController *alertController = [UIAlertController
//                                          alertControllerWithTitle:@""
//                                          message:@"Open this in mobile browser?"
//                                          preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction
//                                   actionWithTitle:@"Cancel"
//                                   style:UIAlertActionStyleCancel
//                                   handler:^(UIAlertAction *action)
//                                   {
//                                       NSLog(@"Cancel action");
//                                       //return NO;
//                                   }];
//    
//    UIAlertAction *okAction = [UIAlertAction
//                               actionWithTitle:@"OK"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action)
//                               {
//                                   NSLog(@"OK action");
//                                   //if (navigationType == UIWebViewNavigationTypeLinkClicked) {
//                                        [[UIApplication sharedApplication] openURL:[request URL]];
//
//                                   //}
//                                   //return YES;
//                               }];
//    
//    [alertController addAction:cancelAction];
//    [alertController addAction:okAction];
//    [self presentViewController:alertController animated:YES completion:nil];
//    
//    return NO;
//}

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

@end
