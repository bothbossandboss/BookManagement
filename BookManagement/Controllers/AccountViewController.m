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
#import <AFNetworking/AFNetworking.h>

#define KEYBOARD_THRESHOLD 10
#define ADJUSTING_SCREEN_EDGE 80
#define NAVIGATION_BAR_HEIGHT 88

@interface AccountViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
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
- (void)postJsonDataToLogIn
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = @"http://localhost:8888/cakephp/account/login";
    NSDictionary *param =@{@"method":@"account/login",
                           @"params":@{@"mail_address":self.mailAddressTextField.text,
                                       @"password":self.passwordTextField.text}
                           };
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:url
       parameters:param
          success:^(AFHTTPRequestOperation *operation,id responseObject){
              NSString *status = [responseObject objectForKey:@"status"];
              NSDictionary *data = [responseObject objectForKey:@"data"];
              if([status isEqualToString:@"ng"]){
                  //アカウントは存在するがパスワードが違う。
                  NSString *errorMessage = [responseObject objectForKey:@"error"];
                  NSLog(@"%@",errorMessage);
                  NSString *msg = @"パスワードが違います";
                  [self showAlert:msg];
              }else{
                  NSLog(@"login status:%@",status);
                  NSString *userID = [data objectForKey:@"user_id"];
                  NSString *userMail = [data objectForKey:@"mail_address"];
                  NSString *userPass = [data objectForKey:@"password"];
                  //ユーザーデフォルトにユーザーIDを保存。ユーザーデフォルトは1回目の呼び出しで初期化され、2回目以降は同じインスタンスが呼び出される。
                  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                  [userDefaults setObject:userID forKey:@"userID"];
                  [userDefaults setObject:userMail forKey:@"mail_address"];
                  [userDefaults setObject:userPass forKey:@"password"];
                  [userDefaults synchronize];
                  //mailAddressとpasswordをTextFieldの内容に更新
                  NSString *str1 = self.mailAddressTextField.text;
                  self.mailAddress = str1;
                  NSString *str2 = self.passwordTextField.text;
                  self.password = str2;
                  [self.delegate saveEditedAccountInfo:self];
                  [self dismissViewControllerAnimated:YES completion:nil];
                  NSLog(@"%@",userID);
              }
          }
          failure:^(AFHTTPRequestOperation *operation,NSError *error){
              NSLog(@"Error:%@",error);
          }];

}

- (void)saveButtonTapped
{
    //メールアドレス、パスワードが入力されてない場合、警告画面の表示のみ。
    NSString *mail = self.mailAddressTextField.text;
    NSString *pass = self.passwordTextField.text;
    if([self isEmptyString:mail] || [self isEmptyString:pass]){
        NSString *msg = @"メールアドレスとパスワードを入力してください";
        [self showAlert:msg];
        return;
    }
    
    //文字列(NSString)の比較はisEqualToString:を用いる。(==)ではだめ。
    //isEqualToString:はバイト数が違うとアウトのようです。似通ったものでもokならcompareだとか(？)
    if (![passwordTextField.text isEqualToString:confirmTextField.text]) {
        NSString *msg = @"パスワードが違います";
        [self showAlert:msg];
    }else{
        /*とりあえず新規登録*/
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *url = @"http://localhost:8888/cakephp/account/regist";
        //送信すべき情報はパラメータに格納。
        NSDictionary *param =@{@"method":@"account/regist",
                               @"params":@{@"mail_address":mail,
                                           @"password":pass}
                               };
        //apiの通り、リクエストデータはjson形式なので、パラメータをjsonへ変換。
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //パラメータを送信してデータを受けとる。
        [manager POST:url
           parameters:param
              success:^(AFHTTPRequestOperation *operation,id responseObject){
                  NSString *status = [responseObject objectForKey:@"status"];
                  NSString *errorMessage = [responseObject objectForKey:@"error"];
                  NSDictionary *data = [responseObject objectForKey:@"data"];
                  //アカウントが既にある場合。
                  if([status isEqualToString:@"ng"]){
                      NSLog(@"%@",errorMessage);
                      //ログインへ移行。
                      [self postJsonDataToLogIn];
                  }else if([self.delegate respondsToSelector:@selector(saveEditedAccountInfo:)]){
                      NSString *userID = [data objectForKey:@"user_id"];
                      NSString *userMail = [data objectForKey:@"mail_address"];
                      NSString *userPass = [data objectForKey:@"password"];
                      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                      [userDefaults setObject:userID forKey:@"userID"];
                      [userDefaults setObject:userMail forKey:@"mail_address"];
                      [userDefaults setObject:userPass forKey:@"password"];
                      [userDefaults synchronize];
                      //mailAddressとpasswordをTextFieldの内容に更新
                      NSString *str1 = self.mailAddressTextField.text;
                      self.mailAddress = str1;
                      NSString *str2 = self.passwordTextField.text;
                      self.password = str2;
                      [self.delegate saveEditedAccountInfo:self];
                      [self dismissViewControllerAnimated:YES completion:nil];
                  }
              }
              failure:^(AFHTTPRequestOperation *operation,NSError *error){
                  NSLog(@"Error:%@",error);
              }];
    }
}

- (void)cancelButtonTapped
{
    //メールアドレス、パスワードが入力されてない場合、警告画面の表示のみ。
    NSString *mail = self.mailAddressTextField.text;
    NSString *pass = self.passwordTextField.text;
    if([self isEmptyString:mail] || [self isEmptyString:pass]){
        NSString *msg = @"メールアドレスとパスワードを入力してください";
        [self showAlert:msg];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
        if(self.mailAddressTextField.isFirstResponder
           || self.passwordTextField.isFirstResponder
           || self.confirmTextField.isFirstResponder){
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
    _activeField = textField;
    return YES;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *userInfo;
    userInfo = [aNotification userInfo];
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    float screenHeight = screenBounds.size.height;
    float textFieldEdge = _activeField.frame.origin.y + _activeField.frame.size.height;
    float keyboardEdge = screenHeight-keyboardFrameEnd.size.height - KEYBOARD_THRESHOLD;
    float afterScreenEdge = screenHeight-_activeField.frame.origin.y - _activeField.frame.size.height-keyboardFrameEnd.size.height - ADJUSTING_SCREEN_EDGE;
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
    _activeField = nil;
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

- (void)showAlert:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"エラー"
                              message:message
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)isEmptyString:(NSString*)str
{
    if(str == nil || [str length] == 0){
        return true;
    }else{
        return false;
    }
}

@end
