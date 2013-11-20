//
//  BPPEyeFiConnector.h
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@interface BPPEyeFiConnector : HTTPConnection

@property (strong, nonatomic) NSData *postData;

@end
