//
//  GameLayer.m
//  cardgame
//
//  Created by Mark Evans on 5/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "MenuLayer.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "Reachability.h"
#import "CreditsLayer.h"

//SET kChipTransition TO 0.2 FOR NORMAL OPERATION
static const int kChipTransition = 8.2;
#define randint(min, max) (arc4random() % ((max + 1) - min)) + min
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds ].size.height - (double)568) < DBL_EPSILON)

#pragma mark - GameLayer

@implementation GameLayer

@synthesize swipeDownRecognizer, swipeUpRecognizer;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

-(void) onExit
{
    [super onExit];
    
    //UNLOAD CACHED SOUNDS
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"coin.mp3"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"wrong.wav"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"end.mp3"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"add_chips.mp3"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"shuffle.mp3"];
    
    //UNLOAD GESTURE RECOGNIZERS
    NSArray *grs = [[[CCDirector sharedDirector] view] gestureRecognizers];
    for (UIGestureRecognizer *gesture in grs){
        if([gesture isKindOfClass:[UIGestureRecognizer class]]){
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:gesture];
        }
    }
}

-(id) init
{
	if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
        
        //LOAD SAVED LOCAL LEADERBOARD DATA
        AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *t = [defaults objectForKey:@"scoresArray"];
        if (t.count > 0){
            scoresArray = [[NSMutableArray alloc]initWithArray:t];
        } else {
            scoresArray = [[NSMutableArray alloc]initWithArray:app.scoresArray];
        }
        
        //WIN SIZE
        size = [[CCDirector sharedDirector] winSize];
        
        //CACHE SOUNDS
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"coin.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"wrong.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"end.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"add_chips.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"shuffle.mp3"];
        
        //MENU BACKGROUND
        if (IS_IPHONE_5) {
            background = [CCSprite spriteWithFile:@"gamebg-568@2x.png"];
        } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            background = [CCSprite spriteWithFile:@"gamebg.png"];
        }
        background.position = ccp(size.width/2, size.height/2);
        [self addChild: background];
        
        //SET ANTE SPOT
        showAnteSpot = [CCSprite spriteWithFile:@"bet.png"];
        if (IS_IPHONE_5) {
            anteSpot = ccp(-2+size.width/2, -88+size.height/2);
        } else {
            anteSpot = ccp(-2+size.width/2, -88+size.height/2);
        }
        [showAnteSpot setPosition:ccp(3+anteSpot.x, anteSpot.y)];
        [self addChild:showAnteSpot];
        
        //SET CARD TYPES
        cardType = [[NSMutableArray alloc]initWithObjects:@"s", @"c", @"d", @"h", nil];
        
        //SET SPRITE SHEETS
        if (IS_IPHONE_5) {
            CCTexture2D *iphone5_tex = [[CCTextureCache sharedTextureCache] addImage:@"customcards.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"customcards_coords.plist" texture:iphone5_tex];
        } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:@"customcards_r.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"customcards_r_coords.plist" texture:tex];
        }
        
        //GAME PREFIXED VALUES
        startOffMoney = 1500;
        realTotal = startOffMoney;
        maxBet = 1000;
        passValue = 0;
        moneyflag = 0;
        
        //CREATE SCORE LABEL
        scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", realTotal] fontName:@"Georgia-Bold" fontSize:20];
        if (IS_IPHONE_5) {
            [scoreLabel setPosition:ccp(-217+size.width/2, -17+size.height/1)];
        } else {
            [scoreLabel setPosition:ccp(-177+size.width/2, -17+size.height/1)];
        }
		[self addChild:scoreLabel z:1];
        [scoreLabel setColor:ccYELLOW];
        
        //SET COIN IMAGE
        CCSprite *coins = [CCSprite spriteWithFile:@"coins.png"];
        if (IS_IPHONE_5) {
            [coins setPosition:ccp(-270+size.width/2, -20+size.height/1)];
        } else {
            [coins setPosition:ccp(-225+size.width/2, -20+size.height/1)];
        }
        [self addChild:coins];
        
        //CREATE BET LABEL
        betLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Bet: %i",passValue] fontName:@"Georgia-Bold" fontSize:18];
        if (IS_IPHONE_5) {
            [betLabel setPosition:ccp(-185+size.width/2, -120+size.height/2)];
        } else {
            [betLabel setPosition:ccp(-130+size.width/2, -120+size.height/2)];
        }
		[self addChild:betLabel z:1];
        [betLabel setColor:ccWHITE];
        
        //CREATE PAUSE BUTTON
        CCMenuItemSprite *pauseImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"pause.png"] selectedSprite:[CCSprite spriteWithFile:@"pause.png"] target:self selector:@selector(pauseMenu)];
        pausemenu = [CCMenu menuWithItems:pauseImage, nil];
        if (IS_IPHONE_5) {
            [pausemenu setPosition:ccp(245+size.width/2, -20+size.height/1)];
        } else {
            [pausemenu setPosition:ccp(215+size.width/2, -20+size.height/1)];
        }
        [self addChild:pausemenu z:1];
        
        //CREATE GAMEPLAY MENU
        CCMenuItemSprite *closeImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"close.png"] selectedSprite:[CCSprite spriteWithFile:@"closeOn.png"] target:self selector:@selector(endGame)];
        CCMenuItemSprite *hi = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"higherButton.png"] selectedSprite:[CCSprite spriteWithFile:@"higherButtonOn.png"] target:self selector:@selector(higher)];
        CCMenuItemSprite *lo = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lowerButton.png"] selectedSprite:[CCSprite spriteWithFile:@"lowerButtonOn.png"] target:self selector:@selector(lower)];
        CCMenuItemSprite *clear = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"clear.png"] selectedSprite:[CCSprite spriteWithFile:@"clearOn.png"] target:self selector:@selector(resetBet)];
        menu = [CCMenu menuWithItems:closeImage, hi, lo, clear, nil];
        if (IS_IPHONE_5) {
            [menu setPosition:ccp(-68+size.width/1, size.height/2)];
        } else {
            [menu setPosition:ccp(-55+size.width/1, size.height/2)];
        }
        [menu alignItemsVerticallyWithPadding:20.0];
        [self addChild:menu z:1];
        
        //CREATE COIN MENU
        CCMenuItemSprite *five = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"chip5.png"] selectedSprite:[CCSprite spriteWithFile:@"chip5.png"] target:self selector:@selector(runFive)];
        CCMenuItemSprite *twentyfive = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"chip25.png"] selectedSprite:[CCSprite spriteWithFile:@"chip25.png"] target:self selector:@selector(runTwentyFive)];
        CCMenuItemSprite *onehundred = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"chip100.png"] selectedSprite:[CCSprite spriteWithFile:@"chip100.png"] target:self selector:@selector(runOneHundred)];
        coin_menu = [CCMenu menuWithItems:onehundred, twentyfive, five, nil];
        if (IS_IPHONE_5) {
            [coin_menu setPosition:ccp(-225+size.width/2, -40+size.height/2)];
        } else {
            [coin_menu setPosition:ccp(-195+size.width/2, -60+size.height/2)];
        }
        [coin_menu alignItemsVerticallyWithPadding:2.0];
        [self addChild:coin_menu z:1];
        
        [self randomCards];
        soundFlag = FALSE;
        pauseFlag = FALSE;
        [self schedule:@selector(update:)];
        [self schedule:@selector(collision:)];
	}
	return self;
}

