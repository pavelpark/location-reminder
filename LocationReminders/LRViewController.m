//
//  LRViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 9/12/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LRViewController.h"

@interface LRViewController ()

@property UIImageView *backgroundView;

@end

@implementation LRViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sylwia_bartyzel_442"]];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginLogoClear"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.logInView.logo = logoView;
    
    self.fields = PFLogInFieldsLogInButton |
    PFLogInFieldsSignUpButton |
    PFLogInFieldsUsernameAndPassword |
    PFLogInFieldsPasswordForgotten;
    
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundView.frame = CGRectMake(0, 0, self.logInView.frame.size.width, self.logInView.frame.size.height);
}

@end
