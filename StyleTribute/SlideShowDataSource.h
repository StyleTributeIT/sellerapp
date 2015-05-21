//
//  SlideShowDataSource.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 21/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KASlideShow.h>

@interface SlideShowDataSource : NSObject<KASlideShowDataSource>

+(SlideShowDataSource*)sharedInstance;
-(UIImage*)slideShow:(KASlideShow*)slideShow imageForPosition:(KASlideShowPosition)position;

@end
