CBLinearHierarchy
=================

CBLinearHierarchy provides a UICollectionView-backed linear representation of a user's path through a menu hierarchy.  

In iOS applications, using UINavigationController to push and pop through a series of tableviews is the default way to navigate through a tree of options, and allows a user to "drill-down" to a piece of information within a hierarchical menu.  This is often supported through full screen views on an iPhone, or through a UIPopoverController on an iPad.

CBLinearHierarchy provides an alternative approach through a custom UICollectionViewController, allowing a user to navigate through a hierarchy along a single axis either horizontally or vertically.  It's the sort of thing that's harder to describe than it is to visualize. See the following animations/videos for examples of how this works:

![alt text](https://dl.dropboxusercontent.com/u/19417682/horizontalLinearHierarchy.gif "Horizontal Linear Hierarchy Animation")

[Video of horizontal animation example](https://dl.dropboxusercontent.com/u/19417682/horizontalHierarchy2.mov)

[Video of vertical animation example](https://dl.dropboxusercontent.com/u/19417682/verticalHierarchy2.mov)

##Displaying Content

CBLinearHierarchy includes support for user-specified hierarchy data via the following formats:  

* plist files  
* JSON files  
* NSDictionary/NSArray data supplied directly in code  

Support is also provided for dynamically generated content at runtime.  In the demo project provided, the "Spacecraft" area is left empty in the plist file, and is only populated at runtime.  This is typically done by overriding the following delegate methods:

```objective-c
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
```

In this example, calculating the number of items in a section applies custom logic for specific circumstances, and otherwise follows a default path:

```objective-c
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.selectedItemName isEqualToString:@"Spacecraft"] && section == 1)
    {
        return [self.dataAtRuntime count];
    } else {
        return [self.lhVC collectionView:collectionView numberOfItemsInSection:section];
    }
}
```

##How it Works

CBLinearHierarchy uses an implementation of UICollectionViewFlowLayout. Rather than using UICollectionView's supplementary views or decoration views, sections and items are added/removed from the data source based on a selection the user made.  It's actually a combination of three different classes:

* **CBLinearHierarchyViewController**, a subclass of UICollectionViewController, to override some of the UICollectionView delegate and datasource methods  
* **CBLinearHierarchyFlowLayout**, a subclass of UICollectionViewFlowLayout, to handle the layout and positioning of the cells
* **CBLinearHierarchyCell**, a subclass of UICollectionViewCell, to provide some public properties that the ViewController and Layout need, as well as some convenience defaults

The initial state displays cells representing all the "top level / root" items to the user, and inserts them into the first section of the collection.  Whenever a selection is made indicating that the user wants to drill down into the hierarchy, all other items at the same section of the selection in the data model are removed from the collection, and a new section containing that node's child items is inserted. Correspondingly, when a previous section is selected, any section that was added beyond that selection is deleted, and that selection's child items are restored as the collection "collapses".

For example, an initial starting point might have five items, all at section 0.  When a user selects item 2, items 0, 1 ,3 and 4 are removed, and item 2's children are added into a new section (section 1). A similar corresponding process happens when collapsing back to a lower level, but reversed.

##Usage

CBLinearHierarchy can be used directly. Add it's view as a subview to an existing UIViewController's view, and set your implementing ViewController as the delegate and data source if there's a need to incorporate any dynamically generated content.  Alternatively, use View Controller Containment to add it as a child view controller. An example of the first option is shown in the demo project and summarized below.

For additional control over colors, sizes, customizations, etc, you can subclass CBLinearHierarchyViewController and CBLinearHierarchyCell, and use it in one of the scenarios described above.

###Horizontal Implementation

```objective-c
    self.lhLayout = [[CBLinearHierarchyFlowLayout alloc] init];
    self.lhLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.lhLayout.minimumInteritemSpacing = 5.0f;
    
    self.lhVC = [[CBLinearHierarchyViewController alloc] initWithCollectionViewLayout:self.lhLayout];
    self.lhVC.lhCellManagerDelegate = self;
    self.lhVC.normalLHCellColor = [UIColor darkGrayColor];
    self.lhVC.activeLHCellColor = [UIColor purpleColor];
    self.lhVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.lhVC.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, preferredCellSize.height);

    self.lhVC.hierarchyItems = [self getHierarchyFromPList];

    self.lhVC.collectionView.dataSource = self;
    self.lhVC.collectionView.delegate = self;
    
    [self.view addSubview:self.lhVC.view];
```

###Vertical Implementation

```objective-c
    self.lhLayout = [[CBLinearHierarchyFlowLayout alloc] init];
    self.lhLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.lhLayout.minimumInteritemSpacing = 5.0f;
    
    self.lhVC = [[CBLinearHierarchyViewController alloc] initWithCollectionViewLayout:self.lhLayout];
    self.lhVC.lhCellManagerDelegate = self;
    self.lhVC.normalLHCellColor = [UIColor darkGrayColor];
    self.lhVC.activeLHCellColor = [UIColor purpleColor];
    self.lhVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.lhVC.collectionView.frame = CGRectMake(0, 0, preferredCellSize.width, self.view.frame.size.height);

    self.lhVC.hierarchyItems = [self getHierarchyFromPList];

    self.lhVC.collectionView.dataSource = self;
    self.lhVC.collectionView.delegate = self;
    
    [self.view addSubview:self.lhVC.view];
```

Cells don't need to all be the same size.  You can use variable width/height cells (not shown in the demo animation) setting your implementing View Controller conform to the UICollectionViewDelegateFlowLayout protocol, and have your code handle the specific instances when you need different sized cells.

```objective-c
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
```

If you have no need for more than one size, simply set the itemSize property on the layout object.




