//
//  BPPEyeFiConnector.m
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//
//  Credit for reverse engineered EyeFi server concept:
//    https://npmjs.org/package/eyefi
//    https://code.google.com/p/sceye-fi/wiki/UploadProtocol
//

#import "BPPEyeFiConnector.h"
#import "HTTPDataResponse.h"

@implementation BPPEyeFiConnector

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    return YES;
}

- (void)processBodyData:(NSData *)postDataChunk
{
    _postData = postDataChunk;
    NSLog(@"%@", [[NSString alloc] initWithData:postDataChunk encoding:NSUTF8StringEncoding]);
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    if ([path isEqualToString: @"/api/soap/eyefilm/v1"]) {
        return [[HTTPDataResponse alloc] initWithData:[[NSString stringWithFormat:@"communication method: %@", [[NSString alloc] initWithData:_postData encoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([path isEqualToString: @"/api/soap/eyefilm/upload"]) {
        return [[HTTPDataResponse alloc] initWithData:[@"upload data" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return FALSE;
}

@end
