//
//  Reminder.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/3/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "Reminder.h"
#import <Parse/PFObject+Subclass.h>

@implementation Reminder

@dynamic name;
@dynamic location;
@dynamic radius;
@dynamic username;

+(void)load{
    [super load];
    [self registerSubclass];
}

+(NSString *)parseClassName{
    return @"Reminder";
}

@end
