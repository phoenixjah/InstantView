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
#import "Constant.h"

@interface PersonalInterviewViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate>
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *btns;
@property (nonatomic,assign) NSInteger selectedRow;
@property (nonatomic,strong) UIBarButtonItem *backBtn,*addElementBtn,*closeBtn;
@end

@implementation PersonalInterviewViewController
@synthesize portraitCell,photoCell,noteCell,quoteCell;

static CGFloat PhotoCellHeight = 270;
static CGFloat QuoteCellHeight = 135;
static CGFloat NoteCellHeight = 175;
static CGFloat PortraitCellHeight = 317;
static BOOL btnsShow = NO;

#pragma mark - Setters Getters Funcions
-(NSMutableArray*)datas{
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithContentsOfFile:self.dataSourcePath];
    }
    return _datas;
}
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
    if (btnsShow) {
        [self clearBtns];
    }

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //NSLog(@"original %f,converted %f",textField.frame.origin.y,convertedPoint.y);
    [self.tableView setContentOffset:CGPointMake(0, textField.frame.origin.y - 170) animated:YES];
    self.tableView.scrollEnabled = NO;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
   
    if (textField.tag == NAME_TAG) {
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
    if (btnsShow) {
        [self clearBtns];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.tableView.scrollEnabled = NO;
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
    self.tableView.scrollEnabled = YES;
    UITableViewCell *cell = (UITableViewCell*)[[textView superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    //NSLog(@"textView Ended");
    //put the text into data source
    [[self.datas objectAtIndex:indexPath.row] setObject:textView.text forKey:kCellTextKey];
    
}

#pragma mark - Cell Edit Funtcion
-(void)addImageToCell{
    if (btnsShow) {
        [self clearBtns];
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark - Share Result Btn Functions

-(void)shareResultPressed:(id)sender{
    NSString *fileName = [NSString stringWithFormat:@"result_%d.pdf",self.view.tag];
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
    [mailer setSubject:[NSString stringWithFormat:@"[FIELD REPORT] %@ Interview",[[self.datas objectAtIndex:0]objectForKey:@"Name"]]];
    
    
    //ATTACH FILE
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){//Does file exist?
        //NSLog(@"in NewCardSorting sendResult File exists to attach");
        
        NSData *myData = [NSData dataWithContentsOfFile:filePath];
        
        [mailer addAttachmentData:myData mimeType:@"application/pdf"
                         fileName:[NSString stringWithFormat:@"%@.pdf",[[self.datas objectAtIndex:0]objectForKey:@"Name"]]];
        
    }
    
    //CREATE EMAIL BODY TEXT
    [mailer setMessageBody:@"Hi! I would like to share this interview I did on the field with you.\n\n\nSent from FieldReport App" isHTML:NO];
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
- (CGFloat) drawBorder:(CGRect)rectSize//return the height of the border
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor lightGrayColor];
    
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, pdfPhotoBorderLine);
    CGContextStrokeRect(currentContext, rectSize);
    //draw the shadow of the border
    UIImage *shadowImage = [UIImage imageNamed:@"PDFshadow"];
    shadowImage = [UIImageView imageWithImage:shadowImage scaledToSize:CGSizeMake(pdfGapX, shadowImage.size.height*(pdfGapX/320))];
    [shadowImage drawAtPoint:CGPointMake(rectSize.origin.x, rectSize.origin.y + rectSize.size.height)];
    shadowImage = nil;
    return rectSize.size.height + pdfGapY;
}

-(CGFloat)drawImage:(NSString*)pathForImage at:(CGPoint)pointToDraw{
    UIImage *imageToDraw = [[UIImage alloc] initWithContentsOfFile:pathForImage];
    CGFloat ratio = imageToDraw.size.width/pdfImageWidth;
    
    [imageToDraw drawInRect:CGRectMake(pointToDraw.x,pointToDraw.y,pdfImageWidth,imageToDraw.size.height/ratio)];
    
    //draw frame for photo
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor lightGrayColor];
    
    
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, 0.05);
    CGContextStrokeRect(currentContext, CGRectMake(pointToDraw.x-0.1,pointToDraw.y-0.1,pdfImageWidth + 0.1,imageToDraw.size.height/ratio+0.1));
    return imageToDraw.size.height/ratio;//return the height of the image
}

