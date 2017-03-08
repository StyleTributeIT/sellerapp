//
//  ShopViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/1/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ShopViewController.h"
#import <ZDCChat/ZDCChat.h>

@interface ShopViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property NSString *shop_url;
@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shop_url = @"https://styletribute.com/app.html";
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    UIColor* pink = [UIColor colorWithRed:1 green:0 blue:102.0/255 alpha:1];
    UIBarButtonItem *supportBtn =[[UIBarButtonItem alloc]initWithTitle:@"Support" style:UIBarButtonItemStyleDone target:self action:@selector(popToSupport)];
    supportBtn.title = @"Support";
    [supportBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Montserrat-Light" size:14], NSFontAttributeName,
                                        pink, NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = supportBtn;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.shop_url]];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

- (void) popToSupport{
    [ZDCChat initializeWithAccountKey:@"4dkfRL5ABzKB60Xu4VEW7jV65zynqc3T"];
    
    // start a chat in a new modal
    [ZDCChat startChatIn:self.navigationController withConfig:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.email = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.phone = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.department = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.message = ZDCPreChatDataOptionalEditable;
    }];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *string = [[request URL] absoluteString];
    if ([string isEqualToString:self.shop_url])
        return YES;
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Open this in mobile browser?"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       //return NO;
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                                   //if (navigationType == UIWebViewNavigationTypeLinkClicked) {
                                        [[UIApplication sharedApplication] openURL:[request URL]];

                                   //}
                                   //return YES;
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    return NO;
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

@end
