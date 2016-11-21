//
//  PhotosTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@protocol PhotoCellDelegate

-(void)selectedImageIndex:(NSUInteger)selectedImageIndex;

@end

@interface PhotosTableViewCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>
    @property (strong, nonatomic) IBOutlet UILabel *guideLabel;
    @property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *titleBorder;
@property (strong, nonatomic) id<PhotoCellDelegate> delegate;
    @property Product* curProduct;
    
    -(void)setup:(Product*)product;
@end
