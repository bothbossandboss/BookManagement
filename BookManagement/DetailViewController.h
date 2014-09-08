//
//  DetailViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/08.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController 

@property int indexPathRow;
@property int indexPathSection;
@property (weak, nonatomic)NSString *bookName;
@property (weak, nonatomic)NSString *price;
@property (weak, nonatomic)NSString *date;
@property (weak, nonatomic)UIImage *image;

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIButton *imageSelectButton;
@property (weak, nonatomic) IBOutlet UITextField *bookNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;

@end
