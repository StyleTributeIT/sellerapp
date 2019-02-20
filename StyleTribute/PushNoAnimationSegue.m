//
//  PushNoAnimationSegue.m
//  StyleTribute
//
//  Created by selim mustafaev on 09/09/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "PushNoAnimationSegue.h"

@implementation PushNoAnimationSegue

-(void) perform{
    [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
