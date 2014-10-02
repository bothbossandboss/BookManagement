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
#import <AFNetworking/AFNetworking.h>

#define NUM_OF_FIRST_CELL_ROW 10
#define CELL_HEIGHT 90
#define FIRST_BEGIN_PAGE 28
#define NUM_OF_PAGE 10

@interface MainTableViewController () <EditViewControllerDelegate, AddViewControllerDelegate>
{
    NSInteger numOfCellRow;
    NSMutableArray *bookIdArray;
    NSMutableArray *bookNameArray;
    NSMutableArray *priceArray;
    NSMutableArray *dateArray;
    NSMutableArray *imageArray;
}
@end

@implementation MainTableViewController

#pragma mark - data base method
- (void)getJSONDataOfBooks:(NSDictionary*)requestUser label:(NSDictionary*)requestPage
{
    NSString *url = @"http://localhost:8888/cakephp/book/get";
    //初回の読み込みかそれ以外か判断。
    NSString *isThisFirstGet = [requestPage objectForKey:@"position"];
    NSDictionary *param =@{@"method":@"book/get",
                           @"params":@{@"request_token":requestUser,
                                       @"page":requestPage
                                   }
                           };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:url
      parameters:param
         success:^(AFHTTPRequestOperation *operation,id responseObject){
             NSDictionary *data = [responseObject objectForKey:@"data"];
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             [userDefaults setObject:[data objectForKey:@"numOfBooks"] forKey:@"numOfBooks"];
             int i;
             int numOfData = (int)[data count] - 1;
             if([isThisFirstGet isEqualToString:@"latest"]){
                 numOfCellRow = numOfData;
                 for (i=0; i<numOfData; i++) {
                     NSString *str = [[NSString alloc]initWithFormat:@"array%d",i];
                     NSDictionary *array = [data objectForKey:str];
                     NSString *bookID = [array objectForKey:@"book_id"];
                     NSString *title = [array objectForKey:@"title"];
                     NSString *price = [array objectForKey:@"price"];
                     NSDate *purchaseDate = [array objectForKey:@"purchase_date"];
                     [bookIdArray replaceObjectAtIndex:i withObject:bookID];
                     [bookNameArray replaceObjectAtIndex:i withObject:title];
                     [priceArray replaceObjectAtIndex:i withObject:price];
                     [dateArray replaceObjectAtIndex:i withObject:purchaseDate];
                 }
             }else{
                 for (i=0; i<numOfData; i++) {
                     NSString *str = [[NSString alloc]initWithFormat:@"array%d",i];
                     NSDictionary *array = [data objectForKey:str];
                     NSString *bookID = [array objectForKey:@"book_id"];
                     NSString *title = [array objectForKey:@"title"];
                     NSString *price = [array objectForKey:@"price"];
                     NSDate *purchaseDate = [array objectForKey:@"purchase_date"];
                     [bookIdArray addObject:bookID];
                     [bookNameArray addObject:title];
                     [priceArray addObject:price];
                     [dateArray addObject:purchaseDate];
                     [imageArray addObject:[UIImage imageNamed:@"6fe029a2.jpg"]];
                 }
                 numOfCellRow += numOfData;
             }
             [self.tableView reloadData];
         }
         failure:^(AFHTTPRequestOperation *operation,NSError *error){
             NSLog(@"Error:%@",error);
         }];
}

- (void)registerJsonDataOfBook:(NSDictionary*)paramData label:(NSInteger)indexPathRow
{
    NSString *url = @"http://localhost:8888/cakephp/book/regist";
    NSDictionary *param =@{@"method":@"book/regist",
                           @"params":paramData
                           };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:url
       parameters:param
          success:^(AFHTTPRequestOperation *operation,id responseObject){
              NSString *status = [responseObject objectForKey:@"status"];
              if([status isEqualToString:@"ok"]){
                  NSDictionary *data = [responseObject objectForKey:@"data"];
                  NSString *bookID = [data objectForKey:@"book_id"];
                  NSLog(@"bookID %@",bookID);
                  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                  NSInteger oldNumOfBooks = [userDefaults integerForKey:@"numOfBooks"];
                  NSInteger newNumOfBooks = oldNumOfBooks + 1;
                  [userDefaults setInteger:newNumOfBooks forKey:@"numOfBooks"];
                  [userDefaults synchronize];
                  //cellの更新
                  ++numOfCellRow;
                  [bookIdArray insertObject:bookID atIndex:0];
                  [bookNameArray insertObject:[paramData objectForKey:@"book_name"] atIndex:0];
                  [priceArray insertObject:[paramData objectForKey:@"price"] atIndex:0];
                  [dateArray insertObject:[paramData objectForKey:@"purchase_date"] atIndex:0];
                  [imageArray insertObject:[UIImage imageNamed:@"pnenoimgs011.gif"]
                                   atIndex:0];
                  [self.tableView reloadData];
              }else{
                  NSString *error = [responseObject objectForKey:@"error"];
                  [self showAlertView:error];
              }
          }
          failure:^(AFHTTPRequestOperation *operation,NSError *error){
              NSLog(@"Error:%@",error);
          }];
}

