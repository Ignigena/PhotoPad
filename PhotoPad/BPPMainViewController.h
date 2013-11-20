//
//  BPPMainViewController.h
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "BPPFlipsideViewController.h"

@interface BPPMainViewController : UIViewController <BPPFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