-(void)drawPageTitle:(NSString*)title{
    CGFloat axiesY = pdfBorderMarginY;
    CGSize textSize;
    //draw line
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(currentContext, pdfHeaderLineWidth);
    
    CGContextSetStrokeColorWithColor(currentContext, [UIColor darkGrayColor].CGColor);
    
    CGPoint startPoint = CGPointMake(pdfBorderMarginX, pdfBorderMarginY);
    CGPoint endPoint = CGPointMake(pdfSizeWidth - pdfBorderMarginX, pdfBorderMarginY);
    
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    
    axiesY = axiesY + 5.0;
    //draw titles
    //draw "INTERVIEW"
    CGContextSetRGBFillColor(currentContext, 89.0/255.0, 89.0/255.0, 89.0/255.0, 1.0);
    NSString *subtitle = @"FieldReport Interview";
    UIFont *font = [UIFont fontWithName:@"Kefa" size:14.0];
    textSize = [subtitle drawAtPoint:CGPointMake(pdfBorderMarginX + pdfIndent, axiesY) withFont:font];
    //draw title,ex:NAME - BACKGROUND
    axiesY = axiesY + textSize.height;
    font = [UIFont boldSystemFontOfSize:21];
    /*
    CGFloat fontSize;
    
    [title drawAtPoint:CGPointMake(pdfBorderMarginX + pdfIndent, axiesY)
              forWidth:pdfSizeWidth - 2*(pdfIndent + pdfBorderMarginX)
              withFont:font
           minFontSize:20.0
        actualFontSize:&fontSize
         lineBreakMode:UILineBreakModeTailTruncation
    baselineAdjustment:UIBaselineAdjustmentNone
     ];
    NSLog(@"%f",fontSize);*/
    
    textSize = [title drawInRect:CGRectMake(pdfBorderMarginX + pdfIndent, axiesY, pdfSizeWidth-2*(pdfIndent + pdfBorderMarginX), pdfHeaderHeight - textSize.height - pdfGapY*2)
             withFont:font lineBreakMode:UILineBreakModeTailTruncation
     ];
    
}
-(void)generatePDF:(NSString*)filePath{
    //draw pdf
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    CGSize pageSize = CGSizeMake(pdfSizeWidth, pdfSizeHeight);//A4 size?
    
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    
    NSString *cellType;
    
    CGFloat beginX, beginY, imageHeight;
    NSInteger i;
    NSDictionary *eachCell;
    
    //portrait cell template is special
    eachCell = [self.datas objectAtIndex:0];//take out the portrait cell
    //draw header first
    [self drawPageTitle:[NSString stringWithFormat:@"%@ - %@",[eachCell objectForKey:@"Name"],[eachCell objectForKey:@"Background"]]];
    
    beginX = pdfBorderMarginX + pdfIndent;
    beginY = pdfBorderMarginY + pdfHeaderHeight + pdfGapY;
    
    imageHeight = [self drawImage:[eachCell objectForKey:kCellPhotoKey] at:CGPointMake(beginX + pdfIndent, beginY+pdfIndent)];
    //draw Name of the profile
    imageHeight = imageHeight + pdfIndent + [(NSString*)[eachCell objectForKey:@"Name"] drawAtPoint:CGPointMake(beginX + pdfIndent + 2, beginY + imageHeight + pdfIndent)
                                                                                           forWidth:pdfImageWidth - pdfIndent
                                                                                           withFont:[UIFont boldSystemFontOfSize:21.0]
                                                                                        minFontSize:13
                                                                                     actualFontSize:nil
                                                                                      lineBreakMode:UILineBreakModeTailTruncation
                                                                                 baselineAdjustment:UIBaselineAdjustmentNone
                                             ].height;
    //draw border for the image
    beginY = beginY + [self drawBorder:CGRectMake(beginX, beginY, pdfGapX, imageHeight + pdfGapY)];
    beginY = beginY + pdfGapY;
    
    //draw the remains cell
    UIImage *noteImage = [UIImage imageNamed:@"note.png"];
    noteImage = [UIImageView imageWithImage:noteImage scaledToSize:CGSizeMake(pdfGapX, noteImage.size.height*(pdfGapX/320))];
    UIImage *quoteImage = [UIImage imageNamed:@"quote.png"];
    quoteImage = [UIImageView imageWithImage:quoteImage scaledToSize:CGSizeMake(pdfGapX,quoteImage.size.height*(pdfGapX/320))];
    CGFloat threashould;
    
    for (i=1;i<[self.datas count];i++) {
        eachCell = [self.datas objectAtIndex:i];
        cellType = [eachCell objectForKey:kCellTypeKey];
        
        if ([cellType isEqualToString:PHOTO_CELL]) {
            threashould = PhotoCellHeight;
        }else{
            threashould = noteImage.size.height;
        }
        //reset the drawing offset
        if (beginY + threashould > pageSize.height - pdfBorderMarginY/2) {//change to next column
            beginY = pdfBorderMarginY + pdfHeaderHeight + pdfGapY;
            beginX = beginX + pdfGapX + pdfIndent*3;
            if (beginX + pdfGapX >= pageSize.width) {//excceed the page, create the new page
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
                CGContextRef    currentContext = UIGraphicsGetCurrentContext();
                CGContextSetRGBFillColor(currentContext, 89.0/255.0, 89.0/255.0, 89.0/255.0, 1.0);
                beginX = pdfBorderMarginX;
                beginY = pdfBorderMarginY + pdfHeaderHeight + pdfGapY;
                
            }
        }
        
        if ([cellType isEqualToString:NOTE_CELL]) {
            //it's the text content
            [noteImage drawAtPoint:CGPointMake(beginX, beginY)];
            [(NSString*)[eachCell objectForKey:kCellTextKey] drawInRect:CGRectMake(beginX + 10, beginY+16, noteImage.size.width - 20, noteImage.size.height - 2*pdfIndent)
                                                               withFont:[UIFont fontWithName:@"MarkerFelt-Thin" size:13.0]
                                                          lineBreakMode:UILineBreakModeWordWrap
                                                              alignment:UITextAlignmentCenter];
            
            beginY = beginY + noteImage.size.height + pdfGapY;
            
        }else if ([cellType isEqualToString:QUOTE_CELL]) {
            [quoteImage drawAtPoint:CGPointMake(beginX, beginY)];
            [(NSString*)[eachCell objectForKey:kCellTextKey] drawInRect:CGRectMake(beginX + 10, beginY + 18, quoteImage.size.width - 20, quoteImage.size.height - 2*pdfIndent)

                                                               withFont:[UIFont fontWithName:@"Kefa" size:11.0]
                                                          lineBreakMode:UILineBreakModeWordWrap
                                                              alignment:UITextAlignmentCenter
             ];
            beginY = beginY + quoteImage.size.height + pdfGapY;
            
        }else if([cellType isEqualToString:PHOTO_CELL]){
            //it's the image content
            imageHeight = [self drawImage:[eachCell objectForKey:kCellPhotoKey] at:CGPointMake(beginX + pdfIndent, beginY + pdfIndent)];
        
            [(NSString*)[eachCell objectForKey:kCellTextKey] drawInRect:CGRectMake(beginX + 10, beginY + imageHeight + pdfIndent + 3, pdfImageWidth, 30)
                                                               withFont:[UIFont systemFontOfSize:10.0]
                                                          lineBreakMode:UILineBreakModeWordWrap
                                                              alignment:UITextAlignmentCenter
             ];
            imageHeight = imageHeight + 30;
            beginY = beginY + [self drawBorder:CGRectMake(beginX, beginY, pdfGapX, imageHeight + pdfGapY)];
            
            beginY = beginY + pdfGapY;
        }
        
    }
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    noteImage = nil;
    quoteImage = nil;
}
#pragma mark - Add Element Btn Functions

