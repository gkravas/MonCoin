//
//  CoinMarketViewController.m
//  MonitorCoin
//
//  Created by George Kravas on 4/16/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "CoinMarketViewController.h"

@interface CoinMarketViewController ()

@end

@implementation CoinMarketViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    [self initAndLoadData];
}

- (void)appDidEnterForeground:(NSNotification *)notification {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initAndLoadData];
}

- (void)initAndLoadData {
    [self showLoading];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString *currency;
    switch ( self.currentCurrency ) {
        case USD:
            currency = @"usd";
            break;
            
        case BTC:
        default:
            currency = @"btc";
            break;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://coinmarketcap.northpole.ro/api/%@/all.json" , currency];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self populateTableWithJSON:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        [self askForReload];
    }];
}

- (void)populateTableWithJSON:(NSDictionary*)JSON {
    int currentTimestamp = [[JSON valueForKey:@"timestamp"] intValue];
    if ( currentTimestamp <= self.lastTimestamp ) {
        [self hideLoading];
        return;
    }
    
    self.lastTimestamp = currentTimestamp;
    self.data = [@[] mutableCopy];
    for ( NSDictionary *market in [JSON objectForKey:@"markets"] ) {
        CoinMarketModel *model = [CoinMarketModel new];
        model.coinName = market[@"name"];
        model.value = market[@"price"];
        model.currency = market[@"currency"];
        model.profitability = market[@"change24"];
        model.rank = market[@"position"];
        [self.data addObject:model];
    }
    [self.tableView reloadData];
    [self hideLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoinMarketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoinMarketCell" forIndexPath:indexPath];
    CoinMarketModel *model = [self.data objectAtIndex:indexPath.row];
    [cell initWithModel:model];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)openMainMenu:(id)sender {
    if ( [Utilities getAppDelegate].container.menuState == MFSideMenuStateClosed ) {
        [ (MFSideMenuContainerViewController *)self.parentViewController.parentViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:nil];
    } else if ( [Utilities getAppDelegate].container.menuState == MFSideMenuStateLeftMenuOpen ) {
        [ (MFSideMenuContainerViewController *)self.parentViewController.parentViewController setMenuState:MFSideMenuStateClosed completion:nil];
    }
}

- (IBAction)reloadTable:(id)sender {
    [self initAndLoadData];
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
    [self hideLoading];
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
