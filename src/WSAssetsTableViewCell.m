//
//  WSAssetsTableViewCell.m
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


#import "WSAssetsTableViewCell.h"
#import "WSAssetWrapper.h"
#import "WSAssetViewColumn.h"


@implementation WSAssetsTableViewCell

+ (WSAssetsTableViewCell *)assetsCellWithAssets:(NSArray *)assets reuseIdentifier:(NSString *)identifier
{
    WSAssetsTableViewCell *cell = [[WSAssetsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.cellAssetViews = assets;
    
    return cell;
}

- (id)initWithAssets:(NSArray *)assets assetCellParams:(AssetCellParams *)assetCellParams reuseIdentifier:(NSString *)identifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
        self.assetCellParams = assetCellParams;
        self.cellAssetViews = assets;
    }
    
    return self;
}

- (void)stopObserving
{
    // Remove the old WSAssetViews.    
    for (WSAssetViewColumn *assetViewColumn in self.cellAssetViews) {
        
        [assetViewColumn removeObserver:self forKeyPath:@"isSelected"];
        [assetViewColumn removeFromSuperview];
    }
}

- (void)setCellAssetViews:(NSArray *)assets
{
    // Remove the old WSAssetViews.    
    [self stopObserving];
    
    // Create new WSAssetViews
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[assets count]];
    
    for (WSAssetWrapper *assetWrapper in assets) {
        CGRect frame = CGRectMake(0, 0, self.assetCellParams.assetWidth, self.assetCellParams.assetWidth);
        WSAssetViewColumn *assetViewColumn = [[WSAssetViewColumn alloc] initWithImage:[UIImage imageWithCGImage:assetWrapper.asset.thumbnail] andFrame:frame];
        assetViewColumn.selectedAssetImageName = self.assetPickerConfig.selectedAssetImageName;
        assetViewColumn.videoAssetImageName = self.assetPickerConfig.videoAssetImageName;
        
        if ([[assetWrapper.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            [assetViewColumn markAsVideo:YES];
        }
        
        assetViewColumn.column = [assets indexOfObject:assetWrapper];
        assetViewColumn.selected = assetWrapper.isSelected;
        
        // Observe the column's isSelected property.
        [assetViewColumn addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionNew context:NULL];
        
        [columns addObject:assetViewColumn];
    }
    
    _cellAssetViews = columns;
}


- (void)layoutSubviews
{
    // Calculate the container's width.
    int assetsPerRow = self.assetCellParams.assetsPerRow;
    float containerWidth = assetsPerRow * self.assetCellParams.assetWidth + (assetsPerRow - 1) * self.assetCellParams.paddingWidth;
    
    // Create the container frame dynamically.
    CGRect containerFrame;
    containerFrame.origin.x = self.assetCellParams.borderWidth;
    containerFrame.origin.y = 0;
    containerFrame.size.width = containerWidth;
    containerFrame.size.height = self.assetCellParams.assetWidth;
    
    // Create a containing view with flexible margins.
    UIView *assetsContainerView = [[UIView alloc] initWithFrame:containerFrame];
    CGRect frame = CGRectMake(0, 0, self.assetCellParams.assetWidth, self.assetCellParams.assetWidth);
    
    for (WSAssetViewColumn *assetView in self.cellAssetViews) {
        assetView.frame = frame;
        [assetsContainerView addSubview:assetView];
        
        // Adjust the frame x-origin of the next assetView.
        frame.origin.x = frame.origin.x + frame.size.width + self.assetCellParams.paddingWidth;
    }                                              
    
    [self addSubview:assetsContainerView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isMemberOfClass:[WSAssetViewColumn class]]) {
        
        WSAssetViewColumn *column = (WSAssetViewColumn *)object;
        if ([self.assetTableViewDelegate respondsToSelector:@selector(assetsTableViewCell:didSelectAsset:atColumn:)]) {
            [self.assetTableViewDelegate assetsTableViewCell:self didSelectAsset:column.isSelected atColumn:column.column];
        }
    }
}

- (void)dealloc
{
    [self stopObserving];
}

@end
