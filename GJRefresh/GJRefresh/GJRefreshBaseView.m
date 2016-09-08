//
//  GJRefreshBaseView.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/11.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "GJRefreshBaseView.h"
#import <objc/runtime.h>

@interface GJRefreshBaseView ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign, readwrite) GJRefreshState state;
@property (nonatomic, copy) void(^_stateChanged)(GJRefreshState state, GJRefreshState originState, GJRefreshBaseView *refreshView);
@property (nonatomic, assign) GJRefreshState lockedStateOrigin;

@end

@implementation GJRefreshBaseView

#pragma mark- init

+ (instancetype)initWithRefreshingTarget:(id)target selector:(SEL)selector {
    GJRefreshBaseView *refreshView = [[self alloc] init];
    refreshView.target = target;
    refreshView.refreshingSelector = selector;
    return refreshView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.height = 50;
    self.pullingOffset = self.height;
}

#pragma mark- life cycle

- (void)beginPullingFromState:(GJRefreshState)state {}

- (void)pullingProgressDidChanged:(CGFloat)progress {}

- (void)canRefresh {}

- (void)refreshing {}

- (void)refreshComplete {}

- (void)refreshCompleteAndBackToOrigin {}

#pragma mark- public

- (void)startRefresh {}

- (void)endRefreshing {
    if (self.state == GJRefreshStateRefreshing) {
        self.state = GJRefreshStateNormal;
        [self refreshComplete];
        [UIView animateWithDuration:0.25 animations:^{
            [self _resetScrollViewContentInsets];
        } completion:^(BOOL finished) {
            [self refreshCompleteAndBackToOrigin];
        }];
    }
}

- (void)noMoreData {}

- (void)setHidden:(BOOL)hidden {
    if (self.state == GJRefreshStateLocked) return;
    [super setHidden:hidden];
    if (hidden) {
        self.state = GJRefreshStateHidden;
        [self _resetScrollViewContentInsets];
    }
    else {
        self.state = GJRefreshStateNormal;
    }
}

- (void)setDisabled:(BOOL)disabled {
    if (self.state == GJRefreshStateLocked) return;
    if (disabled) {
        self.state = GJRefreshStateDisabled;
        [self _resetScrollViewContentInsets];
    }
    else {
        self.state = GJRefreshStateNormal;
    }
}

- (void)_lockRefreshView {
    self.lockedStateOrigin = GJRefreshStateNormal;
    
    if (self.state == GJRefreshStateHidden || self.state == GJRefreshStateDisabled)
        self.lockedStateOrigin = self.state;
    
    self.state = GJRefreshStateLocked;
}

- (void)_unlockRefreshView {
    if (self.state == GJRefreshStateLocked) {
        self.state = self.lockedStateOrigin;
    }
}

- (void)setState:(GJRefreshState)state {
    GJRefreshState originState = _state;
    _state = state;
    !self._stateChanged ? : self._stateChanged(state, originState, self);
    
    NSString *str = nil;
    switch (state) {
        case GJRefreshStateNormal:
            str = @"normal";
            break;
        case GJRefreshStatePulling:
            [self beginPullingFromState:originState];
            str = @"pulling";
            break;
        case  GJRefreshStateCanRefresh:
            [self canRefresh];
            str = @"can refresh";
            break;
        case GJRefreshStateRefreshing:
            [self _excuteRefreshingAction];
            [self refreshing];
            str = @"refreshing";
            break;
        case GJRefreshStateHidden:
            str = @"hidden";
            break;
        case GJRefreshStateNoMoreData:
            str = @"nodata";
        case GJRefreshStateLocked:
            str = [NSString stringWithFormat:@"lock %@",self];
        default:
            break;
    }
#if DEBUG
    NSLog(@"%@",str);
#endif
}

#pragma mark- KVO callback

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self _scrollView:self.scrollView contentOffsetDidChanged:self.scrollView.contentOffset];
    }
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self _scrollView:self.scrollView contentSizeDidChanged:self.scrollView.contentSize];
    }
}

- (void)_scrollView:(UIScrollView *)scrollView contentOffsetDidChanged:(CGPoint)contentOffset {
    if (self.state == GJRefreshStateLocked) return;

    if ((self.state == GJRefreshStateNormal || (self.state == GJRefreshStateCanRefresh && self.scrollView.isDragging)) &&
        [self _isPullingOffset]) {
        self.state = GJRefreshStatePulling;
    }
    else if ((self.state == GJRefreshStatePulling || self.state == GJRefreshStateNormal) && [self _isCanRefreshOffset]) {
        self.state = GJRefreshStateCanRefresh;
    }
    else if ((self.state == GJRefreshStatePulling || self.state == GJRefreshStateCanRefresh) && [self _isNormalOffset]) {
        self.state = GJRefreshStateNormal;
    }
    
    if (self.state == GJRefreshStateCanRefresh && !self.scrollView.isDragging) {
        self.state = GJRefreshStateRefreshing;
        self.scrollView.contentInset = [self _refreshingInsets];
        self.scrollView.contentOffset = contentOffset;
    }
    
    if (self.state == GJRefreshStatePulling || self.state == GJRefreshStateCanRefresh || self.state == GJRefreshStateNormal) {
        if (self.state == GJRefreshStateCanRefresh && self.pullingProgress == 1.0) return;
        if (self.state == GJRefreshStateNormal && self.pullingProgress == 0) return;
        self.pullingProgress = fmin(fabs([self _currentPullingOffset] / self.pullingOffset),1);
        [self pullingProgressDidChanged:self.pullingProgress];
    }
}

- (void)_scrollView:(UIScrollView *)scrollView contentSizeDidChanged:(CGSize)contentSize {}

#pragma mark- private except for UIScrollView+GJRefresh
- (void)_addRefreshViewToScrollView:(UIScrollView *)scrollView {
    if (self.scrollView == scrollView) return;
    self.scrollView = scrollView;
    if (!scrollView) return;
    [scrollView addSubview:self];
    [scrollView addObserver:self
                 forKeyPath:@"contentOffset"
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:nil];
    [scrollView addObserver:self
                 forKeyPath:@"contentSize"
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:nil];
    
    [self _resestRefreshView];
}

- (void)layoutSubviews {
    [self _resestRefreshView];
    [super layoutSubviews];
}
- (void)_removeRefreshView {
    if (self.superview) {
        [self removeFromSuperview];
    }
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark- private inherit
- (void)_resestRefreshView {
    CGRect frame = CGRectMake(0, - self.height, self.scrollView.bounds.size.width, self.height);
    self.frame = frame;
}

- (BOOL)_isPullingOffset {
    return NO;
}

- (BOOL)_isCanRefreshOffset {
    return NO;
}

- (BOOL)_isNormalOffset {
    return NO;
}

- (UIEdgeInsets)_refreshingInsets {
    return UIEdgeInsetsZero;
}

- (void)_resetScrollViewContentInsets {}

- (CGFloat)_currentPullingOffset{
    return self.scrollView.contentOffset.y;
}

#pragma mark- private
- (void)_excuteRefreshingAction {
    !self.refreshingBlock ? : self.refreshingBlock();
    if (!self.target || !self.refreshingSelector) return;
    if ([self.target respondsToSelector:self.refreshingSelector]) {
        IMP imp = [self.target methodForSelector:self.refreshingSelector];
        void (*func)(id, SEL) = (void *)imp;
        func(self.target, self.refreshingSelector);
    }
}
@end
