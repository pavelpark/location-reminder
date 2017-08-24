//
//  AddReminderViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "AddReminderViewController.h"
#import "Reminder.h"
#import "LocationController.h"

@interface AddReminderViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *locationName;
@property (strong, nonatomic) IBOutlet UITextField *locationRadius;

@end

@implementation AddReminderViewController

@synthesize locationName, locationRadius;
- (void)viewDidLoad {
    [super viewDidLoad];
    locationName.delegate = self;
    locationRadius.delegate = self;
};

//Keyboard Away
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [locationName resignFirstResponder];
    [locationRadius resignFirstResponder];

    return YES;
}

- (IBAction)setReminderButtonPressed:(UIButton *)sender {
    
    Reminder *newReminder = [Reminder object];
    
    newReminder.username = [[PFUser currentUser] username];
    
    newReminder.name = self.locationName.text;
    if ([newReminder.name isEqual:@""]) {
        newReminder.name = @"Reminder";
    }
    
    newReminder.location = [PFGeoPoint geoPointWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    
    NSNumber *radius = [NSNumber numberWithFloat:self.locationRadius.text.floatValue];
    
    if (radius == 0) {
        radius = [NSNumber numberWithFloat:100];
    }
    newReminder.radius = radius;
    
    [newReminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Annotation Title: %@", self.locationName.text);
        NSLog(@"Coordinates: %f, %f", self.coordinate.latitude, self.coordinate.longitude);
        
        NSLog(@"Save Reminder Successful:%i - Error: %@", succeeded, error.localizedDescription);
        NSLog(@"Radius Number: %@", self.locationRadius.init);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReminderSavedToParse" object:nil];
        
        //To start monetoring region.
        if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:self.coordinate radius:[radius intValue] identifier:newReminder.name];
            
            [LocationController.shared startMonitoringForRegion:region];
        }

        if (self.completion) {
            
            CGFloat overlayRadius = radius.floatValue;
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:overlayRadius];
            
            self.completion(circle);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
