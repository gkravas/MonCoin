//
//  UIColor.h
//  Crowdcast
//
//  Created by George Kravas on 11/20/12.
//  Copyright (c) 2012 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (ColorWithHex)

+(UIColor*)colorWithHexValue:(uint)hexValue andAlpha:(float)alpha;
+(UIColor*)colorWithHexString:(NSString *)hexString andAlpha:(float)alpha;

@end
