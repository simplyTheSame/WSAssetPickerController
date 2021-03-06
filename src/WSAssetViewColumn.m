//
//  WSAssetView.m
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


#import "WSAssetPickerConfig.h"
#import "WSAssetViewColumn.h"
#import "WSAssetWrapper.h"
#import <QuartzCore/QuartzCore.h>


@interface WSAssetViewColumn ()

@property (nonatomic, weak) UIImageView *selectedView;
@property (nonatomic, weak) UIImageView *videoView;
@property (nonatomic) CGRect assetFrame;

@end


@implementation WSAssetViewColumn


#pragma mark - Initialization

- (id)initWithImage:(UIImage *)thumbnail andFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _assetFrame = frame;
        
        // Setup a tap gesture.
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        // Add the photo thumbnail.
        UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:frame];
        assetImageView.contentMode = UIViewContentModeScaleToFill;
        assetImageView.image = thumbnail;
        assetImageView.layer.borderWidth = 0.5;
        
        if ([UIScreen mainScreen].scale < 1.5) {
            assetImageView.layer.borderWidth = 1.0;
        }
        
        assetImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25].CGColor;
        
        [self addSubview:assetImageView];
    }
    
    return self;
}


#pragma mark - Setters/Getters

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        
        // KVO compliant notifications.
        [self willChangeValueForKey:@"isSelected"];
        _selected = selected;
        [self didChangeValueForKey:@"isSelected"];
        
        // Update the selectedView.
        self.selectedView.hidden = !_selected;
    }
    [self setNeedsDisplay];
}

- (UIImageView *)selectedView
{
    if (!_selectedView) {
        // Lazily create the selectedView.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.selectedAssetImageName]];
        imageView.frame = self.assetFrame;
        imageView.hidden = YES;
        imageView.layer.borderWidth = 0.5;
        if ([UIScreen mainScreen].scale < 1.5) {
            imageView.layer.borderWidth = 1.0;
        }

        imageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
        
        [self addSubview:imageView];
        
        _selectedView = imageView;
    }
    
    return _selectedView;
}


- (void)markAsVideo:(BOOL)isVideo {
    if(!_videoView) {
        UIImageView *videoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.videoAssetImageName]];
        videoView.frame = self.assetFrame;
        _videoView = videoView;
        [self addSubview:videoView];
    }
    
    _videoView.hidden = !isVideo;
}


#pragma mark - Actions

- (void)userDidTapAction:(UITapGestureRecognizer *)sender
{   
    // Tell the delegate.
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        // Set the selection state.
        self.selected = !self.isSelected;
    }
}

@end
