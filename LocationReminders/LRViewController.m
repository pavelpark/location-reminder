//
//  LRViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 9/12/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LRViewController.h"
#import "LogoView.h"

@interface LRViewController ()

@property UIImageView *backgroundView;
@property LogoView *logoView;

@end

@implementation LRViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set background color and image
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sylwia_bartyzel_442"]];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    // Create logo view and assign as new logInview
    self.logoView = [[LogoView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
    self.logInView.logo = self.logoView;
    
    self.fields = PFLogInFieldsLogInButton |
    PFLogInFieldsSignUpButton |
    PFLogInFieldsUsernameAndPassword |
    PFLogInFieldsPasswordForgotten;
    
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Layout background view to fit screen
    self.backgroundView.frame = CGRectMake(0, 0, self.logInView.frame.size.width, self.logInView.frame.size.height);
    
    // Layout logo view
    [self.logInView.logo sizeToFit];
    CGRect logoFrame = self.logInView.logo.frame;
    // Calculate new Y position based on size of logo view.
    // The offset is somewhat arbitrary; the PFLoginViewController superclass is appears to be overriding the logoView's
    //  initial height, and basing the position of the usernameField on that. We adjusted constants until it looked good.
    CGFloat logoFrameOriginY = self.logInView.usernameField.frame.origin.y - logoFrame.size.height - 60;
    self.logInView.logo.frame = CGRectMake(logoFrame.origin.x, logoFrameOriginY, self.logInView.frame.size.width, 100);
}

@end
