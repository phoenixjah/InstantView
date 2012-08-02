//
//  PersonalInterviewViewController.m
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PersonalInterviewViewController.h"
#import "QuoteCell.h"
//#import "NoteCell.h"
//#import "PhotoCell.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

#define PHOTO_CELL @"PhotoCell"
#define NOTE_CELL @"NoteCell"
#define QUOTE_CELL @"QuoteCell"
#define DEFAULT_NOTE_MESSAGE @"What do you think?"
#define DEFAULT_QUOTE_MESSAGE @"What did they say?"

#define PHOTO_TAG 3
#define TEXT_TAG 1
#define CELL_INPUT 20
#define NAME_TAG 10

@interface PersonalInterviewViewController ()<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,MFMailComposeViewControllerDelegate>
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
@synthesize portraitCell,photoCell,noteCell,quoteCell;
@synthesize selectedRow = _selectedRow;
@synthesize dataSourcePath = _dataSourcePath;

static NSString *kCellTypeKey = @"TypeOfCell";
static NSString *kCellTextKey = @"ContentOfCell";
static NSString *kCellPhotoKey = @"PhotoOfCell";
static CGFloat PhotoCellHeight = 265;
static CGFloat QuoteCellHeight = 130;
static CGFloat NoteCellHeight = 173;
static CGFloat PortraitCellHeight = 317;

#pragma mark - Text Input Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldBeginEdit tag = %d",textField.tag);
    CGPoint convertedPoint = [self.tableView convertPoint:textField.frame.origin  fromView:textField];
    //NSLog(@"original %f,converted %f",textField.frame.origin.y,convertedPoint.y);
    if (textField.tag != CELL_INPUT) {//if called by CELL_INPUT, than scroll already, no scroll again
    [self.tableView setContentOffset:CGPointMake(0, convertedPoint.y - 310) animated:YES];
    }
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{

    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField.tag == CELL_INPUT) {
        [[self.datas objectAtIndex:self.selectedRow] setValue:textField.text forKey:kCellTextKey];
        [textField removeFromSuperview];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        self.tableView.userInteractionEnabled = YES;
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }else if (textField.tag == NAME_TAG) {
        self.title = textField.text;
    }
    return YES;
}
#pragma mark - Cell Edit Funtcion
-(void)addImageToCell{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark - Share Result Btn Functions

-(void)shareResultPressed:(id)sender{
    //write a pdf
    NSString *pdfPath = [self generatePDF];
    //send it through email
    [self sendMailWithAttach:pdfPath];
}
-(void)sendMailWithAttach:(NSString*)filePath{
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:[NSString stringWithFormat:@"Interview%d Result",self.view.tag+1]];
    
    
    //ATTACH FILE
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){//Does file exist?
        //NSLog(@"in NewCardSorting sendResult File exists to attach");
        
        NSData *myData = [NSData dataWithContentsOfFile:filePath];
        
        [mailer addAttachmentData:myData mimeType:@"application/pdf"
                         fileName:@"result.pdf"];
        
    }
    
    //CREATE EMAIL BODY TEXT
    [mailer setMessageBody:@"Conducted at date:" isHTML:NO];
    mailer.modalPresentationStyle = UIModalPresentationPageSheet;
    
    //PRESENT THE MAIL COMPOSITION INTERFACE
    [self presentViewController:mailer animated:YES completion:nil];

}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    //NSLog(@"in mailConpose result");

        [self dismissViewControllerAnimated:YES 
                                 completion:nil
         ];//Clear the compose email view controller
    
    
}
#pragma mark - PDF Generating Function
-(void)drawText:(NSString*)textToDraw at:(CGRect)rectToDraw{
    
    [textToDraw drawInRect:rectToDraw
                  withFont:[UIFont systemFontOfSize:16.0] 
             lineBreakMode:UILineBreakModeWordWrap
     ];
    
}

