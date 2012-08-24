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

#define CELL_HEIGHT 150

#define kNameKey @"Name"
#define kImageKey @"Portrait"
#define kPathKey @"DataPath"

@interface PeopleViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation PeopleViewController
@synthesize peopleCell;
#pragma mark - Add Btn Function

-(id)prepareForNewInterview{
    PersonalInterviewViewController *newPersonViewController = [[PersonalInterviewViewController alloc] init];
    //push it into modal

    newPersonViewController.view.tag = [self.datas count];
    //create a data path for it
    NSString *fileName = [NSString stringWithFormat:@"interview_%d.plist",[self.datas count]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    //setup modal for new controller
    NSMutableArray *newDatas = [NSMutableArray array];
    
    [newDatas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PortraitCell",kCellTypeKey,@"",@"Name",@"",@"Background", nil]];
    [newDatas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey,DEFAULT_NOTE_MESSAGE,kCellTextKey, nil]];
    if ([newDatas writeToFile:filePath atomically:YES] == NO) {
        NSLog(@"File Writing Error");
    }else{
        newPersonViewController.dataSourcePath = filePath;
    }
    [self.datas addObject:filePath];
    return newPersonViewController;

}
-(void)addPeople:(id)sender{
    //add pepople btn pressed
    //new a view controller
    PersonalInterviewViewController *newPersonViewController = [self prepareForNewInterview];

    //go to next view controller
    [self.navigationController pushViewController:newPersonViewController animated:YES];
}

#pragma mark - Variable setter

-(NSMutableArray*)datas{
    if (_datas == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:APP_FILENAME];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
            _datas = [NSMutableArray arrayWithContentsOfFile:filePath];
        }else{
            _datas = [NSMutableArray array];
        }
        
        if ([_datas count] == 0) {//application is new to launch
            if ([self prepareForNewInterview] == nil) {
                NSLog(@"Fuck you error in init datas in PeopleViewController!!");
            }
        }
    }
    return _datas;
}
#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tableView = nil;
    self.datas = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //write data
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:APP_FILENAME];
    
    if ([self.datas writeToFile:filePath atomically:YES]== NO) {
        NSLog(@"in PeopleViewController file write error");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    //layout navigation bar
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"list_nav.gif"] forBarMetrics:UIBarMetricsDefault];
}
#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - TableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
    UILabel *label;
    NSArray *datasForCell = [NSArray arrayWithContentsOfFile:[self.datas objectAtIndex:indexPath.row]];
    NSDictionary *dataForCell = [datasForCell objectAtIndex:0];
    
    label = (UILabel*)[cell viewWithTag:NAME_TAG];
    
    label.text = [dataForCell objectForKey:@"Name"];
        //NSLog(@"%@",theController.title);
    if ([label.text length] == 0) {
        label.text = DEFAULT_NAME_MESSAGE;
    }
    UIImageView *portrait = (UIImageView*) [cell viewWithTag:PHOTO_TAG];

    [portrait.layer setBorderWidth:1.0];
    [portrait.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dataForCell objectForKey:kCellPhotoKey]]) {//have image to show
            portrait.image = [UIImage imageWithContentsOfFile:[dataForCell objectForKey:kCellPhotoKey]];
    }else{
        portrait.image = [UIImage imageNamed:@"list_default_image.gif"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone ];
    datasForCell = nil;
    dataForCell = nil;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonalInterviewViewController *nextController = [[PersonalInterviewViewController alloc] init];
        nextController.dataSourcePath = (NSString*)[self.datas objectAtIndex:indexPath.row];
    nextController.view.tag = indexPath.row;
    [self.navigationController pushViewController:nextController animated:YES];
}
@end
