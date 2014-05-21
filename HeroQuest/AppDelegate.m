//
//  AppDelegate.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/12/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Uncomment to change the background color of navigation bar
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xffbc42)];
    
    // Uncomment to change the color of back button
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Uncomment to change the font style of the title
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           UIColorFromRGB(0xFFFFFF), NSForegroundColorAttributeName,
                                                           nil, NSShadowAttributeName,
                                                           nil, NSFontAttributeName, nil]];
    
    //Loading the default filter if doesn't exist
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* filters = [userDefaults objectForKey:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER];
    if (!filters) {
        filters = @{QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME: @"",
                    QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT: @QUEST_ALIGNMENT_NEUTRAL,
                    QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_MAP_TYPE: @QUEST_MAP_TYPE_STANDARD
                    };
        [userDefaults setObject:filters forKey:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER];
        [userDefaults synchronize];
    }
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
