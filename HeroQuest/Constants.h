//
//  Constants.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/13/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define LOGIN_USERNAME              @"Lancelot"
#define LOGIN_PASSWORD              @"arthurDoesntKnow"

#pragma mark IDs

#define TABLE_VIEW_CELL_QUEST_LIST_LANDSCAPE        @"QuestListTableViewCellID_landscape"
#define TABLE_VIEW_CELL_QUEST_LIST_PORTRAIT         @"QuestListTableViewCellID_portrait"

#define LOGIN_VIEW_CONTROLLER_REMEMBER_USERNAME     @"LoginViewControlerRememberUsername"

#define QUEST_SETTINGS_VIEW_CONTROLLER_ID           @"QuestSettingsViewControllerID"

#pragma mark Segue

#define SEGUE_FROM_LOGIN_TO_QUEST_LIST              @"SegueFromLoginViewControllerToQuestListViewController"




#define TITLE @"title"
#define GIVER @"giver"
#define GIVER_LOCATION @"giverLocation"
#define ALIGNMENT @"alignment"
#define DESCRIPTION @"description"
#define LOCATION @"location"

#define POSTED_BY  @"Posted by: %@"
#define GOOD  1
#define NEUTRAL 2
#define EVIL 3



@interface Constants : NSObject

@end
