//
//  QuestSettingsViewController.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/15/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuestSettingsViewControllerDelegate <NSObject>
@optional
-(void)didDismissSettigns;
@end

@interface QuestSettingsViewController : UIViewController

@property (weak, nonatomic) id<QuestSettingsViewControllerDelegate> delegate;

@end
