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
#define DEFAULT_NOTE_MESSAGE @"What do you think?"
#define DEFAULT_QUOTE_MESSAGE @"What did they say?"

#define CELL_INPUT 20
@interface PersonalInterviewViewController ()<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong) UIButton *addElementBtn;
@property (nonatomic,strong) UIButton *shareResultBtn;
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) NSInteger selectedRow;
@end

@implementation PersonalInterviewViewController
@synthesize addElementBtn = _addElementBtn;
@synthesize shareResultBtn = _shareResultBtn;
@synthesize datas = _datas;
@synthesize tableView = _tableView;
@synthesize portraitCell;
@synthesize selectedRow = _selectedRow;

static NSString *kCellTypeKey = @"TypeOfCell";
static NSString *kCellTextKey = @"ContentOfCell";
static NSString *kCellPhotoKey = @"PhotoOfCell";
static CGFloat PhotoCellHeight = 263;
static CGFloat QuoteCellHeight = 127;
static CGFloat NoteCellHeight = 173;
static CGFloat PortraitCellHeight = 317;

#pragma mark - Text Input Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    //NSLog(@"textFieldBeginEdit");
    if (textField.tag != CELL_INPUT) {//if called by CELL_INPUT, than scroll already, no scroll again
    [self.tableView setContentOffset:CGPointMake(0, textField.frame.origin.y - 20) animated:YES];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField.tag == CELL_INPUT) {
        [[self.datas objectAtIndex:self.selectedRow] setValue:textField.text forKey:kCellTextKey];
        [textField removeFromSuperview];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    return YES;
}
#pragma mark - Setter

#pragma mark - Share Result Btn Functions

-(void)shareResultPressed:(id)sender{
    //write a pdf
    //send it through email
}

#pragma mark - Add Element Btn Functions

-(void)addElementPressed:(id)sender{
    //different elements could be added, ask for which one
    UIActionSheet *chooseTypeToAdd = [[UIActionSheet alloc] initWithTitle:@"Choose Type To Add"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo",@"Quote",@"Note", nil];
    [chooseTypeToAdd showInView:self.view];
}
#pragma mark - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    //NSLog(@"%d",buttonIndex);
    //Photo btn index = 0, Quote = 1, Note = 2
    switch (buttonIndex) {
        case 0:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:PHOTO_CELL,kCellTypeKey,@"",kCellTextKey, nil]];
            [self.tableView reloadData];
            break;
        case 1:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:QUOTE_CELL,kCellTypeKey,DEFAULT_QUOTE_MESSAGE,kCellTextKey, nil]];
            [self.tableView reloadData];
            break;
        case 2:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey, DEFAULT_NOTE_MESSAGE,kCellTextKey,nil]];
            [self.tableView reloadData];
            break;
        
        default://cancel
            break;
    }
    if (buttonIndex != 3) {//cancel
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - PhotoCellHeight) animated:YES];
    }
}

#pragma mark - Add Photo/Text Functions

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
    //if the first one, alloc the special one
    
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
            }else if ([cellType isEqualToString:@"PortraitCell"]) {
                [[NSBundle mainBundle] loadNibNamed:@"PortraitCell" owner:self options:nil ];
                cell = portraitCell;
                self.portraitCell = nil;
            }else {
                NSLog(@"In CellForRowAtIndexPath Error");
            }
        
    }
    if ([cellType isEqualToString:PHOTO_CELL] || [cellType isEqualToString:@"PortraitCell"]) {
        UIImageView *photoCell = (UIImageView*)[cell viewWithTag:3];
        photoCell.image = [[self.datas objectAtIndex:indexPath.row]objectForKey:kCellPhotoKey];
    }
    cell.textLabel.text = [[self.datas objectAtIndex:indexPath.row] objectForKey:kCellTextKey];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellType = [[self.datas objectAtIndex:indexPath.row] objectForKey:kCellTypeKey];
    CGFloat cellHeight = PortraitCellHeight;
    
    if ([cellType isEqualToString:PHOTO_CELL]) {
        cellHeight = PhotoCellHeight;
    }else if ([cellType isEqualToString:NOTE_CELL]) {
        cellHeight = NoteCellHeight;
    }else if([cellType isEqualToString:QUOTE_CELL]){
        cellHeight = QuoteCellHeight;
    }
    
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%d",indexPath.row);
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedRow = indexPath.row;
    
    [self.tableView setContentOffset:CGPointMake(0, selectedCell.frame.origin.y - 10.0) animated:YES];
    
    //selected then is edited
    if ([selectedCell.reuseIdentifier isEqualToString:PHOTO_CELL] || [selectedCell.reuseIdentifier isEqualToString:@"PortraitCell"]) {//pick image
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [self presentModalViewController:imagePicker animated:YES];
    
    }else{//edit content
        selectedCell.alpha = 0.3;
        UITextField *cellContent = [[UITextField alloc] initWithFrame:CGRectMake(80, selectedCell.frame.size.height/2, 180, 80)];
        cellContent.delegate = self;
        cellContent.tag = CELL_INPUT;
        
        if ([selectedCell.textLabel.text isEqualToString:DEFAULT_NOTE_MESSAGE] == NO && [selectedCell.textLabel.text isEqualToString:DEFAULT_QUOTE_MESSAGE] == NO) {
            cellContent.text = selectedCell.textLabel.text;
        }
        
        [self.view addSubview:cellContent];
        [cellContent becomeFirstResponder];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - ImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    //push the image to model
    [[self.datas objectAtIndex:self.selectedRow] setValue:image forKey:kCellPhotoKey];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRow 
                                                                                       inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone
     ];
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    //setup modal
    self.datas = [NSMutableArray array];
    
    [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PortraitCell",kCellTypeKey, nil]];
    [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey,DEFAULT_NOTE_MESSAGE,kCellTextKey, nil]];
    
    //setup subviews template
        
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView.backgroundView addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]]];
    [self.view addSubview:self.tableView];
    self.tableView.separatorColor = [UIColor clearColor];
    
    
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
    self.datas = nil;
    self.addElementBtn = nil;
    self.shareResultBtn = nil;
    self.tableView = nil;
}

-(void)viewWillAppear:(BOOL)animated{
}

#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
