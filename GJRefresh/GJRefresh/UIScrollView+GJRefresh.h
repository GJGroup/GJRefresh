//
//  UIScrollView+GJRefresh.h
//  GJRefresh
//
//  Created by wangyutao on 16/8/11.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GJRefreshBaseView;

@interface UIScrollView (GJRefresh)

@property (nonatomic, strong) GJRefreshBaseView *gj_header;
@property (nonatomic, strong) GJRefreshBaseView *gj_footer;

@property (nonatomic, assign) BOOL gj_autoLock;
@end
