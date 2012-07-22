//
//  PhotoCell.m
//  Instantview
//
//  Created by Chia Lin on 12/7/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhotoCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation PhotoCell
@synthesize photo = _photo
;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImage *background = [UIImage imageNamed:@"Photo.png"];
        self.contentView.layer.contents = (id)background.CGImage;
        
        self.photo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 6, 290, 163)];
        //self.photo.contentMode = UIViewContentModeScaleAspectFill;
        self.photo.tag = 3;
        self.photo.backgroundColor = [UIColor blueColor];
        [self addSubview:self.photo];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
