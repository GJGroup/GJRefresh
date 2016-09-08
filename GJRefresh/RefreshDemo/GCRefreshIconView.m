//
//  GCRefreshIconView.m
//  FreshTest
//
//  Created by wangyutao on 15/8/4.
//  Copyright (c) 2015年 wangyutao. All rights reserved.
//

#import "GCRefreshIconView.h"

static NSString *animationKey = @"runAround";

@interface GCRefreshIconView (){
    
    CAShapeLayer *_shapeLayer;
    CGMutablePathRef *_path;
    CALayer *_pointLayer;
    
}

@property (nonatomic, assign) GCRefreshIconViewState freshState;


@end

@implementation GCRefreshIconView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.pullMaxInset = 54.0;
        self.pullStartInset = 30.0;

        _shapeLayer = [CAShapeLayer layer];
        
        CGMutablePathRef path = [self iconDrawPath];
        
        _shapeLayer.path = path;
        
        [self.layer addSublayer:_shapeLayer];
        
        _pointLayer = [CALayer layer];
        _pointLayer.frame = CGRectMake(MAXFLOAT, MAXFLOAT, 2.5 , 2.5);
        _pointLayer.backgroundColor = [UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1].CGColor;
        [self.layer addSublayer:_pointLayer];
        
        _shapeLayer.strokeColor = [UIColor colorWithRed:252.0/255 green:104.0/255 blue:79.0/255 alpha:1].CGColor;
        _shapeLayer.lineWidth = 1.5;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
//        _shapeLayer.lineCap = kCALineCapRound;
//        _shapeLayer.lineJoin = kCALineJoinRound;
        _shapeLayer.frame = self.bounds;
        _shapeLayer.strokeEnd = .0;
        _shapeLayer.speed = 64.0;

//        CABasicAnimation *writeText = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        writeText.fromValue = @0;
//        writeText.toValue = @1;
//        writeText.duration = 1.0;
//        [_shapeLayer addAnimation:writeText forKey:@"write"];
//        
//        _shapeLayer.timeOffset = 1;
        
        CGPathRelease(path);
    }
    
    return self;
}

- (CGMutablePathRef)iconDrawPath{
    
    CGFloat scale = 1.5;
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height /2);

    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat float1 = 7.5 * scale;
    CGFloat float2 = 5.8 * scale;
    CGFloat float3 = 3.8 * scale;
    CGFloat float4 = 7 * scale;
    CGFloat float5 = 2 * scale;
    CGFloat float6 = 3.12 * scale;
    CGFloat float7 = 4.8 * scale;
    
    CGPoint startPoint = CGPointMake(center.x, center.y + float1);
    
    CGPoint point1 = CGPointMake(center.x - float2, center.y - float3);
    
    CGPoint point2 = CGPointMake(center.x, center.y - float1);
    
    CGPoint point3 = CGPointMake(center.x + float2, center.y - float3);
    
    CGPoint controll1 = CGPointMake(center.x - float4, center.y + float6);
    
    CGPoint controll2 = CGPointMake(center.x - float5, center.y - float7);
    
    CGPoint controll3 = CGPointMake(center.x + float5, center.y - float7);
    
    CGPoint controll4 = CGPointMake(center.x + float4, center.y + float6);
    
    
    CGPathMoveToPoint(path, NULL, startPoint.x , startPoint.y );
    
    
    CGPathAddQuadCurveToPoint(path, NULL, controll1.x,  controll1.y , point1.x, point1.y);
    
    CGPathAddQuadCurveToPoint(path, NULL, controll2.x,  controll2.y , point2.x - 1.1 , point2.y);
    
    CGPathAddLineToPoint(path, NULL, point2.x + 1.1, point2.y);
    
    CGPathAddQuadCurveToPoint(path, NULL, controll3.x,  controll3.y, point3.x , point3.y);
    
    CGPathAddQuadCurveToPoint(path, NULL, controll4.x,  controll4.y, startPoint.x, startPoint.y);
    
    return  path ;
}

#pragma mark - setter


- (void)setPointColor:(UIColor *)pointColor{
    _pointColor = pointColor;
    _pointLayer.backgroundColor = pointColor.CGColor;
}

- (void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    _shapeLayer.strokeColor = lineColor.CGColor;
}

- (void)setFreshState:(GCRefreshIconViewState)freshState{
    
    if (_freshState == freshState) {
        return;
    }
    
    _freshState = freshState;
    
    if (_freshState == kGCRefreshIconViewStateLoading) {
        [self runPointLayerAnimation];
    }
    else{
        _shapeLayer.strokeEnd = 1;
        [_pointLayer removeAnimationForKey:animationKey];
    }
    
}

- (void)runPointLayerAnimation{
    _shapeLayer.strokeEnd = 1;
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = _shapeLayer.path;
    pathAnimation.duration = 1.5;
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.repeatCount = MAXFLOAT;
    [_pointLayer addAnimation:pathAnimation forKey:animationKey];

}

#pragma mark - public method
- (void)runLoadingAnimation{
    self.freshState = kGCRefreshIconViewStateLoading;
}

- (void)stopLoadingAnimation{
    self.freshState = kGCRefreshIconViewStateNormal;
}

- (void)setPersent:(CGFloat)persent{
    if (self.freshState == kGCRefreshIconViewStateNormal) {
        _shapeLayer.strokeEnd = MIN(persent, 1);
    }
}

- (void)setOffset:(CGFloat)offset{
    
    if (self.freshState == kGCRefreshIconViewStateNormal) {
        
        CGFloat animateOffset = offset - self.pullStartInset;
        CGFloat timeOffset = MIN(animateOffset / (self.pullMaxInset - self.pullStartInset) , 1);
        timeOffset = MAX(timeOffset, 0);
        _shapeLayer.strokeEnd = timeOffset ;
    }

}

#pragma mark- notification method

- (void)checkAnimation{
    
    if (self.freshState == kGCRefreshIconViewStateLoading && self.window) {
        if ([_pointLayer animationKeys] == 0) {
            [self runPointLayerAnimation];
        }
    }
}

#pragma mark - deprecated method

void YRDPathAddArc(CGMutablePathRef path,
                   const CGAffineTransform *matrix,
                   CGRect rect,
                   CGFloat startAngle,
                   CGFloat delta){
    
    
    if (rect.size.width != rect.size.height) {
        return;
    }
    
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width /2 ,
                                 rect.origin.y + rect.size.height / 2);
    
    CGPathAddRelativeArc(path, matrix, center.x, center.y, rect.size.width / 2, startAngle, delta);

}


@end
