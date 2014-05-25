//
//  LoginViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/13/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "LoginViewController.h"
#import "QuestListViewController.h"

@interface LoginViewController () <ParseTransactionsDelegate, NSURLConnectionDelegate>
{
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UISwitch *rememberUsernameSwitch;
    IBOutlet UIView *myView;
    IBOutlet UIButton *facebookLoginButton;
    
    
    NSUserDefaults* userDefaults;
    ParseTransactions* parseTransactions;
    NSMutableData* imageData;
    PFUser* loggedUser;
}

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    myView.layer.cornerRadius = 15;
    myView.layer.masksToBounds = YES;
    facebookLoginButton.layer.cornerRadius = 5;
    facebookLoginButton.layer.masksToBounds = YES;
    
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
    NSArray *permissionsArray = @[ @"user_about_me", @"user_birthday"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils initializeFacebook];
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
            
            //Get information from user's profile
            FBRequest *request = [FBRequest requestForMe];
            
            // Send request to Facebook
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    NSString *facebookID = userData[@"id"];
                    NSString *name = userData[@"name"];
                    
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                          timeoutInterval:2.0f];
                    // Run network request asynchronously
                    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        
                        PFFile* file = [PFFile fileWithData:data];
                        [file save];
                        [user setObject:file forKey:PARSE_USER_CUSTOM_USER_IMAGE];
                        
                        [user saveEventually];
                    }];
                    
                    
                    user[PARSE_USER_NAME] = name;
                    user[PARSE_USER_IMAGE_URL] = [pictureURL description];
                    [user saveEventually];
                    [userDefaults setObject:user.objectId forKey:LOGGED_USER_ID];
                    [userDefaults setObject:user[PARSE_USER_NAME] forKey:LOGGED_USER_NAME];
                    [userDefaults synchronize];
                }
            }];
            
            [userDefaults setObject:user.objectId forKey:LOGGED_USER_ID];
            [userDefaults synchronize];
            [self performSegueWithIdentifier:SEGUE_FROM_LOGIN_TO_QUEST_LIST sender:self];
            
        }
    }];
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [imageData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    loggedUser[PARSE_USER_CUSTOM_USER_IMAGE] = [UIImage imageWithData:imageData];
    
    [loggedUser saveEventually];
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
