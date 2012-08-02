//
//  QuoteCell.m
//  Instantview
//
//  Created by Chia Lin on 12/7/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuoteCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation QuoteCell
@synthesize description = _description;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImage *background = [UIImage imageNamed:@"Quote.png"];
        [self.contentView addSubview:[[UIImageView alloc]initWithImage:background]];

        self.textLabel.textColor = [UIColor grayColor];
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.numberOfLines = 3;
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.tag = 1;
        [self.textLabel setFont:[UIFont fontWithName:@"Kefa" size:20.0]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
