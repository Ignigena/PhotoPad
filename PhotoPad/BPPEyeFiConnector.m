//
//  BPPEyeFiConnector.m
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//
//  Credit for reverse engineered EyeFi server concept:
//    https://github.com/usefulthink/node-eyefi
//    https://code.google.com/p/sceye-fi/wiki/UploadProtocol
//

#import "BPPEyeFiConnector.h"
#import "BPPEyeFiResponseParse.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPDynamicFileResponse.h"
#import "NSString+Hex.h"
#import "NSData+MD5.h"
#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "NSFileManager+Tar.h"

@implementation BPPEyeFiConnector

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    return YES;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
}

- (void)processBodyData:(NSData *)postDataChunk
{
    [parser appendData:postDataChunk];
    
    _postData = postDataChunk;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    if ([path isEqualToString:@"/api/soap/eyefilm/v1/upload"]) {
        // Need to verify the photo was transferred successfully.
        // Currently just returns "success" after a photo is uploaded.
        return [[HTTPDataResponse alloc] initWithData:[[self stringForTemplate:@"UploadPhoto"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    self.parseQueue = [NSOperationQueue new];
    BPPEyeFiResponseParse *parseOperation = [[BPPEyeFiResponseParse alloc] initWithData:self.postData];
    [self.parseQueue addOperation:parseOperation];
    [self.parseQueue waitUntilAllOperationsAreFinished];
    
    NSLog(@"Method is: %@", parseOperation.eyeFiMethod);
    
    if ([parseOperation.eyeFiMethod isEqualToString:@"StartSession"]) {
        return [self startSessionAuthenticate: parseOperation.eyeFiPayload];
    }
    
    if ([parseOperation.eyeFiMethod isEqualToString:@"GetPhotoStatus"]) {
        return [[HTTPDataResponse alloc] initWithData:[[self stringForTemplate:@"GetPhotoStatus"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // The "MarkLastPhotoInRoll" is not required for functionality.
    // Will add it later, skipping now due to time constraints.
    
    return [super httpResponseForMethod:method URI:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	// Inform HTTP server that we expect a body to accompany a POST request
	if([method isEqualToString:@"POST"] && [path isEqualToString:@"/api/soap/eyefilm/v1/upload"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
		// enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

#pragma Multipart data processing.

- (void)processStartOfPartWithHeader:(MultipartMessageHeader*)header {
    test = 1;
	MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
		return;
	}
	NSString* uploadDirPath = [@"~/Documents" stringByExpandingTildeInPath];
	
    _imagePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:_imagePath] ) {
        storeFile = nil;
    }
    else {
		if(![[NSFileManager defaultManager] createFileAtPath:_imagePath contents:nil attributes:nil]) {
			NSLog(@"Could not create file at path: %@", _imagePath);
		}
		storeFile = [NSFileHandle fileHandleForWritingAtPath:_imagePath];
    }
}


- (void)processContent:(NSData*)data WithHeader:(MultipartMessageHeader*)header
{
	if (storeFile) {
		[storeFile writeData:data];
        test++;
	}
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader*)header
{
    if (storeFile) {
        [storeFile closeFile];
    
        storeFile = nil;
    
        NSData* tarData = [NSData dataWithContentsOfFile:_imagePath];
        NSError *error;
        [[NSFileManager defaultManager] createFilesAndDirectoriesAtPath:[@"~/Documents/" stringByExpandingTildeInPath] withTarData:tarData error:&error];
    }
}

#pragma Helper methods.

- (HTTPDataResponse *)startSessionAuthenticate:(NSDictionary *)payload
{
    NSString *credential = [self generateCredentialWithMAC: [payload objectForKey:@"macaddress"] cnonce: [payload objectForKey:@"cnonce"]];
    NSString* result = [NSString stringWithFormat:
                        [self stringForTemplate:@"StartSession"],
                        credential,
                        [self generateRandomToken],
                        [payload objectForKey:@"transfermode"],
                        [payload objectForKey:@"transfermodetimestamp"]];
    
    HTTPDataResponse *response = [[HTTPDataResponse alloc] initWithData:[result dataUsingEncoding:NSUTF8StringEncoding]];
    
    return response;
}

// The authentication credentials are an MD5 hash of macaddress, cnonce and the upload key.
// The upload key can be found at ~/Library/Eye-Fi/Settings.xml on Mac OS X after setting up the card.
- (NSString *)generateCredentialWithMAC:(NSString *)macaddress cnonce:(NSString *)cnonce
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *upload_key = [standardUserDefaults objectForKey:@"upload_key"];
    
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
