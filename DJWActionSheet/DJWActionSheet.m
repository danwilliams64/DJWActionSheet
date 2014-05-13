//
//  DJWActionSheet.m
//  DJWActionSheet
//
//  Copyright (c) 2014 Daniel Williams. All rights reserved.
//

#import "DJWActionSheet.h"

// Action sheet
static const CGFloat DJWActionSheetHorizontalElementMargin = 10.0;
static const CGFloat DJWActionSheetVerticalElementMargin = 5.0;
static const CGFloat DJWActionSheetTopMargin = 10.0;
static const CGFloat DJWActionSheetRoundedCornerRadius = 6.0;

// Action sheet buttons
static const CGFloat DJWActionSheetButtonHeight = 44.0;
static const CGFloat DJWActionSheetButtonVerticalPadding = 0;

// Animation Durations
static const CGFloat DJWActionSheetPresentationAnimationSpeed = 0.6;
static const CGFloat DJWActionSheetDismissAnimationSpeed = 0.3;

// Font Sizes
static const CGFloat DJWActionSheetTitleFontSize = 14.0;
static const CGFloat DJWActionSheetButtonFontSize = 17.0;

@interface DJWActionSheet()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSString *destructiveButtonTitle;
@property (strong, nonatomic) NSArray *otherButtonTitles;
@property (weak, nonatomic) UIView *containerView;

// UI Properties
@property (strong, nonatomic) UIView *actionSheetBackgroundView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) UIView *containerSnapShotView;

@end

#pragma mark - UIButton+BackgroundColorForState Category

@interface UIButton (BackgroundColorForState)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end

@implementation UIButton (BackgroundColorForState)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, 2, 2);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:img forState:state];
}

@end

#pragma mark - UIView+RoundCornersMask Category

@interface UIView (CornerRadiusWithCorners)

- (void)applyCornerRadiusMaskForCorners:(UIRectCorner)corners withRadius:(CGFloat)radius;

@end

@implementation UIView (CornerRadiusWithCorners)

- (void)applyCornerRadiusMaskForCorners:(UIRectCorner)corners withRadius:(CGFloat)radius
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    self.layer.mask = shape;
}

@end

#pragma mark - DJWAction Sheet Implementation

@implementation DJWActionSheet

+ (void)showInView:(UIView *)view
         withTitle:(NSString *)title
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSArray *)otherButtonTitles
          tapBlock:(DJWActionSheetTapBlock)tapBlock
{
    DJWActionSheet *actionSheet = [[DJWActionSheet alloc] initWithTitle:title
                                                      cancelButtonTitle:cancelButtonTitle
                                                 destructiveButtonTitle:destructiveButtonTitle
                                                      otherButtonTitles:otherButtonTitles
                                                               tapBlock:tapBlock
                                                          containerView:view];
    [actionSheet showInView:view];
}

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                     tapBlock:(DJWActionSheetTapBlock)tapBlock
                containerView:(UIView *)containerView
{
    if ([otherButtonTitles count] > 8) {
        [NSException raise:@"DJWActionSheetIllegalOtherButtonTitlesCount" format:@"Other button titles count cannot be greater than 8, you've used %@", @([otherButtonTitles count])];
        return nil;
    }
    
    self = [super initWithFrame:containerView.bounds];
    if (self) {
        _title = title;
        _cancelButtonTitle = cancelButtonTitle;
        _destructiveButtonTitle = destructiveButtonTitle;
        _otherButtonTitles = otherButtonTitles;
        _tapBlock = tapBlock;
        _containerView = containerView;
        
        self.backgroundColor = [UIColor blackColor];
        _containerSnapShotView = [containerView snapshotViewAfterScreenUpdates:YES];
        [self addSubview:_containerSnapShotView];
        
        [_containerSnapShotView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonTapped:)]];
        
        NSInteger numberOfButtons = [otherButtonTitles count];
        CGFloat actionSheetHeight = [self heightForActionSheetWithNumberOfButtons:numberOfButtons];
        
        // Position at bottom of containerView
        
        _actionSheetBackgroundView = ({
            UIView *view = [[UIView alloc] initWithFrame:({
                CGRect frame = self.bounds;
                frame.size.width = CGRectGetWidth(containerView.bounds);
                frame.size.height = actionSheetHeight;
                frame.origin.x = 0;
                frame.origin.y = CGRectGetHeight(containerView.bounds) - actionSheetHeight;
                frame;
            })];
            
            view.backgroundColor = [UIColor clearColor];
            view;
        });
        
        [self addSubview:_actionSheetBackgroundView];
        
        if (_title) {
            _titleLabel = ({
                UILabel *label = [[UILabel alloc] initWithFrame:({
                    CGRect frame = CGRectZero;
                    CGFloat labelHeight = [self heightForActionSheetTitleLabel];
                    frame = CGRectMake(DJWActionSheetHorizontalElementMargin, DJWActionSheetTopMargin, CGRectGetWidth(_actionSheetBackgroundView.bounds) - (DJWActionSheetHorizontalElementMargin * 2), labelHeight);
                    frame;
                })];
                
                label.text = _title;
                label.numberOfLines = 0;
                label.font = [UIFont systemFontOfSize:14.0];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [DJWActionSheet DJWActionSheetTitleBackgroundColor];
                label.textColor = [UIColor blackColor];
                
                [label applyCornerRadiusMaskForCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:DJWActionSheetRoundedCornerRadius];
                [label addSubview:[self buttonDividerAtYPos:CGRectGetMaxY(label.bounds) - 1]];

                label;
            });
            [_actionSheetBackgroundView addSubview:_titleLabel];
        }
        
        [self addButtonSubViewsToView:_actionSheetBackgroundView];
    }
    
    return self;
}

