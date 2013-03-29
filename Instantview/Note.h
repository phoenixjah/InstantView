//
//  Note.h
//  FieldReport
//
//  Created by Chia Lin on 13/3/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Interview;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Interview *whoseNotes;

@end
