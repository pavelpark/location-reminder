//
//  LocationController.h
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@protocol LocationControllerDelegate <NSObject>

@required

- (void)locationControllerUpdatedLocation:(CLLocation *)location;

@end

@interface LocationController : NSObject

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) CLLocation *location;
@property(weak, nonatomic) id delegate;

+ (LocationController *)shared;

- (void)requestPermissions;
- (void)startMonitoringForRegion:(CLRegion *)region;
- (void)stopMonitoringForRegionWithIdentifier:(NSString *)regionIdentifier;
- (void)resetMonitoredRegions;

- (void)addRegion:(CLRegion *)region;

@end
