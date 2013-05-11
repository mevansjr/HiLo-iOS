//
//  AppDelegate.h
//  cardgame
//
//  Created by Mark Evans on 5/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class RootViewController;
@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
    RootViewController	*viewController;
	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) RootViewController *viewController;

@end