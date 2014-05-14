//
//  LoginViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/13/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
{
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIView *myView;
    
}

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myView.layer.cornerRadius = 15;
    myView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Actions

- (IBAction)onLoginButtonPressed:(UIButton *)sender {
    
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
    return ([username isEqualToString:LOGIN_USERNAME] && [password isEqualToString:LOGIN_PASSWORD]);
}

#pragma mark Keyboard

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}


@end
