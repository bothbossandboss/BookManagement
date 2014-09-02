//
//  MainViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property(strong, nonatomic) UITapGestureRecognizer *singleTap;
@property(weak, nonatomic) IBOutlet UITextField *bookNameTextField;
@property(weak, nonatomic) IBOutlet UITextField *priceTextField;
@property(weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@end