-(void)pauseMenu
{
    //ADD PAUSE BG
    if (IS_IPHONE_5) {
        pausebg = [CCSprite spriteWithFile:@"pausebg-568@2x.png"];
        [pausebg setPosition:ccp(size.width/2, size.height/2)];
        [self addChild:pausebg];
        [pausebg setVisible:TRUE];
    } else {
        pausebg = [CCSprite spriteWithFile:@"pausebg.png"];
        [pausebg setPosition:ccp(size.width/2, size.height/2)];
        [self addChild:pausebg];
        [pausebg setVisible:TRUE];
    }
    
    [self removeChild:pausemenu cleanup:TRUE];
    //ADD RESUME MENU
    CCMenuItemSprite *resumeImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"resume.png"] selectedSprite:[CCSprite spriteWithFile:@"resume.png"] target:self selector:@selector(resumePlayCall)];
    resumemenu = [CCMenu menuWithItems:resumeImage, nil];
    if (IS_IPHONE_5) {
        [resumemenu setPosition:ccp(245+size.width/2, -20+size.height/1)];
    } else {
        [resumemenu setPosition:ccp(215+size.width/2, -20+size.height/1)];
    }
    [self addChild:resumemenu z:1];
    
    pauseFlag = TRUE;
    coin_menu.isTouchEnabled = FALSE;
    menu.isTouchEnabled = FALSE;
}

