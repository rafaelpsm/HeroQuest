//
//  ParseTransactions.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/22/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "ParseTransactions.h"

@implementation ParseTransactions

#pragma mark User

-(void)authenticateWithUsername:(NSString*)username withPassword:(NSString*)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (!error) {
            if (self.delegate) {
                [self.delegate didAutenticatheResponse:user];
            }
        } else {
            NSLog(@"Error authenticateWithUsername: %@ %@", error, [error userInfo]);
            if (self.delegate) {
                [self.delegate didAutenticatheResponse:nil];
            }
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
            NSLog(@"Error verifyExistenceUsername: %@ %@", error, [error userInfo]);
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

#pragma mark Quest

-(void)listQuests:(NSDictionary *)filters status:(NSNumber*)status
{
    PFQuery *query;
    PFGeoPoint *swOfSF;
    PFGeoPoint *neOfSF;
    NSMutableString* predicateFormatString = [NSMutableString new];
    NSMutableArray* parameters = [NSMutableArray new];
    if (filters) {
        if (filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME] && ![filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME] isEqualToString:@""]) {
            [predicateFormatString appendString:@" AND %K contains[cd] %@ "];
            [parameters addObject:PARSE_QUESTS_NAME];
            [parameters addObject:filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME]];
        }
        if ([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT] integerValue] != QUEST_ALIGNMENT_NEUTRAL) {
            [predicateFormatString appendString:@" AND %K == %@ "];
            [parameters addObject:PARSE_QUESTS_ALIGNMENT];
            [parameters addObject:filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT]];
        }
        if (filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER]) {
            CLLocationCoordinate2D centerCoordenate = CLLocationCoordinate2DMake([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER][0] doubleValue], [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER][1] doubleValue]);
            MKCoordinateSpan span = MKCoordinateSpanMake([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION][0] doubleValue], [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION][1] doubleValue]);
            
            swOfSF = [PFGeoPoint geoPointWithLatitude:centerCoordenate.latitude - span.latitudeDelta longitude:centerCoordenate.longitude - span.longitudeDelta];
            neOfSF = [PFGeoPoint geoPointWithLatitude:centerCoordenate.latitude + span.latitudeDelta longitude:centerCoordenate.longitude + span.longitudeDelta];
        }

    }
    if (parameters.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[predicateFormatString substringFromIndex:4] argumentArray:parameters];
        query = [PFQuery queryWithClassName:PARSE_QUESTS predicate:predicate];
    } else {
        query = [PFQuery queryWithClassName:PARSE_QUESTS];
    }
    if ([status intValue] >= 0) {
        [query whereKey:PARSE_QUESTS_COMPLETED equalTo:status];
    }
    if (swOfSF) {
        [query whereKey:PARSE_QUESTS_LOCATION withinGeoBoxFromSouthwest:swOfSF toNortheast:neOfSF];
    }
    
    [query orderByDescending:PARSE_QUESTS_COMPLETED];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.delegate) {
                [self.delegate didListQuests:objects];
            }
        } else {
            NSLog(@"Error listQuests: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
