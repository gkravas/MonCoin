//
//  MarketModel.m
//  MonCoin
//
//  Created by George Kravas on 4/6/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "MarketModel.h"

@implementation MarketModel

- (id)init {
    self = [super init];
    if ( self ) {
        self.wallets = [@{} mutableCopy];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.coinCode forKey:@"coinCode"];
    [encoder encodeObject:self.wallets forKey:@"wallets"];
    [encoder encodeObject:self.total forKey:@"total"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self.coinCode = [decoder decodeObjectForKey:@"coinCode"];
    self.wallets = [decoder decodeObjectForKey:@"wallets"];
    self.total = [decoder decodeObjectForKey:@"total"];
    
    return self;
}

- (void)calculateTotal {
    float total = 0;
    NSArray *coinCodes = [self.wallets allKeys];
    for (NSString *coinCode in coinCodes) {
        total += [( (WalletModel*)self.wallets[ coinCode ] ) getTotalPrice];
    }
    self.total = [NSNumber numberWithFloat:total];
}

@end
