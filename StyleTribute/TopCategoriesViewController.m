//
//  TopCategoriesViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/3/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "TopCategoriesViewController.h"
#import "CategoryCell.h"
#import "CategoryViewCell.h"
#import "ChooseBrandController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface TopCategoriesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionCategories;
@property NSMutableArray *categories;
@property NSString *selected_title;
@end

@implementation TopCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionCategories.accessibilityIdentifier = @"Choose category table";
    self.collectionCategories.delegate = self;
    self.collectionCategories.dataSource = self;
    if([DataCache sharedInstance].categories == nil)
    {
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getCategories:^(NSArray *categories) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [DataCache sharedInstance].categories = categories;
            _categories = [NSMutableArray arrayWithArray:categories];
            [self.collectionCategories reloadData];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    } else
    {
        if (!self.categories)
            self.categories = [NSMutableArray arrayWithArray:[DataCache sharedInstance].categories];
    }
}

-(void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadWithChildrens:(NSArray*)childrens andPrevCategorie:(STCategory*)categorie
{
    self.navigationItem.title = [categorie.name capitalizedString];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 15, 24);
    [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    backButton.showsTouchWhenHighlighted = YES;
    
    UIImage *backButtonImage = [UIImage imageNamed:@"backBtn"];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    /*NSMutableArray* categories = [NSMutableArray new];
    for (NSDictionary* categoryDict in childrens) {
        [categories addObject:[STCategory parseFromJson:categoryDict]];
    }*/
    self.categories = [NSMutableArray arrayWithArray:childrens];
    [self.collectionCategories reloadData];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)unwindToAddItem:(UIStoryboardSegue*)sender
{
    
    if([sender.sourceViewController isKindOfClass:[ChooseBrandController class]]) {
        ChooseBrandController *ccController = sender.sourceViewController;
        self.brandField = ccController.product.designer.name;
    }
    [self performSegueWithIdentifier:@"unwindToAddItem" sender:self];
}

#pragma mark CollectionView delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width/2, (self.view.frame.size.width/2) + 50);
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionCategories deselectItemAtIndexPath:indexPath animated:NO];
    self.selectedCategory = [self.categories objectAtIndex:indexPath.row];
    Product *product = [DataCache getSelectedItem];
    product.category = self.selectedCategory;
    product.photos = [NSMutableArray arrayWithCapacity:product.category.imageTypes.count];
    for(int i = 0; i < product.category.imageTypes.count; ++i) {
        [product.photos addObject:[NSNull null]];
    }
    [DataCache setSelectedItem:product];
    //TopCategoriesViewController *categoris = [[TopCategoriesViewController alloc] init];
    if (((STCategory*)[self.categories objectAtIndex:indexPath.row]).children.count != 0)
    {
        TopCategoriesViewController *viewController = [[UIStoryboard storyboardWithName:@"ProductFlow" bundle:nil] instantiateViewControllerWithIdentifier:@"categorySelection"];
        [viewController loadWithChildrens:((STCategory*)[self.categories objectAtIndex:indexPath.row]).children andPrevCategorie:self.selectedCategory];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        //ChooseBrandController *vc = [[UIStoryboard storyboardWithName:@"ProductFlow" bundle:nil] instantiateViewControllerWithIdentifier:@"brandSelection"];
        //vc.title = self.selectedCategory.name;
        self.selected_title = self.selectedCategory.name;
        [self performSegueWithIdentifier:@"ChooseBrandSegue2" sender:nil];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categories.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryViewCell *cell = (CategoryViewCell*)[_collectionCategories dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
    STCategory* category = [self.categories objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    cell.categoryName.text = category.name;
    if(category.thumbnail.length > 0) {
        [cell.categoryImage sd_setImageWithURL:[NSURL URLWithString:category.thumbnail] placeholderImage:[UIImage imageNamed:@"stub"]];
    }
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor colorWithRed:219/255.0f green:219/255.0f blue:219/255.0f alpha:1.0f].CGColor;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChooseBrandSegue2"])
    {
        ChooseBrandController *brand = segue.destinationViewController;
        brand.navigationItem.title = @"Brand";
        brand.product = self.product;
    }
}


@end