-(void)removePauseMenuBg
{
    [pausebg setVisible:FALSE];
    pauseFlag = FALSE;
    coin_menu.isTouchEnabled = TRUE;
    menu.isTouchEnabled = TRUE;
    [[CCDirector sharedDirector] resume];
}

-(void)resumePlayCall
{
    pauseFlag = FALSE;
    coin_menu.isTouchEnabled = TRUE;
    menu.isTouchEnabled = TRUE;
    [[CCDirector sharedDirector] resume];
    [self resumeMenu];
}

-(void)resumeMenu
{
    [pausebg runAction:[CCSequence actionOne:[CCFadeOut actionWithDuration:1.0] two:[CCCallFunc actionWithTarget:self selector:@selector(removePauseMenuBg)]]];
    [self removeChild:resumemenu cleanup:TRUE];
    //ADD PAUSE BUTTON
    CCMenuItemSprite *pauseImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"pause.png"] selectedSprite:[CCSprite spriteWithFile:@"pause.png"] target:self selector:@selector(pauseMenu)];
    pausemenu = [CCMenu menuWithItems:pauseImage, nil];
    if (IS_IPHONE_5) {
        [pausemenu setPosition:ccp(245+size.width/2, -20+size.height/1)];
    } else {
        [pausemenu setPosition:ccp(215+size.width/2, -20+size.height/1)];
    }
    [self addChild:pausemenu z:1];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)onEnterTransitionDidFinish
{
    CCTouchDispatcher *ccTouchDispatcher =[[CCTouchDispatcher alloc]init];
    [ccTouchDispatcher addStandardDelegate:self priority:0];
    
    _swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp)];
    _swipeUpRecognizer.delegate = self;
    _swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [[CCDirector sharedDirector].view addGestureRecognizer:_swipeUpRecognizer];
    
    _swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown)];
    _swipeDownRecognizer.delegate = self;
    _swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[CCDirector sharedDirector].view addGestureRecognizer:_swipeDownRecognizer];
}

-(void)handleSwipeUp
{
    [self higher];
    //NSLog(@"SWIPED UP -- Higher");
}

-(void)handleSwipeDown
{
    [self lower];
     //NSLog(@"SWIPED DOWN -- Lower");
}

-(void)removeSprite:(CCSprite*)sprite
{
    [sprite setPosition:CGPointMake(-1000, -1000)];
}

