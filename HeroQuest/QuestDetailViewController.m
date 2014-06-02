//
//  QuestDetailViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/14/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "QuestDetailViewController.h"
#import "QuestPointAnnotation.h"

@interface QuestDetailViewController () <MKMapViewDelegate, UIAlertViewDelegate, ParseTransactionsDelegate>
{
    IBOutlet UILabel *questTitleLabel;
    IBOutlet UILabel *questAuthorLabel;
    IBOutlet UITextView *questDescriptionTextView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIBarButtonItem *acceptBarButtonItem;
    IBOutlet UIImageView *questImageView;
    IBOutlet UIView *loadingQuestImageView;
    UIView *portraitView;
    UIView *landscapeView;
    UIView *currentView;
    NSDictionary* filters;
    NSUserDefaults* userDefaults;
    ParseTransactions* parseTransactions;
    QuestPointAnnotation* annotationGiver;
}

@end

@implementation QuestDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    parseTransactions = [ParseTransactions new];
    parseTransactions.delegate = self;
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    filters = [userDefaults objectForKey:[NSString stringWithFormat:QUEST_SETTINGS_VIEW_CONTROLLER_FILTER, [userDefaults objectForKey:LOGGED_USER_ID]]];

    questTitleLabel.text = self.quest[PARSE_QUESTS_NAME];
    questAuthorLabel.text = [NSString stringWithFormat:POSTED_BY, self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_NAME]];
    questDescriptionTextView.text = self.quest[PARSE_QUESTS_DESCRIPTION];
    
    if ([self.quest[PARSE_QUESTS_COMPLETED] boolValue]) {
        acceptBarButtonItem.image = [UIImage imageNamed:@"bt_completed"];
    } else if ([((PFUser*) self.quest[PARSE_QUESTS_ACCEPTED_BY]).objectId isEqualToString:[userDefaults objectForKey:LOGGED_USER_ID]]) {
        acceptBarButtonItem.image = [UIImage imageNamed:@"bt_complete"];
    }
    
    if (self.questCachedImage) {
        questImageView.image = self.questCachedImage;
        [self.view bringSubviewToFront:questImageView];
        questImageView.layer.cornerRadius = 15;
        questImageView.layer.masksToBounds = YES;
        questImageView.hidden = NO;
    } else if (self.quest[PARSE_QUESTS_LOCATION_IMAGE_URL]){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        
        dispatch_async(queue, ^{
            NSURL* url = [NSURL URLWithString:self.quest[PARSE_QUESTS_LOCATION_IMAGE_URL]];
            
            NSData* imageData = nil;
            imageData = [NSData dataWithContentsOfURL:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    UIImage* image = [UIImage imageWithData:imageData];
                    
                    questImageView.image = image;
                    [self.view bringSubviewToFront:questImageView];
                    questImageView.layer.cornerRadius = 15;
                    questImageView.layer.masksToBounds = YES;
                    questImageView.hidden = NO;
                    questImageView.alpha = 1;
                    
                    //Modifies anotattion
                    [mapView removeAnnotation:annotationGiver];
                    annotationGiver.image = image;
                    [mapView addAnnotation:annotationGiver];
                }];
            });
            
        });
    } else {
        questImageView.image = [UIImage imageNamed:NO_IMAGE_AVAILABLE];
        
        //Modifies anotattion
        [mapView removeAnnotation:annotationGiver];
        annotationGiver.image = questImageView.image;
        [mapView addAnnotation:annotationGiver];
    }
    
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
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self addConstraints];
    }];
    
}

