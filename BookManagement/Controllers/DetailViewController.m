//
//  DetailViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/08.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

//navigationControllerとかtabControllerが入る時はScrollViewをnavigationBar、tabBarを無視して作る。
//適宜調整のこと。

#import "DetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFHTTPRequestOperationManager.h>

#define KEYBOARD_THRESHOLD 50
#define ADJUSTING_SCREEN_EDGE 80

@interface DetailViewController ()
<UITextFieldDelegate, UIGestureRecognizerDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UITextField *activeField;
    UIDatePicker *datePicker;
}
@end

@implementation DetailViewController

@synthesize indexPathRow;
@synthesize indexPathSection;
@synthesize myScrollView;
@synthesize imageView;
@synthesize imageSelectButton;
@synthesize bookNameTextField;
@synthesize priceTextField;
@synthesize dateTextField;
@synthesize image;
@synthesize bookName;
@synthesize price;
@synthesize date;

#pragma mark - the life cycle of view
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //シングルタップでキーボードを収納するための設定。
    self.myScrollView.frame = self.view.bounds;
    self.singleTap = [[UITapGestureRecognizer alloc]
                      initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    [self.imageSelectButton addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)selectImage
{
    NSLog(@"selectImage");
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        //Photo Libraryが使える時
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = selectedImage;
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self uploadImageFile:selectedImage];
    //[self imageDownload2];
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
    float keyboardEdge = screenHeight-keyboardFrameEnd.size.height - KEYBOARD_THRESHOLD;
    float afterScreenEdge = screenHeight-activeField.frame.origin.y - activeField.frame.size.height-keyboardFrameEnd.size.height - ADJUSTING_SCREEN_EDGE;
    //NSLog(@"keyboardEdge:%f afterScreenEdge:%f", keyboardEdge, afterScreenEdge);
    if(textFieldEdge > keyboardEdge){
        //NSLog(@"keyboard scroll");
        [UIView animateWithDuration:0.2
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

//画像アップロード
- (void)uploadImageFile:(UIImage*)uploadImage
{
    NSString *url = @"http://localhost:8888/cakephp/book/upload_image";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer new];
        
    NSData *testData = UIImagePNGRepresentation(uploadImage);
    NSDate *now = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%d.jpg",(int)[now timeIntervalSince1970]];
    
        //アップロード先のURLを設定したNSURLRequestインスタンスを生成する。
        NSMutableURLRequest *request =
        [manager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                        URLString:url
                                                       parameters:@{@"method":@"book/upload_image",
                                                                    @"destination":@"/Applications/MAMP/htdocs/cakephp/app/webroot/img/"}
                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                                            [formData appendPartWithFileData:testData
                                                                        name:@"Image"
                                                                    fileName:fileName
                                                                    mimeType:@"image/jpeg"];
                                        }error:NULL];        
        //アップロード処理のためのAFHTTPRequestOperationインスタンスを生成する。
        AFHTTPRequestOperation *operation =
        [manager HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation *operation,id responseObject){
                                             if([[responseObject objectForKey:@"status"] isEqualToString:@"ok"]){
                                                 NSString *str1 = @"http://localhost:8888/cakephp/app/webroot/img/";
                                                 _imagePath = [str1 stringByAppendingString:fileName];
                                                 NSLog(@"detail image path : %@",_imagePath);
                                             }else{
                                                 NSLog(@"%@", [responseObject objectForKey:@"error"]);
                                             }
                                         }
                                         failure:^(AFHTTPRequestOperation *operation,NSError *error){
                                             NSLog(@"Error:%@",error);
                                         }];
        //データを送信するたびに実行される処理を設定する。
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                            long long totalBytesWritten, long long totalByteExpectedToWrite){
            //アップロード中の進捗状況をコンソールに表示する。
            NSLog(@"bytesWritten:%@, totalBytesWritten:%@,totalBytesExpectedToWrite:%@,process:%@",
                  @(bytesWritten), @(totalBytesWritten), @(totalByteExpectedToWrite),
                  @((float)totalBytesWritten / totalByteExpectedToWrite));
        }];
        //アップロード開始
        [manager.operationQueue addOperation:operation];
}

@end
