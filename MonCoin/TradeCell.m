//
//  TradeViewCell.m
//  MonCoin
//
//  Created by George Kravas on 3/30/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "TradeCell.h"

@implementation TradeCell

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

- (void) setModelData:(MarketTradeModel*)data {
    self.data = data;
    
    if ( data.type == Sell ) {
        self.typeLbl.textColor = [UIColor purpleColor];
        self.typeLbl.text = @"Sell";
    } else {
        self.typeLbl.textColor = [UIColor orangeColor];
        self.typeLbl.text = @"Buy";
    }
    
    self.dateLbl.text = data.date;
    self.amountLbl.text = [Utilities formatFloat:[data.amount floatValue]];
    self.profitLbl.text = [Utilities formatFloat:[data.total floatValue]];
    self.priceLbl.text = [Utilities formatFloat:[data.price floatValue]];
}

@end
