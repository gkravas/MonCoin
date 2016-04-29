//
//  WalletInfoCell.m
//  MonCoin
//
//  Created by George Kravas on 3/25/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "WalletInfoCell.h"

@implementation WalletInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initWithwallet:(WalletModel*)currentWallet andPreviousStateWallet:(WalletModel*) previousWallet {
    NSString *coinCode = currentWallet.coinCode;
    
    self.data = currentWallet;
    
    self.coinNameLbl.text = [NSString stringWithFormat:@"%@ / %@", coinCode, currentWallet.exchangeCoinCode];
    self.btcPriceLbl.text = [Utilities formatFloat:[currentWallet.price floatValue]];
    float balance = [currentWallet.balance floatValue];
    float price = [currentWallet.price floatValue];
    float prevPrice = [previousWallet.price floatValue];
    
    if ( price > prevPrice ) {
        self.btcPriceLbl.textColor = [UIColor greenColor];
        self.totalValueLbl.textColor = [UIColor greenColor];
    } else if ( price < prevPrice ) {
        self.btcPriceLbl.textColor = [UIColor redColor];
        self.totalValueLbl.textColor = [UIColor redColor];
    } else {
        self.btcPriceLbl.textColor = [UIColor grayColor];
        self.totalValueLbl.textColor = [UIColor grayColor];
    }
    
    float total = balance;
    self.userBalalceLbl.text = [Utilities formatFloat:total];
    total += [currentWallet.orderBalance floatValue];
    if ( [currentWallet.orderBalance intValue] > -1 ) {
        self.userHeldForOrderBalanceLbl.text = [Utilities formatFloat:[currentWallet.orderBalance floatValue]];
    } else {
        self.userHeldForOrderBalanceLbl.hidden = YES;
    }
    
    
    total *= price;
    self.totalValueLbl.text = [Utilities formatFloat:total];
    self.TotalTitleLbl.text = [NSString stringWithFormat:@"Total %@", currentWallet.exchangeCoinCode];
    
    [Utilities setStyleForButton:self.tradeHistoryBtn];
    [Utilities setStyleForButton:self.openOrdersBtn];
    
    //[Utilities setRowWithGapStyleForView:self];
}

@end
