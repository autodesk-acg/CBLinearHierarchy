//
//  CBLinearHierarchyCell.m
//  CBLinearHierarchy
//
//  Created by Chris Benoit on 12/19/2013.
//  Copyright (c) 2013 Autodesk Inc. All rights reserved.
//


#import "CBLinearHierarchyCell.h"

@implementation CBLinearHierarchyCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _name = @"";
        _active = NO;
        _dynamic = NO;
        _hierarchyLevel = 0;
    }
    return self;
}

- (void)setActive:(BOOL)active
{
    if (active) {
        self.contentView.backgroundColor = [self.cellDelegate activeLHCellColor];
    } else {
        self.contentView.backgroundColor = [self.cellDelegate normalLHCellColor];
    }
    _active = active;
    return;
}

+ (CGSize)defaultCellSize
{
    return CGSizeMake(100, 100);
}

@end
