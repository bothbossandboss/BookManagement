//
//  AccountViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

/*
 * <キーボード表示/非表示におけるScrollViewの処理について>
 * このコードにおいてviewDidLoadでmyScrollView.frame = self.view.bounds;を行っているが、この時の
 * self.view.boundsは、(0,0,320,568)である。
 * 一方、viewDidApperでは、viewDidLoad内でnavigationBarを表示させているため、self.view.boundsはnavigationBarを
 * 除いた範囲の大きさしかない。
 * よって、キーボード処理ではnavigationBar分を考慮する必要がある。(ここでは#define NAVIGATION_BAR_HEIGHT 88)
 * 他の方法の一つはxibファイルで大きさを確定してコードではmyScrollViewの大きさをいじらないことだが、それは少し面倒か。
 * 又は、DetailViewControllerのように、xibファイルでnavigationBarやtabBarの大きさを意識せずに作ってしまうか。
 * この時はxibのviewがnavigationBarやtabBarを除いた範囲であることに注意。(だから全体的に上にobjectがある。)
 */

#import "AccountViewController.h"

#define KEYBOARD_THRESHOLD 10
#define ADJUSTING_SCREEN_EDGE 80
#define NAVIGATION_BAR_HEIGHT 88

@interface AccountViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    UITextField *activeField;
}
@end

@implementation AccountViewController

@synthesize singleTap;
@synthesize myScrollView;
@synthesize mailAddressTextField;
@synthesize passwordTextField;
@synthesize confirmTextField;
@synthesize mailAddress;
@synthesize password;

#pragma mark - the life cycle of view
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"アカウント設定";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"保存"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(saveButtonTapped)];
    self.navigationItem.rightBarButtonItem = saveButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"閉じる"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(cancelButtonTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.singleTap = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(onSingleTap:)];
    myScrollView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    mailAddressTextField.delegate = self;
    passwordTextField.delegate = self;
    confirmTextField.delegate = self;
    mailAddressTextField.text = mailAddress;
    passwordTextField.text = password;
    confirmTextField.text = password;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)saveButtonTapped
{
    //文字列(NSString)の比較はisEqualToString:を用いる。(==)ではだめ。
    //isEqualToString:はバイト数が違うとアウトのようです。似通ったものでもokならcompareだとか(？)
    if (![passwordTextField.text isEqualToString:confirmTextField.text]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"エラー"
                                  message:@"パスワードが違います"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }else{
        //mailAddressとpasswordをTextFieldの内容に更新
        if([self.delegate respondsToSelector:@selector(saveEditedAccountInfo:)]){
            self.mailAddress = self.mailAddressTextField.text;
            self.password = self.passwordTextField.text;
            [self.delegate saveEditedAccountInfo:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//シングルタップでの挙動（キーボード表示の時）
- (void)onSingleTap:(UITapGestureRecognizer*)recognizer
{
    [self.mailAddressTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
}

//キーボードが表示されていない時は他に影響を与えないように無効化。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(gestureRecognizer == self.singleTap){
        //キーボード表示中
        if(self.mailAddressTextField.isFirstResponder == YES
           || self.passwordTextField.isFirstResponder == YES
           || self.confirmTextField.isFirstResponder == YES){
            return YES;
        }else{
            return NO;
        }
    }
    return  YES;
}

//TextField制御
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWasShown:)
     name:UIKeyboardDidShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillBeHidden:)
     name:UIKeyboardWillHideNotification
     object:nil];
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *userInfo;
    userInfo = [aNotification userInfo];
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    float screenHeight = screenBounds.size.height;
    float textFieldEdge = activeField.frame.origin.y + activeField.frame.size.height;
    float keyboardEdge = screenHeight-keyboardFrameEnd.size.height - KEYBOARD_THRESHOLD;
    float afterScreenEdge = screenHeight-activeField.frame.origin.y - activeField.frame.size.height-keyboardFrameEnd.size.height - ADJUSTING_SCREEN_EDGE;
    if(textFieldEdge > keyboardEdge){
        [UIView animateWithDuration:0.3
                         animations:^{
                             myScrollView.frame = CGRectMake(0, afterScreenEdge, myScrollView.frame.size.width, myScrollView.frame.size.height);
                         }];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         myScrollView.frame = CGRectMake(0, -NAVIGATION_BAR_HEIGHT,
                                                         myScrollView.frame.size.width,
                                                         myScrollView.frame.size.height);
                     }];
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         myScrollView.frame = CGRectMake(0, -NAVIGATION_BAR_HEIGHT,
                                                         myScrollView.frame.size.width,
                                                         myScrollView.frame.size.height);
                     }];
    [textField resignFirstResponder];
    return  YES;
}

@end
