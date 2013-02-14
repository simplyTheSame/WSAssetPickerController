//
//  WSAssetPickerConfig.h
//  WSAssetPickerController
//
//  Created by Samuel Mellert on 2/10/13.
//  Copyright (c) 2013 Wesley D. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAssetPickerConfig : NSObject

// filtering
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic) ALAssetsGroupType assetsGroupTypes;

// sorting
@property (nonatomic, getter = isAlbumSortingAlphabeticaly) BOOL albumSortingAlphabeticaly;
@property (nonatomic) NSEnumerationOptions assetEnumerationOptions;

// strings
@property (nonatomic, strong) NSString *albumTableNavigationItemTitle;
@property (nonatomic, strong) NSString *albumTableAssetCountLabelFormat;
@property (nonatomic, strong) NSString *assetTableNavigationItemTitle;

// indicator images
@property (nonatomic, strong) NSString *selectedAssetImageName;
@property (nonatomic, strong) NSString *videoAssetImageName;

@end
