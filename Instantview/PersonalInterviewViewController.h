//
//  PersonalInterviewViewController.h
//  Instantview
//
//  Created by Chia Lin on 12/7/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInterviewViewController : UIViewController{
    NSString *dataSourcePath;
}
@property (nonatomic,assign) IBOutlet UITableViewCell *portraitCell;
@property (nonatomic,assign) IBOutlet UITableViewCell *photoCell;
@property (nonatomic,strong) NSString *dataSourcePath;
@end
