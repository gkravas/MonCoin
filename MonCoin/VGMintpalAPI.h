//
//  VGMintpalAPI.h
//  MonCoin
//
//  Created by George Kravas on 4/7/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MintpalAPISuccessBlock)(id response);
typedef void (^MintpalAPIErrorBlock)(NSError *error);


@interface VGMintpalAPI : NSObject

- (id)initWithApiKey:(NSString *)apiKey andSecret:(NSString *)secret;
- (void)apiQuery:(NSString *)method params:(NSDictionary *)params success:(MintpalAPISuccessBlock)success error:(MintpalAPIErrorBlock)error;

@end