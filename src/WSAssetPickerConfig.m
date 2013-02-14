//
//  WSAssetPickerConfig.m
//  WSAssetPickerController
//
//  Created by Samuel Mellert on 2/10/13.
//  Copyright (c) 2013 Wesley D. Smith. All rights reserved.
//


#import "WSAssetPickerConfig.h"


#define DEFAULT_SELECTED_ASSET_IMAGE_NAME          @"WSAssetViewSelectionIndicator.png"
#define DEFAULT_VIDEO_ASSET_IMAGE_NAME             @"WSAssetViewVideoIndicator.png"
#define DEFAULT_NAVIGATION_ITEM_TITLE              NSLocalizedString(@"albumPickerNavigationItemTitle", nil)
#define DEFAULT_ASSET_COUNT_FORMAT                 NSLocalizedString(@"assetCountLabelFormat", nil)


@implementation WSAssetPickerConfig

@synthesize albumTableAssetCountLabelFormat = _albumTableAssetCountLabelFormat;
@synthesize videoAssetImageName = _videoAssetImageName;
@synthesize selectedAssetImageName = _selectedAssetImageName;

+ (WSAssetPickerConfig *)sharedInstance
{
    static dispatch_once_t once;
    static WSAssetPickerConfig *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _albumSortingAlphabeticaly = YES;
        _assetEnumerationOptions = NSEnumerationReverse;
    }
    
    return self;
}

- (void)setAlbumTableAssetCountLabelFormat:(NSString *)albumTableAssetCountLabelFormat
{
    if ([albumTableAssetCountLabelFormat rangeOfString:@"%d"].length > 0) {
        _albumTableAssetCountLabelFormat = albumTableAssetCountLabelFormat;
    } else {
        NSLog(@"Warning: invalid albumTableAssetCountLabelFormat specified!");
    }
}

- (NSString *)albumTableAssetCountLabelFormat
{
    return _albumTableAssetCountLabelFormat ? _albumTableAssetCountLabelFormat : DEFAULT_ASSET_COUNT_FORMAT;
}

- (NSString *)albumTableNavigationItemTitle
{
    return _albumTableNavigationItemTitle ? _albumTableNavigationItemTitle : DEFAULT_NAVIGATION_ITEM_TITLE;
}

- (void)setSelectedAssetImageName:(NSString *)selectedAssetImageName
{
    if ([UIImage imageNamed:selectedAssetImageName]) {
        _selectedAssetImageName = selectedAssetImageName;
    } else {
        NSLog(@"Warning: specified image '%@' for selected asset not found!", selectedAssetImageName);
    }
}

- (NSString *)selectedAssetImageName
{
    return _selectedAssetImageName ? _selectedAssetImageName : DEFAULT_SELECTED_ASSET_IMAGE_NAME;
}

- (void)setVideoAssetImageName:(NSString *)videoAssetImageName
{
    if ([UIImage imageNamed:videoAssetImageName]) {
        _videoAssetImageName = videoAssetImageName;
    } else {
        NSLog(@"Warning: specified image '%@' for video asset not found!", videoAssetImageName);
    }
}

- (NSString *)videoAssetImageName
{
    return _videoAssetImageName ? _videoAssetImageName : DEFAULT_VIDEO_ASSET_IMAGE_NAME;
}

@end
