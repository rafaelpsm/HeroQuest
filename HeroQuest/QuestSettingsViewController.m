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
    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *mapInstructionsLabel;
    IBOutlet UISegmentedControl *mapTypeSegmentControl;
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
    filters = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:[NSString stringWithFormat:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER, [userDefaults objectForKey:LOGGED_USER_ID]]]];
    
    if (!filters) {
        //Loading the default filter if doesn't exist
        filters = [NSMutableDictionary dictionaryWithDictionary:
                                @{QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME: @"",
                                 QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT: @QUEST_ALIGNMENT_NEUTRAL,
                                 QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_MAP_TYPE: @QUEST_MAP_TYPE_STANDARD
                                }];
    }
    
    nameTextField.text = filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME];
    alignmentSegmentControl.selectedSegmentIndex = [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT] integerValue];
    mapTypeSegmentControl.selectedSegmentIndex = [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_MAP_TYPE] integerValue];
    [self onMapTypeChange:mapTypeSegmentControl];
    
    if (filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER]) {
        CLLocationCoordinate2D centerCoordenate = CLLocationCoordinate2DMake([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER][0] doubleValue], [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER][1] doubleValue]);
        MKCoordinateSpan span = MKCoordinateSpanMake([filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION][0] doubleValue], [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION][1] doubleValue]);
        MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordenate, span);
        
        mapView.region = region;
    }
    
    [self setUpViewForOrientation];
}

- (IBAction)onMapTypeChange:(UISegmentedControl *)sender {
    mapView.mapType = sender.selectedSegmentIndex;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setUpViewForOrientation];
}

- (void)setUpViewForOrientation
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self addConstraints];
    }];
}

- (void)addConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(topLayerView, navigationBar, nameTextField, alignmentSegmentControl, mapView, mapInstructionsLabel, mapTypeSegmentControl);
    NSDictionary* metrics = @{@"spacing": @8, @"vspacing": @65, @"padding": @20};
    
    NSArray* constraints;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topLayerView]|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navigationBar]|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[nameTextField]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[alignmentSegmentControl]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[mapView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[mapInstructionsLabel]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[mapTypeSegmentControl]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayerView(21)][navigationBar(44)]-spacing-[nameTextField]-[alignmentSegmentControl]-[mapView(262)]-[mapInstructionsLabel(35)]-[mapTypeSegmentControl]" options:0 metrics:metrics  views:views]];
        
    } else {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topLayerView]|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navigationBar]|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[nameTextField]-[mapView(280)]-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[alignmentSegmentControl]-[mapView(280)]-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[mapInstructionsLabel]-[mapView(280)]-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[mapTypeSegmentControl]-[mapView(280)]-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayerView(21)][navigationBar(44)]-padding-[nameTextField]-[alignmentSegmentControl]-[mapInstructionsLabel(35)]-[mapTypeSegmentControl]" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayerView(21)][navigationBar(44)]-spacing-[mapView]-spacing-|" options:0 metrics:metrics  views:views]];
        
    }
    [self.view addConstraints:constraints];
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender {
    filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_NAME] = nameTextField.text;
    filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_ALIGNMENT] = [NSNumber numberWithInteger:alignmentSegmentControl.selectedSegmentIndex];
    filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_MAP_TYPE] = [NSNumber numberWithInteger:mapTypeSegmentControl.selectedSegmentIndex];
    
    filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_CENTER] = @[[NSNumber numberWithDouble:mapView.region.center.latitude], [NSNumber numberWithDouble:mapView.region.center.longitude]];
    filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_LOCATION_REGION] = @[[NSNumber numberWithDouble:mapView.region.span.latitudeDelta], [NSNumber numberWithDouble:mapView.region.span.longitudeDelta]];
    
    [userDefaults setObject:filters forKey:[NSString stringWithFormat:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER, [userDefaults objectForKey:LOGGED_USER_ID]]];
    
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate didDismissSettigns];
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
