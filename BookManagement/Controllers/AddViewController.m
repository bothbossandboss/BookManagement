//
//  AddViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "AddViewController.h"

@implementation AddViewController

#pragma mark - the life cycle of view
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.bookNameTextField.delegate = self;
    self.priceTextField.delegate = self;
    self.dateTextField.delegate = self;
    self.bookNameTextField.text = self.bookName;
    self.priceTextField.text = self.price;
    self.dateTextField.text = self.date;
    self.imageView.image = [UIImage imageNamed:@"pnenoimgs011.gif"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)saveButtonTapped
{
    if([self.delegate respondsToSelector:@selector(saveAddedData:)]){
        NSString *str1 = self.bookNameTextField.text;
        self.bookName = str1;
        NSString *str2 = self.priceTextField.text;
        self.price = str2;
        NSString *str3 = self.dateTextField.text;
        self.date = str3;
        self.image = self.imageView.image;
        [self.delegate saveAddedData:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
