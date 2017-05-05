//
//  AddReminderViewController.h
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;
//@import ContactsUI;
//@import MessageUI;

typedef void(^NewReminderCreateCompletion)(MKCircle *);

@interface AddReminderViewController : UIViewController

@property(strong, nonatomic) NSString *annotationTitle;
@property(nonatomic) CLLocationCoordinate2D coordinate;

@property(strong, nonatomic) NewReminderCreateCompletion completion;


@end
