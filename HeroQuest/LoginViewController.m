//
//  LoginViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/13/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "LoginViewController.h"
#import "QuestListViewController.h"

@interface LoginViewController () <ParseTransactionsDelegate>
{
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UISwitch *rememberUsernameSwitch;
    IBOutlet UIView *myView;
    
    
    NSUserDefaults* userDefaults;
    ParseTransactions* parseTransactions;
}

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    myView.layer.cornerRadius = 15;
    myView.layer.masksToBounds = YES;
    
    //Remembering username
    NSString* usernameRemembered = [userDefaults objectForKey:LOGIN_VIEW_CONTROLLER_REMEMBER_USERNAME];
    if (usernameRemembered) {
        usernameTextField.text = usernameRemembered;
        rememberUsernameSwitch.on = YES;
    } else {
        rememberUsernameSwitch.on = NO;
    }
    
    parseTransactions = [ParseTransactions new];
    parseTransactions.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Actions

- (IBAction)onLoginButtonPressed:(UIButton *)sender {
    
    //If Remember username is activated we save the username on userdefaults
    if (rememberUsernameSwitch.on) {
        [userDefaults setObject:usernameTextField.text forKey:LOGIN_VIEW_CONTROLLER_REMEMBER_USERNAME];
    } else {
        [userDefaults removeObjectForKey:LOGIN_VIEW_CONTROLLER_REMEMBER_USERNAME];
    }
    [userDefaults synchronize];
    
    //verify login data
    [self authenticate];

}

- (IBAction)onFBLoginButtonPressed:(id)sender  {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [userDefaults setObject:user.objectId forKey:LOGGED_USER_ID];
            [userDefaults setObject:user[PARSE_USER_NAME] forKey:LOGGED_USER_NAME];
            [userDefaults synchronize];
            [self performSegueWithIdentifier:SEGUE_FROM_LOGIN_TO_QUEST_LIST sender:self];
            
        }
    }];
}

#pragma mark Helpful Methods

- (void)authenticate {
    [parseTransactions authenticateWithUsername:usernameTextField.text withPassword:passwordTextField.text];
}

#pragma mark ParseTransactionsDelegate

- (void)didAutenticatheResponse:(PFUser*)user
{
    if (user) {
        [userDefaults setObject:user.objectId forKey:LOGGED_USER_ID];
        [userDefaults setObject:user[PARSE_USER_NAME] forKey:LOGGED_USER_NAME];
        [userDefaults synchronize];
        [self performSegueWithIdentifier:SEGUE_FROM_LOGIN_TO_QUEST_LIST sender:self];
    } else {
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertview.loginincorrect.title", nil)
                                                     message:NSLocalizedString(@"alertview.loginincorrect.message", nil)
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"alertview.loginincorrect.button.ok", nil), nil];
        [al show];
    }
}


#pragma mark Keyboard

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[QuestListViewController class]]) {
        QuestListViewController* vc = segue.destinationViewController;
        vc.navigationItem.hidesBackButton = YES;
    }
}


@end
