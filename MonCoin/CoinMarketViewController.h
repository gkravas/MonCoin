//
//  CoinMarketViewController.h
//  MonitorCoin
//
//  Created by George Kravas on 4/16/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "CoinMarketCell.h"
#import "CoinMarketModel.h"
#import "Exchange.h"

@interface CoinMarketViewController : UITableViewController <Exchange>

@property int lastTimestamp;
@property Currency currentCurrency;
@property NSMutableArray *data;

- (IBAction)openMainMenu:(id)sender;
- (IBAction)reloadTable:(id)sender;

@end
