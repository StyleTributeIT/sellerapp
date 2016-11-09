//
//  PhotoCell.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell

@property IBOutlet UIImageView* photoView;
@property IBOutlet UILabel* photoTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *plusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bigPhotoCell;

@end
