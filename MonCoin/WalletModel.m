//
//  WalletModel.m
//  MonCoin
//
//  Created by George Kravas on 3/30/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "WalletModel.h"

@implementation WalletModel

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.coinCode forKey:@"coinCode"];
    [encoder encodeObject:self.coinName forKey:@"coinName"];
    [encoder encodeObject:self.exchangeCoinCode forKey:@"exchangeCoinCode"];
    [encoder encodeObject:self.exchangeCoinName forKey:@"exchangeCoinName"];
    [encoder encodeObject:self.price forKey:@"price"];
    [encoder encodeObject:self.balance forKey:@"balance"];
    [encoder encodeObject:self.orderBalance forKey:@"orderBalance"];
    [encoder encodeObject:self.marketId forKey:@"marketId"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self.coinCode = [decoder decodeObjectForKey:@"coinCode"];
    self.coinName = [decoder decodeObjectForKey:@"coinName"];
    self.exchangeCoinCode = [decoder decodeObjectForKey:@"exchangeCoinCode"];
    self.exchangeCoinName = [decoder decodeObjectForKey:@"exchangeCoinName"];
    self.price = [decoder decodeObjectForKey:@"price"];
    self.balance = [decoder decodeObjectForKey:@"balance"];
    self.orderBalance = [decoder decodeObjectForKey:@"orderBalance"];
    self.marketId = [decoder decodeObjectForKey:@"marketId"];
    
    return self;
}

- (float) getTotalPrice {
    return [self.price floatValue]* ([self.balance floatValue] + [self.orderBalance floatValue]);
}

@end
