//
//  GJRefreshFooter.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/18.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "GJRefreshFooter.h"

@interface GJRefreshFooter ()
@property (nonatomic, weak) UIScrollView *scrollView;
@end

@implementation GJRefreshFooter

- (void)startRefresh {
    if (self.state == GJRefreshStateLocked) return;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentInset = [self _refreshingInsets];
        self.scrollView.contentOffset = CGPointMake(0, [self _refreshThreshold] + self.pullingOffset);
    }];
}

#pragma mark- private inherit
//called when scrollView's frame did changed.
- (void)_resestRefreshView {
    [self _resetFrame];
}

- (void)_scrollView:(UIScrollView *)scrollView contentSizeDidChanged:(CGSize)contentSize {
    [self _resetFrame];
}

- (void)_resetFrame {
    CGRect originFrame = self.frame;
    originFrame.size.width = self.scrollView.bounds.size.width;
    originFrame.size.height = self.height;
    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
        originFrame.origin.y = self.scrollView.bounds.size.height;
    }
    else {
        originFrame.origin.y = self.scrollView.contentSize.height;
    }
    self.frame = originFrame;
}

- (BOOL)_isPullingOffset {
    return self.scrollView.contentOffset.y > [self _refreshThreshold] && self.scrollView.contentOffset.y < [self _refreshThreshold] + self.pullingOffset;
}

- (BOOL)_isCanRefreshOffset {
    return self.scrollView.contentOffset.y >= [self _refreshThreshold] + self.pullingOffset;
}

- (BOOL)_isNormalOffset {
    return self.scrollView.contentOffset.y <= [self _refreshThreshold];
}

- (UIEdgeInsets)_refreshingInsets {
    UIEdgeInsets insets = self.scrollView.contentInset;
    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
        insets.bottom = self.pullingOffset + self.scrollView.bounds.size.height - self.scrollView.contentSize.height;
    }
    else {
        insets.bottom = self.pullingOffset;
    }
    return insets;
}

- (void)_resetScrollViewContentInsets {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = 0;
    self.scrollView.contentInset = insets;
}

#pragma mark- private
- (BOOL)_isFullBounds {
    return self.scrollView.contentSize.height >= self.scrollView.bounds.size.height;
}

- (CGFloat)_refreshThreshold {
    if ([self _isFullBounds]) {
        return self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    return 0;
}

- (CGFloat)_currentPullingOffset {
    return self.scrollView.contentOffset.y - [self _refreshThreshold];
}
@end
