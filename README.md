##EPRotaryKnobControl
Simple rotary knob control for iOS applications

EPRotaryKnobControl requires Xcode 5, targeting either iOS 5.0+

Project uses ARC.

<p align="center" >
  <img src="https://raw.github.com/somedev/EPRotaryKnobControl/master/assets/screen.png" alt="EPRotaryKnobControl" title="EPRotaryKnobControl">
</p>

##Example Code

```objective-c
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
```
