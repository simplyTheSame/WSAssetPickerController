//
//  WSAssetPickerController.h
//  WSAssetPickerController
//
//  Created by Wesley Smith on 5/12/12.
//  Copyright (c) 2012 Wesley D. Smith. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import <UIKit/UIKit.h>
#import "WSAssetPickerConfig.h"
#import <AssetsLibrary/AssetsLibrary.h>


@protocol WSAssetPickerControllerDelegate;


@interface WSAssetPickerController : UINavigationController

@property (nonatomic, readonly) NSArray *selectedAssets;
@property (nonatomic, readonly) NSUInteger selectedCount; // Observable via key-value observing.

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

// Designated initializer.
- (id)initWithDelegate:(id<WSAssetPickerControllerDelegate>)delegate;

@end


@protocol WSAssetPickerControllerDelegate <NSObject>

// Called when the 'cancel' button it tapped.
- (void)assetPickerControllerDidCancel:(WSAssetPickerController *)picker;

// Called when the done button is tapped.
- (void)assetPickerController:(WSAssetPickerController *)picker didFinishPickingMediaWithAssets:(NSArray *)assets;

@optional

// Called when access to asset library was denied. Enabled so show custom error message to the user.
- (void)assetPickerController:(WSAssetPickerController *)picker didFailWithError:(NSInteger)errorCode;

@end