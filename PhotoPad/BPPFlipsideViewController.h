//
//  BPPFlipsideViewController.h
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPPFlipsideViewController;

@protocol BPPFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(BPPFlipsideViewController *)controller;
@end

@interface BPPFlipsideViewController : UIViewController

@property (weak, nonatomic) id <BPPFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
