//
//  QuestSettingsViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/15/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "QuestSettingsViewController.h"
#import "QuestListViewController.h"

@interface QuestSettingsViewController ()
{
    IBOutlet UIView *topLayerView;
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UITextField *nameTextField;
    IBOutlet UISegmentedControl *alignmentSegmentControl;
    NSUserDefaults* userDefaults;
    NSMutableDictionary* filters;
}

@end

@implementation QuestSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Altero cor da label localizada no topo para ter a mesma cor de fundo do topo
    topLayerView.backgroundColor = UIColorFromRGB(0xffbc42);
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xffbc42)];
    
    //Load Filters from user defaults
    userDefaults = [NSUserDefaults standardUserDefaults];
    filters = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER]];
    
    nameTextField.text = filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME];
    alignmentSegmentControl.selectedSegmentIndex = [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT] integerValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender {
    filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME] = nameTextField.text;
    filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT] = [NSNumber numberWithInteger:alignmentSegmentControl.selectedSegmentIndex];
    [userDefaults setObject:filters forKey:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.originViewController isKindOfClass:[QuestListViewController class]]) {
            QuestListViewController* vc = (QuestListViewController*) self.originViewController;
            [vc applyFilters];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
