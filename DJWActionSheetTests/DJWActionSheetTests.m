//
//  DJWActionSheetTests.m
//  DJWActionSheetTests
//
//  Created by Daniel Williams on 02/01/2014.
//  Copyright (c) 2014 Daniel Williams. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DJWActionSheet.h"

@interface DJWActionSheetTests : XCTestCase

@property (nonatomic, strong) DJWActionSheet *actionSheet;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation DJWActionSheetTests

- (void)setUp
{
    [super setUp];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 360, 480)];
    [self.window addSubview:self.containerView];
    
    self.actionSheet = [[DJWActionSheet alloc] initWithTitle:@"Test Action Sheet"
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Delete"
                                           otherButtonTitles:@[@"Title 1", @"Title 2", @"Title 3"]
                                                    tapBlock:^(DJWActionSheet *actionSheet, NSInteger tappedButtonIndex) {
                                                        NSLog(@"Tapped action sheet");
                                                    } containerView:self.containerView];
}

- (void)tearDown
{
    self.containerView = nil;
    self.actionSheet = nil;
    self.window = nil;
    [super tearDown];
}

- (void)testSettingTapBlock
{
    void (^localTapBlock)(DJWActionSheet *actionSheet, NSInteger tappedButtonIndex) = ^void (DJWActionSheet *actionSheet, NSInteger tappedButtonIndex){
        NSLog(@"Tapped action sheet");
    };
    
    self.actionSheet.tapBlock = localTapBlock;
    
    XCTAssertEqualObjects(self.actionSheet.tapBlock, localTapBlock, @"The action sheet tapblock should equal the local tap block");
}

- (void)testActionSheetIsAddedToContainerViewsWindow
{
    [self.actionSheet showInView:self.containerView];
    NSArray *containerSubViews = self.containerView.window.subviews;
    BOOL actionSheetIsSubview = [containerSubViews containsObject:self.actionSheet];
    
    XCTAssertTrue(actionSheetIsSubview, @"The action sheet should be a subview of the container view");
}

- (void)code
{
    [[[UIAlertView alloc] initWithTitle:@"Hi" message:@"hi" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
