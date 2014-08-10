//
//  EPRotaryKnobControl.m
//  SimpleCircleSlider
//
//  Copyright (c) 2013 Eduard Panasiuk
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "EPRotaryKnobControl.h"

//dot diameter
static const CGFloat kDotDiameterRatio = 0.02f;

//circle diameter
static const CGFloat kCircleDiameterRatio = 0.85f;

//handle diameter
static const CGFloat kHandleDiameterRatio = 0.08f;

//handle position diameter
static const CGFloat kHandlePositionRatio = 0.7f;

//handle moving cut off
static const double kHandleCutOffAngleRadians =  M_PI_2;
static const double kHandleMinAngleRadians =  (3 * M_PI / 2 - kHandleCutOffAngleRadians / 2);
static const double kHandleMaxAngleRadians =  (3 * M_PI / 2 + kHandleCutOffAngleRadians / 2);
static const double kHandleScaleRadians =  (kHandleMinAngleRadians + 2 * M_PI - kHandleMaxAngleRadians);

@interface EPRotaryKnobControl ()

@property (nonatomic, strong) CAShapeLayer *handleLayer;
@property (nonatomic, strong) CALayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *dotsLayer;
@property (nonatomic, assign) double currentAngleRadians;
@property (nonatomic, assign) double previousAngleRadians;
@property (nonatomic, strong) NSMutableArray *dotsPositions;

@end

@implementation EPRotaryKnobControl

@synthesize dotsCount = _dotsCount;
@synthesize circleColor = _circleColor;
@synthesize handleAndDotsColor = _handleAndDotsColor;

#pragma mark properties
- (void)setDotsCount:(NSInteger)dCount
{
    _dotsCount = dCount;
    [self generateDotsPositions];
    [self drawDots];
}

- (void)setValue:(CGFloat)value
{
    if(value < 0){
        value = 0;
    }
    else if(value > 1){
        value = 1;
    }
    self.currentAngleRadians = (kHandleMinAngleRadians - kHandleScaleRadians * value);
}

- (CGFloat)value
{
    double valueRadians = kHandleMinAngleRadians - self.currentAngleRadians;
    if(valueRadians < 0){
        valueRadians = 2 * M_PI + valueRadians;
    }
    return (CGFloat) (valueRadians / kHandleScaleRadians);
}

- (void)setCircleColor:(UIColor *)color
{
    _circleColor = color;
    self.circleLayer.backgroundColor = color.CGColor;
}

- (void)setHandleAndDotsColor:(UIColor *)color
{
    _handleAndDotsColor = color;
    [self drawDots];
    [self drawHandle];
}

#pragma mark setup

- (void)setupView:(CGRect)frame
{
    self.backgroundColor = [UIColor clearColor];
    
    //circleLayer
    CGFloat circleDiameter = kCircleDiameterRatio*fminf(self.frame.size.width, self.frame.size.height);
    self.circleLayer = [CALayer layer];
    self.circleLayer.cornerRadius = circleDiameter / 2;
    self.circleLayer.frame = CGRectMake((frame.size.width - circleDiameter) / 2,
                                        (frame.size.height - circleDiameter) / 2,
                                        circleDiameter,
                                        circleDiameter);
    self.circleLayer.masksToBounds = NO;
    self.circleLayer.shadowOpacity = 1.0f;
    self.circleLayer.shadowOffset = CGSizeMake(0, 2);
    self.circleLayer.shadowRadius = 2.0;
    
    //handle layer
    self.handleLayer = [CAShapeLayer layer];
    CGFloat handleDiameter = kHandleDiameterRatio * circleDiameter;
    self.handleLayer.frame = CGRectMake(0, 0, handleDiameter, handleDiameter);
    
    self.layer.delegate = self;
    
    self.dotsLayer = [CAShapeLayer layer];
    self.dotsLayer.frame = frame;
    
    [self.layer addSublayer:self.dotsLayer];
    [self.layer addSublayer:self.circleLayer];
    [self.layer addSublayer:self.handleLayer];
    
    self.handleAndDotsColor = [UIColor blueColor];
    self.circleLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.handleLayer.backgroundColor =[UIColor clearColor].CGColor;
    self.dotsLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.dotsCount = 11;
    [self setValue:0];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView:self.frame];
    }
    return self;
}

#pragma mark Drawig

- (void)drawDotAtPosition:(float)anglePosition inBezierPath:(UIBezierPath *)bezierPath
{
    CGFloat circleDiameter = fminf(self.frame.size.width, self.frame.size.height);
    CGFloat dotDiameter = circleDiameter*kDotDiameterRatio;
    double dotPositionRadius = circleDiameter / 2- 2 * dotDiameter;
    CGPoint dotPosition = [self calculatePointPositionWithAngle:anglePosition radius:dotPositionRadius];
    dotPosition = [self.dotsLayer convertPoint:dotPosition fromLayer:self.layer];
    [bezierPath moveToPoint:CGPointMake(dotPosition.x + dotDiameter / 2, dotPosition.y)];
    [bezierPath addArcWithCenter:dotPosition
                          radius:dotDiameter / 2
                      startAngle:0
                        endAngle:(CGFloat) (2 * M_PI)
                       clockwise:YES];
}

