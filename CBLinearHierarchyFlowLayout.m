//
//  CBLinearHierarchyFlowLayout.m
//  CBLinearHierarchy
//
//  Created by Chris Benoit on 12/19/2013.
//  Copyright (c) 2013 Autodesk Inc. All rights reserved.
//

#import "CBLinearHierarchyFlowLayout.h"
#import "CBLinearHierarchyCell.h"

@interface CBLinearHierarchyFlowLayout ()
{
    NSMutableArray* _insertedIndexPaths;
    NSMutableArray* _deletedIndexPaths;
    NSMutableArray* _insertedSections;
    NSMutableArray* _deletedSections;
    id<UICollectionViewDelegateFlowLayout> _flowLayoutDelegagte;
}

@end

@implementation CBLinearHierarchyFlowLayout

-(id)init
{
    self = [super init];
    if (self)
    {
        // these are just defaults that can all be overridden by delegate/subclass
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemSize = CGSizeMake(150, 150);
        self.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.minimumLineSpacing = 0.0;
        self.minimumInteritemSpacing = 0.0f;
        
        _insertedIndexPaths = [[NSMutableArray alloc] init];
        _deletedIndexPaths = [[NSMutableArray alloc] init];
        _insertedSections = [[NSMutableArray alloc] init];
        _deletedSections = [[NSMutableArray alloc] init];
    }
    return self;
}

