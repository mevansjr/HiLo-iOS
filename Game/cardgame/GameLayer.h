//
//  GameLayer.h
//  cardgame
//
//  Created by Mark Evans on 5/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "GCHelper.h"

@interface GameLayer : CCLayer <CCStandardTouchDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
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
    int getTotal;
    int getBet;
    int rebetInt;
    BOOL soundFlag;
    BOOL pauseFlag;
    BOOL firstClearFlag;
    BOOL gameplayFlag;
    NSString* feedbackFlag;
    CCSprite *background;
    CCSprite *feedback_minus;
    CCSprite *feedback_add;
    CGPoint anteSpot;
    CCSprite *selSprite;
    CCSprite *rebet;
    CGPoint location;
    NSMutableArray *cardType;
    CCMenu *pausemenu;
    CCMenu *resumemenu;
    CCMenu *coin_menu;
    CCMenu *menu;
    CCMenuItemSprite *clear;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *scoreLabels;
    CCLabelTTF *betLabel;
    CCLabelTTF *betLabels;
    CCSprite *showAnte;
    CCSprite *showAnteSpot;
    CCSprite *hChip;
    CCSprite *pausebg;
    NSUserDefaults *defaults;
    NSMutableArray *scoresArray;
    UISwipeGestureRecognizer * _swipeUpRecognizer;
    UISwipeGestureRecognizer * _swipeDownRecognizer;
}
@property (retain) UISwipeGestureRecognizer * swipeUpRecognizer;
@property (retain) UISwipeGestureRecognizer * swipeDownRecognizer;
+(CCScene *) scene;
-(void)update:(ccTime)delta;
-(void)collision:(ccTime)delta;

@end
