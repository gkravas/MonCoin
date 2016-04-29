//
//  CryptsyMonitorViewController.m
//  MonCoin
//
//  Created by George Kravas on 3/25/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "PoloniexMonitorViewController.h"

@interface PoloniexMonitorViewController ()

@end

@implementation PoloniexMonitorViewController {
    BOOL willReload;
    NSString *prefix;
    NSMutableArray *remainingMarkets;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        willReload = YES;
        prefix = @"poliex";
        remainingMarkets = [@[] mutableCopy];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Utilities addOnWakeHandlersForController:self withSelector:@selector(appDidBecomeActive:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [Utilities removeOnWakeHandlersForController:self];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    if ( self.api ) {
        [self initAndLoadData];
    }
}

- (void)appDidEnterForeground:(NSNotification *)notification {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ( willReload ) {
        [self initAndLoadData];
    } else {
        willReload = YES;
    }
}

- (void)initAndLoadData {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [defaults stringForKey:POLONIEX_API_KEY];
    NSString *apiSecret = [defaults stringForKey:POLONIEX_API_SECRET];
    apiKey = apiKey ? apiKey : @"";
    apiSecret = apiSecret ? apiSecret : @"";
    
    if ( [apiKey isEqualToString:@""] || [apiSecret isEqualToString:@""]) {
        [self showError:@"You have not enter valid API key or API secret for Poloniex"];
        return;
    }
    
    self.api = [[VGPoloniexAPI alloc] initWithApiKey:apiKey andSecret:apiSecret];
    [self getExchangeData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.markets count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *marketKeys = [self.markets allKeys];
    return [ ( (MarketModel*)self.markets[ marketKeys[ section ] ] ).wallets count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *marketKey = [ self.markets allKeys ][ section ];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, SECTION_HEIGHT)];
    header.backgroundColor = [UIColor blackColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, SECTION_HEIGHT)];
    [header addSubview:label];
    
    float total = [ ( (MarketModel*)self.markets[ marketKey ] ).total floatValue ];
    float prevTotal = [ ( (MarketModel*)[ self getPreviousMarkets ][ marketKey ] ).total floatValue ];
    
    if ( total > prevTotal ) {
        label.textColor = [UIColor greenColor];
    } else if ( total < prevTotal ) {
        label.textColor = [UIColor redColor];
    } else {
        label.textColor = [UIColor whiteColor];
    }
    
    label.text = [ NSString stringWithFormat:@"%@: %@" , marketKey, [Utilities formatFloat:total ] ];
    
    return header;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WalletInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletInfoCell" forIndexPath:indexPath];
    
    NSString *marketCode = [ self.markets allKeys][indexPath.section ];
    NSString *coinCode = [ ( (MarketModel*)self.markets[ marketCode ] ).wallets allKeys ][ indexPath.row ];
    
    WalletModel *currentWallet = ( (MarketModel*)self.markets[ marketCode ] ).wallets[coinCode];
    WalletModel *previousWallet = ( (MarketModel*)[self getPreviousMarkets][ marketCode ] ).wallets[coinCode];
    [cell initWithwallet:currentWallet andPreviousStateWallet:previousWallet];
    
    return cell;
}

#pragma mark - Exchange API

-(void)getExchangeData {
    if ( [self.markets count] ) {
        [self saveMarkets];
    }
    self.markets = [@{} mutableCopy];
    self.balances = [@{} mutableCopy];
    self.balancesHeldForOrders = [@{} mutableCopy];
    
    self.openOrders = [@{} mutableCopy];
    [self getExchangeMarkets];
}

- (void)getExchangeMarkets {
    [self showLoading];
    
    [self.api apiQuery:@"returnTicker" isPublic:YES params:nil success:^(id response) {
        // success
        NSDictionary *JSON = (NSDictionary *)response;
        if ( [JSON count] == 0 ) {
            [self handleError:JSON];
            return;
        }
        NSLog(@"%@", JSON);
        for ( NSString *marketKey in [JSON allKeys] ) {
            [remainingMarkets addObject:marketKey];
            NSArray *marketInfo = [marketKey componentsSeparatedByString:@"_"];
            NSString *marketCoinCode = marketInfo[ 0 ];
            if ( !self.markets[ marketCoinCode ] ) {
                self.markets[ marketCoinCode ] = [MarketModel new];
            }
            NSString *coinCode = marketInfo[ 1 ];
            WalletModel *model = [WalletModel new];
            model.coinCode = coinCode;
            model.coinName = coinCode;
            model.exchangeCoinCode = marketCoinCode;
            model.exchangeCoinName = marketCoinCode;
            model.price = [ NSNumber numberWithFloat:[ JSON[ marketKey ][@"last"] floatValue ] ];
            //model.marketId = [ NSNumber numberWithInt:[ marketData[ @"marketid" ] intValue ] ];
            
            ( (MarketModel*)self.markets[ marketCoinCode ] ).wallets[ coinCode ] = model;
        }
        [self getOpenOrdersAPI];
    } error:^(NSError *error) {
        // error
        [self hideLoading];
        [self askForReload];
    }];
}