- (void)addConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(questImageView, loadingQuestImageView, questTitleLabel, questAuthorLabel, questDescriptionTextView, mapView);
    NSDictionary* metrics = @{@"spacing": @8, @"vspacing": @65, @"padding": @20};
    
    NSArray* constraints;
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questImageView(100)]-[questTitleLabel]-padding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questImageView(100)]-[questAuthorLabel]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[loadingQuestImageView(100)]-[questTitleLabel]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[loadingQuestImageView(100)]-[questAuthorLabel]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questDescriptionTextView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[mapView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[questImageView(100)]-[questDescriptionTextView]-[mapView(232)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[loadingQuestImageView(100)]-[questDescriptionTextView]-[mapView(232)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[questTitleLabel(>=21)]-[questAuthorLabel(21)]-[questDescriptionTextView]-[mapView(232)]-padding-|" options:0 metrics:metrics  views:views]];
        
    } else {
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questImageView(100)]-[questTitleLabel]-spacing-[mapView(280)]-padding-|" options:0 metrics:metrics  views:views];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questImageView(100)]-[questAuthorLabel]-spacing-[mapView(260)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[loadingQuestImageView(100)]-[questTitleLabel]-spacing-[mapView(280)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[loadingQuestImageView(100)]-[questAuthorLabel]-spacing-[mapView(260)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[questDescriptionTextView]-spacing-[mapView(260)]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[mapView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[questImageView(100)]-[questDescriptionTextView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[loadingQuestImageView(100)]-[questDescriptionTextView]-padding-|" options:0 metrics:metrics  views:views]];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vspacing-[questTitleLabel(>=41)]-[questAuthorLabel(21)]-[questDescriptionTextView]-padding-|" options:0 metrics:metrics  views:views]];
        
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
    annotation.title = self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_NAME];
    annotation.pointType = GIVER_TYPE;
    
    if (self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_IMAGE_URL]) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        
        dispatch_async(queue, ^{
            NSURL* url = [NSURL URLWithString:self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_IMAGE_URL]];
            
            NSData* imageData = nil;
            imageData = [NSData dataWithContentsOfURL:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [mapView removeAnnotation:annotation];
                
                UIImage* image = [UIImage imageWithData:imageData];
                annotation.image = image;
                
                [mapView addAnnotation:annotation];
            });
            
        });
    } else {
        annotation.image = [UIImage imageNamed:NO_IMAGE_AVAILABLE];
    }
    
    
    [mapView addAnnotation:annotation];
    
    annotation = nil;
    annotation = [QuestPointAnnotation new];
    annotation.coordinate = taskCoordinate;
    annotation.title = self.quest[PARSE_QUESTS_NAME];
    annotation.pointType = QUEST_TYPE;
    if (self.questCachedImage) {
        annotation.image = self.questCachedImage;
    }
    annotationGiver = annotation;
    
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
    
    if ([self.quest[PARSE_QUESTS_COMPLETED] boolValue]) {
        
    } else if ([((PFUser*) self.quest[PARSE_QUESTS_ACCEPTED_BY]).objectId isEqualToString:[userDefaults objectForKey:LOGGED_USER_ID]]) {
        
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertview.questdetail.title", nil)
                                                     message:NSLocalizedString(@"alertview.questdetail.complete.message", nil)
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"alertview.questdetail.complete.yes", nil), NSLocalizedString(@"alertview.questdetail.complete.no", nil), nil];
        [al show];
    } else {
        
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertview.questdetail.title", nil)
                                                     message:NSLocalizedString(@"alertview.questdetail.accept.message", nil)
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"alertview.questdetail.accept.yes", nil), NSLocalizedString(@"alertview.questdetail.accept.no", nil), nil];
        [al show];
    }
    
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
    
    CGRect cropRect = CGRectMake(0.0, 0.0,35.0, 35.0);
    if (questPointAnnotation.image) {
        UIImageView* myImageView = [[UIImageView alloc] initWithFrame:cropRect];
        myImageView.layer.masksToBounds = YES;
        myImageView.layer.cornerRadius = 5;
        myImageView.image = questPointAnnotation.image;
        av.leftCalloutAccessoryView = myImageView;
    } else {
        UIView* view = [[UIView alloc] initWithFrame:cropRect];
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:cropRect];
        indicator.color = [UIColor blackColor];
        [indicator startAnimating];
        [view addSubview:indicator];
        av.leftCalloutAccessoryView = view;
    }
    av.highlighted=YES;
    av.canShowCallout=YES;
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(pushGoogleMapsApp:) forControlEvents:UIControlEventTouchUpInside];
    av.rightCalloutAccessoryView = button;

    button.tag = questPointAnnotation.pointType;
    
    return av;
}

- (void)pushGoogleMapsApp:(UIButton*)button
{
    double latitude, longitude;
    if (button.tag == GIVER_TYPE) {
        latitude = [(PFGeoPoint*)self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_LOCATION] latitude];
        longitude = [(PFGeoPoint*)self.quest[PARSE_QUESTS_QUEST_GIVER][PARSE_USER_LOCATION] longitude];
    } else if (button.tag == QUEST_TYPE) {
        latitude = [(PFGeoPoint*)self.quest[PARSE_QUESTS_LOCATION] latitude];
        longitude = [(PFGeoPoint*)self.quest[PARSE_QUESTS_LOCATION] longitude];
    }
    NSString *latlong = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
    NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?q=%@", [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if ([((PFUser*) self.quest[PARSE_QUESTS_ACCEPTED_BY]).objectId isEqualToString:[userDefaults objectForKey:LOGGED_USER_ID]]) {
                self.quest[PARSE_QUESTS_COMPLETED] = @YES;
                [parseTransactions saveQuest:self.quest];
            } else {
                self.quest[PARSE_QUESTS_ACCEPTED_BY] = [PFUser currentUser];
                [parseTransactions saveQuest:self.quest];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark ParseTransactionsDelegate

- (void)didSaveQuest:(BOOL)succeeded
{
    if ([self.quest[PARSE_QUESTS_COMPLETED] boolValue]) {
        acceptBarButtonItem.image = [UIImage imageNamed:@"bt_completed"];
    } else if ([((PFUser*) self.quest[PARSE_QUESTS_ACCEPTED_BY]).objectId isEqualToString:[userDefaults objectForKey:LOGGED_USER_ID]]) {
        acceptBarButtonItem.image = [UIImage imageNamed:@"bt_complete"];
    }
    [userDefaults setObject:[NSDate new] forKey:QUEST_DETAIL_VIEW_CONTROLLER_UPDATE_LIST];
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
