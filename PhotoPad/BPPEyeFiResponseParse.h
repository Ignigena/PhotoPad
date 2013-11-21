//
//  BPPEyeFiResponseParse.h
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPPEyeFiResponseParse : NSOperation <NSXMLParserDelegate>

@property (copy, readonly) NSData *eyeFiData;
@property (strong, nonatomic) NSMutableString *eyeFiMethod;
@property (strong, nonatomic) NSMutableDictionary *eyeFiPayload;

@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;

- (id)initWithData:(NSData *)parseData;

@end
