//
//  PersonalInterviewViewController.h
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInterviewViewController : UIViewController

@property (nonatomic,assign) IBOutlet UITableViewCell *portraitCell;
@property (nonatomic,assign) IBOutlet UITableViewCell *photoCell;
@property (nonatomic,assign) IBOutlet UITableViewCell *noteCell;
@property (nonatomic,assign) IBOutlet UITableViewCell *quoteCell;
@property (nonatomic,strong) NSString *dataSourcePath;
@end
