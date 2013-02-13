//
//  WSAlbumViewCell.m
//  WSAssetPickerController
//
//  Created by Samuel Mellert on 2/1/13.
//  Copyright (c) 2013 Wesley D. Smith. All rights reserved.
//


#import "WSAlbumViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define kRowHeight 56.0

@implementation WSAlbumViewCell

+ (CGFloat)rowHeight
{
    return kRowHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        int padding = 5;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.albumThumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding,
                                                                                kRowHeight - 2 * padding,
                                                                                kRowHeight - 2 * padding)];
        
        self.albumThumbnailView.clipsToBounds = YES;
        self.albumThumbnailView.layer.cornerRadius = 2.0;
        self.albumThumbnailView.layer.borderWidth = 0.5;
        self.albumThumbnailView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
        
        
        CGFloat labelOriginX = CGRectGetMaxX(self.albumThumbnailView.frame) + padding;
        CGFloat accessoryWidth = CGRectGetWidth(self.accessoryView.bounds);
        CGFloat labelWidth = CGRectGetWidth(self.contentView.bounds) - labelOriginX - accessoryWidth - padding;
        
        self.albumTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX, padding,
                                                                         labelWidth,
                                                                         kRowHeight / 2.0 - padding)];
        
        self.albumTitleLabel.textColor = [UIColor blackColor];
        self.albumTitleLabel.highlightedTextColor = [UIColor whiteColor];
        self.albumTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
        self.albumTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.assetCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelOriginX, kRowHeight / 2.0,
                                                                         labelWidth, kRowHeight / 2.0 - padding)];
        
        self.assetCountLabel.textColor = [UIColor darkGrayColor];
        self.assetCountLabel.highlightedTextColor = [UIColor whiteColor];
        self.assetCountLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        self.assetCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addSubview:self.albumThumbnailView];
        [self.contentView addSubview:self.albumTitleLabel];
        [self.contentView addSubview:self.assetCountLabel];
        
    }
    
    return self;
}

@end
