//
//  EditViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

//継承用のファイルとxib作っても、xibはinitWithNibNameで追加して初期化しなきゃいけない。
//xibファイルを使い回して同じような画面を作るときは、xibファイルのcustom classをUIViewにして関連づけを断つ。

#import "EditViewController.h"

@implementation EditViewController

#pragma mark - the life cycle of view
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                   initWithTitle:@"保存"
                   style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(saveButtonTapped:)
                   ];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.title = @"書籍編集";
    self.bookNameTextField.delegate = self;
    self.priceTextField.delegate = self;
    self.dateTextField.delegate = self;
    self.bookNameTextField.text = self.bookName;
    self.priceTextField.text = self.price;
    self.dateTextField.text = self.date;
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)saveButtonTapped:(id)sender
{
    //詳細画面において、保存ボタンを押すと実行されるべき事柄
    //書籍名、金額、日付データを取得し、前のTable画面へデータを渡す。
    if([self.delegate respondsToSelector:@selector(saveEditedData:)]){
        self.bookName = self.bookNameTextField.text;
        self.price = self.priceTextField.text;
        self.date = self.dateTextField.text;
        self.image = self.imageView.image;
        NSLog(@"indexPath%d bookName%@ price%@ date%@",self.indexPathRow,self.bookName,self.price,self.date);
        [self.delegate saveEditedData:self];
    }
}

@end
