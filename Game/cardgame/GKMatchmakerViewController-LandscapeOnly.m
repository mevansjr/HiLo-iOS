//
//  GKMatchmakerViewController-LandscapeOnly.m
//  CatRace
//


#import "GKMatchmakerViewController-LandscapeOnly.h"

@implementation GKMatchmakerViewController (LandscapeOnly)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

@end
