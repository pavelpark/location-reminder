//
//  LocationController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LocationController.h"
#import "ViewController.h"
#import "Reminder.h"

@import UserNotifications;
@import MapKit;
@import Parse;

@interface LocationController () <CLLocationManagerDelegate>
@property NSMutableArray<CLRegion *> *allRegions;
@end

@implementation LocationController

@synthesize locationManager;
@synthesize location;
@synthesize allRegions;

+ (LocationController *)shared {
    
    static LocationController *shared = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (LocationController *)init {
    self = [super init];
    locationManager = [[CLLocationManager alloc] init];
    location = [[CLLocation alloc] init];
    allRegions = [[NSMutableArray alloc] init];
    self.locationManager.delegate = self;
    return self;
}

- (void)requestPermissions {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)monitorSignificantMovements {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.distanceFilter = 5000; // Update only every 5 km while in background
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)monitorFullMovements {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // Continual updates when more accuracy is needed
    [self.locationManager startUpdatingLocation];
}

- (void)addRegion:(CLRegion *)region {
    [self.allRegions addObject:region];
    NSLog(@"All regions: %@", self.allRegions);
}

- (void)checkForNearbyRegions {
    // Check for reminders within 10 km of current location
    NSMutableArray *nearbyRegions = [[NSMutableArray alloc] init];
    
    for (CLCircularRegion *region in allRegions) {
        CLLocation *regionCenterLocation = [[CLLocation alloc] initWithLatitude:region.center.latitude
                                                                      longitude:region.center.longitude];
        if ([regionCenterLocation distanceFromLocation: self.location] < 10000) {
            [nearbyRegions addObject:region];
        }
    }
}

- (void)resetMonitoredRegions {
    for (CLRegion *monitoredRegion in [self.locationManager monitoredRegions]) {
        [locationManager stopMonitoringForRegion:monitoredRegion];
    }
    [self.allRegions removeAllObjects];
}

- (void)startMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringForRegionWithIdentifier:(NSString *)regionIdentifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", regionIdentifier];
    CLRegion *regionToRemove = [[[self.locationManager monitoredRegions] filteredSetUsingPredicate:predicate] anyObject];
    NSLog(@"%@", regionToRemove);
    [locationManager stopMonitoringForRegion:regionToRemove];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
        CLLocation *lastLocation = locations.lastObject;
        
        self.location = lastLocation;
        [self.delegate locationControllerUpdatedLocation:self.location];
}

// We need to apply all of these methods in order to identify the region and monitor the region.
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"We have successfully started monitoring changes for a region: %@", region.identifier);
}

// When the user enters the region notification gets pushed.
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"User entered region:%@", region.identifier);
    
    PFQuery *localQuery = [[Reminder query] fromLocalDatastore];
    [localQuery getObjectInBackgroundWithId:region.identifier block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Local query error: %@", error);
        } else {
            NSLog(@"Local query results: %@", object);
        [self postNotificationForReminderNamed: object[@"name"] withId: object.objectId];
        }
    }];

}

- (void)postNotificationForReminderNamed:(NSString *)name withId:(NSString *)objectId {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"Reminder";
    content.body = [NSString stringWithFormat:@"%@", name];
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"REMINDER";
    content.userInfo = [NSDictionary dictionaryWithObject:objectId forKey:@"objectId"];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Location Entered" content:content trigger:trigger];
    
    UNUserNotificationCenter *current = [UNUserNotificationCenter currentNotificationCenter];
    
    [current removeAllPendingNotificationRequests];
    [current addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error posting user notification: %@", error.localizedDescription);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"User exited region: %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"There was an error: %@", error.localizedDescription); //ignore if its in the simulator.
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    NSLog(@"This is here for no reason... But heres a visit: %@", visit);
}

@end
