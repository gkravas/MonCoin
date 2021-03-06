//
//  CryptsyMonitorViewController.h
//  MonCoin
//
//  Created by George Kravas on 3/25/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACDCryptsyAPI.h"
#import "WalletInfoCell.h"
#import "MBProgressHUD.h"
#import "OpenOrderModel.h"
#import "MarketTradeModel.h"
#import "WalletInfoCell.h"
#import "OpenOrdersViewController.h"
#import "TradesViewController.h"
#import "WalletModel.h"
#import "MarketModel.h"
#import "Exchange.h"

@interface CryptsyMonitorViewController : UITableViewController <Exchange>

@property (nonatomic) ACDCryptsyAPI *api;

@property (nonatomic) NSArray *data;

@property (nonatomic) NSMutableDictionary *markets;
@property (nonatomic) NSMutableDictionary *balances;
@property (nonatomic) NSMutableDictionary *balancesHeldForOrders;
@property (nonatomic) NSMutableDictionary *openOrders;
@property (strong, nonatomic) IBOutlet UILabel *totalLbl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)reloadTable:(id)sender;
- (IBAction)openOpenOrders:(id)sender;
- (IBAction)openTrades:(id)sender;
- (IBAction)openMainMenu:(id)sender;

@end
