//
//  Constants.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/13/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//FB APP ID - 1489594571258985
//APP Secret - b4bc0d8b722150196a092fbff1f9b4e5

#define LOGGED_USER_ID          @"LOGGED_USER_ID"
#define LOGGED_USER_NAME        @"LOGGED_USER_NAME"

#pragma mark IDs

#define TABLE_VIEW_CELL_QUEST_LIST_LANDSCAPE        @"QuestListTableViewCellID_landscape"
#define TABLE_VIEW_CELL_QUEST_LIST_PORTRAIT         @"QuestListTableViewCellID_portrait"

#define LOGIN_VIEW_CONTROLLER_REMEMBER_USERNAME     @"LoginViewControlerRememberUsername"

#define QUEST_SETTINGS_VIEW_CONTROLLER_ID           @"QuestSettingsViewControllerID"
#define QUEST_SETTINGS_VIEW_CONTROLLER_FILTER       @"QuestSettingsViewControllerFilterForUser_%@"
#define QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME  @"QuestSettingsViewControllerFilterName"
#define QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT  @"QuestSettingsViewControllerFilterAlignment"
#define QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER   @"QuestSettingsViewControllerFilterLocationCenter"
#define QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION   @"QuestSettingsViewControllerFilterLocationRegion"
#define QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_MAP_TYPE   @"QuestSettingsViewControllerFilterMapType"

#define QUEST_LOADING_VIEW_CONTROLLER_ID            @"LoadingViewControllerID"

#define QUEST_DETAIL_VIEW_CONTROLLER_UPDATE_LIST    @"QuestDetailViewControllerUpdateList"

#define QUEST_ALIGNMENT_GOOD  0
#define QUEST_ALIGNMENT_NEUTRAL  1
#define QUEST_ALIGNMENT_EVIL  2

#define QUEST_MAP_TYPE_STANDARD  0
#define QUEST_MAP_TYPE_SATELLITE  1
#define QUEST_MAP_TYPE_HYBRID  2

#pragma mark Segue


#define SEGUE_FROM_LOGIN_TO_QUEST_LIST              @"SegueFromLoginViewControllerToQuestListViewController"
#define SEGUE_FROM_QUEST_LIST_TO_DETAIL             @"SegueFromQuestListViewControllerToDetailViewController"
#define SEGUE_FROM_SIGNUP_TO_QUEST_LIST             @"SegueSignupViewControllerToQuestListViewController"




#define TITLE @"title"
#define GIVER @"giver"
#define GIVER_LOCATION @"giverLocation"
#define ALIGNMENT @"alignment"
#define DESCRIPTION @"description"
#define LOCATION @"location"

#define POSTED_BY  @"Posted by: %@"


#define PARSE_USER              @"User"
#define PARSE_USER_OBJECT_ID    @"objectId"
#define PARSE_USER_USERNAME     @"username"
#define PARSE_USER_PASSWORD     @"password"
#define PARSE_USER_AUTHDATA     @"authData"
#define PARSE_USER_EMAIL_VERIFIED @"emailVerified"
#define PARSE_USER_ADDITIONAL   @"additional"
#define PARSE_USER_ALIGNMENT    @"alignment"
#define PARSE_USER_CUSTOM_USER_IMAGE @"customUserImage"
#define PARSE_USER_EMAIL        @"email"
#define PARSE_USER_IMAGE_URL    @"imageUrl"
#define PARSE_USER_IS_HERO      @"isHero"
#define PARSE_USER_LOCATION     @"location"
#define PARSE_USER_NAME         @"name"
#define PARSE_USER_CREATED_AT   @"createdAt"
#define PARSE_USER_UPDATED_AT   @"updatedAt"
#define PARSE_USER_ACL          @"ACL"

#define PARSE_QUESTS              @"Quests"
#define PARSE_QUESTS_OBJECT_ID    @"objectId"
#define PARSE_QUESTS_ACCEPTED_BY  @"acceptedBy"
#define PARSE_QUESTS_ALIGNMENT    @"alignment"
#define PARSE_QUESTS_COMPLETED    @"completed"
#define PARSE_QUESTS_DESCRIPTION  @"description"
#define PARSE_QUESTS_LOCATION     @"location"
#define PARSE_QUESTS_LOCATION_IMAGE_URL @"locationImageUrl"
#define PARSE_QUESTS_NAME         @"name"
#define PARSE_QUESTS_QUEST_GIVER  @"questGiver"
#define PARSE_QUESTS_CREATED_AT   @"createdAt"
#define PARSE_QUESTS_UPDATED_AT   @"updatedAt"
#define PARSE_QUESTS_ACL          @"ACL"


@interface Constants : NSObject

@end