- (void)getOpenOrdersAPI {
    NSArray *cRemainingMarkets = [remainingMarkets copy];
    for (NSString *marketKey in cRemainingMarkets) {
        [self.api apiQuery:@"returnOpenOrders" isPublic:NO params:@{@"currencyPair":marketKey} success:^(id response) {
            NSDictionary *JSON = (NSDictionary *)response;
            if ( [JSON count] == 0 || ![[JSON objectForKey:@"error"] isEqual:nil] ) {
                [remainingMarkets removeObject:marketKey];
                if ( [remainingMarkets count] == 0 ) {
                    [self getWallets];
                }
                return;
            }
            NSArray *marketInfo = [marketKey componentsSeparatedByString:@"_"];
            NSString *marketCoinCode = marketInfo[ 0 ];
            NSString *coinCode = marketInfo[ 1 ];
            
            WalletModel *wallet = ( (WalletModel*)( (MarketModel*)self.markets[ marketCoinCode ] ).wallets[ coinCode ]);
            float balance = 0;
            for (NSDictionary *openOrder in JSON) {
                if ( [openOrder[@"type"] isEqualToString:@"sell"] ) {
                    balance += [openOrder[ @"amount" ] floatValue];
                }
            }
            wallet.orderBalance = [NSNumber numberWithFloat:balance];
            
            [remainingMarkets removeObject:marketKey];
            if ( [remainingMarkets count] == 0 ) {
                [self getWallets];
            }
        } error:^(NSError *error) {
            // error
            [self hideLoading];
            [self askForReload];
        }];
    }
    
}

- (void)getWallets {
    [self.api apiQuery:@"returnBalances" isPublic:NO params:nil success:^(id response) {
        // success
        NSDictionary *JSON = (NSDictionary *)response;
        if ( [JSON count] == 0 ) {
            [self handleError:JSON];
            return;
        }

        NSMutableArray *coinsToShow = [@[] mutableCopy];
        NSArray *allMarketCoinCodes = [self.markets allKeys];
        for (NSString *marketCoinCodes in allMarketCoinCodes) {
            for (NSString *coinCode in [JSON allKeys]) {
                float balance = [JSON[ coinCode ] floatValue];
                if ( balance > 0 ) {
                    WalletModel *wallet = ( (WalletModel*) ( (MarketModel*)self.markets[ marketCoinCodes ] ).wallets[ coinCode ] );
                    wallet.balance = [NSNumber numberWithFloat:balance];
                    wallet.orderBalance = [NSNumber numberWithInt:-1];
                    [coinsToShow addObject:coinCode];
                }
            }
        }
        //strip duplicate
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:coinsToShow];
        coinsToShow = [orderedSet.array mutableCopy];
        //NSMutableArray *arr = [@[] mutableCopy];
        NSMutableDictionary *filteredMarkets = [@{} mutableCopy];
        for (NSString* marketCoinCode in [self.markets allKeys]) {
            filteredMarkets[marketCoinCode] = [MarketModel new];
            for (NSString *coinCode in coinsToShow) {
                if ( ( (MarketModel*)self.markets[ marketCoinCode ] ).wallets[ coinCode ] == nil) {
                    continue;
                }
                ( (MarketModel*)filteredMarkets[ marketCoinCode ] ).wallets[ coinCode ] = ( (MarketModel*)self.markets[ marketCoinCode ] ).wallets[ coinCode ];
            }
            
        }
        self.markets = [Utilities stripEmptyMarkets:filteredMarkets];
        [self updateTotal];
        [self.tableView reloadData];
        [self hideLoading];
    } error:^(NSError *error) {
        // error
        [self hideLoading];
        [self askForReload];
    }];
}

- (void)getExchangeUserOpenOrdersForMarketId:(NSString*)marketId {
    [self showLoading];
    [self.api apiQuery:@"returnOpenOrders" isPublic:NO params:@{@"currencyPair":marketId} success:^(id response) {
        // success
        NSDictionary *JSON = (NSDictionary *)response;
        if ( [JSON count] == 0 ) {
            [self hideLoading];
            [self showError:@"You have 0 open orders"];
            return;
        }
        NSMutableArray *arr = [@[] mutableCopy];
        for (NSDictionary *openOrder in JSON) {
            OpenOrderModel *data = [OpenOrderModel new];
            data.type = ([openOrder[@"type"] isEqualToString:@"sell"]) ? Sell : Buy;
            data.amount = openOrder[@"amount"];
            data.profit = openOrder[@"total"];
            data.price = openOrder[@"rate"];
            data.date = @"n/a";
            [arr addObject:data];
        }
        [self openOpenOrderViewControllerWithData:arr];
        [self hideLoading];
    } error:^(NSError *error) {
        // error
        [self hideLoading];
        [self showError:@"Comunication error"];
    }];
}

