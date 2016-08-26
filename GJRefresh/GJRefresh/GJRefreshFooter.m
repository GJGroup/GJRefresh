//
//  GJRefreshFooter.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/18.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "GJRefreshFooter.h"

@interface GJRefreshFooter ()
@property (nonatomic, weak) NSLayoutConstraint * layoutVertical;
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

- (void)_addConstraintsToScrollView {
    NSLayoutConstraint *layoutWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *layoutHeight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.height];
    NSLayoutConstraint *layoutLeft = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *layoutRight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    self.layoutVertical = [NSLayoutConstraint constraintWithItem:self
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.scrollView
                                                       attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                        constant:0];
    
    [self.scrollView addConstraints:@[layoutWidth,layoutHeight,layoutLeft,layoutRight,self.layoutVertical]];
}

- (void)_scrollView:(UIScrollView *)scrollView contentSizeDidChanged:(CGSize)contentSize {
    
    if (contentSize.height < self.scrollView.bounds.size.height) {
        self.layoutVertical.constant = self.scrollView.bounds.size.height - contentSize.height;
    }
    else {
        self.layoutVertical.constant = 0;
    }
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
    insets.bottom = self.pullingOffset;
    return insets;}

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
