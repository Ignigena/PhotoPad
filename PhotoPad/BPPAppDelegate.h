//
//  BPPAppDelegate.h
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTTPServer;

@interface BPPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) HTTPServer *httpServer;
@property (strong, nonatomic) UIWindow *window;

@end
