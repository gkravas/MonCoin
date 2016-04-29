//
//  SettingsTableViewController.m
//  MonCoin
//
//  Created by George Kravas on 3/25/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

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
    self.appIdLbl.text = CRYPTSY_APPLICATION_KEY;
    UILabel *apperance = [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];
    [apperance setFont:[UIFont systemFontOfSize:18]];
    [apperance setTextColor:[UIColor whiteColor]];
    UIView *apperanceForView = [UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];
    [apperanceForView setBackgroundColor:[UIColor blackColor]];
    
    self.tableView.sectionHeaderHeight = SECTION_HEIGHT;
    [Utilities setStyleForButton:self.saveBtn];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    self.apiKeyTxt.text = [defaults stringForKey:CRYPTSY_APP_KEY];
    self.poloniexApiKey.text = [defaults stringForKey:POLONIEX_API_KEY];
    self.poloniexApiSecret.text = [defaults stringForKey:POLONIEX_API_SECRET];
    self.bitrexApiKey.text = [defaults stringForKey:BITREX_API_KEY];
}

- (IBAction)saveData:(id)sender {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.apiKeyTxt.text forKey:CRYPTSY_APP_KEY];
    [defaults setValue:self.poloniexApiKey.text forKey:POLONIEX_API_KEY];
    [defaults setValue:self.poloniexApiSecret.text forKey:POLONIEX_API_SECRET];
    [defaults setValue:self.bitrexApiKey.text forKey:BITREX_API_KEY];
    [defaults synchronize];
    
    [Utilities showUIAlertViewWithTitle:@"Success"
                                message:@"Your settings have been saved"
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil
                               tapBlock:nil];
}

- (IBAction)openMainMenu:(id)sender {
    if ( [Utilities getAppDelegate].container.menuState == MFSideMenuStateClosed ) {
        [ (MFSideMenuContainerViewController *)self.parentViewController.parentViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:nil];
    } else if ( [Utilities getAppDelegate].container.menuState == MFSideMenuStateLeftMenuOpen ) {
        [ (MFSideMenuContainerViewController *)self.parentViewController.parentViewController setMenuState:MFSideMenuStateClosed completion:nil];
    }
}
@end
