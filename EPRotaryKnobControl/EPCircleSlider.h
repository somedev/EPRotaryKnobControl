//
//  EPCircleSlider.h
//  SimpleCircleSlider
//
//  Created by Ed on 30.08.13.
//  Copyright (c) 2013 Eduard Panasiuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface EPCircleSlider : UIControl

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) NSInteger dotsCount;
@property (nonatomic, copy) void (^updateBlock)(CGFloat value);
@property (nonatomic, strong) UIColor * circleColor;
@property (nonatomic, strong) UIColor * handleAndDotsColor;
@end
