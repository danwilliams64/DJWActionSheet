//
//  DJWActionSheet.m
//  DJWActionSheet
//
//  Created by Daniel Williams on 02/01/2014.
//  Copyright (c) 2014 Daniel Williams. All rights reserved.
//

#import "DJWActionSheet.h"

#define kDJWActionSheetHorizontalElementMargin                      10.0
#define kDJWActionSheetVerticalElementMargin                        5.0
#define kDJWActionSheetTopMargin                                    10.0

#define kDJWActionSheetRoundedCornerRadius                          6.0

#define kDJWActionSheetTitleBackgroundColor                         [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1]
#define kDJWActionSheetTitleFontSize                                14.0
#define kDJWActionSheetTitleFont                                    [UIFont systemFontOfSize:kDJWActionSheetTitleFontSize]

#define kDJWActionSheetButtonTextColorNormalState                   [UIColor blackColor]
#define kDJWActionSheetButtonTextColorHighlightedState              [UIColor whiteColor]
#define kDJWActionSheetButtonBackgroundColorNormal                  [UIColor whiteColor]
#define kDJWActionSheetButtonBackgroundColorHighlighted             [UIColor colorWithRed:0.000 green:0.490 blue:0.965 alpha:1]

#define kDJWActionSheetButtonDividerColor                           [UIColor colorWithRed:0.800 green:0.800 blue:0.800 alpha:1]

#define kDJWActionSheetCancelButtonTextColorNormalState             [UIColor whiteColor]
#define kDJWActionSheetCancelButtonTextColorHighlightedState        [UIColor whiteColor]
#define kDJWActionSheetCancelButtonBackgroundColorNormal            [UIColor colorWithRed:0.192 green:0.192 blue:0.192 alpha:kDJWActionSheetCancelButtonAlpha]
#define kDJWActionSheetCancelButtonBackgroundColorHighlighted       [UIColor colorWithRed:0.000 green:0.490 blue:0.965 alpha:kDJWActionSheetCancelButtonAlpha]
#define kDJWActionSheetCancelButtonAlpha                            0.9

#define kDJWActionSheetDestructiveButtonBackgroundColorNormal       [UIColor colorWithRed:0.784 green:0.000 blue:0.000 alpha:1]
#define kDJWActionSheetDestructiveButtonBackgroundColorHighlighted  [UIColor colorWithRed:0.588 green:0.000 blue:0.000 alpha:1]
#define kDJWActionSheetDestructiveButtonTextColorNormal             [UIColor whiteColor]
#define kDJWActionSheetDestructiveButtonTextColorHighlighted        [UIColor whiteColor]

#define kDJWActionSheetButtonFontSize                               17.0
#define kDJWActionSheetButtonFont                                   [UIFont boldSystemFontOfSize:kDJWActionSheetButtonFontSize]

#define kDJWActionSheetButtonHeight                                 44.0
#define kDJWActionSheetButtonVerticalPadding                        0.0

#define kDJWActionSheetPresentationAnimationSpeed                   0.6
#define kDJWActionSheetDismissAnimationSpeed                        0.3

