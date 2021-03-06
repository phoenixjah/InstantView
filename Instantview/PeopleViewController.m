//
//  PeopleViewController.m
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PeopleViewController.h"
#import "PersonalInterviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constant.h"
#import "NSFileManager+CreateUniqueFilePath.h"
#import "JTTableViewGestureRecognizer.h"

#define CELL_HEIGHT 150

#define kNameKey @"Name"
#define kImageKey @"Portrait"
#define kPathKey @"DirPath"

@interface PeopleViewController ()<UITableViewDelegate,UITableViewDataSource,ProfileUpdateDelegate,JTTableViewGestureEditingRowDelegate>
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@end

@implementation PeopleViewController
@synthesize peopleCell;

#pragma mark - Data Prepare
-(NSMutableArray*)datas{
    if (_datas == nil) {
        //set data path in document
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:APP_FILENAME];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path] == NO) {
            //file does not exist, setup default data
            //create unique filename
            
            NSString *uniqueName = [NSFileManager createUniqueFileName];
            NSString *newPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:uniqueName];
            
            //newPath = [newPath stringByAppendingPathExtension: @"plist"];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_NAME_MESSAGE,kNameKey,newPath,kPathKey, nil];
            _datas = [NSMutableArray arrayWithObject:data];
            if ([_datas writeToFile:path atomically:YES] == NO) {
                NSLog(@"write File error");
            }
            data = nil;

        }else{
            //file exist, load it
            _datas = [[NSMutableArray alloc] initWithContentsOfFile:path];
        }
    }
    return _datas;
}

#pragma mark - ProfileUpdateDelegate Method
-(void)updatedProfile:(NSDictionary *)data atIndex:(NSInteger)index{
    NSLog(@"update profile at cell %d",index);
    [self.datas replaceObjectAtIndex:index withObject:data];
    [self.datas writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:APP_FILENAME] atomically:YES];
    [self.tableView reloadData];
}

#pragma mark - Add Btn Function
-(PersonalInterviewViewController*)prepareForNewInterview{
    PersonalInterviewViewController *newPersonViewController = [[PersonalInterviewViewController alloc] init];
    
    //create a data path for new view controller
    //create unique filename

    NSString *newPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSFileManager createUniqueFileName]];
    //newPath = [newPath stringByAppendingPathExtension: @"plist"];
    
    //setup modal for new controller
    NSDictionary *newData = [NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_NAME_MESSAGE,kNameKey,newPath,kPathKey, nil];
    
//    [newDatas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PortraitCell",kCellTypeKey,@"",@"Name",@"",@"Background", nil]];
//    [newDatas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey,DEFAULT_NOTE_MESSAGE,kCellTextKey, nil]];

    newPersonViewController.view.tag = [self.datas count];
    newPersonViewController.dataSourceDirPath = newPath;
    newPersonViewController.delegate = self;
    [self.datas addObject:newData];
    return newPersonViewController;

}
-(void)addPeople:(id)sender{
    //add pepople btn pressed
  
    //new a view controller
    PersonalInterviewViewController *newPersonViewController = [self prepareForNewInterview];

    //go to next view controller
    [self.navigationController pushViewController:newPersonViewController animated:YES];
    [self.tableView reloadData];
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //prepare for before entering background
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(saveDatasToFile)
//                                                 name:UIApplicationWillResignActiveNotification
//                                               object:[UIApplication sharedApplication]];
    //setup TableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.view = self.tableView;

    self.tableView.separatorColor = [UIColor clearColor];
    //put ADD function btn
    UIButton *addNewPeopleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addNewPeopleBtn setImage:[UIImage imageNamed:@"btn_plus_normal.png"] forState:UIControlStateNormal];
    [addNewPeopleBtn setImage:[UIImage imageNamed:@"btn_normal_pressed.png"] forState:UIControlStateHighlighted];
    [addNewPeopleBtn addTarget:self action:@selector(addPeople:) forControlEvents:UIControlEventTouchDown];
    addNewPeopleBtn.frame = CGRectMake(0, 0, 32, 32);
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:addNewPeopleBtn];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //NSLog(@"viewWillDisappear");
    //write file
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:APP_FILENAME];
    if([self.datas writeToFile:path atomically:YES]==NO){
        NSLog(@"in ViewDisappear write file error");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //NSLog(@"in viewWillAppear");
    [super viewWillAppear:animated];
    //[self.tableView reloadData];
    //layout navigation bar
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"int_nav.gif"] forBarMetrics:UIBarMetricsDefault];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self.tableView endUpdates];
}
#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    //NSLog(@"number of Object = %d",[self.datas count]);
    return [self.datas count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"PeopleListCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PersonListCell" owner:self options:nil];
        cell = peopleCell;
        self.peopleCell = nil;
    }

    NSMutableDictionary *dataForCell = [self.datas objectAtIndex:indexPath.row];
    UILabel *label;

    label = (UILabel*)[cell viewWithTag:NAME_TAG];
    
    label.text = [dataForCell valueForKey:kNameKey];

    UIImageView *portrait = (UIImageView*) [cell viewWithTag:PHOTO_TAG];

    [portrait.layer setBorderWidth:1.0];
    [portrait.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dataForCell objectForKey:kImageKey]]) {
        //have image to show
        portrait.image = [UIImage imageWithContentsOfFile:[dataForCell valueForKey:kImageKey]];
    }
    //}else{
      //  portrait.image = [UIImage imageNamed:@"list_default_image.gif"];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone ];
    //[cell setEditing:YES];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonalInterviewViewController *nextController = [[PersonalInterviewViewController alloc] init];
    
    nextController.view.tag = indexPath.row;
    nextController.dataSourceDirPath = [[self.datas objectAtIndex:indexPath.row] valueForKey:kPathKey];
    nextController.delegate = self;
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark - UITableView datasource delegate, for delete
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    
//    UIColor *backgroundColor = nil;
    switch (state) {
//        case JTTableViewCellEditingStateMiddle:
//            backgroundColor = [[UIColor redColor] colorWithHueOffset:0.12 * indexPath.row / [self tableView:self.tableView numberOfRowsInSection:indexPath.section]];
//            break;
        case JTTableViewCellEditingStateRight:
            cell.alpha = 0.6;
            break;
        default:
            cell.alpha = 1;
            break;
    }
//    cell.contentView.backgroundColor = backgroundColor;
//    if ([cell isKindOfClass:[TransformableTableViewCell class]]) {
//        ((TransformableTableViewCell *)cell).tintColor = backgroundColor;
//    }
}

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.datas count] == 1) {
        //if only one left, then delete is not allowed
        return NO;
    }else{
        return YES;
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    [tableView beginUpdates];
    if (state == JTTableViewCellEditingStateRight) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
        
        //delete datas in dir
        NSString *dirPath = [[self.datas objectAtIndex:indexPath.row] valueForKey:kPathKey];
        //NSLog(@"delete index %d",indexPath.row);
        [self.datas removeObjectAtIndex:indexPath.row];
        [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
        
 
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }else {
        // JTTableViewCellEditingStateMiddle shouldn't really happen in
        // - [JTTableViewGestureDelegate gestureRecognizer:commitEditingState:forRowAtIndexPath:]
    }
    [tableView endUpdates];
    
    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];
}
#pragma mark-Background task
-(void)saveDatasToFile{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    //update files in dir
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:APP_FILENAME];
    if([self.datas writeToFile:path atomically:YES]==NO){
        NSLog(@"in ViewDisappear write file error");
    }
}
@end
