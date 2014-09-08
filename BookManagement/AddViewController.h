//
//  AddViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

//継承は、@interface ~~~ : (継承するクラス)で表す。
#import "DetailViewController.h"

@protocol AddViewControllerDelegate;

@interface AddViewController : DetailViewController <UITextFieldDelegate>

@property (weak, nonatomic) id <AddViewControllerDelegate> delegate;

@end

@protocol AddViewControllerDelegate <NSObject>
- (void)saveAddedData:(AddViewController*)controller;
@end