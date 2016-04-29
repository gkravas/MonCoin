//
//  VGPoloniexAPI.m
//  MonCoin
//
//  Created by George Kravas on 4/7/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "VGPoloniexAPI.h"
#import "AFNetworking.h"
#include <CommonCrypto/CommonDigest.h>
#include "AFURLRequestSerialization.h"
#include <CommonCrypto/CommonHMAC.h>

@implementation VGPoloniexAPI {
    NSString *_apiKey;
    NSString *_secretKey;
}

- (NSString *)createSHA512:(NSString *)string withKey:(NSString *)key {
    
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    
    for (int i = 0; i < HMACData.length; ++i) {
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    }
    
    return HMAC;
    
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

- (id)initWithApiKey:(NSString *)apiKey andSecret:(NSString *)secret {
    
    self = [super init];
    if (self) {
        _apiKey = apiKey;
        _secretKey = secret;
    }
    return self;
    
}

- (void)apiQuery:(NSString *)method isPublic:(BOOL)isPublic params:(NSDictionary *)params success:(CryptsyAPISuccessBlock)success error:(CryptsyAPIErrorBlock)error {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [newParams setObject:[NSNumber numberWithInt:[NSDate timeIntervalSinceReferenceDate]] forKey:@"nonce"];
    [newParams setObject:method forKey:@"command"];
    NSDictionary *sortedParams = [self sortedByKeys:newParams];
    
    if ( isPublic ) {
        [manager GET:@"https://poloniex.com/public" parameters:sortedParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSError *error;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            success(jsonDict);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            
            error(err);
            
        }];
    } else {
        NSString *signature;
        NSError *internalError;
        
        NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:@"https://poloniex.com/tradingApi" parameters:sortedParams error:&internalError];
        NSString *query = [[request.URL absoluteString] stringByReplacingOccurrencesOfString:@"https://poloniex.com/tradingApi?" withString:@""];
        signature = [self createSHA512:query withKey:_secretKey];
        
        [manager.requestSerializer setValue:signature forHTTPHeaderField:@"Sign"];
        [manager.requestSerializer setValue:_apiKey forHTTPHeaderField:@"Key"];
        
        [manager POST:@"https://poloniex.com/tradingApi" parameters:sortedParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSError *error;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            success(jsonDict);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            
            error(err);
            
        }];
    }
    
    
}

@end
