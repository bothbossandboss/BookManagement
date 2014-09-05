//
//  AddViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "AddViewController.h"

#define keyboardThreshold 50
#define adjustingScreenEdge 80

@interface AddViewController ()
{
    UITextField *activeField;
    UIDatePicker *datePicker;
}

@end

@implementation AddViewController

@synthesize myScrollView;
@synthesize bookNameTextField;
@synthesize priceTextField;
@synthesize dateTextField;
@synthesize imageView;
@synthesize indexPathRow;
@synthesize indexPathSection;
@synthesize bookName;
@synthesize price;
@synthesize date;
@synthesize imageName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myScrollView.frame = self.view.bounds;
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
    self.navigationItem.title = @"書籍追加";
    //シングルタップでキーボードを収納するための設定。
    self.singleTap = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    bookNameTextField.delegate = self;
    priceTextField.delegate = self;
    dateTextField.delegate = self;
    self.bookNameTextField.text = bookName;
    self.priceTextField.text = price;
    self.dateTextField.text = date;
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveButtonTapped
{
    if([self.delegate respondsToSelector:@selector(saveAddedData:)]){
        self.bookName = self.bookNameTextField.text;
        self.price = self.priceTextField.text;
        self.date = self.dateTextField.text;
        [self.delegate saveAddedData:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 *以下はTextFieldに関する処理
 */

//シングルタップでの挙動（キーボード表示の時）
- (void)onSingleTap:(UITapGestureRecognizer*)recognizer
{
    [self.bookNameTextField resignFirstResponder];
    [self.priceTextField resignFirstResponder];
}
//キーボードが表示されていない時は他に影響を与えないように無効化。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
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
//TextField制御
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    if(textField == dateTextField){
        datePicker = [[UIDatePicker alloc]init];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker addTarget:self action:@selector(updateTextField:)
             forControlEvents:UIControlEventValueChanged];
        dateTextField.inputView = datePicker;
        dateTextField.delegate = self;
        
        UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc]init];
        keyboardDoneButtonView.barStyle  = UIBarStyleBlack;
        keyboardDoneButtonView.translucent = YES;
        keyboardDoneButtonView.tintColor = nil;
        [keyboardDoneButtonView sizeToFit];
        
        // 完了ボタンとSpacerの配置
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完了" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerDoneTapped)];
        UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer,spacer1,doneButton,nil]];
        // Viewの配置
        textField.inputAccessoryView = keyboardDoneButtonView;
    }
    return YES;
}

- (void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy/MM/dd";
    self.dateTextField.text = [df stringFromDate:picker.date];
}

- (void)pickerDoneTapped
{
    [self.dateTextField resignFirstResponder];
    activeField = nil;
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
