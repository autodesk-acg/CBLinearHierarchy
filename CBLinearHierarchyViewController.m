//
//  CBLinearHierarchyViewController.m
//  CBLinearHierarchy
//
//  Created by Chris Benoit on 12/19/2013.
//  Copyright (c) 2013 Autodesk Inc. All rights reserved.
//


#import "CBLinearHierarchyViewController.h"
#import "CBLinearHierarchyCell.h"

@interface CBLinearHierarchyViewController ()

// set some properties as readonly for subclasses, but readwrite for itself
@property (readwrite, nonatomic, assign) int hierarchyLevel;
@property (readwrite, nonatomic, strong) NSMutableArray* currentItems;

@end

@implementation CBLinearHierarchyViewController

@synthesize hierarchyItems = _hierarchyItems;

- (void) dealloc
{
    self.currentItems = nil;
    self.hierarchyItems = nil;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        self.hierarchyLevel = 0;
        self.currentItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* cellIdentifier;
    if (self.lhCellManagerDelegate)
    {
        cellIdentifier = [self.lhCellManagerDelegate cellReuseIdentifierForHierarchyNavigator];
        [self.lhCellManagerDelegate registerClassForCBLinearHierarchyCell];
    } else {
        cellIdentifier = [self cellReuseIdentifierForHierarchyNavigator];
        [self.collectionView registerClass:[CBLinearHierarchyCell class] forCellWithReuseIdentifier:cellIdentifier];
    }
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.hierarchyLevel + 1;
    
}

// what this method returns depends on whether we're asking for items at the active hierarchy level, or a previous level
// if asking for a section that's not the active one, return 1 (just the first item of a parent section)
// or if we're at the current level, return count of number of items at that level
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (self.hierarchyLevel != section)
    {
        count = 1;
    } else {
        if (section < self.currentItems.count)
            count = [self.currentItems[section] count];
    }

    return count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier;    
    if (self.lhCellManagerDelegate)
        cellIdentifier = [self.lhCellManagerDelegate cellReuseIdentifierForHierarchyNavigator];
    else
        cellIdentifier = [self cellReuseIdentifierForHierarchyNavigator];
    
    CBLinearHierarchyCell* cell = [cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // cell is active if it's below the current hierarchy level
    cell.cellDelegate = self;
    cell.active = (indexPath.section < self.hierarchyLevel);
    
    // if we have current items for the given section, display them
    // if not, it means we're using dynamic content provided by a subclass
    if ((self.currentItems.count > 0) && [[self.currentItems objectAtIndex:indexPath.section] count] > 0)
    {
        NSDictionary* dataToDisplay = (NSDictionary*)[[self.currentItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.item];
        cell.children = [NSArray arrayWithArray:[dataToDisplay objectForKey:kHierarchyNavigatorKeyChildren]];
        cell.name = [dataToDisplay objectForKey:kHierarchyNavigatorKeyName];
        cell.dynamic = [[dataToDisplay objectForKey:kHierarchyNavigatorKeyType] isEqualToString:kHierarchyNavigatorTypeDynamic] ? YES : NO;
    } else {
        cell.children = nil;
        cell.name = @"";
        cell.dynamic = NO;
    }
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self collectionView:collectionView didSelectItemAtIndexPath:indexPath expandBlock:nil collapseBlock:nil];
}

// on selection, figure out if we're expanding to a new hierarchy level
// or if we're collapsing back to a previous hierarchy level
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
           expandBlock:(void (^)())expandBlock collapseBlock:(void (^)())collapseBlock
{
    [self.collectionView setUserInteractionEnabled:NO];
    
    CBLinearHierarchyCell* tappedCell = (CBLinearHierarchyCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView bringSubviewToFront:tappedCell];
    
    if (!tappedCell.active)
    {
        if (([tappedCell.children count] > 0) || (tappedCell.dynamic))
        {
            // expanding to a new hierarchy level
            [self expandNewLevelForCellAtIndexPath:indexPath completionBlock:expandBlock];
        } else {
            // selected a leaf node, nothing to do here
            // custom selection actions can be handled in the implementing view controller's delegate or a subclass
            [self.collectionView setUserInteractionEnabled:YES];
        }
    } else {
        // collapsing back to a previous hierarchy level
        [self collapseCurrentLevelForCellAtIndexPath:indexPath completionBlock:collapseBlock];
        [self.collectionView setUserInteractionEnabled:YES];
    }
    [self.collectionView setNeedsDisplay];
}

