//
//  BPPMainViewController.m
//  PhotoPad
//
//  Created by Albert Martin on 11/20/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "BPPMainViewController.h"
#import "BPPGalleryCell.h"
#import "NSFileManager+Tar.h"

@interface BPPMainViewController ()

@end

@implementation BPPMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateTitle)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateGallery:)
                                                name:@"EyeFiUnarchiveComplete"
                                              object:nil];
    
    // Create array of `MWPhoto` objects
    _photos = [[NSMutableArray array] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    [_photos addObjectsFromArray: [[NSBundle bundleWithPath:[paths objectAtIndex:0]] pathsForResourcesOfType:@".JPG" inDirectory:nil]];
    
    // Setup the photo browser.
    _photosBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [_photosBrowser showPreviousPhotoAnimated:YES];
    [_photosBrowser showNextPhotoAnimated:YES];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTitle
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *windowTitle = [standardUserDefaults objectForKey:@"window_title"];
    self.navigationController.navigationBar.topItem.title = (windowTitle) ? windowTitle : @"Browse All Photos";
}

- (void)updateGallery:(NSNotification *) notification
{
    [_photos addObject: [notification.userInfo objectForKey:@"path"]];
    [_galleryView reloadData];
}

#pragma mark - Photo Gallery

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BPPGalleryCell *cell = (BPPGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    cell.asset = [self imageWithImage: [UIImage imageWithContentsOfFile:self.photos[indexPath.row]] scaledToFillSize:CGSizeMake(200, 200)];
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_photosBrowser setCurrentPhotoIndex:indexPath.row];
    [self.navigationController pushViewController:_photosBrowser animated:YES];
}

#pragma mark - Photo Browser

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[self.photos objectAtIndex:index]]];
    return nil;
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(BPPFlipsideViewController *)controller
{
    [self.flipsidePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.flipsidePopoverController = popoverController;
        popoverController.delegate = self;
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
