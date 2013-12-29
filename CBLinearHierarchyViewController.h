//
//  CBLinearHierarchyViewController.h
//  CBLinearHierarchy
//
//  Created by Chris Benoit on 12/19/2013.
//  Copyright (c) 2013 Autodesk Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CBLinearHierarchyCell.h"

#define kHierarchyNavigatorCellID @"CBLinearHierarchyNavigatorCell"
#define kHierarchyNavigatorKeyChildren @"children"
#define kHierarchyNavigatorKeyName @"name"
#define kHierarchyNavigatorKeyType @"type"
#define kHierarchyNavigatorTypeDynamic @"dynamic"
#define kHierarchyNavigatorTypeStatic @"static"
#define kHierarchyNavigatorKeyEditable @"editable"

@protocol CBLinearHierarchyCellManagerProtocol <NSObject>

- (NSString*) cellReuseIdentifierForHierarchyNavigator;
- (void) registerClassForCBLinearHierarchyCell;

@end

@interface CBLinearHierarchyViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CBLinearHierarchyCellProtocol>

@property (nonatomic, strong) NSArray* hierarchyItems;
@property (readonly, nonatomic, strong) NSMutableArray* currentItems;
@property (readonly, nonatomic, assign) int hierarchyLevel;

@property (nonatomic, strong) UIColor* activeLHCellColor;
@property (nonatomic, strong) UIColor* normalLHCellColor;

// this is used in case we want another view controller to specify a different subclass other than the default "CBLinearHierarchyCell"
@property (nonatomic, assign) id<CBLinearHierarchyCellManagerProtocol> lhCellManagerDelegate;

- (void)  collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
             expandBlock:(void (^)())expandBlock
           collapseBlock:(void (^)())collapseBlock;

- (void)collapseCurrentLevelForCellAtIndexPath:(NSIndexPath*)indexPath
                               completionBlock:(void (^)())completionBlock;

- (void)expandNewLevelForCellAtIndexPath:(NSIndexPath*)indexPath
                         completionBlock:(void (^)())completionBlock;

- (NSString*) cellReuseIdentifierForHierarchyNavigator;
- (void) registerClassForCBLinearHierarchyCell;

@end
