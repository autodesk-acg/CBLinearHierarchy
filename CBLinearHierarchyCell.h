//
//  CBLinearHierarchyCell.h
//  CBLinearHierarchy
//
//  Created by Chris Benoit on 12/19/2013.
//  Copyright (c) 2013 Autodesk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CBLinearHierarchyCellProtocol <NSObject>

@property (nonatomic, strong) UIColor* activeLHCellColor;
@property (nonatomic, strong) UIColor* normalLHCellColor;

@end

@interface CBLinearHierarchyCell : UICollectionViewCell

@property (nonatomic, assign) NSString* name;
@property (nonatomic, strong) NSArray* children;

@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL dynamic;
@property (nonatomic, assign) int hierarchyLevel;

@property (nonatomic, weak) id<CBLinearHierarchyCellProtocol> cellDelegate;

+ (CGSize)defaultCellSize;

@end
