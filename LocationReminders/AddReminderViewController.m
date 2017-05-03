//
//  AddReminderViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "AddReminderViewController.h"

@interface AddReminderViewController () <UITextFieldDelegate>

@property(weak, nonatomic) UITextField *locationName;
@property(weak, nonatomic) UITextField *locationRadius;

@end

@implementation AddReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Annotation Title: %@", self.annotationTitle);
    NSLog(@"Coordinates: %f, %f", self.coordinate.latitude, self.coordinate.longitude);
}
- (IBAction)LocationName:(UITextField *)sender {
    NSString *nameField = _locationName.text;
}
- (IBAction)LocationRadius:(UITextField *)sender {
    
}



@end
