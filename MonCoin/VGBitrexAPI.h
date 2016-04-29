//
//  CryptsyModel.h
//  iCryptsy
//
//  Created by Blake Schwendiman on 12/24/13.
//  Copyright 2013 Viking Rick's, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BitrexAPISuccessBlock)(id response);
typedef void (^BitrexAPIErrorBlock)(NSError *error);


@interface VGBitrexAPI : NSObject

- (id)initWithApiKey:(NSString *)apiKey;
- (void)apiQuery:(NSString *)method params:(NSDictionary *)params success:(BitrexAPISuccessBlock)success error:(BitrexAPIErrorBlock)error;

@end
