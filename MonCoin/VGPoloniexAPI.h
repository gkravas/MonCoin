//
//  VGPoloniexAPI.h
//  MonCoin
//
//  Created by George Kravas on 4/7/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PoloniexAPISuccessBlock)(id response);
typedef void (^PoloniexAPIErrorBlock)(NSError *error);


@interface VGPoloniexAPI : NSObject

- (id)initWithApiKey:(NSString *)apiKey andSecret:(NSString *)secret;
- (void)apiQuery:(NSString *)method isPublic:(BOOL)isPublic params:(NSDictionary *)params success:(CryptsyAPISuccessBlock)success error:(CryptsyAPIErrorBlock)error;
@end