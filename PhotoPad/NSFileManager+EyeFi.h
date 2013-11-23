//
//  BPPEyeFiFileHandling.h
//  PhotoPad
//
//  Created by Albert Martin on 11/22/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (EyeFi)

- (void)unarchiveEyeFi:(NSString *)path;

@end
