//
//  BPPEyeFiFileHandling.m
//  PhotoPad
//
//  Created by Albert Martin on 11/22/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "NSFileManager+EyeFi.h"
#import "NSFileManager+Tar.h"

@implementation NSFileManager (EyeFi)

- (void)unarchiveEyeFi:(NSString *)path
{
    NSFileManager *files = [NSFileManager defaultManager];
    NSData* tarData = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
    NSString *filename = pathComponents[[pathComponents count]-1];
    
    [files createFilesAndDirectoriesAtPath:[path stringByReplacingOccurrencesOfString:filename withString:@""] withTarData:tarData error:&error];
    [files removeItemAtPath:path error:&error];
    [files removeItemAtPath:[path stringByReplacingOccurrencesOfString:@".tar" withString:@".log"] error:&error];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"EyeFiUnarchiveComplete" object:nil userInfo:[NSDictionary dictionaryWithObject:[path stringByReplacingOccurrencesOfString:@".tar" withString:@""] forKey:@"path"]];
}

@end
