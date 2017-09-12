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
@property (weak, nonatomic) IBOutlet UIButton *setReminderButton;

@property (assign, nonatomic) NSInteger userUnits;
@property (strong, nonatomic) NSMeasurement *radiusMeasurement;

@end

@implementation AddReminderViewController

@synthesize locationName, locationRadius;

- (void)viewDidLoad {
    [super viewDidLoad];
    locationName.delegate = self;
    locationRadius.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateReminder:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.locationRadius];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateReminder:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.locationName];
};

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Defaults to 0 (meters) if not already set
    self.userUnits = [[NSUserDefaults standardUserDefaults] integerForKey:@"userUnits"];
    NSLog(@"User units: %ld", (long)self.userUnits);
    [self.radiusUnits setSelectedSegmentIndex:self.userUnits];
    self.radiusMeasurement = [[NSMeasurement alloc] initWithDoubleValue:0.0 unit:[NSUnitLength meters]];
    [self updateUnits];
    
    [self.setReminderButton setBackgroundColor:[UIColor grayColor]];
    self.setReminderButton.layer.cornerRadius = 5.0;
    self.setReminderButton.clipsToBounds = YES;
}

//Keyboard Away
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [locationName resignFirstResponder];
    [locationRadius resignFirstResponder];

    return YES;
}

- (void)validateReminder:(NSNotification *)sender {
    NSLog(@"Text field changed");
    BOOL validName = YES;
    BOOL validRadius = YES;
    
    if ([self.locationName.text isEqual: @""]) {
        validName = NO;
    }
    
    NSString *regex = @"(^[^\\D]{0,9}(\\.?)\\d{0,2}$)";
    NSRange replacementRange = [self.locationRadius.text rangeOfString:regex options:NSRegularExpressionSearch];
    
    if (replacementRange.location == NSNotFound || ! (self.locationRadius.text.floatValue > 0.0) ) {
        validRadius = NO;
    } else if (sender.object == self.locationRadius) {
        NSLog(@"Sender: %@", sender);
        NSMeasurement *newMeasurement = [[NSMeasurement alloc] initWithDoubleValue:self.locationRadius.text.doubleValue
                                                                              unit:self.radiusMeasurement.unit];
        self.radiusMeasurement = newMeasurement;
        NSLog(@"Text changed, new measurement: %@", self.radiusMeasurement);
    }
    
    if (validRadius && validName) {
        [self.setReminderButton setEnabled:YES];
        [self.setReminderButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.478431 blue:1.0 alpha:1.0]];
    } else {
        [self.setReminderButton setEnabled:NO];
        [self.setReminderButton setBackgroundColor:[UIColor grayColor]];
    }
}

- (IBAction)radiusUnitsChanged:(UISegmentedControl *)sender {
    NSLog(@"Units changed");
    self.userUnits = sender.selectedSegmentIndex;
    NSString *newRadiusString = [NSString alloc];
    NSNumber *newRadiusNumber = [NSNumber alloc];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    // Change displayed value and update userDefaults
    switch (self.userUnits) {
        case 0:
            // set units to m
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength meters]];
            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
            break;
        case 1:
            // set units to km
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength kilometers]];
            numberFormatter.usesSignificantDigits = YES;
            numberFormatter.minimumSignificantDigits = 1;
            numberFormatter.maximumSignificantDigits = 2;
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            break;
        case 2:
            // set units to ft
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength feet]];
            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
            break;
        case 3:
            // set units to mi
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength miles]];
            numberFormatter.usesSignificantDigits = YES;
            numberFormatter.minimumSignificantDigits = 1;
            numberFormatter.maximumSignificantDigits = 2;
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            break;
        default:
            break;
    }
    NSLog(@"New measurement: %@", self.radiusMeasurement);
    
    if (! (self.radiusMeasurement.doubleValue > 0.0)) {
        newRadiusString = @"";
    } else {
        newRadiusNumber = [NSNumber numberWithDouble: self.radiusMeasurement.doubleValue];
        newRadiusString = [numberFormatter stringFromNumber:newRadiusNumber];
    }
    self.locationRadius.text = newRadiusString;
    self.userUnits = sender.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:self.userUnits forKey:@"userUnits"];
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
    
    NSMeasurement *currentRadiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength meters]];
    NSNumber *radius = [NSNumber numberWithDouble:currentRadiusMeasurement.doubleValue];
    
    if (radius == 0) {
        NSLog(@"Radius string resulted in a zero, default to 100 meters");
        radius = [NSNumber numberWithDouble:100];
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
                                                                         radius:radius.doubleValue
                                                                     identifier:newReminder.objectId];
            
            [LocationController.shared startMonitoringForRegion:region];
        }

        if (self.completion) {
            
            // CGFloat overlayRadius = radius.floatValue;
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:radius.doubleValue];
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
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength meters]];
            self.locationRadius.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 1:
            // Kilometers
            self.locationRadius.placeholder = @"Distance in km";
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength kilometers]];
            self.locationRadius.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case 2:
            // Feet
            self.locationRadius.placeholder = @"Distance in ft";
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength feet]];
            self.locationRadius.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 3:
            // Miles
            self.locationRadius.placeholder = @"Distance in mi";
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength miles]];
            self.locationRadius.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        default:
            break;
    }
    if (self.locationRadius.isFirstResponder) {
        [self.locationRadius reloadInputViews];
    }
}

@end
