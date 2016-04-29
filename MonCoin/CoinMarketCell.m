//
//  CoinMarketCell.m
//  MonitorCoin
//
//  Created by George Kravas on 4/17/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "CoinMarketCell.h"

@implementation CoinMarketCell

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

- (void)initWithModel:(CoinMarketModel*)model {
    self.data = model;
    self.coinNameLbl.text = self.data.coinName;
    self.valueLbl.text = [NSString stringWithFormat:@"%@ %@", self.data.value, [self.data.currency uppercaseString]];
    self.profitabilityLbl.text = self.data.profitability;
    self.rankLbl.text = self.data.rank;
    
    NSString *symbol = [self.data.profitability substringToIndex:1];
    UIColor *color;
    if ( [symbol isEqualToString:@"+"] ) {
        color = [UIColor greenColor];
    } else if ( [symbol isEqualToString:@"-"] ) {
        color = [UIColor redColor];
    } else {
        color = [UIColor grayColor];
    }
    
    self.valueLbl.textColor = color;
    self.profitabilityLbl.textColor = color;
}

@end
