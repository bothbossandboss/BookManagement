//
//  AccountViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountViewControllerDelegate;

@interface AccountViewController : UIViewController
<UITextFieldDelegate, UIGestureRecognizerDelegate>

//あるオブジェクトをそのオブジェクト自身のデリゲートに設定する時はweakがおすすめ。（循環参照を避けれる）
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UITextField *mailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
@property (strong, nonatomic) NSString *mailAddress;
@property (strong, nonatomic) NSString *password;
@property (weak, nonatomic) id <AccountViewControllerDelegate> delegate;

@end

@protocol AccountViewControllerDelegate <NSObject>

- (void)saveEditedAccountInfo:(AccountViewController*)controller;

@end