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
#import "NSString+Hex.h"
#import "NSData+MD5.h"

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
    NSLog(@"%@", path);
    if ([path isEqualToString: @"/api/soap/eyefilm/v1"] || [path isEqualToString: @"/api/soap/eyefilm/upload"]) {
        self.parseQueue = [NSOperationQueue new];
        BPPEyeFiResponseParse *parseOperation = [[BPPEyeFiResponseParse alloc] initWithData:self.postData];
        [self.parseQueue addOperation:parseOperation];
        [self.parseQueue waitUntilAllOperationsAreFinished];
        
        if ([parseOperation.eyeFiMethod isEqualToString:@"StartSession"]) {
            return [self startSessionAuthenticate: parseOperation.eyeFiPayload];
        }
        
        return [[HTTPDataResponse alloc] initWithData:[[NSString stringWithFormat:@"communication method: %@ payload: %@", parseOperation.eyeFiMethod, parseOperation.eyeFiPayload] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return FALSE;
}

- (HTTPDataResponse *)startSessionAuthenticate:(NSDictionary *)payload
{
    NSString *credential = [self generateCredentialWithMAC: [payload objectForKey:@"macaddress"] cnonce: [payload objectForKey:@"cnonce"]];
    NSString* result = [NSString stringWithFormat:
                        [self stringForTemplate:@"StartSession"],
                        credential,
                        [self generateRandomToken],
                        [payload objectForKey:@"transfermode"],
                        [payload objectForKey:@"transfermodetimestamp"]];
    
    NSLog(@"RESPONSE SENT:");
    NSLog(@"%@", result);
    
    HTTPDataResponse *response = [[HTTPDataResponse alloc] initWithData:[result dataUsingEncoding:NSUTF8StringEncoding]];
    
    return response;
}

// The authentication credentials are an MD5 hash of macaddress, cnonce and the upload key.
// The upload key can be found at ~/Library/Eye-Fi/Settings.xml on Mac OS X after setting up the card.
- (NSString *)generateCredentialWithMAC:(NSString *)macaddress cnonce:(NSString *)cnonce
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *upload_key = [standardUserDefaults objectForKey:@"upload_key"];
    
    NSLog(@"%@\n%@\n%@", macaddress, cnonce, upload_key);
    NSLog(@"%@\n%@\n%@", [macaddress hex], [cnonce hex], [upload_key hex]);
    
    return [[self createDataWithHexString: [NSString stringWithFormat:@"%@%@%@", macaddress, cnonce, upload_key]] MD5];
}

// Generate a random server token.
-(NSString *)generateRandomToken {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *token = [NSMutableString stringWithCapacity: 32];
    
    for (int i=0; i<32; i++) {
        [token appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return token;
}

// This is required to create the proper data to MD5 encode.
- (NSData *)createDataWithHexString:(NSString *)inputString
{
    NSUInteger inLength = [inputString length];
    
    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
    
    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
    
    NSInteger i, o = 0;
    UInt8 outByte = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 c = inCharacters[i];
        SInt8 value = -1;
        
        if      (c >= '0' && c <= '9') value =      (c - '0');
        else if (c >= 'A' && c <= 'F') value = 10 + (c - 'A');
        else if (c >= 'a' && c <= 'f') value = 10 + (c - 'a');
        
        if (value >= 0) {
            if (i % 2 == 1) {
                outBytes[o++] = (outByte << 4) | value;
                outByte = 0;
            } else {
                outByte = value;
            }
            
        } else {
            if (o != 0) break;
        }
    }
    
    return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}

- (NSString *)stringForTemplate:(NSString *)template
{
    NSString* response = [NSString stringWithFormat:@"%@/%@.xml", [[NSBundle mainBundle] resourcePath], template];
    NSError *error;
    
    return [NSString stringWithContentsOfFile:response encoding:NSUTF8StringEncoding error:&error];
}

@end
