//
//  LocationController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LocationController.h"
#import "ViewController.h"

@import UserNotifications;
@import MapKit;

@interface LocationController () <CLLocationManagerDelegate>

@end
@implementation LocationController

@synthesize locationManager;
@synthesize location;

+(LocationController *)shared{
    
    static LocationController *shared = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (LocationController *)init {
    self = [super init];
    locationManager = [[CLLocationManager alloc]init];
    location = [[CLLocation alloc]init];
    self.locationManager.delegate = self;
    return self;
}

-(void)startMonitoringForRegion:(CLRegion *)region{
    [self.locationManager startMonitoringForRegion:region];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.lastObject;
    
//    self.location = location;
    
    [self.delegate locationControllerUpdatedLocation:location];
    
}

//We need to apply all of these methods in order to identify the region and monitore the region.
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    NSLog(@"We have successfully started monitoring changes for a region: %@", region.identifier);
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"User did enter region:%@", region.identifier);
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"Reminder";
    content.body = [NSString stringWithFormat:@"%@", region.identifier];
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Location Entered" content:content trigger:trigger];
    
    UNUserNotificationCenter *current = [UNUserNotificationCenter currentNotificationCenter];
    
    [current removeAllPendingNotificationRequests];
    [current addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error posting user notofication: %@", error.localizedDescription);
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSLog(@"The User did exit Region: %@", region.identifier);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"There was an error: %@", error.localizedDescription); //ignore if its in the simulator.
}

-(void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit{
    NSLog(@"This is here for no reason... But heres a visit: %@", visit);
}

@end