-(void)addElementPressed:(id)sender{
    //self.tableView.allowsSelection = NO;
    //CGPoint velocity = [self.tableView.panGestureRecognizer velocityInView:self.tableView.panGestureRecognizer.view];
    //UIGestureRecognizerState gestureState = self.tableView.panGestureRecognizer.state;
    
    if (btnsShow == NO) {
    //display the option btns to add
    __block NSInteger i;
    
    for (UIButton* btn in self.btns) {
        btn.center = CGPointMake(288, -30);
    }
    [UIView animateWithDuration:0.3
                     animations:^{ 
                         
                         for (i=[self.btns count]-1; i>=0; i--) {
                             UIButton *btn = [self.btns objectAtIndex:i];
                             [self.view addSubview:btn];
                             btn.center = CGPointMake(288, 30+i*55);
                         }
                     }
     ];
        btnsShow = YES;
        [self.navigationItem setRightBarButtonItem:self.closeBtn animated:YES];
        //self.addElementBtn.customView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0.2);
        //self.addElementBtn.customView.backgroundColor = [UIColor blackColor];
    }else if(btnsShow == YES){
        //[self closeTheAddBtns];//and set btnsShow = NO
        // self.addElementBtn.customView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0.0);
    }
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
    [self closeTheAddBtns];
}