- (void)resetBet
{
    tempTotal = realTotal + passValue;
    realTotal = tempTotal;
    [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
    passValue = 0;
    [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
    showAnte = [CCSprite spriteWithFile:@"bet.png"];
    [showAnte setPosition:ccp(3+anteSpot.x, anteSpot.y)];
    [self addChild:showAnte];
}

-(void)update:(ccTime)delta
{
    //DETECT PAUSE FLAG
    if (pauseFlag == TRUE)
    {
        coin_menu.isTouchEnabled = FALSE;
        menu.isTouchEnabled = FALSE;
        [[CCDirector sharedDirector] pause];
    } else {
        [[CCDirector sharedDirector] resume];
    }
}

-(void)collision:(ccTime)delta
{
    //UNSCHEDULE FUNCTION
    if (soundFlag == TRUE)
    {
        [self unschedule:@selector(collision:)];
    }
    
    //COLLISION DETECTION
    if (CGRectIntersectsRect(showAnteSpot.boundingBox, showAnte.boundingBox))
    {
        //NSLog(@"TOUCHED ON ANTE SPOT");
        [[SimpleAudioEngine sharedEngine] playEffect:@"add_chips.mp3"];
        soundFlag = TRUE;
    }
}

- (void)runFive
{
    hChip = [CCSprite spriteWithFile:@"chip_h.png"];
    if (IS_IPHONE_5) {
        [hChip setPosition:ccp(-226+size.width/2, -81+size.height/2)];
    } else {
        [hChip setPosition:ccp(-196+size.width/2, -101+size.height/2)];
    }
    [self addChild:hChip];
    moneyflag = 1;
    [self performSelector:@selector(removeHchip:) withObject:hChip afterDelay:2];
}

- (void)runTwentyFive
{
    hChip = [CCSprite spriteWithFile:@"chip_h.png"];
    if (IS_IPHONE_5) {
        [hChip setPosition:ccp(-226+size.width/2, -39+size.height/2)];
    } else {
        [hChip setPosition:ccp(-196+size.width/2, -59+size.height/2)];
    }
    [self addChild:hChip];
    moneyflag = 2;
    [self performSelector:@selector(removeHchip:) withObject:hChip afterDelay:2];
}

- (void)runOneHundred
{
    hChip = [CCSprite spriteWithFile:@"chip_h.png"];
    if (IS_IPHONE_5) {
        [hChip setPosition:ccp(-226+size.width/2, 3+size.height/2)];
    } else {
        [hChip setPosition:ccp(-196+size.width/2, -17+size.height/2)];
    }
    [self addChild:hChip];
    moneyflag = 3;
    [self performSelector:@selector(removeHchip:) withObject:hChip afterDelay:2];
}

- (void)removeHchip:(CCSprite *)sprite

{
    if (sprite != nil){
        [sprite removeFromParentAndCleanup:true];
    }
}

- (void)callFive
{
    int ante = 5;
    if (passValue == 0)
    {
        passValue = ante;
    } else if (passValue > 0)
    {
        passValue = passValue + ante;
    } else {
        passValue = ante;
    }
    
    if (passValue <= maxBet){
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else if (passValue == maxBet){
        passValue = 1000;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else {
        //NSLog(@"MAX BET REACHED");
        passValue = 1000;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MAX BET REACHED" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }

    if (realTotal < passValue) {
        //NSLog(@"CAN NOT ADD BET");
        passValue = 0;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
        showAnteSpot = [CCSprite spriteWithFile:@"bet.png"];
        [showAnteSpot setPosition:ccp(3+anteSpot.x, anteSpot.y)];
        [self addChild:showAnteSpot];
    } else {
        showAnte = [CCSprite spriteWithFile:@"chip5.png"];
        if (IS_IPHONE_5) {
            [showAnte setPosition:ccp(-225+size.width/2, -70+size.height/2)];
        } else {
            [showAnte setPosition:ccp(-195+size.width/2, -90+size.height/2)];
        }
        [betLabel runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:.2 scale:1.2] two:[CCScaleTo actionWithDuration:.3 scale:1]]];
        [showAnte runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:kChipTransition position:ccp(anteSpot.x+1, anteSpot.y+1)] two:[CCRotateBy actionWithDuration:.5 angle:360]]];
        [self addChild:showAnte];
    }
}

- (void)callTwentyFive
{
    int ante = 25;
    if (passValue == 0)
    {
        passValue = ante;
    } else if (passValue > 0)
    {
        passValue = passValue + ante;
    } else {
        passValue = ante;
    }
    
    if (passValue <= maxBet){
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else if (passValue == maxBet){
        passValue = 1000;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else {
        //NSLog(@"MAX BET REACHED");
        passValue = 1000;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MAX BET REACHED" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if (realTotal < passValue) {
        //NSLog(@"CAN NOT ADD BET");
        passValue = 0;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
        showAnteSpot = [CCSprite spriteWithFile:@"bet.png"];
        [showAnteSpot setPosition:ccp(3+anteSpot.x, anteSpot.y)];
        [self addChild:showAnteSpot];
    } else {
        showAnte = [CCSprite spriteWithFile:@"chip25.png"];
        if (IS_IPHONE_5) {
            [showAnte setPosition:ccp(-225+size.width/2, -40+size.height/2)];
        } else {
            [showAnte setPosition:ccp(-195+size.width/2, -60+size.height/2)];
        }
        [betLabel runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:.2 scale:1.2] two:[CCScaleTo actionWithDuration:.3 scale:1]]];
        [showAnte runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:kChipTransition position:ccp(anteSpot.x+1, anteSpot.y+1)] two:[CCRotateBy actionWithDuration:.5 angle:360]]];
        [self addChild:showAnte];
    }
}

