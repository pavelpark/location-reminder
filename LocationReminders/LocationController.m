//
//  LocationController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LocationController.h"


@implementation LocationController

@synthesize locationManager;
@synthesize location;

+(LocationController *)sharedLocationController{
    
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
    return self;
}

@end
