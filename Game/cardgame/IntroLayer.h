//
//  IntroLayer.h
//  cardgame
//
//  Created by Mark Evans on 5/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"

@interface IntroLayer : CCLayer
{
    CCSprite *background;
    CCSpriteBatchNode *spriteSheet;
}

+(CCScene *) scene;

@end
