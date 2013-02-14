//
//  WSAssetPickerConfig.h
//  WSAssetPickerController
//
//  Created by Samuel Mellert on 2/10/13.
//  Copyright (c) 2013 Wesley D. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAssetPickerConfig : NSObject

+ (WSAssetPickerConfig *)sharedInstance;

@property (nonatomic, strong) NSString *albumTableNavigationItemTitle;
@property (nonatomic, strong) NSString *albumTableAssetCountLabelFormat;
@property (nonatomic, getter = isAlbumSortingAlphabeticaly) BOOL albumSortingAlphabeticaly;
@property (nonatomic, strong) NSString *selectedAssetImageName;
@property (nonatomic, strong) NSString *videoAssetImageName;

@end
