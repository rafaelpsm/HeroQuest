//
//  SignupViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/21/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController (){
    
    IBOutlet UIView *myView;
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *nameTextField;
    IBOutlet UISegmentedControl *alignmentSegmentControl;
    
    NSUserDefaults* userDefaults;
}

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    myView.layer.cornerRadius = 15;
    myView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onSignupButtonPressed:(UIButton *)sender {
    NSString* field;
    
    if ([usernameTextField.text isEqualToString:@""]) {
        field = NSLocalizedString(@"alertview.missingdata.username", nil);
    } else if ([passwordTextField.text isEqualToString:@""]) {
        field = NSLocalizedString(@"alertview.missingdata.password", nil);
    } if ([nameTextField.text isEqualToString:@""]) {
        field = NSLocalizedString(@"alertview.missingdata.name", nil);
    }
    
    if (field) {
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertview.missingdata.title", nil)
                                                     message:NSLocalizedString(@"alertview.missingdata.message", nil)
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"alertview.missingdata.button.ok", nil), nil];
        [al show];
    } else {
        //parse
    }
}

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
