//
//  OpenOrderModel.h
//  MonCoin
//
//  Created by George Kravas on 3/29/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenOrderModel : NSObject

@property (nonatomic) TransactionType type;
@property (nonatomic) NSNumber *amount;
@property (nonatomic) NSNumber *profit;
@property (nonatomic) NSNumber *price;
@property (nonatomic) NSString *date;

@end
