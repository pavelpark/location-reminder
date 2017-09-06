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
@property (weak, nonatomic) IBOutlet UISegmentedControl *radiusUnits;
@property (weak, nonatomic) NSUserDefaults *userDefaults;
@property (assign, nonatomic) NSInteger userUnits;

@end

@implementation AddReminderViewController

@synthesize locationName, locationRadius;
- (void)viewDidLoad {
    [super viewDidLoad];
    locationName.delegate = self;
    locationRadius.delegate = self;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
};

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.userUnits = [self.userDefaults integerForKey:@"userUnits"];
    NSLog(@"User units: %ld", (long)self.userUnits);
    if (!self.userUnits) {
        NSLog(@"ViewWillAppear: Units are not set, setting to 0");
        self.locationRadius.placeholder = @"Distance in m";
        self.userUnits = 0;
        [self.userDefaults setInteger:0 forKey:@"userUnits"];
        [self.radiusUnits setSelectedSegmentIndex:0];
    }
    [self updateUnits];
}

//Keyboard Away
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [locationName resignFirstResponder];
    [locationRadius resignFirstResponder];

    return YES;
}

- (IBAction)radiusUnitsChanged:(UISegmentedControl *)sender {
    NSLog(@"Units changed");
    // Capture current value
    NSMeasurement *radiusMeasurement = [NSMeasurement alloc];
    double oldRadiusValue = self.locationRadius.text.doubleValue;
    switch (self.userUnits) {
        case 0:
            radiusMeasurement = [radiusMeasurement initWithDoubleValue:oldRadiusValue unit:[NSUnitLength meters]];
            NSLog(@"Captured value: %f meters", oldRadiusValue);
            break;
        case 1:
            radiusMeasurement = [radiusMeasurement initWithDoubleValue:oldRadiusValue unit:[NSUnitLength kilometers]];
            NSLog(@"Captured value: %f km", oldRadiusValue);
            break;
        case 2:
            radiusMeasurement = [radiusMeasurement initWithDoubleValue:oldRadiusValue unit:[NSUnitLength feet]];
            NSLog(@"Captured value: %f feet", oldRadiusValue);
            break;
        case 3:
            radiusMeasurement = [radiusMeasurement initWithDoubleValue:oldRadiusValue unit:[NSUnitLength miles]];
            NSLog(@"Captured value: %f miles", oldRadiusValue);
            break;
        default:
            radiusMeasurement = [radiusMeasurement initWithDoubleValue:oldRadiusValue unit:[NSUnitLength meters]];
            NSLog(@"Captured default value: %f meters", oldRadiusValue);
            break;
    }
    NSLog(@"Current measurement units: %@", radiusMeasurement.unit);
    
    
    // Change displayed value and update userDefaults
    switch (sender.selectedSegmentIndex) {
        case 0:
            // set units to m
            radiusMeasurement = [radiusMeasurement measurementByConvertingToUnit:[NSUnitLength meters]];
            break;
        case 1:
            // set units to km
            radiusMeasurement = [radiusMeasurement measurementByConvertingToUnit:[NSUnitLength kilometers]];
            break;
        case 2:
            // set units to ft
            radiusMeasurement = [radiusMeasurement measurementByConvertingToUnit:[NSUnitLength feet]];
            break;
        case 3:
            // set units to mi
            radiusMeasurement = [radiusMeasurement measurementByConvertingToUnit:[NSUnitLength miles]];
            break;
        default:
            radiusMeasurement = [radiusMeasurement measurementByConvertingToUnit:[NSUnitLength meters]];
            break;
    }
    NSLog(@"New measurement units: %@", radiusMeasurement.unit);
    
    NSString *newRadiusString = [NSString alloc];
    if (radiusMeasurement.doubleValue == 0.0) {
        newRadiusString = @"";
    } else {
        newRadiusString = [NSString stringWithFormat:@"%f",radiusMeasurement.doubleValue];
    }
    self.locationRadius.text = newRadiusString;
    self.userUnits = sender.selectedSegmentIndex;
    [self.userDefaults setInteger:self.userUnits forKey:@"userUnits"];
    [self updateUnits];
}


- (IBAction)setReminderButtonPressed:(UIButton *)sender {
    
    Reminder *newReminder = [Reminder object];
    
    newReminder.username = [[PFUser currentUser] username];
    
    newReminder.name = self.locationName.text;
    if ([newReminder.name isEqual:@""]) {
        newReminder.name = @"Reminder";
    }
    
    newReminder.location = [PFGeoPoint geoPointWithLatitude:self.coordinate.latitude
                                                  longitude:self.coordinate.longitude];
    
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
        
        // To start monitoring region.
        if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:self.coordinate
                                                                         radius:[radius intValue]
                                                                     identifier:newReminder.objectId];
            
            [LocationController.shared startMonitoringForRegion:region];
        }

        if (self.completion) {
            
            CGFloat overlayRadius = radius.floatValue;
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:overlayRadius];
            circle.title = newReminder.objectId;
            
            self.completion(circle);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [newReminder pinInBackground];
    
}

- (void)updateUnits {
    switch (self.userUnits) {
        case 0:
            // Meters
            self.locationRadius.placeholder = @"Distance in m";
            break;
        case 1:
            // Kilometers
            self.locationRadius.placeholder = @"Distance in km";
            break;
        case 2:
            // Feet
            self.locationRadius.placeholder = @"Distance in ft";
            break;
        case 3:
            // Miles
            self.locationRadius.placeholder = @"Distance in mi";
            break;
        default:
            NSLog(@"Updating units: Units are not set; setting to 0");
            self.locationRadius.placeholder = @"Distance in m";
            self.userUnits = 0;
            [self.userDefaults setInteger:0 forKey:@"userUnits"];
            [self.radiusUnits setSelectedSegmentIndex:0];
            break;
    }
}

@end