- (void)addButtonSubViewsToView:(UIView *)view
{
    __block CGFloat yPos = CGRectGetMaxY(self.titleLabel.frame);
    
    [self.otherButtonTitles enumerateObjectsUsingBlock:^(NSString *buttonTitle, NSUInteger idx, BOOL *stop) {
        UIButton *newButton = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = ({
                CGRect frame = CGRectMake(DJWActionSheetHorizontalElementMargin, yPos, CGRectGetWidth(view.frame) - (DJWActionSheetHorizontalElementMargin * 2), DJWActionSheetButtonHeight);
                frame;
            });
            
            [button setTag:idx]; // To determine which button was tapped
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button setTitleColor:[DJWActionSheet DJWActionSheetButtonTextColorForState:UIControlStateNormal] forState:UIControlStateNormal];
            [button setTitleColor:[DJWActionSheet DJWActionSheetButtonTextColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            [button setBackgroundColor:[DJWActionSheet DJWActionSheetButtonBackgroundColorForState:UIControlStateNormal] forState:UIControlStateNormal];
            [button setBackgroundColor:[DJWActionSheet DJWActionSheetButtonBackgroundColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            
            button.titleLabel.font = [UIFont boldSystemFontOfSize:DJWActionSheetTitleFontSize];
            button.layer.masksToBounds = YES;
            
            NSInteger lastButtonIndex = [self.otherButtonTitles count] - 1;
            if (idx == 0 && !self.title) {
                [button applyCornerRadiusMaskForCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:DJWActionSheetRoundedCornerRadius];
            } else if (idx == lastButtonIndex && !self.destructiveButtonTitle) {
                [button applyCornerRadiusMaskForCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight withRadius:DJWActionSheetRoundedCornerRadius];
            } else if (lastButtonIndex == 0 && !self.destructiveButtonTitle) {
                [button applyCornerRadiusMaskForCorners:UIRectCornerAllCorners withRadius:DJWActionSheetRoundedCornerRadius];
            }
            
            if (idx != lastButtonIndex) {
                [button addSubview:[self buttonDividerAtYPos:CGRectGetMaxY(button.bounds) - 1]];
            }
            
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        [view addSubview:newButton];
        yPos = CGRectGetMaxY(newButton.frame) + DJWActionSheetButtonVerticalPadding;
    }];
    
    if (self.destructiveButtonTitle) {
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
        newButton.frame = ({
            CGRect frame = CGRectMake(DJWActionSheetHorizontalElementMargin, yPos, CGRectGetWidth(view.frame) - (DJWActionSheetHorizontalElementMargin * 2), DJWActionSheetButtonHeight);
            frame;
        });
        
        [newButton setTag:-2];
        [newButton setTitle:self.destructiveButtonTitle forState:UIControlStateNormal];
        [newButton setTitleColor:[DJWActionSheet DJWActionSheetDestructiveButtonTextColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [newButton setTitleColor:[DJWActionSheet DJWActionSheetDestructiveButtonTextColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [newButton setBackgroundColor:[DJWActionSheet DJWActionSheetDestructiveButtonBackgroundColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [newButton setBackgroundColor:[DJWActionSheet DJWActionSheetDestructiveButtonBackgroundColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        newButton.titleLabel.font = [UIFont boldSystemFontOfSize:DJWActionSheetButtonFontSize];

        [newButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        newButton.layer.masksToBounds = NO;
        [newButton applyCornerRadiusMaskForCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight withRadius:DJWActionSheetRoundedCornerRadius];

        [view addSubview:newButton];
        yPos = CGRectGetMaxY(newButton.frame) + DJWActionSheetButtonVerticalPadding;
    }
    
    self.cancelButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = ({
            CGRect frame = CGRectMake(DJWActionSheetHorizontalElementMargin, yPos + DJWActionSheetVerticalElementMargin, CGRectGetWidth(view.frame) - (DJWActionSheetHorizontalElementMargin * 2), DJWActionSheetButtonHeight);
            frame;
        });
        
        [button setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [button setTitleColor:[DJWActionSheet DJWActionSheetCancelButtonTextColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [button setTitleColor:[DJWActionSheet DJWActionSheetCancelButtonTextColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[DJWActionSheet DJWActionSheetCancelButtonBackgroundColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [button setBackgroundColor:[DJWActionSheet DJWActionSheetCancelButtonBackgroundColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        
        button.titleLabel.font = [UIFont boldSystemFontOfSize:DJWActionSheetButtonFontSize];

        [button addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        button.layer.cornerRadius = 6.0f;
        button.layer.masksToBounds = YES;
        
        button;
    });
    
    [view addSubview:self.cancelButton];
}

- (UIView *)buttonDividerAtYPos:(CGFloat)yPos
{
    return ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, CGRectGetWidth(self.containerView.bounds) - (DJWActionSheetHorizontalElementMargin * 2), 1)];
        view.backgroundColor = [DJWActionSheet DJWActionSheetDividerColor];
        view;
    });
}

- (CGFloat)heightForActionSheetTitleLabel
{
    NSString *title = self.title;
    CGSize maxLabelSize = CGSizeMake(CGRectGetWidth(self.frame) - (DJWActionSheetHorizontalElementMargin * 2), CGFLOAT_MAX);
    
    CGRect labelRect = [title boundingRectWithSize:maxLabelSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:DJWActionSheetTitleFontSize]}
                                           context:nil];
    
    return labelRect.size.height + 10;
}

- (CGFloat)heightForActionSheetWithNumberOfButtons:(NSInteger)numberOfButtons
{
    CGFloat height = 0.0;
    
    numberOfButtons++; // increment to account for the `cancel` button
    if (self.destructiveButtonTitle) {
        numberOfButtons++;
    }
    
    height += DJWActionSheetButtonHeight * numberOfButtons;
    height += DJWActionSheetButtonVerticalPadding * numberOfButtons;
    height += DJWActionSheetTopMargin * 2;
    height += DJWActionSheetVerticalElementMargin;
    
    height += (self.title) ? [self heightForActionSheetTitleLabel] : 0;
    return height;
}

- (void)buttonTapped:(UIButton *)sender
{
    self.tapBlock(self, sender.tag);
    [self dismissFromView:self.containerView];
}

- (void)cancelButtonTapped:(UIButton *)sender
{
    self.tapBlock(self, -1);
    
    [self dismissFromView:self.containerView];
}

- (void)showInView:(UIView *)view
{
    [self animateContainerSnapshotViewToScale:0.9];
    
    CGRect actionSheetBackgroundViewEndFrame = self.actionSheetBackgroundView.frame;
    CGRect cancelButtonEndFrame = self.cancelButton.frame;
    
    self.actionSheetBackgroundView.frame = CGRectMake(CGRectGetMinX(self.actionSheetBackgroundView.frame), CGRectGetHeight(self.containerView.frame), CGRectGetWidth(self.actionSheetBackgroundView.frame), CGRectGetHeight(self.actionSheetBackgroundView.frame));
    self.cancelButton.frame = CGRectMake(CGRectGetMinX(self.cancelButton.frame), CGRectGetMinY(self.cancelButton.frame) + DJWActionSheetVerticalElementMargin * 15, CGRectGetWidth(self.cancelButton.frame), CGRectGetHeight(self.cancelButton.frame));
    
    [self.containerView addSubview:self];
    
    [UIView animateWithDuration:DJWActionSheetPresentationAnimationSpeed delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
        self.actionSheetBackgroundView.frame = actionSheetBackgroundViewEndFrame;
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.35 delay:0.3 usingSpringWithDamping:0.65 initialSpringVelocity:0 options:0 animations:^{
        self.cancelButton.frame = cancelButtonEndFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateContainerSnapshotViewToScale:(CGFloat)scale
{
    [UIView animateWithDuration:0.3 animations:^{
        self.containerSnapShotView.alpha = (scale < 1) ? 0.6 : 1.0;
        self.containerSnapShotView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    }];
}

- (void)dismissFromView:(UIView *)view
{
    [self animateContainerSnapshotViewToScale:1.0];
    
    CGRect actionSheetBackgroundViewEndFrame = CGRectMake(CGRectGetMinX(self.actionSheetBackgroundView.frame), CGRectGetHeight(self.containerView.frame), CGRectGetWidth(self.actionSheetBackgroundView.frame), CGRectGetHeight(self.actionSheetBackgroundView.frame));
    
    [UIView animateWithDuration:DJWActionSheetDismissAnimationSpeed animations:^{
        self.actionSheetBackgroundView.frame = actionSheetBackgroundViewEndFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Getters

- (NSInteger)cancelButtonIndex
{
    return -1;
}

- (NSInteger)destructiveButtonIndex
{
    return -2;
}

#pragma mark - Class Methods

+ (UIColor *)DJWActionSheetButtonTextColorForState:(UIControlState)controlState
{
    switch (controlState) {
        case UIControlStateNormal:
            return [UIColor blackColor];
            break;
        case UIControlStateHighlighted:
            return [UIColor whiteColor];
            break;
            
        default:
            return [UIColor blackColor];
            break;
    }
}

+ (UIColor *)DJWActionSheetButtonBackgroundColorForState:(UIControlState)controlState
{
    switch (controlState) {
        case UIControlStateNormal:
            return [UIColor whiteColor];
            break;
        case UIControlStateHighlighted:
            return [UIColor colorWithRed:0.000 green:0.490 blue:0.965 alpha:1];
            break;
            
        default:
            return [UIColor whiteColor];
            break;
    }
}

+ (UIColor *)DJWActionSheetCancelButtonTextColorForState:(UIControlState)controlState
{
    switch (controlState) {
        case UIControlStateNormal:
            return [UIColor whiteColor];
            break;
        case UIControlStateHighlighted:
            return [UIColor whiteColor];
            break;
            
        default:
            return [UIColor whiteColor];
            break;
    }
}

+ (UIColor *)DJWActionSheetDestructiveButtonBackgroundColorForState:(UIControlState)controlState
{
    switch (controlState) {
        case UIControlStateNormal:
            return [UIColor colorWithRed:0.784 green:0.000 blue:0.000 alpha:1];
            break;
        case UIControlStateHighlighted:
            return [UIColor colorWithRed:0.588 green:0.000 blue:0.000 alpha:1];
            break;
            
        default:
            return [UIColor blackColor];
            break;
    }
}

+ (UIColor *)DJWActionSheetDestructiveButtonTextColorForState:(UIControlState)controlState
{
    switch (controlState) {
        case UIControlStateNormal:
            return [UIColor whiteColor];
            break;
        case UIControlStateHighlighted:
            return [UIColor whiteColor];
            break;
            
        default:
            return [UIColor whiteColor];
            break;
    }
}

+ (UIColor *)DJWActionSheetCancelButtonBackgroundColorForState:(UIControlState)controlState
{
    switch (controlState) {
        case UIControlStateNormal:
            return [UIColor colorWithRed:0.192 green:0.192 blue:0.192 alpha:0.9];
            break;
        case UIControlStateHighlighted:
            return [UIColor colorWithRed:0.000 green:0.490 blue:0.965 alpha:0.9];
            break;
            
        default:
            return [UIColor blackColor];
            break;
    }
}

+ (UIColor *)DJWActionSheetTitleBackgroundColor
{
    return [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
}

+ (UIColor *)DJWActionSheetDividerColor
{
    return [UIColor colorWithRed:0.800 green:0.800 blue:0.800 alpha:1];
}

@end