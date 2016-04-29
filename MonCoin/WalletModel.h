//
//  WalletModel.h
//  MonCoin
//
//  Created by George Kravas on 3/30/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalletModel : NSObject<NSCoding>

@property (nonatomic) NSString *coinCode;
@property (nonatomic) NSString *coinName;
@property (nonatomic) NSString *exchangeCoinCode;
@property (nonatomic) NSString *exchangeCoinName;
@property (nonatomic) NSNumber *price;
@property (nonatomic) NSNumber *balance;
@property (nonatomic) NSNumber *orderBalance;
@property (nonatomic) NSNumber *marketId;

- (float) getTotalPrice;

@end
