//
//  GJRefreshHeader.m
//  GJRefresh
//
//  Created by wangyutao on 16/8/18.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import "GJRefreshHeader.h"

@interface GJRefreshHeader ()
@property (nonatomic, weak) UIScrollView *scrollView;
@end

@implementation GJRefreshHeader

- (void)startRefresh {
    if (self.state == GJRefreshStateLocked) return;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentInset = [self _refreshingInsets];
        self.scrollView.contentOffset = CGPointMake(0, - self.pullingOffset);
    }];
}

- (BOOL)_isPullingOffset {
    return self.scrollView.contentOffset.y < 0 && self.scrollView.contentOffset.y > -self.pullingOffset;
}

- (BOOL)_isCanRefreshOffset {
    return self.scrollView.contentOffset.y <= -self.pullingOffset;
}

- (BOOL)_isNormalOffset {
    return self.scrollView.contentOffset.y >= 0;
}

- (UIEdgeInsets)_refreshingInsets {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = self.pullingOffset;
    return insets;
}

- (void)_resetScrollViewContentInsets {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = 0;
    self.scrollView.contentInset = insets;
}


@end
