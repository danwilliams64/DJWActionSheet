DJWActionSheet
==============

A block based alternative to UIActionSheet in the style of TweetBot
-------------------------------------------------------------------

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
