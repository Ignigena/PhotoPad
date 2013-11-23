//
//  BPPMainViewController.h
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "MWPhotoBrowser.h"

@interface BPPMainViewController : UIViewController <MWPhotoBrowserDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) MWPhotoBrowser *photosBrowser;
@property (weak, nonatomic) IBOutlet UICollectionView *galleryView;
@property (strong, nonatomic) UIActionSheet *photoToolSheet;
@property (nonatomic) NSUInteger selectedIndex;

- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;

@end
