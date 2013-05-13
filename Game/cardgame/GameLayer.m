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

#define randint(min, max) (arc4random() % ((max + 1) - min)) + min
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds ].size.height - (double)568) < DBL_EPSILON)

#pragma mark - GameLayer

@implementation GameLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

-(void) onEnter
{
    [super onEnter];
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"musicloop.wav" loop:YES];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"musicloop.wav"];
}

-(id) init
{
	if( (self=[super init]) ) {
        //WIN SIZE
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //MENU BACKGROUND
        CCSprite *background;
        if (IS_IPHONE_5) {
            background = [CCSprite spriteWithFile:@"gamebg-568@2x.png"];
        } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            background = [CCSprite spriteWithFile:@"gamebg.png"];
        }
        background.position = ccp(size.width/2, size.height/2);
        [self addChild: background];
        
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
        
        //START WITH 1000 COINS
        startOffMoney = 1000;
        realTotal = startOffMoney;
        maxBet = 500;
        passValue = 0;
        
        //CREATE SCORE LABEL
        scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", realTotal] fontName:@"Georgia-Bold" fontSize:20];
        if (IS_IPHONE_5) {
            [scoreLabel setPosition:ccp(-225+size.width/2, -17+size.height/1)];
        } else {
            [scoreLabel setPosition:ccp(-185+size.width/2, -17+size.height/1)];
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
        
        //CREATE CLOSE BUTTON
        CCMenuItemSprite *closeImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"close.png"] selectedSprite:[CCSprite spriteWithFile:@"closeOn.png"] target:self selector:@selector(endGame)];
        CCMenu *closemenu = [CCMenu menuWithItems:closeImage, nil];
        if (IS_IPHONE_5) {
            [closemenu setPosition:ccp(220+size.width/2, -25+size.height/1)];
        } else {
            [closemenu setPosition:ccp(190+size.width/2, -25+size.height/1)];
        }
        [self addChild:closemenu z:1];
        
        //CREATE GAMEPLAY MENU
        CCMenuItemSprite *hi = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"higherButton.png"] selectedSprite:[CCSprite spriteWithFile:@"higherButtonOn.png"] target:self selector:@selector(higher:)];
        CCMenuItemSprite *lo = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lowerButton.png"] selectedSprite:[CCSprite spriteWithFile:@"lowerButtonOn.png"] target:self selector:@selector(lower:)];
        CCMenuItemSprite *clear = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"clear.png"] selectedSprite:[CCSprite spriteWithFile:@"clearOn.png"] target:self selector:@selector(resetBet)];
        CCMenu *menu = [CCMenu menuWithItems:hi, lo, clear, nil];
        if (IS_IPHONE_5) {
            [menu setPosition:ccp(-68+size.width/1, size.height/2)];
        } else {
            [menu setPosition:ccp(-55+size.width/1, size.height/2)];
        }
        [menu alignItemsVerticallyWithPadding:20.0];
        [self addChild:menu z:1];
        
        //CREATE COIN MENU
        CCMenuItemSprite *five = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"chip5.png"] selectedSprite:[CCSprite spriteWithFile:@"chip5.png"] target:self selector:@selector(callFive)];
        CCMenuItemSprite *twentyfive = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"chip25.png"] selectedSprite:[CCSprite spriteWithFile:@"chip25.png"] target:self selector:@selector(callTwentyFive)];
        CCMenuItemSprite *onehundred = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"chip100.png"] selectedSprite:[CCSprite spriteWithFile:@"chip100.png"] target:self selector:@selector(callOneHundred)];
        CCMenu *coin_menu = [CCMenu menuWithItems:onehundred, twentyfive, five, nil];
        if (IS_IPHONE_5) {
            [coin_menu setPosition:ccp(-225+size.width/2, -40+size.height/2)];
        } else {
            [coin_menu setPosition:ccp(-195+size.width/2, -60+size.height/2)];
        }
        [coin_menu alignItemsVerticallyWithPadding:2.0];
        [self addChild:coin_menu z:1];
        
        //ANTE SPOT
        if (IS_IPHONE_5) {
            anteSpot = ccp(-2+size.width/2, -88+size.height/2);
        } else {
            anteSpot = ccp(-2+size.width/2, -88+size.height/2);
        }
        
        [self randomCards];
	}
	return self;
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
        NSLog(@"%i",passValue);
    }
    
    if (passValue <= maxBet){
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else if (passValue == maxBet){
        passValue = 500;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else {
        NSLog(@"MAX BET REACHED");
        passValue = 500;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MAX BET REACHED" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }

    if (realTotal < passValue) {
        NSLog(@"CAN NOT ADD BET");
        passValue = 0;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
        showAnte = [CCSprite spriteWithFile:@"bet.png"];
        [showAnte setPosition:ccp(3+anteSpot.x, anteSpot.y)];
        [self addChild:showAnte];
    } else {
        showAnte = [CCSprite spriteWithFile:@"chip5.png"];
        [showAnte setPosition:ccp(anteSpot.x+1, anteSpot.y+1)];
        [self addChild:showAnte];
        [showAnte runAction:[CCRotateBy actionWithDuration:.5 angle:360]];
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
        NSLog(@"%i",passValue);
    }
    
    if (passValue <= maxBet){
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else if (passValue == maxBet){
        passValue = 500;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else {
        NSLog(@"MAX BET REACHED");
        passValue = 500;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MAX BET REACHED" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if (realTotal < passValue) {
        NSLog(@"CAN NOT ADD BET");
        passValue = 0;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
        showAnte = [CCSprite spriteWithFile:@"bet.png"];
        [showAnte setPosition:ccp(3+anteSpot.x, anteSpot.y)];
        [self addChild:showAnte];
    } else {
        showAnte = [CCSprite spriteWithFile:@"chip25.png"];
        [showAnte setPosition:ccp(anteSpot.x+1, anteSpot.y+1)];
        [self addChild:showAnte];
        [showAnte runAction:[CCRotateBy actionWithDuration:.5 angle:360]];
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
        NSLog(@"%i",passValue);
    }
    
    if (passValue <= maxBet){
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else if (passValue == maxBet){
        passValue = 500;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
    } else {
        NSLog(@"MAX BET REACHED");
        passValue = 500;
        tempTotal = realTotal - passValue;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", tempTotal]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MAX BET REACHED" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if (realTotal < passValue) {
        NSLog(@"CAN NOT ADD BET");
        passValue = 0;
        [betLabel setString:[NSString stringWithFormat:@"Bet: %i", passValue]];
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
        showAnte = [CCSprite spriteWithFile:@"bet.png"];
        [showAnte setPosition:ccp(3+anteSpot.x, anteSpot.y)];
        [self addChild:showAnte];
    } else {
        showAnte = [CCSprite spriteWithFile:@"chip100.png"];
        [showAnte runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:1.0 position:ccp(anteSpot.x+1, anteSpot.y+1)] two:[CCMoveBy actionWithDuration:1.0 position:ccp(0, 0)]]];
        //[showAnte setPosition:ccp(anteSpot.x+1, anteSpot.y+1)];
        [self addChild:showAnte];
        [showAnte runAction:[CCRotateBy actionWithDuration:.5 angle:360]];
    }
}

- (void)reportScore
{
    [[GCHelper sharedInstance] reportScore:realTotal forLeaderboardID:@"highscore"];
}

- (void)endGame
{
    if (realTotal > 0)
    {
        [self reportScore];
    }
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccWHITE]];
}

- (void)addPoints:(int)pass
{
    if (pass == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"MUST PLACE BET" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        realTotal = realTotal + pass;
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
    }
}

- (void)removePoints:(int)pass
{
    if (pass == 0)
    {
        NSLog(@"PRE GAME OVER");
    } else {
        realTotal = realTotal - pass;
        [scoreLabel setString:[NSString stringWithFormat:@"%i", realTotal]];
    }
    if (realTotal <= 0)
    {
        NSLog(@"GAME OVER");
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccWHITE]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"GAME OVER!" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
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
    //WIN SIZE
    CGSize size = [[CCDirector sharedDirector] winSize];
    
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
}

- (void)higher:(id)sender
{
    if (passValue <= 0){
        NSLog(@"PLEASE PLACE BET");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"PLEASE PLACE BET" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        //WIN SIZE
        CGSize size = [[CCDirector sharedDirector] winSize];
        
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
            NSLog(@"DRAW");
            //[self drawPoints];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        } else if (dealerInt > playerInt) {
            NSLog(@"PLAYER WINS");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        } else if (playerInt > dealerInt) {
            NSLog(@"DEALER WINS");
            [self removePoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"wrong.wav"];
        } else {
            NSLog(@"WEIRD");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        }
        //RESET
        [self scheduleOnce:@selector(reset) delay:2];
    }
}

- (void)lower:(id)sender
{
    if (passValue <= 0){
        NSLog(@"PLEASE PLACE BET");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ALERT" message:@"PLEASE PLACE BET" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        //WIN SIZE
        CGSize size = [[CCDirector sharedDirector] winSize];
        
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
            NSLog(@"DRAW");
            //[self drawPoints];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        } else if (dealerInt < playerInt) {
            NSLog(@"PLAYER WINS");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        } else if (playerInt < dealerInt) {
            NSLog(@"DEALER WINS");
            [self removePoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"wrong.wav"];
        } else {
            NSLog(@"WEIRD");
            [self addPoints:passValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.mp3"];
        }
        //RESET
        [self scheduleOnce:@selector(reset) delay:2];
    }
}

- (void)reset
{
    //WIN SIZE
    CGSize size = [[CCDirector sharedDirector] winSize];
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

- (void) dealloc
{
	[super dealloc];
}

@end
