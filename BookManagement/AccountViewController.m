//
//  AccountViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "AccountViewController.h"

#define keyboardThreshold 50
#define adjustingScreenEdge 80

@interface AccountViewController ()
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
    myScrollView.frame = self.view.bounds;
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
    float keyboardEdge = screenHeight-keyboardFrameEnd.size.height - keyboardThreshold;
    float afterScreenEdge = screenHeight-activeField.frame.origin.y - activeField.frame.size.height-keyboardFrameEnd.size.height - adjustingScreenEdge;
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
                         myScrollView.frame = CGRectMake(0, 0,
                                                         myScrollView.frame.size.width,
                                                         myScrollView.frame.size.height);
                     }];
    activeField = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         myScrollView.frame = CGRectMake(0, 0,
                                                         myScrollView.frame.size.width,
                                                         myScrollView.frame.size.height);
                     }];
    [textField resignFirstResponder];
    return  YES;
}


@end
