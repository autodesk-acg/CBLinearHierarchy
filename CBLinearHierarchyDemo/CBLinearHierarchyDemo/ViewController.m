//
//  ViewController.m
//  CBLinearHierarchyDemo
//
//  Created by Chris Benoit on 12/18/13.
//  Copyright (c) 2013 Autodesk Inc. All rights reserved.
//

#import "ViewController.h"
#import "CBLinearHierarchyFlowLayout.h"
#import "CBLinearHierarchyViewController.h"
#import "CustomCell.h"

static const CGSize preferredCellSize = {92, 92};

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CBLinearHierarchyCellManagerProtocol>

@property (nonatomic, strong) CBLinearHierarchyFlowLayout* lhLayout;
@property (nonatomic, strong) CBLinearHierarchyViewController* lhVC;
@property (nonatomic, strong) NSArray* dataAtRuntime;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic, strong) NSString* selectedItemName;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.lhLayout = [[CBLinearHierarchyFlowLayout alloc] init];
    //self.lhLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.lhLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //self.lhLayout.itemSize = CGSizeMake(92.0f, 92.0f);
    self.lhLayout.minimumInteritemSpacing = 5.0f;
    
    self.lhVC = [[CBLinearHierarchyViewController alloc] initWithCollectionViewLayout:self.lhLayout];
    self.lhVC.lhCellManagerDelegate = self;
    self.lhVC.normalLHCellColor = [UIColor darkGrayColor];
    self.lhVC.activeLHCellColor = [UIColor purpleColor];
    self.lhVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //self.lhVC.collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, preferredCellSize.height);
    self.lhVC.collectionView.frame = CGRectMake(0, 0, preferredCellSize.width, self.view.frame.size.height);
    
    self.dataAtRuntime = @[@"Vux Intruder", @"Mmrnhrmm Transformer", @"Shofixti Scout", @"UrQuan Dreadought"];
    
    //self.lhVC.hierarchyItems = [self getHierarchyFromJSON];
    self.lhVC.hierarchyItems = [self getHierarchyFromDictionary];
    //self.lhVC.hierarchyItems = [self getHierarchyFromPList];

    self.lhVC.collectionView.dataSource = self;
    self.lhVC.collectionView.delegate = self;
    
    [self.view addSubview:self.lhVC.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.lhVC numberOfSectionsInCollectionView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.selectedItemName isEqualToString:@"Spacecraft"] && section == 1)
    {
        return [self.dataAtRuntime count];
    } else {
        return [self.lhVC collectionView:collectionView numberOfItemsInSection:section];
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell* cell;
    cell = (CustomCell*)[self.lhVC collectionView:collectionView cellForItemAtIndexPath:indexPath];
 
    if ([self.selectedItemName isEqualToString:@"Spacecraft"] && indexPath.section == 1)
    {
        cell.cellLabel.text = [self.dataAtRuntime objectAtIndex:indexPath.item];
    } else {
        cell.cellLabel.text = cell.name;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    CustomCell* cell;
    cell = (CustomCell*)[self.lhVC.collectionView cellForItemAtIndexPath:indexPath];
    
    self.selectedItemName = cell.cellLabel.text;
    
    NSLog(@"Selected cell with indexPath: %@", indexPath);
    
    return [self.lhVC collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return preferredCellSize;
}

#pragma mark - CBLinearHierarchyCellManagerProtocol

- (NSString*) cellReuseIdentifierForHierarchyNavigator
{
    return @"myCellIdentifier";
}

- (void) registerClassForCBLinearHierarchyCell
{
    [self.lhVC.collectionView registerClass:[CustomCell class] forCellWithReuseIdentifier:[self cellReuseIdentifierForHierarchyNavigator]];
}

#pragma mark - Three different ways of supplying hierarchy data to collection view

- (NSArray*)getHierarchyFromPList
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:filePath];
}

- (NSArray*)getHierarchyFromJSON
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return [json objectForKey:@"root"];
}

- (NSArray*)getHierarchyFromDictionary
{
    return [NSMutableArray arrayWithArray:
    @[               
        @{  kHierarchyNavigatorKeyName: @"Automobiles",
            kHierarchyNavigatorKeyType : kHierarchyNavigatorTypeStatic,
            kHierarchyNavigatorKeyChildren: @[
                @{kHierarchyNavigatorKeyName: @"Motorcycles", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                @{kHierarchyNavigatorKeyName: @"Cars",
                  kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic,
                  kHierarchyNavigatorKeyChildren: @[
                          @{kHierarchyNavigatorKeyName: @"Small", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                          @{kHierarchyNavigatorKeyName: @"Medium", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                          @{kHierarchyNavigatorKeyName: @"Large", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                ]},
                @{kHierarchyNavigatorKeyName: @"Trucks", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                @{kHierarchyNavigatorKeyName: @"SUVs", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
        ]},
        @{  kHierarchyNavigatorKeyName: @"Boats",
            kHierarchyNavigatorKeyType : kHierarchyNavigatorTypeStatic,
            kHierarchyNavigatorKeyChildren: @[
                    @{kHierarchyNavigatorKeyName: @"Sailboats", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                    @{kHierarchyNavigatorKeyName: @"Motorboats", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                    @{kHierarchyNavigatorKeyName: @"Canoes", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                    @{kHierarchyNavigatorKeyName: @"Kayaks", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                    @{kHierarchyNavigatorKeyName: @"Rafts", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
        ]},
        @{  kHierarchyNavigatorKeyName: @"Bicycles",
            kHierarchyNavigatorKeyType : kHierarchyNavigatorTypeStatic
        },
        @{  kHierarchyNavigatorKeyName: @"Spacecraft",
            kHierarchyNavigatorKeyType : kHierarchyNavigatorTypeDynamic
        },
        @{  kHierarchyNavigatorKeyName: @"Aircraft",
            kHierarchyNavigatorKeyType : kHierarchyNavigatorTypeStatic,
            kHierarchyNavigatorKeyChildren: @[
                    @{kHierarchyNavigatorKeyName: @"Planes", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                    @{kHierarchyNavigatorKeyName: @"Helicopters", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
                    @{kHierarchyNavigatorKeyName: @"Blimps", kHierarchyNavigatorKeyType: kHierarchyNavigatorTypeStatic},
        ]},
    ]];
}

@end
