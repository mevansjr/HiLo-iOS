//
//  IntroLayer.m
//  cardgame
//
//  Created by Mark Evans on 5/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "IntroLayer.h"
#import "MenuLayer.h"
#import "SimpleAudioEngine.h"

#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds ].size.height - (double)568) < DBL_EPSILON)
#pragma mark - IntroLayer

@implementation IntroLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	IntroLayer *layer = [IntroLayer node];
	[scene addChild: layer];
	return scene;
}

// 
-(void) onEnter
{
	[super onEnter];
    
    //LOAD BACKGROUND MUSIC
    [[SimpleAudioEngine sharedEngine] playEffect:@"startup2.wav" ];

    //WIN SIZE
	CGSize size = [[CCDirector sharedDirector] winSize];
    
    //SPLASH BACKGROUND
	if (IS_IPHONE_5) {
        background = [CCSprite spriteWithFile:@"blank_bg-568@2x.png"];
        background.rotation = 90;
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        background = [CCSprite spriteWithFile:@"blank_bg.png"];
        background.rotation = 90;
    } else {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);
	[self addChild: background];
    
    //SET SPRITE SHEETS
    if (IS_IPHONE_5) {
        CCTexture2D *iphone5_tex = [[CCTextureCache sharedTextureCache] addImage:@"splashtex@2x.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"splashtex@2x.plist" texture:iphone5_tex];
        spriteSheet = [CCSpriteBatchNode batchNodeWithTexture:iphone5_tex];
        [self addChild:spriteSheet];
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:@"splashtex.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"splashtex.plist" texture:tex];
        spriteSheet = [CCSpriteBatchNode batchNodeWithTexture:tex];
        [self addChild:spriteSheet];
    }
    
    //LOGO ANIMATION
    NSMutableArray *logoFrames = [NSMutableArray array];
    if (IS_IPHONE_5) {
        for (int i=1; i<=5; i++) {
            [logoFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"splashlogo_%d@2x.png",i]]];
            CCAnimation *logoAnim = [CCAnimation animationWithSpriteFrames:logoFrames delay:0.3f];
            CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"splashlogo_1@2x.png"];
            logo.position = ccp(size.width/2, size.height/2);
            CCAction *logoAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:logoAnim]];
            [logo runAction:logoAction];
            [spriteSheet addChild:logo];
        }
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        for (int i=1; i<=5; i++) {
            [logoFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"splashlogo_%d.png",i]]];
            CCAnimation *logoAnim = [CCAnimation animationWithSpriteFrames:logoFrames delay:0.1f];
            CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"splashlogo_1.png"];
            logo.position = ccp(size.width/2, size.height/2);
            CCAction *logoAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:logoAnim]];
            [logo runAction:logoAction];
            [spriteSheet addChild:logo];
        }
    }
	
	[self scheduleOnce:@selector(makeTransition:) delay:1];
}

-(void) makeTransition:(ccTime)dt
{
    [[SimpleAudioEngine sharedEngine] stopEffect:@"startup2.wav"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MenuLayer scene] withColor:ccWHITE]];
}
@end
