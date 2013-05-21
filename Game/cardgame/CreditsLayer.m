//
//  CreditsLayer.m
//  hilo
//
//  Created by Mark Evans on 5/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CreditsLayer.h"
#import "SimpleAudioEngine.h"
#import "MenuLayer.h"

#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds ].size.height - (double)568) < DBL_EPSILON)

@implementation CreditsLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	CreditsLayer *layer = [CreditsLayer node];
	[scene addChild: layer];
	return scene;
}

-(void) onEnter
{
    [super onEnter];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"clapping.mp3"];
}

-(void) onExit
{
    [super onExit];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"clapping.mp3"];
}

-(id) init
{
    if( (self=[super init]) ) {
        //WIN SIZE
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //SPLASH BACKGROUND
        if (IS_IPHONE_5) {
            background = [CCSprite spriteWithFile:@"blank_bg-568@2x.png"];
            background.rotation = 90;
        } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            background = [CCSprite spriteWithFile:@"blank_bg.png"];
            background.rotation = 90;
        }
        background.position = ccp(size.width/2, size.height/2);
        [self addChild: background];
        
        //CREDITS
        CCMenuItemSprite *gameCreditsImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"gamecredits.png"] selectedSprite:[CCSprite spriteWithFile:@"gamecredits.png"]];
        CCMenuItemFont *createdBy = [CCMenuItemFont itemWithString:@"Created by: Mark Evans"];
        [createdBy setFontSize:22];
        CCMenuItemFont *musicBy = [CCMenuItemFont itemWithString:@"Music provided by: SoundBible.com"];
        [musicBy setFontSize:18];
        CCMenuItemFont *graphicsBy = [CCMenuItemFont itemWithString:@"Graphics provided by: Mark Evans"];
        [graphicsBy setFontSize:18];
        CCMenuItemSprite *startGameImage = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"backtogame.png"] selectedSprite:[CCSprite spriteWithFile:@"backtogameOn.png"] target:self selector:@selector(buttonAction:)];
        
        //CREDIT MENU
        CCMenu *myMenu = [CCMenu menuWithItems:gameCreditsImage, createdBy, musicBy, graphicsBy, startGameImage, nil];
        [myMenu setPosition:ccp(size.width/2,size.height/2)];
        [myMenu alignItemsVerticallyWithPadding:15.0];
        [self addChild:myMenu z:1];
        
        [self performSelector:@selector(playEffect) withObject:nil afterDelay:1];
    }
    return self;
}

- (void)playEffect
{
    //LOAD EFFECT
    [[SimpleAudioEngine sharedEngine] playEffect:@"clapping.mp3"];
}

- (void)buttonAction:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccWHITE]];
}

@end
