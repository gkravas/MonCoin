//
//  Utilities.m
//  MonCoin
//
//  Created by George Kravas on 3/29/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *)formatFloat:(float)number {
    return [NSString localizedStringWithFormat:@"%.8F", number];
}

+ (void) setGradientToMainMenuView:(UIView*)view {
    view.backgroundColor = [UIColor clearColor];
    // add a layer that overlays the cell adding a subtle gradient effect
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = @[(id)[[UIColor colorWithHexString:@"c42d34" andAlpha:1.0] CGColor],
                                     (id)[[UIColor colorWithHexString:@"b0262c" andAlpha:1.0] CGColor]];
    gradientLayer.locations = @[@0.00f, @1.00f];
    
    [view.layer insertSublayer:gradientLayer atIndex:0];
}

+ (UIViewController*) getControllerFromStoryBoardWithName:(NSString*)name {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:name];
}

+ (AppDelegate*)getAppDelegate {
    return ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
}

+ (UINavigationController*)getAppNavigationController {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    
    UIColor *firstColor = [UIColor colorWithHexString:@"1cad38" andAlpha:1.0];
    UIColor *secondColor = [UIColor colorWithHexString:@"149833" andAlpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[navigationController navigationBar] setTranslucent:NO]; // Remember, the default value is YES.
    UIColor *globalColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: globalColor}];
    [[UINavigationBar appearance] setTintColor:globalColor];
    return navigationController;
}

+ (UIAlertView*)showUIAlertViewWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
                     tapBlock:(UIAlertViewCompletionBlock)tapBlock {
    
    return [UIAlertView showWithTitle:title
                              message:message
                    cancelButtonTitle:cancelButtonTitle
                    otherButtonTitles:otherButtonTitles
                             tapBlock:tapBlock];
}

+ (NSMutableDictionary*)stripEmptyMarkets:(NSMutableDictionary*)markets {
    for (NSString *marketKey in [markets allKeys]) {
        if ( [ ( (MarketModel*)markets[ marketKey ] ).wallets count ] == 0 ) {
            [markets removeObjectForKey:marketKey];
        }
    }
    return markets;
}

+ (void)addOnWakeHandlersForController:(UIViewController*)controller withSelector:(SEL)selectorFunction {
    [[NSNotificationCenter defaultCenter] addObserver:controller selector:selectorFunction name:UIApplicationDidBecomeActiveNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:controller selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

+ (void)removeOnWakeHandlersForController:(UIViewController*)controller {
    [[NSNotificationCenter defaultCenter] removeObserver:controller name:UIApplicationDidBecomeActiveNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver name:UIApplicationWillEnterForegroundNotification object:nil];
}

+ (void) setStyleForButton:(UIButton*)button {
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.frame = button.bounds;
    gradientLayer.colors = @[(id)[[UIColor colorWithHexString:@"eeeeee" andAlpha:1.0] CGColor],
                             (id)[[UIColor colorWithHexString:@"dbdbdb" andAlpha:1.0] CGColor]];
    gradientLayer.locations = @[@0.00f, @1.00f];
    
    
    //Render Gradient
    UIGraphicsBeginImageContext(gradientLayer.frame.size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *normalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    
    [button addRightBorderWithWidth:1 andColor:[UIColor colorWithHexString:@"c2c2c2" andAlpha:1.0]];
    [button addLeftBorderWithWidth:1 andColor:[UIColor colorWithHexString:@"c2c2c2" andAlpha:1.0]];
    [button addTopBorderWithHeight:1 andColor:[UIColor colorWithHexString:@"c2c2c2" andAlpha:1.0]];
    [button addBottomBorderWithHeight:1 andColor:[UIColor colorWithHexString:@"c2c2c2" andAlpha:1.0]];
    
    
    CAGradientLayer* gradientLayerSelected = [CAGradientLayer layer];
    
    gradientLayerSelected.frame = button.bounds;
    gradientLayerSelected.colors = @[(id)[[UIColor colorWithHexString:@"efefef" andAlpha:1.0] CGColor],
                                     (id)[[UIColor colorWithHexString:@"c5c5c5" andAlpha:1.0] CGColor]];
    gradientLayerSelected.locations = @[@0.00f, @1.00f];
    [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateSelected];
    
    
    //Render Gradient
    UIGraphicsBeginImageContext(gradientLayerSelected.frame.size);
    [gradientLayerSelected renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *selectedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
}

+ (void) setRowWithGapStyleForView:(UIView*)view {
    view.backgroundColor = [UIColor clearColor];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(-2, -2, view.bounds.size.width + 4, view.bounds.size.height - 1);
    layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF" andAlpha:1.0].CGColor;
    layer.borderWidth = 1;
    layer.borderColor = [UIColor colorWithHexString:@"cccbc8" andAlpha:1.0].CGColor;
    
    [view.layer insertSublayer:layer atIndex:0];
    view.clipsToBounds = YES;
}

@end
