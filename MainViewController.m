//
//  MainViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController (){
    UITextField *activeField;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _myScrollView.frame = self.view.bounds;
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"保存"
                   style:UIBarButtonItemStyleBordered
                   target:self
                   action:@selector(nextWindowCreate:)
                   ];
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.title = @"書籍編集";
    //シングルタップでキーボードを収納するための設定。
    self.singleTap = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    _bookNameTextField.delegate = self;
    _priceTextField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//シングルタップでの挙動（キーボード表示の時）
-(void)onSingleTap:(UITapGestureRecognizer*)recognizer{
    [self.bookNameTextField resignFirstResponder];
    [self.priceTextField resignFirstResponder];
}
//キーボードが表示されていない時は他に影響を与えないように無効化。
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(gestureRecognizer == self.singleTap){
        //キーボード表示中
        if(self.bookNameTextField.isFirstResponder == YES
           || self.priceTextField.isFirstResponder == YES){
            return YES;
        }else{
            return NO;
        }
    }
    return  YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    activeField = textField;
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
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

-(void)keyboardWasShown:(NSNotification*)aNotification{
    NSDictionary *userInfo;
    userInfo = [aNotification userInfo];
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    float screenHeight = screenBounds.size.height;
    float textFieldEdge = activeField.frame.origin.y + activeField.frame.size.height;
    float keyboardEdge = screenHeight-keyboardFrameEnd.size.height - 30;
    float afterScreenEdge = screenHeight-activeField.frame.origin.y - activeField.frame.size.height-keyboardFrameEnd.size.height - 80;
    if(textFieldEdge > keyboardEdge){
        [UIView animateWithDuration:0.3
                     animations:^{
                         _myScrollView.frame = CGRectMake(0, afterScreenEdge, _myScrollView.frame.size.width, _myScrollView.frame.size.height);
                     }];
    }
}

-(void)keyboardWillBeHidden:(NSNotification*)aNotification{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _myScrollView.frame = CGRectMake(0, 0,
                                                          _myScrollView.frame.size.width,
                                                          _myScrollView.frame.size.height);
                     }];
    activeField = nil;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _myScrollView.frame = CGRectMake(0, 0,
                                                          _myScrollView.frame.size.width,
                                                          _myScrollView.frame.size.height);
                     }];
    [textField resignFirstResponder];
    return  YES;
}


@end
