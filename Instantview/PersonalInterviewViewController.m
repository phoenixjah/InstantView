//
//  PersonalInterviewViewController.m
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PersonalInterviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "UIImageView+ImagePackage.h"

#define PHOTO_CELL @"PhotoCell"
#define NOTE_CELL @"NoteCell"
#define QUOTE_CELL @"QuoteCell"
#define DEFAULT_NOTE_MESSAGE @"What do you think?"
#define DEFAULT_QUOTE_MESSAGE @"What did they say?"
#define DEFAULT_PHOTO_MESSAGE @"Topic of photo"

#define PHOTO_TAG 3
#define TEXT_TAG 1
#define NAME_TAG 10
#define BACKGROUND_TAG 2

@interface PersonalInterviewViewController ()<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate>
{
    UIBarButtonItem *backBtn;
}
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
    self.navigationItem.leftBarButtonItem = nil;
    NSLog(@"textFieldBeginEdit tag = %d",textField.tag);
    //UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
    //NSLog(@"cell index %d",[self.tableView indexPathForCell:cell].row);
    //NSLog(@"original %f,converted %f",textField.frame.origin.y,convertedPoint.y);
    [self.tableView setContentOffset:CGPointMake(0, textField.frame.origin.y - 150) animated:YES];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    self.navigationItem.leftBarButtonItem = backBtn;
    if (textField.tag == NAME_TAG) {
        self.title = textField.text;
        [[self.datas objectAtIndex:0] setObject:textField.text forKey:@"Name"];
    }else if(textField.tag == BACKGROUND_TAG){
        [[self.datas objectAtIndex:0] setObject:textField.text forKey:@"Background"];
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
    [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y) animated:YES];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    //NSLog(@"textView Begin");
    self.navigationItem.leftBarButtonItem = nil;
    UITableViewCell *cell = (UITableViewCell*)[[textView superview] superview];
    NSLog(@"cell index = %d",[self.tableView indexPathForCell:cell].row);
    
    //scroll view to upper area
    //PhotoCell need special care
    if ([cell.reuseIdentifier isEqualToString:PHOTO_CELL]) {
        [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y + 60) animated:YES];
    }else{
        [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y - 60) animated:YES];
    }
    if ([textView.text isEqualToString:DEFAULT_PHOTO_MESSAGE] || [textView.text isEqualToString:DEFAULT_NOTE_MESSAGE] || [textView.text isEqualToString:DEFAULT_QUOTE_MESSAGE]) {
        textView.text = @"";
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        //return NO;
    }
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    self.navigationItem.leftBarButtonItem = backBtn;
    UITableViewCell *cell = (UITableViewCell*)[[textView superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    //NSLog(@"textView Ended");
    //put the text into data source
    [[self.datas objectAtIndex:indexPath.row] setObject:textView.text forKey:kCellTextKey];
    
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
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:PHOTO_CELL,kCellTypeKey,DEFAULT_PHOTO_MESSAGE,kCellTextKey, nil]];
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
                
                UILabel *cellLabel = (UILabel*)[cell viewWithTag:TEXT_TAG];
                [cellLabel setFont:[UIFont fontWithName:@"Kefa" size:20.0]];
            }else if ([cellType isEqualToString:@"PortraitCell"]) {
                [[NSBundle mainBundle] loadNibNamed:@"PortraitCell" owner:self options:nil ];
                cell = portraitCell;
                self.portraitCell = nil;
            }else {
                NSLog(@"In CellForRowAtIndexPath Error");
            }
        
    }
    
    [self configureCell:cell atIndex:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath{
    
    //process cell that have images
    if ([cell.reuseIdentifier isEqualToString:PHOTO_CELL] || [cell.reuseIdentifier isEqualToString:@"PortraitCell"]) {
        UIImageView *myPhotoCell = (UIImageView*)[cell viewWithTag:PHOTO_TAG];
        //load image if it is nil
        NSString *fullPath = [[self.datas objectAtIndex:indexPath.row]objectForKey:kCellPhotoKey];
        //NSLog(@"photocell path %@",fullPath);
        if (fullPath == nil) {//new photoCell
            myPhotoCell.image = nil;
        }else if (myPhotoCell.image == nil) {//reload image if it is release
            myPhotoCell.image = [UIImage imageWithContentsOfFile:fullPath];
        }
    }
    //process cell's text content
    if ([cell.reuseIdentifier isEqualToString:@"PortraitCell"]) {//portrait cell has more than one text
        UITextField *nameField = (UITextField*)[cell viewWithTag:NAME_TAG];
        nameField.text = [[self.datas objectAtIndex:0] objectForKey:@"Name"];
        self.title = nameField.text;
        UITextField *backGround = (UITextField*)[cell viewWithTag:BACKGROUND_TAG];
        backGround.text = [[self.datas objectAtIndex:0] objectForKey:@"Background"];
    }else{//PhotoCell, NoteCell, QuoteCell just has one text input
        UILabel *cellLabel = (UILabel*)[cell viewWithTag:TEXT_TAG];
        cellLabel.text = [[self.datas objectAtIndex:indexPath.row] objectForKey:kCellTextKey];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
    
    [self.tableView setContentOffset:selectedCell.frame.origin animated:YES];
    //NSLog(@"use identifier %@",selectedCell.reuseIdentifier);
    //selected then is edited
    if ([selectedCell.reuseIdentifier isEqualToString:PHOTO_CELL] || [selectedCell.reuseIdentifier isEqualToString:@"PortraitCell"]) {//pick image
        [self addImageToCell];
    
    }else{
        UITextView *inputView = (UITextView*)[selectedCell viewWithTag:TEXT_TAG];
        [inputView becomeFirstResponder];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
    UIImageView *cellImage = (UIImageView*)[cell viewWithTag:PHOTO_TAG];
    
    image = [UIImageView imageWithImage:image scaledToSize:cellImage.frame.size];
    //store image to document
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d_%d.png",self.view.tag,self.selectedRow]]; //add our image to the path

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
-(void)backPrev:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    //setup modal
    self.datas = [NSMutableArray array];
    
    [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PortraitCell",kCellTypeKey,@"",@"Name",@"",@"Background", nil]];
    [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey,DEFAULT_NOTE_MESSAGE,kCellTextKey, nil]];
    
    //setup subviews template
        
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView.backgroundView addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]]];
    [self.view addSubview:self.tableView ];
    self.tableView.separatorColor = [UIColor clearColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_normal.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed.png"]
                      forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(backPrev:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 39, 39);
    backBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backBtn;
    self.navigationItem.hidesBackButton = YES;
    
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
    backBtn = nil;
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
