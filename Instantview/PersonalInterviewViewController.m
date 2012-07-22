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
@synthesize portraitCell,photoCell;
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

-(NSString*)generatePDF{
    NSString *fileName = [NSString stringWithFormat:@"result_%d.pdf",self.view.tag];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    //print screen
    UIGraphicsBeginImageContext(self.tableView.contentSize);
    [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //[self.view addSubview:[[UIImageView alloc]initWithImage:resultingImage]];
    //draw pdf
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
    
    CGSize pageSize = self.tableView.contentSize;
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
                
                [[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil ];
                cell = photoCell;
                self.photoCell = nil;
                
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
        UIImageView *myPhotoCell = (UIImageView*)[cell viewWithTag:PHOTO_TAG];
        NSString *fullPath = [[self.datas objectAtIndex:indexPath.row]objectForKey:kCellPhotoKey];
        myPhotoCell.image = [UIImage imageWithContentsOfFile:fullPath];
    }
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:TEXT_TAG];
    cellLabel.text = [[self.datas objectAtIndex:indexPath.row] objectForKey:kCellTextKey];
    
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
    if (indexPath.row == [self.datas count]) {//last row
        cellHeight = cellHeight + 80;
    }
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%d",indexPath.row);
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
    //store image to document
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d_%d.png",self.view.tag,self.selectedRow]]; //add our image to the path
    
    [[NSFileManager defaultManager] createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    //push the path at document to model
    [[self.datas objectAtIndex:self.selectedRow] setValue:fullPath forKey:kCellPhotoKey];
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
