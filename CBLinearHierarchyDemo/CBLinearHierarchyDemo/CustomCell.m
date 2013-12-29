//
//  CustomCell.m
//  CBLinearHierarchyDemo
//
//  Created by Chris Benoit on 12/27/2013.
//  Copyright (c) 2013 Chris Benoit. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeCenter;
        _cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _cellLabel.textColor = [UIColor whiteColor];
        _cellLabel.font = [UIFont systemFontOfSize:13.0];
        _cellLabel.textAlignment = NSTextAlignmentCenter;
        _cellLabel.numberOfLines = 2;
        _cellLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _cellImage = [[UIImageView alloc] initWithFrame:self.frame];
        [self.contentView addSubview:_cellImage];
        [self.contentView addSubview:_cellLabel];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
