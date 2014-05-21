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




@interface QuestListViewController (){
    NSArray* questListTemp;
    NSMutableArray* questList;
    NSIndexPath* selectedIndexPath;
    IBOutlet UITableView *questTableView;
    UIDeviceOrientation currentOrientation;
    NSUserDefaults* userDefaults;
}

@end

@implementation QuestListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    questListTemp = @[
                  @{TITLE: @"Bandits in the Woods - Yes this is a log title",
                    GIVER: @"HotDogg The Bounty Hunter",
                    GIVER_LOCATION: @[@46.8541979, @-96.8285138],
                    ALIGNMENT: @QUEST_ALIGNMENT_GOOD,
                    DESCRIPTION: @"The famed bounty hunter HotDog has requested the aid of a hero in ridding the woods of terrifying bandits who have thus far eluded his capture, as he is actually a dog, and cannot actually grab things more than 6 feet off the ground. ",
                    LOCATION: @[@46.908588, @-96.808991]
                    },
                  @{TITLE: @"Special Delivery",
                    GIVER: @"Sir Jimmy The Swift",
                    GIVER_LOCATION: @[@46.8739748, @-96.806112],
                    ALIGNMENT: @QUEST_ALIGNMENT_NEUTRAL,
                    DESCRIPTION: @"Sir Jimmy was once the fastest man in the kingdom, brave as any soldier and wise as a king. Unfortunately, age catches us all in the end, and he has requested that I, his personal scribe, find a hero to deliver a package of particular importance--and protect it with their life. ",
                    LOCATION: @[@46.8657639, @-96.7363173]
                    },
                  @{TITLE: @"Filthy Mongrel",
                    GIVER: @"Prince Jack, The Iron Horse",
                    GIVER_LOCATION: @[@46.8739748, @-96.806112],
                    ALIGNMENT: @QUEST_ALIGNMENT_EVIL,
                    DESCRIPTION: @"That strange dog that everyone is treating like a bounty-hunter must go. By the order of Prince Jack, that smelly, disease ridden mongrel must be removed from our streets by any means necessary. He is disrupting the lives of ordinary citizens, and it's just really weird. Make it gone. ",
                    LOCATION: @[@46.892386, @-96.799669]
                    }
                  ];
    
    [self applyFilters];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (currentOrientation != [[UIDevice currentDevice] orientation]) {
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
    NSDictionary* filters = [userDefaults objectForKey:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER];
    NSMutableString* predicateFormatString = [NSMutableString stringWithString:@" 1 == 1 "];
    NSMutableArray* parameters = [NSMutableArray new];
    questList = [NSMutableArray new];
    
    if (filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME] && ![filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME] isEqualToString:@""]) {
        [predicateFormatString appendString:@" AND %K contains[cd] %@ "];
        [parameters addObject:GIVER];
        [parameters addObject:filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME]];
    }
    if ([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT] integerValue] != QUEST_ALIGNMENT_NEUTRAL) {
        [predicateFormatString appendString:@" AND %K == %@ "];
        [parameters addObject:ALIGNMENT];
        [parameters addObject:filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT]];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormatString argumentArray:parameters];
    questListTemp = [questListTemp filteredArrayUsingPredicate:predicate];
    
    CLLocationCoordinate2D centerCoordenate = CLLocationCoordinate2DMake([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER][0] doubleValue], [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER][1] doubleValue]);
    MKCoordinateSpan span = MKCoordinateSpanMake([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION][0] doubleValue], [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION][1] doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordenate, span);
    
    for (NSDictionary* dict in questListTemp) {
        CLLocationCoordinate2D coordinateTask = CLLocationCoordinate2DMake([dict[LOCATION][0] doubleValue], [dict[LOCATION][1] doubleValue]);
        CLLocationCoordinate2D coordinateGiver = CLLocationCoordinate2DMake([dict[GIVER_LOCATION][0] doubleValue], [dict[GIVER_LOCATION][1] doubleValue]);
        if([self coordinate:coordinateTask inRegion:region] || [self coordinate:coordinateGiver inRegion:region]){
            [questList addObject:dict];
        }
    }
    
    [questTableView reloadData];
}

- (BOOL)coordinate:(CLLocationCoordinate2D)coord inRegion:(MKCoordinateRegion)region
{
    CLLocationCoordinate2D center = region.center;
    MKCoordinateSpan span = region.span;
    
    BOOL result = YES;
    result &= cos((center.latitude - coord.latitude)*M_PI/180.0) > cos(span.latitudeDelta/2.0*M_PI/180.0);
    result &= cos((center.longitude - coord.longitude)*M_PI/180.0) > cos(span.longitudeDelta/2.0*M_PI/180.0);
    return result;
}

#pragma mark Actions

- (IBAction)onSettingButtonPressed:(UIBarButtonItem *)sender {
    QuestSettingsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:QUEST_SETTINGS_VIEW_CONTROLLER_ID];
    controller.originViewController = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return questList.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellID = TABLE_VIEW_CELL_QUEST_LIST_LANDSCAPE;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        cellID = TABLE_VIEW_CELL_QUEST_LIST_PORTRAIT;
    }
    QuestListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    NSDictionary* dict = questList[indexPath.row];
    
    cell.questTitleLabel.text = dict[TITLE];
    cell.questAuthorLabel.text = [NSString stringWithFormat:POSTED_BY, dict[GIVER]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:SEGUE_FROM_QUEST_LIST_TO_DETAIL sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    QuestDetailViewController* vc = segue.destinationViewController;
    vc.questDetailDictionary = questList[selectedIndexPath.row];
}


@end
