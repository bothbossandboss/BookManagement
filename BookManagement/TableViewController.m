//
//  TableViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "TableViewController.h"
#import "MainViewController.h"
#import "DetailTableViewCell.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"test";
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    //cellのxibファイルを指定しカスタマイズしたことで、以下のif文は実際はいらない。
    if(cell == nil){
        cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.bookNameLabel.adjustsFontSizeToFitWidth = YES;
    cell.priceLabel.adjustsFontSizeToFitWidth = YES;
    cell.dateLabel.adjustsFontSizeToFitWidth = YES;
    cell.bookNameLabel.text = [NSString stringWithFormat:@"row%d",indexPath.row];
    cell.priceLabel.text = [NSString stringWithFormat:@"%d円",indexPath.row*100];
    cell.dateLabel.text = [NSString stringWithFormat:@"2014/9/%d",indexPath.row+1];
    //画像を指定。
    NSString *imageName;
    srand((unsigned int)time(NULL));
    int n = rand() % 3;
    if(n == 0) imageName = @"20140805161726950.jpg";
    else if(n == 1) imageName = @"1920_1080_20100420011049652500.jpg";
    else imageName = @"6fe029a2.jpg";
    cell.bookImage.image = [UIImage imageNamed:imageName];
    return cell;
}
//cellの大きさ（高さ）の設定。
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

//cellが選択された時に呼ばれるメソッド
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //次の画面の戻るボタンのタイトルの編集はここで行う。
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"戻る";
    backItem.style = UIBarButtonSystemItemCancel;
    self.navigationItem.backBarButtonItem = backItem;
    //詳細画面の作成。
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MainViewController *detailViewController = [[MainViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end
