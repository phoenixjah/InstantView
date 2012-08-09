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
#define DEFAULT_NOTE_MESSAGE @"What's the insight?"
#define DEFAULT_QUOTE_MESSAGE @"What did they say?"
#define DEFAULT_PHOTO_MESSAGE @"What's the photo about?"

#define PHOTO_TAG 3
#define TEXT_TAG 1
#define NAME_TAG 10
#define BACKGROUND_TAG 2

@interface PersonalInterviewViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate>
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *btns;
@property (nonatomic,assign) NSInteger selectedRow;
@property (nonatomic,strong) UIBarButtonItem *backBtn,*addElementBtn;
@end

@implementation PersonalInterviewViewController
@synthesize portraitCell,photoCell,noteCell,quoteCell;

static NSString *kCellTypeKey = @"TypeOfCell";
static NSString *kCellTextKey = @"ContentOfCell";
static NSString *kCellPhotoKey = @"PhotoOfCell";
static CGFloat PhotoCellHeight = 265;
static CGFloat QuoteCellHeight = 130;
static CGFloat NoteCellHeight = 173;
static CGFloat PortraitCellHeight = 317;

#pragma mark - Btn Setters Funcions
-(NSArray*)btns{
    
    if (_btns == nil) {
        UIButton *addPhoto,*addQuote,*addNote,*share;
        addPhoto = [self setButtonWithImage:@"add_photo.png"];
        addQuote = [self setButtonWithImage:@"add_quote.png"];
        addNote = [self setButtonWithImage:@"add_postit.png"];
        share = [self setButtonWithImage:@"add_email.png"];
        [addQuote addTarget:self action:@selector(addElement:) forControlEvents:UIControlEventTouchUpInside];
        [addNote addTarget:self action:@selector(addElement:) forControlEvents:UIControlEventTouchUpInside];
        [addPhoto addTarget:self action:@selector(addElement:) forControlEvents:UIControlEventTouchUpInside];
        [share addTarget:self action:@selector(shareResultPressed:) forControlEvents:UIControlEventTouchUpInside];
        _btns = [NSArray arrayWithObjects:addNote,addPhoto,addQuote,share, nil];
    }
    return _btns;
}
-(UIButton*)setButtonWithImage:(NSString*)name{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 53, 53);
    return btn;
}
#pragma mark - Text Input Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //NSLog(@"textFieldBeginEdit tag = %d",textField.tag);
    //UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
    //NSLog(@"cell index %d",[self.tableView indexPathForCell:cell].row);
    //NSLog(@"original %f,converted %f",textField.frame.origin.y,convertedPoint.y);
    [self.tableView setContentOffset:CGPointMake(0, textField.frame.origin.y - 170) animated:YES];
    self.tableView.scrollEnabled = NO;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
   
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
    self.tableView.scrollEnabled = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
    [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y) animated:YES];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    //NSLog(@"textView Begin");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tableView.userInteractionEnabled = NO;
    UITableViewCell *cell = (UITableViewCell*)[[textView superview] superview];
    //NSLog(@"cell index = %d",[self.tableView indexPathForCell:cell].row);
    
    //scroll view to upper area
    //PhotoCell need special care
    if ([cell.reuseIdentifier isEqualToString:PHOTO_CELL]) {
        [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y + 80) animated:YES];
    }else{
        [self.tableView setContentOffset:CGPointMake(0, cell.frame.origin.y - 80) animated:YES];
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.tableView.userInteractionEnabled = YES;
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
    NSString *fileName = [NSString stringWithFormat:@"result_%d.pdf",self.view.tag+1];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    //write a pdf
    [self generatePDF:pdfFileName];
    //send it through email
    [self sendMailWithAttach:pdfFileName];
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

-(void)generatePDF:(NSString*)filePath{
    //draw pdf
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    CGSize pageSize = self.tableView.contentSize;

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
            [self drawText:[NSString stringWithFormat:@"'%@'",[eachCell objectForKey:kCellTextKey]] at:CGRectMake(38, beginY + QuoteCellHeight/2, 251, 63)];
            beginY = beginY + QuoteCellHeight;
        }else {
                    //it's the image content
                    [self drawImage:[eachCell objectForKey:kCellPhotoKey] at:CGRectMake(20, beginY, 280, 200)];
            beginY = beginY + PhotoCellHeight;
                        }
    }
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}
#pragma mark - Add Element Btn Functions

-(void)addElementPressed:(id)sender{
    self.tableView.userInteractionEnabled = NO;
    //display the option btns to add
    __block NSInteger i;
    CGPoint coor = self.navigationItem.rightBarButtonItem.customView.frame.origin;
    for (UIButton* btn in self.btns) {
        btn.center = CGPointMake(coor.x + 10, -30);
    }
    [UIView animateWithDuration:0.3
                     animations:^{
    for (i=[self.btns count]-1; i>=0; i--) {
        UIButton *btn = [self.btns objectAtIndex:i];
        [self.view addSubview:btn];
        btn.center = CGPointMake(coor.x + 10, 30+i*55);
    }
                     }
     ];
}

-(void)addElement:(id)sender{
    //index of Note = 0, Photo = 1, Quote = 2
    NSInteger buttonIndex = [self.btns indexOfObject:sender];
    switch (buttonIndex) {
        case 0:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NOTE_CELL,kCellTypeKey, DEFAULT_NOTE_MESSAGE,kCellTextKey,nil]];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.datas count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            break;
        case 1:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:PHOTO_CELL,kCellTypeKey,DEFAULT_PHOTO_MESSAGE,kCellTextKey, nil]];
            [self.tableView reloadData];
            self.selectedRow = [self.datas count]-1;//image picker delegate would use
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [self addImageToCell];
            break;
        case 2:
            [self.datas addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:QUOTE_CELL,kCellTypeKey,DEFAULT_QUOTE_MESSAGE,kCellTextKey, nil]];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.datas count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            break;
        default://cancel
            NSLog(@"WTF in addElement??");
            break;
    }
    //disappear btns
    __block NSInteger i;
    CGPoint coor = self.navigationItem.rightBarButtonItem.customView.frame.origin;
    [UIView animateWithDuration:0.5
                     animations:^{
                         for (i=0; i<[self.btns count]; i++) {
                             UIButton *btn = [self.btns objectAtIndex:i];
                             btn.center = CGPointMake(coor.x + 10, -30);
                         }
                     }
                     completion:^(BOOL finished){
                         for (UIButton* btn in self.btns) {
                             [btn removeFromSuperview];
                         }
                     }
    ];
    self.tableView.userInteractionEnabled = YES;
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
    //dispatch_queue_t handleImage = dispatch_queue_create("resize image and store", NULL);
    //dispatch_async(handleImage, ^{
        
    //    dispatch_async(dispatch_get_main_queue(), ^{
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
     ];*///});
    //});
    //dispatch_release(handleImage);
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
    self.backBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = self.backBtn;
    self.navigationItem.hidesBackButton = YES;
    
    //put add btn
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"btn_plus_normal.png"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"btn_plus_pressed.png"]
                      forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addElementPressed:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.frame = CGRectMake(0, 0, 39, 39);
    self.addElementBtn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = self.addElementBtn;
    
    //set add element btns
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.datas = nil;
    self.tableView = nil;
    self.btns = nil;
    self.backBtn = nil;
    self.addElementBtn = nil;
}

-(void)viewWillAppear:(BOOL)animated{
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