- (void)callOneHundred
{
    int ante = 100;
    if (passValue == 0)
    {
        passValue = ante;
    } else if (passValue > 0)
    {
        passValue = passValue + ante;
    } else {
        passValue = ante;
    }
    
    if (passValue <= maxBet){
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else if (passValue == maxBet){
        passValue = 1000;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else {
        //NSLog(@"MAX BET REACHED");
        passValue = 1000;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MAX BET REACHED" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if (realTotal < passValue) {
        //NSLog(@"CAN NOT ADD BET");
        passValue = 0;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
        showAnteSpot = [CCSprite spriteWithFile:@"bet.png"];
        [showAnteSpot setPosition:ccp(3+anteSpot.x, anteSpot.y)];
        [self addChild:showAnteSpot];
    } else {
        showAnte = [CCSprite spriteWithFile:@"chip100.png"];
        if (IS_IPHONE_5) {
            [showAnte setPosition:ccp(-225+size.width/2, -10+size.height/2)];
        } else {
            [showAnte setPosition:ccp(-195+size.width/2, -30+size.height/2)];
        }
        [betLabel runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:.2 scale:1.2] two:[CCScaleTo actionWithDuration:.3 scale:1]]];
        [showAnte runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:kChipTransition position:ccp(anteSpot.x+1, anteSpot.y+1)] two:[CCRotateBy actionWithDuration:.5 angle:360]]];
        [self addChild:showAnte];
    }
}

- (void)reportScore
{
    [[GCHelper sharedInstance] reportScore:realTotal forLeaderboardID:@"highscore"];
}

- (void)endGame
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (realTotal > 0)
    {
        [self reportScore];
        NSNumber *n = [[NSNumber alloc]initWithInt:realTotal];
        [scoresArray addObject:n];
        [defaults setObject:scoresArray forKey:@"scoresArray"];
        [defaults synchronize];
    }
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccWHITE]];
}

- (void)addPoints:(int)pass
{
    if (pass == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MUST PLACE BET" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        realTotal = realTotal + pass;
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
    }
    
    if (realTotal >= 5000)
    {
        //NSLog(@"WINNER - GAME OVER");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WINNER" message:@"YOU WON!" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccWHITE]];
    }
}

