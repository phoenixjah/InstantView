//
//  PeopleViewController.m
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PeopleViewController.h"
#import "PersonalInterviewViewController.h"
#import "Constant.h"

#define CELL_HEIGHT 147

#define kViewControllerKey @"ViewController"
#define kNameKey @"Name"
#define kImageKey @"Portrait"

@interface PeopleViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation PeopleViewController
@synthesize peopleCell;
#pragma mark - Add Btn Function

-(void)addPeople:(id)sender{
    //add pepople btn pressed
    //new a view controller
    PersonalInterviewViewController *newPersonViewController = [[PersonalInterviewViewController alloc] init];
    //push it into modal
    [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:newPersonViewController,kViewControllerKey,@"New Interview",kNameKey,[UIImage imageNamed:@"list_default_image.png"],kImageKey, nil]];
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
    //go to next view controller
    [self.navigationController pushViewController:newPersonViewController animated:YES];
}

#pragma mark - Variable setter

-(NSMutableArray*)datas{
    if (_datas == nil) {
        _datas = [NSMutableArray array];
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

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    //layout navigation bar
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"list_nav.png"] forBarMetrics:UIBarMetricsDefault];
    
    [[self.navigationController navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor,
                                                                       [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                                       [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                       [UIFont systemFontOfSize:18.0], UITextAttributeFont, nil]];
    
     //check if there is datas to show
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
    label = (UILabel*)[cell viewWithTag:NAME_TAG];
    PersonalInterviewViewController *theController = (PersonalInterviewViewController*)[[self.datas objectAtIndex:indexPath.row] objectForKey:kViewControllerKey];
    if (theController.title == nil) {
        label.text = DEFAULT_NAME_MESSAGE;
    }else{
        label.text = theController.title;
    }//NSLog(@"%@",theController.title);
    
    UIImageView *portrait = (UIImageView*) [cell viewWithTag:PHOTO_TAG];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d_0.png",theController.view.tag]]; //add our image to the path
    if (fullPath != nil) {//have image to show
            portrait.image = [UIImage imageWithContentsOfFile:fullPath];
    }else{
        portrait.image = [UIImage imageNamed:@"list_default_image.png"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone ];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonalInterviewViewController *nextController = [[self.datas objectAtIndex:indexPath.row] objectForKey:kViewControllerKey];
    
    [self.navigationController pushViewController:nextController animated:YES];
}
@end
