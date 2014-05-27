//
//  Quest.h
//  HeroQuest
//
//  Created by Rafael Paiva Silva on 5/25/14.
//  Copyright (c) 2014 Rafael Paiva Silva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quest : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@end
