//
//  ViewController.h
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/1/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;


@interface ViewController : UIViewController

- (void)locationControllerUpdatedLocation:(CLLocation *)location;

- (IBAction)setMap:(id)sender;

@end

