//
//  BaseInputController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"

@interface BaseInputController()

@property CGFloat bottomInset;

@end

@implementation BaseInputController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.widthConstraint.constant = [[UIScreen mainScreen] bounds].size.width;
}

#pragma mark - Keyboard handling

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, kbSize.height + 40, self.scrollView.contentInset.right);
//    NSLog(@"content inset 1 - %f", contentInsets.bottom);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
//    NSLog(@"content inset 2 - %f", self.scrollView.contentInset.bottom);
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
    
//    UIEdgeInsets ins = self.scrollView.contentInset;
//    NSLog(@"scroll view: %f, %f, %f, %f", ins.top, ins.left, ins.bottom, ins.right);
//    NSLog(@"content size: %f, %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.bottomInset, self.scrollView.contentInset.right);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)dismissKeyboard {
    [self.activeField resignFirstResponder];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeField = textView;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    self.activeField = nil;
}

#pragma mark - Positioning

- (void)centerContent
{
    CGFloat top = 0, left = 0, scrollTop = 0, scrollLeft = 0;
    CGFloat scrollHeight = self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    
    if (self.contentView.frame.size.height < scrollHeight) {
        top = (scrollHeight - self.contentView.frame.size.height) * 0.5f;
    } else {
        scrollTop = (self.contentView.frame.size.height - scrollHeight) * 0.5f;
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left);
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollTop, scrollLeft, scrollTop, scrollLeft);
    self.bottomInset = top;
}

-(void)moveContentToTop {
    NSLog(@"scrollbar height: %f", self.view.bounds.size.height);

    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.bottomInset = 0;
}

#pragma mark - Utils

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

-(void)alertWithTitle:(NSString*)title andMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title  message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

@end
