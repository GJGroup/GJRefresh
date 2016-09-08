//
//  GCRefreshFotter.m
//  GJRefresh
//
//  Created by wangyutao on 16/9/8.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "GCRefreshFooter.h"
#import "GCRefreshIconView.h"
#import "Masonry.h"

@interface GCRefreshFooter ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) GCRefreshIconView *icon;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation GCRefreshFooter

- (void)commonInit {
    [super commonInit];
    
    self.contentView = [UIView new];
    [self addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.equalTo(self.mas_height);
    }];
    
    self.titleLabel = [UILabel new];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    self.icon = [[GCRefreshIconView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    self.icon.pullMaxInset = self.pullingOffset;
    [self.contentView addSubview:self.icon];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.titleLabel.mas_left).offset(-5);;
        make.width.equalTo(@30);
        make.height.equalTo(@40);
    }];
    
    self.titleLabel.text = @"上拉刷新";
}

- (void)pullingProgressDidChanged:(CGFloat)progress {
    [self.icon setPersent:progress];
}

- (void)refreshing {
    [self.icon runLoadingAnimation];
    self.titleLabel.text = @"刷新中……";
}

- (void)refreshCompleteAndBackToOrigin {
    [self.icon stopLoadingAnimation];
    self.titleLabel.text = @"下拉刷新";
}

- (void)canRefresh {
    self.titleLabel.text = @"松开即可刷新";
}

- (void)beginPullingFromState:(GJRefreshState)state {
    self.titleLabel.text = @"上拉刷新";
}


@end
