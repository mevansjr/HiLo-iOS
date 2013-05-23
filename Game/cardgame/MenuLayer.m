//
//  MenuLayer.m
//  Game
//
//  Created by Mark Evans on 5/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MenuLayer.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "LeaderBoardViewController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "CreditsLayer.h"

static const int kScrollSpeed = 2;
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds ].size.height - (double)568) < DBL_EPSILON)

@implementation MenuLayer

+(CCScene *)scene
{
	CCScene *scene = [CCScene node];
	MenuLayer *layer = [MenuLayer node];
	[scene addChild: layer];
	return scene;
}

-(void) onEnter
{
    [super onEnter];
    
    scoresArray = [[NSArray alloc]init];
    
    //LOAD BACKGROUND MUSIC
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"musicloop.wav" loop:YES];
}

-(void) onExit
{
    [super onExit];
    
    //UNLOAD BACKGROUND MUSIC
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

-(id)init
{
	if( (self=[super init]) )
    {
        self.isTouchEnabled = YES;
        
        //GAME KIT -- RETRIEVE TOP TEN FOR LEADERBOARD
        //[[GCHelper sharedInstance] retrieveTopTenScores];
        
        //SET USER NAME
        AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
        app.playerName = [[UIDevice currentDevice] name];
        
        //WIN SIZE
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //SCROLLING BACKGROUND -- MENU
        if (IS_IPHONE_5) {
            _bg1 = [CCSprite spriteWithFile:@"newmenubg568@2x.png"];
            _bg1.position = CGPointMake(0, size.height * 0.5f);
            _bg1.anchorPoint = CGPointMake(0, 0.5f);
            [self addChild:_bg1];
            _bg2 = [CCSprite spriteWithFile:@"newmenubg568@2x.png"];
            _bg2.position = CGPointMake(_bg2.contentSize.width, _bg1.position.y);
            _bg2.anchorPoint = CGPointMake(0, 0.5f);
            [self addChild:_bg2];
            CCSprite *logo = [CCSprite spriteWithFile:@"hilo-logo@2x.png"];
            [logo setPosition:ccp(-125+size.width/2, -65+size.height/1)];
            [self addChild:logo];
            CCSprite *menu = [CCSprite spriteWithFile:@"menu568@2x.png"];
            [menu setPosition:ccp(150+size.width/2, size.height/2)];
            [self addChild:menu];
        } else {
            _bg1 = [CCSprite spriteWithFile:@"newmenubg.png"];
            _bg1.position = CGPointMake(0, size.height * 0.5f);
            _bg1.anchorPoint = CGPointMake(0, 0.5f);
            [self addChild:_bg1];
            _bg2 = [CCSprite spriteWithFile:@"newmenubg.png"];
            _bg2.position = CGPointMake(_bg2.contentSize.width, _bg1.position.y);
            _bg2.anchorPoint = CGPointMake(0, 0.5f);
            [self addChild:_bg2];
            CCSprite *logo = [CCSprite spriteWithFile:@"hilo-logo.png"];
            [logo setPosition:ccp(-105+size.width/2, -65+size.height/1)];
            [self addChild:logo];
            CCSprite *menu = [CCSprite spriteWithFile:@"menu.png"];
            [menu setPosition:ccp(130+size.width/2, size.height/2)];
            [self addChild:menu];
        }
        
        //CREATE BUTTONS
        CCMenuItemSprite *startGameImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"startgame.png"] selectedSprite:[CCSprite spriteWithFile:@"startgameOn.png"] target:self selector:@selector(buttonAction:)];
        CCMenuItemSprite *leaderboardImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"leaderboard.png"] selectedSprite:[CCSprite spriteWithFile:@"leaderboardOn.png"] target:self selector:@selector(leaderBoardAction:)];
        CCMenuItemSprite *howToImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"howto.png"] selectedSprite:[CCSprite spriteWithFile:@"howtoOn.png"] target:self selector:@selector(howToAction:)];
        CCMenuItemSprite *settingsImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"credits.png"] selectedSprite:[CCSprite spriteWithFile:@"creditsOn.png"] target:self selector:@selector(gameCredits)];
        
        //CREATE MENU
        if (IS_IPHONE_5) {
            CCMenu *myMenu = [CCMenu menuWithItems:startGameImage, leaderboardImage, howToImage, settingsImage, nil];
            [myMenu setPosition:ccp(167 + size.width/2, -52 + size.height/2)];
            [myMenu alignItemsVerticallyWithPadding:3.0];
            [self addChild:myMenu z:1];
        } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CCMenu *myMenu = [CCMenu menuWithItems:startGameImage, leaderboardImage, howToImage, settingsImage, nil];
            [myMenu setPosition:ccp(143 + size.width/2, -45 + size.height/2)];
            [myMenu alignItemsVerticallyWithPadding:3.0];
            [self addChild:myMenu z:1];
        }
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)howToAction:(id)sender
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[GCHelper sharedInstance] playTutorial];
}

- (void)gameCredits
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[CreditsLayer scene] withColor:ccWHITE]];

}

-(void)update:(ccTime)delta
{
	CGPoint bg1Pos = _bg1.position;
	CGPoint bg2Pos = _bg2.position;
	bg1Pos.x -= kScrollSpeed;
	bg2Pos.x -= kScrollSpeed;
    
	// move scrolling background back from left to right end to achieve "endless" scrolling
	if (bg1Pos.x < -(_bg1.contentSize.width))
	{
		bg1Pos.x += _bg1.contentSize.width;
		bg2Pos.x += _bg2.contentSize.width;
	}
    
	// remove any inaccuracies by assigning only int values (this prevents floating point rounding errors accumulating over time)
	bg1Pos.x = (int)bg1Pos.x;
	bg2Pos.x = (int)bg2Pos.x;
	_bg1.position = bg1Pos;
	_bg2.position = bg2Pos;
}

- (void)leaderBoardAction:(id)sender
{
    [[GCHelper sharedInstance] getCustomLeaderBoard];
}

- (void)buttonAction:(id)sender
{
	//REFERENCE BUTTON
	CCMenuItemFont *button = (CCMenuItemFont *)sender;
    
	//SPIN BUTTON AND START GAME
	[button runAction:[CCScaleTo actionWithDuration:2.0 scale:1.2]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] withColor:ccWHITE]];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in [event allTouches])
    {
        //TOUCH LOCATION
        //CGPoint touchLocation = [touch locationInView:touch.view];
        //NSLog(@"TOUCH-> x: %f - y: %f", touchLocation.x, touchLocation.y);
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //
}

-(void)onEnterTransitionDidFinish
{
    CCTouchDispatcher *ccTouchDispatcher =[[CCTouchDispatcher alloc]init];
    [ccTouchDispatcher addStandardDelegate:self priority:0];
}

#pragma mark GCHelperDelegate

- (void)matchStarted {
    //CCLOG(@"Match started");
}

- (void)matchEnded {
    //CCLOG(@"Match ended");
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    //CCLOG(@"Received data");
}

- (void)onLeaderboardViewDismissed
{
    //CCLOG(@"Leaderboard Dismissed");
}

@end
