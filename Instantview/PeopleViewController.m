//
//  PeopleViewController.m
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PeopleViewController.h"
#import "PersonalInterviewViewController.h"

#define CELL_HEIGHT 140

#define kViewControllerKey @"ViewController"
#define kNameKey @"Name"
#define kImageKey @"Portrait"

@interface PeopleViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UIButton *addNewPeopleBtn;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation PeopleViewController
@synthesize datas = _datas;
@synthesize addNewPeopleBtn = _addNewPeopleBtn;
@synthesize tableView = _tableView;
@synthesize peopleCell;

#pragma mark - Add Btn Function

-(void)addPeople:(id)sender{
    //add pepople btn pressed
    //new a view controller
    PersonalInterviewViewController *newPersonViewController = [[PersonalInterviewViewController alloc] init];
    //push it into modal
    [self.datas addObject:[NSDictionary dictionaryWithObjectsAndKeys:newPersonViewController,kViewControllerKey,@"Unknow",kNameKey,[UIImage imageNamed:@"default.png"],kImageKey, nil]];
    //go to next view controller
    [self.navigationController pushViewController:newPersonViewController animated:YES];
}

#pragma mark - Variable setter

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //init data modal
    self.datas = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorColor = [UIColor clearColor];
    //put ADD function btn
    self.addNewPeopleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.addNewPeopleBtn.frame = CGRectMake(10, 10, 80,80);
    [self.addNewPeopleBtn setTitle:@"Add" forState:UIControlStateNormal];
    [self.addNewPeopleBtn addTarget:self action:@selector(addPeople:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.addNewPeopleBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated{
    //hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.tableView reloadData];
    //check if there is datas to show
}
#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
    label = (UILabel*)[cell viewWithTag:1];
    label.text = [[self.datas objectAtIndex:indexPath.row] objectForKey:kNameKey];
    
    UIImageView *portrait;
    portrait = (UIImageView*) [cell viewWithTag:0];
    portrait.image = [[self.datas objectAtIndex:indexPath.row] objectForKey:kImageKey];
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
