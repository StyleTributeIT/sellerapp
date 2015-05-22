//
//  SlideShowDataSource.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 21/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "SlideShowDataSource.h"

@interface SlideShowDataSource ()

@property NSUInteger curIndex;
@property NSArray* images;

@end

@implementation SlideShowDataSource

-(SlideShowDataSource*)init {
    self = [super init];
    if(self) {
        self.curIndex = 0;
        self.images = @[[UIImage imageNamed:@"1.jpg"],
                        [UIImage imageNamed:@"2.jpg"],
                        [UIImage imageNamed:@"3.jpg"],
                        [UIImage imageNamed:@"4.jpg"],
                        [UIImage imageNamed:@"5.jpg"],
                        [UIImage imageNamed:@"6.jpg"],
                        [UIImage imageNamed:@"7.jpg"],
                        [UIImage imageNamed:@"8.jpg"]];
    }
    
    return self;
}

+(SlideShowDataSource*)sharedInstance {
    static dispatch_once_t once;
    static SlideShowDataSource *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[SlideShowDataSource alloc] init]; });
    return sharedInstance;
}

-(UIImage*)slideShow:(KASlideShow*)slideShow imageForPosition:(KASlideShowPosition)position {    
    switch (position) {
        case KASlideShowPositionTop: {
            NSUInteger current = self.curIndex;
            if(self.curIndex == (self.images.count - 1)) {
                self.curIndex = 0;
            } else {
                self.curIndex++;
            }
            return [self.images objectAtIndex:current];
            break;
        }
            
        case KASlideShowPositionBottom: {
            return [self.images objectAtIndex:self.curIndex];
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

@end
