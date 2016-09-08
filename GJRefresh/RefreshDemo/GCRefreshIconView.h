//
//  GCRefreshIconView.h
//  FreshTest
//
//  Created by wangyutao on 15/8/4.
//  Copyright (c) 2015年 wangyutao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 状态，
 kGCRefreshIconViewStateNormal为下拉画图状态，
 kGCRefreshIconViewStateLoading为缺口动画状态
 */
typedef NS_ENUM(NSUInteger, GCRefreshIconViewState) {
    kGCRefreshIconViewStateNormal,
    kGCRefreshIconViewStateLoading,
};

@interface GCRefreshIconView : UIView

/**
 下拉动画最大inset,大于或等于此值时动画strokeEnd为1,动画完成,默认值为54
 */
@property (nonatomic, assign) CGFloat pullMaxInset;

/**
 动画开始的inset
 */
@property (nonatomic, assign) CGFloat pullStartInset;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) UIColor *pointColor;


- (void)setPersent:(CGFloat)persent;

- (void)setOffset:(CGFloat)offset;

- (void)runLoadingAnimation;

- (void)stopLoadingAnimation;

- (void)checkAnimation;

@end
