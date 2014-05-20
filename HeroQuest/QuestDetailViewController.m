//
//  QuestDetailViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/14/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "QuestDetailViewController.h"

@interface QuestDetailViewController ()
{
    IBOutlet UILabel *questTitleLabel;
    IBOutlet UILabel *questAuthorLabel;
    IBOutlet UITextView *questDescriptionTextView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *portraitView;
    IBOutlet UIView *landscapeView;
    UIView *currentView;
}

@end

@implementation QuestDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    questTitleLabel.text = self.questDetailDictionary[TITLE];
    questAuthorLabel.text = self.questDetailDictionary[GIVER];
    questDescriptionTextView.text = self.questDetailDictionary[DESCRIPTION];
    
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