- (void)removePoints:(int)pass
{
    if (pass == 0)
    {
        //NSLog(@"PRE GAME OVER");
    } else {
        realTotal = realTotal - pass;
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
    }
    if (realTotal <= 0)
    {
        //NSLog(@"GAME OVER");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"LOSER" message:@"GAME OVER!" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)drawPoints
{
    realTotal = realTotal + 0;
    [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
}

-(void)randomCards
{
    //GET RANDOM CARD VALUE
    int r1 = randint(1, 13);
    playerInt = r1;
    
    //GET RANDOM CARD TYPE
    int random = randint(0, 3);
    NSString *card = [[NSString alloc]initWithFormat:@"%@%d.psd",[cardType objectAtIndex:random],r1];
    
    CCSprite *dealerCard = [CCSprite spriteWithSpriteFrameName:card];
    if (IS_IPHONE_5) {
        dealerCard.position = ccp(-67+size.width/2, 50+size.height/2);
    } else {
        dealerCard.position = ccp(-70+size.width/2, 48+size.height/2);
    }
    [self addChild:dealerCard];
    
    CCSprite *playerCard = [CCSprite spriteWithSpriteFrameName:@"back.psd"];
    if (IS_IPHONE_5) {
         playerCard.position = ccp(73+size.width/2, 50+size.height/2);
    } else {
        playerCard.position = ccp(70+size.width/2, 48+size.height/2);
    }
    [self addChild:playerCard];
    [playerCard runAction:[CCRotateBy actionWithDuration:.4 angle:360]];
    [[SimpleAudioEngine sharedEngine] playEffect:@"shuffle.mp3"];
}

- (void)higher
{
    if (passValue <= 0){
        //NSLog(@"PLEASE PLACE BET");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"PLEASE PLACE BET" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        //GET RANDOM CARD VALUE
        int r2 = randint(1, 13);
        dealerInt = r2;
        
        //GET RANDOM CARD TYPE
        int random = randint(0, 3);
        NSString *card = [[NSString alloc]initWithFormat:@"%@%d.psd",[cardType objectAtIndex:random],r2];
        
        CCSprite *playerCard =[CCSprite spriteWithSpriteFrameName:card];
        if (IS_IPHONE_5) {
            playerCard.position = ccp(73+size.width/2, 50+size.height/2);
        } else {
            playerCard.position = ccp(70+size.width/2, 48+size.height/2);
        }
        [self addChild:playerCard];
        
        if (dealerInt == playerInt) {
            //NSLog(@"DRAW");
            //[self drawPoints];
            [[SimpleAudioEngine sharedEngine] playEffect:@"wrong.mp3"];
        } else if (dealerInt > playerInt) {
            //NSLog(@"PLAYER WINS");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
            
            //FEEDBACK ADD
            feedback_add = [CCSprite spriteWithFile:@"feedback_add.png"];
            [feedback_add setScale:.11];
            if (IS_IPHONE_5) {
                [feedback_add setPosition:ccp(-185+size.width/2, 131+size.height/2)];
            } else {
                [feedback_add setPosition:ccp(-145+size.width/2, 131+size.height/2)];
            }
            [self addChild:feedback_add];
            [scoreLabel runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:.2 scale:1.2] two:[CCScaleTo actionWithDuration:.3 scale:1]]];
            [feedback_add runAction:[CCJumpTo actionWithDuration:.4 position:ccp(-10, 270) height:1 jumps:2]];
            [self performSelector:@selector(removeHchip:) withObject:feedback_add afterDelay:2];
        } else if (playerInt > dealerInt) {
            //NSLog(@"DEALER WINS");
            [self removePoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"wrong.wav"];
            
            //FEEDBACK MINUS
            feedback_minus = [CCSprite spriteWithFile:@"feedback_minus.png"];
            [feedback_minus setScale:.11];
            if (IS_IPHONE_5) {
                [feedback_minus setPosition:ccp(-185+size.width/2, 131+size.height/2)];
            } else {
                [feedback_minus setPosition:ccp(-145+size.width/2, 131+size.height/2)];
            }
            [self addChild:feedback_minus];
            [scoreLabel runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:.2 scale:1.2] two:[CCScaleTo actionWithDuration:.3 scale:1]]];
            [feedback_minus runAction:[CCJumpTo actionWithDuration:.4 position:ccp(-10, 270) height:1 jumps:2]];
            [self performSelector:@selector(removeHchip:) withObject:feedback_minus afterDelay:2];
        } else {
            //NSLog(@"WEIRD");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        }
        //RESET
        [self scheduleOnce:@selector(reset) delay:2];
    }
}

- (void)lower
{
    if (passValue <= 0){
        //NSLog(@"PLEASE PLACE BET");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"PLEASE PLACE BET" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        //GET RANDOM CARD VALUE
        int r2 = randint(1, 13);
        dealerInt = r2;
        
        //GET RANDOM CARD TYPE
        int random = randint(0, 3);
        NSString *card = [[NSString alloc]initWithFormat:@"%@%d.psd",[cardType objectAtIndex:random],r2];
        
        CCSprite *playerCard =[CCSprite spriteWithSpriteFrameName:card];
        if (IS_IPHONE_5) {
            playerCard.position = ccp(73+size.width/2, 50+size.height/2);
        } else {
            playerCard.position = ccp(70+size.width/2, 48+size.height/2);
        }
        [self addChild:playerCard];
        if (dealerInt == playerInt) {
            //NSLog(@"DRAW");
            //[self drawPoints];
            [[SimpleAudioEngine sharedEngine] playEffect:@"wrong.mp3"];
        } else if (dealerInt < playerInt) {
            //NSLog(@"PLAYER WINS");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
            
            //FEEDBACK ADD
            feedback_add = [CCSprite spriteWithFile:@"feedback_add.png"];
            [feedback_add setScale:.11];
            if (IS_IPHONE_5) {
                [feedback_add setPosition:ccp(-185+size.width/2, 131+size.height/2)];
            } else {
                [feedback_add setPosition:ccp(-145+size.width/2, 131+size.height/2)];
            }
            [self addChild:feedback_add];
            [scoreLabel runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:.2 scale:1.2] two:[CCScaleTo actionWithDuration:.3 scale:1]]];
            [feedback_add runAction:[CCJumpTo actionWithDuration:.4 position:ccp(-10, 270) height:1 jumps:2]];
            [self performSelector:@selector(removeHchip:) withObject:feedback_add afterDelay:2];
        } else if (playerInt < dealerInt) {
            //NSLog(@"DEALER WINS");
            [self removePoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"wrong.wav"];
            
            //FEEDBACK MINUS
            feedback_minus = [CCSprite spriteWithFile:@"feedback_minus.png"];
            [feedback_minus setScale:.11];
            if (IS_IPHONE_5) {
                [feedback_minus setPosition:ccp(-185+size.width/2, 131+size.height/2)];
            } else {
                [feedback_minus setPosition:ccp(-145+size.width/2, 131+size.height/2)];
            }
            [self addChild:feedback_minus];
            [scoreLabel runAction:[CCSequence actionOne:[CCScaleBy actionWithDuration:.2 scale:1.2] two:[CCScaleTo actionWithDuration:.3 scale:1]]];
            [feedback_minus runAction:[CCJumpTo actionWithDuration:.4 position:ccp(-10, 270) height:1 jumps:2]];
            [self performSelector:@selector(removeHchip:) withObject:feedback_minus afterDelay:2];
        } else {
            //NSLog(@"WEIRD");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        }
        //RESET
        [self scheduleOnce:@selector(reset) delay:2];
    }
}

