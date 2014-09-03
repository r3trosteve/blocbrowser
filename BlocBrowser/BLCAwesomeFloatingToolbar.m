//
//  BLCSwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Steven Schofield on 26/07/2014.
//  Copyright (c) 2014 Double Digital. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;

@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UIButton *forwardButton;
@property(nonatomic, strong) UIButton *stopButton;
@property(nonatomic, strong) UIButton *refreshButton;

@end

@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        [self setupGestures];
        
        
        self.buttons = @[self.backButton, self.forwardButton, self.stopButton, self.refreshButton];
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
    }
    
    return self;
}

- (void) setupGestures {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(longPressFired:)];
    [self addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *panGesture =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(panFired:)];
    [self addGestureRecognizer:panGesture];
    UIPinchGestureRecognizer *pinchGesture =
    [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(pinchFired:)];
    [self addGestureRecognizer:pinchGesture];
}

#pragma mark - Lazy Loading

-(UIButton *) refreshButton{
    if (!_refreshButton){
        _refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _refreshButton.backgroundColor = [UIColor yellowColor];
        _refreshButton.alpha = .25;
        [_refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
        [_refreshButton addTarget:self
                           action:@selector(buttonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (UIButton *) stopButton {
    if (!_stopButton){
        _stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _stopButton.backgroundColor = [UIColor greenColor];
        _stopButton.alpha = .25;
        [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [_stopButton addTarget:self
                        action:@selector(buttonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}


- (UIButton *) forwardButton {
    if (!_forwardButton){
        _forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _forwardButton.backgroundColor = [UIColor blueColor];
        _forwardButton.alpha = .25;
        [_forwardButton setTitle:@"Forward" forState:UIControlStateNormal];
        [_forwardButton addTarget:self
                           action:@selector(buttonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _forwardButton;
}

- (UIButton *) backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _backButton.backgroundColor = [UIColor redColor];
        _backButton.alpha = .25;
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        [_backButton addTarget:self
                        action:@selector(buttonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void) layoutSubviews {
    // set the frames for the 4 buttons
    
    CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
    CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
    self.backButton.frame = CGRectMake(0, 0, labelWidth, labelHeight);
    self.forwardButton.frame =
    CGRectMake((CGRectGetWidth(self.bounds)) / 2, 0, labelWidth, labelHeight);
    self.stopButton.frame =
    CGRectMake(0, CGRectGetHeight(self.bounds) / 2, labelWidth, labelHeight);
    self.refreshButton.frame =
    CGRectMake(labelWidth, labelHeight, labelWidth, labelHeight);
}

#pragma mark - Touch Handling

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchToScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchToScale:recognizer.scale];
        }
        
    }
}

- (void)longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        NSMutableArray *newColors = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < self.colors.count; ++i) {
            [newColors addObject:self.colors[(i - 1) % self.colors.count]];
            
        }
        
        self.colors = newColors;
        
        [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            button.backgroundColor = self.colors[idx];
        }];
    }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    UIButton *button = [self.buttons objectAtIndex:index];
    if (index != NSNotFound) {
        
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

- (void)buttonPressed:(UIButton *)sender {
    UIButton *pressed = sender;
    
    if ([self.delegate
         respondsToSelector:@selector(floatingToolbar:didSelectButton:)]) {
        [self.delegate floatingToolbar:self didSelectButton:(UIButton *)pressed];
    }
}

@end
