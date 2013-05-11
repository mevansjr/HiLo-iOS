//
//  CCUIViewWrapper.h
//  cardgame
//
//  Created by Mark Evans on 5/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCUIViewWrapper : CCSprite
{
	UIView *uiItem;
	float rotation;
}

@property (nonatomic, retain) UIView *uiItem;

+ (id) wrapperForUIView:(UIView*)ui;
- (id) initForUIView:(UIView*)ui;

- (void) updateUIViewTransform;

@end
