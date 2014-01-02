//
//  CustomCell.h
//  CBLinearHierarchyDemo
//
//  Created by Chris Benoit on 12/27/2013.
//  Copyright (c) 2013 Autodesk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBLinearHierarchyCell.h"

@interface CustomCell : CBLinearHierarchyCell

@property (nonatomic, strong) UILabel* cellLabel;
@property (nonatomic, strong) UIImageView* cellImage;

@end
