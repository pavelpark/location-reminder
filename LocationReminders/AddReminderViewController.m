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

@property (weak, nonatomic) IBOutlet UITextField *locationName;
@property (weak, nonatomic) IBOutlet UITextField *locationRadius;

@end

@implementation AddReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
};

//Keyboard Away
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_locationName resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTapped:(id)sender {
    
}

- (IBAction)setReminderButtonPressed:(UIButton *)sender {
    
    Reminder *newReminder = [Reminder object];
    
    newReminder.name = self.annotationTitle;
    
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
