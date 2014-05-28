//
//  ParseTransactions.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/22/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Quest.h"

@protocol ParseTransactionsDelegate <NSObject>
@optional
- (void)didAutenticatheResponse:(PFUser*)user;
- (void)didVerifyExistenceUsername:(BOOL)usernameExists;
- (void)didSignupUser:(BOOL)succeed;
- (void)didListQuests:(NSArray*)list;
- (void)didSaveQuest:(BOOL)succeeded;
@end

@interface ParseTransactions : NSObject

@property (nonatomic, weak) id <ParseTransactionsDelegate> delegate;

-(void)authenticateWithUsername:(NSString*)username withPassword:(NSString*)password;
-(void)verifyExistenceUsername:(NSString*)username;
-(void)signupUser:(PFUser*)user;
-(void)listQuests:(NSDictionary *)filters status:(NSNumber*)status;
-(void)saveQuest:(Quest*)quest;

@end
