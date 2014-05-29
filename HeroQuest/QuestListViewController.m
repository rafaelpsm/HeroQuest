//
//  QuestListViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/14/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "QuestListViewController.h"
#import "QuestListTableViewCell.h"
#import "QuestDetailViewController.h"
#import "QuestSettingsViewController.h"
#import "ParseTransactions.h"
#import "Quest.h"


@interface QuestListViewController () <QuestSettingsViewControllerDelegate, ParseTransactionsDelegate>
{
    IBOutlet UITableView *questTableView;
    IBOutlet UIView *loadingView;
    IBOutlet UISegmentedControl *statusFilterSegmentControl;
    IBOutlet UIView *statusView;
    
    NSArray* questListTemp;
    NSArray* questListOrder;
    NSMutableDictionary* questList;
    NSIndexPath* selectedIndexPath;
    UIDeviceOrientation currentOrientation;
    NSUserDefaults* userDefaults;
    ParseTransactions* parseTransactions;
}

@end

@implementation QuestListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    parseTransactions = [ParseTransactions new];
    parseTransactions.delegate = self;
    
    loadingView.layer.cornerRadius = 20;
    loadingView.layer.masksToBounds = YES;
    
    [self applyFilters];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([userDefaults objectForKey:QUEST_DETAIL_VIEW_CONTROLLER_UPDATE_LIST]) {
        [userDefaults removeObjectForKey:QUEST_DETAIL_VIEW_CONTROLLER_UPDATE_LIST];
        
        [self applyFilters];
        
    } else if (currentOrientation != [[UIDevice currentDevice] orientation]) {
        [questTableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    currentOrientation = [[UIDevice currentDevice] orientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    currentOrientation = [[UIDevice currentDevice] orientation];
    [questTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)applyFilters
{
    loadingView.hidden = NO;
    NSDictionary* filters = [userDefaults objectForKey:[NSString stringWithFormat:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER, [userDefaults objectForKey:LOGGED_USER_ID]]];
    [parseTransactions listQuests:filters status:[NSNumber numberWithInteger:statusFilterSegmentControl.selectedSegmentIndex]];
}

-(void)questListReceived
{
    questList = [NSMutableDictionary new];
    questListOrder = @[];
    NSMutableArray* sectionCompleted = [NSMutableArray new];
    NSMutableArray* sectionAccepted = [NSMutableArray new];
    NSMutableArray* sectionNotAccepted = [NSMutableArray new];
    
    for (Quest* quest in questListTemp) {
        if ([quest[PARSE_QUESTS_COMPLETED] isEqualToNumber:@YES]) {
            [sectionCompleted addObject:quest];
        } else if ([((PFUser*) quest[PARSE_QUESTS_ACCEPTED_BY]).objectId isEqualToString:[userDefaults objectForKey:LOGGED_USER_ID]]) {
            [sectionAccepted addObject:quest];
        } else {
            [sectionNotAccepted addObject:quest];
        }
    }
    
    if (sectionNotAccepted.count > 0) {
        [questList setObject:sectionNotAccepted forKey:NSLocalizedString(@"quest.notaccepted", nil)];
        questListOrder = [questListOrder arrayByAddingObject:NSLocalizedString(@"quest.notaccepted", nil)];
    }
    if (sectionAccepted.count > 0) {
        [questList setObject:sectionAccepted forKey:NSLocalizedString(@"quest.accepted", nil)];
        questListOrder = [questListOrder arrayByAddingObject:NSLocalizedString(@"quest.accepted", nil)];
    }
    if (sectionCompleted.count > 0) {
        [questList setObject:sectionCompleted forKey:NSLocalizedString(@"quest.completed", nil)];
        questListOrder = [questListOrder arrayByAddingObject:NSLocalizedString(@"quest.completed", nil)];
    }
    
    [questTableView reloadData];
    loadingView.hidden = YES;
}

#pragma mark Actions

- (IBAction)onSettingButtonPressed:(UIBarButtonItem *)sender {
    QuestSettingsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:QUEST_SETTINGS_VIEW_CONTROLLER_ID];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onFilterButtonPressed:(UIBarButtonItem *)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    if (statusView.frame.origin.y < (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height)) {
        CGRect rect = statusView.frame;
        rect.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
        statusView.frame = rect;
    } else {
        CGRect rect = statusView.frame;
        rect.origin.y = 0;
        statusView.frame = rect;
    }
}

- (IBAction)onStatusFilterChange:(UISegmentedControl *)sender {
    [self applyFilters];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return questListOrder.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return questListOrder[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 35)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string = [self tableView:tableView titleForHeaderInSection:section];
    label.text = string;
    label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
    
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xFFDC86)];
    
    return view;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [questList[questListOrder[section]] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = TABLE_VIEW_CELL_QUEST_LIST_LANDSCAPE;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        cellID = TABLE_VIEW_CELL_QUEST_LIST_PORTRAIT;
    }
    QuestListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    Quest* quest = [questList[questListOrder[indexPath.section]] objectAtIndex:indexPath.row];
    PFUser* user = quest[PARSE_QUESTS_QUEST_GIVER];
    [user fetchIfNeeded];
    
    cell.questTitleLabel.text = quest[PARSE_QUESTS_NAME];
    NSLog(@"%@", (PFUser*)quest[PARSE_QUESTS_QUEST_GIVER]);
    cell.questAuthorLabel.text = [NSString stringWithFormat:POSTED_BY, user[PARSE_USER_NAME]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:SEGUE_FROM_QUEST_LIST_TO_DETAIL sender:self];
}

#pragma mark QuestSettingsViewControllerDelegate

- (void)didDismissSettigns
{
    [self applyFilters];
}

#pragma mark ParseTransactionsDelegate

- (void)didListQuests:(NSArray *)list
{
    questListTemp = list;
    
    [self questListReceived];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    QuestDetailViewController* vc = segue.destinationViewController;
    vc.quest = [questList[questListOrder[selectedIndexPath.section]] objectAtIndex:selectedIndexPath.row];
}


@end