- (void)updateJsonDataOfBook:(NSDictionary*)paramData
{
    NSString *url = @"http://localhost:8888/cakephp/book/update";
    NSDictionary *param = @{@"method":@"book/update",
                            @"params":paramData
                            };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:url
       parameters:param
          success:^(AFHTTPRequestOperation *operation,id responseObject){
              NSString *status = [responseObject objectForKey:@"status"];
              if([status isEqualToString:@"ok"]){
                  NSDictionary *data = [responseObject objectForKey:@"data"];
                  NSString *bookID = [data objectForKey:@"book_id"];
                  NSLog(@"bookID %@",bookID);
              }
          }
          failure:^(AFHTTPRequestOperation *operation,NSError *error){
              NSLog(@"Error:%@",error);
          }];
}

#pragma mark - the life cycle of view
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"書籍一覧";
    numOfCellRow = NUM_OF_FIRST_CELL_ROW;
    bookIdArray = [[NSMutableArray alloc]init];
    bookNameArray = [[NSMutableArray alloc]init];
    priceArray = [[NSMutableArray alloc]init];
    dateArray = [[NSMutableArray alloc]init];
    imageArray = [[NSMutableArray alloc]init];
    int i;
    for(i=0; i<numOfCellRow; i++){
        [bookIdArray insertObject:@"bookID" atIndex:i];
        [bookNameArray insertObject:@"title" atIndex:i];
        [priceArray insertObject:@"price" atIndex:i];
        [dateArray insertObject:@"purchaseDate" atIndex:i];
        [imageArray insertObject:[UIImage imageNamed:@"pnenoimgs011.gif"] atIndex:i];
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

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults objectForKey:@"userID"];
    NSString *userMail = [userDefaults objectForKey:@"mail_address"];
    NSString *userPass = [userDefaults objectForKey:@"password"];
    NSDictionary *requestUser = @{@"user_id":userID,
                                  @"mail_address":userMail,
                                  @"password":userPass
                                  };
    NSDictionary *requestPage = @{@"begin":@FIRST_BEGIN_PAGE,
                                  @"numOfPage":@NUM_OF_PAGE,
                                  @"position":@"latest"};
    [self getJSONDataOfBooks:requestUser label:requestPage];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    moreButton.frame = CGRectMake(0, 0, 320, 72);
    [moreButton setTitle:@"***もっと読み込む***" forState:UIControlStateNormal];
    [moreButton setBackgroundColor:[UIColor grayColor]];
    [moreButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(reloadMoreData) forControlEvents:UIControlEventTouchDown];
    return moreButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertView:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"エラー"
                              message:message
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
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

