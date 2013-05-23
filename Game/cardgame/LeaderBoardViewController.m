//
//  LeaderBoardViewController.m
//  game
//
//  Created by Mark Evans on 3/27/13.
//  Copyright (c) 2013 Mark Evans. All rights reserved.
//

#import "LeaderBoardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "CustomCell.h"
#import <FacebookSDK/FacebookSDK.h>


@interface LeaderBoardViewController ()

@end

@implementation LeaderBoardViewController
@synthesize scoresTable, textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;

#define REFRESH_HEADER_HEIGHT 52.0f

-(void)setupStrings
{
    textPull = @"Pull down to refresh...";
    textRelease = @"Release to refresh...";
    textLoading = @"Loading...";
}

- (void)addPullToRefreshHeader
{
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:13.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [scoresTable addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scoresTable.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            scoresTable.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        scoresTable.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        scoresTable.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

-(IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    winsize = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
    [self setupStrings];
    [self setTitle:@"Game"];
    AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *t = [defaults objectForKey:@"scoresArray"];
    if (t.count > 0){
        scoresArray = [[NSMutableArray alloc]initWithArray:t];
    } else {
        scoresArray = [[NSMutableArray alloc]initWithArray:app.scoresArray];
    }
    [scoresArray sortUsingSelector:@selector(compare:)];
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    [scoresArray sortUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
}

-(void)refresh
{
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
    @try {
        [scoresTable reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addPullToRefreshHeader];
    
    thenavbar.delegate = self;
    
    //Set Custom NavBar
    UIImage *image = [UIImage imageNamed:@"navbg.png"];
    [[UINavigationBar appearance]setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"shadow.png"]];
    
    [closebtn setShowsTouchWhenHighlighted:YES];
    
    UIImage *headerImage = [UIImage imageNamed:@"logoleaderboard.png"];
    navItem.titleView = [[UIImageView alloc] initWithImage:headerImage];
}

-(void)viewDidUnload
{
    AudioServicesDisposeSystemSoundID(end);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSString *s = @"Top Scores";
        return s;
    }
    return nil;
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return scoresArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    UIView *cellbg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, winsize.size.width, 35)];
    [cellbg setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tablecell.png"]]];
    [cell setBackgroundView:cellbg];
    if (cell != nil)
    {
        AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
        @try {
            NSString *score = [NSString stringWithFormat:@"%@",[scoresArray objectAtIndex:indexPath.row]];
            NSString *detail = app.playerName;
            
            if (detail != nil)
            {
                cell.textLabel.text = detail;
                [cell.textLabel setBackgroundColor:[UIColor clearColor]];
            }
            if (score != nil)
            {
                cell.detailTextLabel.text = score;
                [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
                [cell.detailTextLabel setTextColor:[UIColor redColor]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
