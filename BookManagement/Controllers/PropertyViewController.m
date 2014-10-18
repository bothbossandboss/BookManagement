//
//  PropertyViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

/*
 *アプリ初回起動時にAccountViewControllerを表示させるが、この時、accountSetButtonTappedが先に呼ばれ、
 *その後viewDidLoadが呼ばれる。これにより、accountInfoが初期値で初期化されず、
 *Account画面のメール、パスワード、確認は全て空欄となる。
 */

#import "PropertyViewController.h"
#import "AccountViewController.h"
#import <AFNetworking/AFNetworking.h>

#define MAIL 0
#define PASSWORD 1

@interface PropertyViewController () <AccountViewControllerDelegate>
{
    NSMutableArray *accountInfo;
}
@end

@implementation PropertyViewController
@synthesize accountSetButton;

#pragma mark - the life cycle of view
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.title = @"設定";
    accountInfo = [[NSMutableArray alloc]init];
    //アカウント情報の設定
    NSString *firstMailAddress = @"01234@567.com";
    NSString *firstPassword = @"01234567";
    [accountInfo insertObject:firstMailAddress atIndex:MAIL];
    [accountInfo insertObject:firstPassword atIndex:PASSWORD];
    [accountSetButton  addTarget:self action:@selector(accountSetButtonTapped) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)accountSetButtonTapped
{
    AccountViewController *accountViewController = [[AccountViewController alloc]init];
    accountViewController.delegate = self;
    //accountViewController.mailAddress = [accountInfo objectAtIndex:MAIL];
    //accountViewController.password = [accountInfo objectAtIndex:PASSWORD];
    UINavigationController *accountNavi = [[UINavigationController alloc]
                                           initWithRootViewController:accountViewController];
    [self.navigationController presentViewController:accountNavi animated:YES completion:nil];
}

#pragma mark - public method
- (void)saveEditedAccountInfo:(AccountViewController *)controller
{
    [accountInfo replaceObjectAtIndex:MAIL withObject:controller.mailAddress];
    [accountInfo replaceObjectAtIndex:PASSWORD withObject:controller.password];
}

@end
