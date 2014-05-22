//
//  LoginViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/13/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "LoginViewController.h"
#import "QuestListViewController.h"

@interface LoginViewController ()
{
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UISwitch *rememberUsernameSwitch;
    IBOutlet UIView *myView;
    
    
    NSUserDefaults* userDefaults;
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
    if ([self authenticate]) {
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

#pragma mark Helpful Methods

- (BOOL)authenticate {
    NSString* username = usernameTextField.text;
    NSString* password = passwordTextField.text;
    
    //verify login data
    //return ([username isEqualToString:LOGIN_USERNAME] && [password isEqualToString:LOGIN_PASSWORD]);
    return true;
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
