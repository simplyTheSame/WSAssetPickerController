//
//  WSAlbumTableViewController.m
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


#import "WSAlbumTableViewController.h"
#import "WSAssetPickerState.h"
#import "WSAssetTableViewController.h"

#import "WSAlbumViewCell.h"


@interface WSAlbumTableViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetGroups; // Model (all groups of assets).
@property (nonatomic, strong) ALAssetsFilter *filter;

@property ALAssetsGroupType groupTypes;

@end


@implementation WSAlbumTableViewController


#pragma mark - Init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.filter = [ALAssetsFilter allPhotos];
        self.groupTypes = ALAssetsGroupAll;
    }
    
    return self;
}

#pragma mark - Getters 

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSMutableArray *)assetGroups
{
    if (!_assetGroups) {
        _assetGroups = [NSMutableArray array];
    }
    
    return _assetGroups;
}



#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.assetPickerState.state = WSAssetPickerStatePickingAlbum;
    
    DLog(@"\n*********************************\n\nShowing Album Picker\n\n*********************************");
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.assetPickerConfig.albumTableNavigationItemTitle;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancelButtonAction:)];
    
    [self.assetsLibrary enumerateGroupsWithTypes:self.groupTypes usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // If group is nil, the end has been reached.
        if (group == nil) {
            if (self.assetPickerConfig.isAlbumSortingAlphabeticaly) {
                [self.assetGroups sortUsingComparator:^NSComparisonResult(ALAssetsGroup *group1, ALAssetsGroup* group2) {
                    return [[group1 valueForProperty:ALAssetsGroupPropertyName] compare:[group2 valueForProperty:ALAssetsGroupPropertyName] options:NSCaseInsensitiveSearch];
                }];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
            });
            
            return;
        }

        [group setAssetsFilter:self.filter];

        if (![group numberOfAssets]) {
            // No sense showing empty groups/albums
            return;
        }

        // Add the group to the array.
        [self.assetGroups addObject:group];
        
        // Reload the tableview on the main thread.
        if (!self.assetPickerConfig.isAlbumSortingAlphabeticaly) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }        
    } failureBlock:^(NSError *error) {
        id <WSAssetPickerControllerDelegate> delegate = (id <WSAssetPickerControllerDelegate>)self.pickerDelegate;
        
        if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryAccessGloballyDeniedError) {
            NSLog(@"errorCode: %d", error.code);
            if ([delegate respondsToSelector:@selector(assetPickerControllerDidFailWithError)]) {
                [delegate assetPickerController:self.assetPickerController didFailWithError:error.code];
            }
        }

    }];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma  mark - Actions

- (void)cancelButtonAction:(id)sender 
{    
    self.assetPickerState.state = WSAssetPickerStatePickingCancelled;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.assetGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WSAlbumCell";
    WSAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[WSAlbumViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the group from the datasource.
    ALAssetsGroup *group = [self.assetGroups objectAtIndex:indexPath.row];
    
    // Setup the cell.
    cell.albumTitleLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.assetCountLabel.text = [NSString stringWithFormat:self.assetPickerConfig.albumTableAssetCountLabelFormat, [group numberOfAssets]];
    cell.albumThumbnailView.image = [UIImage imageWithCGImage:[group posterImage]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = [self.assetGroups objectAtIndex:indexPath.row];
    
    WSAssetTableViewController *assetTableViewController = [[WSAssetTableViewController alloc] initWithStyle:UITableViewStylePlain];
    assetTableViewController.assetPickerState = self.assetPickerState;
    assetTableViewController.assetsGroup = group;
    assetTableViewController.assetPickerConfig = self.assetPickerConfig;
    
    [self.navigationController pushViewController:assetTableViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	return [WSAlbumViewCell rowHeight];
}

@end
