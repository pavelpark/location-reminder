//
//  LRViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 9/12/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LRViewController.h"

@interface LRViewController ()

@end

@implementation LRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fields = PFLogInFieldsLogInButton |
    PFLogInFieldsSignUpButton |
    PFLogInFieldsUsernameAndPassword |
    PFLogInFieldsPasswordForgotten;
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginLogo"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sylwia_bartyzel_442"]];
    [self.view addSubview:backgroundView];
    backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundView.clipsToBounds = YES;
    self.logInView.logo = logoView;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
}

@end