// frequently we encounter a pattern where certain attributes can be explicitly set, or returned via delegate
// just setting the property is simpler, but it prevents the option for using variable sizes depending on the indexPath
// this convenience method checks to see whether we care about this (if so, the delegate method is used)
- (CGSize)itemSizeAtIndexPath:(NSIndexPath*)indexPath
{
    if (_flowLayoutDelegagte && [_flowLayoutDelegagte respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
    {
        return [_flowLayoutDelegagte collectionView:self.collectionView
                                             layout:self.collectionView.collectionViewLayout
                             sizeForItemAtIndexPath:indexPath];
    } else {
        return self.itemSize;
    }
}

- (CGSize)collectionViewContentSize
{
    int length = 0;
    _flowLayoutDelegagte = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    for (int s = 0; s < [self.collectionView numberOfSections]; s++)
    {
        for (int i = 0; i < [self.collectionView numberOfItemsInSection:s]; i++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:s];
            length +=   (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ?
                        [self itemSizeAtIndexPath:indexPath].width :
                        [self itemSizeAtIndexPath:indexPath].height;
            length += self.minimumInteritemSpacing;
        }
    }
    
    // subtract the last space from the length
    length -= self.minimumInteritemSpacing;
    
    // the size we return depends on whether this is a horizontal or vertical scroller
    // don't leave any extra padding, the contentSize is tight to the height/width of each item
    CGSize sizeToReturn;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
        sizeToReturn = CGSizeMake(length, self.itemSize.height);
    else
        sizeToReturn = CGSizeMake(self.itemSize.width, length);

    return sizeToReturn;
}

- (void)prepareForCollectionViewUpdates:(NSArray*)updates
{
    [super prepareForCollectionViewUpdates:updates];

    for (UICollectionViewUpdateItem* updateItem in updates)
    {
        if (updateItem.updateAction == UICollectionUpdateActionInsert)
        {
            if (updateItem.indexPathAfterUpdate.item != NSNotFound)
                [_insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
            else
                [_insertedSections addObject:[NSNumber numberWithInt:updateItem.indexPathAfterUpdate.section]];
            
        } else if (updateItem.updateAction == UICollectionUpdateActionDelete) {
            
            if (updateItem.indexPathBeforeUpdate.item != NSNotFound)
                [_deletedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
            else
                [_deletedSections addObject:[NSNumber numberWithInt:updateItem.indexPathBeforeUpdate.section]];
        }
    }
}

- (void)finalizeCollectionViewUpdates
{
    [_insertedIndexPaths removeAllObjects];
    [_deletedIndexPaths removeAllObjects];
    [_insertedSections removeAllObjects];
    [_deletedSections removeAllObjects];
}


// For each cell in the specified rect
// Figure out its attributes by calling layoutAttributesForItemAtIndexPath

- (NSArray*) layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributesToReturn = [[NSMutableArray alloc] init];
    
    // use [super layoutAttributesForElementsInRect] mainly as a convenience
    // to get to the visible index paths (there's a number of ways this can be done)
    // we actually return a different array, populated from calls to layoutAttributesForItemAtIndexPath
    for (UICollectionViewLayoutAttributes* attributes in [super layoutAttributesForElementsInRect:rect])
        [attributesToReturn addObject:[self layoutAttributesForItemAtIndexPath:attributes.indexPath]];
    
    return attributesToReturn;
}

// this method used to only get fired for the items that are actually being inserted or removed
// now, it actually gets called on ALL items in the collection
- (UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // start with an empty attributes object
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    int offset = 0;
    attributes.size = [self itemSizeAtIndexPath:indexPath];
    
    // offset for the space needed for the root cells from earlier sections
    for (int i = 0; i < indexPath.section; i++)
    {
        NSIndexPath* parentIndexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        CGSize parentCellSize = [self itemSizeAtIndexPath:parentIndexPath];
        offset += (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? parentCellSize.width : parentCellSize.height;
        offset += self.minimumInteritemSpacing;
    }

    // offset for the space needed for the sibling cells that came earlier
    for (int i = 0; i < indexPath.item; i++)
    {
        NSIndexPath* parentIndexPath = [NSIndexPath indexPathForItem:i inSection:indexPath.section];
        CGSize parentCellSize = [self itemSizeAtIndexPath:parentIndexPath];
        offset += (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? parentCellSize.width : parentCellSize.height;
        offset += self.minimumInteritemSpacing;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
        attributes.center = CGPointMake(offset + attributes.size.width/2, attributes.size.height/2);
    else
        attributes.center = CGPointMake(attributes.size.width/2, offset + attributes.size.height/2);
    
    return attributes;
}

// in this layout, the final position for any deleted item is the same frame as it's "parent" in the hierarchy
// this produces the effect of getting "sucked" back underneath its parent
// to figure this out, multiply the width by the number of sections, while including offset

// this method used to only get fired for the items that are actually being inserted or removed
// now, it actually gets called on ALL items in the collection
- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // an earlier implementation of this method didn't change attributes for items not included in the inserts/deletes
    // unfortunately, it's not that simple
    // for the second part of an expand/collapse animation, we often want an item that was not explicitly involved in insert/delete
    // to still be involved in the animation
    // 2 cases for this
    // 1 - expanding to new hierarchy level to see a cell's children, inserting a section
    //   - that cell, although not part of the deleted items, needs to move to left to become an "active section" cell
    // 2 - collapsing to a previous hierarchy level, deleting a section
    //   - that cell, although not part of the inserted items, needs to move to take its previous position in the list

    // this custom stuff only really needs to happen on finalLayoutAttr
    // for initialLayoutAttr, it's always fine to start from the current position, we only need to adjust where it's going
    
    NSInteger commonSectionInAllDeletedIndexPaths = -1;
    NSInteger commonSectionInAllInsertedIndexPaths = -1;
    if ([_deletedIndexPaths firstObject])
        commonSectionInAllDeletedIndexPaths = [[_deletedIndexPaths firstObject] section];
    if ([_insertedIndexPaths firstObject])
        commonSectionInAllInsertedIndexPaths = [[_insertedIndexPaths firstObject] section];
    
    if (itemIndexPath.section == commonSectionInAllDeletedIndexPaths || itemIndexPath.section == commonSectionInAllInsertedIndexPaths || [_deletedSections containsObject:@(itemIndexPath.section)])
    {
        UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // we always want it to collapse back into an item size of the root node
        NSIndexPath* indexPathToReferenceForSize = [NSIndexPath indexPathForItem:0 inSection:MAX(0, itemIndexPath.section-1)];
        attributes.size = [self itemSizeAtIndexPath:indexPathToReferenceForSize];
        
        CGFloat itemSizeForOffset = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? attributes.size.width : attributes.size.height;
        int offset = ([self.collectionView numberOfSections] - 1) * (itemSizeForOffset + self.minimumInteritemSpacing);

        if ([_deletedIndexPaths containsObject:itemIndexPath])
            attributes.zIndex = -1;
        else
            attributes.zIndex = 0;
        
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
            attributes.center = CGPointMake(offset + attributes.size.width/2, attributes.size.height/2);
        else
            attributes.center = CGPointMake(attributes.size.width/2, offset + attributes.size.height/2);
        
        return attributes;
    } else {
        UICollectionViewLayoutAttributes* attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
        attributes.zIndex = 0;
        return attributes;
    }
}

// in this layout, the initial position for every element is "underneath" its parent, similar to final above
// to find this position, we start from the root and "walk up" the hierarchy to the current indexpath
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if ([_insertedIndexPaths containsObject:itemIndexPath] || [_insertedSections containsObject:@(itemIndexPath.section)])
    {
        UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        //UICollectionViewLayoutAttributes* attributes  = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
        
        // we always want it to start as an item size of the parent root node, or if no parent root node, its own size
        NSIndexPath* indexPathToReferenceForSize = [NSIndexPath indexPathForItem:0 inSection:MAX(0, itemIndexPath.section-1)];
        attributes.size = [self itemSizeAtIndexPath:indexPathToReferenceForSize];
        
        CGFloat itemSizeForOffset = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? attributes.size.width : attributes.size.height;
        int offset = 0;
        for (int i = 0; i < itemIndexPath.section; i++)
            offset += [self.collectionView numberOfItemsInSection:i] * itemSizeForOffset + self.minimumInteritemSpacing;

        attributes.zIndex = -1;
        
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
            attributes.center = CGPointMake(offset - attributes.size.width/2 - self.minimumInteritemSpacing, attributes.size.height/2);
        else
            attributes.center = CGPointMake(attributes.size.width/2, offset - attributes.size.height/2 - self.minimumInteritemSpacing);
        
        return attributes;
    } else {
        UICollectionViewLayoutAttributes* attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
        attributes.zIndex = 0;
        return attributes;
    }
}

/*
 
This was originally a way to generate zIndexes in reverse order
So things earlier in the list would go before things later in the list
But for now, stick with 2 levels (above and below) (0 and -1) just to keep things simpler
 
- (NSInteger) getReverseZIndexForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger numSections = [self.collectionView numberOfSections];
    NSInteger numItems = [self.collectionView numberOfItemsInSection:indexPath.section];
    NSString* firstString = [NSString stringWithFormat:@"%d",(numSections - indexPath.section)];
    NSString* secondString = [NSString stringWithFormat:@"%d",(numItems - indexPath.item)];

    return [[firstString stringByAppendingString:secondString] integerValue];
}
*/

@end
