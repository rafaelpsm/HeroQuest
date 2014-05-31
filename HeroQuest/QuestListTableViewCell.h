//
//  QuestListTableViewCell.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/14/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *questTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *questAuthorLabel;
@property (strong, nonatomic) IBOutlet UILabel *questRewardLabel;
@property (strong, nonatomic) IBOutlet UIImageView *questImageView;
@property (strong, nonatomic) IBOutlet UIView *loadingQuestImageView;

@end
