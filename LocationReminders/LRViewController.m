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
    
}

- (void)displayLogInViewController {
    
    self.fields = PFLogInFieldsLogInButton |
    PFLogInFieldsSignUpButton |
    PFLogInFieldsUsernameAndPassword |
    PFLogInFieldsPasswordForgotten;
    
    self.logInView.logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LoginLogo"]];
    self.view.backgroundColor = [UIColor darkGrayColor];
    
}


@end