- (void)updateCell:(DetailTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.bookID = [bookIdArray objectAtIndex:indexPath.row];
    cell.bookNameLabel.text = [bookNameArray objectAtIndex:indexPath.row];
    cell.priceLabel.text = [priceArray objectAtIndex:indexPath.row];
    cell.dateLabel.text = [dateArray objectAtIndex:indexPath.row];
    cell.bookImageView.image = [imageArray objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cellのxibファイルを指定したことで、以下のcellがnilになることは無い。
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.bookNameLabel.adjustsFontSizeToFitWidth = YES;
    cell.priceLabel.adjustsFontSizeToFitWidth = YES;
    cell.dateLabel.adjustsFontSizeToFitWidth = YES;
    [self updateCell:cell atIndexPath:indexPath];
    return cell;
}
//cellの大きさ（高さ）の設定。
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

#pragma mark - private method
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
    EditViewController *detailViewController = [[EditViewController alloc]
                                                initWithNibName:@"DetailViewController" bundle:nil];
    //indexPathで指定したcellのデータを読み出す。この時、cellForRowAtIndexの返り値はUITableViewCellなので適宜キャストすること。
    DetailTableViewCell *cell = (DetailTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    //textField.textをセットするのではなく、NSStringのデータを渡すようにセットする。
    //set変数名で初期値をセットして画面を作成できる。
    [detailViewController setIndexPathRow:(int)indexPath.row];
    [detailViewController setIndexPathSection:(int)indexPath.section];
    [detailViewController setBookName:cell.bookNameLabel.text];
    [detailViewController setPrice:cell.priceLabel.text];
    [detailViewController setDate:cell.dateLabel.text];
    [detailViewController setImage:cell.bookImageView.image];
    detailViewController.delegate = self;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)addButtonTapped
{
    AddViewController *myAddViewController = [[AddViewController alloc]
                                              initWithNibName:@"DetailViewController" bundle:nil];
    myAddViewController.delegate = self;
    myAddViewController.indexPathRow = (int)numOfCellRow;
    myAddViewController.indexPathSection = (int)[self.tableView numberOfSections];
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:myAddViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)reloadMoreData
{
    //昔のcellを取得して表示する。
    NSLog(@"reload");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults objectForKey:@"userID"];
    NSInteger numOfBooks = [userDefaults integerForKey:@"numOfBooks"];
    NSInteger beginPageInteger = numOfBooks - numOfCellRow;
    if(beginPageInteger == 0){
        [self showAlertView:@"これ以上のデータはありません"];
    }
    NSNumber *beginPage = [NSNumber numberWithInteger:beginPageInteger];
    NSString *userMail = [userDefaults objectForKey:@"mail_address"];
    NSString *userPass = [userDefaults objectForKey:@"password"];
    NSDictionary *requestUser = @{@"user_id":userID,
                                  @"mail_address":userMail,
                                  @"password":userPass
                                  };
    NSDictionary *requestPage = @{@"begin":beginPage,
                                  @"numOfPage":@NUM_OF_PAGE,
                                  @"position":@"old"};
    [self getJSONDataOfBooks:requestUser label:requestPage];
}

#pragma mark - public method
//ボタンの実装
- (void)saveEditedData:(EditViewController*)controller
{
    //indexPathを指定してcellを呼び出す。
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:controller.indexPathRow inSection:controller.indexPathSection];
    DetailTableViewCell *cell = (DetailTableViewCell*)[self.tableView cellForRowAtIndexPath:cellIndexPath];
    //値の更新
    NSString *bookID = cell.bookID;
    cell.bookNameLabel.text = controller.bookName;
    cell.priceLabel.text = controller.price;
    cell.dateLabel.text = controller.date;
    cell.bookImageView.image = controller.image;
    [bookNameArray replaceObjectAtIndex:controller.indexPathRow withObject:controller.bookName];
    [priceArray replaceObjectAtIndex:controller.indexPathRow withObject:controller.price];
    [dateArray replaceObjectAtIndex:controller.indexPathRow withObject:controller.date];
    [imageArray replaceObjectAtIndex:controller.indexPathRow withObject:controller.image];
    //DBデータ更新
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults objectForKey:@"userID"];
    NSString *userMail = [userDefaults objectForKey:@"mail_address"];
    NSString *userPass = [userDefaults objectForKey:@"password"];
    NSDictionary *requestUser = @{@"user_id":userID,
                                  @"mail_address":userMail,
                                  @"password":userPass
                                  };
    NSDictionary *paramData =@{@"request_token":requestUser,
                               @"book_id":bookID,
                               @"book_name":cell.bookNameLabel.text,
                               @"price":cell.priceLabel.text,
                               @"purchase_date":cell.dateLabel.text,
                               @"image":@"no image"
                               };
    [self updateJsonDataOfBook:paramData];
    //controllerの解放
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAddedData:(AddViewController*)controller
{
    NSLog(@"table view back");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults objectForKey:@"userID"];
    NSString *userMail = [userDefaults objectForKey:@"mail_address"];
    NSString *userPass = [userDefaults objectForKey:@"password"];
    NSLog(@"id:%@ mail:%@ pass:%@", userID, userMail, userPass);
    NSDictionary *requestUser = @{@"user_id":userID,
                                  @"mail_address":userMail,
                                  @"password":userPass
                                  };
    //controllerが消失するタイミングが不明なので、データをコピーしとこう。
    NSLog(@"t:%@ p:%@ d:%@",controller.bookName, controller.price, controller.date);
    NSDictionary *paramData =@{@"request_token":requestUser,
                               @"book_name":controller.bookName,
                               @"price":controller.price,
                               @"purchase_date":controller.date,
                               @"image":@"no image"
                               };
    NSInteger indexPathRow = controller.indexPathRow;
    NSLog(@"%@",paramData);
    //DBにアクセスして登録すべきか判断。登録すべき場合はcell更新。
    [self registerJsonDataOfBook:paramData label:indexPathRow];
}

@end
