//
//  ViewController.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/2.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "ViewController.h"
#import "GCRefreshFooter.h"
#import "GCRefreshHeader.h"
#import "UIScrollView+GJRefresh.h"
#import "AFHTTPSessionManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"movieCell"];
    self.tableView.gj_header = [GCRefreshHeader initWithRefreshingTarget:self selector:@selector(headerRefreshing)];
    self.tableView.gj_footer = [GCRefreshFooter initWithRefreshingTarget:self selector:@selector(footerRefreshing)];
    self.tableView.gj_autoLock = YES;
}

- (void)headerRefreshing {
    [self.httpManager GET:@"http://facebook.github.io/react-native/movies.json"
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      NSArray *movies = responseObject[@"movies"];
                      self.dataList = movies.mutableCopy;
                      [self.tableView reloadData];
                      [self.tableView.gj_header endRefreshing];
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      [self.tableView.gj_header endRefreshing];
                  }];
}

- (void)footerRefreshing {
    [self.httpManager GET:@"http://facebook.github.io/react-native/movies.json"
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      NSArray *movies = responseObject[@"movies"];
                      [self.dataList addObjectsFromArray:movies];;
                      [self.tableView reloadData];
                      [self.tableView.gj_footer endRefreshing];
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      [self.tableView.gj_footer endRefreshing];
                  }];
}

- (AFHTTPSessionManager *)httpManager {
    if (!_httpManager) {
        _httpManager = [AFHTTPSessionManager manager];
    }
    return _httpManager;
}

#pragma mark- tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    NSDictionary *movie = self.dataList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",movie[@"title"],movie[@"releaseYear"]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
