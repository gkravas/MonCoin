//
//  MainMenuViewController.m
//  MonCoin
//
//  Created by George Kravas on 4/4/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController {
    NSArray *exchanges;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        exchanges = @[
                      @{ @"name": @"Coin Market Cap",
                         @"controller": @"CoinMarketViewController"},
                      @{ @"name": @"Bitrex",
                         @"controller": @"BitrexMonitorViewController"},
                      @{ @"name": @"Cryptsy",
                         @"controller": @"CryptsyMonitorViewController"},
                      //@{ @"name": @"Mintpal",
                      //   @"controller": @"MintpalMonitorViewController"},
                      @{ @"name": @"Poloniex",
                         @"controller": @"PoloniexMonitorViewController"},
                      @{ @"name": @"Settings",
                         @"controller": @"SettingsTableViewController"}
                    ];
    }
    return self;
}

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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [exchanges count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *exchangeName = [exchanges[indexPath.row] valueForKey:@"name"];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:30]];
    cell.textLabel.text = exchangeName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *exchangeCtrl = [exchanges[indexPath.row] valueForKey:@"controller"];
    MFSideMenuContainerViewController *container = [Utilities getAppDelegate].container;
    UINavigationController *navigationController = [Utilities getAppNavigationController];
    [navigationController setViewControllers:@[[Utilities getControllerFromStoryBoardWithName:exchangeCtrl]]];
    [container setCenterViewController:navigationController];
    container.menuState = MFSideMenuStateClosed;
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

@end
