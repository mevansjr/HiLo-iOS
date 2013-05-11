//
//  MenuLayer.h
//  Game
//
//  Created by Mark Evans on 5/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCHelper.h"

@interface MenuLayer : CCLayer <CCStandardTouchDelegate, GCHelperDelegate>
{
    CCSprite *_bg1;
    CCSprite *_bg2;
}
+(CCScene *) scene;
-(void)update:(ccTime)delta;

@end
