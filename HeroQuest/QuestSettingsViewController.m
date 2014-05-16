//
//  QuestSettingsViewController.m
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/15/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import "QuestSettingsViewController.h"

@interface QuestSettingsViewController ()
{
    
    IBOutlet UIView *topLayerView;
    IBOutlet UINavigationBar *navigationBar;
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
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
