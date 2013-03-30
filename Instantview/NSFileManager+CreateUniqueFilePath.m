//
//  NSFileManager+CreateUniqueFilePath.m
//  FieldReport
//
//  Created by Chia Lin on 13/3/26.
//
//

#import "NSFileManager+CreateUniqueFilePath.h"

@implementation NSFileManager (CreateUniqueFilePath)
+(NSString*)createUniqueFileName{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    
    NSString* newUniqueName = [NSString stringWithFormat:@"%@",newUniqueIdString];
    //NSLog(@"new str = %@",newUniquePath);
    CFRelease(newUniqueId);
    CFRelease(newUniqueIdString);
    //NSLog(@"new str after release %@",newUniquePath);
    return newUniqueName;
}

@end
