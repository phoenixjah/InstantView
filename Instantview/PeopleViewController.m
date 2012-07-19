//
//  PeopleViewController.m
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PeopleViewController.h"
#import "PersonalInterviewViewController.h"

@interface PeopleViewController ()
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UIButton *addNewPeopleBtn;
@end

@implementation PeopleViewController
@synthesize datas = _datas;
@synthesize addNewPeopleBtn = _addNewPeopleBtn;

#pragma mark - Add Btn Function

-(void)addPeople:(id)sender{
    //add pepople btn pressed
    //new a view controller
    PersonalInterviewViewController *newPersonViewController = [[PersonalInterviewViewController alloc] init];
    //push it into modal
    [self.datas addObject:newPersonViewController];
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
    self.datas = [[NSMutableArray alloc] init];
    
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
    
    //check if there is datas to show
}
#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
