//
//  GameLayer.h
//  cardgame
//
//  Created by Mark Evans on 5/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface GameLayer : CCLayer
{
    int dealerInt;
    int playerInt;
    int scoreInt;
    int passValue;
    int maxBet;
    CGPoint anteSpot;
    NSMutableArray *cardType;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *scoreLabels;
    CCLabelTTF *betLabel;
    CCLabelTTF *betLabels;
    CCSprite *showAnte;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