-(void)closeTheAddBtns{
    __block NSInteger i;
    [UIView animateWithDuration:0.3
                     animations:^{
                         for (i=0; i<[self.btns count]; i++) {
                             UIButton *btn = [self.btns objectAtIndex:i];
                             btn.center = CGPointMake(288, -30);
                         }
                     }
                     completion:^(BOOL finished){
                         for (UIButton* btn in self.btns) {
                             [btn removeFromSuperview];
                         }
                     }
     ];
    btnsShow = NO;
    [self.navigationItem setRightBarButtonItem:self.addElementBtn animated:YES];
    //self.tableView.allowsSelection = YES;
}
-(void)clearBtns{
    for (UIButton* btn in self.btns) {
        [btn removeFromSuperview];
    }
    btnsShow = NO;
    [self.navigationItem setRightBarButtonItem:self.addElementBtn animated:YES];
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
        //myPhotoCell.image = [UIImage imageWithContentsOfFile:fullPath];
        if (fullPath == nil) {//new photoCell
            myPhotoCell.image = nil;
        }else{//reload image if it is release
            myPhotoCell.image = [UIImage imageWithContentsOfFile:fullPath];
            [myPhotoCell.layer setBorderWidth:1.0];
            [myPhotoCell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        }
    }
    //process cell's text content
    if ([cell.reuseIdentifier isEqualToString:@"PortraitCell"]) {//portrait cell has more than one text
        UITextField *nameField = (UITextField*)[cell viewWithTag:NAME_TAG];
        nameField.text = [[self.datas objectAtIndex:0] objectForKey:@"Name"];
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
    //dispatch_queue_t handleImage = dispatch_queue_create("resize image and store", NULL);
    //dispatch_async(handleImage, ^{
    
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%d_%d.png",self.view.tag,self.selectedRow]]; //add our image to the path

    
        
    [[NSFileManager defaultManager] createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    //push the path at document to model
    [[self.datas objectAtIndex:self.selectedRow] setValue:fullPath forKey:kCellPhotoKey];
    cellImage.image = image;
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
    
    //setup subviews template
        
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -1, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:self.tableView];
    self.tableView.separatorColor = [UIColor clearColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_normal.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed.png"]
                      forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(backPrev:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 32, 32);
    self.backBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = self.backBtn;
    self.navigationItem.hidesBackButton = YES;
    
    //put add btn
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"btn_plus_normal.png"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"btn_plus_pressed.png"]
                      forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addElementPressed:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.frame = CGRectMake(0, 0, 32, 32);
    self.addElementBtn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = self.addElementBtn;
    
    //init close btn
    UIButton *closeAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeAddBtn setBackgroundImage:[UIImage imageNamed:@"btn_close_normal.png"] forState:UIControlStateNormal];
    [closeAddBtn setBackgroundImage:[UIImage imageNamed:@"btn_close_pressed.png"]
                      forState:UIControlStateHighlighted];
    [closeAddBtn addTarget:self action:@selector(closeTheAddBtns) forControlEvents:UIControlEventTouchUpInside];
    closeAddBtn.frame = CGRectMake(0, 0, 32, 32);
    self.closeBtn = [[UIBarButtonItem alloc] initWithCustomView:closeAddBtn];
    
    //add Gesture Recognizer
    //[self.tableView.panGestureRecognizer addTarget:self action:@selector(addElementPressed:)];
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
    self.closeBtn = nil;
}

-(void)viewWillAppear:(BOOL)animated{
      //[[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"int_nav.gif"] forBarMetrics:UIBarMetricsDefault];
    //load data
    
}

-(void)viewWillDisappear:(BOOL)animated{
    if (btnsShow) {
        [self clearBtns];
    }
    
    //write data
    if([self.datas writeToFile:self.dataSourcePath atomically:YES] == NO){
        NSLog(@"in PersonalViewController write to plist file error, path %@",self.dataSourcePath);
    }else{
        self.datas = nil;
    }
    
    //NSLog(@"self title %@",self.title);
}

#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
