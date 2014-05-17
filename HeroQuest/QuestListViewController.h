//
//  QuestListViewController.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/14/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

-(void)applyFilters;

@end
