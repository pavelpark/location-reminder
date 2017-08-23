//
//  Reminder.h
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/3/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import <Parse/Parse.h>

@interface Reminder : PFObject <PFSubclassing>

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) PFGeoPoint *location;
@property(strong, nonatomic) NSNumber *radius;
@property(strong, nonatomic) NSString *username;

@end
