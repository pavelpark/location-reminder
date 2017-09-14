//
//  LogoView.m
//  LocationReminders
//
//  Created by Rob Hatfield on 9/14/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "LogoView.h"

@interface LogoView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation LogoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self customInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self customInit];
    }
    
    return self;
}

- (void)customInit {
    [[NSBundle mainBundle] loadNibNamed:@"LogoView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
