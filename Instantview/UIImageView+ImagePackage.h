//
//  UIImageView+ImagePackage.h
//  Instantview
//
//  Created by Chia Lin on 12/8/2.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (ImagePackage)
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
@end
