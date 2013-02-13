//
//  WSAlbumViewCell.h
//  WSAssetPickerController
//
//  Created by Samuel Mellert on 2/1/13.
//  Copyright (c) 2013 Wesley D. Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAlbumViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *albumThumbnailView;
@property (nonatomic, strong) UILabel *albumTitleLabel;
@property (nonatomic, strong) UILabel *assetCountLabel;

+ (CGFloat)rowHeight;

@end
