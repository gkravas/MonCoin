//
//  WalletInfoCell.h
//  MonCoin
//
//  Created by George Kravas on 3/25/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WalletModel.h"
@interface WalletInfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *coinNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *btcPriceLbl;
@property (strong, nonatomic) IBOutlet UILabel *userBalalceLbl;
@property (strong, nonatomic) IBOutlet UILabel *userHeldForOrderBalanceLbl;
@property (strong, nonatomic) IBOutlet UILabel *totalValueLbl;
@property (strong, nonatomic) IBOutlet UILabel *TotalTitleLbl;
@property (strong, nonatomic) IBOutlet UIButton *tradeHistoryBtn;
@property (strong, nonatomic) IBOutlet UIButton *openOrdersBtn;
@property (nonatomic) WalletModel *data;

- (void) initWithwallet:(WalletModel*)currentWallet andPreviousStateWallet:(WalletModel*) previousWallet;

@end
