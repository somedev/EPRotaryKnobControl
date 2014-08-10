//
//  ViewController.m
//  EPRotaryKnobControlExample
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


#import "ViewController.h"
#import "EPRotaryKnobControl.h"

@interface ViewController ()
@property (nonatomic, strong) EPRotaryKnobControl *cSlider;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cSlider = [[EPRotaryKnobControl alloc] initWithFrame:CGRectMake(60, 100, 200, 200)];
    self.cSlider.backgroundColor = [UIColor whiteColor];
    self.cSlider.circleColor = [UIColor whiteColor];
    self.cSlider.handleAndDotsColor = [UIColor lightGrayColor];
    self.label.text=[NSString stringWithFormat:@"%.0f", self.cSlider.value * 100.0f];
    
    __weak typeof(self) wself = self;
    
    //update value block
    self.cSlider.updateBlock = ^(CGFloat value){
        wself.label.text = [NSString stringWithFormat:@"%.0f %%", value * 100.0f];
    };

    [self.view addSubview:self.cSlider];
}

@end
