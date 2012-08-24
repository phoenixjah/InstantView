//
//  Constant.h
//  Instantview
//
//  Created by Chia Lin on 12/8/13.
//
//

#ifndef Instantview_Constant_h
#define Instantview_Constant_h

//For PeopleViewController
#define DEFAULT_NAME_MESSAGE @"Untitled Interview"
#define APP_FILENAME @"AllInterviews"
//for PersonalViewController
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

static NSString *kCellTypeKey = @"TypeOfCell";
static NSString *kCellTextKey = @"ContentOfCell";
static NSString *kCellPhotoKey = @"PhotoOfCell";

//PDF Constant
static const CGFloat pdfSizeWidth = 612;
static const CGFloat pdfSizeHeight = 792;
static const CGFloat pdfGapX = 184;
static const CGFloat pdfGapY = 5;
static const CGFloat pdfImageWidth = 176;
static const CGFloat pdfBorderMarginX = 20;
static const CGFloat pdfBorderMarginY = 40;
static const CGFloat pdfIndent = 4;
static const CGFloat pdfHeaderLineWidth = 2;
static const CGFloat pdfHeaderHeight = 75;
static const CGFloat pdfPhotoBorderLine = 0.1;
#endif
