//
//  TradeViewCell.h
//  MonCoin
//
//  Created by George Kravas on 3/30/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarketTradeModel.h"

@interface TradeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *typeLbl;
@property (strong, nonatomic) IBOutlet UILabel *amountLbl;
@property (strong, nonatomic) IBOutlet UILabel *profitLbl;
@property (strong, nonatomic) IBOutlet UILabel *priceLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
@property (nonatomic) MarketTradeModel *data;

- (void) setModelData:(MarketTradeModel*)data;

@end
