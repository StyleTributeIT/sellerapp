//
//  ContactUsController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ContactUsController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *whatsappButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)mapTapped:(UITapGestureRecognizer *)sender;

@end
