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
@property (weak, nonatomic) IBOutlet UILabel *nameNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *radiusNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameWarning;
@property (weak, nonatomic) IBOutlet UILabel *radiusWarning;

@property (assign, nonatomic) NSInteger userUnits;
@property (strong, nonatomic) NSMeasurement *radiusMeasurement;
@property (assign, nonatomic) NSInteger minRadius, maxRadius;

@end

@implementation UIColor (Extensions)

+ (UIColor *)enabledButtonColor {
    return [UIColor colorWithRed:0.0 green:0.478431 blue:1.0 alpha:1.0];
}

+ (UIColor *)yellowNoteColor {
    return [UIColor colorWithRed:0.999534 green:0.988357 blue:0.472736 alpha:1];
}

+ (UIColor *)pinkNoteColor {
    return [UIColor colorWithRed:0.939375 green:0.703384 blue:0.837451 alpha:1];
}

@end

@implementation AddReminderViewController

@synthesize locationName, locationRadius;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Radius must be 15m - 40km.
    self.minRadius = 15; // 15 m. / ~50 ft.
    self.maxRadius = 40234; // ~40 km. / 25 mi.
    
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
    self.radiusMeasurement = [[NSMeasurement alloc] initWithDoubleValue:0.0
                                                                   unit:[NSUnitLength meters]];
    [self updateUnits];
    
    [self.setReminderButton setBackgroundColor:[UIColor grayColor]];
    self.setReminderButton.layer.cornerRadius = 5.0;
    self.setReminderButton.clipsToBounds = YES;
    self.radiusNoteLabel.layer.cornerRadius = 2.5;
    self.radiusNoteLabel.clipsToBounds = YES;
    self.nameNoteLabel.layer.cornerRadius = 2.5;
    self.nameNoteLabel.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check how many regions are currently being monitored.
    NSUInteger monitoredRegionCount = LocationController.shared.locationManager.monitoredRegions.count;
    NSUInteger regionLimit = 20; // Default is 20
    NSUInteger regionWarningCount = 17; // Default is 17
    if (monitoredRegionCount < regionWarningCount) {
        return;
    }
    
    NSString *warningMessage = [NSString alloc];
    if (monitoredRegionCount >= regionLimit) {
        NSLog(@"We're full!");
        warningMessage = @"You can create this reminder, but you will not be alerted of it until you complete some of your previous reminders.";
    } else {
        NSLog(@"Almost full!");
        NSUInteger remainingRegions = regionLimit - monitoredRegionCount;
        if (remainingRegions == 1) {
            warningMessage = [NSString stringWithFormat: @"This is the last reminder we can actively monitor. Complete reminders to free up space."];
        } else {
            warningMessage = [NSString stringWithFormat: @"We can only monitor %lu reminders at a time. You are approaching your limit; there are %lu reminders remaining.", regionLimit, remainingRegions];
        }
    }
    
    UIAlertController *regionLimitAlertController = [UIAlertController alertControllerWithTitle:@"LocReminder Warning"
                                                                                        message:warningMessage
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [regionLimitAlertController addAction: okAction];
    [self presentViewController:regionLimitAlertController animated:YES completion:nil];
}

//Keyboard Away
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [locationName resignFirstResponder];
    [locationRadius resignFirstResponder];

    return YES;
}

- (void)validateReminder:(NSNotification *)sender {
    BOOL validName = YES;
    BOOL validRadius = YES;
    
    if ([self.locationName.text isEqual: @""]) {
        validName = NO;
        [self.nameNoteLabel setTextColor:[UIColor whiteColor]];
        [self.nameNoteLabel setBackgroundColor:[UIColor pinkNoteColor]];
        [self.nameWarning setHidden:NO];
    } else {
        [self.nameNoteLabel setTextColor:[UIColor darkGrayColor]];
        [self.nameNoteLabel setBackgroundColor:[UIColor yellowNoteColor]];
        [self.nameWarning setHidden:YES];
    }
    
    NSString *regex = @"(^[^\\D]{0,4}(\\.?)\\d{0,3}$)";
    NSRange replacementRange = [self.locationRadius.text rangeOfString:regex options:NSRegularExpressionSearch];
    
    if (replacementRange.location == NSNotFound || ! (self.locationRadius.text.floatValue > 0.0) ) {
        validRadius = NO;
    } else if (sender.object == self.locationRadius) {
        NSMeasurement *newMeasurement = [[NSMeasurement alloc] initWithDoubleValue:self.locationRadius.text.doubleValue
                                                                              unit:self.radiusMeasurement.unit];
        // Verify that new measurement is within min & max radius limits.
        double meterCheck = [[newMeasurement measurementByConvertingToUnit:[NSUnitLength meters]] doubleValue];
        if ( meterCheck >= self.minRadius && meterCheck <= self.maxRadius ) {
            self.radiusMeasurement = newMeasurement;
            NSLog(@"Text changed, new measurement: %@", self.radiusMeasurement);
        } else {
            validRadius = NO;
        }
    }
    
    if (validRadius) {
        [self.radiusNoteLabel setTextColor:[UIColor darkGrayColor]];
        [self.radiusNoteLabel setBackgroundColor:[UIColor yellowNoteColor]];
        [self.radiusWarning setHidden:YES];
    } else {
        [self.radiusNoteLabel setTextColor:[UIColor whiteColor]];
        [self.radiusNoteLabel setBackgroundColor:[UIColor pinkNoteColor]];
        [self.radiusWarning setHidden:NO];
    }
    
    if (validRadius && validName) {
        [self.setReminderButton setEnabled:YES];
        [self.setReminderButton setBackgroundColor:[UIColor enabledButtonColor]];
    } else {
        [self.setReminderButton setEnabled:NO];
        [self.setReminderButton setBackgroundColor:[UIColor grayColor]];
    }
}

- (IBAction)radiusUnitsChanged:(UISegmentedControl *)sender {
    NSLog(@"Units changed");
    self.userUnits = sender.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:self.userUnits forKey:@"userUnits"];
    [self updateUnits];
    
    NSString *newRadiusString = [NSString alloc];
    NSNumber *newRadiusNumber = [NSNumber alloc];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    // Change displayed value and update userDefaults
    switch (self.userUnits) {
        case 0:
            // set units to m
            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
            break;
        case 1:
            // set units to km
            numberFormatter.usesSignificantDigits = YES;
            numberFormatter.minimumSignificantDigits = 1;
            numberFormatter.maximumSignificantDigits = 2;
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            break;
        case 2:
            // set units to ft
            numberFormatter.numberStyle = NSNumberFormatterNoStyle;
            break;
        case 3:
            // set units to mi
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
            self.locationRadius.placeholder = @"Distance in meters";
            self.radiusNoteLabel.text = @"From 15 to 40,000 m";
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength meters]];
            self.locationRadius.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 1:
            // Kilometers
            self.locationRadius.placeholder = @"Distance in kilometers";
            self.radiusNoteLabel.text = @"From 0.1 to 40 km";
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength kilometers]];
            self.locationRadius.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case 2:
            // Feet
            self.locationRadius.placeholder = @"Distance in feet";
            self.radiusNoteLabel.text = @"From 50 to 132,000 ft";
            self.radiusMeasurement = [self.radiusMeasurement measurementByConvertingToUnit:[NSUnitLength feet]];
            self.locationRadius.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 3:
            // Miles
            self.locationRadius.placeholder = @"Distance in miles";
            self.radiusNoteLabel.text = @"From 0.01 to 25 mi";
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