- (void)reset
{
    playerInt = 0;
    dealerInt = 0;
    
    CCSprite *dealerCard = [CCSprite spriteWithSpriteFrameName:@"back.psd"];
    if (IS_IPHONE_5) {
        dealerCard.position = ccp(-67+size.width/2, 50+size.height/2);
    } else {
        dealerCard.position = ccp(-70+size.width/2, 48+size.height/2);
    }
    [self addChild:dealerCard];
    
    CCSprite *playerCard = [CCSprite spriteWithSpriteFrameName:@"back.psd"];
    if (IS_IPHONE_5) {
        playerCard.position = ccp(73+size.width/2, 50+size.height/2);
    } else {
        playerCard.position = ccp(70+size.width/2, 48+size.height/2);
    }
    [self addChild:playerCard];
    
    [self randomCards];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in [event allTouches])
    {
        location = [touch locationInView:touch.view];
        location = [[CCDirector sharedDirector]convertToGL:location];
        
        if (pausebg != nil){
            if (CGRectContainsPoint(pausebg.boundingBox, location)){
                pauseFlag = FALSE;
                coin_menu.isTouchEnabled = TRUE;
                menu.isTouchEnabled = TRUE;
                [[CCDirector sharedDirector] resume];
                [self resumeMenu];
            }
        }
        
        //TOUCH POINT -- ANTE SPOT
        if (showAnteSpot != nil) {
            CGRect showAnteRect = CGRectMake(showAnteSpot.boundingBox.origin.x, showAnteSpot.boundingBox.origin.y, showAnteSpot.boundingBox.size.width, showAnteSpot.boundingBox.size.height);
            
            CGRect *checkForAnte = CGRectContainsPoint(showAnteRect,location);
            if (checkForAnte)
            {
                if (moneyflag == 0)
                {
                    //NSLog(@"FLAG NOT SET");
                } else if (moneyflag == 1) {
                    [self callFive];
                    soundFlag = FALSE;
                    [self schedule:@selector(collision:)];
                    //NSLog(@"COLLISION OCCURED -- CALL FIVE FUNCTION");
                } else if (moneyflag == 2) {
                    [self callTwentyFive];
                    soundFlag = FALSE;
                    [self schedule:@selector(collision:)];
                    //NSLog(@"COLLISION OCCURED -- CALL TWENTY FIVE FUNCTION");
                } else if (moneyflag == 3) {
                    [self callOneHundred];
                    soundFlag = FALSE;
                    [self schedule:@selector(collision:)];
                    //NSLog(@"COLLISION OCCURED -- CALL ONE HUNDRED FUNCTION");
                } else {
                    //NSLog(@"FLAG NOT SET PROPERLY: x:%f, y:%f", location.x, location.y);
                }
            } else {
                //NSLog(@"TOUCHED OUTSIDE OF ANTE SPOT - NO COLLISION");
            }
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //TOUCHES END FUNCTION
}

- (void) dealloc
{
	[super dealloc];
}

@end
