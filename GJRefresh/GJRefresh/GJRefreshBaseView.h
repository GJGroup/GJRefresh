//
//  GJRefreshBaseView.h
//  GJRefresh
//
//  Created by wangyutao on 16/8/11.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GJRefreshState) {
    GJRefreshStateNormal, 
    GJRefreshStatePulling,
    GJRefreshStateCanRefresh,
    GJRefreshStateRefreshing,
    GJRefreshStateNoMoreData,
    GJRefreshStateHidden,
    GJRefreshStateDisabled,
    GJRefreshStateLocked
};

@interface GJRefreshBaseView : UIView

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat pullingOffset;

@property (nonatomic, assign, readonly) GJRefreshState state;

@property (nonatomic, assign) CGFloat pullingProgress;

#pragma mark- call back

@property (nonatomic, weak) id target;

@property (nonatomic, assign) SEL refreshingSelector;

@property (nonatomic, copy) void(^refreshingBlock)(void);

#pragma mark- actions

- (void)startRefresh;

- (void)endRefreshing;

- (void)noMoreData;

- (void)setHidden:(BOOL)hidden;

- (void)setDisabled:(BOOL)disabled;

#pragma mark- life cycle

- (void)commonInit;

- (void)beginPullingFromState:(GJRefreshState)state;

- (void)pullingProgressHasChanged:(CGFloat)progress;

- (void)canRefresh;

- (void)refreshing;

- (void)refreshComplete;

- (void)refreshCompleteAndBackToOrigin;


@end
