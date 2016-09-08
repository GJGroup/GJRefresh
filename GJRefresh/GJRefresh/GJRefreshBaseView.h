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

+ (instancetype)initWithRefreshingTarget:(id)target selector:(SEL)selector;

#pragma mark- actions

- (void)startRefresh;

- (void)endRefreshing;

- (void)noMoreData;

- (void)setHidden:(BOOL)hidden;

- (void)setDisabled:(BOOL)disabled;

#pragma mark- life cycle (inherit & implement)

/**
 *  called by init
 */
- (void)commonInit;

- (void)beginPullingFromState:(GJRefreshState)state;

- (void)pullingProgressDidChanged:(CGFloat)progress;

- (void)canRefresh;

/**
 *  start refreshing
 */
- (void)refreshing;

- (void)refreshComplete;

- (void)refreshCompleteAndBackToOrigin;


@end
