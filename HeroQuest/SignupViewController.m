//
//  SignupViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/21/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "SignupViewController.h"
#import "QuestListViewController.h"

@interface SignupViewController () <ParseTransactionsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    
    IBOutlet UIView *myView;
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *nameTextField;
    IBOutlet UISegmentedControl *alignmentSegmentControl;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIView *loadingView;
    
    NSUserDefaults* userDefaults;
    ParseTransactions* parseTransactions;
    UIImagePickerController* picker;
    UITextField* activeField;
    CGRect originalPositionView;
    long keyboardSize;
    BOOL keyboardIsUp;
    BOOL photoWasSelected;
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
    
    [self setUpViewForOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveViewUp:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveViewDown:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveViewUp:)
                                                 name:UITextFieldTextDidBeginEditingNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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
        loadingView.hidden = NO;
        [parseTransactions verifyExistenceUsername:usernameTextField.text];
    }
}


- (void)saveUserParse {
    
    PFUser *user = [PFUser user];
    user.username = usernameTextField.text;
    user.password = passwordTextField.text;
    user[PARSE_USER_NAME] = nameTextField.text;
    user[PARSE_USER_ALIGNMENT] = [NSNumber numberWithLong:alignmentSegmentControl.selectedSegmentIndex];
    
    if (photoWasSelected) {
        PFFile* file = [PFFile fileWithData: UIImagePNGRepresentation(profileImageView.image)];
        [file save];
        user[PARSE_USER_CUSTOM_USER_IMAGE] = file;
    }
    
    [parseTransactions signupUser:user];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setUpViewForOrientation];
}

- (void)setUpViewForOrientation
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
             [self addConstraints];
             float width = originalPositionView.size.width;
             originalPositionView.size.width = originalPositionView.size.height;
             originalPositionView.size.height = width;
             
         } completion:^(BOOL finished) {
             
             if (keyboardIsUp) {
                 [self moveViewUp:nil];
             }
         }
    ];
}

- (void)addConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(profileImageView, myView);
    NSDictionary* metrics = @{@"spacing": @8, @"vspacingLandscape": @60, @"vspacingPortrait": @70, @"padding": @20};
    
    NSArray* constraints;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[profileImageView]-padding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[myView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacingPortrait-[profileImageView]-[myView(==233)]-padding-|" options:0 metrics:metrics  views:views]];
        
    } else {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[profileImageView(<=280)]-[myView(==280)]-padding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacingLandscape-[myView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacingLandscape-[profileImageView]-padding-|" options:0 metrics:metrics  views:views]];
        
    }
    [self.view addConstraints:constraints];
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
    loadingView.hidden = YES;
    if (user) {
        [userDefaults setObject:user.objectId forKey:LOGGED_USER_ID];
        [userDefaults setObject:user[PARSE_USER_NAME] forKey:LOGGED_USER_NAME];
        [userDefaults synchronize];
        [self performSegueWithIdentifier:SEGUE_FROM_SIGNUP_TO_QUEST_LIST sender:self];
    } else {
        NSLog(@"Could not authenticate");
    }
}

#pragma mark UIImagePickerControllerDelegate


-(IBAction) onImageViewTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else{
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:picker animated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    profileImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    photoWasSelected = YES;
    [picker dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark Keyboard

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark TextField Hidden


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)moveViewUp:(NSNotification*)aNotification
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
            if ([aNotification.name isEqualToString:UIKeyboardDidShowNotification]) {
                NSDictionary* info = [aNotification userInfo];
                keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
                if (keyboardSize >= self.view.frame.size.height) {
                    keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
                }
            }
            if (keyboardSize > 0) {
                CGRect bkgndRect = originalPositionView;
                float bottomY = bkgndRect.origin.y + activeField.superview.frame.origin.y + activeField.frame.origin.y + activeField.frame.size.height + 5;
                float keyboardY = bkgndRect.size.height - keyboardSize;
                if (bottomY > keyboardY) {
                    bkgndRect.origin.y -= (bottomY - keyboardY);
                }
                [self.view setFrame:bkgndRect];
                
                keyboardIsUp = YES;
            }
            
        }
     ];
    
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)moveViewDown:(NSNotification*)aNotification
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self.view setFrame:originalPositionView];
        keyboardIsUp = NO;
    }];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (CGRectIsEmpty(originalPositionView)) {
        originalPositionView = self.view.frame;
    }
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
