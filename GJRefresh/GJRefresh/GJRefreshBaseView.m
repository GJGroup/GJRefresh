//
//  GJRefreshBaseView.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/11.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "GJRefreshBaseView.h"

@interface GJRefreshBaseView ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign, readwrite) GJRefreshState state;
@property (nonatomic, copy) void(^_stateChanged)(GJRefreshState state, GJRefreshState originState, GJRefreshBaseView *refreshView);
@property (nonatomic, assign) GJRefreshState lockedStateOrigin;

@end

@implementation GJRefreshBaseView

#pragma mark- init

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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor yellowColor];
}

#pragma mark- life cycle

- (void)beginPullingFromState:(GJRefreshState)state {}

- (void)pullingProgressHasChanged:(CGFloat)progress {NSLog(@"%@",@(progress));}

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

    NSLog(@"%@",str);
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

    if ((self.state == GJRefreshStateNormal || self.state == GJRefreshStateCanRefresh) && [self _isPullingOffset]) {
        self.state = GJRefreshStatePulling;
    }
    else if ((self.state == GJRefreshStatePulling || self.state == GJRefreshStateNormal) && [self _isCanRefreshOffset]) {
        self.state = GJRefreshStateCanRefresh;
    }
    else if ((self.state == GJRefreshStatePulling || self.state == GJRefreshStateCanRefresh) && [self _isNormalOffset]) {
        self.pullingProgress =  fmin(fabs([self _currentPullingOffset] / self.pullingOffset),1);
        [self pullingProgressHasChanged:self.pullingProgress];
        self.state = GJRefreshStateNormal;
    }
    
    if (self.state == GJRefreshStateCanRefresh && !self.scrollView.isDragging) {
        self.state = GJRefreshStateRefreshing;
        self.scrollView.contentInset = [self _refreshingInsets];
        self.scrollView.contentOffset = contentOffset;
    }
    
    if (self.state == GJRefreshStatePulling ||
        self.state == GJRefreshStateCanRefresh) {
        self.pullingProgress =  fmin(fabs([self _currentPullingOffset] / self.pullingOffset),1);
        [self pullingProgressHasChanged:self.pullingProgress];
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
    
    [self _addConstraintsToScrollView];
}

- (void)_removeRefreshView {
    if (self.superview) {
        [self removeFromSuperview];
    }
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark- private inherit
- (void)_addConstraintsToScrollView {

    NSLayoutConstraint *layoutWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *layoutHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.height];
    NSLayoutConstraint *layoutLeft = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *layoutRight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *layoutVertical
    = [NSLayoutConstraint constraintWithItem:self
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:self.scrollView
                                   attribute:NSLayoutAttributeTop
                                  multiplier:1.0
                                    constant:0];
    [self.scrollView addConstraints:@[layoutWidth,layoutHeight,layoutLeft,layoutRight,layoutVertical]];
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
@end
