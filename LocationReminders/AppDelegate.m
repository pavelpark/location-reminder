//
//  AppDelegate.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/1/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "AppDelegate.h"

@import Parse;
@import UserNotifications;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

//MARK: - Application lifecycle methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self registerForNotifications];
    
    // Verify that notifications have been authorized
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"Notifications are authorized.");
            [self setCategoriesForNotificationCenter];
        } else {
            NSLog(@"Notifications are not authorized.");
        }
    }];
    
    [self initializeParse];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of
    // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    //
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games
    // should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application
    // state information to restore your application to its current state in case it is terminated later.
    //
    // If your application supports background execution, this method is called instead of applicationWillTerminate:
    // when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes
    // made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application
    // was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also
    // applicationDidEnterBackground:.
}


//MARK: - UserNotifications Framework

- (void)registerForNotifications {
    UNUserNotificationCenter *current = [UNUserNotificationCenter currentNotificationCenter];
    current.delegate = self;
    
    UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
    [current requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            NSLog(@"There was an error %@", error.localizedDescription);
        }
        if (granted) {
            NSLog(@"The user has allowed permission for notifications!");
        }
    }];
}

- (void)setCategoriesForNotificationCenter {
    // Define notification actions.
    UNNotificationAction *completeReminderAction = [UNNotificationAction actionWithIdentifier:@"COMPLETE_ACTION"
                                                                                        title:@"Mark as complete"
                                                                                      options:UNNotificationActionOptionNone];
    UNNotificationAction *snoozeReminderAction = [UNNotificationAction actionWithIdentifier:@"SNOOZE_ACTION"
                                                                                      title:@"Snooze"
                                                                                    options:UNNotificationActionOptionNone];
    NSArray *notificationActions = @[completeReminderAction, snoozeReminderAction];
    
    // Define notification categories and set associated actions.
    UNNotificationCategory *reminderCategory = [UNNotificationCategory categoryWithIdentifier:@"REMINDER"
                                                                                      actions:notificationActions
                                                                            intentIdentifiers:@[]
                                                                                      options:UNNotificationCategoryOptionCustomDismissAction];
    NSSet *categories = [NSSet setWithObjects:reminderCategory, nil];
    
    // Set notification categories on the UNUserNotificationCenter
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
}

//MARK: UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Called when a notification is delivered to a foreground app.

    // Create the alert controller.
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reminder:"
                                                                   message:notification.request.content.body
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Define alert actions.
    UIAlertAction *snooze = [UIAlertAction actionWithTitle:@"Snooze"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"User snoozed the reminder");
    }];
    UIAlertAction *complete = [UIAlertAction actionWithTitle:@"Mark as complete"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"User completed the reminder");
    }];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"User dismissed the reminder");
    }];
    
    // Add actions to the alert controller.
    [alert addAction:complete];
    [alert addAction:snooze];
    [alert addAction:dismiss];
    
    [[self.window rootViewController] presentViewController:alert animated: YES completion:nil];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    // Called to let your app know which action was selected by the user for a given notification.
}


//MARK: - Parse Framework

- (void)initializeParse {
    ParseClientConfiguration *parseConfig = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> _Nonnull configuration) {
        configuration.applicationId = @"34bh5342n50";
        configuration.clientKey = @"as7d7as8d88vfdv091";
        configuration.server = @"https://location-reminder-server-pp.herokuapp.com/parse";
    }];
    
    [Parse initializeWithConfiguration:parseConfig];
}




@end
