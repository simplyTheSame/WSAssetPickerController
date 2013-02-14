//
//  WSAssetPickerConfig.m
//  WSAssetPickerController
//
//  Created by Samuel Mellert on 2/10/13.
//  Copyright (c) 2013 Wesley D. Smith. All rights reserved.
//


#import "WSAssetPickerConfig.h"


#define DEFAULT_SELECTED_ASSET_IMAGE_NAME                   @"WSAssetViewSelectionIndicator.png"
#define DEFAULT_VIDEO_ASSET_IMAGE_NAME                      @"WSAssetViewVideoIndicator.png"

#define ALBUM_PICKER_NAVIGATION_ITEM_TITLE_KEY              @"wsassetpicker_albumPickerNavigationItemTitle"
#define ASSET_PICKER_NAVIGATION_ITEM_TITLE_KEY              @"wsassetpicker_assetPickerNavigationItemTitle"
#define ALBUM_PICKER_ASSET_COUNT_FORMAT_KEY                 @"wsassetpicker_albumPickerAssetCountLabelFormat"

#define STRINGS_TABLE_NAME                                  @"WSAssetPicker"


@implementation WSAssetPickerConfig

@synthesize albumTableAssetCountLabelFormat = _albumTableAssetCountLabelFormat;
@synthesize assetTableNavigationItemTitle = _assetTableNavigationItemTitle;
@synthesize videoAssetImageName = _videoAssetImageName;
@synthesize selectedAssetImageName = _selectedAssetImageName;

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
    if (!_albumTableAssetCountLabelFormat) {
        _albumTableAssetCountLabelFormat = [self userOverrideableStringForKey:ALBUM_PICKER_ASSET_COUNT_FORMAT_KEY];
    }
    
    return _albumTableAssetCountLabelFormat;
}

- (NSString *)albumTableNavigationItemTitle
{
    if (!_albumTableNavigationItemTitle) {
        _albumTableNavigationItemTitle = [self userOverrideableStringForKey:ALBUM_PICKER_NAVIGATION_ITEM_TITLE_KEY];
    }
    
    return _albumTableNavigationItemTitle;
}

- (NSString *)assetTableNavigationItemTitle
{
    if (!_assetTableNavigationItemTitle) {
        NSString *titleString = NSLocalizedString(ASSET_PICKER_NAVIGATION_ITEM_TITLE_KEY, nil);
        if (![titleString isEqualToString:ASSET_PICKER_NAVIGATION_ITEM_TITLE_KEY]) {
            return titleString;
        }
    }
    
    return _assetTableNavigationItemTitle;
}

- (void)setSelectedAssetImageName:(NSString *)selectedAssetImageName
{
    if ([UIImage imageNamed:selectedAssetImageName]) {
        _selectedAssetImageName = selectedAssetImageName;
    } else {
        NSLog(@"Warning: specified image '%@' for selected asset not found!", selectedAssetImageName);
    }
}

- (NSString *)userOverrideableStringForKey:(NSString *)stringKey
{
    NSString *userDefinedString = NSLocalizedString(stringKey, nil);
    if (![userDefinedString isEqualToString:stringKey]) {
        return userDefinedString;
    }
    
    return NSLocalizedStringFromTable(stringKey, STRINGS_TABLE_NAME, nil);
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

- (ALAssetsFilter *)assetsFilter
{
    if (!_assetsFilter) {
        _assetsFilter = [ALAssetsFilter allPhotos];
    }
    
    return _assetsFilter;
}

- (ALAssetsGroupType)assetsGroupTypes
{
    if (_assetsGroupTypes == 0) {
        _assetsGroupTypes = ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupLibrary | ALAssetsGroupPhotoStream;
    }
        
    return _assetsGroupTypes;
}

@end
