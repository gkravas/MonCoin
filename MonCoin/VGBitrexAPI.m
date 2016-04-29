//
//  VGPoloniexAPI.m
//  MonCoin
//
//  Created by George Kravas on 4/7/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "VGBitrexAPI.h"
#import "AFNetworking.h"
#include <CommonCrypto/CommonDigest.h>
#include "AFURLRequestSerialization.h"
#include <CommonCrypto/CommonHMAC.h>

@implementation VGBitrexAPI {
    NSString *_apiKey;
}

- (NSDictionary *)sortedByKeys:(NSDictionary *)dict {
    
    NSArray *myKeys = [dict allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableDictionary *sortedDict = [[NSMutableDictionary alloc] init];
    
    for(id key in sortedKeys) {
        id object = [dict objectForKey:key];
        [sortedDict setObject:object forKey:key];
    }
    
    return sortedDict;
    
}

- (id)initWithApiKey:(NSString *)apiKey {
    
    self = [super init];
    if (self) {
        _apiKey = apiKey;
    }
    return self;
    
}

- (void)apiQuery:(NSString *)method params:(NSDictionary *)params success:(BitrexAPISuccessBlock)success error:(BitrexAPIErrorBlock)error {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [newParams setObject:_apiKey forKey:@"apikey"];
    NSDictionary *sortedParams = [self sortedByKeys:newParams];
    

    [manager GET:[NSString stringWithFormat:@"https://bittrex.com/api/v1/%@", method] parameters:sortedParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        
        error(err);
        
    }];
    
    
}

@end
