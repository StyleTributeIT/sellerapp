//
//  UITextViewWorkaround.m
//  StyleTribute
//
//  Created by Alankar Muley on 12/11/19.
//  Copyright © 2019 StyleTribute. All rights reserved.
//

#import "UITextViewWorkaround.h"
#import  <objc/runtime.h>

//******************************************************************
// MARK: - Workaround for the Xcode 11.2 bug
//******************************************************************

@implementation UITextViewWorkaround
+ (void)executeWorkaround {
    if (@available(iOS 13.2, *)) {
    }
    else {
        const char *className = "_UITextLayoutView";
        Class cls = objc_getClass(className);
        if (cls == nil) {
            cls = objc_allocateClassPair([UIView class], className, 0);
            objc_registerClassPair(cls);
#if DEBUG
            printf("added %s dynamically\n", className);
#endif
        }
    }
}
@end
