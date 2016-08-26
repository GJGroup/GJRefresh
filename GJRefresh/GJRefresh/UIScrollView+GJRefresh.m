//
//  UIScrollView+GJRefresh.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/11.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "UIScrollView+GJRefresh.h"
#import "GJRefreshBaseView.h"
#import <objc/runtime.h>

@interface GJRefreshBaseView ()
- (void)_addRefreshViewToScrollView:(UIScrollView *)scrollView;
- (void)_removeRefreshView;
- (void)_lockRefreshView;
- (void)_unlockRefreshView;
@property (nonatomic, copy) void(^_stateChanged)(GJRefreshState state, GJRefreshState originState, GJRefreshBaseView *refreshView);
@end

@implementation UIScrollView (GJRefresh)

- (void)setGj_header:(GJRefreshBaseView *)gj_header {
    GJRefreshBaseView *originRefreshView = [self gj_header];
    [originRefreshView _removeRefreshView];
    objc_setAssociatedObject(self, @selector(gj_header), gj_header, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [gj_header _addRefreshViewToScrollView:self];
    [self _setChangeStateBlock:gj_header];
}

- (GJRefreshBaseView *)gj_header {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setGj_footer:(GJRefreshBaseView *)gj_footer {
    GJRefreshBaseView *originRefreshView = [self gj_footer];
    [originRefreshView _removeRefreshView];
    objc_setAssociatedObject(self, @selector(gj_footer), gj_footer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [gj_footer _addRefreshViewToScrollView:self];
    [self _setChangeStateBlock:gj_footer];
}

- (GJRefreshBaseView *)gj_footer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAutoLock:(BOOL)autoLock {
    objc_setAssociatedObject(self, @selector(autoLock), @(autoLock), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)autoLock {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
} 

- (void)_setChangeStateBlock:(GJRefreshBaseView *)refreshView {
    __weak typeof(self) weakSelf = self;
    refreshView._stateChanged = ^(GJRefreshState state, GJRefreshState originState, GJRefreshBaseView *refreshView) {
        if (!weakSelf.autoLock) return;
        
        if (state == GJRefreshStateRefreshing) {
            if (refreshView == [weakSelf gj_footer]) [[weakSelf gj_header] _lockRefreshView];
            else [[weakSelf gj_footer] _lockRefreshView];
        }
        if (originState == GJRefreshStateRefreshing && state == GJRefreshStateNormal) {
            if (refreshView == [weakSelf gj_footer]) [[weakSelf gj_header] _unlockRefreshView];
            else [[weakSelf gj_footer] _unlockRefreshView];
        }
    };
}

@end
