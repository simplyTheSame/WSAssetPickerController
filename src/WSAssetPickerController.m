//
//  WSAssetPickerController.m
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


#import "WSAssetPickerController.h"
#import "WSAssetPickerState.h"
#import "WSAlbumTableViewController.h"


@interface WSAssetPickerController ()

@property (nonatomic, strong) WSAssetPickerState *assetPickerState;
@property (nonatomic, readwrite) NSUInteger selectedCount;
@property (nonatomic) UIStatusBarStyle originalStatusBarStyle;
@property (nonatomic, strong) WSAlbumTableViewController *albumTableViewController;
@property (nonatomic, weak) id<WSAssetPickerControllerDelegate> pickerDelegate;
@property (nonatomic, strong) WSAssetPickerConfig *pickerConfig;

@end


@implementation WSAssetPickerController

@dynamic selectedAssets;


#pragma mark - Initialization

- (id)initWithDelegate:(id <WSAssetPickerControllerDelegate>)delegate;
{
    self.pickerConfig = [[WSAssetPickerConfig alloc] init];
    
    // Create the Album TableView Controller.
    self.albumTableViewController = [[WSAlbumTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.albumTableViewController.assetPickerState = self.assetPickerState;
    self.albumTableViewController.assetPickerConfig = self.pickerConfig;
    self.albumTableViewController.assetPickerController = self;
    self.albumTableViewController.pickerDelegate = delegate;
    
    if ((self = [super initWithRootViewController:self.albumTableViewController])) {
        self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.toolbar.barStyle = UIBarStyleBlackTranslucent;
        self.pickerDelegate = delegate;
    }
    
    return self;
}

#define STATE_KEY @"state"
#define SELECTED_COUNT_KEY @"selectedCount"

- (WSAssetPickerState *)assetPickerState
{
    if (!_assetPickerState) {
        _assetPickerState = [[WSAssetPickerState alloc] init];
    }
    return _assetPickerState;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    // Start observing state changes and selectedCount changes.
    [_assetPickerState addObserver:self forKeyPath:STATE_KEY options:NSKeyValueObservingOptionNew context:NULL];
    [_assetPickerState addObserver:self forKeyPath:SELECTED_COUNT_KEY options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.originalStatusBarStyle animated:YES];
    
    // Stop observing state changes and selectedCount changes.
    [_assetPickerState removeObserver:self forKeyPath:STATE_KEY];
    [_assetPickerState removeObserver:self forKeyPath:SELECTED_COUNT_KEY];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{    
    if (![object isEqual:self.assetPickerState]) return;
    
    if ([STATE_KEY isEqualToString:keyPath]) {     
        
        DLog(@"State Changed: %@", change);
        
        // Cast the delegate to the assetPickerDelegate.
        id <WSAssetPickerControllerDelegate> delegate = (id <WSAssetPickerControllerDelegate>)self.pickerDelegate;
        
        if (WSAssetPickerStatePickingCancelled == self.assetPickerState.state) {
            if ([delegate conformsToProtocol:@protocol(WSAssetPickerControllerDelegate)]) {
                [delegate assetPickerControllerDidCancel:self];
            }
        } else if (WSAssetPickerStatePickingDone == self.assetPickerState.state) {
            if ([delegate conformsToProtocol:@protocol(WSAssetPickerControllerDelegate)]) {
                [delegate assetPickerController:self didFinishPickingMediaWithAssets:self.assetPickerState.selectedAssets];
            }
        }
    } else if ([SELECTED_COUNT_KEY isEqualToString:keyPath]) {
        
        self.selectedCount = self.assetPickerState.selectedCount;
        DLog(@"Total selected: %d", self.assetPickerState.selectedCount);
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Configuration -

- (void)setAssetsFilter:(ALAssetsFilter *)assetsFilter
{
    self.pickerConfig.assetsFilter = assetsFilter;
}

- (void)setAssetsGroupTypes:(ALAssetsGroupType)assetsGroupTypes
{
    self.pickerConfig.assetsGroupTypes = assetsGroupTypes;
}

- (void)setAlbumSortingAlphabeticaly:(BOOL)albumSortingAlphabeticaly
{
    self.pickerConfig.albumSortingAlphabeticaly = albumSortingAlphabeticaly;
}

- (void)setAssetEnumerationOptions:(NSEnumerationOptions)assetEnumerationOptions
{
    self.pickerConfig.assetEnumerationOptions = assetEnumerationOptions;
}

- (void)setAlbumTableNavigationItemTitle:(NSString *)albumTableNavigationItemTitle
{
    self.pickerConfig.albumTableNavigationItemTitle = albumTableNavigationItemTitle;
}

- (void)setAlbumTableAssetCountLabelFormat:(NSString *)albumTableAssetCountLabelFormat
{
    self.pickerConfig.albumTableAssetCountLabelFormat = albumTableAssetCountLabelFormat;
}

- (void)setAssetTableNavigationItemTitle:(NSString *)assetTableNavigationItemTitle
{
    self.pickerConfig.assetTableNavigationItemTitle = assetTableNavigationItemTitle;
}

- (void)setSelectedAssetImageName:(NSString *)selectedAssetImageName
{
    self.pickerConfig.selectedAssetImageName = selectedAssetImageName;
}

- (void)setVideoAssetImageName:(NSString *)videoAssetImageName
{
    self.pickerConfig.videoAssetImageName = videoAssetImageName;
}

@end