-(void)drawImage:(NSString*)pathForImage at:(CGRect)rectToDraw{
    UIImage *imageToDraw = [[UIImage alloc] initWithContentsOfFile:pathForImage];
    [imageToDraw drawInRect:rectToDraw];
}

-(NSString*)generatePDF{
    NSString *fileName = [NSString stringWithFormat:@"result_%d.pdf",self.view.tag+1];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    //draw pdf
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
    CGSize pageSize = self.tableView.contentSize;
    //print screen
    //[self.view addSubview:[[UIImageView alloc]initWithImage:resultingImage]];
    /*  
    BOOL done = NO;
    do 
    {
        //Start a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        
        //Draw text fo our header.
        //[self drawHeader];
        
        //Draw an image
        [resultingImage drawInRect:CGRectMake( (pageSize.width - resultingImage.size.width/2)/2, 350, resultingImage.size.width/2, resultingImage.size.height/2)];
        done = YES;
    } 
    while (!done);
    */
    
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    NSString *cellType;
    //UITableViewCell *cellInTable;
    CGFloat beginY = 0.0;
    for (NSDictionary *eachCell in self.datas) {
        cellType = [eachCell objectForKey:kCellTypeKey];

        if ([cellType isEqualToString:NOTE_CELL]) {
            //it's the text content
            [[UIImage imageNamed:@"Note.png"] drawInRect:CGRectMake(20, beginY, 300, NoteCellHeight)];
            [self drawText:[eachCell objectForKey:kCellTextKey] at:CGRectMake(20, beginY+NoteCellHeight/2, 300, NoteCellHeight)];
            beginY = beginY + NoteCellHeight;
        }else if ([cellType isEqualToString:QUOTE_CELL]) {
            [[UIImage imageNamed:@"Quote.png"] drawInRect:CGRectMake(20, beginY, 300, QuoteCellHeight)];
            [self drawText:[NSString stringWithFormat:@"'%@'",[eachCell objectForKey:kCellTextKey]] at:CGRectMake(20, beginY + QuoteCellHeight/2, 300, QuoteCellHeight)];
            beginY = beginY + QuoteCellHeight;
        }else {
                    //it's the image content
                    [self drawImage:[eachCell objectForKey:kCellPhotoKey] at:CGRectMake(20, beginY, 280, 200)];
            beginY = beginY + PhotoCellHeight;
                        }
    }
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    return pdfFileName;
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
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - PhotoCellHeight - 70) animated:YES];
            break;
        case 1:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:QUOTE_CELL,kCellTypeKey,DEFAULT_QUOTE_MESSAGE,kCellTextKey, nil]];
            [self.tableView reloadData];
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - QuoteCellHeight - 70) animated:YES];
            break;
        case 2:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey, DEFAULT_NOTE_MESSAGE,kCellTextKey,nil]];
            [self.tableView reloadData];
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - NoteCellHeight - 70) animated:YES];
            break;
        
        default://cancel
            break;
    }
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
    //if the first one, alloc the special one
    
        if (cell == nil) {
            if ([cellType isEqualToString:PHOTO_CELL]) {
                
                [[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil ];
                cell = photoCell;
                self.photoCell = nil;
                
            }else if ([cellType isEqualToString:NOTE_CELL]) {
                [[NSBundle mainBundle] loadNibNamed:@"NoteCell" owner:self options:nil ];
                cell = noteCell;
                self.noteCell = nil;
                
            }else if ([cellType isEqualToString:QUOTE_CELL]) {
                [[NSBundle mainBundle] loadNibNamed:@"QuoteCell" owner:self options:nil ];
                cell = quoteCell;
                self.quoteCell = nil;
            }else if ([cellType isEqualToString:@"PortraitCell"]) {
                [[NSBundle mainBundle] loadNibNamed:@"PortraitCell" owner:self options:nil ];
                cell = portraitCell;
                self.portraitCell = nil;
            }else {
                NSLog(@"In CellForRowAtIndexPath Error");
            }
        
    }
    if ([cellType isEqualToString:PHOTO_CELL] || [cellType isEqualToString:@"PortraitCell"]) {
        UIImageView *myPhotoCell = (UIImageView*)[cell viewWithTag:PHOTO_TAG];
        //load image if it is nil
        NSString *fullPath = [[self.datas objectAtIndex:indexPath.row]objectForKey:kCellPhotoKey];
        NSLog(@"photocell path %@",fullPath);
        if (fullPath == nil) {//new photoCell
            myPhotoCell.image = nil;
        }else if (myPhotoCell.image == nil) {//reload image if it is release
            myPhotoCell.image = [UIImage imageWithContentsOfFile:fullPath];
        }
    }
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:TEXT_TAG];
    cellLabel.text = [[self.datas objectAtIndex:indexPath.row] objectForKey:kCellTextKey];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
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
    //NSLog(@"index row %d, datas count %d",indexPath.row,[self.datas count]);
    if (indexPath.row+1 == [self.datas count]) {
        cellHeight = cellHeight + 50.0;
        //NSLog(@"last row %d, cellHeight %f",indexPath.row,cellHeight);
    }
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did selected %d",indexPath.row);
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedRow = indexPath.row;
    
    [self.tableView setContentOffset:CGPointMake(0, selectedCell.frame.origin.y - 10.0) animated:YES];
    //NSLog(@"use identifier %@",selectedCell.reuseIdentifier);
    //selected then is edited
    if ([selectedCell.reuseIdentifier isEqualToString:PHOTO_CELL] || [selectedCell.reuseIdentifier isEqualToString:@"PortraitCell"]) {//pick image
        [self addImageToCell];
    
    }else{//edit content
        selectedCell.alpha = 0.3;
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(addAction:)
                                       ];
        //self.navigationItem.rightBarButtonItem = addButton;
        self.navigationItem.hidesBackButton = YES;
        self.tableView.userInteractionEnabled = NO;;
        UITextField *cellContent = [[UITextField alloc] initWithFrame:CGRectMake(80,selectedCell.frame.size.height/3, 180, 80)];
        cellContent.delegate = self;
        cellContent.tag = CELL_INPUT;
        
        if ([selectedCell.textLabel.text isEqualToString:DEFAULT_NOTE_MESSAGE] == NO && [selectedCell.textLabel.text isEqualToString:DEFAULT_QUOTE_MESSAGE] == NO) {
            cellContent.text = selectedCell.textLabel.text;
        }
        selectedCell.textLabel.text = @"";
        [self.view addSubview:cellContent];
        cellContent.returnKeyType = UIReturnKeyDone;
        [cellContent becomeFirstResponder];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)addAction:(UITextField*)sender{
    
}
#pragma mark - ImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //store image to document
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d_%d.png",self.view.tag,self.selectedRow]]; //add our image to the path
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
    UIImageView *cellImage = (UIImageView*)[cell viewWithTag:PHOTO_TAG];
    cellImage.image = image;
    [[NSFileManager defaultManager] createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    //push the path at document to model
    [[self.datas objectAtIndex:self.selectedRow] setValue:fullPath forKey:kCellPhotoKey];
    /*
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.selectedRow 
                                                                                       inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone
     ];*/
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
        
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView.backgroundView addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]]];
    [self.view addSubview:self.tableView ];
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
    //layout navigation bar

    //load data
    
}

-(void)viewWillDisappear:(BOOL)animated{
    self.dataSourcePath = [[self.datas objectAtIndex:0] objectForKey:kCellPhotoKey];
    //write data
    /*
    if([self.datas writeToFile:self.dataSourcePath atomically:YES] == NO){
        NSLog(@"write to plist file error, path %@",self.dataSourcePath);
    }
    */
    //NSLog(@"self title %@",self.title);
}

#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
