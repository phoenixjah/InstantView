//
//  QuoteCell.h
//  Instantview
//
//  Created by Chia Lin on 12/7/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuoteCell : UITableViewCell<UITextViewDelegate>
@property (nonatomic,strong) UITextView *description;
@end
