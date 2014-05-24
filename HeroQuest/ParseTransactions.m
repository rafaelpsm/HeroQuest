//
//  ParseTransactions.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/22/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "ParseTransactions.h"

@implementation ParseTransactions

-(void)authenticateWithUsername:(NSString*)username withPassword:(NSString*)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (!error) {
            if (self.delegate) {
                [self.delegate didAutenticatheResponse:user];
            }
        } else {
            NSLog(@"Error onSignupButtonPressed: %@ %@", error, [error userInfo]);
        }
    }];
    
}

-(void)verifyExistenceUsername:(NSString*)username
{
    PFQuery* query = [PFUser query];
    
    [query whereKey:PARSE_USER_USERNAME equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.delegate) {
                if (objects.count > 0) {
                    [self.delegate didVerifyExistenceUsername:YES];
                } else {
                    [self.delegate didVerifyExistenceUsername:NO];
                }
            }
        } else {
            NSLog(@"Error onSignupButtonPressed: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)signupUser:(PFUser*)user
{
    [user signUpInBackgroundWithTarget:self selector:@selector(callBackSaveObject: error:)];
}

- (void)callBackSaveObject:(NSNumber*)result error:(NSError*)error
{
    if (self.delegate) {
        [self.delegate didSignupUser:[result boolValue]];
    }
}

@end
