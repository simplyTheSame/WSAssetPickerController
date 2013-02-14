//
//  WSAssetTableViewController.m
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


#import "WSAssetTableViewController.h"
#import "WSAssetPickerState.h"
#import "WSAssetsTableViewCell.h"
#import "WSAssetWrapper.h"
#import "WSAssetPickerConfig.h"


#define ASSET_MIN_WIDTH 75
#define PADDING_MIN_WIDTH 4.0
#define BORDER_MIN_WIDTH 4.0


@implementation AssetCellParams

@end


@interface WSAssetTableViewController () <WSAssetsTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *fetchedAssets;
@property (nonatomic, readonly) NSInteger assetsPerRow;
@property (nonatomic, readonly) AssetCellParams *assetCellParams;

@end


@implementation WSAssetTableViewController

@synthesize assetsPerRow = _assetsPerRow;
@synthesize assetCellParams = _assetCellParams;


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setup the toolbar if there are items in the navigationController's toolbarItems.
    if (self.navigationController.toolbarItems.count > 0) {
        self.toolbarItems = self.navigationController.toolbarItems;
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
    
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(self.assetCellParams.borderWidth + navHeight, 0, 0, 0);
    
    self.assetPickerState.state = WSAssetPickerStatePickingAssets;
    
    DLog(@"\n*********************************\n\nShowing Asset Picker\n\n*********************************");
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Hide the toolbar in the event it's being displayed.
    if (self.navigationController.toolbarItems.count > 0) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    if (self.assetPickerConfig.assetTableNavigationItemTitle) {
        self.navigationItem.title = self.assetPickerConfig.assetTableNavigationItemTitle;
    } else {
        if (self.assetsGroup) {
            self.navigationItem.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        } else {
            self.navigationItem.title = @"Loading";
        }
    }
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                           target:self 
                                                                                           action:@selector(doneButtonAction:)];
    
    // TableView configuration.
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.allowsSelection = NO;
    
    // Fetch the assets.
    [self fetchAssets];
}


#pragma mark - Getters

- (NSMutableArray *)fetchedAssets
{
    if (!_fetchedAssets) {
        _fetchedAssets = [NSMutableArray array];
    }
    return _fetchedAssets;
}

- (AssetCellParams *)assetCellParams
{
    if (_assetCellParams.assetsPerRow == 0) {
        
        CGFloat paddingWidth = PADDING_MIN_WIDTH;
        CGFloat assetWidth = ASSET_MIN_WIDTH;

        CGFloat contentWidth = self.tableView.frame.size.width;
        CGFloat assetsPerRow = floorf(contentWidth / (assetWidth + paddingWidth));

        CGFloat assetsWidth = assetsPerRow * assetWidth;
        CGFloat paddingsWidth = (assetsPerRow - 1) * paddingWidth;
        
        CGFloat borderLeft = floorf((contentWidth - (assetsWidth + paddingsWidth)) / 2.0);
        
        if (borderLeft > 2 * paddingWidth) {
            assetWidth = floorf((contentWidth - (assetsPerRow + 1) * paddingWidth) / assetsPerRow);
            
            assetsWidth = assetsPerRow * assetWidth;
            paddingsWidth = (assetsPerRow - 1) * paddingWidth;
            
            borderLeft = floorf((contentWidth - (assetsWidth + paddingsWidth)) / 2.0);
        }
        
        AssetCellParams *params = [AssetCellParams new];
        params.assetWidth = assetWidth;
        params.borderWidth = borderLeft;
        params.paddingWidth = paddingWidth;
        params.assetsPerRow = assetsPerRow;
        
        _assetCellParams = params;
    }
    return _assetCellParams;
}

- (NSInteger)assetsPerRow
{
    return self.assetCellParams.assetsPerRow;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _assetCellParams = nil;
    
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(self.assetCellParams.borderWidth + navHeight, 0, 0, 0);
    [self.tableView reloadData];
}


#pragma mark - Fetching Code

- (void)fetchAssets
{
    // TODO: Listen to ALAssetsLibrary changes in order to update the library if it changes. 
    // (e.g. if user closes, opens Photos and deletes/takes a photo, we'll get out of range/other error when they come back.
    // IDEA: Perhaps the best solution, since this is a modal controller, is to close the modal controller.
    
    dispatch_queue_t enumQ = dispatch_queue_create("AssetEnumeration", NULL);
    
    dispatch_async(enumQ, ^{
        
        NSEnumerationOptions enumnerationOptions = self.assetPickerConfig.assetEnumerationOptions;
        [self.assetsGroup enumerateAssetsWithOptions:enumnerationOptions usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (!result || index == NSNotFound) {
                DLog(@"Done fetching.");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
//                    self.navigationItem.title = [NSString stringWithFormat:@"%@", [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
                });
                
                return;
            }
            
            WSAssetWrapper *assetWrapper = [[WSAssetWrapper alloc] initWithAsset:result];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.fetchedAssets addObject:assetWrapper];
                
            });
            
        }];
    });
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    dispatch_release(enumQ);
#endif

    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

#pragma mark - Actions

- (void)doneButtonAction:(id)sender
{     
    self.assetPickerState.state = WSAssetPickerStatePickingDone;
}


#pragma mark - WSAssetsTableViewCellDelegate Methods

- (void)assetsTableViewCell:(WSAssetsTableViewCell *)cell didSelectAsset:(BOOL)selected atColumn:(NSUInteger)column
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // Calculate the index of the corresponding asset.
    NSUInteger assetIndex = indexPath.row * self.assetsPerRow + column;
    
    WSAssetWrapper *assetWrapper = [self.fetchedAssets objectAtIndex:assetIndex];
    assetWrapper.selected = selected;
    
    // Update the state object's selectedAssets.
    [self.assetPickerState changeSelectionState:selected forAsset:assetWrapper.asset];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"Num Rows: %d", (self.fetchedAssets.count + self.assetsPerRow - 1) / self.assetsPerRow);
    
    return (self.fetchedAssets.count + self.assetsPerRow - 1) / self.assetsPerRow;
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)indexPath
{    
    NSRange assetRange;
    assetRange.location = indexPath.row * self.assetsPerRow;
    assetRange.length = self.assetsPerRow;
    
    // Prevent the range from exceeding the array length.
    if (assetRange.length > self.fetchedAssets.count - assetRange.location) {
        assetRange.length = self.fetchedAssets.count - assetRange.location;
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:assetRange];
    
    // Return the range of assets from fetchedAssets.
    return [self.fetchedAssets objectsAtIndexes:indexSet];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AssetCellIdentifier = @"WSAssetCell";
    WSAssetsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AssetCellIdentifier];
    
    if (cell == nil) {
        cell = [[WSAssetsTableViewCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] assetCellParams:self.assetCellParams reuseIdentifier:AssetCellIdentifier];
    } else {
        cell.cellAssetViews = [self assetsForIndexPath:indexPath];
        cell.assetCellParams = self.assetCellParams;
    }
    
    cell.assetTableViewDelegate = self;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return self.assetCellParams.assetWidth + self.assetCellParams.paddingWidth;
}

@end
