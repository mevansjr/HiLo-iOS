//
//  CreditsLayer.h
//  hilo
//
//  Created by Mark Evans on 5/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CreditsLayer : CCLayer
{
    CCSprite *background;
    CCSpriteBatchNode *spriteSheet;
}
+(CCScene *) scene;

@end