- (void)drawHandle
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:self.handleLayer.position
                    radius:self.handleLayer.frame.size.width / 2
                startAngle:0
                  endAngle:(CGFloat) (2 * M_PI)
                 clockwise:YES];
    
    self.handleLayer.strokeColor = self.handleAndDotsColor.CGColor;
    self.handleLayer.fillColor = [UIColor clearColor].CGColor;
    self.handleLayer.lineWidth = 2.0;
    self.handleLayer.path = path.CGPath;
}

- (void)drawDots
{
    if(self.dotsCount <= 0)
        return;
    
    UIBezierPath *bPath = [[UIBezierPath alloc] init];
    for (NSNumber *dotPos in self.dotsPositions) {
        [self drawDotAtPosition:dotPos.floatValue inBezierPath:bPath];
    }
    self.dotsLayer.strokeColor = self.handleAndDotsColor.CGColor;
    self.dotsLayer.fillColor = [UIColor clearColor].CGColor;
    self.dotsLayer.lineWidth = 1.0;
    self.dotsLayer.path = bPath.CGPath;
}

#pragma mark UIControl
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint touchPoint = [touch locationInView:self];
    CALayer *touchedLayer = [self.handleLayer hitTest:[touch locationInView:self]];
    
    //you can start moving handle only when touch it
    if(touchedLayer != self.handleLayer)
        return NO;
    
    [self processTrackPoint:touchPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    [self processTrackPoint:[touch locationInView:self]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)processTrackPoint:(CGPoint )touchPoint
{
    double angleRadians = [self calculateAngleFromTouchPoint:touchPoint];
    
    if(angleRadians < kHandleMaxAngleRadians &&  angleRadians > kHandleMinAngleRadians){
        angleRadians = (angleRadians > self.previousAngleRadians) ? kHandleMinAngleRadians : kHandleMaxAngleRadians;
    }
    
    self.previousAngleRadians = self.currentAngleRadians;
    self.currentAngleRadians =  angleRadians;
    [self.layer layoutSublayers];
    if(self.updateBlock){
        self.updateBlock(self.value);
    }
}

#pragma mark calculating
- (double)calculateAngleFromTouchPoint:(CGPoint)point
{
    CGPoint zeroPoint = CGPointMake(self.frame.size.width / 2,self.frame.size.height / 2);
    CGPoint polarXY = CGPointMake(point.x - zeroPoint.x,point.y - zeroPoint.y);
    double len = sqrt(polarXY.x * polarXY.x + polarXY.y * polarXY.y);
    polarXY.x /= len;
    polarXY.y /= len;
    double result = (CGFloat) atan2(polarXY.y,polarXY.x);
    result = ((result >=0) ? result : result + M_PI * 2);
    return (2 * M_PI - result);
}

- (CGPoint)calculatePointPositionWithAngle:(double)angleradians radius:(double)radius
{
    CGPoint zeroPoint = CGPointMake(self.frame.size.width / 2,self.frame.size.height / 2);
    CGFloat x= (CGFloat) (radius * cos(-angleradians) + zeroPoint.x);
    CGFloat y= (CGFloat) (radius * sin(-angleradians) + zeroPoint.y);
    CGPoint centerPoint = CGPointMake(x, y);
    return centerPoint;
}

- (void)generateDotsPositions
{
    self.dotsPositions = [NSMutableArray arrayWithCapacity:0];
    if(self.dotsCount == 0)
        return;
    [self.dotsPositions addObject:@(kHandleMinAngleRadians)];
    if(self.dotsCount < 2)
        return;
    [self.dotsPositions addObject:@(kHandleMaxAngleRadians)];
    if(self.dotsCount > 2){
        double dotsDistanseRadians = kHandleScaleRadians / (self.dotsCount - 1);
        for(int i = 0; i < self.dotsCount - 2; i++){
            double positionRadians = kHandleMinAngleRadians - dotsDistanseRadians * (1 + i);
            if(positionRadians < 0){
                positionRadians = 2 * M_PI + positionRadians;
            }
            [self.dotsPositions addObject:@(positionRadians)];
        }
    }
}

#pragma mark CALayerDelegate
- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    CGFloat circleDiameter = fminf(self.frame.size.width, self.frame.size.height);
    CGFloat handlePositionRadius = circleDiameter*kHandlePositionRatio / 2;
    //change handle position without animation
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.handleLayer.position = [self calculatePointPositionWithAngle:self.currentAngleRadians
                                                               radius:handlePositionRadius];
    [CATransaction commit];
}

@end
