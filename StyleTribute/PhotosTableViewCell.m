//
//  PhotosTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "PhotosTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ApiRequester.h"
#import "PhotoCell.h"
#import "Photo.h"

@implementation PhotosTableViewCell
    
#define PHOTOS_PER_ROW 3.5f
    
- (void)awakeFromNib {
    [super awakeFromNib];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.accessibilityIdentifier = @"Photos collection";
    self.collectionView.accessibilityLabel = @"Photos collection";
}
    
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
    
    -(void)setup:(Product*)product
    {
        self.curProduct = product;
        [self.collectionView reloadData];
    }
    
#pragma mark - Photo collection
    
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}
    
-(NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.curProduct.photos.count + 1;
}
    
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSString* reuseId = [NSString stringWithFormat:@"reuse%zd", indexPath.row];
    __block PhotoCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    //    PhotoCell* newCell = [PhotoCell new];
    
    // Handle "plus" item
    NSLog(@"index: %zd || %zd", indexPath.row, self.curProduct.photos.count);
    if(indexPath.row == self.curProduct.photos.count) {
        newCell.photoView.image = [UIImage imageNamed:@"plus"];
        [newCell.photoTypeLabel setHidden:YES];
    } else {
        ImageType* imgType = nil;
        if(indexPath.row >= self.curProduct.category.imageTypes.count) {
            imgType = [ImageType new];
            imgType.name = [NSString stringWithFormat:@"%zd", indexPath.row - self.curProduct.category.imageTypes.count + 1];
        } else {
            imgType = [self.curProduct.category.imageTypes objectAtIndex:indexPath.row];
        }
        
        newCell.photoTypeLabel.text = imgType.name;
        [newCell.photoTypeLabel setHidden:NO];
        
        if(self.curProduct.photos != nil && self.curProduct.photos.count >= (indexPath.row + 1)) {
            Photo* photo = [self.curProduct.photos objectAtIndex:indexPath.row];
            if(photo != nil && [photo isKindOfClass:[Photo class]]) {
                if(photo.image != nil) {
                    newCell.photoView.image = photo.image;
                } else {
                    [newCell.photoView sd_setImageWithURL:[NSURL URLWithString:photo.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"stub"]];
                }
            } else {
                [newCell.photoView sd_setImageWithURL:[NSURL URLWithString:imgType.preview] placeholderImage:[UIImage imageNamed:@"stub"]];
            }
        } else {
            [newCell.photoView sd_setImageWithURL:[NSURL URLWithString:imgType.preview] placeholderImage:[UIImage imageNamed:@"stub"]];
        }
    }
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [newCell.photoView addGestureRecognizer:tapRecognizer];
    
    newCell.photoView.tag = indexPath.row;
    newCell.accessibilityLabel = [NSString stringWithFormat:@"Photo cell %td", indexPath.row];
    return newCell;
}
    
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = collectionView.frame.size.width/PHOTOS_PER_ROW;
    return CGSizeMake(itemSize, itemSize);
}
    
    
    @end
