//
//  DJWViewController.m
//  DJWActionSheet
//
//  Created by Daniel Williams on 02/01/2014.
//  Copyright (c) 2014 Daniel Williams. All rights reserved.
//

#import "DJWViewController.h"
#import "DJWActionSheet.h"

@interface DJWViewController ()

@end

@implementation DJWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showActionSheetButtonTapped:(id)sender
{
    [DJWActionSheet showInView:self.view
                     withTitle:@"@thatgamecompany is not blocked."
             cancelButtonTitle:@"Cancel"
        destructiveButtonTitle:@"Delete"
             otherButtonTitles:@[@"View Replies", @"View Favourites", @"Report Spam"]
                      tapBlock:^(DJWActionSheet *actionSheet, NSInteger tappedButtonIndex) {
                          if (tappedButtonIndex == actionSheet.cancelButtonIndex) {
                              NSLog(@"the user pressed the cancel button!");
                          } else {
                              NSLog(@"The user tapped button at index: %i", tappedButtonIndex);
                          }
                      }];
}

@end
