//
//  CoinMarketCell.h
//  MonitorCoin
//
//  Created by George Kravas on 4/17/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinMarketModel.h"

@interface CoinMarketCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *coinNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *valueLbl;
@property (strong, nonatomic) IBOutlet UILabel *profitabilityLbl;
@property (strong, nonatomic) IBOutlet UILabel *rankLbl;

@property CoinMarketModel *data;

- (void)initWithModel:(CoinMarketModel*)model;

@end