- (void) collapseCurrentLevelForCellAtIndexPath:(NSIndexPath*)indexPath
                                completionBlock:(void (^)())completionBlock
{
    CBLinearHierarchyCell *cell = (CBLinearHierarchyCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.active = NO;
    
    NSMutableIndexSet* indexesToRemove = [[NSMutableIndexSet alloc] init];
    for (int i = self.hierarchyLevel; i > indexPath.section; i--)
    {
        [indexesToRemove addIndex:i];
        [self.currentItems removeObjectAtIndex:i];
        self.hierarchyLevel--;
    }
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteSections:indexesToRemove];
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
            
            NSArray* newItems;
            if (indexPath.section != 0)
            {
                NSIndexPath* prevSection = [NSIndexPath indexPathForItem:0 inSection:(indexPath.section-1)];
                CBLinearHierarchyCell* prevSectionCell = (CBLinearHierarchyCell*)[self.collectionView cellForItemAtIndexPath:prevSection];
                newItems = [[NSArray alloc] initWithArray:[prevSectionCell children]];
            } else {
                newItems = [[NSArray alloc] initWithArray:self.hierarchyItems];
            }
            
            int targetItemIndex = 1;
            NSIndexPath *newIndexPathForCell = nil;
            for (NSDictionary* item in newItems)
            {
                if (![[item objectForKey:kHierarchyNavigatorKeyName] isEqualToString:cell.name])
                {
                    if (newIndexPathForCell == nil)
                    {
                        [[self.currentItems objectAtIndex:indexPath.section] insertObject:item atIndex:(targetItemIndex-1)];
                        [indexPaths addObject:[NSIndexPath indexPathForItem:(targetItemIndex-1) inSection:(indexPath.section)]];
                    } else {
                        [[self.currentItems objectAtIndex:indexPath.section] insertObject:item atIndex:targetItemIndex];
                        [indexPaths addObject:[NSIndexPath indexPathForItem:targetItemIndex inSection:(indexPath.section)]];
                    }
                    targetItemIndex++;
                } else {
                    newIndexPathForCell = [NSIndexPath indexPathForItem:(targetItemIndex-1) inSection:(indexPath.section)];
                }
            }
            
            [self.collectionView performBatchUpdates:^
            {
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
                
            } completion:^(BOOL finished) {
                
                [self.collectionView scrollToItemAtIndexPath:newIndexPathForCell atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                if (completionBlock)
                    completionBlock();
                [self.collectionView setUserInteractionEnabled:YES];
            }];
        }
        
    }];
    
}

- (void) expandNewLevelForCellAtIndexPath:(NSIndexPath*)indexPath completionBlock:(void (^)())completionBlock
{
    CBLinearHierarchyCell *cell = (CBLinearHierarchyCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.active = YES;

    // get set of all cells other than the current one
    NSMutableArray* indexPathsToRemove = [[NSMutableArray alloc] init];
    NSMutableIndexSet* indexesToRemove = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < [[self.currentItems objectAtIndex:indexPath.section] count]; i++)
    {
        if (i != indexPath.item)
        {
            [indexesToRemove addIndex:i];
            [indexPathsToRemove addObject:[NSIndexPath indexPathForItem:i inSection:indexPath.section]];
        }
    }
    
    [self.collectionView performBatchUpdates:^{
        
        [[self.currentItems objectAtIndex:indexPath.section] removeObjectsAtIndexes:indexesToRemove];
        [self.collectionView deleteItemsAtIndexPaths:indexPathsToRemove];
        
        
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            self.hierarchyLevel++;
            [self.currentItems addObject:[[NSMutableArray alloc] initWithArray:cell.children]];
            
            [self.collectionView performBatchUpdates:^
            {
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:(indexPath.section + 1)]];
            
            } completion:^(BOOL finished) {

                if (completionBlock)
                    completionBlock();
                [self.collectionView setUserInteractionEnabled:YES];
            }];
        }
    }];
}

#pragma mark DelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [CBLinearHierarchyCell defaultCellSize];
}

#pragma mark - CBLinearHierarchyCellManagerProtocol

- (NSString*) cellReuseIdentifierForHierarchyNavigator
{
    return kHierarchyNavigatorCellID;
}

- (void) registerClassForCBLinearHierarchyCell
{
    [self.collectionView registerClass:[CBLinearHierarchyCell class] forCellWithReuseIdentifier:[self cellReuseIdentifierForHierarchyNavigator]];
}

#pragma mark - hierarchyItems set/get

// rootItems are the initial

- (NSArray*) hierarchyItems
{
    return _hierarchyItems;
}

- (void) setHierarchyItems:(NSArray *)hierarchyItems
{
    // setting root items resets current items and hierarchy level
    _hierarchyItems = hierarchyItems;
    [self.currentItems removeAllObjects];
    [self.currentItems addObject:[[NSMutableArray alloc] initWithArray:_hierarchyItems]];
    self.hierarchyLevel = 0;
}

@end
