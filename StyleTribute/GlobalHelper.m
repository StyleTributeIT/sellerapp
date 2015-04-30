//
//  GlobalHelper.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"

@implementation GlobalHelper

+(void)addLogoToNavBar:(UINavigationItem*)item {
    UIImageView *titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    titleImg.image = [UIImage imageNamed:@"LogoHeader"];
    item.titleView = titleImg;
}

@end
