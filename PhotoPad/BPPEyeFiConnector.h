//
//  BPPEyeFiConnector.h
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface BPPEyeFiConnector : HTTPConnection {
    MultipartFormDataParser* parser;
    NSFileHandle*					storeFile;
    int test;
}

@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSData *postData;
@property (nonatomic) NSOperationQueue *parseQueue;

@end
