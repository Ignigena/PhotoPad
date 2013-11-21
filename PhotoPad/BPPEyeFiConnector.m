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
#import "BPPEyeFiResponseParse.h"
#import "HTTPDataResponse.h"

@implementation BPPEyeFiConnector

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    return YES;
}

- (void)processBodyData:(NSData *)postDataChunk
{
    _postData = postDataChunk;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    if ([path isEqualToString: @"/api/soap/eyefilm/v1"] || [path isEqualToString: @"/api/soap/eyefilm/upload"]) {
        self.parseQueue = [NSOperationQueue new];
        BPPEyeFiResponseParse *parseOperation = [[BPPEyeFiResponseParse alloc] initWithData:self.postData];
        [self.parseQueue addOperation:parseOperation];
        [self.parseQueue waitUntilAllOperationsAreFinished];
        
        return [[HTTPDataResponse alloc] initWithData:[[NSString stringWithFormat:@"communication method: %@ payload: %@", parseOperation.eyeFiMethod, parseOperation.eyeFiPayload] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return FALSE;
}

@end
