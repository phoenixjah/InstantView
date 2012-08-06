//
//  UIImageView+ImagePackage.m
//  Instantview
//
//  Created by Chia Lin on 12/8/2.
//
//

#import "UIImageView+ImagePackage.h"

@implementation UIImageView (ImagePackage)
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    //Keep the ratio of the image
    CGFloat widthRatio = image.size.width/newSize.width;
    CGFloat heightRatio = image.size.height/newSize.height;
    
    if (widthRatio < heightRatio) {//fit to width
        newSize = CGSizeMake(newSize.width, image.size.height/widthRatio);
    }else{//fit to height
        newSize = CGSizeMake(image.size.width/heightRatio, newSize.height);
    }
    
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
@end
