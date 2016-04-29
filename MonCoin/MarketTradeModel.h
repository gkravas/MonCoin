//
//  MarketTradeModel.h
//  MonCoin
//
//  Created by George Kravas on 3/30/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarketTradeModel : NSObject

@property (nonatomic) TransactionType type;
@property (nonatomic) NSNumber *amount;
@property (nonatomic) NSNumber *total;
@property (nonatomic) NSNumber *price;
@property (nonatomic) NSString *date;

@end