@interface DJWActionSheet()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSString *destructiveButtonTitle;
@property (strong, nonatomic) NSArray *otherButtonTitles;
@property (copy, nonatomic) DJWActionSheetCompletionBlock tapBlock;
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
          tapBlock:(DJWActionSheetCompletionBlock)tapBlock
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
                     tapBlock:(DJWActionSheetCompletionBlock)tapBlock
                containerView:(UIView *)containerView
{
    self = [super initWithFrame:containerView.frame];
    if (self) {
        _title = title;
        _cancelButtonTitle = cancelButtonTitle;
        _destructiveButtonTitle = destructiveButtonTitle;
        _otherButtonTitles = otherButtonTitles;
        _tapBlock = tapBlock;
        _containerView = containerView;
        
        self.backgroundColor = [UIColor blackColor];
        _containerSnapShotView = [containerView.window snapshotViewAfterScreenUpdates:NO];
        [self addSubview:_containerSnapShotView];
        
        NSInteger numberOfButtons = [otherButtonTitles count];
#warning ToDo: account for destructive button
        CGFloat actionSheetHeight = [self heightForActionSheetWithNumberOfButtons:numberOfButtons];
        
        // Position at bottom of containerView
        
        _actionSheetBackgroundView = ({
            UIView *view = [[UIView alloc] initWithFrame:({
                CGRect frame = self.bounds;
                frame.size.width = CGRectGetWidth(containerView.frame);
                frame.size.height = actionSheetHeight;
                frame.origin.x = 0;
                frame.origin.y = CGRectGetHeight(containerView.frame) - actionSheetHeight;
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
                    frame = CGRectMake(kDJWActionSheetHorizontalElementMargin, kDJWActionSheetTopMargin, CGRectGetWidth(_actionSheetBackgroundView.frame) - (kDJWActionSheetHorizontalElementMargin * 2), labelHeight);
                    frame;
                })];
                
                label.text = _title;
                label.numberOfLines = 0;
                label.font = [UIFont systemFontOfSize:14.0];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = kDJWActionSheetTitleBackgroundColor;
                label.textColor = [UIColor blackColor];
                
                [label applyCornerRadiusMaskForCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:kDJWActionSheetRoundedCornerRadius];
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
                CGRect frame = CGRectMake(kDJWActionSheetHorizontalElementMargin, yPos, CGRectGetWidth(view.frame) - (kDJWActionSheetHorizontalElementMargin * 2), kDJWActionSheetButtonHeight);
                frame;
            });
            
            [button setTag:idx]; // To determine which button was tapped
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button setTitleColor:kDJWActionSheetButtonTextColorNormalState forState:UIControlStateNormal];
            [button setTitleColor:kDJWActionSheetButtonTextColorHighlightedState forState:UIControlStateHighlighted];
            [button setBackgroundColor:kDJWActionSheetButtonBackgroundColorNormal forState:UIControlStateNormal];
            [button setBackgroundColor:kDJWActionSheetButtonBackgroundColorHighlighted forState:UIControlStateHighlighted];
            
            button.titleLabel.font = kDJWActionSheetButtonFont;
            
            button.layer.masksToBounds = YES;
            
            NSInteger lastButtonIndex = [self.otherButtonTitles count] - 1;
            if (idx == 0 && !self.title) {
                [button applyCornerRadiusMaskForCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:kDJWActionSheetRoundedCornerRadius];
            } else if (idx == lastButtonIndex && !self.destructiveButtonTitle) {
                [button applyCornerRadiusMaskForCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight withRadius:kDJWActionSheetRoundedCornerRadius];
            } else if (lastButtonIndex == 0 && !self.destructiveButtonTitle) {
                [button applyCornerRadiusMaskForCorners:UIRectCornerAllCorners withRadius:kDJWActionSheetRoundedCornerRadius];
            }
            
            if (idx != lastButtonIndex) {
                [button addSubview:[self buttonDividerAtYPos:CGRectGetMaxY(button.bounds) - 1]];
            }
            
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        [view addSubview:newButton];
        yPos = CGRectGetMaxY(newButton.frame) + kDJWActionSheetButtonVerticalPadding;
    }];
    
    if (self.destructiveButtonTitle) {
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
        newButton.frame = ({
            CGRect frame = CGRectMake(kDJWActionSheetHorizontalElementMargin, yPos, CGRectGetWidth(view.frame) - (kDJWActionSheetHorizontalElementMargin * 2), kDJWActionSheetButtonHeight);
            frame;
        });
        
        [newButton setTag:-2];
        [newButton setTitle:self.destructiveButtonTitle forState:UIControlStateNormal];
        [newButton setTitleColor:kDJWActionSheetDestructiveButtonTextColorNormal forState:UIControlStateNormal];
        [newButton setTitleColor:kDJWActionSheetDestructiveButtonTextColorHighlighted forState:UIControlStateHighlighted];
        [newButton setBackgroundColor:kDJWActionSheetDestructiveButtonBackgroundColorNormal forState:UIControlStateNormal];
        [newButton setBackgroundColor:kDJWActionSheetDestructiveButtonBackgroundColorHighlighted forState:UIControlStateHighlighted];
        newButton.titleLabel.font = kDJWActionSheetButtonFont;

        [newButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        newButton.layer.masksToBounds = NO;
        [newButton applyCornerRadiusMaskForCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight withRadius:kDJWActionSheetRoundedCornerRadius];

        [view addSubview:newButton];
        yPos = CGRectGetMaxY(newButton.frame) + kDJWActionSheetButtonVerticalPadding;
    }
    
    self.cancelButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = ({
            CGRect frame = CGRectMake(kDJWActionSheetHorizontalElementMargin, yPos + kDJWActionSheetVerticalElementMargin, CGRectGetWidth(view.frame) - (kDJWActionSheetHorizontalElementMargin * 2), kDJWActionSheetButtonHeight);
            frame;
        });
        
        [button setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [button setTitleColor:kDJWActionSheetCancelButtonTextColorNormalState forState:UIControlStateNormal];
        [button setTitleColor:kDJWActionSheetCancelButtonTextColorHighlightedState forState:UIControlStateHighlighted];
        [button setBackgroundColor:kDJWActionSheetCancelButtonBackgroundColorNormal forState:UIControlStateNormal];
        [button setBackgroundColor:kDJWActionSheetCancelButtonBackgroundColorHighlighted forState:UIControlStateHighlighted];
        
        button.titleLabel.font = kDJWActionSheetButtonFont;

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
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, CGRectGetWidth(self.containerView.frame) - (kDJWActionSheetHorizontalElementMargin * 2), 1)];
        view.backgroundColor = kDJWActionSheetButtonDividerColor;
        view;
    });
}

