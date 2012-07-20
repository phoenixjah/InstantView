//
//  PersonalInterviewViewController.m
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PersonalInterviewViewController.h"
#import "QuoteCell.h"
#import "NoteCell.h"
#import "PhotoCell.h"

#define PHOTO_CELL @"PhotoCell"
#define NOTE_CELL @"NoteCell"
#define QUOTE_CELL @"QuoteCell"

@interface PersonalInterviewViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong) UIButton *addElementBtn;
@property (nonatomic,strong) UIButton *shareResultBtn;
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation PersonalInterviewViewController
@synthesize addElementBtn = _addElementBtn;
@synthesize shareResultBtn = _shareResultBtn;
@synthesize datas = _datas;
@synthesize tableView = _tableView;

static NSString *kCellTypeKey = @"TypeOfCell";
static CGFloat ElementWidth = 320;
static CGFloat PhotoCellHeight = 290;
static CGFloat QuoteCellHeight = 121;
static CGFloat NoteCellHeight = 173;

#pragma mark - Share Result Btn Functions

-(void)shareResultPressed:(id)sender{
    //write a pdf
    //send it through email
}

#pragma mark - Add Element Btn Functions

-(void)addElementPressed:(id)sender{
    //different elements could be added, ask for which one
    //pass the choice to create new view
}

#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //look up which type
    
    NSString *cellType = [[self.datas objectAtIndex:indexPath.row] objectForKey:kCellTypeKey];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellType];
    if (cell == nil) {
        if ([cellType isEqualToString:PHOTO_CELL]) {
            
            cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:PHOTO_CELL];
        
        }else if ([cellType isEqualToString:NOTE_CELL]) {
            
            cell = [[NoteCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:NOTE_CELL ];
        
        }else if ([cellType isEqualToString:QUOTE_CELL]) {
            
            cell = [[QuoteCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:QUOTE_CELL];
        }else {
            NSLog(@"In CellForRowAtIndexPath Error");
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellType = [[self.datas objectAtIndex:indexPath.row] objectForKey:kCellTypeKey];
    
    if ([cellType isEqualToString:PHOTO_CELL]) {
        return PhotoCellHeight;
    }else if ([cellType isEqualToString:NOTE_CELL]) {
        return NoteCellHeight;
    }else if([cellType isEqualToString:QUOTE_CELL]){
        return QuoteCellHeight;
    }
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //setup modal
    self.datas = [NSMutableArray array];
    
    [self.datas addObject:[NSDictionary dictionaryWithObjectsAndKeys:PHOTO_CELL,kCellTypeKey, nil]];
    [self.datas addObject:[NSDictionary dictionaryWithObjectsAndKeys:QUOTE_CELL,kCellTypeKey, nil]];
    [self.datas addObject:[NSDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey, nil]];
    
    //setup subviews template
        
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    
    
    //put add btn
    self.addElementBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.addElementBtn.frame = CGRectMake(10, 10, 80, 50);
    [self.addElementBtn setTitle:@"Add New" forState:UIControlStateNormal];
    [self.addElementBtn addTarget:self action:@selector(addElementPressed:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.addElementBtn];
    
    //put share btn
    self.shareResultBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.shareResultBtn.frame = CGRectMake(200, 10, 80, 50);
    [self.shareResultBtn setTitle:@"Share This" forState:UIControlStateNormal];
    [self.shareResultBtn addTarget:self action:@selector(shareResultPressed:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.shareResultBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
