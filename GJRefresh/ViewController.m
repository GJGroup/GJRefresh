//
//  ViewController.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/2.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "ViewController.h"
#import "GJRefreshHeader.h"
#import "GJRefreshFooter.h"
#import "UIScrollView+GJRefresh.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.gj_header = [[GJRefreshHeader alloc] init];
    self.scrollView.gj_footer = [[GJRefreshFooter alloc] init];
    self.scrollView.gj_footer.backgroundColor = [UIColor redColor];
    self.scrollView.gj_header.backgroundColor = [UIColor redColor];
    self.scrollView.autoLock = YES;
    
    self.scrollView.gj_header.pullingOffset = 80;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.scrollView addGestureRecognizer:tap];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self.scrollView.gj_header endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
