//
//  AddViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddViewControllerDelegate;

@interface AddViewController : UIViewController
<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property int indexPathRow;
@property int indexPathSection;
@property (weak, nonatomic)NSString *bookName;
@property (weak, nonatomic)NSString *price;
@property (weak, nonatomic)NSString *date;
@property (weak, nonatomic)NSString *imageName;

@property (weak, nonatomic) UITextField *bookNameTextField;
@property (weak, nonatomic) UITextField *priceTextField;
@property (weak, nonatomic) UIScrollView *myScrollView;
@property (weak, nonatomic) UITextField *dateTextField;
@property (strong, nonatomic) UIImageView* imageView;

@property (weak, nonatomic) id <AddViewControllerDelegate> delegate;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;

@end

@protocol AddViewControllerDelegate <NSObject>
- (void)saveAddedData:(AddViewController*)controller;
@end