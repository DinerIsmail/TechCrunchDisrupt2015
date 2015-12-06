//
//  AppDelegate.swift
//  FlashPoint
//
//  Created by Diner Ismail on 05/12/2015.
//  Copyright (c) 2015 FlashPoint. All rights reserved.
//

import UIKit
import Parse


// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()

		Parse.setApplicationId("gUsGmcZRkybGab0Lw5idxugRlHqIP0Er7INzmMy0", clientKey: "42Ypr1Sgo0FrRn14ozsLfN9W7KIPjfKJszOEZe6j")
//TESTING
//AppId: xKchtsJYcrBTan4IcSTclsiC8iStBqLapaL4ifMQ
//Client: vArKSdlwI3DAfPjEEiAbAyEZuUtK2sreuIZHBpaO

//PRODUCTION
//AppId: gUsGmcZRkybGab0Lw5idxugRlHqIP0Er7INzmMy0
//Client: 42Ypr1Sgo0FrRn14ozsLfN9W7KIPjfKJszOEZe6j
        PFUser.enableAutomaticUser()

        let defaultACL = PFACL();

        // If you would like all objects to be private by default, remove this line.
        defaultACL.publicReadAccess = true

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.

            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
		
		// ArcGIS Geotriggering
//		[AGSGTGeotriggerManager setupWithClientId:kClientId isProduction:NO tags:@[@"test"] isOffline:YES completion:^(NSError *error) {
//			if (error != nil) {
//				NSLog(@"Geotrigger Service setup encountered error: %@", error);
//			} else {
//				NSLog(@"Geotrigger Service ready to go!");
//				
//				// Turn on location tracking in adaptive mode
//				[AGSGTGeotriggerManager sharedManager].trackingProfile = kAGSGTTrackingProfileAdaptive;
//			}
//		}];

		AGSGTGeotriggerManager.setupWithClientId("VO8CyLsD8JCpWpbM", isProduction: false, tags: ["TechCrunch"], isOffline: true) { (error) -> Void in
			if error != nil {
				print("Geotrigger Service setup encountered error")
			} else {
				print("Geotrigger Service ready to go!")
			}
			
			AGSGTGeotriggerManager.sharedManager().trackingProfile = kAGSGTTrackingProfileAdaptive
		}

        //  Swift 2.0
        //
        //        if #available(iOS 8.0, *) {
        //            let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
        //            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        //            application.registerUserNotificationSettings(settings)
        //            application.registerForRemoteNotifications()
        //        } else {
        //            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
        //            application.registerForRemoteNotificationTypes(types)
        //        }

        return true
    }

    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		AGSGTGeotriggerManager.sharedManager().registerAPNSDeviceToken(deviceToken, completion: nil)
		
		let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()

        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n");
            } else {
                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error)
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		print("Failed to register for remote notifications")
		
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }
}
