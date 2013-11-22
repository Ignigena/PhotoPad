//
//  BPPEyeFiResponse.m
//  PhotoPad
//
//  Created by Albert Martin on 11/21/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "BPPEyeFiResponse.h"

@implementation BPPEyeFiResponse

- (NSDictionary *)httpHeaders
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Close", @"Connection",
            @"no-cache", @"Pragma",
            @"Eye-Fi Agent/3.4.35 (Mac OS X - 10.9)", @"Server",
            @"text/xml; charset=\"utf-8\"", @"Content-Type",
            nil];
}

@end
