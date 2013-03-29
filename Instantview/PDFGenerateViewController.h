//
//  PDFGenerateViewController.h
//  FieldReport
//
//  Created by Chia Lin on 13/3/26.
//
//

#import <UIKit/UIKit.h>

@interface PDFGenerateViewController : UIViewController
-(void)generatePDFat:(NSString*)filePath fromDatas:(NSArray*)datas;
@end
