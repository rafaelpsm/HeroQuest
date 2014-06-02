//
//  QuestPointAnnotation.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/20/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum : NSUInteger {
    GIVER_TYPE,
    QUEST_TYPE
} QuestPointAnnotationType;

@interface QuestPointAnnotation : MKPointAnnotation

@property (nonatomic) QuestPointAnnotationType pointType;
@property (nonatomic) UIImage* image;

@end
