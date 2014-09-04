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

#define cellImageViewX 20
#define cellImageViewY 10
#define cellImageWidth 80
#define cellImageHeight 80


@interface TableViewController () <MainViewControllerDelegate>

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    srand((unsigned int)time(NULL));
    int n = rand() % 3;
    if(n == 0) cell.bookImageName = @"20140805161726950.jpg";
    else if(n == 1) cell.bookImageName = @"1920_1080_20100420011049652500.jpg";
    else cell.bookImageName = @"6fe029a2.jpg";
    cell.bookImageView.image = [UIImage imageNamed:cell.bookImageName];
    return cell;
}
//cellの大きさ（高さ）の設定。
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    //indexPathで指定したcellのデータを読み出す。この時、cellForRowAtIndexの返り値はUITableViewCellなので適宜キャストすること。
    DetailTableViewCell *cell = (DetailTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    //textField.textをセットするのではなく、NSStringのデータを渡すようにセットする。
    //set変数名で初期値をセットして画面を作成できる。
    [detailViewController setIndexPathRow:indexPath.row];
    [detailViewController setIndexPathSection:indexPath.section];
    [detailViewController setBookName:cell.bookNameLabel.text];
    [detailViewController setPrice:cell.priceLabel.text];
    [detailViewController setDate:cell.dateLabel.text];
    [detailViewController setImageName:cell.bookImageName];
    detailViewController.delegate = self;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)detailData:(NSMutableArray*)detailDataArray
{
    //[detailDataArray replaceObjectAtIndex:0 withObject:]
}

- (void)saveEditedData:(MainViewController*)controller
{
    //indexPathを指定してcellを呼び出す。
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:controller.indexPathRow inSection:controller.indexPathSection];
    DetailTableViewCell *cell = (DetailTableViewCell*)[self.tableView cellForRowAtIndexPath:cellIndexPath];
    //値の更新
    cell.bookNameLabel.text = controller.bookName;
    cell.priceLabel.text = controller.price;
    cell.dateLabel.text = controller.date;
    cell.bookImageView.image = [UIImage imageNamed:controller.imageName];
    //controllerの解放
    [self.navigationController popViewControllerAnimated:YES];
}






@end