- (void)getExchangeUserTradesForMarketId:(NSString*)marketId {
    [self showLoading];
    [self.api apiQuery:@"returnTradeHistory" isPublic:NO params:@{@"currencyPair":marketId} success:^(id response) {
        // success
        NSDictionary *JSON = (NSDictionary *)response;
        if ( [JSON count] == 0 ) {
            [self hideLoading];
            [self showError:@"You have no trade history"];
            return;
        }
        NSMutableArray *arr = [@[] mutableCopy];
        for (NSDictionary *openOrder in JSON) {
            MarketTradeModel *data = [MarketTradeModel new];
            data.type = ([openOrder[@"type"] isEqualToString:@"sell"]) ? Sell : Buy;
            data.amount = openOrder[@"amount"];
            data.total = [NSNumber numberWithFloat:[openOrder[@"total"] floatValue]];
            data.price = openOrder[@"rate"];
            data.date = openOrder[@"date"];
            [arr addObject:data];
        }
        [self openTradesViewControllerWithData:arr];
        [self hideLoading];
    } error:^(NSError *error) {
        // error
        [self hideLoading];
        [self showError:@"Comunication error"];
    }];
}


- (IBAction)reloadTable:(id)sender {
    [self initAndLoadData];
}

- (IBAction)openOpenOrders:(id)sender {
    willReload = NO;
    WalletModel *data = ( (WalletModel*)((WalletInfoCell*)[[[((UIButton*)sender) superview] superview] superview]).data );
    NSString *marketId = [NSString stringWithFormat:@"%@_%@", data.exchangeCoinCode, data.coinCode];
    [self getExchangeUserOpenOrdersForMarketId:marketId];
}

- (IBAction)openTrades:(id)sender {
    willReload = NO;
    WalletModel *data = ( (WalletModel*)((WalletInfoCell*)[[[((UIButton*)sender) superview] superview] superview]).data );
    NSString *marketId = [NSString stringWithFormat:@"%@_%@", data.exchangeCoinCode, data.coinCode];
    [self getExchangeUserTradesForMarketId:marketId];
}

- (IBAction)openMainMenu:(id)sender {
    if ( [Utilities getAppDelegate].container.menuState == MFSideMenuStateClosed ) {
        [ (MFSideMenuContainerViewController *)self.parentViewController.parentViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:nil];
    } else if ( [Utilities getAppDelegate].container.menuState == MFSideMenuStateLeftMenuOpen ) {
        [ (MFSideMenuContainerViewController *)self.parentViewController.parentViewController setMenuState:MFSideMenuStateClosed completion:nil];
    }
}

- (void)openOpenOrderViewControllerWithData:(NSArray*)data {
    
    OpenOrdersViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenOrdersViewController"];
    vc.data = data;
    vc.title = @"Open Orders";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openTradesViewControllerWithData:(NSArray*)data {
    TradesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TradesViewController"];
    vc.data = data;
    vc.title = @"Trade history";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) updateTotal {
    NSArray *allMarketCoinCodes = [self.markets allKeys];
    
    for (NSString *marketCoinCodes in allMarketCoinCodes) {
        [( (MarketModel*)self.markets[ marketCoinCodes ] ) calculateTotal];
    }
}

- (void) saveMarkets {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.markets];
    [defaults setValue:data forKey:[NSString stringWithFormat:@"%@_%@", prefix, PREV_MARKETS_DATA]];
    [defaults synchronize];
}

- (NSDictionary *) getPreviousMarkets {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:[NSString stringWithFormat:@"%@_%@", prefix, PREV_MARKETS_DATA]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void) showLoading {
    [self hideLoading];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tableView.scrollEnabled = false;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.labelText = @"Loading...";
}

- (void) hideLoading {
    self.tableView.scrollEnabled = YES;
    [MBProgressHUD hideLatHUDAnimated:YES];
}

- (void) askForReload {
    [Utilities showUIAlertViewWithTitle:@"Attention"
                                message:@"Comunication error, reload data?"
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@[@"Yes"]
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
                                       [self initAndLoadData];
                                   }
                               }];
}

- (void) showError:(NSString*)error {
    [Utilities showUIAlertViewWithTitle:@"Attention"
                                message:error
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil
                               tapBlock:nil];
}

- (void) handleError:(NSDictionary*)JSON {
    NSLog(@"%@", JSON);
    [self hideLoading];
    [self showError:JSON[@"error"]];
}

@end
