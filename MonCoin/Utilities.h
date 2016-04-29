//
//  Utilities.h
//  MonCoin
//
//  Created by George Kravas on 3/29/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+HexString.h"
#import "AppDelegate.h"
#import "UIAlertView+Blocks.h"
#import "MarketModel.h"
#import "UIView+Borders.h"

@interface Utilities : NSObject

+ (NSString *)formatFloat:(float)number;
+ (void) setGradientToMainMenuView:(UIView*)view;
+ (UIViewController*) getControllerFromStoryBoardWithName:(NSString*)name;
+ (AppDelegate*)getAppDelegate;
+ (UINavigationController*)getAppNavigationController;
+ (UIAlertView*)showUIAlertViewWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                     tapBlock:(UIAlertViewCompletionBlock)tapBlock;

+ (NSMutableDictionary*)stripEmptyMarkets:(NSDictionary*)markets;
+ (void)addOnWakeHandlersForController:(UIViewController*)controller withSelector:(SEL)selectorFunction;
+ (void)removeOnWakeHandlersForController:(UIViewController*)controller;
+ (void) setStyleForButton:(UIButton*)button;
+ (void) setRowWithGapStyleForView:(UIView*)view;

@end
