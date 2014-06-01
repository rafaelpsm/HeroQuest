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
    
    NSMutableDictionary* cachedImages;
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
    
    cachedImages = [NSMutableDictionary new];
    
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
        
//    } else if (currentOrientation != [[UIDevice currentDevice] orientation]) {
//        [questTableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    currentOrientation = [[UIDevice currentDevice] orientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    currentOrientation = [[UIDevice currentDevice] orientation];
    
    NSArray* cells = [questTableView visibleCells];
    for (QuestListTableViewCell* cell in cells) {
        [self addConstraintsToCell:cell];
    }
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
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        if (statusView.frame.origin.y < (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height)) {
            CGRect rect = statusView.frame;
            rect.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
            statusView.frame = rect;
        } else {
            CGRect rect = statusView.frame;
            rect.origin.y = 0;
            statusView.frame = rect;
        }
    }];
    
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
    NSString* cellID = TABLE_VIEW_CELL_QUEST_LIST_PORTRAIT;
    
    QuestListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    Quest* quest = [questList[questListOrder[indexPath.section]] objectAtIndex:indexPath.row];
    PFUser* user = quest[PARSE_QUESTS_QUEST_GIVER];
    [user fetchIfNeeded];
    
    cell.questTitleLabel.text = quest[PARSE_QUESTS_NAME];
    cell.questAuthorLabel.text = [NSString stringWithFormat:POSTED_BY, user[PARSE_USER_NAME]];
    
    //Load image in background
    cell.questImageView.hidden = YES;
    
    [cell bringSubviewToFront:cell.loadingQuestImageView];
    cell.questImageView.image = nil;
    
    [self addConstraintsToCell:cell];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    
    dispatch_async(queue, ^{
        NSURL* url = [NSURL URLWithString:quest[PARSE_QUESTS_LOCATION_IMAGE_URL]];
        
        NSData* imageData = nil;
        __block UIImage* cachedImage = nil;
        if ([cachedImages objectForKey:quest.objectId]) {
            cachedImage = [cachedImages objectForKey:quest.objectId];
        } else {
            imageData = [NSData dataWithContentsOfURL:url];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!cachedImage) {
                cachedImage = [UIImage imageWithData:imageData];
                
                [cachedImages setObject:cachedImage forKey:quest.objectId];
            }
            cell.questImageView.image = cachedImage;
            [cell bringSubviewToFront:cell.questImageView];
            cell.questImageView.layer.cornerRadius = 15;
            cell.questImageView.layer.masksToBounds = YES;
            cell.questImageView.hidden = NO;
        });
        
    });
    
    return cell;
}

- (void)addConstraintsToCell:(QuestListTableViewCell*)cell
{
    [cell removeConstraints:cell.constraints];
    
    UILabel* titleLabel = cell.questTitleLabel;
    UILabel* authorLabel = cell.questAuthorLabel;
    UILabel* rewardLabel = cell.questRewardLabel;
    UIImageView* imageView = cell.questImageView;
    UIView* loadingImageView = cell.loadingQuestImageView;
    
    NSDictionary* views = NSDictionaryOfVariableBindings(titleLabel, authorLabel, rewardLabel, imageView, loadingImageView);
    NSDictionary* metrics = @{@"spacing": @2, @"padding": @5, @"rightPadding": @15};
    
    NSArray* constraints;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[imageView(66)]-[titleLabel]-rightPadding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[imageView(66)]-[authorLabel]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[imageView(66)]-[rewardLabel]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[loadingImageView(66)]-[titleLabel]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[loadingImageView(66)]-[authorLabel]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[loadingImageView(66)]-[rewardLabel]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[imageView(66)]-spacing-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[loadingImageView(66)]-spacing-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[titleLabel]-spacing-[authorLabel]-spacing-[rewardLabel]-spacing-|" options:0 metrics:metrics  views:views]];
        
    } else {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[imageView(66)]-[titleLabel]-[rewardLabel(<=150)]-rightPadding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[imageView(66)]-[authorLabel]-[rewardLabel(<=150)]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[loadingImageView(66)]-[titleLabel]-[rewardLabel(<=150)]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[loadingImageView(66)]-[authorLabel]-[rewardLabel(<=150)]-rightPadding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[imageView(66)]-spacing-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[loadingImageView(66)]-spacing-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[titleLabel]-padding-[authorLabel(21)]" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[rewardLabel]-spacing-|" options:0 metrics:metrics  views:views]];
        
    }
    [cell addConstraints:constraints];
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
