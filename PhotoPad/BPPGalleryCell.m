//
//  BPPGalleryCell.m
//  PhotoPad
//
//  Created by Albert Martin on 11/22/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "BPPGalleryCell.h"

@interface BPPGalleryCell ()

@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;

@end

@implementation BPPGalleryCell

- (void)setAsset:(UIImage *)asset
{
    _asset = asset;
    self.photoImageView.image = asset;
}

@end