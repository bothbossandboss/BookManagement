//
//  EditViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

//循環参照を避けるため、@protocol ~;   --->  @protocol ~ <NSObject> ....@endと書く。
@protocol EditViewControllerDelegate;

@interface EditViewController : UIViewController
<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property int indexPathRow;
@property int indexPathSection;
@property(weak, nonatomic)NSString *bookName;
@property(weak, nonatomic)NSString *price;
@property(weak, nonatomic)NSString *date;
@property(weak, nonatomic)NSString *imageName;

@property(weak, nonatomic) IBOutlet UITextField *bookNameTextField;
@property(weak, nonatomic) IBOutlet UITextField *priceTextField;
@property(weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property(weak, nonatomic) IBOutlet UITextField *dateTextField;
@property(strong, nonatomic) IBOutlet UIImageView* imageView;

@property(weak, nonatomic) id<EditViewControllerDelegate> delegate;
- (void)saveButtonTapped:(id)sender;
@property(strong, nonatomic) UITapGestureRecognizer *singleTap;

@end

@protocol EditViewControllerDelegate <NSObject>
- (void)saveEditedData:(EditViewController*)controller;
@end
