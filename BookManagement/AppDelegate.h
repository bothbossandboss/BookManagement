//
//  AppDelegate.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//


#import "EditViewController.h"
#import "AccountViewController.h"
#import "PropertyViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    PropertyViewController *propertyView;
    UINavigationController *propertyNavi;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
