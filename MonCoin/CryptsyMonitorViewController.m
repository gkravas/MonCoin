//
//  CryptsyMonitorViewController.m
//  MonCoin
//
//  Created by George Kravas on 3/25/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "CryptsyMonitorViewController.h"

@interface CryptsyMonitorViewController ()

@end

@implementation CryptsyMonitorViewController {
    BOOL willReload;
    NSString *prefix;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        willReload = YES;
        prefix = @"cryptsy";
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
    NSString *apiKey = [defaults stringForKey:CRYPTSY_APP_KEY];
    apiKey = apiKey ? apiKey : @"";
    if ( [apiKey isEqualToString:@""] ) {
        [self showError:@"You have not enter a valid Application Key for Cryptsy"];
        return;
    }
    self.api = [[ACDCryptsyAPI alloc] initWithApiKey:apiKey andSecret:CRYPTSY_APPLICATION_KEY];
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
    
    [self.api apiQuery:@"getmarkets" params:nil success:^(id response) {
        // success
        //NSLog(@"%@", response);
        NSDictionary *JSON = (NSDictionary *)response;
        if ( JSON[@"success"] == 0 ) {
            [self handleError:JSON];
            return;
        }
        NSArray *marketsData = (NSArray *)JSON[@"return"];
        for ( NSDictionary *marketData in marketsData ) {
            NSString *marketCoinCode = marketData[@"secondary_currency_code"];
            if ( !self.markets[ marketCoinCode ] ) {
                self.markets[ marketCoinCode ] = [MarketModel new];
            }
            NSString *coinCode = marketData[@"primary_currency_code"];
            WalletModel *model = [WalletModel new];
            model.coinCode = coinCode;
            model.coinName = marketData[@"primary_currency_name"];
            model.exchangeCoinCode = marketData[@"secondary_currency_code"];;
            model.exchangeCoinName = marketData[@"secondary_currency_name"];
            model.price = [NSNumber numberWithFloat:[marketData[@"last_trade"] floatValue]];
            model.marketId = [NSNumber numberWithInt:[marketData[@"marketid"] intValue]];
            
            ( (MarketModel*)self.markets[ marketCoinCode ] ).wallets[ coinCode ] = model;
        }
        [self getWallets];
    } error:^(NSError *error) {
        // error
        [self hideLoading];
        [self askForReload];
    }];
}

- (void)getWallets {
    [self.api apiQuery:@"getinfo" params:nil success:^(id response) {
        // success
        //NSLog(@"%@", response);
        NSDictionary *JSON = (NSDictionary *)response;
        if ( JSON[@"success"] == 0 ) {
            NSLog(@"%@", JSON);
            [self hideLoading];
            return;
        }
        NSDictionary *walletsData = (NSDictionary *)JSON[@"return"];
        NSDictionary *balancesAvailable = (NSDictionary *)walletsData[@"balances_available"];
        self.balancesHeldForOrders = [(NSDictionary *)walletsData[@"balances_hold"] mutableCopy];
        NSMutableArray *coinsToShow = [@[] mutableCopy];
        NSArray *allMarketCoinCodes = [self.markets allKeys];
        
        for (NSString *marketCoinCodes in allMarketCoinCodes) {
            
            for (NSString *coinCode in balancesAvailable) {
                float balance = [balancesAvailable[ coinCode ] floatValue];
                if ( balance > 0 ) {
                    ( (WalletModel*) ( (MarketModel*)self.markets[ marketCoinCodes ] ).wallets[ coinCode ] ).balance = [NSNumber numberWithFloat:balance];
                    [coinsToShow addObject:coinCode];
                }
            }
            
            for (NSString *coinCode in self.balancesHeldForOrders) {
                float orderBalance = [self.balancesHeldForOrders[ coinCode ] floatValue];
                ( (WalletModel*) ( (MarketModel*)self.markets[ marketCoinCodes ] ).wallets[ coinCode ] ).orderBalance = [NSNumber numberWithFloat:orderBalance];
                [coinsToShow addObject:coinCode];
            }
        }
        //NSMutableDictionary *filteredMarkets = [@{} mutableCopy];
        //NSMutableArray *coins = [[self.balances allKeys] mutableCopy];
        //[coins addObjectsFromArray:[self.balancesHeldForOrders allKeys]];
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

- (void)getExchangeUserOpenOrdersForMarketId:(NSNumber*)marketId {
    [self showLoading];
    
    [self.api apiQuery:@"myorders" params:@{@"marketid":marketId} success:^(id response) {
        // success
        NSDictionary *JSON = (NSDictionary *)response;
        NSLog(@"%@", JSON);
        if ( JSON[@"success"] == 0 ) {
            NSLog(@"%@", JSON);
            [self hideLoading];
            return;
        }
        NSMutableArray *arr = [@[] mutableCopy];
        for (NSDictionary *openOrder in JSON[@"return"]) {
            OpenOrderModel *data = [OpenOrderModel new];
            data.type = ([openOrder[@"ordertype"] isEqualToString:@"Sell"]) ? Sell : Buy;
            data.amount = openOrder[@"orig_quantity"];
            data.profit = openOrder[@"total"];
            data.price = openOrder[@"price"];
            data.date = openOrder[@"created"];
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

- (void)getExchangeUserTradesForMarketId:(NSNumber*)marketId {
    [self showLoading];
    
    [self.api apiQuery:@"mytrades" params:@{@"marketid":marketId} success:^(id response) {
        // success
        NSDictionary *JSON = (NSDictionary *)response;
        NSLog(@"%@", JSON);
        if ( JSON[@"success"] == 0 ) {
            NSLog(@"%@", JSON);
            [self hideLoading];
            return;
        }
        NSMutableArray *arr = [@[] mutableCopy];
        for (NSDictionary *openOrder in JSON[@"return"]) {
            MarketTradeModel *data = [MarketTradeModel new];
            data.type = ([openOrder[@"tradetype"] isEqualToString:@"Sell"]) ? Sell : Buy;
            data.amount = openOrder[@"quantity"];
            data.total = [NSNumber numberWithFloat:[openOrder[@"total"] floatValue] - [openOrder[@"fee"] floatValue]];
            data.price = openOrder[@"tradeprice"];
            data.date = openOrder[@"datetime"];
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
    NSNumber *marketId = ((WalletInfoCell*)[[[((UIButton*)sender) superview] superview] superview]).data.marketId;
    [self getExchangeUserOpenOrdersForMarketId:marketId];
}

- (IBAction)openTrades:(id)sender {
    willReload = NO;
    NSNumber *marketId = ((WalletInfoCell*)[[[((UIButton*)sender) superview] superview] superview]).data.marketId;
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
