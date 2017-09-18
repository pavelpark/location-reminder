//
//  LRSignUpViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 9/18/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LRSignUpViewController.h"
#import "LogoView.h"

@interface LRSignUpViewController ()

@property UIImageView *backgroundView;

@end

@implementation LRSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setEmailAsUsername:YES];

    // Set background image.
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sylwia_bartyzel_442"]];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    // Create logo view and assign as new logInview
    LogoView *logoView = [[LogoView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
    self.signUpView.logo = logoView;
    
    UIColor *customLightBlue = [UIColor colorWithRed:0.08984375 green:0.57421875 blue:0.78515625 alpha:1.0];
    
    [self.signUpView.signUpButton setBackgroundImage:nil forState:normal];
    [self.signUpView.signUpButton setBackgroundColor: customLightBlue];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Layout background view to fit screen
    self.backgroundView.frame = CGRectMake(0, 0, self.signUpView.frame.size.width, self.signUpView.frame.size.height);

    // Layout logo view
    [self.signUpView.logo sizeToFit];
    CGRect logoFrame = self.signUpView.logo.frame;
    // Calculate new Y position based on size of logo view.
    // The offset is somewhat arbitrary; the PFLoginViewController superclass is appears to be overriding the logoView's
    //  initial height, and basing the position of the usernameField on that. We adjusted constants until it looked good.
    CGFloat logoFrameOriginY = self.signUpView.usernameField.frame.origin.y - logoFrame.size.height - 60;
    self.signUpView.logo.frame = CGRectMake(logoFrame.origin.x, logoFrameOriginY, self.signUpView.frame.size.width, 100);
}

@end