- (CGFloat)heightForActionSheetTitleLabel
{
    NSString *title = self.title;
    CGSize maxLabelSize = CGSizeMake(CGRectGetWidth(self.frame) - (kDJWActionSheetHorizontalElementMargin * 2), CGFLOAT_MAX);
    
    CGRect labelRect = [title boundingRectWithSize:maxLabelSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kDJWActionSheetTitleFontSize]}
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
    
    height += kDJWActionSheetButtonHeight * numberOfButtons;
    height += kDJWActionSheetButtonVerticalPadding * numberOfButtons;
    height += kDJWActionSheetTopMargin * 2;
    height += kDJWActionSheetVerticalElementMargin;
    
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
    self.cancelButton.frame = CGRectMake(CGRectGetMinX(self.cancelButton.frame), CGRectGetMinY(self.cancelButton.frame) + kDJWActionSheetVerticalElementMargin * 15, CGRectGetWidth(self.cancelButton.frame), CGRectGetHeight(self.cancelButton.frame));
    
    [view.window addSubview:self];
    
    [UIView animateWithDuration:kDJWActionSheetPresentationAnimationSpeed delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
        self.actionSheetBackgroundView.frame = actionSheetBackgroundViewEndFrame;
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.35 delay:0.3 usingSpringWithDamping:0.65 initialSpringVelocity:0 options:0 animations:^{
        self.cancelButton.frame = cancelButtonEndFrame;
    } completion:^(BOOL finished) {
    }];
    
#warning ToDo: Check to see if the view can accomodate the actionSheet view correctly
}

- (void)animateContainerSnapshotViewToScale:(CGFloat)scale
{
    [UIView animateWithDuration:0.3 animations:^{
        self.containerSnapShotView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    }];
}

- (void)dismissFromView:(UIView *)view
{
    [self animateContainerSnapshotViewToScale:1.0];
    
    CGRect actionSheetBackgroundViewEndFrame = CGRectMake(CGRectGetMinX(self.actionSheetBackgroundView.frame), CGRectGetHeight(self.containerView.frame), CGRectGetWidth(self.actionSheetBackgroundView.frame), CGRectGetHeight(self.actionSheetBackgroundView.frame));
    
    [UIView animateWithDuration:kDJWActionSheetDismissAnimationSpeed animations:^{
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

@end

