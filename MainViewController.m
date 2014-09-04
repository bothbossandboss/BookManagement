//
//  MainViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
{
    UITextField *activeField;
    UIDatePicker *datePicker;
}

@end

@implementation MainViewController

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

#define imageViewX 20
#define imageViewY 20
#define imageViewWidth 140
#define imageViewHeight 140

- (void)viewDidLoad
{
    [super viewDidLoad];
    _myScrollView.frame = self.view.bounds;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"保存"
                   style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(saveButtonTapped:)
                   ];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.title = @"書籍編集";
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

- (void)saveButtonTapped:(id)sender{
    //詳細画面において、保存ボタンを押すと実行されるべき事柄
    //書籍名、金額、日付データを取得し、前のTable画面へデータを渡す。
    //値の更新
    if([self.delegate respondsToSelector:@selector(saveEditedData:)]){
        self.bookName = self.bookNameTextField.text;
        self.price = self.priceTextField.text;
        self.date = self.dateTextField.text;
        NSLog(@"indexPath%d bookName%@ price%@ date%@ imageName%@"
              ,self.indexPathRow,self.bookName,self.price,self.date,self.imageName);
        [self.delegate saveEditedData:self];
    }
}







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
    float keyboardEdge = screenHeight-keyboardFrameEnd.size.height - 30;
    float afterScreenEdge = screenHeight-activeField.frame.origin.y - activeField.frame.size.height-keyboardFrameEnd.size.height - 80;
    if(textFieldEdge > keyboardEdge){
        [UIView animateWithDuration:0.3
                     animations:^{
                         _myScrollView.frame = CGRectMake(0, afterScreenEdge, _myScrollView.frame.size.width, _myScrollView.frame.size.height);
                     }];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _myScrollView.frame = CGRectMake(0, 0,
                                                          _myScrollView.frame.size.width,
                                                          _myScrollView.frame.size.height);
                     }];
    activeField = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
