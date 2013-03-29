//
//  Quote.h
//  FieldReport
//
//  Created by Chia Lin on 13/3/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Interview;

@interface Quote : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Interview *whoseQuotes;

@end
