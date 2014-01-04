//
//  DJWActionSheet.m
//  DJWActionSheet
//
//  Created by Daniel Williams on 02/01/2014.
//  Copyright (c) 2014 Daniel Williams. All rights reserved.
//

#import "DJWActionSheet.h"

#define kDJWActionSheetHorizontalElementMargin                  10.0
#define kDJWActionSheetVerticalElementMargin                    5.0
#define kDJWActionSheetToplMargin                               10.0

#define kDJWActionSheetButtonTextColorNormalState               [UIColor blackColor]
#define kDJWActionSheetButtonTextColorHighlightedState          [UIColor whiteColor]
#define kDJWActionSheetButtonBackgroundColorNormal              [UIColor whiteColor]
#define kDJWActionSheetButtonBackgroundColorHighlighted         [UIColor colorWithRed:0.000 green:0.490 blue:0.965 alpha:1]

#define kDJWActionSheetButtonDividerColor                       [UIColor lightGrayColor]

#define kDJWActionSheetCancelButtonTextColorNormalState         [UIColor whiteColor]
#define kDJWActionSheetCancelButtonTextColorHighlightedState    [UIColor whiteColor]
#define kDJWActionSheetCancelButtonBackgroundColorNormal        [UIColor colorWithRed:0.192 green:0.192 blue:0.192 alpha:1]
#define kDJWActionSheetCancelButtonBackgroundColorHighlighted   [UIColor colorWithRed:0.000 green:0.490 blue:0.965 alpha:1]

#define kDJWActionSheetButtonFontSize                           17.0
#define kDJWActionSheetButtonFont                               [UIFont boldSystemFontOfSize:kDJWActionSheetButtonFontSize]

#define kDJWActionSheetButtonHeight                             44.0
#define kDJWActionSheetButtonVerticalPadding                    0.0

@interface DJWActionSheet()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSString *destructiveButtonTitle;
@property (strong, nonatomic) NSArray *otherButtonTitles;
@property (copy, nonatomic) DJWActionSheetCompletionBlock tapBlock;
@property (weak, nonatomic) UIView *containerView;

// UI Properties
@property (copy, nonatomic) UILabel *titleLabel;

@end

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
    NSInteger numberOfButtons = [otherButtonTitles count] + 1;
#warning ToDo: account for destructive button
    CGFloat actionSheetHeight = [self heightForActionSheetWithNumberOfButtons:numberOfButtons];
    
    self = [super initWithFrame:containerView.frame];
    if (self) {
        _title = title;
        _cancelButtonTitle = cancelButtonTitle;
        _destructiveButtonTitle = destructiveButtonTitle;
        _otherButtonTitles = otherButtonTitles;
        _tapBlock = tapBlock;
        _containerView = containerView;
        
        // Position at bottom of containerView
        
        UIView *backgroundView = ({
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
        
        [self addSubview:backgroundView];
        
        if (_title) {
            _titleLabel = ({
                UILabel *label = [[UILabel alloc] initWithFrame:({
                    CGRect frame = CGRectZero;
                    frame = CGRectMake(kDJWActionSheetHorizontalElementMargin, kDJWActionSheetToplMargin, CGRectGetWidth(backgroundView.frame) - (kDJWActionSheetHorizontalElementMargin * 2), 30);
#warning ToDo: Remove magic number '30' and calculate the height of the label
                    frame;
                })];
                
                label.text = _title;
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor whiteColor];
                label.textColor = [UIColor blackColor];
                label;
            });
            [backgroundView addSubview:_titleLabel];
        }
        
        [self addButtonSubViewsToView:backgroundView];
    }
    
    return self;
}

- (void)addButtonSubViewsToView:(UIView *)view
{
    __block CGFloat yPos = CGRectGetMaxY(self.titleLabel.frame) + kDJWActionSheetVerticalElementMargin;
    
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
            if (idx == 0) {
                [self addMaskToButton:button byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
            } else if (idx == lastButtonIndex) {
                [self addMaskToButton:button byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight];
            } else if (lastButtonIndex == 0) {
                [self addMaskToButton:button byRoundingCorners:UIRectCornerAllCorners];
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
    
    UIButton *cancelButton = ({
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
        
        button.alpha = 0.8;
        
        [button addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        button.layer.cornerRadius = 6.0f;
        button.layer.masksToBounds = YES;
        
        button;
    });
    
    [view addSubview:cancelButton];
}

- (UIView *)buttonDividerAtYPos:(CGFloat)yPos
{
    return ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, yPos, CGRectGetWidth(self.containerView.frame) - (kDJWActionSheetHorizontalElementMargin * 2), 1)];
        view.backgroundColor = kDJWActionSheetButtonDividerColor;
        view;
    });
}

- (void)addMaskToButton:(UIButton *)button byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(6.0, 6.0)];
    
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    button.layer.mask = shape;
}

- (CGFloat)heightForActionSheetWithNumberOfButtons:(NSInteger)numberOfButtons
{
    CGFloat height = 0.0;
    
    height += kDJWActionSheetButtonHeight * numberOfButtons;
    height += kDJWActionSheetButtonVerticalPadding * numberOfButtons;
    height += kDJWActionSheetToplMargin * 2;
    height += kDJWActionSheetVerticalElementMargin;
    
    height += (self.title) ? 30 : 0;
#warning ToDo: Remove magic number '30' and calculate the height of the label
    
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
    [view addSubview:self];
#warning Check to see if the view can accomodate the actionSheet view correctly
}

- (void)dismissFromView:(UIView *)view
{
    [self removeFromSuperview];
}

#pragma mark - Getters

- (NSInteger)cancelButtonIndex
{
    return -1;
}

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