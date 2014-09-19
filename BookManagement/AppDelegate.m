//
//  AppDelegate.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "AppDelegate.h"
#import "EditViewController.h"
#import "MainTableViewController.h"
#import "AccountViewController.h"
#import "PropertyViewController.h"

#define setTabBarItemPosition -10

@interface AppDelegate()
{
    UITabBarController *tabBarController;
    PropertyViewController *propertyView;
    UINavigationController *propertyNavi;
}
@end

@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    MainTableViewController *mainView = [[MainTableViewController alloc]init];
    UINavigationController *mainNavi = [[UINavigationController alloc]
                    initWithRootViewController:mainView];
    propertyView = [[PropertyViewController alloc]init];
    propertyNavi = [[UINavigationController alloc]
                    initWithRootViewController:propertyView];
    tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:mainNavi,propertyNavi, nil];
    //TabBarアイコンの設定(ここでタイトルとか設定)
    UIFont *tabFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
    NSDictionary *selectedAttributes = @{NSFontAttributeName:tabFont,NSForegroundColorAttributeName:[UIColor blueColor]};
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes
                                             forState:UIControlStateSelected];
    NSDictionary *attributesNomal = @{NSFontAttributeName:tabFont,NSForegroundColorAttributeName:[UIColor grayColor]};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesNomal
                                                 forState:UIControlStateNormal];
    UITabBarItem *mainTabBarItem = [tabBarController.tabBar.items objectAtIndex:0];
    mainTabBarItem.title = @"書籍一覧";
    UITabBarItem *propertyTabBarItem = [tabBarController.tabBar.items objectAtIndex:1];
    propertyTabBarItem.title = @"設定";
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, setTabBarItemPosition)];
    self.window.rootViewController = tabBarController;
    tabBarController.selectedViewController = propertyNavi;
    [self.window makeKeyAndVisible];
    [self performSelector:@selector(firstLogin) withObject:nil afterDelay:0.2];
    return YES;
}

- (void)firstLogin
{
     //初回起動時
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"HasLaunchedOnce"]) {
        NSLog(@"first");
        [propertyView accountSetButtonTapped];
    }
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
