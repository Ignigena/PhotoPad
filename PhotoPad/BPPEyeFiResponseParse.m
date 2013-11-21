//
//  BPPEyeFiResponseParse.m
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "BPPEyeFiResponseParse.h"

@implementation BPPEyeFiResponseParse {
    BOOL _accumulatingParsedCharacterData;
}

- (id)initWithData:(NSData *)parseData {
    self = [super init];
    if (self) {
        _eyeFiData = [parseData copy];
        _eyeFiMethod = [[NSMutableString alloc] init];
        _eyeFiPayload = [[NSMutableDictionary alloc] init];
        _currentParsedCharacterData = [[NSMutableString alloc] init];
    }
    return self;
}

// The main function for this NSOperation, to start the parsing.
- (void)main {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.eyeFiData];
    [parser setDelegate:self];
    [parser parse];
}

// Called when an element starts parsing.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // Determine what method is being called by the EyeFi card.
    if ([[elementName substringToIndex:4] isEqualToString:@"ns1:"]) {
        [self.eyeFiMethod setString: [elementName componentsSeparatedByString:@":"][1]];
        return;
    }
    
    // Parse out the elements we care about and add to the payload.
    if ([elementName isEqualToString:@"cnonce"] ||
        [elementName isEqualToString:@"credential"] ||
        [elementName isEqualToString:@"filename"] ||
        [elementName isEqualToString:@"filesize"] ||
        [elementName isEqualToString:@"macaddress"] ||
        [elementName isEqualToString:@"transfermode"]) {
        // Start accumulating parsed character data.
        _accumulatingParsedCharacterData = YES;
        // Reset the accumuluated string.
        [self.currentParsedCharacterData setString:@""];
        return;
    }
}

// During parsing.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // Keep the string if we care about it.
    if (_accumulatingParsedCharacterData) {
        [_currentParsedCharacterData appendString:string];
    }
}

// Called when an element finishes parsing.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (_accumulatingParsedCharacterData) {
        [_eyeFiPayload setObject:[NSString stringWithFormat:@"%@", self.currentParsedCharacterData] forKey:elementName];
    }
    
    // Stop accumulating parsed character data.
    _accumulatingParsedCharacterData = NO;
}

@end
