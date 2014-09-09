//
//  PropertyViewController.h
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/05.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

@interface PropertyViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *accountSetButton;
- (void)accountSetButtonTapped;
- (void)setAccountInfo:(NSString*)firstLaunchMail label:(NSString*)firstLaunchPass;

@end