# DJWActionSheet

A block based alternative to UIActionSheet in the style of TweetBot

## Demo

![Screenshot](https://raw.githubusercontent.com/danwilliams64/danwilliams64.github.io/master/images/DJWActionSheetDemo.gif)

## Usage

Create and then show the action sheet

```objective-c
- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                     tapBlock:(DJWActionSheetTapBlock)tapBlock
                containerView:(UIView *)containerView;

- (void)showInView:(UIView *)view;
```

Alternatively, use

```objective-c
+ (void)showInView:(UIView *)view
         withTitle:(NSString *)title
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSArray *)otherButtonTitles
          tapBlock:(DJWActionSheetTapBlock)tapBlock;
```
to instantiate and show the action sheet in the specified view.

When the user has responded by tapping one of the buttons, the tapBlock is executed. Use `tappedButtonIndex` to decide what action to take.

## Installation

Simply add `DJWActionSheet` to your Podfile if you're using Cocoapods. Alternatively, add `DJWActionSheet.h` and `DJWActionSheet.m` to your project.
