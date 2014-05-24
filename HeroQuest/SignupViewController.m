//
//  SignupViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/21/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "SignupViewController.h"
#import "QuestListViewController.h"

@interface SignupViewController () <ParseTransactionsDelegate>
{
    
    IBOutlet UIView *myView;
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *nameTextField;
    IBOutlet UISegmentedControl *alignmentSegmentControl;
    
    NSUserDefaults* userDefaults;
    ParseTransactions* parseTransactions;
}

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    myView.layer.cornerRadius = 15;
    myView.layer.masksToBounds = YES;
    
    parseTransactions = [ParseTransactions new];
    parseTransactions.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onSignupButtonPressed:(UIButton *)sender {
    NSString* field;
    
    if ([usernameTextField.text isEqualToString:@""]) {
        field = NSLocalizedString(@"field.username", nil);
    } else if ([passwordTextField.text isEqualToString:@""]) {
        field = NSLocalizedString(@"field.password", nil);
    } else if ([nameTextField.text isEqualToString:@""]) {
        field = NSLocalizedString(@"field.name", nil);
    }
    
    if (field) {
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertview.loginincorrect.title", nil)
                                                     message:[NSString stringWithFormat: NSLocalizedString(@"alertview.mandatory.message", nil), field]
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"alertview.loginincorrect.button.ok", nil), nil];
        [al show];
    } else {
        [parseTransactions verifyExistenceUsername:usernameTextField.text];
    }
}


- (void)saveUserParse {
    PFUser *user = [PFUser user];
    user.username = usernameTextField.text;
    user.password = passwordTextField.text;
    user[PARSE_USER_NAME]      = nameTextField.text;
    user[PARSE_USER_ALIGNMENT] = [NSNumber numberWithLong:alignmentSegmentControl.selectedSegmentIndex];
    
    [parseTransactions signupUser:user];
}

#pragma mark ParseTransactionsDelegate

- (void)didVerifyExistenceUsername:(BOOL)usernameExists
{
    if (usernameExists) {
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertview.loginincorrect.title", nil)
                                                     message:NSLocalizedString(@"alertview.username.existent.message", nil)
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"alertview.loginincorrect.button.ok", nil), nil];
        [al show];
    } else {
        [self saveUserParse];
    }
}

- (void)didSignupUser:(BOOL)succeed
{
    if (succeed) {
        [parseTransactions authenticateWithUsername:usernameTextField.text withPassword:passwordTextField.text];
    } else {
        NSLog(@"Error when salving in Parse");
    }
}

- (void)didAutenticatheResponse:(PFUser*)user
{
    if (user) {
        [userDefaults setObject:user.objectId forKey:LOGGED_USER_ID];
        [userDefaults setObject:user[PARSE_USER_NAME] forKey:LOGGED_USER_NAME];
        [userDefaults synchronize];
        [self performSegueWithIdentifier:SEGUE_FROM_SIGNUP_TO_QUEST_LIST sender:self];
    } else {
        NSLog(@"Could not authenticate");
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
