//
//  GCHelper.h
//  hilo
//
//  Created by Mark Evans on 5/10/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol GCHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
- (void)onLeaderboardViewDismissed;
@end

@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate, GKGameCenterControllerDelegate, GKLeaderboardViewControllerDelegate, MPMediaPickerControllerDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    
    UIViewController *presentingViewController;
    GKMatch *match;
    BOOL matchStarted;
    id <GCHelperDelegate> delegate;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (assign) id <GCHelperDelegate> delegate;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)getCustomLeaderBoard;
- (void)retrieveTopTenScores;
- (void)playTutorial;
- (void) showLeaderboard: (NSString*) leaderboardID;
- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) category;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GCHelperDelegate>)theDelegate;

@end
