//
//  QuestDetailViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/14/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "QuestDetailViewController.h"
#import "QuestPointAnnotation.h"

@interface QuestDetailViewController () <MKMapViewDelegate>
{
    IBOutlet UILabel *questTitleLabel;
    IBOutlet UILabel *questAuthorLabel;
    IBOutlet UITextView *questDescriptionTextView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIBarButtonItem *acceptBarButtonItem;
    UIView *portraitView;
    UIView *landscapeView;
    UIView *currentView;
    NSDictionary* filters;
}

@end

@implementation QuestDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    filters = [userDefaults objectForKey:[NSString stringWithFormat:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER, [userDefaults objectForKey:LOGGED_USER_ID]]];

    questTitleLabel.text = self.quest[PARSE_QUESTS_NAME];
    questAuthorLabel.text = self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_NAME];
    questDescriptionTextView.text = self.quest[PARSE_QUESTS_DESCRIPTION];
    
    [self populateMapView];
    
    [self setUpViewForOrientation];
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
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [self addConstraints];
}

- (void)addConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(questTitleLabel, questAuthorLabel, questDescriptionTextView, mapView);
    NSDictionary* metrics = @{@"spacing": @8, @"vspacing": @65, @"padding": @20};
    
    NSArray* constraints;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questTitleLabel]-padding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questAuthorLabel]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questDescriptionTextView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[mapView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[questTitleLabel(>=21)]-[questAuthorLabel(21)]-[questDescriptionTextView]-[mapView(262)]-padding-|" options:0 metrics:metrics  views:views]];
        
    } else {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questTitleLabel]-spacing-[mapView(280)]-padding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questAuthorLabel]-spacing-[mapView(280)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questDescriptionTextView]-spacing-[mapView(280)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[mapView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[questTitleLabel(41)]-[questAuthorLabel(21)]-[questDescriptionTextView]-padding-|" options:0 metrics:metrics  views:views]];
        
    }
    [self.view addConstraints:constraints];
}

- (void)populateMapView
{
    PFGeoPoint* geoPointTask = self.quest[PARSE_QUESTS_LOCATION];
    PFGeoPoint* geoPointGiver = self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_LOCATION];
    CLLocationCoordinate2D taskCoordinate = CLLocationCoordinate2DMake(geoPointTask.latitude, geoPointTask.longitude);
    CLLocationCoordinate2D giverCoordinate = CLLocationCoordinate2DMake(geoPointGiver.latitude, geoPointGiver.longitude);
    
    QuestPointAnnotation* annotation = nil;
    annotation = [QuestPointAnnotation new];
    annotation.coordinate = giverCoordinate;
    annotation.title = self.quest[GIVER];
    annotation.subtitle = self.quest[TITLE];
    annotation.pointType = GIVER_TYPE;
    
    
    [mapView addAnnotation:annotation];
    
    annotation = nil;
    annotation = [QuestPointAnnotation new];
    annotation.coordinate = taskCoordinate;
    annotation.title = self.quest[TITLE];
    annotation.pointType = QUEST_TYPE;
    
    [mapView addAnnotation:annotation];
    
    double latitude = (geoPointTask.latitude + geoPointGiver.latitude) / 2;
    double longitude = (geoPointTask.longitude + geoPointGiver.longitude) / 2;
    
    double spanLatitude = (geoPointTask.latitude - geoPointGiver.latitude) * 1.4;
    double spanLongitude = (geoPointTask.longitude - geoPointGiver.longitude) * 1.4;
    
    CLLocationCoordinate2D centerCoordenate = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(fabs(spanLatitude), fabs(spanLongitude));
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordenate, span);
    
    mapView.region = region;
    mapView.mapType = [filters[QUEST_SETTINGS_VIEW_CONTROLLER_FILTER_MAP_TYPE] integerValue];
}


- (IBAction)onAcceptBarButtonItemPressed:(id)sender {
    
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    QuestPointAnnotation* questPointAnnotation = annotation;
    
    if (questPointAnnotation.pointType == GIVER_TYPE) {
        av.image = [UIImage imageNamed:@"pin_blue"];
    } else if (questPointAnnotation.pointType == QUEST_TYPE) {
        av.image = [UIImage imageNamed:@"pin_green"];
    }
    av.canShowCallout = YES;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(pushGoogleMapsApp:) forControlEvents:UIControlEventTouchUpInside];
    av.leftCalloutAccessoryView = button;

    button.tag = questPointAnnotation.pointType;
    
    return av;
}

- (void)pushGoogleMapsApp:(UIButton*)button
{
    double latitude, longitude;
    if (button.tag == GIVER_TYPE) {
        latitude = [self.quest[GIVER_LOCATION][0] doubleValue];
        longitude = [self.quest[GIVER_LOCATION][1] doubleValue];
    } else if (button.tag == QUEST_TYPE) {
        latitude = [self.quest[LOCATION][0] doubleValue];
        longitude = [self.quest[LOCATION][1] doubleValue];
    }
    NSString *latlong = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
    NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?q=%@", [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
