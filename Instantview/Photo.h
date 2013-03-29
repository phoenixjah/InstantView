//
//  Photo.h
//  FieldReport
//
//  Created by Chia Lin on 13/3/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Interview;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Interview *whosePhotos;

@end
