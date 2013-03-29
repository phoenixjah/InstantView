//
//  PDFGenerateViewController.m
//  FieldReport
//
//  Created by Chia Lin on 13/3/26.
//
//

#import "PDFGenerateViewController.h"
#import "Constant.h"
#import "UIImageView+ImagePackage.h"

@interface PDFGenerateViewController ()

@end

@implementation PDFGenerateViewController
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
-(void)generatePDFat:(NSString*)filePath fromDatas:(NSArray *)datas{
    //draw pdf
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    CGSize pageSize = CGSizeMake(pdfSizeWidth, pdfSizeHeight);//A4 size?
    
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    
    NSString *cellType;
    
    CGFloat beginX, beginY, imageHeight;
    NSInteger i;
    NSDictionary *eachCell;
    
    //portrait cell template is special
    eachCell = [datas objectAtIndex:0];//take out the portrait cell
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
    
    for (i=1;i<[datas count];i++) {
        eachCell = [datas objectAtIndex:i];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
