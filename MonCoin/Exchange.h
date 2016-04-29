//
//  Exchange.h
//  MonitorCoin
//
//  Created by George Kravas on 29/04/16.
//  Copyright © 2016 George Kravas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Exchange <NSObject>

- (IBAction)reloadTable:(id)sender;
- (IBAction)openOpenOrders:(id)sender;
- (IBAction)openTrades:(id)sender;
- (IBAction)openMainMenu:(id)sender;

@end
