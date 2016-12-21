//
//  TopCategoriesViewController.h
//  StyleTribute
//
//  Created by Mcuser on 11/3/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"
#import "Product.h"

@interface TopCategoriesViewController : UIViewController
@property STCategory* selectedCategory;
@property NSString* brandField;
@property (weak) Product* product;

-(void)loadWithChildrens:(NSArray*)childrens andPrevCategorie:(STCategory*)categorie;

@end
