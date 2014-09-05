//
//  PropertyViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "PropertyViewController.h"
#import "AccountViewController.h"

#define MAIL 0
#define PASSWORD 1

@interface PropertyViewController () <AccountViewControllerDelegate>
{
    NSMutableArray *accountInfo;
}

@end

@implementation PropertyViewController
@synthesize accountSetButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"設定";
    [accountSetButton  addTarget:self action:@selector(accountSetButtonTapped) forControlEvents:UIControlEventTouchDown];
    //アカウント情報の設定
    NSString *firstMailAddress = @"01234@56789.com";
    NSString *firstPassword = @"0123456789";
    accountInfo = [[NSMutableArray alloc]init];
    [accountInfo insertObject:firstMailAddress atIndex:MAIL];
    [accountInfo insertObject:firstPassword atIndex:PASSWORD];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)accountSetButtonTapped
{
    AccountViewController *accountViewController = [[AccountViewController alloc]init];
    accountViewController.delegate = self;
    accountViewController.mailAddress = [accountInfo objectAtIndex:MAIL];
    accountViewController.password = [accountInfo objectAtIndex:PASSWORD];
    UINavigationController *accountNavi = [[UINavigationController alloc]
                                           initWithRootViewController:accountViewController];
    [self.navigationController presentViewController:accountNavi animated:YES completion:nil];
    
}

- (void)saveEditedAccountInfo:(AccountViewController *)controller
{
    [accountInfo insertObject:controller.mailAddress atIndex:MAIL];
    [accountInfo insertObject:controller.password atIndex:PASSWORD];
    NSLog(@"MAIL:%@ PASS:%@",[accountInfo objectAtIndex:MAIL],[accountInfo objectAtIndex:PASSWORD]);
}

@end
