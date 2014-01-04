//
//  DJWActionSheet.h
//  DJWActionSheet
//
//  Created by Daniel Williams on 02/01/2014.
//  Copyright (c) 2014 Daniel Williams. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DJWActionSheet;

typedef void (^DJWActionSheetCompletionBlock) (DJWActionSheet * actionSheet, NSInteger tappedButtonIndex);

@interface DJWActionSheet : UIView

@property (assign, nonatomic, readonly) NSInteger cancelButtonIndex;

+ (void)showInView:(UIView *)view
         withTitle:(NSString *)title
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSArray *)otherButtonTitles
          tapBlock:(DJWActionSheetCompletionBlock)tapBlock;

@end

@interface UIButton (BackgroundColorForState)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end