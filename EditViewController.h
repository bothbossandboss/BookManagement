//
//  EditViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

//循環参照を避けるため、@protocol ~;   --->  @protocol ~ <NSObject> ....@endと書く。
#import "DetailViewController.h"

@protocol EditViewControllerDelegate;

@interface EditViewController : DetailViewController <UITextFieldDelegate>

@property (weak, nonatomic) id<EditViewControllerDelegate> delegate;

@end

@protocol EditViewControllerDelegate <NSObject>
- (void)saveEditedData:(EditViewController*)controller;
@end
