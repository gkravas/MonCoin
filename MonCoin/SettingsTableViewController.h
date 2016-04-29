//
//  SettingsTableViewController.h
//  MonCoin
//
//  Created by George Kravas on 3/25/14.
//  Copyright (c) 2014 George Kravas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *apiKeyTxt;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UILabel *appIdLbl;
@property (strong, nonatomic) IBOutlet UITextField *poloniexApiKey;
@property (strong, nonatomic) IBOutlet UITextField *poloniexApiSecret;
@property (strong, nonatomic) IBOutlet UITextField *bitrexApiKey;

- (IBAction)saveData:(id)sender;
- (IBAction)openMainMenu:(id)sender;

@end
