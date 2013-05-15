//
//  GameLayer.h
//  cardgame
//
//  Created by Mark Evans on 5/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface GameLayer : CCLayer <CCStandardTouchDelegate, UIGestureRecognizerDelegate>
{
    CGSize size;
    int dealerInt;
    int playerInt;
    int startOffMoney;
    int tempTotal;
    int realTotal;
    int passValue;
    int maxBet;
    int moneyflag;
    CCSprite *background;
    CGPoint anteSpot;
    CCSprite *selSprite;
    CGPoint location;
    NSMutableArray *cardType;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *scoreLabels;
    CCLabelTTF *betLabel;
    CCLabelTTF *betLabels;
    CCSprite *showAnte;
    CCSprite *showAnteSpot;
    UISwipeGestureRecognizer * _swipeUpRecognizer;
    UISwipeGestureRecognizer * _swipeDownRecognizer;
}
@property (retain) UISwipeGestureRecognizer * swipeUpRecognizer;
@property (retain) UISwipeGestureRecognizer * swipeDownRecognizer;
+(CCScene *) scene;
-(void)update:(ccTime)delta;

@end
