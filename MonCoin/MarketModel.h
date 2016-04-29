//
//  MarketModel.h
//  MonCoin
//
//  Created by George Kravas on 4/6/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketModel : NSObject

@property (nonatomic) NSString *coinCode;
@property (nonatomic) NSMutableDictionary *wallets;
@property (nonatomic) NSNumber *total;

-(void) calculateTotal;
@end
