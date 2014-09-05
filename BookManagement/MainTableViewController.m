//
//  MainTableViewController.m
//  BookManagement
//
//  Created by 大杉康仁 on 2014/09/02.
//  Copyright (c) 2014年 ___YOhsugi___. All rights reserved.
//

#import "MainTableViewController.h"
#import "EditViewController.h"
#import "DetailTableViewCell.h"
#import "AddViewController.h"

#define numOfFirstCellRow 10
#define cellHeight 90

@interface MainTableViewController () <EditViewControllerDelegate, AddViewControllerDelegate>
{
    NSInteger numOfCellRow;
    NSMutableArray *bookNameArray;
    NSMutableArray *priceArray;
    NSMutableArray *dateArray;
    NSMutableArray *imageNameArray;
}

@end

@implementation MainTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"書籍一覧";
    numOfCellRow = numOfFirstCellRow;
    bookNameArray = [[NSMutableArray alloc]init];
    priceArray = [[NSMutableArray alloc]init];
    dateArray = [[NSMutableArray alloc]init];
    imageNameArray = [[NSMutableArray alloc]init];
    int i;
    for(i=0;i<numOfFirstCellRow;i++){
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"row%d",i];
        [bookNameArray insertObject:str atIndex:i];
        str = [[NSMutableString alloc] initWithFormat:@"%d円",i*100];
        [priceArray insertObject:str atIndex:i];
        str = [[NSMutableString alloc] initWithFormat:@"2014/9/%d",i];
        [dateArray insertObject:str atIndex:i];
        NSString *randomImage;
        srand((unsigned int)time(NULL));
        int n = rand() % 3;
        if(n == 0) randomImage = @"20140805161726950.jpg";
        else if(n == 1) randomImage = @"1920_1080_20100420011049652500.jpg";
        else randomImage = @"6fe029a2.jpg";
        [imageNameArray insertObject:randomImage atIndex:i];
    }
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"追加"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(addButtonTapped)
                                   ];
    self.navigationItem.rightBarButtonItem = addButton;    
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  numOfCellRow;
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
    cell.bookNameLabel.text = [bookNameArray objectAtIndex:indexPath.row];
    cell.priceLabel.text = [priceArray objectAtIndex:indexPath.row];
    cell.dateLabel.text = [dateArray objectAtIndex:indexPath.row];
    cell.bookImageView.image = [UIImage imageNamed:[imageNameArray objectAtIndex:indexPath.row]];
    return cell;
}
//cellの大きさ（高さ）の設定。
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
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
    EditViewController *detailViewController = [[EditViewController alloc] init];
    //indexPathで指定したcellのデータを読み出す。この時、cellForRowAtIndexの返り値はUITableViewCellなので適宜キャストすること。
    DetailTableViewCell *cell = (DetailTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    //textField.textをセットするのではなく、NSStringのデータを渡すようにセットする。
    //set変数名で初期値をセットして画面を作成できる。
    [detailViewController setIndexPathRow:indexPath.row];
    [detailViewController setIndexPathSection:indexPath.section];
    [detailViewController setBookName:cell.bookNameLabel.text];
    [detailViewController setPrice:cell.priceLabel.text];
    [detailViewController setDate:cell.dateLabel.text];
    [detailViewController setImageName:[imageNameArray objectAtIndex:indexPath.row]];
    detailViewController.delegate = self;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)detailData:(NSMutableArray*)detailDataArray
{
    //[detailDataArray replaceObjectAtIndex:0 withObject:]
}

//ボタンの実装
- (void)saveEditedData:(EditViewController*)controller
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

- (void)addButtonTapped
{
    //xibファイルを使い回して同じような画面を作るときは、xibファイルのcustom classをUIViewにして関連づけを断つ。
    AddViewController *myAddViewController = [[AddViewController alloc]
                                              initWithNibName:@"EditViewController" bundle:nil];
    myAddViewController.delegate = self;
    myAddViewController.indexPathRow = numOfCellRow;
    myAddViewController.indexPathSection = [self.tableView numberOfSections];
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:myAddViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)saveAddedData:(AddViewController *)controller
{
    //cellの追加は、配列に要素を追加してreloadすればいいみたい。insertは働かなかった。
    ++numOfCellRow;
    [bookNameArray insertObject:controller.bookName atIndex:controller.indexPathRow];
    [priceArray insertObject:controller.price atIndex:controller.indexPathRow];
    [dateArray insertObject:controller.date atIndex:controller.indexPathRow];
    //[imageNameArray insertObject:controller.imageName atIndex:controller.indexPathRow];
    [imageNameArray insertObject:@"20140805161726950.jpg" atIndex:controller.indexPathRow];
    [self.tableView reloadData];
}



@end
